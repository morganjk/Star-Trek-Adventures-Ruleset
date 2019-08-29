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


function repcheck(winFrame)
	local rRoll="dCD";
	Debug.chat(dCD);
	Debug.chat(rRoll);
	
	local rActor = ActorManager.getActor("pc", winFrame.getDatabaseNode());
	Debug.console("rActor: ");
	Debug.console(rActor);
					
	local nodeWin = winFrame.getDatabaseNode();
	Debug.console("nodeWin: ");
	Debug.console(nodeWin);
						
	local CD = nodeWin.getChild("reputation.challengedie").getValue();
	Debug.console("CD: ");
	Debug.console(CD);
					
	local msg = {font = "chatfont"};
	msg.text = rActor.sName .. " rolls for reputation"
	Comm.deliverChatMessage(msg);
	
	sta.processRoll("sta", CD.."dCDx");
	return true;
end

function resetdice(winFrame)
	local nodeWin = winFrame.getDatabaseNode();
	nodeWin.getChild("rollable.dicetoroll").setValue(2);
	nodeWin.getChild("rollable.comprange").setValue(1);
	nodeWin.getChild("rollable.focusused").setValue(0);
end

--[[
function CombatDice(type, bonus, name)
	if control then
		local dice = {};
		table.insert(dice, type);
		control.throwDice("dice", dice, bonus, name);
	end
end


function NPCskillcheck(winFrame,button,button2,desc)
	local rRoll="2d20";
	local rActor = ActorManager.getActor("pc", winFrame.getDatabaseNode());
	Debug.console("rActor: ");
	Debug.console(rActor);
					
	local nodeWin = winFrame.getDatabaseNode();
	Debug.console("nodeWin: ");
	Debug.console(nodeWin);
						
	local attrib = nodeWin.getChild(button2.."score").getValue();
	Debug.console("accroTN: ");
	Debug.console(attrib);
					
	local skill = nodeWin.getChild(button.."score").getValue();
	Debug.console("accroFC: ");
	Debug.console(skill);
					
	local rolling20 = nodeWin.getChild("NPCdicetoroll").getValue();
	Debug.console("rolling20: ");
	Debug.console(rolling20);
	

	
	local TN=attrib+skill
	local FC=skill
						
	local msg = {font = "crom-12"};
	msg.text = rActor.sName .. " makes a "..desc.." test\n  Target of " .. TN.."\n  Focus of "..FC..".\n Rolling "..rolling20.. "d20"
	Comm.deliverChatMessage(msg);
	
	local msg = {font = "crom-8"};
	msg.text = "Rolling "..rolling20.. "d20\n"
	Comm.deliverChatMessage(msg);
	Conan.processRoll("conan", rolling20.."d20x" .. TN .."y"..FC);
	return true;
end

function combatdice()
	local msg = {font = "msgfont"};
	msg.text="ATTACK!";
	Comm.deliverChatMessage(msg);
	CD={}
	for x = 1,6 do
		CD[x]="d6"
	end
	Comm.throwDice( "dice", CD, 0, "rolling")
end

function attribcheck(winFrame,button)
	local rRoll="2d20";
	local rActor = ActorManager.getActor("pc", winFrame.getDatabaseNode());
	Debug.console("rActor: ");
	Debug.console(rActor);
					
	local nodeWin = winFrame.getDatabaseNode();
	Debug.console("nodeWin: ");
	Debug.console(nodeWin);
						
	local sHeroType = nodeWin.getChild(button.."score").getValue();
	Debug.console("sHeroType: ");
	Debug.console(sHeroType);
					
	local rolling20 = nodeWin.getChild("dicetoroll").getValue();
	Debug.console("rolling20: ");
	Debug.console(rolling20);
						
	local msg = {font = "crom-12"};
	msg.text = rActor.sName .. " makes a "..button.." check against a TN of " .. sHeroType;
	Comm.deliverChatMessage(msg);
	
	spendmomentum(winFrame);
	resetdice(winFrame);
	
	X=Conan.processRoll("conan", rolling20.. "d20x" .. sHeroType .."y0");
					
	return true;
end

function NPCattribcheck(winFrame,button)
	local rRoll="2d20";
	local rActor = ActorManager.getActor("pc", winFrame.getDatabaseNode());
	Debug.console("rActor: ");
	Debug.console(rActor);
					
	local nodeWin = winFrame.getDatabaseNode();
	Debug.console("nodeWin: ");
	Debug.console(nodeWin);
						
	local sHeroType = nodeWin.getChild(button.."score").getValue();
	Debug.console("sHeroType: ");
	Debug.console(sHeroType);
					
	local rolling20 = nodeWin.getChild("NPCdicetoroll").getValue();
	Debug.console("rolling20: ");
	Debug.console(rolling20);
						
	local msg = {font = "crom-12"};
	msg.text = rActor.sName .. " makes a "..button.." check against a TN of " .. sHeroType;
	Comm.deliverChatMessage(msg);
	
	Conan.processRoll("conan", rolling20.. "d20x" .. sHeroType .."y0");
					
	return true;
end



function skilldicebuy(window,purchasetype,dice)						
	local rActor = ActorManager.getActor("pc", window.getDatabaseNode());
	Debug.console("rActor: ");
	Debug.console(rActor);
	local nodeWin = window.getDatabaseNode();
	Debug.console("nodeWin: ");
	Debug.console(nodeWin);
	local currentDice = nodeWin.getChild("dicetoroll").getValue();
	Debug.console("currentdice: ");
	Debug.console(currentDice);
	local msg = {font = "crom-8"}
	local currentTypeValue = nodeWin.getChild("current"..purchasetype).getValue();
	Debug.console("purchased: ");
	Debug.console("purchased"..dice .."dice for 1 momentum");
	Debug.console(tonumber(currentTypeValue));

	
	local currentTypeValue = nodeWin.getChild("current"..purchasetype).getValue();
	Debug.console("increased to:");
	Debug.console(tonumber(currentTypeValue));
	
	local msg = {font = "copper10"}

	if (tonumber(nodeWin.getChild("dicetoroll").getValue())>4) then
		msg.text="Maximum Dice Purchase.\nReset by doubleclicking dice number or roll a skill check";
		Comm.deliverChatMessage(msg);
	else
		nodeWin.getChild("current"..purchasetype).setValue(tonumber(currentTypeValue)+1);
		nodeWin.getChild("dicetoroll").setValue(currentDice+tonumber(dice));
	end

end
--]]

--[[
function spendmomentum(winFrame)
		local nodeWin = winFrame.getDatabaseNode();
		local CD = nodeWin.getChild("currentdoom").getValue();
		local CM = nodeWin.getChild("currentmomentum").getValue();
		local Pmomentum=nodeWin.getChild("PlayerMomentum").getValue();
		local Momentumspend=CM;
		local PoolMomentumSpend=0;
		if (tonumber(CM)>0)then
			Pmomentum=Pmomentum-CM;
			if (tonumber(Pmomentum)<1) then
				Momentumspend=CM+Pmomentum;
				PoolMomentumSpend=Pmomentum*-1;
				Pmomentum=0;
			end
		end
		

		Debug.console("Personal Momentum");
		Debug.console(Pmomentum);
		
		local msg = {font = "copper10"};
		msg.text="Using "..CM.." momentum and "..CD.." doom";
		Comm.deliverChatMessage(msg);
		
		Debug.console(Momentumspend);
		
		if (tonumber(CM)>0) then
			msg.text="     "..Momentumspend.." player momentum was used.";
			msg.icon="smallmomentum";
			Comm.deliverChatMessage(msg);
		
			msg.text="     "..PoolMomentumSpend.." pool momentum was used.";
			msg.icon="smallpool";
			Comm.deliverChatMessage(msg);
		end
		
		if (tonumber(CD)>0) then
			msg.text="     "..CD.." Doom was used.";
			msg.icon="smalldoom";
			Comm.deliverChatMessage(msg);
		end
		
		
		nodeWin.getChild("PlayerMomentum").setValue(Pmomentum);
end
function createChatMessage(rSource, rRoll)	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Debug.console("rSource: ");
	Debug.console(rSource);
	Debug.console("rMessage: " .. rMessage.text);
	rMessage.text = rMessage.text .. "\nSuccesses = " .. rRoll.conan .. "\n";
	Debug.console("Mine as well.");
	return rMessage;
end
--]]

function onRoll(rSource, rTarget, rRoll)
	rRoll = DiceRoller.dropDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rRoll);
	rMessage.font="copper10";
	rMessage.type = "dice";
	Comm.deliverChatMessage(rMessage);
	Debug.console(rMessage);
end