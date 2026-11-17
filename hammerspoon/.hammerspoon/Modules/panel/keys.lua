-- shortcut panel, from Michael Borisov's dotfiles
-- https://github.com/SecTedd/dotfiles
--
-- Licensed under the MIT license:
-- http://www.opensource.org/licenses/mit-license
-- Copyright (c) 2026 Michael Borisov
--
-- Key labels for the panel: parsing, search words, query hints.
--
-- A label is what a row shows: "⌃⌥⌘ T", "prefix ⌃Space", "copy mode y", "⌃F  ⌃E"
-- (several keys: the first one stands for the row), "menu bar <bell glyph>".
-- Everything here walks labels character by character (utf8.codes): Lua patterns
-- work on bytes and would tear the multi-byte symbols apart.

local M = {}

-- Symbol -> the words people type for it (first one is the short form)
M.MOD_SYMBOLS = {
  ["⌃"] = { "ctrl", "control" },
  ["⌥"] = { "alt", "option", "opt" },
  ["⌘"] = { "cmd", "command" },
  ["⇧"] = { "shift" },
}
M.KEY_SYMBOLS = {
  ["⏎"] = "enter", ["⌫"] = "backspace", ["⇥"] = "tab", ["␣"] = "space",
  ["←"] = "left", ["→"] = "right", ["↑"] = "up", ["↓"] = "down",
}
-- Other spellings of key names in queries
local KEY_ALIASES = { ["return"] = "enter", delete = "backspace", escape = "esc" }
-- Labels may start with a scope: tmux key tables, or the Hammerspoon window mode
local SCOPES = {
  { name = "prefix", words = "tmux prefix" },
  { name = "copy mode", words = "tmux copy mode" },
  { name = "mode", words = "window mode" },
}

-- label({ "cmd", "alt", "ctrl" }, "t") -> "⌃⌥⌘ T": macOS modifier order, key names as symbols
local MOD_NAME = { ctrl = "ctrl", control = "ctrl", alt = "alt", option = "alt", shift = "shift", cmd = "cmd", command = "cmd" }
local MOD_SYMBOL = { ctrl = "⌃", alt = "⌥", shift = "⇧", cmd = "⌘" }
local MOD_ORDER = { "ctrl", "alt", "shift", "cmd" }
local KEY_NAME = {
  ["return"] = "⏎", space = "Space", escape = "Esc", tab = "⇥", delete = "⌫", forwarddelete = "⌦",
  left = "←", right = "→", up = "↑", down = "↓", home = "Home", ["end"] = "End", pageup = "PgUp", pagedown = "PgDn",
}
function M.label(mods, key)
  local set = {}
  for _, m in ipairs(mods) do set[MOD_NAME[m:lower()] or m] = true end
  local label = ""
  for _, m in ipairs(MOD_ORDER) do
    if set[m] then label = label .. MOD_SYMBOL[m] end
  end
  local k = KEY_NAME[key:lower()] or (#key == 1 and key:upper() or key)
  return label .. " " .. k
end

local MOD_WORDS = {} -- "ctrl" -> "⌃", ...
for sym, names in pairs(M.MOD_SYMBOLS) do
  for _, name in ipairs(names) do MOD_WORDS[name] = sym end
end

-- parse("prefix ⌃Space") -> { scope = "prefix", scopeWords = "tmux prefix", mods = { ["⌃"] = true }, modList = { "⌃" }, key = "space" }
function M.parse(label)
  local scope, scopeWords = "", ""
  for _, s in ipairs(SCOPES) do
    if label:sub(1, #s.name + 1) == s.name .. " " then
      scope, scopeWords, label = s.name, s.words, label:sub(#s.name + 2)
      break
    end
  end
  label = label:match("^(.-)  ") or label -- "⌃F  ⌃E": the first key
  local mods, modList, key = {}, {}, {}
  for _, code in utf8.codes(label) do
    local ch = utf8.char(code)
    if M.MOD_SYMBOLS[ch] then
      mods[ch] = true
      modList[#modList + 1] = ch
    elseif M.KEY_SYMBOLS[ch] then
      key[#key + 1] = M.KEY_SYMBOLS[ch]
    elseif ch ~= " " then
      key[#key + 1] = ch:lower()
    end
  end
  return { scope = scope, scopeWords = scopeWords, mods = mods, modList = modList, key = table.concat(key) }
end

-- Words that make a label findable by name: "ctrl control ctrl-l ctrl+l c-l" for
-- "⌃L", "tmux prefix" for tmux keys. They go into fzf's input right after the label.
function M.searchWords(label)
  local k = M.parse(label)
  local words, short = {}, {}
  for _, sym in ipairs(k.modList) do
    for _, w in ipairs(M.MOD_SYMBOLS[sym]) do words[#words + 1] = w end
    short[#short + 1] = M.MOD_SYMBOLS[sym][1]
  end
  for _, code in utf8.codes(label) do
    local name = M.KEY_SYMBOLS[utf8.char(code)]
    if name then words[#words + 1] = name end
  end
  if #short > 0 and k.key:match("^%w+$") then -- one plain key after the modifiers
    words[#words + 1] = table.concat(short, "-") .. "-" .. k.key -- ctrl-alt-cmd-t
    words[#words + 1] = table.concat(short, "+") .. "+" .. k.key -- ctrl+alt+cmd+t
    if #short == 1 then words[#words + 1] = short[1]:sub(1, 1) .. "-" .. k.key end -- c-l, as tmux writes it
  end
  if k.scopeWords ~= "" then words[#words + 1] = k.scopeWords end
  return table.concat(words, " ")
end

-- What a query says about the key it wants: parseQuery("ctrl alt t") ->
-- { mods = { ["⌃"] = true, ["⌥"] = true }, scope = nil, key = "t", hasHints = true }.
-- hasHints is false when the query names no modifier and no scope (plain text search).
function M.parseQuery(query)
  local q = { mods = {}, scope = nil, key = nil, hasHints = false }
  for word in query:lower():gmatch("[^%s%-+]+") do -- "ctrl l", "ctrl-l", "ctrl+alt+t"
    if MOD_WORDS[word] then
      q.mods[MOD_WORDS[word]] = true
      q.hasHints = true
    elseif word == "prefix" then
      q.scope, q.hasHints = "prefix", true
    elseif not q.key then
      q.key = KEY_ALIASES[word] or word
    end
  end
  return q
end

return M
