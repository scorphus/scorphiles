local apps = {
  ["Return"] = "Ghostty",   -- ⌘⌃↵  terminal
  ["T"]      = "Ghostty",   -- ⌘⌃T  terminal
  ["`"]      = "Ghostty",   -- ⌘⌃`  terminal
  ["B"]      = "Firefox",   -- ⌘⌃B  browser
  ["F"]      = "Firefox",   -- ⌘⌃F  browser (alias)
  ["E"]      = "Zed Dev",   -- ⌘⌃E  editor
  ["Z"]      = "Zed Dev",   -- ⌘⌃Z  editor (alias)
  ["S"]      = "Slack",     -- ⌘⌃S  chat
  ["L"]      = "Linear",    -- ⌘⌃L  issues
  ["M"]      = "Spotify",   -- ⌘⌃M  music
  ["P"]      = "Preview",   -- ⌘⌃P  preview
}
for key, app in pairs(apps) do
  hs.hotkey.bind({ "cmd", "ctrl" }, key, function() hs.application.launchOrFocus(app) end)
end

-- Cheat sheet: ⌃⌘/ lists the app-launcher shortcuts
local keyLabel = { Return = "↵" }
hs.hotkey.bind({ "cmd", "ctrl" }, "/", function()
  local lines = {}
  for key, app in pairs(apps) do
    table.insert(lines, "⌃⌘ " .. (keyLabel[key] or key) .. "   " .. app)
  end
  table.sort(lines)
  hs.alert.show(table.concat(lines, "\n"), { textSize = 20, radius = 12 }, hs.screen.mainScreen(), 4)
end)
