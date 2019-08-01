function onInit()
	-- Add new fonts to the end of the current languagefonts table in manager_gamesystem.lua
--	for k,v in ipairs(new_languagefonts) do
--		Debug.console(v);
--		table.insert(GameSystem.languagefonts, v)
--	end 

	GameSystem.languagefonts = {
		["Vulcan"] = "Vulcan",
		["Andorian"] = "Andorian",		
		["Tellarite"] = "Tellarite",
		["Klingon"] = "Klingon",
		["Romulan"] = "Romulan",
		["Cardassian"] = "Cardassian",
		["Bajoran"] = "Bajoran"
	}	
	
	GameSystem.languages = {
		["Vulcan"] = "Vulcan",
		["Andorian"] = "Andorian",		
		["Tellarite"] = "Tellarite",
		["Klingon"] = "Klingon",
		["Romulan"] = "Romulan",
		["Cardassian"] = "Cardassian",
		["Bajoran"] = "Bajoran"
	}
	
	-- Add new languages to the end of the current languages table in manager_gamesystem.lua
--	for k,v in ipairs(new_languages) do
--		table.insert(GameSystem.languages, v)
--	end 	

	--Debug.console(table.concat(GameSystem.languages, ","));
end