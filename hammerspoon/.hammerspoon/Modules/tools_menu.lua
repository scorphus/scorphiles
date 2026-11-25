local colorPicker = require "Modules/color_picker"
local icon = require "Modules/menubar_icon"

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

local function bell(...)
  return icon.image(14, {
    icon.shape(
      { x = 7, y = 1.3 },
      { x = 11.6, y = 6, c1x = 9.9, c1y = 1.3, c2x = 11.6, c2y = 3.5 },
      { x = 11.6, y = 9 },
      { x = 13.4, y = 11.9, c1x = 11.6, c1y = 10.6, c2x = 13.4, c2y = 10.8 },
      { x = 0.6, y = 11.9 },
      { x = 2.4, y = 9, c1x = 0.6, c1y = 10.8, c2x = 2.4, c2y = 10.6 },
      { x = 2.4, y = 6 },
      { x = 7, y = 1.3, c1x = 2.4, c1y = 3.5, c2x = 4.1, c2y = 1.3 }
    ),
    icon.dot(7, 14.2, 1.6),
    ...
  })
end

local icons = {
  full = icon.image(13, {
    icon.line(1.4, { x = 2.5, y = 1 }, { x = 2.5, y = 15 }),
    icon.line(1.4, { x = 6.5, y = 1 }, { x = 6.5, y = 15 }),
    icon.line(1.4, { x = 10.5, y = 1 }, { x = 10.5, y = 15 }),
    icon.dot(2.5, 5, 2.4),
    icon.dot(6.5, 11, 2.4),
    icon.dot(10.5, 7, 2.4),
  }),
  ping = bell(),
  mute = bell(icon.slash(1.5, 1.5, 12.5, 14.5)),
}

toolsMenu = hs.menubar.new(true, "tools")
-- its own item, so the red ⚠ is an icon as wide as the others, not text with padding
guardMenu = hs.menubar.new(true, "guard")

local warningIcon = icon.image(16, {
  {
    type = "segments", action = "strokeAndFill", closed = true, fillColor = { hex = "#FF3B30" }, strokeColor = { hex = "#FF3B30" },
    strokeWidth = 1.8, strokeJoinStyle = "round", coordinates = { { x = 8, y = 1.4 }, { x = 15.1, y = 14.5 }, { x = 0.9, y = 14.5 } },
  },
  {
    type = "segments", action = "stroke", strokeColor = { white = 1 }, strokeWidth = 1.8, strokeCapStyle = "round",
    coordinates = { { x = 8, y = 5.8 }, { x = 8, y = 9.8 } },
  },
  { type = "circle", action = "fill", fillColor = { white = 1 }, center = { x = 8, y = 12.4 }, radius = 1.1 },
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
