hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = f.y
  f.w = max.w / 2
  f.h = f.h
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = f.y
  f.w = max.w / 3
  f.h = f.h
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = f.y
  f.w = max.w / 2
  f.h = f.h
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (2 * max.w / 3)
  f.y = f.y
  f.w = max.w / 3
  f.h = f.h
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = f.x
  f.y = max.y
  f.w = f.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = f.x
  f.y = max.y + max.h / 2
  f.w = f.w
  f.h = max.h / 2
  win:setFrame(f)
end)

function moveWindowToDisplay(d)
  return function()
    local displays = hs.screen.allScreens()
    local win = hs.window.focusedWindow()
    win:moveToScreen(displays[d], false, true)
  end
end

hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "Up", moveWindowToDisplay(1))
hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "Down", moveWindowToDisplay(2))

-- hs.hotkey.bind({"cmd", "alt", "shift"}, "M", function()
--   local cmd="~/.pyenv/shims/mina show 1 -q"
--   local handle = io.popen(cmd)
--   local result = handle:read("*a")
--   handle:close()
--   hs.eventtap.keyStrokes(("%06d"):format(result))
-- end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "M", function()
  local win = hs.window.focusedWindow()
  win:moveToUnit('[0,0,100,100]')
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "M", function()
  local win = hs.window.focusedWindow()
  win:moveToUnit('[33.3,0,66.7,100]')
end)

--- -- -- -- -- -- -- -- -- -- -- --
-- Center window in display 50/50 --
--- -- -- -- -- -- -- -- -- -- -- --
hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "K", function()
  local frame_width = hs.screen.mainScreen():frame().w
  local win = hs.window.focusedWindow()
  if frame_width == 3840 then
    win:moveToUnit('[25,25,75,75]')
  else
    win:moveToUnit('[15,7,85,82]')
  end
end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Place window on a "nice to look at" position --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "K", function()
  local frame_width = hs.screen.mainScreen():frame().w
  local win = hs.window.focusedWindow()
  if frame_width == 3840 then
    win:moveToUnit('[15,7,85,82]')
  else
    win:moveToUnit('[15,0,85,94]')
  end
end)

-- -- -- -- -- -- -- -- -- --
-- Mute microphone with F1 --
-- -- -- -- -- -- -- -- -- --
hs.loadSpoon("MicMute")
spoon.MicMute:bindHotkeys({ toggle = { {}, "F1" } }, 0.75)
spoon.MicMute:bindVisibilitySetter(function(muted)
  spoon.MicMute.mute_menu:setTitle(muted and "📵" or "🎙")
end)

-- -- -- -- -- -- --
-- -- ColorPicker --
-- -- -- -- -- -- --
local function pickColor()
  local bin = os.getenv("HOME") .. "/.hammerspoon/helpers/colorpicker"
  hs.task.new(bin, function(exitCode, stdout, stderr)
    local hex = stdout and stdout:match("#%x%x%x%x%x%x")
    if hex then
      hs.pasteboard.setContents(hex)
      hs.alert.show("Copied " .. hex)
    end
  end):start()
end

hs.hotkey.bind({"cmd", "shift", "ctrl"}, "P", pickColor)

colorPickerMenu = hs.menubar.new()
colorPickerMenu:setTitle("🎨")
colorPickerMenu:setTooltip("Pick a color (⌘⇧⌃P)")
colorPickerMenu:setClickCallback(pickColor)

-- --- -- -- -- -- --
-- -- Time Tracker --
-- --- -- -- -- -- --

-- local clocking = require "Modules/clocking"
-- dateTimeGarbageCollectorPreventer = clocking.init()

--- -- -- -- -- -- ---
-- Replace Caffeine --
--- -- -- -- -- -- ---
caffeine = require "Modules/caffeine"

hs.hotkey.bind({ "cmd", "alt" }, "V", function()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Clipboard history (⌃⌥C save, ⌃⌥V recall, Backspace deletes)    --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local pastebin = hs.configdir .. "/pastebin.txt"
local CLIP_SEP = "\30\n"  -- record separator (\30) + newline: multi-line-safe, still readable

-- Read all history entries (original order), oldest first
local function readClipEntries()
  local file = io.open(pastebin, "r")
  if not file then return {} end
  local data = file:read("*a")
  file:close()
  local entries = {}
  for entry in data:gmatch("(.-)" .. CLIP_SEP) do
    table.insert(entries, entry)
  end
  return entries
end

-- Overwrite the history file with the given entries
local function writeClipEntries(entries)
  local file = assert(io.open(pastebin, "w"))
  for _, entry in ipairs(entries) do
    file:write(entry .. CLIP_SEP)
  end
  file:close()
end

-- Build chooser rows: most-recent first, de-duped, single-line preview
local function buildClipChoices(entries)
  local seen, choices = {}, {}
  for i = #entries, 1, -1 do
    local clip = entries[i]
    if clip ~= "" and not seen[clip] then
      seen[clip] = true
      local preview = clip:gsub("%s+", " "):gsub("^%s+", "")
      if #preview > 80 then preview = preview:sub(1, 80) .. "…" end
      table.insert(choices, { text = preview, clip = clip })
    end
  end
  return choices
end

-- Save the current clipboard to the history file
hs.hotkey.bind({ "ctrl", "alt" }, "C", function()
  local clip = hs.pasteboard.getContents()
  if not clip or clip == "" then return end
  local file = assert(io.open(pastebin, "a"))
  file:write(clip .. CLIP_SEP)
  file:close()
  hs.alert.show("Saved to clipboard history")
end)

-- Pick an entry from the history; selection is copied back to the clipboard
local clipChoices = {}
local clipChooser = hs.chooser.new(function(choice)
  if choice then
    hs.pasteboard.setContents(choice.clip)
    hs.alert.show("Copied to clipboard")
  end
end)

-- While the chooser is open: Backspace on an empty query deletes the
-- highlighted entry from the history (with text in the query it edits the query)
local clipDeleteTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
  if e:getKeyCode() ~= hs.keycodes.map["delete"] then return false end
  if (clipChooser:query() or "") ~= "" then return false end
  local item = clipChoices[clipChooser:selectedRow()]
  if not item then return true end
  local kept = {}
  for _, entry in ipairs(readClipEntries()) do
    if entry ~= item.clip then table.insert(kept, entry) end
  end
  writeClipEntries(kept)
  clipChoices = buildClipChoices(kept)
  clipChooser:choices(clipChoices)
  return true
end)
clipChooser:showCallback(function() clipDeleteTap:start() end)
clipChooser:hideCallback(function() clipDeleteTap:stop() end)

hs.hotkey.bind({ "ctrl", "alt" }, "V", function()
  clipChoices = buildClipChoices(readClipEntries())
  if #clipChoices == 0 then
    hs.alert.show("No clipboard history yet")
    return
  end
  clipChooser:choices(clipChoices)
  clipChooser:query("")
  clipChooser:show()
end)

--- -- -- -- -- -- -- --
-- Move window around --
--- -- -- -- -- -- -- --
local move_by_min = 1
local move_by_max = 25
local move_by = 1

function move_hor_ver(dx, dy)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x + dx
  f.y = f.y + dy
  win:setFrame(f)
  if move_by < move_by_max then
    move_by = move_by * 1.2
  end
end

function move_hor_ver_init()
  move_by = move_by_min
end

function move_right_init()
  move_hor_ver_init()
  move_right()
end

function move_right()
  move_hor_ver(move_by, 0)
end

function move_left_init()
  move_hor_ver_init()
  move_left()
end

function move_left()
  move_hor_ver(-move_by, 0)
end

function move_up_init()
  move_hor_ver_init()
  move_up()
end

function move_up()
  move_hor_ver(0, -move_by)
end

function move_down_init()
  move_hor_ver_init()
  move_down()
end

function move_down()
  move_hor_ver(0, move_by)
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Home", move_left_init, nil, move_left)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "End", move_right_init, nil, move_right)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "PageUp", move_up_init, nil, move_up)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "PageDown", move_down_init, nil, move_down)

-- -- -- -- -- -- -- -- --
-- Resize window around --
-- -- -- -- -- -- -- -- --
local resize_by_min = 1
local resize_by_max = 25
local resize_by = 1

function resize_hor_ver(dw, dh)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.w = f.w + dw
  f.h = f.h + dh
  win:setFrame(f)
  if resize_by < resize_by_max then
    resize_by = resize_by * 1.2
  end
end

function resize_hor_ver_init()
  resize_by = resize_by_min
end

function resize_right_init()
  resize_hor_ver_init()
  resize_right()
end

function resize_right()
  resize_hor_ver(resize_by, 0)
end

function resize_left_init()
  resize_hor_ver_init()
  resize_left()
end

function resize_left()
  resize_hor_ver(-resize_by, 0)
end

function resize_up_init()
  resize_hor_ver_init()
  resize_up()
end

function resize_up()
  resize_hor_ver(0, -resize_by)
end

function resize_down_init()
  resize_hor_ver_init()
  resize_down()
end

function resize_down()
  resize_hor_ver(0, resize_by)
end

hs.hotkey.bind({ "cmd", "alt" }, "Home", resize_left_init, nil, resize_left)
hs.hotkey.bind({ "cmd", "alt" }, "End", resize_right_init, nil, resize_right)
hs.hotkey.bind({ "cmd", "alt" }, "PageUp", resize_up_init, nil, resize_up)
hs.hotkey.bind({ "cmd", "alt" }, "PageDown", resize_down_init, nil, resize_down)

-- hs.window.highlight.ui.overlay = false
-- hs.window.highlight.ui.overlayColor = { 0.2, 0.05, 0, 0.2 }
-- hs.window.highlight.start()


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Window hints: icon + letter overlay, type to focus     --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Home-row-first key order
local hintChars = {
  "A", "S", "D", "F", "J", "K", "L", "E", "I", "G", "H", "C", "M",
  "R", "U", "W", "O", "V", "N", "T", "Y", "B", "P", "Q", "X", "Z",
}

local hintCanvases = {}
local hintModal = nil

local function clearHints()
  for _, c in ipairs(hintCanvases) do c:delete() end
  hintCanvases = {}
  if hintModal then hintModal:exit() end
end

-- Custom hints: app icon on the left, hint letter on the right of it.
-- Windows are labelled front-to-back (z-order) in the home-row key order.
local function showWindowHints()
  clearHints()
  hintModal = hs.hotkey.modal.new()
  hintModal:bind({}, "escape", clearHints)

  local iconSize, pad, fontSize, letterW = 64, 14, 48, 48
  local boxW = pad + iconSize + pad + letterW + pad
  local boxH = iconSize + pad * 2
  local gap = 8

  local function drawHint(win, ch, x, y)
    local c = hs.canvas.new({ x = x, y = y, w = boxW, h = boxH })
    c[#c + 1] = {
      type = "rectangle", action = "fill",
      roundedRectRadii = { xRadius = 10, yRadius = 10 },
      fillColor = { red = 0, green = 0, blue = 0, alpha = 0.82 },
    }
    local app = win:application()
    local icon = app and app:bundleID() and hs.image.imageFromAppBundle(app:bundleID())
    if icon then
      c[#c + 1] = { type = "image", image = icon, frame = { x = pad, y = pad, w = iconSize, h = iconSize } }
    end
    c[#c + 1] = {
      type = "text", text = ch, textColor = { white = 1, alpha = 1 },
      textSize = fontSize, textAlignment = "center",
      frame = { x = pad + iconSize + pad, y = (boxH - fontSize * 1.25) / 2, w = letterW, h = fontSize * 1.4 },
    }
    c:level(hs.canvas.windowLevels.overlay)
    c:show()
    hintCanvases[#hintCanvases + 1] = c

    hintModal:bind({}, ch, function()
      clearHints()
      win:focus()
    end)
  end

  -- Assign a letter per window (z-order) and group windows by shared centre
  local groups, order = {}, {}
  for i, win in ipairs(hs.window.orderedWindows()) do
    local ch = hintChars[i]
    if not ch then break end
    local f = win:frame()
    local cx, cy = f.x + f.w / 2, f.y + f.h / 2
    local key = math.floor(cx / 20) .. "," .. math.floor(cy / 20)
    local g = groups[key]
    if not g then g = { cx = cx, cy = cy, items = {} }; groups[key] = g; order[#order + 1] = g end
    g.items[#g.items + 1] = { win = win, ch = ch }
  end

  -- Draw each group stacked vertically, centred on the shared centre
  for _, g in ipairs(order) do
    local n = #g.items
    local totalH = n * boxH + (n - 1) * gap
    local startY = g.cy - totalH / 2
    for idx, it in ipairs(g.items) do
      drawHint(it.win, it.ch, g.cx - boxW / 2, startY + (idx - 1) * (boxH + gap))
    end
  end

  if #hintCanvases == 0 then return end
  hintModal:enter()
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "H", showWindowHints)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- App launcher / focus  (⌘⌃ + key)           --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local apps = {
  ["Return"] = "Ghostty",   -- ⌘⌃↵  terminal
  ["B"]      = "Firefox",   -- ⌘⌃B  browser
  ["F"]      = "Firefox",   -- ⌘⌃F  browser (alias)
  ["E"]      = "Zed",       -- ⌘⌃E  editor
  ["Z"]      = "Zed",       -- ⌘⌃Z  editor (alias)
  ["S"]      = "Slack",     -- ⌘⌃S  chat
  ["L"]      = "Linear",    -- ⌘⌃L  issues
  ["M"]      = "Spotify",   -- ⌘⌃M  music
  ["P"]      = "Preview",   -- ⌘⌃P  preview
}
for key, app in pairs(apps) do
  hs.hotkey.bind({ "cmd", "ctrl" }, key, function() hs.application.launchOrFocus(app) end)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Auto-reload config when any .lua changes --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local function reloadConfig(files)
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end
configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config loaded")
