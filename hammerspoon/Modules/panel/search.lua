-- shortcut panel, from Michael Borisov's dotfiles
-- https://github.com/SecTedd/dotfiles
--
-- Licensed under the MIT license:
-- http://www.opensource.org/licenses/mit-license
-- Copyright (c) 2026 Michael Borisov
--
-- Search over the panel's entries, done by fzf (`fzf --filter`: fuzzy matching
-- and ranking, the same as in the shell). On top of fzf's order one thing fzf
-- can't know: when the query names modifiers or "prefix", rows whose
-- modifiers and key match exactly come first ("ctrl l" -> ⌃L before ⌃⌥L).
--
--   local index = search.index(entries)      once per opening of the panel
--   search.query(index, text, callback)      async; callback(entries) with the ranked
--                                            matches; results of an older query are dropped
--   search.rerank(text, entries)             the modifier/key tiering alone (used by query)
--
-- Without fzf a plain substring match stands in.

local keys = require("Modules/panel/keys")

local M = {}

M.fzf = "/opt/homebrew/bin/fzf"
-- --with-nth 2..: match on everything after the index field; --tiebreak begin:
-- among equal scores, matches closer to the start (the key and its words) win
local FZF_ARGS = { "--delimiter", "\t", "--with-nth", "2..", "--tiebreak", "begin,index" }

-- The fzf input: one line per entry, "<index>\t<label> <search words> <description> <group> <source>"
function M.index(entries)
  local lines = {}
  for i, e in ipairs(entries) do
    lines[i] = i .. "\t" .. e.key .. " " .. e.words .. " " .. e.description .. " " .. e.group .. " " .. e.source
  end
  return { entries = entries, input = table.concat(lines, "\n") .. "\n" }
end

function M.rerank(text, entries)
  local q = keys.parseQuery(text)
  if not q.hasHints then return entries end
  local function tier(e)
    local k = keys.parse(e.key)
    local sameMods = q.scope == nil or k.scope == q.scope
    for sym in pairs(q.mods) do if not k.mods[sym] then sameMods = false end end
    for sym in pairs(k.mods) do if not q.mods[sym] then sameMods = false end end
    local sameKey = q.key ~= nil and k.key == q.key
    if sameMods and sameKey then return 0 end
    if sameMods then return 1 end
    if sameKey then return 2 end
    return 3
  end
  local ranked = {}
  for i, e in ipairs(entries) do ranked[i] = { e = e, tier = tier(e), i = i } end
  table.sort(ranked, function(a, b)
    if a.tier ~= b.tier then return a.tier < b.tier end
    return a.i < b.i -- stable: fzf's order within a tier
  end)
  local out = {}
  for i, r in ipairs(ranked) do out[i] = r.e end
  return out
end

local function substringMatches(index, text)
  local needle, out = text:lower(), {}
  for _, e in ipairs(index.entries) do
    if (e.key .. " " .. e.words .. " " .. e.description .. " " .. e.group .. " " .. e.source):lower():find(needle, 1, true) then
      out[#out + 1] = e
    end
  end
  return out
end

local generation = 0

function M.query(index, text, callback)
  generation = generation + 1
  if text == "" then return callback(index.entries) end
  if not hs.fs.attributes(M.fzf) then return callback(M.rerank(text, substringMatches(index, text))) end
  local mine = generation
  local args = { "--filter", text }
  for _, a in ipairs(FZF_ARGS) do args[#args + 1] = a end
  local task = hs.task.new(M.fzf, function(_, stdout)
    if mine ~= generation then return end
    local out = {}
    for line in (stdout or ""):gmatch("[^\n]+") do
      local i = tonumber(line:match("^(%d+)\t"))
      if i and index.entries[i] then out[#out + 1] = index.entries[i] end
    end
    callback(M.rerank(text, out))
  end, args)
  task:setInput(index.input) -- before start(): set afterwards, the data never arrives
  task:start()
  task:closeInput()
end

return M
