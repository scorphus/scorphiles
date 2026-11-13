local colorPicker = require "Modules/color_picker"

-- read by ~/.claude/claude-announce.sh: no file = full, "ping" or "mute"
local announceModeFile = os.getenv("HOME") .. "/.claude/announce-mode"

local function announceMode()
  local f = io.open(announceModeFile, "r")
  if not f then return "full" end
  local mode = f:read("l")
  f:close()
  return mode
end

local function setAnnounceMode(mode)
  if mode == "full" then
    os.remove(announceModeFile)
  else
    local f = io.open(announceModeFile, "w")
    f:write(mode, "\n")
    f:close()
  end
end

local outline = { { strokeColor = { white = 0 }, fillColor = { alpha = 0 } } }

local icons = {
  full = hs.image.imageFromASCII([[ASCII:
.a...b...c.
...........
d.d........
...........
d.d.....f.f
...........
........f.f
....e.e....
...........
....e.e....
...........
...........
.a...b...c.
]]),
  ping = hs.image.imageFromASCII([[ASCII:
.....a.....
.....a.....
.....5.....
...4...6...
...........
..3.....7..
...........
...........
...........
..2.....8..
.1.......9.
...........
....b.b....
]], outline),
  mute = hs.image.imageFromASCII([[ASCII:
c....a.....
.....a.....
.....5.....
...4...6...
...........
..3.....7..
...........
...........
...........
..2.....8..
.1.......9.
...........
....b.b...c
]], outline),
}

toolsMenu = hs.menubar.new(true, "tools")

local function refreshToolsMenuTitle()
  toolsMenu:setIcon(icons[announceMode()] or icons.full)
end

local function modeItem(mode, title)
  return {
    title = title,
    checked = announceMode() == mode,
    fn = function()
      setAnnounceMode(mode)
      refreshToolsMenuTitle()
    end,
  }
end

toolsMenu:setMenu(function()
  return {
    { title = "Pick color (⌘⇧⌃P)", fn = colorPicker.pickColor },
    { title = "-" },
    { title = "Claude announcements", disabled = true },
    modeItem("full", "Sound and speech"),
    modeItem("ping", "Sound only"),
    modeItem("mute", "Muted"),
  }
end)
refreshToolsMenuTitle()
