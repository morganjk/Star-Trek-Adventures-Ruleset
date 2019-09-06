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

function updateControl(sControl, bReadOnly, bShow)
	if not self[sControl] then
		return false;
	end
		
	return self[sControl].update(bReadOnly, not bShow);
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	
	local bWeapon = ItemManager2.isWeapon(nodeRecord);
	local bArmor = ItemManager2.isArmor(nodeRecord);
	
	local bSection = false;
	if updateControl("type", bReadOnly, true) then bSection = true; end
	if updateControl("range", bReadOnly, bWeapon) then bSection = true; end
	
	local bSection2 = false;
	if updateControl("damagerating", bReadOnly, bWeapon) then bSection2 = true; end
	if updateControl("resistance", bReadOnly, bArmor) then bSection2 = true; end
	if updateControl("effect", bReadOnly, bWeapon) then bSection2 = true; end
	
	local bSection3 = false;
	if updateControl("size", bReadOnly, bWeapon) then bSection3 = true; end
	if updateControl("qualities", bReadOnly, bWeapon) then bSection3 = true; end
	if updateControl("cost", bReadOnly, true) then bSection3 = true; end
	
	description.setReadOnly(bReadOnly);
	
	divider.setVisible(bSection and bSection2);
	divider2.setVisible((bSection or bSection2) and bSection3);
	divider3.setVisible(bSection or bSection2 or bSection3);
end
