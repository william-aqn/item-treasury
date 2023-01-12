
function DrawScanWin()

	wScanWin = Turbine.UI.Lotro.Window();
	wScanWin:SetSize(SCREENWIDTH*0.5,SCREENHEIGHT*0.8);
	wScanWin:SetPosition(SETTINGS.SCANWIN.X,SETTINGS.SCANWIN.Y);
	wScanWin:SetText(PLUGINNAME..": ".._LABELS[20][LANGID]);
	wScanWin:SetHideF12(true);
	wScanWin:SetCloseEsc(true);
	--wScanWin:SetVisible(SETTINGS.SCANWIN.VISIBLE);
	--wScanWin:SetVisible(true);

	Utils.Onscreen(wScanWin);


	-- Search Header
	cScanSearchHolder = Turbine.UI.Control();
	cScanSearchHolder:SetParent(wScanWin);
	cScanSearchHolder:SetSize(450,20);
	cScanSearchHolder:SetPosition(40,60);
	--cScanSearchHolder:SetBackColor(Turbine.UI.Color.Blue);


	local lblStartID = NewWindowLabel(cScanSearchHolder,100,20,0,0,_LABELS[21][LANGID]);
	lblStartID:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight);

	txtStartID = NewWindowTextBox(cScanSearchHolder,100,20,lblStartID:GetLeft()+lblStartID:GetWidth()+10,0);
	txtStartID:SetText(LASTID+1);
	txtStartID:SetToolTip(_LABELS[25][LANGID]);

	txtStartID.FocusGained = function ()
		txtStartID:SetWantsKeyEvents(true);
	end
	txtStartID.FocusLost = function()
		txtStartID:SetWantsKeyEvents(false);
	end
	txtStartID.KeyDown = function(Sender,Args)
		if Args.Action == 162 then  -- Performs search when enter is pressed.
			DoScan(txtStartID:GetText());
			btnScanGo:Focus();
		end
	end
	txtStartID.TextChanged = function ()
		txtStartID:SetText(string.match(txtStartID:GetText(),"%f[%.%d]%d*%.?%d*%f[^%.%d%]]"));
		txtStartID:SetText(string.sub(txtStartID:GetText(),1,10));
	end


	btnScanGo = Turbine.UI.Lotro.Button();
	btnScanGo:SetParent(cScanSearchHolder);
	btnScanGo:SetWidth(60);
	btnScanGo:SetPosition(txtStartID:GetLeft()+txtStartID:GetWidth()+10,0);
	btnScanGo:SetText(_LABELS[4][LANGID]);

	btnScanGo.Click = function ()
		DoScan(txtStartID:GetText());
	end

	btnScanPrev = NewPagenateButton();
	btnScanPrev:SetParent(cScanSearchHolder);
	btnScanPrev:SetPosition(btnScanGo:GetLeft()+100,0);
	btnScanPrev:SetText("<<");
	btnScanPrev:SetToolTip(_TOOLTIPS[1][LANGID]);
	btnScanPrev:SetEnabled(true);

	btnScanPrev.Click = function ()
		txtStartID:SetText(LASTID+1);
		DoScan(LASTID+1);
	end


	local itemWidth = 160;
	local itemHeight = 90;
	local listLeftRightBuffer = 40;
	local listTopBuffer = 90;
	local listBottomBuffer = 50;

	local listTop = cScanSearchHolder:GetTop() + cScanSearchHolder:GetHeight() + listTopBuffer;
	local listLeft = listLeftRightBuffer;

	local listWidth = wScanWin:GetWidth() - (2*listLeftRightBuffer);
	local listHeight = wScanWin:GetHeight() - listTop - listBottomBuffer;

	local maxHor = math.floor(listWidth/itemWidth);
	local maxVer = math.floor(listHeight/itemHeight);

	listWidth = maxHor*itemWidth;
	listHeight = maxVer*itemHeight;

	wScanWin:SetWidth(listWidth+(2*listLeftRightBuffer));
	wScanWin:SetHeight(listTop+listHeight+listBottomBuffer);

	cScanSearchHolder:SetLeft( (wScanWin:GetWidth()/2) - (cScanSearchHolder:GetWidth()/2) );


	NewWindowLabel(wScanWin,listWidth,60,listLeft,listTop-70,_LABELS[23][LANGID]);


	lstScanResults = Turbine.UI.ListBox();
	lstScanResults:SetParent(wScanWin);
	lstScanResults:SetPosition(listLeft,listTop);
	lstScanResults:SetSize(listWidth,listHeight);
	lstScanResults:SetOrientation(Turbine.UI.Orientation.Horizontal);
	--lstScanResults:SetBackColor(Turbine.UI.Color.Red);
	lstScanResults["MaxHorizontal"] = maxHor;
	lstScanResults["MaxVertical"] = maxVer;
	lstScanResults["MaxItems"] = maxHor*maxVer;
	lstScanResults:SetMaxItemsPerLine(maxHor);

	chkScanSave = Turbine.UI.Lotro.CheckBox();
	chkScanSave:SetParent(wScanWin);
	chkScanSave:SetPosition(listLeft,listTop+listHeight+10);
	chkScanSave:SetSize(400,20);
	chkScanSave:SetText(" ".._LABELS[27][LANGID]);
	chkScanSave:SetFont(Turbine.UI.Lotro.Font.Verdana14);
	chkScanSave:SetForeColor(_COLORS[2]);
	chkScanSave:SetChecked(SETTINGS.SCANWIN.SAVE);
	chkScanSave:SetToolTip(_TOOLTIPS[10][LANGID]);

	chkScanSave.CheckedChanged = function ()
		SETTINGS.SCANWIN.SAVE = chkScanSave:IsChecked();
	end


	-- Window events
	wScanWin.PositionChanged = function()
		SETTINGS.SCANWIN.X = wScanWin:GetLeft();
		SETTINGS.SCANWIN.Y = wScanWin:GetTop();
	end

	wScanWin.VisibleChanged = function ()
		SETTINGS.SCANWIN.VISIBLE = wScanWin:IsVisible();
		if SETTINGS.SCANWIN.VISIBLE == false then wItemWin:SetVisible(false) end;
	end

end


function DoScan(startID,endID)

	if startID == nil then return end;
	if endID == nil then endID = startID + 5000 end;

	lstScanResults:ClearItems();

	local listCounter = 0;
	local listMax = lstScanResults.MaxItems;

	-- Needs some sort of catch to prevent never ending...
	-- Also needs to be limited by how many widgets the results list can hold - when the list is full then stop.

	local lastID = startID;

	for i=startID,endID do

		local item = Utils.GetItemFromID(i);
		lastID = i;

		if item ~= nil then -- only add items that exist to the list, ignore null values.

			local curItemInfo = item:GetItemInfo();

			if string.find(curItemInfo:GetName(),"GNDN") == nil then  -- Ignore all GNDN's

				local newWidget = GetItemScanDisplay(curItemInfo,i);
				lstScanResults:AddItem(newWidget);

				-- See if item exists in database, if not and save is checked, then add to saved database
				if ExistsInDB(i) == false and SETTINGS.SCANWIN.SAVE == true then
					local curItemTable = NewDBInfo(curItemInfo);
					if curItemTable ~= nil then
						_SAVEDITEMS[i] = curItemTable;
						_ITEMSDB[i] = curItemTable;
					end
				end


				-- Track how many are being added to the list, if it exceeds the max then stop loop.
				listCounter = listCounter + 1;
				if listCounter>= listMax then break end;
			end

		elseif isSkill(i) then -- if not an item then check if a skill

			local newWidget = GetSkillScanDisplay(i);
			lstScanResults:AddItem(newWidget);

			-- Track how many are being added to the list, if it exceeds the max then stop loop.
			listCounter = listCounter + 1;
			if listCounter>= listMax then break end;

		end

	end

	if listCounter == 0 then
		lstScanResults:AddItem(NewWarningLabel(nil,lstScanResults:GetWidth(),90,0,0,_LABELS[24][LANGID]));
	end

	txtStartID:SetText(lastID+1);

end


function GetItemScanDisplay(itemInfo,itemID)

	if itemInfo == nil then return end;


	local cItemContainer = Turbine.UI.Control();
	cItemContainer:SetSize(160,90);


	local cBack = Turbine.UI.Control();
	cBack:SetParent(cItemContainer);
	cBack:SetWidth(cItemContainer:GetWidth()-4);
	cBack:SetHeight(cItemContainer:GetHeight()-4);
	cBack:SetPosition(2,2);
	cBack:SetMouseVisible(false);
	cBack:SetBackColor(Turbine.UI.Color(0.06,0.06,0.06));

	local cPrintInfo = Turbine.UI.Control();
	cPrintInfo:SetParent(cItemContainer);
	cPrintInfo:SetSize(10,10);
	cPrintInfo:SetPosition(6,6);
	cPrintInfo:SetBackground(_IMAGES.ICONS.SHARE);
	cPrintInfo:SetBlendMode(4);
	cPrintInfo:SetToolTip(_TOOLTIPS[6][LANGID]);

	cPrintInfo.MouseClick = function()
		print(itemID .. " = " ..itemInfo:GetName());
	end;

	local lblID = Turbine.UI.Label();
	lblID:SetParent(cItemContainer);
	lblID:SetSize(75,15);
	lblID:SetPosition(cItemContainer:GetWidth()-lblID:GetWidth()-26,4);
	lblID:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight);
	lblID:SetFont(_FONTS[2]);
	lblID:SetForeColor(_COLORS[2]);
	lblID:SetMouseVisible(false);
	lblID:SetText(string.sub(itemID,1,5).." "..string.sub(itemID,6,-1));

	local cExistsFlag = Turbine.UI.Control();
	cExistsFlag:SetParent(cItemContainer);
	cExistsFlag:SetSize(10,10);
	cExistsFlag:SetPosition(144,6);
	cExistsFlag:SetBlendMode(4);

	if ExistsInDB(itemID) then
		cExistsFlag:SetBackground(_IMAGES.ICONS.FLAGTRUE);
		cExistsFlag:SetToolTip(_TOOLTIPS[8][LANGID]);
	else
		cExistsFlag:SetBackground(_IMAGES.ICONS.FLAGFALSE);
		cExistsFlag:SetToolTip(_TOOLTIPS[9][LANGID]);
	end


	local cItemInfo = NewItemInfo(itemID);
	cItemInfo:SetParent(cItemContainer);
	cItemInfo:SetPosition(4,20);

	local lblName = Turbine.UI.Label();
	lblName:SetParent(cItemContainer);
	lblName:SetPosition(43,cItemInfo:GetTop());
	lblName:SetSize(cBack:GetWidth()-2-lblName:GetLeft(),cItemInfo:GetHeight());
	lblName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	lblName:SetFont(_FONTS[2]);
	lblName:SetForeColor(_QUALITYCOLORS[itemInfo:GetQuality()]);
	lblName:SetMouseVisible(false);
	lblName:SetText(itemInfo:GetName());

	local lblCateg = Turbine.UI.Label();
	lblCateg:SetParent(cItemContainer);
	lblCateg:SetSize(cBack:GetWidth()-4,25);
	lblCateg:SetPosition(4,cBack:GetHeight()-25);
	lblCateg:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	lblCateg:SetFont(_FONTS[2]);
	lblCateg:SetForeColor(_COLORS[7]);
	lblCateg:SetMouseVisible(false);
	lblCateg:SetText(_CATEGORY[itemInfo:GetCategory()]);

	return cItemContainer;
end


function isSkill(decID)

	if decID == nil then return false end;

	local blExists = false;
	local itemHex = Utils.TO_HEX(decID);

	local qsSkill = Turbine.UI.Lotro.Quickslot();
	qsSkill:SetVisible(false);

	local function checkSkill() 	-- PCALL THIS incase item does not exist
		qsSkill:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Skill, "0x" .. itemHex));
	end
	if pcall(checkSkill) then
		blExists = true;
	end

	qsSkill = nill;
	return blExists;

end


function GetSkillScanDisplay(skillID)

	if skillID == nil then return end;

	local cItemContainer = Turbine.UI.Control();
	cItemContainer:SetSize(160,90);


	local cBack = Turbine.UI.Control();
	cBack:SetParent(cItemContainer);
	cBack:SetWidth(cItemContainer:GetWidth()-4);
	cBack:SetHeight(cItemContainer:GetHeight()-4);
	cBack:SetPosition(2,2);
	cBack:SetMouseVisible(false);
	cBack:SetBackColor(Turbine.UI.Color.Indigo);

	local cPrintInfo = Turbine.UI.Control();
	cPrintInfo:SetParent(cItemContainer);
	cPrintInfo:SetSize(10,10);
	cPrintInfo:SetPosition(6,6);
	cPrintInfo:SetBackground(_IMAGES.ICONS.SHARE);
	cPrintInfo:SetBlendMode(4);
	cPrintInfo:SetToolTip(_TOOLTIPS[6][LANGID]);

	cPrintInfo.MouseClick = function()
		print(skillID .. " = " .._LABELS[22][LANGID]);
	end;

	local lblID = Turbine.UI.Label();
	lblID:SetParent(cItemContainer);
	lblID:SetSize(75,15);
	lblID:SetPosition(cItemContainer:GetWidth()-lblID:GetWidth()-6,4);
	lblID:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight);
	lblID:SetFont(_FONTS[2]);
	lblID:SetForeColor(_COLORS[2]);
	--lblID:SetBackColor(Turbine.UI.Color.Red);
	lblID:SetMouseVisible(false);
	lblID:SetText(string.sub(skillID,1,5).." "..string.sub(skillID,6,-1));

	local qsSkill = Turbine.UI.Lotro.Quickslot();
	qsSkill:SetParent(cItemContainer);
	qsSkill:SetSize(36,36);
	qsSkill:SetPosition(4,20);
	qsSkill:SetZOrder(10000);
	qsSkill:SetVisible(true);
	qsSkill:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Skill, "0x" .. Utils.TO_HEX(skillID)));


	--[[	This doesn't work, at present there is no way to get skill info from a QS.
	local curSkill = qsSkill:GetShortcut():GetData();
	local curSkillInfo = curSkill:GetSkillInfo();

	local lblName = Turbine.UI.Label();
	lblName:SetParent(cItemContainer);
	lblName:SetPosition(43,qsSkill:GetTop());
	lblName:SetSize(cBack:GetWidth()-2-lblName:GetLeft(),qsSkill:GetHeight());
	lblName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	lblName:SetFont(_FONTS[2]);
	lblName:SetForeColor(_COLORS[7]);
	lblName:SetMouseVisible(false);
	lblName:SetText(curSkillInfo:GetName());
	--]]


	local lblCateg = Turbine.UI.Label();
	lblCateg:SetParent(cItemContainer);
	lblCateg:SetSize(cBack:GetWidth()-4,25);
	lblCateg:SetPosition(4,cBack:GetHeight()-25);
	lblCateg:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	lblCateg:SetFont(_FONTS[2]);
	lblCateg:SetForeColor(_COLORS[7]);
	lblCateg:SetMouseVisible(false);
	lblCateg:SetText(_LABELS[22][LANGID]);


	return cItemContainer;

end


function ExistsInDB(itemID)

	if itemID == nil or type(itemID) ~= 'number' then return false end;

	if _ITEMSDB[itemID] == nil then
		return false;
	else
		return true;
	end

end


function NewDBInfo(itemInfo)

	if itemInfo == nil then return end;

	local itemTable = {};

	local itemName = string.gsub(itemInfo:GetName(),"\n"," ");
	itemName = string.gsub(itemName,"  "," ");
	if string.find(itemName,"GNDN") ~= nil then return end;

	local itemDesc = string.gsub(itemInfo:GetDescription(),"\n"," ");
	itemDesc = string.gsub(itemDesc,"  "," ");
	itemDesc = string.gsub(itemDesc,"\"","'");
	itemDesc = string.gsub(itemDesc,"\n","");
	if string.find(itemDesc,"string table error") then itemDesc = "" end;

	itemTable[1] = itemName;
	itemTable[2] = itemDesc;
	itemTable[3] = itemInfo:GetCategory();
	itemTable[4] = itemInfo:GetQuality();

	return itemTable;

end
