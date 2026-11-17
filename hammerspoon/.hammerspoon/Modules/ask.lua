-- `ask` (bin/ask) writes a Claude prompt in Zed: hammerspoon://ask-place puts that Zed window over
-- the tmux pane `ask` runs in, hammerspoon://ask-done closes it and gives the terminal back
local ZED = "Zed Dev"
local TITLE = "prompt.md"

local terminal, behind, prompt

local function promptWindow()
  local app = hs.application.get(ZED)
  if not app then return nil end
  for _, w in ipairs(app:allWindows()) do
    if w:title():find(TITLE, 1, true) then return w end
  end
end

-- the terminal has no title bar, so its frame divides evenly into tmux's columns and rows
hs.urlevent.bind("ask-place", function(_, p)
  terminal = hs.window.focusedWindow()
  if not terminal then return end
  -- the first non-Zed window under the terminal, as it was before Zed came forward
  behind = nil
  for _, w in ipairs(hs.window.orderedWindows()) do
    if w ~= terminal and w:application():name() ~= ZED then
      behind = w
      break
    end
  end
  local f = terminal:frame()
  local cw, ch = f.w / tonumber(p.cols), f.h / tonumber(p.rows)
  local rect = hs.geometry.rect(f.x + cw * p.left, f.y + ch * p.top, cw * p.width, ch * p.height)
  local tries = 0
  hs.timer.waitUntil(function()
    tries = tries + 1
    prompt = promptWindow()
    return prompt ~= nil or tries > 200
  end, function()
    if not prompt then return end
    prompt:setFrame(rect, 0)
    -- Zed coming forward raises all its windows, which the terminal's transparency shows: the window
    -- that was under the terminal goes back over them, then the terminal, then only the prompt
    if behind then behind:focus() end
    terminal:focus()
    prompt:focus()
  end, 0.05)
end)

hs.urlevent.bind("ask-done", function()
  if prompt then prompt:close() end
  if terminal then terminal:focus() end
  prompt, terminal, behind = nil, nil, nil
end)
