-- Code developed for Internal Affairs
-- Author @SkiRich
-- All rights reserved, duplication and modification prohibited.
-- You may not copy it, package it, or claim it as your own.
-- Created Dec 17th, 2018
-- Updated Dec 17th, 2018

local lf_print = true -- Setup debug printing in local file
                       -- Use if lf_print then print("something") end

local ModDir = CurrentModPath



-- adds additional traits to Sanatorium for curing
local function IAaddCures()
	-- add Renegade,
	local curableTraits = g_SanatoriumTraits
  local found = false

  for i = 1, #curableTraits do
  	if curableTraits[i] == "Renegade" then
  		found = true
  		if lf_print then print("Found Renegade curable trait") end
  		break
  	end -- if curableTraits
  end -- for i

	if not found then
		if lf_print then print("Renegade cure not found.  Adding cure.") end
		table.insert(curableTraits, "Renegade")
	end -- if not found
end -- function IAaddCures()



-------------------------------------------- OnMsgs --------------------------------------------------

function OnMsg.CityStart()
	IAaddCures()
end -- OnMsg.CityStart()

function OnMsg.LoadGame()
	IAaddCures()
end -- OnMsg.LoadGame()

function OnMsg.ClassesGenerate()

  local Old_MartianUniversity_CanTrain = MartianUniversity.CanTrain
  function MartianUniversity:CanTrain(unit)
    if unit.traits.Renegade then return end -- Renegade cannot train in Martian University

    print("Test from IA")
	  return Old_MartianUniversity_CanTrain(self, unit)
  end --MartianUniversity:CanTrain(unit)

end -- OnMsg.ClassesGenerate()