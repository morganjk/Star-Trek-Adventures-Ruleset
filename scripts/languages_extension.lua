function onInit()
	-- Add new fonts to the end of the current languagefonts table in manager_gamesystem.lua
--	for k,v in ipairs(new_languagefonts) do
--		Debug.console(v);
--		table.insert(GameSystem.languagefonts, v)
--	end 

	GameSystem.languagefonts = {
		["Andorian"] = "Andorian",
		["Bajoran"] = "Bajoran",
		["Borg"] = "Borg",
		["Cardassian"] = "Cardassian",
		["Dominion"] = "Dominion",
		["Ferengi"] = "Ferengi",
		["Klingon"] = "Klingon",
		["Romulan"] = "Romulan",
		["Tellarite"] = "Tellarite",
		["Tholian"] = "Tholian",
		["Trill"] = "Trill",
		["Vulcan"] = "Vulcan"
	}	
	
	GameSystem.languages = {
		["Andorian"] = "Andorian",
		["Bajoran"] = "Bajoran",
		["Borg"] = "Borg",
		["Cardassian"] = "Cardassian",
		["Dominion"] = "Dominion",
		["Ferengi"] = "Ferengi",
		["Klingon"] = "Klingon",
		["Romulan"] = "Romulan",
		["Tellarite"] = "Tellarite",
		["Tholian"] = "Tholian",
		["Trill"] = "Trill",
		["Vulcan"] = "Vulcan"
	}
	
	-- Add new languages to the end of the current languages table in manager_gamesystem.lua
--	for k,v in ipairs(new_languages) do
--		table.insert(GameSystem.languages, v)
--	end 	

	--Debug.console(table.concat(GameSystem.languages, ","));
end