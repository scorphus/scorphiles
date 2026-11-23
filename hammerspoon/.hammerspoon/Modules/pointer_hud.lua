local hotkey = require "Modules/hotkey"

local STILL_SECONDS = 0.05
local FADE_SECONDS = 0.2

local function lime(alpha) return { hex = "#39FF14", alpha = alpha } end

local function line(width, alpha, ...)
  return { type = "segments", action = "stroke", strokeWidth = width, strokeColor = lime(alpha), coordinates = { ... } }
end

local function hud()
  local W, H = 300, 230
  local cx, cy = W / 2, H / 2
  local A = 0.17
  local elements = {}
  local function add(e)
    e.withShadow = true
    e.shadow = { blurRadius = 4, color = lime(0.29), offset = { h = 0, w = 0 } }
    elements[#elements + 1] = e
    return #elements
  end
  local function seg(...)
    local points = {}
    local xy = { ... }
    for i = 1, #xy, 2 do points[#points + 1] = { x = cx + xy[i], y = cy + xy[i + 1] } end
    return add(line(1.5, A, table.unpack(points)))
  end
  local function text(x, y, w, s, size)
    return add({
      type = "text", text = s, textColor = lime(0.24), textFont = "Menlo", textSize = size or 10,
      textAlignment = "center", frame = { x = cx + x, y = cy + y, w = w, h = 14 },
    })
  end

  -- flight path marker: the pointer's tip sits in its circle
  add({ type = "circle", center = { x = cx, y = cy }, radius = 6, action = "stroke", strokeWidth = 1.5, strokeColor = lime(A) })
  seg(-18, 0, -6, 0)
  seg(6, 0, 18, 0)
  seg(0, -6, 0, -13)
  seg(0, 6, 0, 13)

  seg(-74, 0, -28, 0)
  seg(28, 0, 74, 0)
  seg(0, -74, 0, -28)
  seg(0, 28, 0, 74)

  -- pitch ladder: solid above the horizon, dashed below, end ticks pointing at the horizon
  for _, rung in ipairs({ { y = -30, label = "5" }, { y = -60, label = "10" }, { y = 30, label = "5" }, { y = 60, label = "10" } }) do
    local toward = rung.y < 0 and 5 or -5
    for _, side in ipairs({ -1, 1 }) do
      local i = seg(side * 52, rung.y + toward, side * 52, rung.y, side * 20, rung.y)
      if rung.y > 0 then elements[i].strokeDashPattern = { 1.5, 1.5 } end
      text(side * 62 - 8, rung.y - 7, 16, rung.label, 8)
    end
  end

  -- a tape and its ticks are one path, so moving the ticks changes one element; a tick sits at
  -- every `step` of the value and is long at every second one
  local function comb(value, step, px, half, point, tick)
    local points = { point(-half) }
    local first = math.ceil((value - half / px) / step)
    local last = math.floor((value + half / px) / step)
    for n = first, last do
      local at = (n * step - value) * px
      local base = point(at)
      points[#points + 1] = base
      points[#points + 1] = tick(at, n % 2 == 0 and 6 or 3)
      points[#points + 1] = base
    end
    points[#points + 1] = point(half)
    return points
  end
  local function vertical(side)
    local x = cx + side * 92
    return function(at) return { x = x, y = cy - at } end, function(at, length) return { x = x + side * length, y = cy - at } end
  end
  local speedPoint, speedTick = vertical(-1)
  local altitudePoint, altitudeTick = vertical(1)
  local function headingPoint(at) return { x = cx + at, y = cy - 88 } end
  local function headingTick(at, length) return { x = cx + at, y = cy - 88 - length } end
  local function speedComb(v) return comb(v, 100, 0.1, 52, speedPoint, speedTick) end
  local function altitudeComb(v) return comb(v, 10, 1, 52, altitudePoint, altitudeTick) end
  local function headingComb(v) return comb(v, 5, 3, 60, headingPoint, headingTick) end
  local speedTape = add(line(1.5, A, table.unpack(speedComb(0))))
  local altitudeTape = add(line(1.5, A, table.unpack(altitudeComb(0))))
  local headingTape = add(line(1.5, A, table.unpack(headingComb(0))))
  add({ type = "rectangle", action = "stroke", strokeWidth = 1.5, strokeColor = lime(A), frame = { x = cx - 144, y = cy - 8, w = 46, h = 16 } })
  add({ type = "rectangle", action = "stroke", strokeWidth = 1.5, strokeColor = lime(A), frame = { x = cx + 98, y = cy - 8, w = 46, h = 16 } })
  local speedText = text(-144, -5, 46, "0")
  local altitudeText = text(98, -5, 46, "0")

  seg(-5, -80, 0, -87, 5, -80)
  local headingText = text(-20, -110, 40, "000")
  local timeText = text(-20, 84, 40, os.date("%H:%M"))

  local lastTapes, lastText = 0, 0
  local function update(canvas, p, speed)
    local now = hs.timer.secondsSinceEpoch()
    if now - lastTapes < 0.03 then return end
    lastTapes = now
    local screen = hs.mouse.getCurrentScreen():fullFrame()
    local altitude = screen.y + screen.h - p.y
    local heading = (p.x - screen.x) / screen.w * 360
    canvas[speedTape].coordinates = speedComb(speed)
    canvas[altitudeTape].coordinates = altitudeComb(altitude)
    canvas[headingTape].coordinates = headingComb(heading)
    if now - lastText < 0.08 then return end
    lastText = now
    canvas[speedText].text = string.format("%.0f", speed)
    canvas[altitudeText].text = string.format("%.0f", altitude)
    canvas[headingText].text = string.format("%03d", math.floor(heading) % 360)
    canvas[timeText].text = os.date("%H:%M")
  end
  return { w = W, h = H }, elements, update
end

local M = {}

local size, elements, update = hud()
M.canvas = hs.canvas.new({ x = 0, y = 0, w = size.w, h = size.h })
M.canvas:appendElements(elements)
M.canvas:level(hs.canvas.windowLevels.overlay)
M.canvas:behavior({ "canJoinAllSpaces", "stationary" })

-- apps draw tooltips inside their own windows, under anything we draw; tooltips come up
-- only while the pointer rests, so the HUD goes away then
M.still = hs.timer.delayed.new(STILL_SECONDS, function() M.canvas:hide(FADE_SECONDS) end)

local last, speed = nil, 0

local function follow()
  local p = hs.mouse.absolutePosition()
  M.canvas:topLeft({ x = p.x - size.w / 2, y = p.y - size.h / 2 })
  local now = hs.timer.secondsSinceEpoch()
  if last and now > last.t then
    local d = math.sqrt((p.x - last.x) ^ 2 + (p.y - last.y) ^ 2)
    speed = speed * 0.8 + d / (now - last.t) * 0.2
  end
  last = { x = p.x, y = p.y, t = now }
  update(M.canvas, p, speed)
  M.canvas:alpha(1)
  M.canvas:show()
  M.still:start()
end

local types = hs.eventtap.event.types
M.tap = hs.eventtap.new(
  { types.mouseMoved, types.leftMouseDragged, types.rightMouseDragged, types.otherMouseDragged },
  function()
    follow()
    return false
  end
)

function M.on()
  M.tap:start()
  follow()
end

function M.off()
  M.tap:stop()
  M.still:stop()
  M.canvas:hide()
end

function M.toggle()
  if M.tap:isEnabled() then M.off() else M.on() end
end

M.hotkey = hotkey.bind({ "cmd", "alt", "ctrl" }, "C", "Pointer HUD on/off", { "cursor", "pointer", "mouse" }, M.toggle)

M.on()

return M
