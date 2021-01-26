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

hs.loadSpoon("MicMute")
spoon.MicMute:bindHotkeys({toggle={{},"F1"}}, 0.75)

hs.hotkey.bind({"ctrl", "alt"}, "C", function()
  local file = assert(io.open("/tmp/pastebin.txt", "a"))
  file:write(hs.pasteboard.getContents() .. "\n")
  file:close()
end)
