local hotkey = require "Modules/hotkey"
local apps = {
  ["Return"] = { "Ghostty", "terminal" },  -- ⌘⌃↵
  ["T"]      = { "Ghostty", "terminal" },  -- ⌘⌃T
  ["`"]      = { "Ghostty", "terminal" },  -- ⌘⌃`
  ["B"]      = { "Firefox", "browser" },   -- ⌘⌃B
  ["F"]      = { "Firefox", "browser" },   -- ⌘⌃F (alias)
  ["E"]      = { "Zed Dev", "editor" },    -- ⌘⌃E
  ["Z"]      = { "Zed Dev", "editor" },    -- ⌘⌃Z (alias)
  ["S"]      = { "Slack", "chat" },        -- ⌘⌃S
  ["L"]      = { "Linear", "issues" },     -- ⌘⌃L
  ["M"]      = { "Spotify", "music" },     -- ⌘⌃M
  ["P"]      = { "Preview", "preview" },   -- ⌘⌃P
}
for key, entry in pairs(apps) do
  local app, role = entry[1], entry[2]
  hotkey.bind({ "cmd", "ctrl" }, key, app, { "launch", role }, function() hs.application.launchOrFocus(app) end)
end

-- Cheat sheet: ⌃⌘/ lists the app-launcher shortcuts
local keyLabel = { Return = "↵" }
hotkey.bind({ "cmd", "ctrl" }, "/", "App launcher cheat sheet", { "help" }, function()
  local lines = {}
  for key, entry in pairs(apps) do
    table.insert(lines, "⌃⌘ " .. (keyLabel[key] or key) .. "   " .. entry[1])
  end
  table.sort(lines)
  hs.alert.show(table.concat(lines, "\n"), { textSize = 20, radius = 12 }, hs.screen.mainScreen(), 4)
end)
