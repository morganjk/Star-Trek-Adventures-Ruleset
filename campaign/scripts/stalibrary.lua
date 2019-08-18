function onInit()
  -- Grabbing the action handler to process my onRoll command to give me control over the results of Damned's Conan roller.
  -- Keith Johnson
	GameSystem.actions["sta"] = { bUseModStack = true, sTargeting = "all" };
	ActionsManager.registerResultHandler("sta", onRoll);
end

function processRoll(sCommand, sParams)
	if not sParams or sParams == "" then 
		createHelpMessage();
		return;
	end

	if sParams == "?" or string.lower(sParams) == "help" then
		createHelpMessage();		
	else
		local rRoll = createRoll(sParams);
		ActionsManager.roll(nil, nil, rRoll);
	end		
end


function taskcheck(winFrame, label)
	local type = "dice";
	local rRoll = { sType = "dice", sDesc = label, aDice = dice.getDice(), nMod = bonus.getValue() };
	Debug.chat("label:")
	Debug.chat(label)
	Debug.chat("rRoll:")
	Debug.chat(rRoll)
	local rActor = ActorManager.getActor("pc", winFrame.getDatabaseNode());
	Debug.chat("rActor: ");
	Debug.chat(rActor);
					
	local nodeWin = winFrame.getDatabaseNode();
	Debug.chat("nodeWin: ");
	Debug.chat(nodeWin);

	local TN = nodeWin.getChild("rollable.targetroll").getValue();
	Debug.chat("TN: ");
	Debug.chat(TN);
					
	local FC = nodeWin.getChild("rollable.focusused").getValue();
	Debug.chat("FC: ");
	Debug.chat(FC);
					
	local rolling20 = nodeWin.getChild("rollable.dicetoroll").getValue();
	Debug.chat("rolling20: ");
	Debug.chat(rolling20);
	
	local comp = nodeWin.getChild("rollable.comprange").getValue();
	Debug.chat("comp");
	Debug.chat(comp);
	
	local msg = {font = "sheetlabel"};
	msg.text = rActor.sName .. " rolls a task"
	Comm.deliverChatMessage(msg);
	
	local msg = {font = "sheetlabel"};
	msg.text= "TN.." .. TN.." / FC.."..FC.."\nRolling "..rolling20.. "d20\n"
	Comm.deliverChatMessage(msg);
	
	for i = 1, rolling20, 1 do	
		table.insert(rRoll, "d20");
	end
	Debug.chat("rRoll");
	Debug.chat(rRoll);


	resetdice(winFrame);
	SkillDieHandler.handleDiceLanded(rSource, TN, rRoll);
		return true;
end

function repcheck(winFrame)
	local rRoll="dCD";
	Debug.console(dCD);
	
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

function addSlot(description, number)
	if #slots < 6 then
		table.insert(slots, { ['description'] = description, ['number'] = number });
	end
	
	updateControl();
end

function updateControl()
	if control then
		if adjustmentedit then
			control.label.setValue(Interface.getString("modstack_label_adjusting"));
		else
			control.label.setValue(Interface.getString("modstack_label_modifier"));
			
			if freeadjustment > 0 then
				control.label.setValue("(+" .. freeadjustment .. ")");
			elseif freeadjustment < 0 then
				control.label.setValue("(" .. freeadjustment .. ")");
			end
			
			control.modifier.setValue(getSum());
			
			control.base.resetCounters();
			for i = 1, #slots do
				control.base.addCounter();
			end
			
			if hoverslot and hoverslot ~= 0 and slots[hoverslot] then
				control.label.setValue(slots[hoverslot].description);
			end
		end
		
		if math.abs(control.modifier.getValue()) > 999 then
			control.modifier.setFont("modcollectorlabel");
		else
			control.modifier.setFont("modcollector");
		end
	end
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

function resetdice(winFrame)
	local nodeWin = winFrame.getDatabaseNode();
	nodeWin.getChild("rollable.dicetoroll").setValue(2);
	nodeWin.getChild("rollable.comprange").setValue(1);
	nodeWin.getChild("rollable.focusused").setValue(0);
end

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


function onRoll(rSource, rTarget, rRoll)
	rRoll = Conan.dropDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rRoll);
	rMessage.font="copper10";
	rMessage.type = "dice";
	Comm.deliverChatMessage(rMessage);
	Debug.console(rMessage);
end
--]]