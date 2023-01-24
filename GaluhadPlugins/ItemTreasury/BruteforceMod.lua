import("GaluhadPlugins.ItemTreasury.RuItems")
import("GaluhadPlugins.ItemTreasury.StringsRu")

-- by DCRM
BruteforceVersion = "0.6";
BruteforceWindow = Turbine.UI.Lotro.Window();

BruteforceStartId = FIRSTID -- FIRSTID 1879049233
BruteforceEndId = LASTID -- LASTID 1879448522
BruteforceDb = _ITEMSDB
BruteforceRuDb = _RUITEMS
BruteforceRuDbSearch = _RUITEMS_SEARCH
BruteforceRuDbVersion = RUVERSION

-- Переопределяем названия предметов в основном окне плагина
function BruteforceTextOverride(label, itemInfo, itemID)
    if (ddLang:GetText() == 'ru' or ddLang:GetText() == 'all') then
        if ExistsInRuDB(itemID) then
            if ddLang:GetText() == 'ru' then
                label:SetText(BruteforceRuDb[itemID][1]);
            else
                label:SetText(BruteforceRuDb[itemID][1] .. '\n' .. itemInfo[1]);
            end
            return BruteforceRuDb[itemID]
        end
    end
    label:SetText(itemInfo[1]);
    return itemInfo
end

-- Находим предмет в РУ базе
function BruteforceItem(itemIn)
    local ret = { ["id"] = 0 }

    local inner
    local ruItem
    local itemInName = itemIn:GetName()

    ret["msg"] = "Запрос [" .. itemInName .. "] - ничего не найдено"
    for i = BruteforceStartId, BruteforceEndId do

        if Windows.ExistsInDB(i) and ExistsInRuDB(i) then
            if BruteforceRuDb[i][1] == itemInName then
                ruItem = BruteforceRuDb[i][1]
                inner = BruteforceDb[i][1]

                ret["id"] = i
                ret["original"] = inner
                ret["msg"] = "Результат:[" ..
                    inner ..
                    "]\nID:[" ..
                    i .. "]\nЗапрос:[" .. ruItem .. "]";

                return ret
            end
        end
    end
    return ret
end

function ExistsInRuDB(itemID)
    if itemID == nil or type(itemID) ~= 'number' then return false end

    if BruteforceRuDb[itemID] == nil then
        return false;
    else
        return true;
    end
end

function BruteforceItemHard(itemIn)
    local item
    local curItemInfo
    local inner
    for i = BruteforceStartId, BruteforceEndId do
        item = Utils.GetItemFromID(i);
        if item ~= nil then -- only add items that exist to the list, ignore null values.
            curItemInfo = item:GetItemInfo();
            if string.find(curItemInfo:GetName(), "GNDN") == nil then -- Ignore all GNDN's
                if curItemInfo:GetName() == itemIn:GetName() then
                    inner = "NotExists"
                    if Windows.ExistsInDB(i) then
                        inner = BruteforceDb[i][1]
                    end
                    return "DB:[" ..
                        inner ..
                        "]\nID:[" ..
                        i .. "]\nЗапрос:[" .. itemIn:GetName() .. "]\nНайдено:[" ..
                        curItemInfo:GetName() .. "]";
                end
            end
        end
    end
    return "Запрос [" .. itemIn:GetName() .. "] - ничего не найдено"
end

function BriteforcePrepareSearchName(searchString)
    local searchName = {};
    local searchStr = string.upper(toUpper(StripAccent(searchString)));
    searchStr = string.gsub(searchStr, "[%p%c]", ''):gsub("  ", ' '):gsub("  ", ' ')
    for w in string.gmatch(searchStr, "%S+") do
        table.insert(searchName, w);
    end
    return searchName
end

function BruteforceSearch(i, searchName, match)
    if match then
        return match
    end
    if not ExistsInRuDB(i) then
        return false
    end

    match = true
    local nameStr = toUpper(BruteforceRuDb[i][1]);
    for wordKey, wordVal in pairs(searchName) do
        if string.find(nameStr, wordVal) == nil then
            match = false;
        end
    end

    return match
end

function RegisterCommandsBruteforce()
    -- /ru
    bruteforceCommand = Turbine.ShellCommand();
    function bruteforceCommand:Execute(command, args)
        BruteforceWindow:SetVisible(not BruteforceWindow:IsVisible());
    end

    function bruteforceCommand:GetHelp()
        return "Put item from bag into bruteforce window";
    end

    function bruteforceCommand:GetShortHelp()
        return "Put item into bruteforce window";
    end

    Turbine.Shell.AddCommand("ru", bruteforceCommand);
end

function LoadBruteforceMod()
    -- Переключаем интерфейс на Русский
    LANGID = 4;
    Windows.DrawWindows();

    -- Переключатель ru/en
    ddLang = Utils.DropDown({ "ru", "en", "all" });
    ddLang:SetParent(Windows.wMainWin);
    ddLang:SetPosition(Windows.ddSortBy:GetLeft() - 100, Windows.ddSortBy:GetTop());
    ddLang:SetWidth(50);
    ddLang:SetAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    ddLang.ItemChanged = function(Sender, Args)
        Windows.RefreshResultsView();
    end

    local height = 150;
    -- Основное окно
    BruteforceWindow:SetSize(300, height);
    BruteforceWindow:SetTop((Turbine.UI.Display:GetHeight() - height) / 2);
    BruteforceWindow:SetLeft((Turbine.UI.Display:GetWidth() - 300) / 4);
    BruteforceWindow:SetText("ID Bruteforce");
    BruteforceWindow:SetAllowDrop(true);
    BruteforceWindow:SetVisible(true);

    -- Подсказка
    local BruteforceCaption = Turbine.UI.Label()
    BruteforceCaption:SetParent(BruteforceWindow)
    BruteforceCaption:SetSize(300, height)
    BruteforceCaption:SetPosition(10, 45)
    BruteforceCaption:SetText("Перетащите сюда предмет")

    -- Быстрый слот для понимания того что распознано
    local BruteforceShortcut = Turbine.UI.Lotro.Quickslot();
    BruteforceShortcut:SetParent(BruteforceWindow);
    BruteforceShortcut:SetSize(36, 36);
    BruteforceShortcut:SetPosition(50, height - 50);
    BruteforceShortcut:SetZOrder(10000);
    BruteforceShortcut:SetEnabled(false);
    BruteforceShortcut:SetVisible(false);
    BruteforceShortcut:SetAllowDrop(false);

    -- Открываем ItemTreasury
    BruteforceButton = Turbine.UI.Lotro.Button();
    BruteforceButton:SetParent(BruteforceWindow);
    BruteforceButton:SetWidth(150);
    BruteforceButton:SetPosition(100, height - 40);
    BruteforceButton:SetText("ItemTreasury");
    BruteforceButton.Click = function()
        Windows.PrepareSearch();
        Windows.wMainWin:SetVisible(true);
        Windows.wMainWin:Activate();
    end

    function BruteforceProcess(args)
        local item = args.DragDropInfo:GetShortcut():GetItem();
        BruteforceCaption:SetText("Поиск ...")
        local result = BruteforceItem(item)
        BruteforceCaption:SetText(result["msg"])
        Turbine.Shell.WriteLine(result["msg"]);

        if (result["id"] > 0) then
            -- Отображаем быстрый слот
            BruteforceShortcut:SetVisible(true);
            BruteforceShortcut:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Item,
                "0x0,0x" .. Utils.TO_HEX(result["id"])));
            -- Устанавливаем текст в строке поиска ItemTreasury
            Windows.txtSearch:SetText(result["original"]);
        else
            BruteforceShortcut:SetVisible(false);
        end
    end

    -- TODO:
    -- cDeskIcon.DragDrop = function (sender, args)
    --     print(Dump(args))
    --     BruteforceWindow:SetVisible(true);
    --     BruteforceProcess(args)
    -- end

    -- Добавляем функционал открытия окна bruteforce по правому клику на значок плагина
	cDeskIcon.MouseClick = function (sender, args)
		if (args.Button == Turbine.UI.MouseButton.Right) then
			if type(cDeskIcon.Windows) ~= 'table' then return end;
            BruteforceWindow:SetVisible(true);
		end
	end

    function BruteforceWindow:DragDrop(args)
        BruteforceProcess(args)
    end

    RegisterCommandsBruteforce();

    print("RU БД версия " .. BruteforceRuDbVersion .. ", модификация версия " ..
        BruteforceVersion .. ", by DCRM");
    print("FirstID = " .. BruteforceStartId .. "; LastId = " .. BruteforceEndId .. ";");
    print("Используйте команду '/ru' что бы показать/скрыть окно перевода предметов или щёлкните правой кнопкой мыши по значку плагина");

end

-- Service functions
-------------------------------------------------------------------------------------------------
function Dump(o)
    if type(o) == 'table' then
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. Dump(v) .. '\n'
        end
        return s .. '}\n'
    else
        return (tostring(o))
    end
end

-- Magic from dt192
function utf8charbytes(s, i)
    -- argument defaults
    i = i or 1

    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8charbytes' (string expected, got " .. type(s) .. ")")
    end
    if type(i) ~= "number" then
        error("bad argument #2 to 'utf8charbytes' (number expected, got " .. type(i) .. ")")
    end

    local c = s:byte(i)

    -- determine bytes needed for character, based on RFC 3629
    -- validate byte 1
    if c > 0 and c <= 127 then
        -- UTF8-1
        return 1

    elseif c >= 194 and c <= 223 then
        -- UTF8-2
        local c2 = s:byte(i + 1)

        if not c2 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        return 2

    elseif c >= 224 and c <= 239 then
        -- UTF8-3
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)

        if not c2 or not c3 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c == 224 and (c2 < 160 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 237 and (c2 < 128 or c2 > 159) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end

        return 3

    elseif c >= 240 and c <= 244 then
        -- UTF8-4
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        local c4 = s:byte(i + 3)

        if not c2 or not c3 or not c4 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c == 240 and (c2 < 144 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 244 and (c2 < 128 or c2 > 143) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 4
        if c4 < 128 or c4 > 191 then
            error("Invalid UTF-8 character")
        end

        return 4

    else
        error("Invalid UTF-8 character")
    end
end

utf8_uc_lc = { ["А"] = "а", ["Б"] = "б", ["В"] = "в", ["Г"] = "г", ["Д"] = "д", ["Е"] = "е", ["Ж"] = "ж",
    ["З"] = "з", ["И"] = "и", ["Й"] = "й", ["К"] = "к", ["Л"] = "л", ["М"] = "м", ["Н"] = "н", ["О"] = "о",
    ["П"] = "п", ["Р"] = "р", ["С"] = "с", ["Т"] = "т", ["У"] = "у", ["Ф"] = "ф", ["Х"] = "х", ["Ц"] = "ц",
    ["Ч"] = "ч", ["Ш"] = "ш", ["Щ"] = "щ", ["Ъ"] = "ъ", ["Ы"] = "ы", ["Ь"] = "ь", ["Э"] = "э", ["Ю"] = "ю",
    ["Я"] = "я", };

utf8_lc_uc = { ["а"] = "А", ["б"] = "Б", ["в"] = "В", ["г"] = "Г", ["д"] = "Д", ["е"] = "Е", ["ж"] = "Ж",
    ["з"] = "З", ["и"] = "И", ["й"] = "Й", ["к"] = "К", ["л"] = "Л", ["м"] = "М", ["н"] = "Н", ["о"] = "О",
    ["п"] = "П", ["р"] = "Р", ["с"] = "С", ["т"] = "Т", ["у"] = "У", ["ф"] = "Ф", ["х"] = "Х", ["ц"] = "Ц",
    ["ч"] = "Ч", ["ш"] = "Ш", ["щ"] = "Щ", ["ъ"] = "Ъ", ["ы"] = "Ы", ["ь"] = "Ь", ["э"] = "Э", ["ю"] = "Ю",
    ["я"] = "Я", };

function addUppers(name, upperPosArr)
    table.sort(upperPosArr);
    local returnStr = "";
    local upperPosArrIdx = 1;
    local letterPos = 1;
    local bytePos = 1;
    while bytePos <= #name do
        local byteCount = utf8charbytes(name, bytePos);
        local c = name:sub(bytePos, bytePos + byteCount - 1);
        if (letterPos == upperPosArr[upperPosArrIdx]) then
            c = (utf8_lc_uc[c] or c);
            upperPosArrIdx = upperPosArrIdx + 1;
        end
        returnStr = returnStr .. c;
        bytePos = bytePos + byteCount;
        letterPos = letterPos + 1;
    end
    return returnStr;
end

function toLower(name)
    local returnStr = "";
    local bytePos = 1;
    while bytePos <= #name do
        local byteCount = utf8charbytes(name, bytePos);
        local c = name:sub(bytePos, bytePos + byteCount - 1);
        returnStr = returnStr .. (utf8_uc_lc[c] or c);
        bytePos = bytePos + byteCount;
    end
    return returnStr;
end

function toUpper(name)
    local returnStr = "";
    local bytePos = 1;
    while bytePos <= #name do
        local byteCount = utf8charbytes(name, bytePos);
        local c = name:sub(bytePos, bytePos + byteCount - 1);
        returnStr = returnStr .. (utf8_lc_uc[c] or c);
        bytePos = bytePos + byteCount;
    end
    return returnStr;
end
-- local testItem={[1]="плащ кардолана",[2]={1,6}};
-- local searchInput = "Плащ";

-- local searchTerm = toLower(searchInput);
-- if string.find(testItem[1], searchTerm) then
--   print("match: " .. addUppers(testItem[1], testItem[2]));
-- else
--   print("no match");
-- end
