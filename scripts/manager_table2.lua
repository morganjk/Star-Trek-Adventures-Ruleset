-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	Comm.registerSlashHandler("rollon", processTableRoll);
	ActionsManager.registerResultHandler("table", onTableRoll);
end

function prepareTableDice(rRoll)
	local aFinalDice = {};
	
	local nOriginalMod = rRoll.nMod;
	
	local aNonStandardResults = {};
	for _,v in ipairs(rRoll.aDice) do
		if StringManager.contains(Interface.getDice(), v) then
			table.insert(aFinalDice, v);
		else
			local sDieSides = v:match("^[dD]([%dF]+)");
			if sDieSides then
				local nResult;
				if sDieSides == "F" then
					local nRandom = math.random(6);
					if nRandom == 1 then
						nResult = 1;
					elseif nRandom == 2 then
						nResult = 2;
					elseif nRandom == 5 then
						nResult = 1;
					elseif nRandom == 6 then
						nResult = 1;
					else
						nResult = 0;
					end
				else
					local nDieSides = tonumber(sDieSides) or 0;
					nResult = math.random(nDieSides);
				end
				rRoll.nMod = rRoll.nMod + nResult;
				table.insert(aNonStandardResults, string.format(" [%s=%d]", v, nResult));
			end
		end
	end
	
	if (nOriginalMod or 0) ~= 0 then
		table.insert(aNonStandardResults, string.format(" [%+d]", nOriginalMod));
	end
	
	rRoll.aDice = aFinalDice;
	if #aNonStandardResults > 0 then
		rRoll.sDesc = rRoll.sDesc .. table.concat(aNonStandardResults, "");
	end
end
