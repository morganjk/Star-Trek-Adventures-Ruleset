-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "chall";

-- MoreCore v0.60 
function onInit()
  CustomDiceManager.add_roll_type(sCmd, performAction, onLanded, true, "all");
end

function performAction(draginfo, rActor, sParams)
  if not sParams or sParams == "" then 
    sParams = "1d6";
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
  rRoll.aDice = {};
  local nStart, nEnd, sDicePattern, sDescriptionParam = string.find(sParams, "([^%s]+)%s*(.*)");
  rRoll.sDesc = sDescriptionParam;
  if sTarget then
    rRoll.nTarget = tonumber(sTarget);
    rRoll.sDesc = sDescriptionParam;
	else
		rRoll.sDesc = sParams;
  end
  
  -- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
  if not sDicePattern:match("([^%s]+)") then
    rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d#\" ";
    return rRoll;
  end
  local sDice = sDicePattern:match("([^%s]+)");
  local aDice = StringManager.convertStringToDice(sDice);
  local aRulesetDice = Interface.getDice();
  local aFinalDice = {};
  local aNonStandardResults = {};
  for k,v in ipairs(aDice) do
    if StringManager.contains(aRulesetDice, v) then
      table.insert(aFinalDice, v);
    elseif v:sub(1,1) == "-" and StringManager.contains(aRulesetDice, v:sub(2)) then
      table.insert(aFinalDice, v);
    else
      local sSign, sDieSides = v:match("^([%-%+]?)[dD]([%dF]+)");
      if sDieSides then
        local nResult;
          local nDieSides = tonumber(sDieSides) or 0;
          nResult = math.random(nDieSides);
        
        if sSign == "-" then
          nResult = 0 - nResult;
        end
        
        table.insert(aNonStandardResults, string.format(" [%s=%d]", v, nResult));
      end
    end
  end
  if sDesc ~= "" then
  sDesc = rRoll.sDesc;
  else
    sDesc = sDice;
  end
  if #aNonStandardResults > 0 then
    sDesc = sDesc .. table.concat(aNonStandardResults, "");
  end
  local rRoll = { sType = sCmd, sDesc = sDesc, aDice = aFinalDice, nMod = 0 };
  ActionsManager.performAction(draginfo, rActor, rRoll);
end

---
--- This function calulates the total number rolled and the total number of
--- effects if any.
---
function getDiceResults(rRoll)
nTotal = 0;
nEffect = 0;
    for _,v in ipairs(rRoll.aDice) do
		if v.result <= 2 then
			nTotal = nTotal + v.result;
		elseif v.result >= 5 then
			nTotal = nTotal + 1
			nEffect = nEffect + 1
		end
	end
  rRoll.aTotal = nTotal;
  rRoll.aEffect = nEffect;
  return rRoll;
end
---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    rMessage.text = rMessage.text.. "\n" .."[Total:]"..rRoll.aTotal.."\n".."[Effects:]".. rRoll.aEffect;
    rMessage.dicedisplay = 0; -- don't display total
    rMessage.text = rMessage.text;
  return rMessage;
end