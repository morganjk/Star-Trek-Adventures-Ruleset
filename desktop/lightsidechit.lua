-- MOD: Trenloe November 2013.  Added onLogin handler.

local dragging = false;
local removingchit = "false";  --Flag used to stop removelightsidechit from occurring twice.

SPECIAL_MSGTYPE_REFRESHDESTINYCHITS = {};
SPECIAL_MSGTYPE_REFRESHDESTINYCHITS.type = "refreshlightsidechits";
SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT = {};
SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT.type = "removelightsidechit"; 
SPECIAL_MSGTYPE_ADDLIGHTSIDECHIT = {};
SPECIAL_MSGTYPE_ADDLIGHTSIDECHIT.type = "addlightsidechit"; 

function onInit()
	setHoverCursor("hand");
	
	if chit then
		setIcon(chit[1] .. "chit");
	end
	
		if User.isHost() then	
			-- subscribe to the login events so that client side chits can be updated when the player logs in.
			User.onLogin = onLogin;	
			-- set up the right-click chit menus - GM only
			registerMenuItem("Clear Pile", "deletealltokens", 1);
			registerMenuItem("Update Player Chits", "broadcast", 7);		
		end
		
		-- register special messages
		OOBManager.registerOOBMsgHandler("refreshlightsidechits", handleRefreshLightsideChits);
		OOBManager.registerOOBMsgHandler("removelightsidechit", handleRemoveLightsideChits);
		OOBManager.registerOOBMsgHandler("addlightsidechit", handleAddLightsideChits);
		
		if User.isHost() then
			if chit then			
				--Set the destiny chits to the current value in the database
				refreshDestinyChits();
			end
		end	
end

function refreshDestinyChits()
	--ChatManager.sendSpecialMessage(SPECIAL_MSGTYPE_REFRESHDESTINYCHITS, {});
--	Debug.console("chit.lua: refreshDestinyChits()"); 
	local msg = SPECIAL_MSGTYPE_REFRESHDESTINYCHITS;
	local identity = User.getCurrentIdentity();
	msg.msgidentity = User.getIdentityLabel() or "GM";
	msg.msguser = User.getIdentityOwner(identity) or "GM";
--	Debug.console("OOB MESSAGE => Type: " .. msg.type .. "; Identity: " .. msg.msgidentity .. "; User: " .. msg.msguser); 
	Comm.deliverOOBMessage(msg);
end

function handleRefreshLightsideChits(servermsg)
--	Debug.console("chit.lua: handleRefreshLightsideChits()"); 
  local lightsidenode = nil;
	
--	Debug.console("chit.lua: handleRefreshLightsideChits()  window.getClass() = " .. window.getClass());

  -- ensure that we have the light side chit node - create it if it does not exist (e.g. for a new campaign)
  if User.isHost() then
    -- If we are the GM this may be a new campaign, need to create the node if not already there.
    if not lightsidenode then
      lightsidenode = DB.createNode("lightsidechit.chits","number");
      lightsidenode.setPublic(true);
--      Debug.console("chit.lua: handleRefreshLightsideChits()  Create Node: " .. window.getClass());
    end		
  end
  
  -- If we don't have the lightsidechit node at this point, find it.
  if not lightsidenode then
    lightsidenode = DB.findNode("lightsidechit.chits");
--    Debug.console("chit.lua: handleRefreshLightsideChits()  Find Node: " .. window.getClass());
  end
    
  if lightsidenode then		
--    Debug.console("chit.lua: handleRefreshLightsideChits() lightsidenode.getValue = " .. lightsidenode.getValue());
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

function removeLightsideChits()
	--local msgparams = {};
	--msgparams[1] = "true";		--Used as the removingchit flag to ensure that the OOB process only fires once on the GM side.	
	--ChatManager.sendSpecialMessage(SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT, msgparams);
--	Debug.console("chit.lua: removeLightsideChits()");
	local msg = SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT;
	local identity = User.getCurrentIdentity();
	msg.msgidentity = User.getIdentityLabel() or "GM";
	msg.msguser = User.getIdentityOwner(identity) or "GM";
--	Debug.console("OOB MESSAGE => Type: " .. msg.type .. "; Identity: " .. msg.msgidentity .. "; User: " .. msg.msguser); 
	Comm.deliverOOBMessage(msg);
end

function handleRemoveLightsideChits(servermsg)
	-- Can onlt adjust the database as the host
--	Debug.console("chit.lua: handleRemoveLightsideChits()");
	--removingchit = true; --msgparams[1];
	if User.isHost() then --and removingchit == "true" then
		local msg = {};
		msg.font = "msgfont";	
		
		-- create  new lightside force node, or find it if it already exists
		lightsidenode = DB.createNode("lightsidechit.chits", "number");
		if lightsidenode then
			-- Only remove a chit if there are actually any there to remove
			if lightsidenode.getValue() > 0 then
				-- decrease the lightside count
				lightsidenode.setValue(lightsidenode.getValue() - 1);
--				Debug.console("Momentum use.");
				if servermsg.msgidentity == "" then
					msg.text = "A Momentum chit has been used by  " .. servermsg.msguser;
				elseif servermsg.msgidentity == "GM" then
					msg.text = "A Momentum chit has been played by the GM on behalf of the players.";
				else
					msg.text = "A Momentum chit has been used by " .. servermsg.msgidentity .. " (" .. servermsg.msguser .. ")";
				end

--				Debug.console("Momentum has been decremented to " ..  lightsidenode.getValue());
				--ChatManager.deliverMessage(msg);
				Comm.deliverChatMessage(msg);
				
				-- Reset flag to stop further processing of this function until another drag event occurs.
				removingchit = "false";
				--msgparams[1] = "false";  --Needed to reset removing chit properly when this function fires again.
				-- Refresh the chits.
				refreshDestinyChits();	
			end
		end
	end
end

function addLightsideChits()
	--local msgparams = {};
	--msgparams[1] = "true";		--Used as the removingchit flag to ensure that the OOB process only fires once on the GM side.	
	--ChatManager.sendSpecialMessage(SPECIAL_MSGTYPE_REMOVELIGHTSIDECHIT, msgparams);
--	Debug.console("chit.lua: addLightsideChits()");
	local msg = SPECIAL_MSGTYPE_ADDLIGHTSIDECHIT;
	local identity = User.getCurrentIdentity();
	msg.msgidentity = User.getIdentityLabel() or "GM";
	msg.msguser = User.getIdentityOwner(identity) or "GM";
--	Debug.console("OOB MESSAGE => Type: " .. msg.type .. "; Identity: " .. msg.msgidentity .. "; User: " .. msg.msguser); 
	Comm.deliverOOBMessage(msg);
end

function handleAddLightsideChits(servermsg)
	-- Can onlt adjust the database as the host
--	Debug.console("chit.lua: handleAddLightsideChits()");
	--removingchit = true; --msgparams[1];
	if User.isHost() then --and removingchit == "true" then
		local msg = {};
		msg.font = "msgfont";	
		
		-- create  new lightside force node, or find it if it already exists
		lightsidenode = DB.createNode("lightsidechit.chits", "number");
		if lightsidenode then
			-- Only add a chit if the total is under the maximum of six
			if lightsidenode.getValue() < 6 then
				-- increase the lightside count
				lightsidenode.setValue(lightsidenode.getValue() + 1);
--				Debug.console("Momentum increase.");
				if servermsg.msgidentity == "" then
					msg.text = servermsg.msguser .. "adds a Momentum chit.";
				elseif servermsg.msgidentity == "GM" then
					msg.text = "GM adds a Momentum chit on behalf of the players.";
				else
					msg.text = servermsg.msguser .. " adds a Momentum chit for " .. servermsg.msgidentity;
				end

--				Debug.console("Momentum has been increased to " ..  lightsidenode.getValue());
				--ChatManager.deliverMessage(msg);
				Comm.deliverChatMessage(msg);
				
				-- Reset flag to stop further processing of this function until another drag event occurs.
				removingchit = "false";
				--msgparams[1] = "false";  --Needed to reset removing chit properly when this function fires again.
				-- Refresh the chits.
				refreshDestinyChits();	
			end
		end
	end
end

function onLogin(username, activated)
	if User.isHost() and activated then
		--Refresh the client side chit icons
		refreshDestinyChits();
	end
end

function onMenuSelection(selection)
	if chit then
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
      
    elseif selection == 7 then
      -- Synchronise the chit piles with the connected players - added for the rare occasion where the client does not synch properly on login
      refreshDestinyChits();
    end			
	end
end

function onDragStart(button, x, y, draginfo)
	-- Allow all users to drag lightside destiny chits
	dragging = false;
	return onDrag(button, x, y, draginfo);
end

function onDrag(button, x, y, draginfo)
	if chit and not dragging then
		draginfo.setType("chit");
		draginfo.setDescription(chit[1]:gsub("^%l", string.upper));
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
		removeLightsideChits();
	end
end

function onDoubleClick(x, y)
	--Only process if the user is the GM
	-- if chit and User.isHost() then		
		-- local msg = {};
		-- msg.font = "msgfont";										
		-- 
    -- -- create  new lightside force node, or find it if it already exists
    -- lightsidenode = DB.findNode("lightsidechit.chits", "number");
    -- if not lightsidenode then
      -- lightsidenode = DB.createNode("lightsidechit.chits", "number");
    -- end
    -- if lightsidenode then
      -- -- increase the lightside count
      -- lightsidenode.setValue(lightsidenode.getValue() + 1);
      -- msg.text = "Momentum has been increased to " ..  lightsidenode.getValue();
      -- --ChatManager.deliverMessage(msg);
      -- Comm.deliverChatMessage(msg);
    -- end	
    -- -- Initiate special message functionality to refresh chits on clients.
    -- refreshDestinyChits();
		-- return true;
	-- end
	addLightsideChits();
end