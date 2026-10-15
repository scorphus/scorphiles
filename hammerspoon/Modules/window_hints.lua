local hotkey = require "Modules/hotkey"
-- Right hand first, home row then the rows above and below, then the left hand the same way.
local hintChars = {
  "J", "K", "L", "H", "U", "I", "O", "P", "Y", "N", "M",
  "F", "D", "S", "A", "G", "R", "E", "W", "Q", "T", "V", "C", "X", "Z", "B",
}

local hintCanvases = {}
local hintModal = nil

local function clearHints()
  for _, c in ipairs(hintCanvases) do c:delete() end
  hintCanvases = {}
  if hintModal then hintModal:exit() end
end

-- Custom hints: app icon on the left, hint letter on the right of it.
-- Windows are labelled front-to-back (z-order) in the home-row key order.
local function showWindowHints()
  clearHints()
  hintModal = hs.hotkey.modal.new()
  hintModal:bind({}, "escape", clearHints)

  local iconSize, pad, fontSize, letterW = 64, 14, 48, 48
  local boxW = pad + iconSize + pad + letterW + pad
  local boxH = iconSize + pad * 2
  local gap = 8

  local function drawHint(win, ch, x, y)
    local c = hs.canvas.new({ x = x, y = y, w = boxW, h = boxH })
    c[#c + 1] = {
      type = "rectangle", action = "fill",
      roundedRectRadii = { xRadius = 10, yRadius = 10 },
      fillColor = { red = 0, green = 0, blue = 0, alpha = 0.82 },
    }
    local app = win:application()
    local icon = app and app:bundleID() and hs.image.imageFromAppBundle(app:bundleID())
    if icon then
      c[#c + 1] = { type = "image", image = icon, frame = { x = pad, y = pad, w = iconSize, h = iconSize } }
    end
    c[#c + 1] = {
      type = "text", text = ch, textColor = { white = 1, alpha = 1 },
      textSize = fontSize, textAlignment = "center",
      frame = { x = pad + iconSize + pad, y = (boxH - fontSize * 1.25) / 2, w = letterW, h = fontSize * 1.4 },
    }
    c:level(hs.canvas.windowLevels.overlay)
    c:show()
    hintCanvases[#hintCanvases + 1] = c

    hintModal:bind({}, ch, function()
      clearHints()
      win:focus()
    end)
  end

  -- Assign a letter per window (z-order) and group windows by shared centre
  local groups, order = {}, {}
  for i, win in ipairs(hs.window.orderedWindows()) do
    local ch = hintChars[i]
    if not ch then break end
    local f = win:frame()
    local cx, cy = f.x + f.w / 2, f.y + f.h / 2
    local key = math.floor(cx / 20) .. "," .. math.floor(cy / 20)
    local g = groups[key]
    if not g then g = { cx = cx, cy = cy, items = {} }; groups[key] = g; order[#order + 1] = g end
    g.items[#g.items + 1] = { win = win, ch = ch }
  end

  -- Draw each group stacked vertically, centred on the shared centre
  for _, g in ipairs(order) do
    local n = #g.items
    local totalH = n * boxH + (n - 1) * gap
    local startY = g.cy - totalH / 2
    for idx, it in ipairs(g.items) do
      drawHint(it.win, it.ch, g.cx - boxW / 2, startY + (idx - 1) * (boxH + gap))
    end
  end

  if #hintCanvases == 0 then return end
  hintModal:enter()
end

hotkey.bind({ "cmd", "alt", "ctrl" }, "H", "Window hints", showWindowHints)
