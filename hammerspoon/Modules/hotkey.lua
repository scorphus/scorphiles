-- hs.hotkey.bind with a description that shows in the hotkey list (⌃⌥⌘/) but not in an
-- alert on every press, which is what Hammerspoon does with a message given at bind time.
-- Every hotkey is tagged with the name of the module that binds it; an optional table
-- after the description adds more tags: hotkey.bind(mods, key, description, { "windows" }, fn)
local M = {}

function M.bind(mods, key, description, ...)
  local args = table.pack(...)
  local first = 1
  local tags = {}
  local module = debug.getinfo(2, "S").source:match("Modules/([%w_]+)%.lua$")
  if module then tags[1] = module:gsub("_", " ") end
  if type(args[1]) == "table" then
    for _, tag in ipairs(args[1]) do tags[#tags + 1] = tag end
    first = 2
  end
  -- unpack up to args.n: the callbacks can have a nil between them
  local hotkey = hs.hotkey.bind(mods, key, table.unpack(args, first, args.n))
  hotkey.msg = hotkey.idx .. ": " .. description
  hotkey.tags = tags
  -- for the shortcut panel (⌃⌥⌘/): its label, and what ⏎ runs there
  hotkey.mods, hotkey.key = mods, key
  local pressed, released = args[first], args[first + 1]
  hotkey.run = function()
    if pressed then pressed() end
    if released then released() end
  end
  return hotkey
end

return M
