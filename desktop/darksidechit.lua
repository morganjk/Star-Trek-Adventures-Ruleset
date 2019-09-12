-- MOD: Trenloe November 2013.  Added onLogin handler.

local dragging = false;
local removingchit = "false";  --Flag used to stop removelightsidechit from occurring twice.

SPECIAL_MSGTYPE_REFRESHDESTINYCHITS = {};
SPECIAL_MSGTYPE_REFRESHDESTINYCHITS.type = "refreshdarksidechits";

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
  OOBManager.registerOOBMsgHandler("refreshdarksidechits", handleRefreshDarksideChits);
  
  if User.isHost() then
    if chit then			
      --Set the destiny chits to the current value in the database
      refreshDestinyChits();
    end
  end	
end

function refreshDestinyChits()
--	Debug.console("chit.lua: refreshDestinyChits()"); 
	local msg = SPECIAL_MSGTYPE_REFRESHDESTINYCHITS;
	local identity = User.getCurrentIdentity();
	msg.msgidentity = User.getIdentityLabel() or "GM";
	msg.msguser = User.getIdentityOwner(identity) or "GM";
--	Debug.console("OOB MESSAGE => Type: " .. msg.type .. "; Identity: " .. msg.msgidentity .. "; User: " .. msg.msguser); 
	Comm.deliverOOBMessage(msg);
end

function handleRefreshDarksideChits(servermsg)
--	Debug.console("chit.lua: handleRefreshDarksideChits()"); 
  local lightsidenode = nil;
	local darksidenode = nil;
	
--	Debug.console("chit.lua: handleRefreshDarksideChits()  window.getClass() = " .. window.getClass());

  -- ensure that we have the light side chit node, create it if it does not exist (e.g. for a new campaign)
  if User.isHost() then
    if not darksidenode then
      darksidenode = DB.createNode("darksidechit.chits","number");
      darksidenode.setPublic(true);
 --     Debug.console("chit.lua: handleRefreshDarksideChits()  Create Node: " .. window.getClass());
    end
  end
  
  -- If we don't have the lightsidechit node at this point, find it.
  if not darksidenode then
    darksidenode = DB.findNode("darksidechit.chits");
--    Debug.console("chit.lua: handleRefreshDarksideChits()  Find Node: " .. window.getClass());
  end	
  
  -- refresh chits here
  if darksidenode then		
--    Debug.console("chit.lua: handleRefreshDarksideChits() darksidenode.getValue = " .. darksidenode.getValue());
    if darksidenode.getValue()<=0 then
      setIcon("darksidechit0");
    elseif darksidenode.getValue()<8 then
      setIcon("darksidechit" .. darksidenode.getValue());
    else
      setIcon("darksidechit8more");
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
end

function onDragStart(button, x, y, draginfo)
  --Allow only GM to drag darkside
  if User.isHost() then
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
		
    darksidenode = DB.createNode("darksidechit.chits", "number");
    if darksidenode then
      -- Only remove a chit if there are actually any there to remove
      if darksidenode.getValue() > 0 then
        -- decrease the darkside count
        darksidenode.setValue(darksidenode.getValue() - 1);
        --msg.text = "Threat has been decremented to " ..  darksidenode.getValue();
        msg.text = "A Threat chit has been used by the GM";
        Comm.deliverChatMessage(msg);
        refreshDestinyChits();
      end
    end
	end
end

function onDoubleClick(x, y)
	--Only process if the user is the GM
	if chit and User.isHost() then		
		local msg = {};
		msg.font = "msgfont";										
		
    -- create  new darkside force node, or find it if it already exists
    darksidenode = DB.createNode("darksidechit.chits", "number");
    if darksidenode then
      -- increase the darkside count
      darksidenode.setValue(darksidenode.getValue() + 1);
      --msg.text = "Darkside destiny has been increased to " ..  darksidenode.getValue();			
      --ChatManager.deliverMessage(msg);				
    end	
    -- Initiate special message functionality to refresh chits on clients.				
    refreshDestinyChits();

		return true;
	end
end