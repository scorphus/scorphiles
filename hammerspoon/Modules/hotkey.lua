-- hs.hotkey.bind with a description that shows in the hotkey list (⌃⌥⌘/) but not in an
-- alert on every press, which is what Hammerspoon does with a message given at bind time.
local M = {}

function M.bind(mods, key, description, ...)
  local hotkey = hs.hotkey.bind(mods, key, ...)
  hotkey.msg = hotkey.idx .. ": " .. description
  return hotkey
end

return M
