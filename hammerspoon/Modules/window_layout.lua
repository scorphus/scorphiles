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
