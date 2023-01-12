
PLUGINDIR = "GaluhadPlugins.ItemTreasury";
RESOURCEDIR = "GaluhadPlugins/ItemTreasury/Resources/";
PLUGINNAME = "Item Treasury";

-- Turbine Imports..
import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI";
import "Turbine.UI.Lotro";

-- Plugin Imports..
import (PLUGINDIR..".Globals");
import (PLUGINDIR..".Images");
import (PLUGINDIR..".Strings");
import (PLUGINDIR..".AddCallBack");
import (PLUGINDIR..".Functions");
import (PLUGINDIR..".Commands");
import (PLUGINDIR..".33_0_5_Items");
import (PLUGINDIR..".33_0_5_NewItems");
import (PLUGINDIR..".Category");

-- Utils Imports..
import (PLUGINDIR..".Utils");

-- Windows..
import (PLUGINDIR..".Windows");

-- BruteforceMod
import (PLUGINDIR..".BruteforceMod");
-----------------------------------------------------------------------------------------------------------

function saveData()
	SETTINGS["__VERSION"] = V_SETTINGS;
	Turbine.PluginData.Save(Turbine.DataScope.Character, "ItemTreasury_Settings", SETTINGS);
	Turbine.PluginData.Save(Turbine.DataScope.Account, "ItemTreasury_SavedItems", _SAVEDITEMS);
	Turbine.PluginData.Save(Turbine.DataScope.Account, "ItemTreasury_FavItems", _FAVITEMS);
end


function loadData()
	---------------------------------------------------------------------------------------------------------------------------------
	-- SAVED ITEMS
	function GetSavedItems()
		_SAVEDITEMS = Turbine.PluginData.Load(Turbine.DataScope.Account, "ItemTreasury_SavedItems");
	end

	if pcall(GetSavedItems) then
		GetSavedItems();

		if _SAVEDITEMS == nil or type(_SAVEDITEMS) ~= 'table' then
			_SAVEDITEMS = {};
		else
			-- check loaded items against actual database... need to phase out items that have since been added to the official database
			-- otherwise merge remaining loaded items into the official database to be used.
			for k,v in pairs (_SAVEDITEMS) do
				if Windows.ExistsInDB(k) then
					_SAVEDITEMS[k] = nil;
				else
					_ITEMSDB[k] = v;
					if k > LASTID then LASTID = k end;
				end
			end
		end
	end

	-- FAV ITEMS ---------------------------------------------------------------------------------------------------------------------------------
	function GetFavItems()
		_FAVITEMS = Turbine.PluginData.Load(Turbine.DataScope.Account, "ItemTreasury_FavItems");
	end

	if pcall(GetFavItems) then
		GetFavItems();

		if _FAVITEMS == nil or type(_FAVITEMS) ~= 'table' then
			_FAVITEMS = {};
		end
	end

	-- SAVED SETTINGS ---------------------------------------------------------------------------------------------------------------------------------
	local SavedSettings = {};

	function GetSavedSettings()
		SavedSettings = Turbine.PluginData.Load(Turbine.DataScope.Character, "ItemTreasury_Settings");
	end

	if pcall(GetSavedSettings) then
		GetSavedSettings();
	else -- Loaded with errors
		SavedSettings = nil;
		printError(_STRINGS[1][1][LANGID]);
	end

	-- Check the saved settings to make sure it is still compatible with newer updates, add in any missing default settings
	if type(SavedSettings) == 'table' then
		local tempSETTINGS = {};
		tempSETTINGS = Utils.deepcopy(DEFAULT_SETTINGS);
		SETTINGS = Utils.mergeTables(tempSETTINGS,SavedSettings);
	else
		SETTINGS = Utils.deepcopy(DEFAULT_SETTINGS);
	end
	----------------------------------------------------------------------------------------------------------------------------------
end


function print(MESSAGE)
	if MESSAGE == nil then return end;
	Turbine.Shell.WriteLine("<rgb=#FF6666>" .. tostring(MESSAGE) .. "</rgb>");
end


function printError(STRING)
	if STRING == nil or STRING == "" then return end;
	Turbine.Shell.WriteLine("<rgb=#FF3333>"..PLUGINNAME..": " .. tostring(STRING) .. "\n" .. _STRINGS[1][2][LANGID] .. "</rgb>");
end


function LoadSequence()
	LANGID = Utils.GetClientLanguage();
	if string.find(PLAYERCHAR:GetName(),"~") then
		Debug(_STRINGS[1][3][LANGID]);
	else
		loadData();
		Utils.InitiateChatLogger();
		Windows.DrawWindows();
		RegisterCommands();

		Turbine.Plugin.Unload = function ()
			saveData();
		end

		print("Loaded '" .. PLUGINNAME .. "' by Galuhad [Evernight]");
		print(_STRINGS[1][6][LANGID]);
		print(_STRINGS[1][7][LANGID]);

		--Windows.CheckMissingCats(_ITEMSDB);	-- Only check on new database updates
	end
end


-- Initiate load sequence
LoadSequence();
-- BruteforceMod load
LoadBruteforceMod();