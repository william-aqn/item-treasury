-- by DCRM
BruteforceVersion = "0.2";
BruteforceWindow = Turbine.UI.Lotro.Window();

BruteforceStartId = FIRSTID -- FIRSTID 1879049233
BruteforceEndId = LASTID -- LASTID 1879448522
BruteforceDb = _ITEMSDB
BruteforceRuDb = _RUITEMS
BruteforceRuDbVersion = RUVERSION
function BruteforceItem(itemIn)
    local inner
    local ruItem
    local itemInName = itemIn:GetName()
    for i = BruteforceStartId, BruteforceEndId do

        if Windows.ExistsInDB(i) and ExistsInRuDB(i) then
            if BruteforceRuDb[i][1] == itemInName then
               ruItem = BruteforceRuDb[i][1]
               inner = BruteforceDb[i][1]
               return "Результат:[" ..
               inner ..
               "]\nID:[" ..
               i .. "]\nЗапрос:[" .. ruItem .. "]";
            end
        end
    end
    return "Запрос [" .. itemInName .. "] - ничего не найдено"
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
                        i .. "]\nЗапрос:[" .. itemIn:GetName() .. "]\nНайдено:[" .. curItemInfo:GetName() .. "]";
                end
            end
        end
    end
    return "Запрос [" .. itemIn:GetName() .. "] - ничего не найдено"
end

function RegisterCommandsBruteforce()
    -- /it
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
    local height = 250;
    BruteforceWindow:SetSize(300, height);
    BruteforceWindow:SetTop((Turbine.UI.Display:GetHeight() - height) / 2);
    BruteforceWindow:SetLeft((Turbine.UI.Display:GetWidth() - 300) / 4);
    BruteforceWindow:SetText("ID Bruteforce");
    BruteforceWindow:SetAllowDrop(true);
    BruteforceWindow:SetVisible(true);

    local searchCaption = Turbine.UI.Label()
    searchCaption:SetParent(BruteforceWindow)
    searchCaption:SetSize(300, height)
    searchCaption:SetPosition(10, 45)
    searchCaption:SetText("Перетащите сюда предмет")

    function BruteforceWindow:DragEnter(args)
    end

    function BruteforceWindow:DragDrop(args)
        local item = args.DragDropInfo:GetShortcut():GetItem();
        searchCaption:SetText("Поиск ...")
        local result = BruteforceItem(item)
        searchCaption:SetText(result)
        Turbine.Shell.WriteLine(result);
    end

    RegisterCommandsBruteforce();

    print("RU БД версия " .. BruteforceRuDbVersion .. ", модификация версия " .. BruteforceVersion .. ", by DCRM");
    print("FirstID = " .. BruteforceStartId .. "; LastId = " .. BruteforceEndId .. ";");
    print("Используйте команду '/ru' что бы показать/скрыть окно перевода предметов");

end
