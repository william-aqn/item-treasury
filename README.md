# Быстрый поиск оригинального предмета RU LOTRO

## Install
Download [item-treasury-mod-0.6.4.zip](https://github.com/william-aqn/item-treasury/releases/download/update-0.6.4/item-treasury-mod-0.6.4.zip) and unpack into `Documents\The Lord of the Rings Online\Plugins\`

## [Auto-update](/GaluhadPlugins/ItemTreasury/_update.ps1) script
Just run PowerShell script from plugin folder to update all databases and (re)patch original plugin 
* double click to `update.cmd`

## How to use
Command to open Bruteforce window `/ru` or right mouse click on plugin icon

Drop into Bruteforce window item from bag, result printed into chat
![How to use](/screen.png)

Or enter Русское название in search filed item-treasury windows
![How to use](/screen-window-ru-en-all.gif)

## Mod based on
- Original version [item-treasury 33.0.5](http://www.lotrointerface.com/downloads/info870)
- DB [35.1.3](https://github.com/dt192/item-treasury-database)

## New database source
https://github.com/dt192/item-treasury-database

## For next updates reminds
1. [Main.lua:30](/GaluhadPlugins/ItemTreasury/Main.lua#L30) after 
`import (PLUGINDIR..".Windows");`
add
```
import (PLUGINDIR..".BruteforceMod");
```

2. [Main.lua:144](/GaluhadPlugins/ItemTreasury/Main.lua#L144) after
`LoadSequence();`
add
```
LoadBruteforceMod();
```

3. [Windows/MainWin.lua:389](/GaluhadPlugins/ItemTreasury/Windows/MainWin.lua#L389) replace
`local searchName = {};`
```
local searchName = BriteforcePrepareSearchName(searchString);
```

4. [Windows/MainWin.lua:438](/GaluhadPlugins/ItemTreasury/Windows/MainWin.lua#L438) replace
`nameMatch = match;`
```
nameMatch = BruteforceSearch(k, searchName, match);
```

5. [Windows/MainWin.lua:679](/GaluhadPlugins/ItemTreasury/Windows/MainWin.lua#L679) replace
`lblName:SetText(itemInfo[1]);`
```
BruteforceTextOverride(lblName, itemInfo, itemID)
```

6. Don't forget the file :) [BruteforceMod.lua](/GaluhadPlugins/ItemTreasury/BruteforceMod.lua) and [RuItems.lua](/GaluhadPlugins/ItemTreasury/RuItems.lua) and [StringsRu.lua](/GaluhadPlugins/ItemTreasury/StringsRu.lua)
