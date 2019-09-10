-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- RECORD TYPE FORMAT
-- 		["recordtype"] = { 
--			bExport = <bool>,
-- 			bHidden = <bool>,
-- 			bID = <bool>,
--			bNoCategories = <bool>,
--			bAllowClientEdit = <bool>,
-- 			aDataMap = <table of strings>, 
-- 			aDisplayIcon = <table of 2 strings>, 
--			fToggleIndex = <function>
-- 			sListDisplayClass = <string>,
-- 			sRecordDisplayClass = <string>,
--			aRecordDisplayCLasses = <table of strings>,
--			fRecordDisplayClass = <function>,
--			aGMListButtons = <table of templates>,
-- 		},
--
-- FIELDS ADDED FROM STRING DATA
-- 		sDisplayText = Interface.getString(library_recordtype_label_ .. sRecordType)
-- 		sEmptyNameText = Interface.getString(library_recordtype_empty_ .. sRecordType)
--
-- 		*FIELDS ADDED FROM STRING DATA (only when bID set)*
-- 		sEmptyUnidentifiedNameText = Interface.getString(library_recordtype_empty_nonid_ .. sRecordType)
--
-- RECORD TYPE LEGEND
--		bExport = Optional. Same as nExport = 1. Boolean indicating whether record should be exportable in the library export window for the record type.
--		nExport = Optional. Overriden by bExport. Number indicating number of data paths which are exportable in the library export window for the record type.
--			NOTE: See aDataMap for bExport/nExport are handled for target campaign data paths vs. reference data paths (editable vs. read-only)
--		bHidden = Optional. Boolean indicating whether record should be displayed in library, and when show aLl records in sidebar selected.
-- 		bID = Optional. Boolean indicating whether record is identifiable or not (currently only items and images)
--		bNoCateories = Optional. Disable display and usage of category information.
--		bAllowClientEdit = Optional. Allow clients to add/delete records in the list that they own.
--		aDataMap = Required. Table of strings. defining the valid data paths for records of this type
--			NOTE: For bExport/nExport, that number of data paths from the beginning of the data map list will be used as the source for exporting 
--				and the target data paths will be the same in the module. (i.e. default campaign data paths, editable).
--				The next nExport data paths in the data map list will be used as the export target data paths for read-only data paths for the 
--				matching source data path.
--			EX: { "item", "armor", "weapon", "reference.items", "reference.armors", "reference.weapons" } with a nExport of 3 would mean that
--				the "item", "armor" and "weapon" data paths would be exported to the matching "item", "armor" and "weapon" data paths in the module by default.
--				If the reference data path option is selected, then "item", "armor" and "weapon" data paths would be exported to 
--				"reference.items", "reference.armors", and "reference.weapons", respectively.
--		aDisplayIcon = Required. Table of strings. Provides icon resource names for sidebar/library buttons for this record type (normal and pressed icon resources)
--		fToggleIndex = Optional. Function. This function will be called when the sidebar/library button is pressed for this record type. If not defined, a default master list window will be toggled.
--		sListDisplayClass = Optional. String. Class to use when displaying this record in a list. If not defined, a default class will be used.
--		sRecordDisplayClass = Required (or aRecordDisplayClasses/fRecordDisplayClass defined). String. Class to use when displaying this record in detail.
--		aRecordDisplayClasses = Required (or sRecordDisplayClass/fRecordDisplayClass defined). Table of strings. List of valid display classes for records of this type. Use fRecordDisplayClass to specify which one to use for a given path.
--		fRecordDisplayClass = Required (or sRecordDisplayClass/aRecordDisplayClasses defined). Function. Function called when requesting to display this record in detail.
--		aGMListButtons = Optional. Table of templates. A list of control templates created and added to the master list window for this record type.
--
--		sDisplayText = Required. String Resource. Text displayed in library and tooltips to identify record type textually.
--		sEmptyNameText = Optional. String Resource. Text displayed in name field of record list and detail classes, when name is empty.
--		sEmptyUnidentifiedNameText = Optional. String Resource. Text displayed in nonid_name field of record list and detail classes, when nonid_name is empty. Only used if bID flag set.
--

aRecordOverrides = {
	["vehicle"] = { 
		bExport = true,
		aDataMap = { "vehicle", "reference.vehicles" }, 
		aDisplayIcon = { "button_vehicles", "button_vehicles_down" },
		-- sRecordDisplayClass = "vehicle", 
	},
	["species"] = { 
		bExport = true,
		aDataMap = { "species", "reference.species" }, 
		aDisplayIcon = { "button_species", "button_species_down" },
		-- sRecordDisplayClass = "species", 
	},
	["talents"] = { 
		bExport = true,
		aDataMap = { "talents", "reference.talents" }, 
		aDisplayIcon = { "button_talents", "button_talents_down" },
		-- sRecordDisplayClass = "talents", 
	},
	["environment"] = { 
		bExport = true,
		aDataMap = { "environment", "reference.environment" }, 
		aDisplayIcon = { "button_environment", "button_environment_down" },
		-- sRecordDisplayClass = "environment", 
	},
	["upbringing"] = { 
		bExport = true,
		aDataMap = { "upbringing", "reference.upbringing" }, 
		aDisplayIcon = { "button_upbringing", "button_upbringing_down" },
		-- sRecordDisplayClass = "upbringing", 
	},
	["backgrounds"] = { 
		bExport = true,
		aDataMap = { "backgrounds", "reference.backgrounds" }, 
		aDisplayIcon = { "button_backrgounds", "button_backrgounds_down" },
		-- sRecordDisplayClass = "backgrounds", 
	},
};

aListViews = {
	["vehicle"] = {
		["byletter"] = {
			sTitleRes = "vehicle_grouped_title_byletter",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "vehicle_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "name", nLength = 1 } },
			aGroupValueOrder = { },
		},
		["bytype"] = {
			sTitleRes = "vehicle_grouped_title_bytype",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "vehicle_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "type", sCustom="vehicle_type" } },
			aGroupValueOrder = { },
		},
	},
	["species"] = {
		["byletter"] = {
			sTitleRes = "species_grouped_title_byletter",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "species_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "name", nLength = 1 } },
			aGroupValueOrder = { },
		},
	},
	["talents"] = {
		["byletter"] = {
			sTitleRes = "talents_grouped_title_byletter",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "talents_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "name", nLength = 1 } },
			aGroupValueOrder = { },
		},
		["byreq"] = {
			sTitleRes = "talents_grouped_title_byreq",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "talents_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "type", sCustom="values_req" } },
			aGroupValueOrder = { },
		},
	},
	["environment"] = {
		["byletter"] = {
			sTitleRes = "environment_grouped_title_byletter",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "environment_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "name", nLength = 1 } },
			aGroupValueOrder = { },
		},
		["byattribute"] = {
			sTitleRes = "environment_grouped_title_byattribute",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "environment_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "type", sCustom="environment_req" } },
			aGroupValueOrder = { },
		},
		["bydiscipline"] = {
			sTitleRes = "environment_grouped_title_bydiscipline",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "environment_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "type", sCustom="environment_req" } },
			aGroupValueOrder = { },
		},
	},
	["upbringing"] = {
		["byletter"] = {
			sTitleRes = "upbringing_grouped_title_byletter",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "upbringing_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "name", nLength = 1 } },
			aGroupValueOrder = { },
		},
	},
	["backgrounds"] = {
		["byletter"] = {
			sTitleRes = "backgrounds_grouped_title_byletter",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "backgrounds_grouped_label_name", nWidth=250 },
			},
			aFilters = { },
			aGroups = { { sDBField = "name", nLength = 1 } },
			aGroupValueOrder = { },
		},
	},
};

function onInit()
	for kRecordType,vRecordType in pairs(aRecordOverrides) do
		LibraryData.overrideRecordTypeInfo(kRecordType, vRecordType);
	end
	for kRecordType,vRecordListViews in pairs(aListViews) do
		for kListView, vListView in pairs(vRecordListViews) do
			LibraryData.setListView(kRecordType, kListView, vListView);
		end
	end
  DesktopManager.setStackIconSizeAndSpacing(50, 20, 3, 3, 4, 0);
  DesktopManager.setDockIconSizeAndSpacing(120, 48, 0, 4);

end