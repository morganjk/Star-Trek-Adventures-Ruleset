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
  ActionsManager.registerResultHandler("dice", handleDiceLanded);
end

function handleDiceLanded(rSource, rTarget, rRoll)
    local add_total = true;
    local success = 0;
    local effects = 0;
    local total = 0;
    
    local dicetable = rRoll.aDice;
    if dicetable then
      for n = 1, table.maxn(dicetable) do
          if dicetable[n].type == "dCD" then
            if dicetable[n].result == 3 then
              dicetable[n].result = 0;              
            elseif dicetable[n].result == 4 then
              dicetable[n].result = 0;              
            elseif dicetable[n].result == 5 then
              effects = effects + 1;
              dicetable[n].result = 1;              
            elseif dicetable[n].result == 6 then
              effects = effects + 1;              
              dicetable[n].result = 1;              
            end
          end
      end
    end
    
    local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
    rMessage.type = rRoll.sType;
    if success > 0 then rMessage.text = rMessage.text .. "[Successes: " .. success .. "]"; end
    if effects > 0 then rMessage.text = rMessage.text .. "[Effects: " .. effects .. "]"; end
    rMessage.text = rMessage.text .. rRoll.sDesc;
    rMessage.dice = rRoll.aDice;
    rMessage.diemodifier = rRoll.nMod;
    
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
    if OptionsManager.isOption("TOTL", "on") and rRoll.aDice and #(rRoll.aDice) > 0 then
      rMessage.dicedisplay = 1;
    end
  
    Comm.deliverChatMessage(rMessage);
    ModifierStack.reset();
    return true;
end