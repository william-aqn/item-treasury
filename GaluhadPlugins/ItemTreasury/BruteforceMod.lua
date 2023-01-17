import("GaluhadPlugins.ItemTreasury.RuItems")
import("GaluhadPlugins.ItemTreasury.RuItemsSearch")
--import ("GaluhadPlugins.ItemTreasury.UTF")

-- by DCRM
BruteforceVersion = "0.4";
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
                label:SetText(BruteforceRuDb[itemID][1]..'\n'..itemInfo[1]); 
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

--debugPring = true
function BruteforceSearch(i, searchName, match)
    if match then
        return match
    end
    if not ExistsInRuDB(i) then
        return false
    end
    local match = true;
    local nameStr = string.upper(BruteforceRuDb[i][1]);
    for wordKey, wordVal in pairs(searchName) do
        if string.find(nameStr, wordVal) == nil then
            match = false;
        end
    end

    -- Поиск в нижнем регистре по отдельной базе
    if not match then
        match = true;
        local nameStr = string.upper(BruteforceRuDbSearch[i][1]);
        for wordKey, wordVal in pairs(searchName) do
            if string.find(nameStr, wordVal) == nil then
                match = false;
            end
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

    function BruteforceWindow:DragEnter(args)
    end

    function BruteforceWindow:DragDrop(args)
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

    RegisterCommandsBruteforce();

    print("RU БД версия " .. BruteforceRuDbVersion .. ", модификация версия " ..
        BruteforceVersion .. ", by DCRM");
    print("FirstID = " .. BruteforceStartId .. "; LastId = " .. BruteforceEndId .. ";");
    print("Используйте команду '/ru' что бы показать/скрыть окно перевода предметов");

end

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
