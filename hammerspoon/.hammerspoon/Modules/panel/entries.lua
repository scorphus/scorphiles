-- shortcut panel, from Michael Borisov's dotfiles
-- https://github.com/SecTedd/dotfiles
--
-- Licensed under the MIT license:
-- http://www.opensource.org/licenses/mit-license
-- Copyright (c) 2026 Michael Borisov
--
-- The panel's entries, collected from the three sources:
--   Hammerspoon  hs.hotkey.getHotkeys(), with what Modules/hotkey.lua adds to each
--   tmux         live from the running server (Modules/panel/tmux.lua)
--   fish         Modules/panel/fish.lua
--
-- An entry: { source, group, key, description, index, words, run | copy, icon, iconTemplate }
--   group  shown as the row's tag: a Hammerspoon hotkey's first tag ("window layout"), others "tmux · ours", "fish · built-in"
--   tags   a Hammerspoon hotkey's other tags, searched but not shown
--   run    function: what ⏎ does (Hammerspoon action, tmux key press)
--   copy   string: what ⏎ puts on the clipboard instead (fish, copy-mode keys)
--   words  search words for the key (Modules/panel/keys.lua) and the tags

local tmux = require("Modules/panel/tmux")
local fish = require("Modules/panel/fish")
local keys = require("Modules/panel/keys")

local M = {}

local function hammerspoonEntries()
  local out = {}
  for _, h in ipairs(hs.hotkey.getHotkeys()) do
    local tags = h.tags or {}
    out[#out + 1] = {
      source = "Hammerspoon", group = tags[1] or "Hammerspoon", tags = { table.unpack(tags, 2) },
      key = h.key and keys.label(h.mods, h.key) or h.idx,
      description = (h.msg or ""):gsub("^.-: ", "", 1), run = h.run,
    }
  end
  table.sort(out, function(a, b) return a.group < b.group or (a.group == b.group and a.key < b.key) end)
  return out
end

local function tmuxEntries()
  local out = tmux.entries()
  for _, e in ipairs(out) do
    if not e.run then e.copy = e.key end -- copy-mode keys: nothing to run outside copy mode
  end
  return out
end

local function fishEntries()
  local out = {}
  local function add(list, group)
    for _, e in ipairs(list) do
      out[#out + 1] = { source = "fish", group = group, key = e.key, description = e.description, copy = e.copy or e.key }
    end
  end
  add(fish.ours, "fish · ours")
  add(fish.abbreviations(), "fish · abbreviation")
  add(fish.builtin, "fish · built-in")
  return out
end

-- Every entry in display order: Hammerspoon, tmux (ours, built-in), fish
function M.all()
  local out = {}
  for _, list in ipairs({ hammerspoonEntries(), tmuxEntries(), fishEntries() }) do
    for _, e in ipairs(list) do
      e.index = #out + 1
      e.words = keys.searchWords(e.key) .. " " .. table.concat(e.tags or {}, " ")
      out[#out + 1] = e
    end
  end
  return out
end

return M
