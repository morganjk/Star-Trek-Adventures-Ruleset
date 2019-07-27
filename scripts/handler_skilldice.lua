-- This file is part of the Fantasy Grounds Open Foundation Ruleset project. 
-- For the latest information, see http://www.fantasygrounds.com/
--
-- Copyright 2008 SmiteWorks Ltd.
--
-- This file is provided under the Open Game License version 1.0a
-- Refer to the license.html file for the full license text
--
-- All producers of work derived from this material are advised to
-- familiarize themselves with the license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.
--
-- All material submitted to the Open Foundation Ruleset project must
-- contain this notice in a manner applicable to the source file type.

function onInit()
  ActionsManager.registerResultHandler("skilldice", handleDiceLanded);
end

function handleDiceLanded(rSource, rTarget, rRoll)
    local add_total = true;
    local success = 0;
    local total = 0;
    
    -- Get Target Info from Modifier Stack
    local target = rRoll.nMod;
    local diffMessage = "[TN=" .. target .. "]";
    
    local dicetable = rRoll.aDice;
    if dicetable then
      for n = 1, table.maxn(dicetable) do
          if dicetable[n].type == "d20" then
            if dicetable[n].result == 1 then
              success = success + 2;
            elseif dicetable[n].result <= target then
              success = success + 1;
            end
          end
      end
    end
    
    local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
    rMessage.type = rRoll.sType;
    rMessage.text = rMessage.text .. diffMessage;
    if success > 0 then rMessage.text = rMessage.text .. "[Base Success: " .. success .. "]"; end
    rMessage.text = rMessage.text .. " " .. rRoll.sDesc;
    rMessage.dice = rRoll.aDice;
    rMessage.diemodifier = 0;
    
    -- Check to see if this roll should be secret (GM or dice tower tag)
    if rRoll.bSecret then
      rMessage.secret = true;
      if rRoll.bTower then
        rMessage.icon = "dicetower_icon";
      end
    elseif User.isHost() and OptionsManager.isOption("REVL", "off") then
      rMessage.secret = true;
    end
    
    -- Show total if option enabled
    --if OptionsManager.isOption("TOTL", "on") and rRoll.aDice and #(rRoll.aDice) > 0 then
    --  rMessage.dicedisplay = 1;
    --end
  
    Comm.deliverChatMessage(rMessage);
    ModifierStack.reset();
    return true;
end