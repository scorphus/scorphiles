local active = {}
local style = { font = { size = 18 }, color = { white = 1, alpha = 0.4 }, paragraphStyle = { alignment = "center" } }
local pad, gap = 18, 8

local function layout()
  local f = hs.screen.mainScreen():frame()
  local y = f.y + f.h / 2
  for _, c in ipairs(active) do
    local s = c:size()
    c:topLeft({ x = f.x + (f.w - s.w) / 2, y = y })
    y = y + s.h + gap
  end
end

-- like hs.alert.show, but in the upper third of the screen, and several banners stack instead of covering each other
function banner(text, seconds)
  local t = hs.drawing.getTextDrawingSize(text, { size = style.font.size })
  local w, h = t.w + 2 * pad, t.h + pad
  local c = hs.canvas.new({ x = 0, y = 0, w = w, h = h })
  c:level(hs.canvas.windowLevels.overlay)
  c:behavior("canJoinAllSpaces")
  c:appendElements(
    { type = "rectangle", roundedRectRadii = { xRadius = 10, yRadius = 10 }, fillColor = { white = 0.1, alpha = 0.7 }, strokeColor = { white = 1, alpha = 0.15 }, strokeWidth = 2 },
    { type = "text", text = hs.styledtext.new(text, style), frame = { x = pad, y = pad / 2, w = t.w + 2, h = t.h } }
  )
  table.insert(active, c)
  layout()
  c:show(0.15)
  hs.timer.doAfter(seconds or 5, function()
    for i, x in ipairs(active) do
      if x == c then table.remove(active, i) end
    end
    c:delete(0.3)
    layout()
  end)
end
