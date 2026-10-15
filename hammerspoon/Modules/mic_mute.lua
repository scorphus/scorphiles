hs.loadSpoon("MicMute")
spoon.MicMute:bindHotkeys({ toggle = { {}, "F1" } }, 0.75)
spoon.MicMute.hotkey.msg = "F1: Toggle microphone, hold to talk"
spoon.MicMute:bindVisibilitySetter(function(muted)
  spoon.MicMute.mute_menu:setTitle(muted and "📵" or "🎙")
end)
