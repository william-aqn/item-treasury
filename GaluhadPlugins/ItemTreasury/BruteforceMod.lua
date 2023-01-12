-- by DCRM
BruteforceVersion = "0.1";
BruteforceWindow = Turbine.UI.Lotro.Window();

BruteforceStartId = FIRSTID -- FIRSTID 1879049233
BruteforceEndId = LASTID -- LASTID 1879448522
BruteforceDb = _ITEMSDB

function BruteforceItem(itemIn)
	for i=BruteforceStartId,BruteforceEndId do
		local item = Utils.GetItemFromID(i);
		if item ~= nil then -- only add items that exist to the list, ignore null values.
			local curItemInfo = item:GetItemInfo();
			if string.find(curItemInfo:GetName(),"GNDN") == nil then  -- Ignore all GNDN's
                if curItemInfo:GetName() == itemIn:GetName() then
                    local inner = "NotExists"
                    if Windows.ExistsInDB(i) then
                        inner = BruteforceDb[i][1]
                    end

                    return "DB:["..inner.."]\nID:[" .. i .. "]\nSearch:[" .. itemIn:GetName() .. "]\nFound:[" .. curItemInfo:GetName() .. "]";
                end
			end
		end
	end
    return "Search [" .. itemIn:GetName() .. "] - not found"
end

function RegisterCommandsBruteforce()
	-- /it
	local itemCommand = Turbine.ShellCommand();
	function itemCommand:Execute(command,args)
		BruteforceWindow:SetVisible( not BruteforceWindow:IsVisible() );
	end
	function itemCommand:GetHelp()
		return "Put item from bag into bruteforce window";
	end
	function itemCommand:GetShortHelp()
		return "Put item into bruteforce window";
	end
	Turbine.Shell.AddCommand( "it", itemCommand);
end

function LoadBruteforceMod()
    local height = 250;
    BruteforceWindow:SetSize(300, height);
    BruteforceWindow:SetTop((Turbine.UI.Display:GetHeight() - height) / 2);
    BruteforceWindow:SetLeft((Turbine.UI.Display:GetWidth() - 300) / 4);
    BruteforceWindow:SetText("ID Bruteforce");
    BruteforceWindow:SetAllowDrop(true);
    BruteforceWindow:SetVisible(true);

    local searchCaption=Turbine.UI.Label()
    searchCaption:SetParent(BruteforceWindow)
    searchCaption:SetSize(300,height)
    searchCaption:SetPosition(10,45)

    function BruteforceWindow:DragEnter(args)
    end

    function BruteforceWindow:DragDrop(args)
        local item = args.DragDropInfo:GetShortcut():GetItem();
        searchCaption:SetText("Search start ...")
        local result = BruteforceItem(item)
        searchCaption:SetText(result)
        Turbine.Shell.WriteLine(result);
    end

    -- RegisterCommandsBruteforce();

    print("Inventory Bag Item ID Bruteforce v" ..  BruteforceVersion .. ", by DCRM");
    print("FirstID = " ..  FIRSTID .. "; LastId = " .. LASTID .. ";");
    print("Use command '/it' to show/hide the bruteforce window");
end
