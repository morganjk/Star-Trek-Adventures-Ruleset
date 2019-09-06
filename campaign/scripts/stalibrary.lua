function onInit()
  -- Grabbing the action handler to process my onRoll command to give me control over the results of Damned's Conan roller.
  -- Keith Johnson
	GameSystem.actions["sta"] = { bUseModStack = true, sTargeting = "all" };
	ActionsManager.registerResultHandler("sta", onRoll);
end

function attribSelect(winFrame, nAttrib)
	local nodeWin = winFrame.getDatabaseNode();
	local testattrib = DB.getValue(nodeWin, nAttrib);
	DB.setValue(nodeWin, "attrib", "number", testattrib);
	return true;
end

function discipSelect(winFrame, nDiscip)
	local nodeWin = winFrame.getDatabaseNode();
	local testdiscip = DB.getValue(nodeWin, nDiscip);
	DB.setValue(nodeWin, "discip", "number", testdiscip);
	return true;
end


function taskcheck(draginfo, winFrame)
	local nodeWin = winFrame.getDatabaseNode();
	local rActor = ActorManager.getActor("pc", nodeWin);
	local rolling20 = nodeWin.getChild("rollable.dicetoroll").getValue();
	local sides = 20
	local TN = nodeWin.getChild("rollable.targetroll").getValue();
	local FC = nodeWin.getChild("rollable.focusused").getValue();
	local nFocus = 0
		if FC == 0 then
			nFocus = 1;
		elseif FC == 1 then 
			nFocus = DB.getValue(nodeWin, "discip");
		end
	local nComp = nodeWin.getChild("rollable.comprange").getValue();
	local comp = 21 - nComp
	local sParams = rolling20.."d"..sides.."x"..TN.."y"..nFocus.."c"..comp;
	local msg = {font = "sheetlabel"};
	msg.text = rActor.sName .. " rolls a task"
	Comm.deliverChatMessage(msg);
	local msg = {font = "sheetlabel"};
	msg.text= "Target Number.." .. TN.."\nFocus Range.."..nFocus.."\nComplication Range.."..nComp.."\nRolling "..rolling20.. "d20\n";
	Comm.deliverChatMessage(msg);

	resetdice(winFrame);
	DiceRoller.performAction(draginfo, rActor, sParams)
	return true;
end

function challengecheck(draginfo, winFrame)
	local nodeWin = winFrame.getDatabaseNode();
	local rActor = ActorManager.getActor("pc", nodeWin);
	local rolling = nodeWin.getChild("damage").getValue();
	local sides = 6
	local sParams = rolling.."d"..sides;
	local msg = {font = "sheetlabel"};
	msg.text = rActor.sName .. " does damage"
	Comm.deliverChatMessage(msg);
	local msg = {font = "sheetlabel"};
	msg.text= "Rolling "..rolling.."d"..sides.."\n";
	Comm.deliverChatMessage(msg);
	ChallengeDiceManager.performAction(draginfo, rActor, sParams);
	return true;
end


function repcheck(dragInfo, winFrame)
	local nodeWin = winFrame.getDatabaseNode();
	local rActor = ActorManager.getActor("pc", nodeWin);
	local rolling = nodeWin.getChild("reputation.challengedie").getValue();
	local sides = 20
	local nRep = nodeWin.getChild("reputation.reputation").getValue();
	local nPriv = nodeWin.getChild("reputation.privilege").getValue();
	local nRespons = nodeWin.getChild("reputation.responsibility").getValue();
	local sParams = rolling.."d"..sides.."x"..nRep.."y"..nPriv.."c"..nRespons;
	local msg = {font = "sheetlabel"};
	msg.text = rActor.sName .. " rolls reputation"
	Comm.deliverChatMessage(msg);
	local msg = {font = "sheetlabel"};
	msg.text= "Reputation.." .. nRep.."\nPrivilege.."..nPriv.."\nResponsibility.."..nRespons.."\nRolling "..rolling.. "d20\n";
	Comm.deliverChatMessage(msg);

	ReputationManager.performAction(draginfo, rActor, sParams);
	return true;
end

function resetdice(winFrame)
	local nodeWin = winFrame.getDatabaseNode();
	nodeWin.getChild("rollable.dicetoroll").setValue(2);
	nodeWin.getChild("rollable.comprange").setValue(1);
	nodeWin.getChild("rollable.focusused").setValue(0);
end

function rankchange(draginfo, winFrame)

	local nodeWin = winFrame.getDatabaseNode();
	local curRank = DB.getValue(nodeWin, "rank");
	DB.setValue(nodeWin, "reputation.rank", "string", curRank);
	DB.setValue(nodeWin, "reputation.reputation", "number", 10);
	
	if DB.getValue(nodeWin, "reputation.rank") == "Ensign" then
		nodeWin.getChild("reputation.privilege").setValue(1);
		nodeWin.getChild("reputation.responsibility").setValue(20);
	elseif DB.getValue(nodeWin, "reputation.rank") == "Lieutenant" then
		nodeWin.getChild("reputation.privilege").setValue(2);
		nodeWin.getChild("reputation.responsibility").setValue(19);
	elseif DB.getValue(nodeWin, "reputation.rank") == "Commander" then
		nodeWin.getChild("reputation.privilege").setValue(3);
		nodeWin.getChild("reputation.responsibility").setValue(18);
	elseif DB.getValue(nodeWin, "reputation.rank") == "Captain" then
		nodeWin.getChild("reputation.privilege").setValue(4);
		nodeWin.getChild("reputation.responsibility").setValue(17);
	end

		
end

function onRoll(rSource, rTarget, rRoll)
	rRoll = DiceRoller.dropDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rRoll);
	rMessage.font="copper10";
	rMessage.type = "dice";
	Comm.deliverChatMessage(rMessage);
end

function npctaskcheck(draginfo, winFrame)
	local nodeWin = winFrame.getDatabaseNode();
	local rActor = ActorManager.getActor("pc", nodeWin);
	local rolling20 = nodeWin.getChild("rollable.dicetoroll").getValue();
	local sides = 20
	local TN = nodeWin.getChild("rollable.targetroll").getValue();
	local FC = nodeWin.getChild("rollable.focusused").getValue();
	local nFocus = 0
		if FC == 0 then
			nFocus = 1;
		elseif FC == 1 then 
			nFocus = DB.getValue(nodeWin, "discip");
		end
	local nComp = nodeWin.getChild("rollable.comprange").getValue();
	local comp = 21 - nComp
	local sParams = rolling20.."d"..sides.."x"..TN.."y"..nFocus.."c"..comp;
	local msg = {font = "sheetlabel"};
	msg.text = rActor.sName .. " rolls a task"
	Comm.deliverChatMessage(msg);
	local msg = {font = "sheetlabel"};
	msg.text= "Target Number.." .. TN.."\nFocus Range.."..nFocus.."\nComplication Range.."..nComp.."\nRolling "..rolling20.. "d20\n";
	Comm.deliverChatMessage(msg);

	npcresetdice(winFrame);
	DiceRoller.performAction(draginfo, rActor, sParams)
	return true;
end

function npcresetdice(winFrame)
	local nodeWin = winFrame.getDatabaseNode();
	nodeWin.getChild("rollable.dicetoroll").setValue(1);
	nodeWin.getChild("rollable.comprange").setValue(1);
	nodeWin.getChild("rollable.focusused").setValue(0);
end