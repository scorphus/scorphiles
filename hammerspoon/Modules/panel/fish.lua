-- shortcut panel, from Michael Borisov's dotfiles
-- https://github.com/SecTedd/dotfiles
--
-- Licensed under the MIT license:
-- http://www.opensource.org/licenses/mit-license
-- Copyright (c) 2026 Michael Borisov
--
-- fish shortcuts for the panel. fish's key bindings carry no descriptions, so they
-- are listed here by hand: a new binding in fish_user_key_bindings.fish -> one line
-- in `ours`. Abbreviations are read live from fish, their expansion is the description.
--
-- key  = what the panel shows; descriptions stay short (the row has ~45 characters)
-- copy = what ⏎ puts on the clipboard (default: the key itself)

local M = {}

M.ours = {
  { key = "⌃R", description = "History search (peco)" },
  { key = "⌃↑", description = "Copy the last command" },
  { key = "⌃↓", description = "Copy the command line" },
  { key = "⌥Y", description = "Paste what ⌃↑ / ⌃↓ copied" },
  { key = "⌃⌫", description = "Delete the word after the cursor" },
}

M.builtin = {
  { key = "⌃F  ⌃E", description = "Accept the autosuggestion" },
  { key = "⌥F", description = "Accept one word of the suggestion" },
  { key = "⌥E", description = "Edit the command line in $EDITOR" },
  { key = "⌥S", description = "Prepend sudo" },
  { key = "⌥L", description = "List the folder under the cursor" },
  { key = "⌥P", description = "Append | less" },
  { key = "⌥H", description = "Man page of the command" },
  { key = "⌥O", description = "Preview the file under the cursor" },
  { key = "⌃U  ⌃K", description = "Delete to line start / end" },
  { key = "⌃W  ⌥D", description = "Delete the word before / after" },
  { key = "⌥←  ⌥→", description = "Previous / next folder (empty line)" },
  { key = "⌥↑  ⌥↓", description = "History search for the token" },
  { key = "⌃Z", description = "Undo the last edit" },
  { key = "⇥  ⇧⇥", description = "Complete / completion pager" },
  { key = "⌃L", description = "Clear the screen" },
}

-- { key = "gco ␣", copy = "gco", description = "git checkout" }, ... from `abbr --show`
function M.abbreviations()
  local out = {}
  local output = hs.execute("/opt/homebrew/bin/fish -c 'abbr --show' 2>/dev/null") or ""
  for name, expansion in output:gmatch("abbr %-a %-%- (%S+) '([^\n]*)'\n") do
    out[#out + 1] = { key = name .. " ␣", copy = name, description = expansion }
  end
  return out
end

return M
