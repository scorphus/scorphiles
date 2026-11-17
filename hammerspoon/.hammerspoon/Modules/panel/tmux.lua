-- shortcut panel, from Michael Borisov's dotfiles
-- https://github.com/SecTedd/dotfiles
--
-- Licensed under the MIT license:
-- http://www.opensource.org/licenses/mit-license
-- Copyright (c) 2026 Michael Borisov
--
-- tmux shortcuts for the panel, read live from the running tmux server.
--
-- `tmux list-keys -N -T <table>` lists every binding that carries a note.
-- tmux's own defaults have notes; ours get them in tmux.conf with `bind -N "..."`,
-- so a new binding shows up here by itself.
-- A key is "ours" when its note is in tmux.conf, everything else is "built-in".
--
-- Running one: `tmux send-keys -K -c <client> <keys>` sends the keys to the most
-- recently used tmux client as if typed, so the binding runs like a key press.


local M = {}

M.tmux = "/opt/homebrew/bin/tmux"
local CONF = os.getenv("HOME") .. "/.tmux.conf"
local PREFIX = "C-Space"

-- `list-keys -N` prints "<prefix key> <key> <note>" for every table
local TABLES = {
  { name = "prefix", format = "prefix %s", send_prefix = true },
  { name = "root", format = "%s" },
  { name = "copy-mode-vi", format = "copy mode %s", display_only = true }, -- only meaningful inside copy mode
}

-- tmux key names -> symbols: "C-Space" -> "⌃Space", "M-Up" -> "⌥↑", "BSpace" -> "⌫"
local KEY_NAME = {
  Space = "Space", Enter = "⏎", Tab = "⇥", BTab = "⇧⇥", BSpace = "⌫", DC = "Del", IC = "Ins", Escape = "Esc",
  Up = "↑", Down = "↓", Left = "←", Right = "→", PPage = "PgUp", NPage = "PgDn", Home = "Home", End = "End",
  MouseDown1Status = "click the status bar",
}
function M.keyLabel(key)
  local mods = ""
  while true do
    local mod, rest = key:match("^([CMS])%-(.+)$")
    if not mod then break end
    mods = mods .. ({ C = "⌃", M = "⌥", S = "⇧" })[mod]
    key = rest
  end
  return mods .. (KEY_NAME[key] or key)
end

-- The notes in tmux.conf: note -> true
local function ours()
  local set = {}
  local f = io.open(CONF)
  if not f then return set end
  for line in f:lines() do
    local note = line:match('^%s*bind%-?k?e?y?%s.-%-N%s+"([^"]*)"')
    if note then set[note] = true end
  end
  f:close()
  return set
end

-- Most recently used tmux client, nil if none is attached
local function activeClient()
  local out = hs.execute(M.tmux .. " list-clients -F '#{client_activity} #{client_name}' 2>/dev/null")
  local best, bestActivity
  for line in (out or ""):gmatch("[^\n]+") do
    local activity, name = line:match("^(%d+) (%S+)$")
    if activity and (not bestActivity or tonumber(activity) > bestActivity) then
      bestActivity, best = tonumber(activity), name
    end
  end
  return best
end

-- Press these keys in the active client (through its key tables)
function M.send(keys)
  local client = activeClient()
  if not client then return hs.alert.show("tmux: no client attached", 1) end
  local args = { "send-keys", "-K", "-c", client }
  for _, key in ipairs(keys) do args[#args + 1] = key end
  hs.task.new(M.tmux, nil, args):start()
end

-- Entries for the panel: ours first, then tmux's built-ins
--   { source = "tmux", group, key, description, run }
function M.entries()
  local mine, builtin = {}, {}
  local isOurs = ours()
  -- all tables in one tmux call, separated by marker lines
  local cmd = {}
  for _, t in ipairs(TABLES) do
    cmd[#cmd + 1] = "echo '== " .. t.name .. "'; " .. M.tmux .. " list-keys -N -T " .. t.name .. " 2>/dev/null"
  end
  local all = hs.execute(table.concat(cmd, "; ")) or ""
  local sections = {}
  local current
  for line in all:gmatch("[^\n]+") do
    local name = line:match("^== (%S+)$")
    if name then current = {}; sections[name] = current elseif current then current[#current + 1] = line end
  end
  for _, t in ipairs(TABLES) do
    for _, line in ipairs(sections[t.name] or {}) do
      local key, note = line:match("^%S+%s+(%S+)%s+(.-)%s*$") -- "C-Space z   Zoom the active pane"
      if key and note and note ~= "" then
        local entry = { source = "tmux", key = string.format(t.format, M.keyLabel(key)), description = note }
        if not t.display_only then
          local keys = t.send_prefix and { PREFIX, key } or { key }
          entry.run = function() M.send(keys) end
        end
        if isOurs[note] then
          entry.group = "tmux · ours"
          mine[#mine + 1] = entry
        else
          entry.group = "tmux · built-in"
          builtin[#builtin + 1] = entry
        end
      end
    end
  end
  for _, entry in ipairs(builtin) do mine[#mine + 1] = entry end
  return mine
end

return M
