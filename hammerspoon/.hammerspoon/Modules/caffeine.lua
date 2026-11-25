-- Caffeine replacement

local icon = require "Modules/menubar_icon"

local RING, ARM, STROKE = 4.2, 2.2, 1.6

local function polar(center, radius, degrees)
  local angle = math.rad(degrees)
  return { x = center.x + radius * math.cos(angle), y = center.y + radius * math.sin(angle) }
end

local function ring(center, radius, start, corners)
  local points = {}
  for i = 0, corners do points[#points + 1] = polar(center, radius, start + 360 / corners * i) end
  return icon.line(STROKE, table.unpack(points))
end

local function arm(center, radius, degrees)
  return icon.line(STROKE, polar(center, radius, degrees), polar(center, radius + ARM, degrees))
end

-- caffeine's skeleton: a hexagon and a pentagon sharing one side, both with sides of length RING
local hexagon = { x = 6.4, y = 8 }
local pentagonRadius = RING / (2 * math.sin(math.rad(36)))
local pentagon = { x = hexagon.x + RING * math.cos(math.rad(30)) + RING / (2 * math.tan(math.rad(36))), y = 8 }

iconOn = icon.image(17.5, {
  ring(hexagon, RING, -90, 6),
  ring(pentagon, pentagonRadius, 144, 5),
  arm(hexagon, RING, -90),
  arm(hexagon, RING, 90),
  arm(hexagon, RING, 210),
  arm(hexagon, RING, 150),
  arm(pentagon, pentagonRadius, -72),
})

local function z(width, left, top, right, bottom)
  return icon.line(width, { x = left, y = top }, { x = right, y = top }, { x = left, y = bottom }, { x = right, y = bottom })
end

iconOff = icon.image(15.8, {
  icon.dot(6.3, 9.4, 6.2),
  icon.cut(icon.dot(9.6, 6.6, 5.4)),
  z(1.3, 8.4, 6, 10.8, 8.7),
  z(1.5, 11.4, 0.9, 15, 4.6),
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
