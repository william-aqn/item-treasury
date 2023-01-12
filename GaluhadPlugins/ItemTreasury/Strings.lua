
-- [ID] = {[1] = "";				[2] = "";				[3] = "";				[4] = "";};

-- 1 = English; 	2 = French; 	3 = German; 	4 = Russian

_STRINGS =
{

	[1] = -- add on messages
	{
		[1] = 	{[1] = "Error loading saved settings";							[2] = "Error loading saved settings";						[3] = "Error loading saved settings";							[4] = "Error loading saved settings";};
		[2] = 	{[1] = "Please report this message at lotrointerface.com";		[2] = "Please report this message at lotrointerface.com";	[3] = "Please report this message at lotrointerface.com";		[4] = "Please report this message at lotrointerface.com";};
		[3] = 	{
			[1] = PLUGINNAME .. " does not support the character played in this session";
			[2] = PLUGINNAME .. " does not support the character played in this session";
			[3] = PLUGINNAME .. " does not support the character played in this session";
			[4] = PLUGINNAME .. " does not support the character played in this session";};

		[4] = 	{[1] = "No items selected";					[2] = "No items selected";					[3] = "No items selected";					[4] = "No items selected";};
		[5] = {
			[1] = "Shows/hides "..PLUGINNAME.." \nitem (search query) -- usage: /item <id/name>";
			[2] = "Shows/hides "..PLUGINNAME.." \nitem (search query) -- usage: /item <id/name>";
			[3] = "Shows/hides "..PLUGINNAME.." \nitem (search query) -- usage: /item <id/name>";
			[4] = "Shows/hides "..PLUGINNAME.." \nitem (search query) -- usage: /item <id/name>";};

		[6] = {
			[1] = "Use command '/item' to show/hide the main window";
			[2] = "Use command '/item' to show/hide the main window";
			[3] = "Use command '/item' to show/hide the main window";
			[4] = "Use command '/item' to show/hide the main window";};

		[7] = {
			[1] = "Use command '/item <id/name>' to search for an item";
			[2] = "Use command '/item <id/name>' to search for an item";
			[3] = "Use command '/item <id/name>' to search for an item";
			[4] = "Use command '/item <id/name>' to search for an item";};


	};

};


_TOOLTIPS =
{
	[1] = {[1] = "First page";							[2] = "First page";							[3] = "First page";							[4] = "First page";};
	[2] = {[1] = "Previous page";						[2] = "Previous page";						[3] = "Previous page";						[4] = "Previous page";};
	[3] = {[1] = "Next page";							[2] = "Next page";							[3] = "Next page";							[4] = "Next page";};
	[4] = {[1] = "Last page";							[2] = "Last page";							[3] = "Last page";							[4] = "Last page";};
	[5] = {[1] = "Quantity";							[2] = "Quantity";							[3] = "Quantity";							[4] = "Quantity";};
	[6] = {[1] = "Print Info";							[2] = "Print Info";							[3] = "Print Info";							[4] = "Print Info";};
	[7] = {[1] = "Live item and skill scanner";			[2] = "Live item and skill scanner";		[3] = "Live item and skill scanner";		[4] = "Live item and skill scanner";};
	[8] = {[1] = "Item already exists in plugin database";			[2] = "Item already exists in plugin database";		[3] = "Item already exists in plugin database";		[4] = "Item already exists in plugin database";};
	[9] = {[1] = "Item does not exist in plugin database";			[2] = "Item does not exist in plugin database";		[3] = "Item does not exist in plugin database";		[4] = "Item does not exist in plugin database";};

	[10] = {
			[1] = "Items found during the scan process that are not part of the plugin database can be saved locally, this will allow these items to be searched in the main plugin window.";
			[2] = "Items found during the scan process that are not part of the plugin database can be saved locally, this will allow these items to be searched in the main plugin window.";
			[3] = "Items found during the scan process that are not part of the plugin database can be saved locally, this will allow these items to be searched in the main plugin window.";
			[4] = "Items found during the scan process that are not part of the plugin database can be saved locally, this will allow these items to be searched in the main plugin window.";};

	[11] = {[1] = "Add or remove from favourites";		[2] = "Add or remove from favourites";		[3] = "Add or remove from favourites";		[4] = "Add or remove from favourites";};
	[12] = {[1] = "Jump forward ten pages";				[2] = "Jump forward ten pages";				[3] = "Jump forward ten pages";				[4] = "Jump forward ten pages";};
	[13] = {[1] = "Jump backwards ten pages";			[2] = "Jump backwards ten pages";			[3] = "Jump backwards ten pages";			[4] = "Jump backwards ten pages";};

};


_LABELS =
{
	[1] =	{[1] = "Items found";						[2] = "Items found";						[3] = "Items found";						[4] = "Items found";};
	[2] = 	{[1] = "Showing Results";					[2] = "Showing Results";					[3] = "Showing Results";					[4] = "Showing Results";};
	[3] = 	{[1] = "All";								[2] = "All";								[3] = "All";								[4] = "All";};
	[4] = 	{[1] = "Go";								[2] = "Go";									[3] = "Go";									[4] = "Go";};
	[5] = 	{[1] = "Reset";								[2] = "Reset";								[3] = "Reset";								[4] = "Reset";};
	[6] = 	{[1] = "Select All";						[2] = "Select All";							[3] = "Select All";							[4] = "Select All";};
	[7] = 	{[1] = "Select None";						[2] = "Select None";						[3] = "Select None";						[4] = "Select None";};
	[8] = 	{[1] = "List Items";						[2] = "List Items";							[3] = "List Items";							[4] = "List Items";};
	[9] = 	{[1] = "Selected items";					[2] = "Selected items";						[3] = "Selected items";						[4] = "Selected items";};
	[10] = 	{[1] = "Print IDs";							[2] = "Print IDs";							[3] = "Print IDs";							[4] = "Print IDs";};
	[11] = 	{[1] = "Database";							[2] = "Database";							[3] = "Database";							[4] = "Database";};
	[12] = 	{[1] = "Update";							[2] = "Update";								[3] = "Update";								[4] = "Update";};
	[13] = 	{[1] = "Full";								[2] = "Full";								[3] = "Full";								[4] = "Full";};

	[14] = {
			[1] = "Invalid number entered";
			[2] = "Invalid number entered";
			[3] = "Invalid number entered";
			[4] = "Invalid number entered";};

	[15] = 	{[1] = "Item Level";						[2] = "Item Level";							[3] = "Item Level";							[4] = "Item Level";};
	[16] = 	{[1] = "Armour";							[2] = "Armour";								[3] = "Armour";								[4] = "Armour";};
	[17] = 	{[1] = "Min. Level";						[2] = "Min. Level";							[3] = "Min. Level";							[4] = "Min. Level";};
	[18] = 	{[1] = "Preview";							[2] = "Preview";							[3] = "Preview";							[4] = "Preview";};
	[19] = 	{[1] = "Item Preview";						[2] = "Item Preview";						[3] = "Item Preview";						[4] = "Item Preview";};
	[20] = 	{[1] = "Scanner";							[2] = "Scanner";							[3] = "Scanner";							[4] = "Scanner";};
	[21] = 	{[1] = "Start ID";							[2] = "Start ID";							[3] = "Start ID";							[4] = "Start ID";};
	[22] = 	{[1] = "SKILL";								[2] = "SKILL";								[3] = "SKILL";								[4] = "SKILL";};

	[23] = {
			[1] = "This feature uses live game data rather than the plugin's built-in database. This is useful for searching game data after a new game update whilst still waiting for an official plugin update. Because this uses live data the search function is limited. The default start ID continues where the previous database finishes.";
			[2] = "This feature uses live game data rather than the plugin's built-in database. This is useful for searching game data after a new game update whilst still waiting for an official plugin update. Because this uses live data the search function is limited. The default start ID continues where the previous database finishes.";
			[3] = "This feature uses live game data rather than the plugin's built-in database. This is useful for searching game data after a new game update whilst still waiting for an official plugin update. Because this uses live data the search function is limited. The default start ID continues where the previous database finishes.";
			[4] = "This feature uses live game data rather than the plugin's built-in database. This is useful for searching game data after a new game update whilst still waiting for an official plugin update. Because this uses live data the search function is limited. The default start ID continues where the previous database finishes.";};

	[24] = {
			[1] = "No items found, suspected end of database";
			[2] = "No items found, suspected end of database";
			[3] = "No items found, suspected end of database";
			[4] = "No items found, suspected end of database";};

	[25] = {
			[1] = "Ten-digit item code";
			[2] = "Ten-digit item code";
			[3] = "Ten-digit item code";
			[4] = "Ten-digit item code";};

	[26] = 	{[1] = "Saved Scans";						[2] = "Saved Scans";						[3] = "Saved Scans";						[4] = "Saved Scans";};
	[27] = 	{[1] = "Automatically save unknown items";	[2] = "Automatically save unknown items";	[3] = "Automatically save unknown items";	[4] = "Automatically save unknown items";};

	[28] = 	{[1] = "Favourites";						[2] = "Favourites";							[3] = "Favourites";							[4] = "Favourites";};
	[29] = 	{[1] = "Delete Items";						[2] = "Delete Items";						[3] = "Delete Items";						[4] = "Delete Items";};
	[30] = 	{[1] = "Delete Selected Items?";			[2] = "Delete Selected Items?";				[3] = "Delete Selected Items?";				[4] = "Delete Selected Items?";};

	[31] = 	{[1] = "Sort";								[2] = "Sort";								[3] = "Sort";								[4] = "Sort";};

};

_CHATCHANNELS =
{			--English				-- French				-- German				-- Russian
	[1] =  {[1] = "World";			[2] = "World";			[3] = "World"; 			[4] = "World";};
	[2] =  {[1] = "Trade";			[2] = "Trade";			[3] = "Trade"; 			[4] = "Trade";};
	[3] =  {[1] = "LFF";			[2] = "LFF";			[3] = "LFF"; 			[4] = "LFF";};
	[4] =  {[1] = "Kinship";		[2] = "Kinship";		[3] = "Kinship"; 		[4] = "Kinship";};
	[5] =  {[1] = "Officer";		[2] = "Officer";		[3] = "Officer"; 		[4] = "Officer";};
	[6] =  {[1] = "Fellowship";		[2] = "Fellowship";		[3] = "Fellowship";		[4] = "Fellowship";};
	[7] =  {[1] = "Raid";			[2] = "Raid";			[3] = "Raid"; 			[4] = "Raid";};
	[8] =  {[1] = "OOC";			[2] = "OOC";			[3] = "OOC"; 			[4] = "OOC";};
	[9] =  {[1] = "Regional";		[2] = "Regional";		[3] = "Regional"; 		[4] = "Regional";};
	[10] = {[1] = "Say";			[2] = "Say";			[3] = "Say"; 			[4] = "Say";};
	[11] = {[1] = "User Chat 1";	[2] = "User Chat 1";	[3] = "User Chat 1";	[4] = "User Chat 1";};
	[12] = {[1] = "User Chat 2";	[2] = "User Chat 2";	[3] = "User Chat 2";	[4] = "User Chat 2";};
	[13] = {[1] = "User Chat 3";	[2] = "User Chat 3";	[3] = "User Chat 3";	[4] = "User Chat 3";};
	[14] = {[1] = "User Chat 4";	[2] = "User Chat 4";	[3] = "User Chat 4";	[4] = "User Chat 4";};
	[15] = {[1] = "User Chat 5";	[2] = "User Chat 5";	[3] = "User Chat 5";	[4] = "User Chat 5";};
	[16] = {[1] = "User Chat 6";	[2] = "User Chat 6";	[3] = "User Chat 6";	[4] = "User Chat 6";};
	[17] = {[1] = "User Chat 7";	[2] = "User Chat 7";	[3] = "User Chat 7";	[4] = "User Chat 7";};
	[18] = {[1] = "User Chat 8";	[2] = "User Chat 8";	[3] = "User Chat 8";	[4] = "User Chat 8";};
};

_CHATCOMMANDS =
{			--English			-- French				-- German				-- Russian
	[1] =  {[1] = "/wd";		[2] = "/wd";			[3] = "/wd"; 			[4] = "/wd";};
	[2] =  {[1] = "/trade";		[2] = "trade";			[3] = "trade"; 			[4] = "trade";};
	[3] =  {[1] = "/lff";		[2] = "/lff";			[3] = "/lff"; 			[4] = "/lff";};
	[4] =  {[1] = "/k";			[2] = "/k";				[3] = "/k"; 			[4] = "/k";};
	[5] =  {[1] = "/o";			[2] = "/o";				[3] = "/o"; 			[4] = "/o";};
	[6] =  {[1] = "/f";			[2] = "/f";				[3] = "/f";				[4] = "/f";};
	[7] =  {[1] = "/ra";		[2] = "/ra";			[3] = "/ra"; 			[4] = "/ra";};
	[8] =  {[1] = "/ooc";		[2] = "/ooc";			[3] = "/ooc"; 			[4] = "/ooc";};
	[9] =  {[1] = "/regional";	[2] = "/regional";		[3] = "/regional"; 		[4] = "/regional";};
	[10] = {[1] = "/say";		[2] = "/say";			[3] = "/say"; 			[4] = "/say";};
	[11] = {[1] = "/1";			[2] = "/1";				[3] = "/1";				[4] = "/1";};
	[12] = {[1] = "/2";			[2] = "/2";				[3] = "/2";				[4] = "/2";};
	[13] = {[1] = "/3";			[2] = "/3";				[3] = "/3";				[4] = "/3";};
	[14] = {[1] = "/4";			[2] = "/4";				[3] = "/4";				[4] = "/4";};
	[15] = {[1] = "/5";			[2] = "/5";				[3] = "/5";				[4] = "/5";};
	[16] = {[1] = "/6";			[2] = "/6";				[3] = "/6";				[4] = "/6";};
	[17] = {[1] = "/7";			[2] = "/7";				[3] = "/7";				[4] = "/7";};
	[18] = {[1] = "/8";			[2] = "/8";				[3] = "/8";				[4] = "/8";};
};

_SORTBY =
{			--English			-- French				-- German				-- Russian
	[1] =  {[1] = "Item Name";		[2] = "Item Name";			[3] = "Item Name"; 			[4] = "Item Name";};
	[2] =  {[1] = "Item ID";		[2] = "Item ID";			[3] = "Item ID"; 			[4] = "Item ID";};
};

_SORTOPTION =
{			--English			-- French				-- German				-- Russian
	[1] =  {[1] = "Ascending";		[2] = "Ascending";			[3] = "Ascending"; 			[4] = "Ascending";};
	[2] =  {[1] = "Descending";		[2] = "Descending";			[3] = "Descending"; 		[4] = "Descending";};
};
