hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
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

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function()
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

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up", function()
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

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Down", function()
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

hs.hotkey.bind({"cmd", "alt", "shift"}, "M", function()
  local cmd="~/.pyenv/shims/mina show 1 -q"
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  hs.eventtap.keyStrokes(("%06d"):format(result))
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end)

--- -- -- -- -- -- -- -- -- -- -- --
-- Center window in display 50/50 --
--- -- -- -- -- -- -- -- -- -- -- --
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "K", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w / 4
  f.y = max.h / 4
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f)
end)

--- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
-- Center window in display with 4/5 of height --
--- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "K", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w / 4
  f.y = max.h / 10 - 25
  f.w = max.w / 2
  f.h = 4 * max.h / 5 + 5
  win:setFrame(f)
end)

-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
--   MicMute:toggleMicMute()
-- end)

-- hs.hotkey.bind({}, "Tab", function()
--   local windowTitle = hs.window.focusedWindow():title()
--   if string.find(windowTitle, " - Google Docs") then
--     hs.eventtap.keyStrokes("    ")
--   else
--     hs.eventtap.keyStroke({}, "Tab")
--   end
-- end)

-- doKeyStroke = function(modifiers, character)
--   local event = require("hs.eventtap").event
--   event.newKeyEvent(modifiers, string.lower(character), true):post()
--   event.newKeyEvent(modifiers, string.lower(character), false):post()
-- end

-- hs.hotkey.bind({"Alt"}, "Tab", function()
--   doKeyStroke({}, "Delete")
--   doKeyStroke({}, "Delete")
--   doKeyStroke({}, "Delete")
--   doKeyStroke({}, "Delete")
-- end)

hs.loadSpoon("MicMute")
spoon.MicMute:bindHotkeys({toggle={{},"F1"}}, 0.75)

hs.hotkey.bind({"cmd", "alt"}, "V", function()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

hs.hotkey.bind({"ctrl", "alt"}, "C", function()
  local file = assert(io.open("/tmp/pastebin.txt", "a"))
  file:write(hs.pasteboard.getContents() .. "\n")
  file:close()
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

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Home", move_left_init, nil, move_left)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "End", move_right_init, nil, move_right)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "PageUp", move_up_init, nil, move_up)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "PageDown", move_down_init, nil, move_down)

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

hs.hotkey.bind({"cmd", "alt"}, "Home", resize_left_init, nil, resize_left)
hs.hotkey.bind({"cmd", "alt"}, "End", resize_right_init, nil, resize_right)
hs.hotkey.bind({"cmd", "alt"}, "PageUp", resize_up_init, nil, resize_up)
hs.hotkey.bind({"cmd", "alt"}, "PageDown", resize_down_init, nil, resize_down)
