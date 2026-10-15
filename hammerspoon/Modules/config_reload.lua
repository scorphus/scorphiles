local function reloadConfig(files)
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end
configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config loaded")
