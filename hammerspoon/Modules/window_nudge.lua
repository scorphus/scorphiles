local hotkey = require "Modules/hotkey"
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

hotkey.bind({ "cmd", "alt", "ctrl" }, "Home", "Nudge window left", move_left_init, nil, move_left)
hotkey.bind({ "cmd", "alt", "ctrl" }, "End", "Nudge window right", move_right_init, nil, move_right)
hotkey.bind({ "cmd", "alt", "ctrl" }, "PageUp", "Nudge window up", move_up_init, nil, move_up)
hotkey.bind({ "cmd", "alt", "ctrl" }, "PageDown", "Nudge window down", move_down_init, nil, move_down)

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

hotkey.bind({ "cmd", "alt" }, "Home", "Resize window left", resize_left_init, nil, resize_left)
hotkey.bind({ "cmd", "alt" }, "End", "Resize window right", resize_right_init, nil, resize_right)
hotkey.bind({ "cmd", "alt" }, "PageUp", "Resize window up", resize_up_init, nil, resize_up)
hotkey.bind({ "cmd", "alt" }, "PageDown", "Resize window down", resize_down_init, nil, resize_down)
