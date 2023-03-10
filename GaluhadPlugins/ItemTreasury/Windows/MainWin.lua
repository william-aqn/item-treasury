
function DrawMainWin()

	wMainWin = Turbine.UI.Lotro.Window();
	wMainWin:SetMinimumSize(900,725);
	wMainWin:SetSize(SCREENWIDTH*0.5,SCREENHEIGHT*0.5);
	wMainWin:SetPosition(SETTINGS.MAINWIN.X,SETTINGS.MAINWIN.Y);
	wMainWin:SetText(PLUGINNAME);
	wMainWin:AssignToDesktopIcon();
	wMainWin:SetHideF12(true);
	wMainWin:SetCloseEsc(true);
	wMainWin:SetVisible(SETTINGS.MAINWIN.VISIBLE);

	Utils.Onscreen(wMainWin);

	-- NewWindowLabel(parent,width,height,left,top,text)
	lblDatabase = NewWindowLabel(wMainWin,80,18,60,40,_LABELS[11][LANGID]..":");

	ddDatabase = Utils.DropDown({_LABELS[13][LANGID],_LABELS[12][LANGID].." "..NEWVERSION,_LABELS[26][LANGID],_LABELS[28][LANGID]});
	ddDatabase:SetParent(wMainWin);
	ddDatabase:SetPosition(lblDatabase:GetLeft()+lblDatabase:GetWidth(),lblDatabase:GetTop());
	ddDatabase:SetWidth(120);
	ddDatabase:SetAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	ddDatabase["SearchID"] = 1;
	ddDatabase.ItemChanged = function (Sender,Args)
		ddDatabase["SearchID"] = Args.Index;
	end

	local check_left = ddDatabase:GetLeft()+ddDatabase:GetWidth()+20;

	--_ITEMQUALITYZORDER
	chkQuality = {};
	for i=0, 5 do
		local zorder = _ITEMQUALITYZORDER[i];
		local check_padding = 10;
		local check_width = _ITEMQUALITY[zorder][2];

		chkQuality[zorder] = Turbine.UI.Lotro.CheckBox();
		chkQuality[zorder]:SetParent(wMainWin);
		chkQuality[zorder]:SetTop(lblDatabase:GetTop());
		chkQuality[zorder]:SetLeft(check_left);
		chkQuality[zorder]:SetWidth(check_width);
		chkQuality[zorder]:SetHeight(18);
		chkQuality[zorder]:SetFont(Turbine.UI.Lotro.Font.Verdana14);
		chkQuality[zorder]:SetText(" " .. _ITEMQUALITY[zorder][1]);
		chkQuality[zorder]:SetForeColor(_QUALITYCOLORS[zorder]);
		chkQuality[zorder]:SetChecked(true);

		check_left = check_left + check_width + check_padding;
	end

	-- Search Header
	cSearchHolder = Turbine.UI.Control();
	cSearchHolder:SetParent(wMainWin);
	cSearchHolder:SetSize(813,30);
	cSearchHolder:SetPosition((wMainWin:GetWidth()/2)-(cSearchHolder:GetWidth()/2),70);
	cSearchHolder:SetBackground(_IMAGES.BACKGROUNDS.HEADER);
	cSearchHolder:SetBlendMode(4);

	txtSearch = NewWindowTextBox(cSearchHolder,250,20,36,5);
	--txtSearch:SetText("1879368415");
	txtSearch.FocusGained = function ()
		txtSearch:SetWantsKeyEvents(true);
	end
	txtSearch.FocusLost = function()
		txtSearch:SetWantsKeyEvents(false);
	end
	txtSearch.KeyDown = function(Sender,Args)
		if Args.Action == 162 then  -- Performs search when enter is pressed.
			btnGo:Focus();
			PrepareSearch();
		end
	end


	local _cats = {};
	for k,v in pairs(_CATEGORY) do
		table.insert(_cats,v);
	end
	table.sort(_cats);
	table.insert(_cats,1,_LABELS[3][LANGID]);
	ddCat = Utils.DropDown(_cats);
	ddCat:SetParent(cSearchHolder);
	ddCat:SetPosition(txtSearch:GetLeft()+txtSearch:GetWidth()+20,txtSearch:GetTop());
	ddCat:SetWidth(250);
	ddCat:SetAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	ddCat["SearchID"] = -1;
	ddCat:SetMaxItems(15);
	ddCat.ItemChanged = function (Sender,Args)
		if Args.Index == 1 then
			ddCat["SearchID"] = -1;
		else
			ddCat["SearchID"] = GetCategoryID(Args.Text);
		end
	end

	btnGo = Turbine.UI.Lotro.Button();
	btnGo:SetParent(cSearchHolder);
	btnGo:SetWidth(80);
	btnGo:SetPosition(ddCat:GetLeft()+ddCat:GetWidth()+20,txtSearch:GetTop());
	btnGo:SetText(_LABELS[4][LANGID]);

	btnGo.Click = function ()
		PrepareSearch();
	end

	btnReset = Turbine.UI.Lotro.Button();
	btnReset:SetParent(cSearchHolder);
	btnReset:SetWidth(90);
	btnReset:SetPosition(btnGo:GetLeft()+btnGo:GetWidth()+30,txtSearch:GetTop());
	btnReset:SetText(_LABELS[5][LANGID]);

	btnReset.Click = function ()
		ClearSearchControls();
	end

	local listWidth = math.floor((wMainWin:GetWidth()-60)/160)*160;
	lblNumResults = NewWindowLabel(wMainWin,700,18,30,cSearchHolder:GetTop()+cSearchHolder:GetHeight()+10);

	ddSortOption = Utils.DropDown({_SORTOPTION[1][LANGID],_SORTOPTION[2][LANGID]});
	ddSortOption:SetParent(wMainWin);
	ddSortOption:SetPosition(cSearchHolder:GetLeft()+cSearchHolder:GetWidth()-120,lblNumResults:GetTop());
	ddSortOption:SetWidth(120);
	ddSortOption:SetAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	ddSortOption.ItemChanged = function (Sender,Args)
		RefreshResultsView();
	end

	ddSortBy = Utils.DropDown({_SORTBY[1][LANGID],_SORTBY[2][LANGID]});
	ddSortBy:SetParent(wMainWin);
	ddSortBy:SetPosition(ddSortOption:GetLeft()-130,lblNumResults:GetTop());
	ddSortBy:SetWidth(120);
	ddSortBy:SetAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	ddSortBy.ItemChanged = function (Sender,Args)
		RefreshResultsView();
	end

	lblSort = NewWindowLabel(wMainWin,80,18,ddSortBy:GetLeft()-90,ddSortBy:GetTop(),_LABELS[31][LANGID]..":");
	lblSort:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight);

	lstResults = Turbine.UI.ListBox();
	lstResults:SetParent(wMainWin);
	lstResults:SetPosition(30,lblNumResults:GetTop()+25);
	lstResults:SetSize(listWidth,wMainWin:GetHeight()-lstResults:GetTop()-100);
	lstResults:SetOrientation(Turbine.UI.Orientation.Horizontal);

	lstResults:SetLeft((wMainWin:GetWidth()/2)-(listWidth/2));
	lblNumResults:SetLeft(lstResults:GetLeft());


	-- pagenate controls -------------------------------------------------------------------
	backPageControls = Turbine.UI.Control();
	backPageControls:SetParent(wMainWin);
	backPageControls:SetSize(450,30);
	backPageControls:SetPosition((wMainWin:GetWidth()/2)-(backPageControls:GetWidth()/2)-30,wMainWin:GetHeight()-backPageControls:GetHeight()-55);
	backPageControls:SetBackground(_IMAGES.BACKGROUNDS.PAGENATE);
	--backPageControls:SetBackColor(_COLORS[2]);
	backPageControls:SetBlendMode(4);

	cPageHolder = Turbine.UI.Control();
	cPageHolder:SetParent(backPageControls);
	cPageHolder:SetSize(backPageControls:GetWidth()-30,20);
	cPageHolder:SetPosition(15,5);

	cNumHolder = NewItemContainer(140,20);
	cNumHolder:SetParent(cPageHolder);
	cNumHolder:SetPosition((cPageHolder:GetWidth()/2)-(cNumHolder:GetWidth()/2),0);

	txtPageNum = NewWindowTextBox(cNumHolder,60,18,(cNumHolder:GetWidth()/2)-62,2,"");
	txtPageNum:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight);
	txtPageNum:SetFont(_FONTS[3]);
	RegisterEditEvent(txtPageNum);

	txtPageNum.KeyDown = function (Sender,Args)
		if Args.Action==162 then
			PAGE = string.gsub(txtPageNum:GetText(),"[%,]","");
			PAGE = math.floor(tonumber(PAGE));
			PagenateResults(PAGE);
		end
	end

	lblPageNum = Turbine.UI.Label();
	lblPageNum:SetParent(cNumHolder);
	lblPageNum:SetSize(60,18);
	lblPageNum:SetPosition((cNumHolder:GetWidth()/2)+2,2);
	lblPageNum:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	lblPageNum:SetFont(_FONTS[3]);
	lblPageNum:SetFontStyle(Turbine.UI.FontStyle.Outline);
	lblPageNum:SetOutlineColor(_COLORS[6]);
	lblPageNum:SetForeColor(_COLORS[1]);
	lblPageNum:SetMultiline(false);
	lblPageNum:SetText("");

	btnFirst = NewPagenateButton();
	btnFirst:SetParent(cPageHolder);
	btnFirst:SetPosition(0,0);
	btnFirst:SetText("<<");
	btnFirst:SetToolTip(_TOOLTIPS[1][LANGID]);
	btnFirst:SetEnabled(false);

	btnFirst.Click = function ()
		PAGE = 1;
		PagenateResults(PAGE);
	end

	btnBackTen = NewPagenateButton();
	btnBackTen:SetParent(cPageHolder);
	btnBackTen:SetPosition(btnFirst:GetLeft()+btnFirst:GetWidth()+5,0);
	btnBackTen:SetText("-10");
	btnBackTen:SetToolTip(_TOOLTIPS[13][LANGID]);
	btnBackTen:SetEnabled(false);

	btnBackTen.Click = function ()
		PAGE = PAGE - 10;
		PagenateResults(PAGE);
	end

	btnPrev = NewPagenateButton();
	btnPrev:SetParent(cPageHolder);
	btnPrev:SetPosition(btnBackTen:GetLeft()+btnBackTen:GetWidth()+5,0);
	btnPrev:SetText("<");
	btnPrev:SetToolTip(_TOOLTIPS[2][LANGID]);
	btnPrev:SetEnabled(false);

	btnPrev.Click = function ()
		PAGE = PAGE - 1;
		PagenateResults(PAGE);
	end


	btnLast = NewPagenateButton();
	btnLast:SetParent(cPageHolder);
	btnLast:SetPosition(cPageHolder:GetWidth()-btnLast:GetWidth(),0);
	btnLast:SetText(">>");
	btnLast:SetToolTip(_TOOLTIPS[4][LANGID]);
	btnLast:SetEnabled(false);

	btnLast.Click = function ()
		PAGE = -1;
		PagenateResults(PAGE);
	end

	btnJumpTen = NewPagenateButton();
	btnJumpTen:SetParent(cPageHolder);
	btnJumpTen:SetPosition(btnLast:GetLeft()-btnLast:GetWidth()-5,0);
	btnJumpTen:SetText("+10");
	btnJumpTen:SetToolTip(_TOOLTIPS[12][LANGID]);
	btnJumpTen:SetEnabled(false);

	btnJumpTen.Click = function ()
		PAGE = PAGE + 10;
		PagenateResults(PAGE);
	end

	btnNext = NewPagenateButton();
	btnNext:SetParent(cPageHolder);
	btnNext:SetPosition(btnJumpTen:GetLeft()-btnJumpTen:GetWidth()-5,0);
	btnNext:SetText(">");
	btnNext:SetToolTip(_TOOLTIPS[3][LANGID]);
	btnNext:SetEnabled(false);

	btnNext.Click = function ()
		PAGE = PAGE + 1;
		PagenateResults(PAGE);
	end

	-- Scanner button
	cScanButton = Turbine.UI.Control();
	cScanButton:SetParent(wMainWin);
	cScanButton:SetSize(30,30);
	cScanButton:SetPosition(backPageControls:GetLeft()+backPageControls:GetWidth()+30,backPageControls:GetTop());
	cScanButton:SetBackground(_IMAGES.ICONS.SCANICON);
	cScanButton:SetBlendMode(4);
	cScanButton:SetToolTip(_TOOLTIPS[7][LANGID]);

	cScanButton.MouseClick = function()
		wScanWin:SetVisible(true);
		wScanWin:Activate();
	end


	-- List option controls
	cButtonHolder = Turbine.UI.Control();
	cButtonHolder:SetParent(wMainWin);

	btnSelectAll = Turbine.UI.Lotro.Button();
	btnSelectAll:SetParent(cButtonHolder);
	btnSelectAll:SetWidth(120);
	btnSelectAll:SetPosition(0,0);
	btnSelectAll:SetText(_LABELS[6][LANGID]);
	btnSelectAll.Click = function ()
		SelectAll();
	end

	btnSelectNone = Turbine.UI.Lotro.Button();
	btnSelectNone:SetParent(cButtonHolder);
	btnSelectNone:SetWidth(120);
	btnSelectNone:SetPosition(btnSelectAll:GetLeft()+btnSelectAll:GetWidth()+10,0);
	btnSelectNone:SetText(_LABELS[7][LANGID]);
	btnSelectNone.Click = function ()
		SelectNone();
	end

	btnListID = Turbine.UI.Lotro.Button();
	btnListID:SetParent(cButtonHolder);
	btnListID:SetWidth(110);
	btnListID:SetPosition(btnSelectNone:GetLeft()+btnSelectNone:GetWidth()+20,0);
	btnListID:SetText(_LABELS[10][LANGID]);
	btnListID.Click = function ()
		ListSelectedIDs();
	end

	btnList = Turbine.UI.Lotro.Button();
	btnList:SetParent(cButtonHolder);
	btnList:SetWidth(110);
	btnList:SetPosition(btnListID:GetLeft()+btnListID:GetWidth()+10,0);
	btnList:SetText(_LABELS[8][LANGID]);
	btnList.Click = function ()
		ListSelectedFull();
	end

	btnDelete = Turbine.UI.Lotro.Button();
	btnDelete:SetParent(cButtonHolder);
	btnDelete:SetWidth(110);
	btnDelete:SetPosition(btnList:GetLeft()+btnList:GetWidth()+10,0);
	btnDelete:SetText(_LABELS[29][LANGID]);
	btnDelete:SetEnabled(false);
	btnDelete.Click = function ()
		DeleteSelected();
	end

	cButtonHolder:SetSize(btnDelete:GetLeft()+btnDelete:GetWidth(),25);
	cButtonHolder:SetPosition((wMainWin:GetWidth()/2)-(cButtonHolder:GetWidth()/2),backPageControls:GetTop()+45);

	-- Window events
	wMainWin.PositionChanged = function()
		SETTINGS.MAINWIN.X = wMainWin:GetLeft();
		SETTINGS.MAINWIN.Y = wMainWin:GetTop();
	end

	wMainWin.VisibleChanged = function ()
		SETTINGS.MAINWIN.VISIBLE = wMainWin:IsVisible();
		if SETTINGS.MAINWIN.VISIBLE == false then wItemWin:SetVisible(false) end;
	end

end


function GetCategoryID(text)
	if text == nil then return end;
	local ID = -1;
	for k,v in pairs (_CATEGORY) do
		if v == text then return k end;
	end
	return ID;
end


function PrepareSearch()

	_dbTable = {};
	FROMSAVED = false;

	if ddDatabase.SearchID == 2 then -- update database
		_dbTable = _NEWITEMS;
	elseif ddDatabase.SearchID == 3 then -- saved items database
		_dbTable = _SAVEDITEMS;
		FROMSAVED = true;
	elseif ddDatabase.SearchID == 4 then -- favourite items database
		_dbTable = _FAVITEMS;
	else
		_dbTable = _ITEMSDB; -- full database
	end

	btnDelete:SetEnabled(FROMSAVED);

	local searchString = txtSearch:GetText();

	-- if search is a number then look for ID.
	if tonumber(searchString) ~= nil then
		local itemID = tonumber(searchString);
		_SEARCHRESULTS = {};
		if _ITEMSDB[itemID] ~= nil then _SEARCHRESULTS = {itemID} end;
		PAGE = 1;
		Windows.PagenateResults(PAGE);
		return;
	end

	local searchName = BriteforcePrepareSearchName(searchString);
	local searchStr = string.upper(StripAccent(searchString));
	for w in string.gmatch(searchStr, "%a+") do
		table.insert(searchName,w);
	end
	lstResults:ClearItems();
	lblNumResults:SetText("");
	Utils.ClearTable(_SEARCHRESULTS);
	local searchCat = ddCat.SearchID;

	for k,v in pairs (_dbTable) do

		--local doesMatch = false; -- Assumes false until it meets a parameter that matches
		--if #v == 0 then doesMatch = false end; -- prevents searching empty id fields.


		--if doesMatch == false and searchCat ~= nil and searchCat ~= -1 then
		--	if v[3] == searchCat then doesMatch = true end;
		--end

		-- Search category match
		local catMatch = false;
		if searchCat == -1 then -- all
			catMatch = true;
		else
			if v[3] == searchCat then catMatch = true end;
		end

		-- Item Quality Match ~~ v[4] = category ID

		-- chkQuality[i].QualityID
		local qualityMatch = false;

		if v[4] == nil or chkQuality[v[4]]:IsChecked() == true then qualityMatch = true end;


		-- Item name
		local nameMatch = false;
		if searchName == nil then nameMatch = true end;

		if catMatch == true and qualityMatch == true and searchName ~= nil then
			local match = true;
			local nameStr = string.upper(StripAccent(v[1]));
			for wordKey,wordVal in pairs(searchName) do
				if string.find(nameStr,wordVal) == nil then
					match = false;
				end
			end
			-- RU DB search
			nameMatch = BruteforceSearch(k, searchName, match);
		end

		-- Item description
		local descMatch = false;
		if searchName == nil then descMatch = true end;

		if catMatch == true and qualityMatch == true and searchName ~= nil and nameMatch == false then -- only search description if name doesn't match
			local match = true;
			local nameStr = string.upper(StripAccent(v[2]));
			for wordKey,wordVal in pairs(searchName) do
				if string.find(nameStr,wordVal) == nil then
					match = false;
				end
			end
			descMatch = match;
		end

		if catMatch == true and qualityMatch == true and (nameMatch == true or descMatch == true) then
			table.insert(_SEARCHRESULTS,k);
		end

		-- Item Quality


	end
	_SEARCHRESULTS = SortResults(_SEARCHRESULTS);
	PAGE = 1;
	PagenateResults(PAGE);
end


function RefreshResultsView()
	-- this function is called when the sort dropdown is changed
	_SEARCHRESULTS = SortResults(_SEARCHRESULTS);
	PagenateResults(PAGE);
end


function SortResults(_idTable)

	-- _idTable of unsorted matching search results
	-- e.g. _idTable = {[1]=1879447837;[2]=18794478868;};
	if _idTable == nil then return {} end;

	-- local sortTypeA = 1; -- by name
	-- local sortTypeA = 2; -- by ID number
	--local sortTypeA = 1;
	local sortTypeA = ddSortBy:GetIndex();

	-- local sortTypeB = 1; -- ascending order (low to high)
	-- local sortTypeB = 2; -- descending order (high to low);
	--local sortTypeB = 1;
	local sortTypeB = ddSortOption:GetIndex();


	local numResults = table.getn(_idTable);
	local _sortedIDs = {};
	for i=1,numResults do
		if sortTypeA == 1 then -- by name
			local itemName = string.lower(StripAccent(_dbTable[_idTable[i]][1])); -- push item name into lower case and remove accents
			itemName = string.gsub(itemName,"\'",""); -- strip away any ' marks.
			itemName = string.gsub(itemName,"\"",""); -- strip away any " marks.
			itemName = string.gsub(itemName,"-"," "); -- strip away any - and replace with a space. -- these all strip text so sorting can be even

			table.insert(_sortedIDs,{["id"]=_idTable[i];["val"]=itemName;});
		else -- by ID number
			table.insert(_sortedIDs,{["id"]=_idTable[i];["val"]=_idTable[i];});
		end
	end
	_idTable = {};

	local sort_func = function(a,b)
		if sortTypeB == 1 then -- ascending
			return a.val < b.val;
		else -- descending
			return a.val > b.val;
		end
	end

	table.sort(_sortedIDs,sort_func);
	for k,v in ipairs(_sortedIDs) do
		table.insert(_idTable,v.id);
	end
	_sortedIDs = nil;
	return _idTable;
end


function PagenateResults(pageNum)

	if pageNum == nil then pageNum = 1 end;

	lstResults:ClearItems();

	local itemWidth = 160;
	local itemHeight = 90;

	local numResults = table.getn(_SEARCHRESULTS);
	local maxRows = math.floor(lstResults:GetHeight()/itemHeight); -- avg height
	local maxCols = math.floor(lstResults:GetWidth()/itemWidth);
	local maxPerPage = maxRows*maxCols;
	local pages = math.ceil(numResults/maxPerPage);
	lstResults:SetMaxItemsPerLine(maxCols);

	if pageNum == -1 or pageNum > pages then -- used as id for last page when button is pressed
		pageNum = pages;
		PAGE = pageNum;
	end

	if pages == 0 then
		txtPageNum:SetText("0");
		lblPageNum:SetText("/0");
		lblNumResults:SetText(_LABELS[1][LANGID] .. ": 0");
	else
		txtPageNum:SetText(Utils.comma_value(pageNum));
		lblPageNum:SetText("/"..Utils.comma_value(pages));
		local first = ((pageNum-1)*maxPerPage)+1;
		local last = pageNum*maxPerPage;
		if last>numResults then last = numResults end;
		lblNumResults:SetText(_LABELS[1][LANGID] .. ": " .. Utils.comma_value(numResults) .. "  " .. _LABELS[2][LANGID] .. ": " .. Utils.comma_value(first).." - "..Utils.comma_value(last));
	end

	local startPage = 1 + ((pageNum-1)*maxPerPage);
	local endPage = startPage+maxPerPage-1;

	for i=startPage, endPage do
		if i>numResults then break end;
		local cItemInfo = GetItemInfoDisplay(_SEARCHRESULTS[i],_dbTable);
		lstResults:AddItem(cItemInfo);
	end

	lstResults:EnsureVisible(1); -- scrolls to top

	-- Handle button states
	-- First & Prev
	if pageNum == 1 or pages == 0 then
		btnPrev:SetEnabled(false);
		btnFirst:SetEnabled(false);
	else
		btnPrev:SetEnabled(true);
		btnFirst:SetEnabled(true);
	end
	-- Next & Last
	if pageNum == pages or pages == 0 then
		btnNext:SetEnabled(false);
		btnLast:SetEnabled(false);
	else
		btnNext:SetEnabled(true);
		btnLast:SetEnabled(true);
	end
	-- btnJumpTen
	if pageNum > (pages-10) then
		btnJumpTen:SetEnabled(false);
	else
		btnJumpTen:SetEnabled(true);
	end
	-- btnBackTen
	if pageNum < 11 then
		btnBackTen:SetEnabled(false);
	else
		btnBackTen:SetEnabled(true);
	end
end


function GetItemInfoDisplay(itemID)

	if itemID == nil then return end;

	local itemInfo = _dbTable[itemID];

	local cItemContainer = Turbine.UI.Control();
	cItemContainer:SetSize(160,90);
	cItemContainer["Selected"] = false;
	cItemContainer["ItemID"] = itemID;
	cItemContainer["ItemHex"] = tonumber("0x"..Utils.TO_HEX(itemID));
	cItemContainer["ItemName"] = itemInfo[1];

	if _SELECTEDSCANS[itemID] ~= nil then cItemContainer.Selected = true end;

	local cBack = Turbine.UI.Control();
	cBack:SetParent(cItemContainer);
	cBack:SetWidth(cItemContainer:GetWidth()-4);
	cBack:SetHeight(cItemContainer:GetHeight()-4);
	cBack:SetPosition(2,2);
	cBack:SetMouseVisible(false);
	cItemContainer["Back"] = cBack;

	if cItemContainer.Selected == true then
		cBack:SetBackColor(_COLORS[5]);
	else
		cBack:SetBackColor(Turbine.UI.Color(0.06,0.06,0.06));
	end

	local txtQty = NewWindowTextBox(cItemContainer,38,16,4,4,"1");
	txtQty:SetFont(_FONTS[2]);
	txtQty:SetForeColor(_COLORS[2]);
	txtQty:SetToolTip(_TOOLTIPS[5][LANGID]);

	local btnFav = NewCustomButton(15,15,_IMAGES.ICONS.BOOKMARK_SELECTED_NORMAL,_IMAGES.ICONS.BOOKMARK_SELECTED_OVER,_IMAGES.ICONS.BOOKMARK_UNSELECTED_NORMAL,_IMAGES.ICONS.BOOKMARK_UNSELECTED_OVER,cItemContainer);
	btnFav:SetPosition(52,4);

	-- determine if button should be selected and update icon accordingly
	if _FAVITEMS[itemID] ~= nil then btnFav:SetSelected(true) end;

	local btnFavClick = function()
		if btnFav:IsSelected() then
			-- add to fav database
			_FAVITEMS[itemID] = itemInfo;
		else
			-- remove from fav database
			_FAVITEMS[itemID] = nil;
		end
	end

	AddCallback(btnFav,"MouseClick",btnFavClick);

	local lblID = Turbine.UI.Label();
	lblID:SetParent(cItemContainer);
	lblID:SetSize(75,15);
	lblID:SetPosition(cItemContainer:GetWidth()-lblID:GetWidth()-4,4);
	lblID:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight);
	lblID:SetFont(_FONTS[2]);
	lblID:SetForeColor(_COLORS[2]);
	--lblID:SetBackColor(Turbine.UI.Color.Red);
	lblID:SetMouseVisible(false);
	lblID:SetText(string.sub(itemID,1,5).." "..string.sub(itemID,6,-1));

	local cItemInfo = NewItemInfo(itemID);
	cItemInfo:SetParent(cItemContainer);
	cItemInfo:SetPosition(4,20);

	local lblName = Turbine.UI.Label();
	lblName:SetParent(cItemContainer);
	lblName:SetPosition(43,cItemInfo:GetTop());
	lblName:SetSize(cBack:GetWidth()-2-lblName:GetLeft(),cItemInfo:GetHeight());
	lblName:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	lblName:SetFont(_FONTS[2]);
	lblName:SetForeColor(_QUALITYCOLORS[itemInfo[4]]);
	lblName:SetMouseVisible(false);
	BruteforceTextOverride(lblName, itemInfo, itemID)
	--lblName:SetText(itemInfo[1]);

	local lblCateg = Turbine.UI.Label();
	lblCateg:SetParent(cItemContainer);
	lblCateg:SetSize(cBack:GetWidth()-4,25);
	lblCateg:SetPosition(4,cBack:GetHeight()-25);
	lblCateg:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	lblCateg:SetFont(_FONTS[2]);
	lblCateg:SetForeColor(_COLORS[7]);
	lblCateg:SetMouseVisible(false);
	lblCateg:SetText(_CATEGORY[itemInfo[3]]);

	txtQty.KeyDown = function(Sender,Args)
		if Args.Action == 162 then
			if tonumber(txtQty:GetText()) then
				cItemInfo:SetQuantity(tonumber(txtQty:GetText()));
				cItemInfo:Focus();
			else
				Utils.MessageBox(_LABELS[14][LANGID]);
			end
		end
	end

	txtQty.FocusLost = function(Sender,Args)
		if tonumber(txtQty:GetText()) then
			cItemInfo:SetQuantity(tonumber(txtQty:GetText()));
			cItemInfo:Focus();
		else
			Utils.MessageBox(_LABELS[14][LANGID]);
		end
	end

	cItemContainer.MouseClick = function ()
		cItemContainer.Selected = not cItemContainer.Selected;
		if cItemContainer.Selected == true then
			cBack:SetBackColor(_COLORS[5]);
			_SELECTEDSCANS[itemID] = itemInfo[1];
		else
			cBack:SetBackColor(Turbine.UI.Color(0.06,0.06,0.06));
			_SELECTEDSCANS[itemID] = nil;
		end
		ExplorerSetItem(itemID);
	end

	return cItemContainer;
end


function CheckMissingCats(_table)
	-- e.g. [251] = "251";
	local _missing = {};
	for k,v in pairs(_table) do
		if v[3] ~= nil and _CATEGORY[v[3]] == nil and _missing[v[3]] == nil then
			_missing[v[3]] = v[3];
			print(v[3]);
		end
	end

	-- Print the table
	for i=1,1000 do
		if _missing[i] ~= nil then
			Turbine.Shell.WriteLine("<rgb=#FFFFFF>[".. i .."] = \"" .. i .. "\";</rgb>");
		end
	end
end


function SelectAll()
	for i=1, lstResults:GetItemCount() do
		local cItemContainer = lstResults:GetItem(i);
		cItemContainer.Selected = true;
		cItemContainer.Back:SetBackColor(_COLORS[5]);
		_SELECTEDSCANS[cItemContainer.ItemID] = cItemContainer.ItemName;
	end
end


function SelectNone()
	for i=1, lstResults:GetItemCount() do
		local cItemContainer = lstResults:GetItem(i);
		cItemContainer.Selected = false;
		cItemContainer.Back:SetBackColor(Turbine.UI.Color(0.06,0.06,0.06));
		_SELECTEDSCANS[cItemContainer.ItemID] = nil;
	end
end


function ListSelectedFull()

	if CheckForSelectedItems() == false then
		Utils.MessageBox(_STRINGS[1][4][LANGID]);
		return;
	end

	local _sort = {};
	for k,v in pairs (_SELECTEDSCANS) do table.insert(_sort,k) end;
	table.sort(_sort);

	local str = "<rgb=#FFA500>".._LABELS[9][LANGID]..":</rgb>";
	for k,v in ipairs (_sort) do
		str = str.."\n["..v.."] = \"".._SELECTEDSCANS[v].."\";";
	end

	print(str);

	SelectNone();
	_SELECTEDSCANS = {};
end


function DeleteSelected()

	if CheckForSelectedItems() == false then
		Utils.MessageBox(_STRINGS[1][4][LANGID]);
		return;
	end

	-- Check before deleting
	local tempMsg = Utils.MessageBox(_LABELS[30][LANGID],"MBYESNO");
	tempMsg.ButtonClick = function (sender,args) -- Event executed when a button is pressed.. args returns a table with the value of the button pressed
		if args.Button == "MBYES" then
			for k,v in pairs(_SELECTEDSCANS) do
				if _SAVEDITEMS[k] ~= nil then _SAVEDITEMS[k] = nil end;
				if _ITEMSDB[k] ~= nil then _ITEMSDB[k] = nil end;
			end
			PrepareSearch();
		end
	end

end


function ListSelectedIDs()

	if CheckForSelectedItems() == false then
		Utils.MessageBox(_STRINGS[1][4][LANGID]);
		return;
	end

	local _sort = {};
	for k,v in pairs (_SELECTEDSCANS) do table.insert(_sort,k) end;
	table.sort(_sort);

	local str = "<rgb=#FFA500>".._LABELS[9][LANGID]..":\n</rgb>";
	for k,v in ipairs (_sort) do
		str = str..v..",";
	end

	str = string.sub(str,1,-2);

	print(str);

	SelectNone();
	_SELECTEDSCANS = {};
end


function CheckForSelectedItems()
	for k,v in pairs(_SELECTEDSCANS) do return true end;
	return false;
end


function ClearSearchControls()
	txtSearch:SetText("");
	ddCat:SetText(_LABELS[3][LANGID]);
	ddCat["SearchID"] = -1;
	for i=0,5 do
		chkQuality[i]:SetChecked(true);
	end
end
