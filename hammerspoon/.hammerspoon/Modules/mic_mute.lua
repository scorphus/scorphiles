local icon = require "Modules/menubar_icon"

local function mic(...)
  return icon.image(11, {
    { type = "rectangle", action = "fill", fillColor = icon.black, frame = { x = 3, y = 0.3, w = 5, h = 9.5 }, roundedRectRadii = { xRadius = 2.5, yRadius = 2.5 } },
    icon.line(1.4, { x = 1, y = 6.5 }, { x = 5.5, y = 12.6, c1x = 1, c1y = 10.2, c2x = 3, c2y = 12.6 }, { x = 10, y = 6.5, c1x = 8, c1y = 12.6, c2x = 10, c2y = 10.2 }),
    icon.line(1.4, { x = 5.5, y = 12.6 }, { x = 5.5, y = 15 }),
    icon.line(1.4, { x = 3, y = 15 }, { x = 8, y = 15 }),
    ...
  })
end

local micOn = mic()
local micMuted = mic(icon.slash(1.2, 1.2, 9.8, 14.8))

hs.loadSpoon("MicMute")
spoon.MicMute:bindHotkeys({ toggle = { {}, "F1" } }, 0.75)
spoon.MicMute.hotkey.msg = "F1: Toggle microphone, hold to talk"
spoon.MicMute.hotkey.tags = { "mic mute", "microphone", "audio" }
spoon.MicMute:bindVisibilitySetter(function(muted)
  spoon.MicMute.mute_menu:setTitle(nil)
  spoon.MicMute.mute_menu:setIcon(muted and micMuted or micOn)
end)
