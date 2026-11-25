local HEIGHT = 16
-- this Mac sets the system spacing between menu bar items to 0, so each icon carries its own
local MARGIN = 4.5
local SCALE = 4

local M = {}

M.black = { white = 0 }

function M.line(width, ...)
  return {
    type = "segments", action = "stroke", strokeColor = M.black, strokeWidth = width,
    strokeCapStyle = "round", strokeJoinStyle = "round", coordinates = { ... },
  }
end

function M.shape(...)
  return {
    type = "segments", action = "strokeAndFill", closed = true, fillColor = M.black, strokeColor = M.black,
    strokeWidth = 1, strokeJoinStyle = "round", coordinates = { ... },
  }
end

function M.dot(x, y, radius)
  return { type = "circle", action = "fill", fillColor = M.black, center = { x = x, y = y }, radius = radius }
end

function M.cut(element)
  element.compositeRule = "destinationOut"
  return element
end

function M.slash(x1, y1, x2, y2)
  return M.cut(M.line(2.8, { x = x1, y = y1 }, { x = x2, y = y2 })), M.line(1.3, { x = x1, y = y1 }, { x = x2, y = y2 })
end

function M.image(width, elements)
  local canvas = hs.canvas.new({ x = 0, y = 0, w = (width + 2 * MARGIN) * SCALE, h = HEIGHT * SCALE })
  local transformation = hs.canvas.matrix.scale(SCALE):translate(MARGIN, 0)
  for _, element in ipairs(elements) do
    element.transformation = transformation
    canvas:appendElements(element)
  end
  local image = canvas:imageFromCanvas():setSize({ w = width + 2 * MARGIN, h = HEIGHT })
  canvas:delete()
  return image
end

return M
