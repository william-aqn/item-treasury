# Add bruteforce item id window into [item-treasury](http://www.lotrointerface.com/downloads/info870) LOTRO

Command to open Bruteforce window `/it`

Drop into Bruteforce window item from bag, result printed into chat
![How to use](/screen.png)

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

3. Don't forget the file :) [BruteforceMod.lua](/GaluhadPlugins/ItemTreasury/BruteforceMod.lua) and [RuItems.lua](/GaluhadPlugins/ItemTreasury/RuItems.lua)