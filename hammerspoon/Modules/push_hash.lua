local hotkey = require "Modules/hotkey"

-- the md5 of the current Unix time rounded up to the minute, as claude/claude-guard.sh expects
local function typePushHash()
  local minute = math.ceil(os.time() / 60) * 60
  local hash = hs.hash.MD5(tostring(minute))
  hs.eventtap.keyStrokes("A: " .. hash)
end

hotkey.bind({ "cmd", "alt", "shift" }, "H", "Type the push hash for Claude", { "claude", "md5", "push" }, typePushHash)
