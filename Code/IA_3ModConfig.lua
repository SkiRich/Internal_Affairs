-- Code developed for Internal Affairs
-- Author @SkiRich
-- All rights reserved, duplication and modification prohibited.
-- You may not copy it, package it, or claim it as your own.
-- Created Dec 17th, 2018
-- Updated Dec 20th, 2018

local lf_print = false -- Setup debug printing in local file
                       -- Use if lf_print then print("something") end

local StringIdBase = 17764701200 -- Deposit Auto Refill  : 701200 - 701299 this file 50-99 next:

local steam_id = "0"
local mod_name = "Internal Affairs"

-- Variable replacement for mod config steam id for check.
local ModConfig_id = "1542863522" -- Reborn
local ModConfigWaitThread = false
g_ModConfigLoaded = false


function OnMsg.ModConfigReady()

    -- Register this mod's name and description
    ModConfig:RegisterMod("IA", -- ID
        T{StringIdBase, "Internal Affairs"}, -- Optional display name, defaults to ID
        T{StringIdBase + 50, "Options for Internal Affairs"} -- Optional description
    )

    ModConfig:RegisterOption("IA", "IAdismissMsg", {
        name = T{StringIdBase + 51, "Auto dismiss notification: "},
        desc = T{StringIdBase + 52, "Auto dismiss Internal Affairs messages.  Set the time below."},
        type = "boolean",
        default = true,
        order = 1
    })

    ModConfig:RegisterOption("IA", "IAnoticeDismissTime", {
        name = T{StringIdBase + 53, "Auto dismiss notification time in seconds:"},
        desc = T{StringIdBase + 54, "The number of seconds to keep notifications on screen before dismissing."},
        type = "number",
        default = 15,
        min = 1,
        max = 200,
        step = 1,
        order = 2
    })

end -- ModConfigReady


function OnMsg.ModConfigChanged(mod_id, option_id, value, old_value, token)
  if g_ModConfigLoaded and (mod_id == "IA") and (token ~= "reset") then

  	-- IAdismissMsg
  	if option_id == "IAdismissMsg" then
  		if value then
  			local dismissmsgtime = ModConfig:Get("IA", "IAnoticeDismissTime")
  			g_IAnoticeDismissTime = dismissmsgtime * 1000 -- (msec)
  		else
  			g_IAnoticeDismissTime = -1 -- stay on screen until dismissed
  		end -- if value is true
    end -- ATPdismissMsg

  	-- IAnoticeDismissTime
  	if option_id == "ATPnoticeDismissTime" and ModConfig:Get("IA", "IAdismissMsg") then
  		-- dont alter the global since we use that as -1 for do not dismiss above
      g_IAnoticeDismissTime = value * 1000 -- in msecs
    end -- ATPdismissMsg

  end -- if g_ModConfigLoaded
end -- OnMsg.ModConfigChanged


function OnMsg.CityStart()
	-- Setup modconfig defaults
	if g_ModConfigLoaded then
	  local IAdismissMsg        = ModConfig:Get("IA", "IAdismissMsg")
	  local IAnoticeDismissTime = ModConfig:Get("IA", "IAnoticeDismissTime")
	  if IAdismissMsg then
	  	g_IAnoticeDismissTime = IAnoticeDismissTime * 1000 -- in msecs
	  else
	  	g_IAnoticeDismissTime = -1 -- always stay on
	  end -- if IAdismissMsg then
  end -- if g_ModConfigLoaded
end -- OnMsg.CityStart()


function OnMsg.LoadGame()
	-- Setup modconfig defaults
	if g_ModConfigLoaded then
	  local IAdismissMsg        = ModConfig:Get("IA", "IAdismissMsg")
	  local IAnoticeDismissTime = ModConfig:Get("IA", "IAnoticeDismissTime")
	  if IAdismissMsg then
	  	g_IAnoticeDismissTime = IAnoticeDismissTime * 1000 -- in msecs
	  else
	  	g_IAnoticeDismissTime = -1 -- always stay on
	  end -- if IAdismissMsg then
  end -- if g_ModConfigLoaded
end -- OnMsg.LoadGame()


local function SRDailyPopup()
    CreateRealTimeThread(function()
        local params = {
              title = "Non-Author Mod Copy",
               text = "We have detected an illegal copy version of : ".. mod_name .. ". Please uninstall the existing version.",
            choice1 = "Download the Original [Opens in new window]",
            choice2 = "Damn you copycats!",
            choice3 = "I don't care...",
              image = "UI/Messages/death.tga",
              start_minimized = false,
        } -- params
        local choice = WaitPopupNotification(false, params)
        if choice == 1 then
        	OpenUrl("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. steam_id, true)
        end -- if statement
    end ) -- CreateRealTimeThread
end -- function end


function OnMsg.NewDay(day)
  if table.find(ModsLoaded, "steam_id", steam_id)~= nil then
    --nothing
  else
    SRDailyPopup()
  end -- SRDailyPopup

end --OnMsg.NewDay(day)
