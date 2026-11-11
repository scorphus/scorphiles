local hotkey = require "Modules/hotkey"
-- ⌃⌥ J / K: smooth scroll down / up while held, in the focused window.
--   Ghostty + tmux: scrolls the active tmux pane through tmux itself, the same
--                   way tmux handles the mouse wheel (the pointer isn't used).
--                   Ghostty is assumed to run tmux: while any tmux client is
--                   attached, a Ghostty window without tmux scrolls that pane too.
--   other apps:     at the pointer if it's inside the focused window,
--                   otherwise at the center of the focused window
-- ⌃⌥⇧ J / K: same scroll, once, in a much bigger chunk

local M = { hotkeys = {} }

local PAGE_LINES = 20   -- tmux: roughly a screenful
local PAGE_PIXELS = 600 -- other apps: a big jump

local mods = { "ctrl", "alt" }

local GHOSTTY = "com.mitchellh.ghostty"

-- tmux command; tests can append socket arguments (e.g. "-L", "name")
M.tmux = { "/opt/homebrew/bin/tmux" }

local MAX_SECONDS = 15 -- safety net: stop scrolling after this long even if held

-- Apps: smooth pixel scrolling
local TICK = 1 / 60    -- seconds between scroll steps (60 per second)
local SPEED_START = 6  -- px per step when the key goes down
local SPEED_MAX = 30   -- px per step at full speed
local ACCEL = 0.6      -- px added per step while held

-- tmux: terminals scroll by lines; each step runs one short tmux command (~3 ms)
local TMUX_TICK = 0.05 -- seconds between steps (20 per second)
local LINES_START = 1  -- lines per step when the key goes down
local LINES_MAX = 3    -- lines per step at full speed
local LINES_ACCEL = 0.1

---------------------------------------------------------------------------
-- tmux

-- Active pane of the most recently used tmux client; nil if tmux isn't running
function M.tmuxPane()
  local out, ok = hs.execute(table.concat(M.tmux, " ") .. " list-clients -F"
    .. " '#{client_activity} #{pane_id} #{pane_in_mode} #{alternate_on}"
    .. " #{mouse_any_flag} #{mouse_sgr_flag} #{pane_width} #{pane_height}"
    .. " #{pane_current_command}' 2>/dev/null")
  if not ok or not out then return nil end

  local best, bestActivity
  for line in out:gmatch("[^\n]+") do
    local activity, id, inMode, alternate, mouse, sgr, width, height, command =
      line:match("^(%d+) (%%%d+) (%d) (%d) (%d) (%d) (%d+) (%d+) (.*)$")
    if activity and (not bestActivity or tonumber(activity) > bestActivity) then
      bestActivity = tonumber(activity)
      best = {
        id = id,
        inMode = inMode == "1",
        alternate = alternate == "1",
        mouse = mouse == "1",
        sgr = sgr == "1",
        width = tonumber(width),
        height = tonumber(height),
        command = command,
      }
    end
  end
  return best
end

-- tmux arguments for one scroll step of n lines (direction 1 = up, -1 = down),
-- mirroring tmux's own mouse wheel handling:
--   scroll mode, or a plain shell -> tmux scroll mode (closes again at the bottom)
--   app that takes the mouse      -> wheel events to the app (Claude, nvim)
--     nvim gets Alt+wheel, which keymaps.lua maps to "scroll the current
--     window" (a plain wheel would scroll the window under the event position)
--   full-screen app without mouse -> Up/Down keys (less, man)
function M.tmuxArgs(pane, direction, n)
  local count = tostring(n)

  if pane.inMode or not (pane.alternate or pane.mouse) then
    if direction > 0 then
      return { "copy-mode", "-e", "-t", pane.id, ";",
               "send-keys", "-X", "-t", pane.id, "-N", count, "scroll-up" }
    end
    -- Only scroll down while in scroll mode; don't re-enter it at the bottom
    return { "if-shell", "-F", "-t", pane.id, "#{pane_in_mode}",
             "send-keys -X -t " .. pane.id .. " -N " .. count .. " scroll-down" }
  end

  if pane.mouse then
    local button = direction > 0 and 64 or 65 -- wheel up / down
    if pane.command == "nvim" then button = button + 8 end -- + Alt
    local x = math.max(1, pane.width // 2)
    local y = math.max(1, pane.height // 2)
    local event
    if pane.sgr then
      event = string.format("\27[<%d;%d;%dM", button, x, y)
    else -- legacy encoding: single bytes, keep them in the ASCII range
      event = "\27[M" .. string.char(32 + button, 32 + math.min(x, 94), 32 + math.min(y, 94))
    end
    -- nvim drops some wheel events when several arrive at once, so it gets
    -- exactly one per step (= 3 lines via keymaps.lua)
    local events = pane.command == "nvim" and 1 or n
    return { "send-keys", "-l", "-t", pane.id, string.rep(event, events) }
  end

  return { "send-keys", "-t", pane.id, "-N", count, direction > 0 and "Up" or "Down" }
end

-- Runs in the background; skipped while the previous step is still running,
-- so steps never pile up
local running

function M.tmuxStep(pane, direction, n)
  if running and running:isRunning() then return end
  local args = {}
  for i = 2, #M.tmux do args[#args + 1] = M.tmux[i] end
  for _, arg in ipairs(M.tmuxArgs(pane, direction, n)) do args[#args + 1] = arg end
  running = hs.task.new(M.tmux[1], nil, args)
  running:start()
end

---------------------------------------------------------------------------
-- Other apps

-- Screen position to scroll at in the given window
function M.target(win)
  local frame = win:frame()
  local pointer = hs.geometry.point(hs.mouse.absolutePosition())
  if pointer:inside(frame) then return pointer end
  return frame.center
end

-- One scroll step at a screen position; dy > 0 scrolls up, dy < 0 down.
-- macOS only delivers scroll events posted system-wide (sending them to the
-- app directly is ignored), and that moves the pointer to the target, so the
-- pointer is put straight back after each step.
-- No modifier flags, so the held ⌃⌥ doesn't turn it into a zoom.
function M.step(target, dy)
  local pointer = hs.mouse.absolutePosition()
  local event = hs.eventtap.event.newScrollEvent({ 0, dy }, {}, "pixel")
  event:location(target)
  event:post()
  hs.mouse.absolutePosition(pointer)
end

---------------------------------------------------------------------------
-- Hold to scroll

local timer

local function stop()
  if timer then
    timer:stop()
    timer = nil
  end
end

-- Runs tick right away, then every interval until J/K is released (hotkey
-- release callback). Checking the held modifiers doesn't work here: macOS
-- reports the flags of the last posted event, i.e. our own scroll events.
local function repeatWhileHeld(interval, tick)
  local started = hs.timer.secondsSinceEpoch()
  tick()
  timer = hs.timer.doEvery(interval, function()
    if hs.timer.secondsSinceEpoch() - started > MAX_SECONDS then return stop() end
    tick()
  end)
end

local function start(direction)
  stop()
  local win = hs.window.focusedWindow()
  if not win then return end

  local app = win:application()
  if app and app:bundleID() == GHOSTTY then
    local pane = M.tmuxPane()
    if pane then
      local lines = LINES_START
      return repeatWhileHeld(TMUX_TICK, function()
        M.tmuxStep(pane, direction, math.floor(lines))
        lines = math.min(lines + LINES_ACCEL, LINES_MAX)
      end)
    end
  end

  local target = M.target(win)
  local speed = SPEED_START
  repeatWhileHeld(TICK, function()
    M.step(target, direction * math.floor(speed))
    speed = math.min(speed + ACCEL, SPEED_MAX)
  end)
end

M.hotkeys.j = hotkey.bind(mods, "j", "Scroll down while held", function() start(-1) end, stop)
M.hotkeys.k = hotkey.bind(mods, "k", "Scroll up while held", function() start(1) end, stop)

---------------------------------------------------------------------------
-- Page scroll: same targeting as the line scroll, in a much bigger chunk,
-- repeating at its own (slower) pace while held

local PAGE_TICK = 0.05 -- seconds between page jumps

local pageTimer

local function stopPage()
  if pageTimer then
    pageTimer:stop()
    pageTimer = nil
  end
end

local function startPage(direction)
  stopPage()
  local win = hs.window.focusedWindow()
  if not win then return end

  local tick
  local app = win:application()
  if app and app:bundleID() == GHOSTTY then
    local pane = M.tmuxPane()
    if pane then
      tick = function() M.tmuxStep(pane, direction, PAGE_LINES) end
    end
  end
  if not tick then
    local target = M.target(win)
    tick = function() M.step(target, direction * PAGE_PIXELS) end
  end

  local started = hs.timer.secondsSinceEpoch()
  tick()
  pageTimer = hs.timer.doEvery(PAGE_TICK, function()
    if hs.timer.secondsSinceEpoch() - started > MAX_SECONDS then return stopPage() end
    tick()
  end)
end

M.hotkeys.pageDown = hotkey.bind({ "ctrl", "alt", "shift" }, "j", "Scroll down a page", { "page" }, function() startPage(-1) end, stopPage)
M.hotkeys.pageUp = hotkey.bind({ "ctrl", "alt", "shift" }, "k", "Scroll up a page", { "page" }, function() startPage(1) end, stopPage)

return M
