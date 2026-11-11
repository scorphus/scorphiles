local hotkey = require "Modules/hotkey"
hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", "Window to left half", { "windows", "snap" }, function()
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

hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "Left", "Window to left third", { "windows", "snap" }, function()
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

hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", "Window to right half", { "windows", "snap" }, function()
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

hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "Right", "Window to right third", { "windows", "snap" }, function()
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

hotkey.bind({ "cmd", "alt", "ctrl" }, "Up", "Window to top half", { "windows", "snap" }, function()
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

hotkey.bind({ "cmd", "alt", "ctrl" }, "Down", "Window to bottom half", { "windows", "snap" }, function()
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

hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "Up", "Window to display 1", { "windows", "display", "monitor" }, moveWindowToDisplay(1))
hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "Down", "Window to display 2", { "windows", "display", "monitor" }, moveWindowToDisplay(2))

hotkey.bind({ "cmd", "alt", "ctrl" }, "M", "Window full screen", { "windows", "snap" }, function()
  local win = hs.window.focusedWindow()
  win:moveToUnit('[0,0,100,100]')
end)

hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "M", "Window to right two thirds", { "windows", "snap" }, function()
  local win = hs.window.focusedWindow()
  win:moveToUnit('[33.3,0,66.7,100]')
end)

--- -- -- -- -- -- -- -- -- -- -- --
-- Center window in display 50/50 --
--- -- -- -- -- -- -- -- -- -- -- --
hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "K", "Window centred, small", { "windows", "snap" }, function()
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
hotkey.bind({ "cmd", "alt", "ctrl" }, "K", "Window centred, large", { "windows", "snap" }, function()
  local frame_width = hs.screen.mainScreen():frame().w
  local win = hs.window.focusedWindow()
  if frame_width == 3840 then
    win:moveToUnit('[15,7,85,82]')
  else
    win:moveToUnit('[15,0,85,94]')
  end
end)
