local hotkey = require "Modules/hotkey"

-- the Caps Lock key is remapped to Escape in macOS, so ⌘ + Caps Lock arrives as ⌘ + Escape
hotkey.bind({ "cmd" }, "escape", "Caps Lock on/off", { "keyboard" }, function()
  hs.alert.show(hs.hid.capslock.toggle() and "Caps Lock on" or "Caps Lock off", 1)
end)
