-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "rep";

-- MoreCore v0.60 
function onInit()
	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
	if not sParams or sParams == "" then 
		sParams = "2d20x10y1";
	end

	local rRoll = createRoll(sParams);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end


function onLanded(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rRoll = getDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rRoll);
	rMessage.type = "dice";
	Comm.deliverChatMessage(rMessage);
end


---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
	local rRoll = {};
	rRoll.sType = sCmd;
	rRoll.nMod = 0;
	rRoll.aDice = {};
	rRoll.aDropped = {};
	rRoll.nRespons = 0;
  
	local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
	rRoll.sDesc = sDescriptionParam;

	if(not sParams:match("(%d+)d([%dF]*)x(%d+)%s*(.*)") and sParams:match("(%d+)d([%dF]+)%s*(.*)")) then
		sDicePattern = sDicePattern .. "x10"
	end
  
	-- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if not sDicePattern:match("(%d+)d([%dF]*)x(%d+)") then
		rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#x#\" or \"#d#x#y#\"";
		return rRoll;
	end

	local sNum, sSize, sRep, sPriv, sRespons = sDicePattern:match("(%d+)d([%dF]+)x(%d+)y(%d+)c(%d+)");
	if sNum == nil then
		sPriv = "1";
		sNum, sSize, sRep = sDicePattern:match("(%d+)d([%dF]+)x(%d+)");
	end
	
	local count = tonumber(sNum);
	local size = tonumber(sSize);
	local reputation = tonumber(sRep);
	local privilege = tonumber(sPriv);
	local responsibility = tonumber(sRespons);

	while count > 0 do
		table.insert(rRoll.aDice, "d" .. sSize);
		count = count - 1;
	end
  
	rRoll.nRep = reputation;
	rRoll.nPriv = privilege;
	rRoll.nRespons = responsibility;

	return rRoll;
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function getDiceResults(rRoll)

	local reputation = tonumber(rRoll.nRep);
	local privilege = tonumber(rRoll.nPriv) or 1;
	local responsibility = tonumber(rRoll.nRespons) or 20;
	local successes = 0;
	local failure = 1;
  
	for _,v in ipairs(rRoll.aDice) do
		if v.result <= reputation then
			successes = successes + 1;
			if v.result <= privilege then
				successes = successes + 1;
			end
		end
		if v.result >= responsibility then
			failure = failure + 1;
		end
	end

	

	rRoll.aSuccesses = successes;
	rRoll.aPriv = privilege;
	rRoll.aRep = reputation;
	rRoll.aFailure = failure;

	return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rMessage.text = rMessage.text .. "\n[Successes] " .. rRoll.aSuccesses .. "\n[Failures] " .. rRoll.aFailure;

	rMessage.dicedisplay = 0; -- don't display total
  
	rMessage.text = rMessage.text;

	return rMessage;
end