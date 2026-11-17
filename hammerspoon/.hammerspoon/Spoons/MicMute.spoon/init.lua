--- === MicMute ===
---
--- Microphone Mute Toggle and status indicator
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/MicMute.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/MicMute.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "MicMute"
obj.version = "1.0"
obj.author = "dctucker <dctucker@github.com>"
obj.homepage = "https://dctucker.com"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.set_visibility_callback = nil

--- MicMute:setVisibility(muted)
--- Method
--- Set visibility options
---
--- Parameters:
---  * muted - Boolean flag indicating whether the mic is muted or not.
function obj:setVisibility(muted)
	if muted then
		obj.mute_menu:setTitle("📵 Muted")
	else
		obj.mute_menu:setTitle("🎙 On")
	end
end

function obj:updateMicMute(muted)
	if muted == -1 then
		muted = hs.audiodevice.defaultInputDevice():muted()
	end
	if obj.set_visibility_callback ~= nil then
		obj.set_visibility_callback(muted)
	else
		obj:setVisibility(muted)
	end
end

--- MicMute:toggleMicMute()
--- Method
--- Toggle mic mute on/off
---
function obj:toggleMicMute()
	local mic = hs.audiodevice.defaultInputDevice()
	local zoom = hs.application'Zoom'
	if mic:muted() then
		mic:setMuted(false)
		if zoom then
			local ok = zoom:selectMenuItem'Unmute Audio'
			if not ok then
				hs.timer.doAfter(0.5, function()
					zoom:selectMenuItem'Unmute Audio'
				end)
			end
		end
	else
		mic:setMuted(true)
		if zoom then
			local ok = zoom:selectMenuItem'Mute Audio'
			if not ok then
				hs.timer.doAfter(0.5, function()
					zoom:selectMenuItem'Mute Audio'
				end)
			end
		end
	end
	obj:updateMicMute(-1)
end

--- MicMute:bindHotkeys(mapping, latch_timeout)
--- Method
--- Binds hotkeys for MicMute
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * toggle - This will cause the microphone mute status to be toggled. Hold for momentary, press quickly for toggle.
---  * latch_timeout - Time in seconds to hold the hotkey before momentary mode takes over, in which the mute will be toggled again when hotkey is released. Latch if released before this time. 0.75 for 750 milliseconds is a good value.
function obj:bindHotkeys(mapping, latch_timeout)
	if (self.hotkey) then
		self.hotkey:delete()
	end
	local mods = mapping["toggle"][1]
	local key = mapping["toggle"][2]

	if latch_timeout then
		self.hotkey = hs.hotkey.bind(mods, key, function()
			self:toggleMicMute()
			self.time_since_mute = hs.timer.secondsSinceEpoch()
		end, function()
			if hs.timer.secondsSinceEpoch() > self.time_since_mute + latch_timeout then
				self:toggleMicMute()
			end
		end)
	else
		self.hotkey = hs.hotkey.bind(mods, key, function()
			self:toggleMicMute()
		end)
	end

	return self
end

function obj:bindVisibilitySetter(callback)
	obj.set_visibility_callback = callback
	obj:updateMicMute(-1)
end

function obj:init()
	obj.time_since_mute = 0
	obj.mute_menu = hs.menubar.new()
	obj.mute_menu:setClickCallback(function()
		obj:toggleMicMute()
	end)
	obj:updateMicMute(-1)

	hs.audiodevice.watcher.setCallback(function(arg)
		if string.find(arg, "dIn ") then
			obj:updateMicMute(-1)
		end
	end)
	hs.audiodevice.watcher.start()
end

return obj
