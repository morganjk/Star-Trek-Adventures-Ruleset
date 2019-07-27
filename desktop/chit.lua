-- MOD: Trenloe November 2013.  Added onLogin handler.

local dragging = false;

local removingchit = "false";  --Flag used to stop removelightsidechit from occurring twice.

local lightsidechitwindow = nil;
local darksidechitwindow = nil;

SPECIAL_MSGTYPE_REFRESHDESTINYCHITS = {};
SPECIAL_MSGTYPE_REFRESHDESTINYCHITS.type = "refreshdestinychits";
SPECIAL_MSGTYPE_REFRESHLIGHTSIDECHITS = {};
SPECIAL_MSGTYPE_REFRESHLIGHTSIDECHITS.type = "refreshlightsidechits";
SPECIAL_MSGTYPE_REFRESHDARKSIDECHITS = {};
SPECIAL_MSGTYPE_REFRESHDARKSIDECHITS.type = "refreshdarksidechits";
SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT = {};
SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT.type = "removelightsidechit"; 

function onInit()
	setHoverCursor("hand");
	
	if chit then
		setIcon(chit[1] .. "chit");
	end
	
	if window.getClass() == "lightsidechit" or window.getClass() == "darksidechit" then
		if User.isHost() then	
			-- subscribe to the login events so that client side chits can be updated when the player logs in.
			User.onLogin = onLogin;	
			-- set up the right-click chit menus - GM only
			registerMenuItem("Clear Pile", "deletealltokens", 1);
			registerMenuItem("Update Player Chits", "broadcast", 7);		
		end
		
		-- Register lightsidechit window instance for use later in GM forced update.
		if window.getClass() == "lightsidechit" then	
  		OOBManager.registerOOBMsgHandler("refreshlightsidechits", handleRefreshLightsideChits);
  		OOBManager.registerOOBMsgHandler("removelightsidechit", handleRemoveLightsideChits);
			lightsidechitwindow = window;
		end
		
		-- Register darksidechit window instance for use later in GM forced update.
		if window.getClass() == "darksidechit" then	
		  OOBManager.registerOOBMsgHandler("refreshdarksidechits", handleRefreshDarksideChits);
			darksidechitwindow = window;
		end	
		
		-- register special messages
		--ChatManager.registerSpecialMessageHandler(SPECIAL_MSGTYPE_REFRESHDESTINYCHITS, handleRefreshdestinyChits);	
		--ChatManager.registerSpecialMessageHandler(SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT, handleRemoveLightsideChits);
		--OOBManager.registerOOBMsgHandler("refreshdestinychits", handleRefreshDestinyChits);
		--OOBManager.registerOOBMsgHandler("removelightsidechit", handleRemoveLightsideChits);
		
		if User.isHost() then
			if chit then			
				--Set the destiny chits to the current value in the database
				refreshDestinyChits();
			end
		end	
	end
	
	if window.getClass() == "woundchit" then
		registerMenuItem("Reset to 1", "erase", 1);
		registerMenuItem("Assign 2 chits", "num2", 2);
	end
end

function refreshDestinyChits()
	--ChatManager.sendSpecialMessage(SPECIAL_MSGTYPE_REFRESHDESTINYCHITS, {});
	Debug.console("chit.lua: refreshDestinyChits()"); 
	local msg = SPECIAL_MSGTYPE_REFRESHDESTINYCHITS;
	if window.getClass() == "lightsidechit" then
  	msg = SPECIAL_MSGTYPE_REFRESHLIGHTSIDECHITS;
  end
	if window.getClass() == "darksidechit" then
  	msg = SPECIAL_MSGTYPE_REFRESHDARKSIDECHITS;
  end
	local identity = User.getCurrentIdentity();
	msg.msgidentity = User.getIdentityLabel() or "GM";
	msg.msguser = User.getIdentityOwner(identity) or "GM";
	Debug.console("OOB MESSAGE => Type: " .. msg.type .. "; Identity: " .. msg.msgidentity .. "; User: " .. msg.msguser); 
	Comm.deliverOOBMessage(msg);
end

function handleRefreshDestinyChits(servermsg)
	Debug.console("chit.lua: handleRefreshDestinyChits()"); 
  local lightsidenode = nil;
	local darksidenode = nil;
	
	Debug.console("chit.lua: handleRefreshDestinyChits()  window.getClass() = " .. window.getClass());

	if window.getClass() == "lightsidechit" then
		-- ensure that we have the light side chit node - create it if it does not exist (e.g. for a new campaign)
		if User.isHost() then
			-- If we are the GM this may be a new campaign, need to create the node if not already there.
			if not lightsidenode then
				lightsidenode = DB.createNode("lightsidechit.chits","number");
			end		
		end
		
		-- If we don't have the lightsidechit node at this point, find it.
		if not lightsidenode then
			lightsidenode = DB.findNode("lightsidechit.chits");
		end
			
		if lightsidenode then		
  		Debug.console("chit.lua: handleRefreshDestinyChits() lightsidenode.getValue = " .. lightsidenode.getValue());
			-- refresh chits here
			if lightsidenode.getValue()<=0 then
				setIcon("lightsidechit0");
			elseif lightsidenode.getValue()<8 then
				setIcon("lightsidechit" .. lightsidenode.getValue());
			else
				setIcon("lightsidechit8more");
			end
		end		
	end
	
	if window.getClass() == "darksidechit" then
		-- ensure that we have the light side chit node, create it if it does not exist (e.g. for a new campaign)
		if not darksidenode then
			darksidenode = DB.createNode("darksidechit.chits","number");
		end

		-- If we don't have the lightsidechit node at this point, find it.
		if not darksidenode then
			darksidenode = DB.findNode("darksidechit.chits");
		end	
		
		-- refresh chits here
		if darksidenode then		
  		Debug.console("chit.lua: handleRefreshDestinyChits() darksidenode.getValue = " .. darksidenode.getValue());
			if darksidenode.getValue()<=0 then
				setIcon("darksidechit0");
			elseif darksidenode.getValue()<8 then
				setIcon("darksidechit" .. darksidenode.getValue());
			else
				setIcon("darksidechit8more");
			end
		end
	end	
end

function handleRefreshLightsideChits(servermsg)
	Debug.console("chit.lua: handleRefreshLightsideChits()"); 
  local lightsidenode = nil;
	local darksidenode = nil;
	
	Debug.console("chit.lua: handleRefreshLightsideChits()  window.getClass() = " .. window.getClass());

	if window.getClass() == "lightsidechit" then
		-- ensure that we have the light side chit node - create it if it does not exist (e.g. for a new campaign)
		if User.isHost() then
			-- If we are the GM this may be a new campaign, need to create the node if not already there.
			if not lightsidenode then
				lightsidenode = DB.createNode("lightsidechit.chits","number");
			end		
		end
		
		-- If we don't have the lightsidechit node at this point, find it.
		if not lightsidenode then
			lightsidenode = DB.findNode("lightsidechit.chits");
		end
			
		if lightsidenode then		
  		Debug.console("chit.lua: handleRefreshLightsideChits() lightsidenode.getValue = " .. lightsidenode.getValue());
			-- refresh chits here
			if lightsidenode.getValue()<=0 then
				setIcon("lightsidechit0");
			elseif lightsidenode.getValue()<8 then
				setIcon("lightsidechit" .. lightsidenode.getValue());
			else
				setIcon("lightsidechit8more");
			end
		end		
	end
end

function refreshDestinyChits()
	--ChatManager.sendSpecialMessage(SPECIAL_MSGTYPE_REFRESHDESTINYCHITS, {});
	Debug.console("chit.lua: refreshDestinyChits()"); 
	local msg = SPECIAL_MSGTYPE_REFRESHDESTINYCHITS;
	local identity = User.getCurrentIdentity();
	msg.msgidentity = User.getIdentityLabel() or "GM";
	msg.msguser = User.getIdentityOwner(identity) or "GM";
	Debug.console("OOB MESSAGE => Type: " .. msg.type .. "; Identity: " .. msg.msgidentity .. "; User: " .. msg.msguser); 
	Comm.deliverOOBMessage(msg);
end

function handleRefreshDarksideChits(servermsg)
	Debug.console("chit.lua: handleRefreshDarksideChits()"); 
  local lightsidenode = nil;
	local darksidenode = nil;
	
	Debug.console("chit.lua: handleRefreshDarksideChits()  window.getClass() = " .. window.getClass());

	if window.getClass() == "darksidechit" then
		-- ensure that we have the light side chit node, create it if it does not exist (e.g. for a new campaign)
		if not darksidenode then
			darksidenode = DB.createNode("darksidechit.chits","number");
		end

		-- If we don't have the lightsidechit node at this point, find it.
		if not darksidenode then
			darksidenode = DB.findNode("darksidechit.chits");
		end	
		
		-- refresh chits here
		if darksidenode then		
  		Debug.console("chit.lua: handleRefreshDarksideChits() darksidenode.getValue = " .. darksidenode.getValue());
			if darksidenode.getValue()<=0 then
				setIcon("darksidechit0");
			elseif darksidenode.getValue()<8 then
				setIcon("darksidechit" .. darksidenode.getValue());
			else
				setIcon("darksidechit8more");
			end
		end
	end	
end

function removeLightsideChits()
	--local msgparams = {};
	--msgparams[1] = "true";		--Used as the removingchit flag to ensure that the OOB process only fires once on the GM side.	
	--ChatManager.sendSpecialMessage(SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT, msgparams);
	Debug.console("chit.lua: removeLightsideChits()");
	local msg = SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT;
	local identity = User.getCurrentIdentity();
	msg.msgidentity = User.getIdentityLabel() or "GM";
	msg.msguser = User.getIdentityOwner(identity) or "GM";
	Debug.console("OOB MESSAGE => Type: " .. msg.type .. "; Identity: " .. msg.msgidentity .. "; User: " .. msg.msguser); 
	Comm.deliverOOBMessage(msg);
end

function handleRemoveLightsideChits(servermsg)
	-- Can onlt adjust the database as the host
	Debug.console("chit.lua: handleRemoveLightsideChits()");
	--removingchit = true; --msgparams[1];
	--if User.isHost() and removingchit == "true" then
		local msg = {};
		msg.font = "msgfont";	
		
		-- create  new lightside force node, or find it if it already exists
		lightsidenode = DB.createNode("lightsidechit.chits", "number");
		if lightsidenode then
			-- Only remove a chit if there are actually any there to remove
			if lightsidenode.getValue() > 0 then
				-- decrease the lightside count
				lightsidenode.setValue(lightsidenode.getValue() - 1);
				Debug.console("Momentum use.");
				if servermsg.msgidentity == "" then
					msg.text = "A Momentum chit has been used by  " .. servermsg.msguser;
				elseif servermsg.msgidentity == "GM" then
					msg.text = "A Momentum chit has been played by the GM on behalf of the players.";
				else
					msg.text = "A Momentum chit has been used by  " .. servermsg.msguser .. ", for character " .. servermsg.msgidentity;
				end

				Debug.console("Momentum has been decremented to " ..  lightsidenode.getValue());
				--ChatManager.deliverMessage(msg);
				Comm.deliverChatMessage(msg);
				
				-- create new darkside force node, or find it if it already exists
				--darksidenode = DB.createNode("darksidechit.chits", "number");
				--if darksidenode then
					-- increase the darkside count
					--darksidenode.setValue(darksidenode.getValue() + 1);
					--msg.text = "Darkside destiny has been incremented to " ..  darksidenode.getValue();
					--ChatManager.deliverMessage(msg);	
				--end
				-- Reset flag to stop further processing of this function until another drag event occurs.
				removingchit = "false";
				--msgparams[1] = "false";  --Needed to reset removing chit properly when this function fires again.
				-- Refresh the chits.
				refreshDestinyChits();	
			end
		end
	--end
end

function onLogin(username, activated)
	if User.isHost() and activated then
		--Add the player as a holder to the destiny chits nodes - this is needed to avoid an error accessing the nodes when a user connects to a campaign DB for the first time.
		--local lightsidenode = DB.findNode("lightsidechit");		
		--if not lightsidenode then
		--	lightsidenode.addHolder(username);
		--end

		--local darksidenode = DB.findNode("darksidechit");
		--if not darksidenode then
			--darksidenode.addHolder(username);	
		--end
		
		--Refresh the client side chit icons
		refreshDestinyChits();
	end
end

function onMenuSelection(selection)
	if chit then
		if window.getClass() == "lightsidechit" or window.getClass() == "darksidechit" then
			if selection == 1 then
				-- Reset both chit piles to 0
				local msg = {};
				msg.font = "msgfont";	
					
				if window.getClass() == "lightsidechit" then									
					-- create new lightside force node, or find it if it already exists
					lightsidenode = DB.createNode("lightsidechit.chits", "number");
					if lightsidenode then
						-- remove all the lightside 
						lightsidenode.setValue(0);
						msg.text = "Momentum has been decremented to " ..  lightsidenode.getValue();
						--ChatManager.deliverMessage(msg);
						Comm.deliverChatMessage(msg);
						refreshDestinyChits();								
					end
				end
				
				if window.getClass() == "darksidechit" then
					darksidenode = DB.createNode("darksidechit.chits", "number");
					if darksidenode then
						-- remove all the darkside 
						darksidenode.setValue(0);
						msg.text = "Threat has been decremented to " ..  darksidenode.getValue();
						--ChatManager.deliverMessage(msg);
						Comm.deliverChatMessage(msg);
						refreshDestinyChits();				
					end
				end		
			elseif selection == 7 then
				-- Synchronise the chit piles with the connected players - added for the rare occasion where the client does not synch properly on login
				refreshDestinyChits();
			end			
		end
		
		if window.getClass() == "woundchit" then
			if selection == 1 then
			
			elseif selection == 2 then
			
			end
		end
	end
end

function onDragStart(button, x, y, draginfo)
	if window.getClass() == "lightsidechit" or window.getClass() == "darksidechit" then
		-- Allow all users to drag lightside destiny chits
		if window.getClass() == "lightsidechit" then	
			dragging = false;
			return onDrag(button, x, y, draginfo);
			
		--Allow GM to drag both lightside and darkside
		elseif User.isHost() then
			dragging = false;
			return onDrag(button, x, y, draginfo);		
		end
	else
		dragging = false;
		return onDrag(button, x, y, draginfo);
	end
end

function onDrag(button, x, y, draginfo)
	if chit and not dragging then
		draginfo.setType("chit");
		draginfo.setDescription(chit[1]);
		draginfo.setIcon(chit[1] .. "chit");
		draginfo.setCustomData(chit[1]);
		dragging = true;
		return true;
	end
end

function onDragEnd(draginfo)
	dragging = false;
	if chit then		
		local msg = {};
		msg.font = "msgfont";										
		
		if window.getClass() == "lightsidechit" then
			removeLightsideChits();
		end
		
		if window.getClass() == "darksidechit" then
			darksidenode = DB.createNode("darksidechit.chits", "number");
			if darksidenode then
				-- Only remove a chit if there are actually any there to remove
				if darksidenode.getValue() > 0 then
					-- decrease the darkside count
					darksidenode.setValue(darksidenode.getValue() - 1);
					--msg.text = "Threat has been decremented to " ..  darksidenode.getValue();
					msg.text = "A Threat chit has been used by the GM";
					--ChatManager.deliverMessage(msg);
					Comm.deliverChatMessage(msg);
					-- create  new lightside force node, or find it if it already exists
					--lightsidenode = DB.createNode("lightsidechit.chits", "number");
					--if lightsidenode then
						-- increase the lightside count
						--lightsidenode.setValue(lightsidenode.getValue() + 1);
						--msg.text = "Lightside destiny has been incremented to " ..  lightsidenode.getValue();
						--ChatManager.deliverMessage(msg);
					--end
					refreshDestinyChits();
				end
			end
		end
	end
end

function onDoubleClick(x, y)
	--Only process if the user is the GM
	if chit and User.isHost() then		
		local msg = {};
		msg.font = "msgfont";										
		
		if window.getClass() == "lightsidechit" then
			-- create  new lightside force node, or find it if it already exists
			lightsidenode = DB.findNode("lightsidechit.chits", "number");
			if not lightsidenode then
				lightsidenode = DB.createNode("lightsidechit.chits", "number");
			end
			if lightsidenode then
				-- increase the lightside count
				lightsidenode.setValue(lightsidenode.getValue() + 1);
				--msg.text = "Lightside destiny has been increased to " ..  lightsidenode.getValue();
				--ChatManager.deliverMessage(msg);				
			end	
			-- Initiate special message functionality to refresh chits on clients.
			refreshDestinyChits();
		end	
		
		if window.getClass() == "darksidechit" then
			-- create  new darkside force node, or find it if it already exists
			lightsidenode = DB.createNode("lightsidechit.chits", "number");
			darksidenode = DB.createNode("darksidechit.chits", "number");
			if darksidenode then
				-- increase the darkside count
				darksidenode.setValue(darksidenode.getValue() + 1);
				--msg.text = "Darkside destiny has been increased to " ..  darksidenode.getValue();			
				--ChatManager.deliverMessage(msg);				
			end	
			-- Initiate special message functionality to refresh chits on clients.				
			refreshDestinyChits();
		end		
		
		return true;
	end
end