-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	update();
end

function VisDataCleared()
	update();
end

function InvisDataAdded()
	update();
end

function updateControl(sControl, bReadOnly, bID)
	if not self[sControl] then
		return false;
	end
		
	if not bID then
		return self[sControl].update(bReadOnly, true);
	end
	
	return self[sControl].update(bReadOnly);
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("item", nodeRecord);
	
	local bWeapon = ItemManager2.isWeapon(nodeRecord);
	local bArmor = ItemManager2.isArmor(nodeRecord);
		
	local bSection1 = false;
	if updateControl("type", bReadOnly, bID) then bSection1 = true; end
	if updateControl("range", bReadOnly, bID and bWeapon) then bSection1 = true; end

	local bSection2 = false;
	if updateControl("damagerating", bReadOnly, bID and bWeapon) then bSection2 = true; end
	if updateControl("resistance", bReadOnly, bID and bArmor) then bSection2 = true; end
	if updateControl("effect", bReadOnly, bID and bWeapon) then bSection2 = true; end

	local bSection3 = false;
	if updateControl("size", bReadOnly, bID and bWeapon) then bSection3 = true; end
	if updateControl("qualities", bReadOnly, bID and bWeapon) then bSection3 = true; end
	if updateControl("cost", bReadOnly, bID) then bSection3 = true; end

	local bSection4 = true
	notes.setReadOnly(bReadOnly);
		
	divider.setVisible(bSection1 and bSection2);
	divider2.setVisible((bSection1 or bSection2) and bSection3);
	divider3.setVisible((bSection1 or bSection2 or bSection3) and bSection4);
end