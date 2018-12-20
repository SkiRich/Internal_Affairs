-- Code developed for Internal Affairs
-- Author @SkiRich
-- All rights reserved, duplication and modification prohibited.
-- You may not copy it, package it, or claim it as your own.
-- Created Dec 17th, 2018
-- Updated Dec 17th, 2018

local lf_print = true -- Setup debug printing in local file
                       -- Use if lf_print then print("something") end

local StringIdBase = 17764701200 -- Deposit Auto Refill  : 701200 - 701299 next: 5
local ModDir = CurrentModPath
local iconIAnotice = ModDir.."UI/Icons/NoticeIconBlank.png"


g_IAnoticeDismissTime = 15000 -- Notice dismiss time in msecs


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

-- remove worker specialization and optionally fire worker
local function IAremoveSpecialization(unit, fireworker, firedOfficers)
  local specialization = unit.specialist
  local workplace = unit.workplace

	if specialization == "security" then
  	unit.city:RemoveFromLabel(unit.specialist, unit)
	  unit:RemoveTrait(unit.specialist)
	  unit.specialist = "none"
	  unit.traits.none = true
    unit:ChooseEntity()
    unit.city:AddToLabel(unit.specialist, unit)
    Msg("NewSpecialist", unit)
  end -- if specialization

  local IAmsg = T{StringIdBase + 3, "Internal affairs found renegade officers"}
  if not firedOfficers then
  	firedOfficers = {}
  	table.insert(firedOfficers, unit)
  end -- if not firedOfficers
  AddCustomOnScreenNotification("IA_IANotice", T{StringIdBase + 4, "Internal Affairs"}, IAmsg, iconIAnotice, nil, {cycle_objs = firedOfficers, expiration = g_IAnoticeDismissTime})
	PlayFX("UINotificationResearchComplete", unit)

  if fireworker and workplace then workplace:FireWorker(unit) end
end -- IAremoveSpecialization(unit)

-- Internal affairs function called during night shift
function IAexecuteInvestigation()
	local secStations = UICity.labels.SecurityStation or empty_table
	local workingStation = false
	local fireworker = true
	local firedOfficers = {}

	for i = 1, #secStations do
		if secStations[i].working then workingStation = true end
	end -- for i

	if workingStation then
	  for i = 1, #secStations do
	  	local workshifts = secStations[i].workers
      for j = 1, #workshifts do
      	local workers = workshifts[j]
     		for k = 1, #workers do
     			if workers[k].traits.Renegade then
     				table.insert(firedOfficers, workers[k])
     				IAremoveSpecialization(workers[k], fireworker, firedOfficers)
     			end -- if renegade
      	end -- for k
      end -- for k
	  end -- for i
	end -- if workingStation

end -- IAexecuteInvestigation()


-------------------------------------------- OnMsgs --------------------------------------------------

function OnMsg.CityStart()
	IAaddCures()
end -- OnMsg.CityStart()

function OnMsg.LoadGame()
	IAaddCures()
end -- OnMsg.LoadGame()

function OnMsg.NewDay()
	IAexecuteInvestigation()
end -- OnMsg.NewDay()

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

   -- cannot cure officer renegades working at a security station
   if unit.traits.Renegade and unit.specialist == "security" and IsKindOf(unit.workplace, "SecurityStation") then return false end

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
        if not unit.IA_PO then
        	local colonistname = _InternalTranslate(unit.name)
        	local IAmsg = T{StringIdBase + 1, "Officer assigned to: <colonistname>", colonistname = colonistname}
          AddCustomOnScreenNotification("IA_PONotice", T{StringIdBase + 2, "Parole Officer Assigned"}, IAmsg, iconIAnotice, nil, {cycle_objs = {unit}, expiration = g_IAnoticeDismissTime})
	        PlayFX("UINotificationResearchComplete", self)
	      end -- if not unit.IA_PO
	      if lf_print and not unit.IA_PO then print("PO Available Curing renegade") end
	      if unit.specialist == "security" then IAremoveSpecialization(unit) end
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
