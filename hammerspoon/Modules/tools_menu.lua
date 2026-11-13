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

-- read by ~/.claude/claude-guard.sh: while it exists, the ask and deny lists are skipped
local guardOffFile = os.getenv("HOME") .. "/.claude/guard-off"

local function guardOff()
  return hs.fs.attributes(guardOffFile) ~= nil
end

local function toggleGuard()
  if guardOff() then
    os.remove(guardOffFile)
  else
    io.open(guardOffFile, "w"):close()
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
-- its own item, so the red ⚠ is an icon as wide as the others, not text with padding
guardMenu = hs.menubar.new(true, "guard")

local warningIcon = hs.image.imageFromASCII([[ASCII:
......1......
.............
.............
.............
......a......
.............
.............
.............
......a......
.............
......b......
......b......
3...........2
]], {
  { fillColor = { red = 1 }, strokeColor = { red = 1 }, shouldClose = true },
  { strokeColor = { white = 1 }, lineWidth = 2 },
  { strokeColor = { white = 1 }, lineWidth = 2 },
})

local function refreshToolsMenuTitle()
  local mode, off = announceMode(), guardOff()
  -- an item without an icon takes no room; removing and re-adding items made macOS lose them
  guardMenu:setIcon(off and warningIcon or nil, false)
  -- the full icon only shows when nothing else does, so the menu stays clickable
  local icon = mode ~= "full" and icons[mode] or (not off and icons.full) or nil
  toolsMenu:setIcon(icon)
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

local function menuItems()
  return {
    { title = "Pick color (⌘⇧⌃P)", fn = colorPicker.pickColor },
    { title = "-" },
    { title = "Claude announcements", disabled = true },
    modeItem("full", "Sound and speech"),
    modeItem("ping", "Sound only"),
    modeItem("mute", "Muted"),
    { title = "-" },
    { title = "Skip the command guard (pushes still need the hash)", checked = guardOff(), fn = function()
      toggleGuard()
      refreshToolsMenuTitle()
    end },
  }
end
toolsMenu:setMenu(menuItems)
guardMenu:setMenu(menuItems)
refreshToolsMenuTitle()
