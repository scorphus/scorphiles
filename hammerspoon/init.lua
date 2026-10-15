require("hs.ipc")

require "Modules/window_layout"
require "Modules/mic_mute"
require "Modules/color_picker"
require "Modules/tools_menu"
caffeine = require "Modules/caffeine"
require "Modules/clipboard"
require "Modules/window_nudge"
require "Modules/window_hints"
require "Modules/scroll"
require "Modules/app_launcher"
require "Modules/config_reload"

-- ⌃⌥⌘/: every hotkey with its description, in a list that scrolls and filters as you type.
local symbols = { cmd = "⌘", ctrl = "⌃", alt = "⌥", shift = "⇧" }
local keyLabels = { left = "←", right = "→", up = "↑", down = "↓", ["return"] = "↵", pageup = "PgUp", pagedown = "PgDn" }
local function keystroke(idx)
  local key = idx:match("%w+$") or ""
  local label = keyLabels[key:lower()]
  local text = label and (idx:sub(1, #idx - #key) .. label) or idx
  return (text:gsub("%^", "⌃"))
end
local hotkeyList = hs.chooser.new(function() end)
hotkeyList:placeholderText("Hotkeys")
require("Modules/hotkey").bind({ "ctrl", "alt", "cmd" }, "/", "Hotkey list", function()
  local choices = {}
  for _, hotkey in ipairs(hs.hotkey.getHotkeys()) do
    table.insert(choices, { text = keystroke(hotkey.idx), subText = (hotkey.msg or ""):gsub("^.-: ", "", 1) })
  end
  table.sort(choices, function(a, b) return a.text < b.text end)
  hotkeyList:choices(choices)
  hotkeyList:show()
end)
