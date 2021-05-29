local clockingLog = hs.logger.new("clocking")
local clockingMenu = hs.menubar.new()
local currentTask = nil

local function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function eval(sexp, callback)
   hs.task.new(
      "/opt/homebrew/bin/emacsclient",
      function(exitCode, stdOut, stdErr)
         if exitCode == 0 then
            callback(trim(stdOut))
         end
      end,
      { "--eval", sexp }
   ):start()
end


local function updateClockingMenu()
   eval(
      "(org-clock-is-active)",
      function(value)
         if value == "nil" then
            clockingMenu:setTitle("No Task")
         else
            eval(
                "(org-clock-get-clock-string)",
                function(value)
                   clockingMenu:setTitle(string.match(value, '"(.+)"'))
                end
            )
         end
      end
   )
end

local function startUpdatingClockingMenu()
  return hs.timer.doEvery(10, updateClockingMenu)
end

local mod = {}

function mod.init()
  updateClockingMenu()
  return startUpdatingClockingMenu()
end

return mod
