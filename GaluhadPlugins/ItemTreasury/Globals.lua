
SETTINGS = {}; 		-- Table used when loading settings.
V_SETTINGS = 1;		-- Table version number, used when saving/loading each table to check against updates.
PAGE = 0;
_SEARCHRESULTS = {};
_SELECTEDSCANS = {};
_dbTable = _ITEMSDB;
_SAVEDITEMS = {};
_FAVITEMS = {};
FROMSAVED = false;

SCREENWIDTH = Turbine.UI.Display.GetWidth();
SCREENHEIGHT = Turbine.UI.Display.GetHeight();

PLAYERCHAR = Turbine.Gameplay.LocalPlayer.GetInstance();

LANGID = 1;

_COLORS =
{
	[1] = Turbine.UI.Color.Ivory;
	[2] = Turbine.UI.Color.Khaki;
	[3] = Turbine.UI.Color.Red;
	[4] = Turbine.UI.Color.Lime;
	[5] = Turbine.UI.Color((0/255),(17/255),(45/255)); -- Scan items selected colour
	[6] = Turbine.UI.Color.Black;
	[7] = Turbine.UI.Color(0.7,0.7,0.7);
};

_FONTS =
{
	[1] = Turbine.UI.Lotro.Font.Verdana10;
	[2] = Turbine.UI.Lotro.Font.Verdana12;
	[3] = Turbine.UI.Lotro.Font.Verdana14;
	[4] = Turbine.UI.Lotro.Font.TrajanPro14;
	[5] = Turbine.UI.Lotro.Font.TrajanPro18;
};

_QUALITYCOLORS =
{
	[0] = Turbine.UI.Color.White;			-- Undefined
	[5] = Turbine.UI.Color.White;			-- Common
	[4] = Turbine.UI.Color.Yellow;			-- Uncommon
	[2] = Turbine.UI.Color.Magenta;			-- Rare
	[3] = Turbine.UI.Color.Aqua;			-- Incomparable
	[1] = Turbine.UI.Color.Orange;			-- Legendary
};

_ITEMQUALITY =
{
	[0] = {[1]="Undefined";[2]=100;}; -- 1 = name. 2 = pixel width
	[1] = {[1]="Legendary";[2]=105;};
	[2] = {[1]="Rare";[2]=60;};
	[3] = {[1]="Incomparable";[2]=120;};
	[4] = {[1]="Uncommon";[2]=105;};
	[5] = {[1]="Common";[2]=90;};
};

_ITEMQUALITYZORDER =
{
	[0] = 0;
	[1] = 5;
	[2] = 4;
	[3] = 2;
	[4] = 3;
	[5] = 1;
};

-- Default Settings
DEFAULT_SETTINGS =
	{
	["MAINWIN"] =
		{
		["X"] = 60;
		["Y"] = 60;
		["VISIBLE"] = true;
		};
	["SCANWIN"] =
		{
		["X"] = 60;
		["Y"] = 60;
		["SAVE"] = true;
		};
	["ITEMWIN"] =
		{
		["X"] = 60;
		["Y"] = 60;
		};
	};

