-- Caffeine replacement

local icon = require "Modules/menubar_icon"

local function corner(i, radius)
  local angle = math.rad(-90 + 60 * i)
  return { x = 7 + radius * math.cos(angle), y = 8 + radius * math.sin(angle) }
end

local function innerBar(i)
  local from, to = corner(i, 4.2), corner(i + 1, 4.2)
  local function at(t) return { x = from.x + (to.x - from.x) * t, y = from.y + (to.y - from.y) * t } end
  return icon.cut(icon.line(1.8, at(0.15), at(0.85)))
end

iconOn = icon.image(14, {
  icon.shape(corner(0, 7.4), corner(1, 7.4), corner(2, 7.4), corner(3, 7.4), corner(4, 7.4), corner(5, 7.4)),
  innerBar(0),
  innerBar(2),
  innerBar(4),
})

iconOff = icon.image(14, {
  icon.line(2, { x = 7, y = 1.2 }, { x = 13, y = 1.2 }, { x = 7, y = 7.4 }, { x = 13, y = 7.4 }),
  icon.line(2, { x = 1, y = 9.8 }, { x = 5.5, y = 9.8 }, { x = 1, y = 14.8 }, { x = 5.5, y = 14.8 }),
})

local module = {}

local menu = hs.menubar.new(true, "caffeine")

function setIcon(state)
  menu:setIcon(state and iconOn or iconOff)
end

function clickCallback()
  local state = hs.caffeinate.toggle("displayIdle")
  -- a reload drops the sleep assertion, so the state is kept in hs.settings
  hs.settings.set("caffeine", state)
  setIcon(state)
end

menu:setClickCallback(clickCallback)
if hs.settings.get("caffeine") then hs.caffeinate.set("displayIdle", true) end
setIcon(hs.caffeinate.get("displayIdle"))

module.menu = menu
return module
