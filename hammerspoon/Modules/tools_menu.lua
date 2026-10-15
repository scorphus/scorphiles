local colorPicker = require "Modules/color_picker"

local announceMuteFlag = os.getenv("HOME") .. "/.claude/announce-muted"

local function announcementsMuted()
  return hs.fs.attributes(announceMuteFlag) ~= nil
end

toolsMenu = hs.menubar.new()

local function refreshToolsMenuTitle()
  toolsMenu:setTitle(announcementsMuted() and "🔕" or "🎛")
end

toolsMenu:setMenu(function()
  return {
    { title = "Pick color (⌘⇧⌃P)", fn = colorPicker.pickColor },
    {
      title = "Mute Claude announcements",
      checked = announcementsMuted(),
      fn = function()
        if announcementsMuted() then
          os.remove(announceMuteFlag)
        else
          io.open(announceMuteFlag, "w"):close()
        end
        refreshToolsMenuTitle()
      end,
    },
  }
end)
refreshToolsMenuTitle()
