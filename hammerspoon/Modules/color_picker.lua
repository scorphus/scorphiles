local module = {}

local function pickColor()
  local bin = os.getenv("HOME") .. "/.hammerspoon/helpers/colorpicker"
  hs.task.new(bin, function(exitCode, stdout, stderr)
    local hex = stdout and stdout:match("#%x%x%x%x%x%x")
    if hex then
      hs.pasteboard.setContents(hex)
      hs.alert.show("Copied " .. hex)
    end
  end):start()
end

hs.hotkey.bind({ "cmd", "shift", "ctrl" }, "P", pickColor)

module.pickColor = pickColor
return module
