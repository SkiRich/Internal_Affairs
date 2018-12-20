-- Code developed for Internal Affairs
-- Author @SkiRich
-- All rights reserved, duplication and modification prohibited.
-- You may not copy it, package it, or claim it as your own.
-- Created Dec 17th, 2018
-- Updated Dec 17th, 2018

local lf_print = true -- Setup debug printing in local file
                       -- Use if lf_print then print("something") end

local ModDir = CurrentModPath
local iconIAnotice = ModDir.."UI/Icons/NoticeIconBlank.png"


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


-- Internal affairs function called during night shift
function IAexecuteInvestigation()
	local secStations = UICity.labels.SecurityStation or empty_table
	local workingStation = false
	for i = 1, #secStations do
		if secStations[i].working then workingStation = true end
	end -- for i

	if workingStation then
	end -- if workingStation

end -- IAexecuteInvestigation()


-------------------------------------------- OnMsgs --------------------------------------------------

function OnMsg.CityStart()
	IAaddCures()
end -- OnMsg.CityStart()

function OnMsg.LoadGame()
	IAaddCures()
end -- OnMsg.LoadGame()

function OnMsg.ClassesGenerate()

  -- renegades cannot train at university
  local Old_MartianUniversity_CanTrain = MartianUniversity.CanTrain
  function MartianUniversity:CanTrain(unit)
    if unit.traits.Renegade then
    	if lf_print then print("Renegade denied education") end
    	return  -- Renegade cannot train in Martian University
    end -- if renegade
	  return Old_MartianUniversity_CanTrain(self, unit)
  end --MartianUniversity:CanTrain(unit)

  local Old_Sanatorium_CanTrain = Sanatorium.CanTrain
  function Sanatorium:CanTrain(unit)
  	-- cannot cure renegade children
  	if unit.traits.Renegade and not TrainingBuilding.CanTrain(self, unit) then return false end

   -- cannot cure officer renegades
   if unit.traits.Renegade and unit.specialist = "security" then return false end

  	local cTraits = unit.traits
  	local canCureRenegade = false
    for k = 1, self.max_traits do
      if cTraits[self["trait" .. k]] then canCureRenegade = true end
    end -- for k

    if unit.traits.Renegade and canCureRenegade then
    	-- do renegade code
    	-- check for parole officer in home dome
    	local cDome = unit.dome
    	local secStations = cDome.labels.SecurityStation or empty_table
    	local parolOfficerAvailable = false

    	if #secStations > 0 then
    		for i = 1, #secStations do
    			if secStations[i].working then parolOfficerAvailable = true end
    		end -- for i
    	end -- if #secStations

    	if parolOfficerAvailable then
    	  if lf_print then print("PO Available Curing renegade") end
    	  unit.IA_PO = true
    	  return true
    	else
    	  if lf_print then print("PO NOT Available cannot cure renegade") end
    	  unit.IA_PO = false
    	  return false
    	end -- if parolOfficerAvailable

    elseif unit.traits.Renegade then
    	-- cannot cure renegade so dont let renegade into Sanatorium
    	if lf_print then print("Cannot cure renegade") end
    	return false
    end -- if unit is a renegade

    -- everybody else do normal code
    return Old_Sanatorium_CanTrain(self, unit)
  end -- Sanatorium:CanTrain(unit)

end -- OnMsg.ClassesGenerate()
