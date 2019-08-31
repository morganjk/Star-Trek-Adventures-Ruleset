-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "trek";

-- MoreCore v0.60 
function onInit()
	CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
	if not sParams or sParams == "" then 
		sParams = "2d20x8y1";
	end

	if sParams == "?" or string.lower(sParams) == "help" then
		createHelpMessage();    
	else
		local rRoll = createRoll(sParams);
		ActionsManager.performAction(draginfo, rActor, rRoll);
	end   

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
	rRoll.nComp = 0;
  
	local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
	rRoll.sDesc = sDescriptionParam;

	if(not sParams:match("(%d+)d([%dF]*)x(%d+)%s*(.*)") and sParams:match("(%d+)d([%dF]+)%s*(.*)")) then
		sDicePattern = sDicePattern .. "x8"
	end
  
	-- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if not sDicePattern:match("(%d+)d([%dF]*)x(%d+)") then
		rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#x#\" or \"#d#x#y#\"";
		return rRoll;
	end

	local sNum, sSize, sSkill, sFocus, sComp = sDicePattern:match("(%d+)d([%dF]+)x(%d+)y(%d+)c(%d+)");
	if sNum == nil then
		sFocus = "1";
		sNum, sSize, sSkill = sDicePattern:match("(%d+)d([%dF]+)x(%d+)");
	end
	
	local count = tonumber(sNum);
	local size = tonumber(sSize);
	local skill = tonumber(sSkill);
	local focus = tonumber(sFocus);
	local comp = tonumber(sComp);

	while count > 0 do
		table.insert(rRoll.aDice, "d" .. sSize);
	
		-- For d100 rolls, we also need to add a d10 dice for the ones place
		if sSize == "100" then
			table.insert(rRoll.aDice, "d10");
		end
		count = count - 1;
	end
  
	rRoll.nSkill = skill;
	rRoll.nFocus = focus;
	rRoll.nComp = comp;

	return rRoll;
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function getDiceResults(rRoll)

	local skill = tonumber(rRoll.nSkill);
	local focus = tonumber(rRoll.nFocus) or 1;
	local comp = tonumber(rRoll.nComp) or 20;
	local successes = 0;
	local complications = 0;
  
	for _,v in ipairs(rRoll.aDice) do
		if v.result <= skill then
			successes = successes + 1;
			if v.result <= focus then
				successes = successes + 1;
			end
		end
		if v.result >= comp then
			complications = complications + 1;
		end
	end

	

	rRoll.aSuccesses = successes;
	rRoll.aFocus = focus;
	rRoll.aSkill = skill;
	rRoll.aComplications = complications;

	return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rMessage.text = rMessage.text .. "\n[Skill] " .. rRoll.aSkill .. "\n[Focus] " .. rRoll.aFocus .. "\n[Successes] " .. rRoll.aSuccesses .. "\n[Complications] " .. rRoll.aComplications;

	rMessage.dicedisplay = 0; -- don't display total
  
	rMessage.text = rMessage.text;

	return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()  
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text .. "The \"/"..sCmd.."\" command is used to roll a set of dice, removing a number of the lowest results.\n"; 
	rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the number of results to be dropped "; 
	rMessage.text = rMessage.text .. "by supplying the \"/rolld\" command with parameters in the format of \"#d#x#\", where the first # is the "; 
	rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
	rMessage.text = rMessage.text .. "x being the number of results to be dropped.\n"; 
	rMessage.text = rMessage.text .. "If no parameters are supplied, the default parameters of \"4d6x1\" are used."; 
	Comm.deliverChatMessage(rMessage);
end
