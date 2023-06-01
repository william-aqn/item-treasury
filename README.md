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


Команды
/item - показать главное окно
/item <id/название> - отобразить список искомых предметов


Как установить плагин:

а. Перед тем, как устанавливать сам плагин, убедитесь, что у вас создана папка Plugins по пути:

%USERPROFILE%\Документы\The Lord of the Rings Online

б. Убедитесь, что у вас скачаны и установлены библиотеки плагинов от Turbine.

1. Распаковать архив в папку по пути:

%USERPROFILE%\Документы\The Lord of the Rings Online\Plugins\


Как запустить плагин:

Запустить плагин можно тремя способами:

    Через стандартную комманду загрузки плагинов /plugins load itemtreasury
    Через встроенное Управление Плагинами от Turbine
    С помощью плагина Shady


FAQ:
"У меня ничего не работает? Что делать?"

    Перед заходом в игру удалите файлы ItemTreasury_Settings.plugindata в папке по пути:

    %USERPROFILE%\Документы\The Lord of the Rings Online\PluginData\<имя аккаунта>\<имя сервера>\<имя персонажа>\

    Затем зайдите в игру и попробуйте загрузить плагин.

    Если это первый ваш плагин, то внимательно прочитайте "Гайд по плагинам".
    Внимательно прочитайте шапку данной темы и выполните все пункты последовательно, обратив пристальное внимание на пункты "Как установить" и "Как запустить".
    Если не выходит, внимательно прочитатайте раздел "FAQ".
    Если все равно ничего не вышло, то Вам следует задать вопрос в этой теме. 

"Я загрузил плагин, но ничего не появилось. Не могу открыть плагин."

    Окно плагина открывается командой /item

"Я не могу загрузить плагин, хотя это уже не первый мой плагин. Все работают, а этот - нет."

    Если плагин не запускается никакими средствами, либо какие-то его функции не работают, значит, в чат должна выдаваться ошибка. Поставьте в настройках чата, в фильтрах, галочку напротив строки "ошибка". Скопируйте текст ошибки из чата в эту тему. Специалисты попробуют разобраться и помочь Вам. И не забывайте, что Вам никто ничего не должен.

"Где кнопка плагина?"

    Функционал кнопки для данного плагина не предусмотрен.


Благодарности
Спасибо Galuhad за столь замечательный плагин!