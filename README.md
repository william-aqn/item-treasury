# Быстрый поиск оригинального предмета для RU LOTRO [item-treasury](http://www.lotrointerface.com/downloads/info870)

Command to open Bruteforce window `/ru`

Drop into Bruteforce window item from bag, result printed into chat
![How to use](/screen.png)

Or enter Русское название in search filed item-treasury windows
![How to use](/screen-window.png)

## New database
https://github.com/dt192/item-treasury-database

## For next updates
1. [Main.lua:30](/GaluhadPlugins/ItemTreasury/Main.lua#L30) after 
`import (PLUGINDIR..".Windows");`
add
```
import (PLUGINDIR..".RuItems");
import (PLUGINDIR..".BruteforceMod");
```

2. [Main.lua:144](/GaluhadPlugins/ItemTreasury/Main.lua#L144) after
`LoadSequence();`
add
```
LoadBruteforceMod();
```

3. [Windows/MainWin.lua:391](/GaluhadPlugins/ItemTreasury/Windows/MainWin.lua#L391) replace
`string.gmatch(searchStr, "%a+")`
```
string.gmatch(searchStr, "%S+")

```
4. [Windows/MainWin.lua:438](/GaluhadPlugins/ItemTreasury/Windows/MainWin.lua#L438) replace
`nameMatch = match;`
```
nameMatch = BruteforceSearch(k, searchName, match);
```

5. Don't forget the file :) [BruteforceMod.lua](/GaluhadPlugins/ItemTreasury/BruteforceMod.lua) and [RuItems.lua](/GaluhadPlugins/ItemTreasury/RuItems.lua)