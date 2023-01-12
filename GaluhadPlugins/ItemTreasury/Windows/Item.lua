
function DrawItem()

	local parentWidth = 300;
	local parentHeight = 300;
	local defaultItem = 1879049233;

	wItemWin = Turbine.UI.Lotro.Window();
	wItemWin:SetSize(parentWidth,parentHeight);
	wItemWin:SetPosition(SETTINGS.ITEMWIN.X,SETTINGS.ITEMWIN.Y);
	wItemWin:SetText(PLUGINNAME);
	wItemWin:SetVisible(false);

	Utils.Onscreen(wItemWin);

	cItemInfoControl = NewItemInfo(defaultItem);
	cItemInfoControl:SetParent(wItemWin);
	cItemInfoControl:SetPosition(20,50);

	-- Item Name --
	tItemName = NewWindowTextBox(wItemWin,214,36,cItemInfoControl:GetLeft()+46,cItemInfoControl:GetTop(),"");
	tItemName:SetMultiline(true);
	tItemName.FocusGained = function ()
		tItemName:SetWantsKeyEvents(true);
	end
	tItemName.FocusLost = function()
		tItemName:SetWantsKeyEvents(false);
		UpdateShortcut();

	end
	tItemName.KeyDown = function(Sender,Args)
		if Args.Action == 162 then  -- Updates when enter is pressed
			cItemInfoControl:Focus();
		end
	end

	-- Item Level --
	lblItemLevel = NewWindowLabel(wItemWin,80,18,20,tItemName:GetTop()+46,_LABELS[15][LANGID]);

	tItemLevel = NewWindowTextBox(wItemWin,80,18,lblItemLevel:GetLeft()+lblItemLevel:GetWidth()+10,tItemName:GetTop()+46,"1");
	tItemLevel.FocusGained = function ()
		tItemLevel:SetWantsKeyEvents(true);
	end
	tItemLevel.FocusLost = function()
		tItemLevel:SetWantsKeyEvents(false);
		UpdateShortcut();
	end
	tItemLevel.KeyDown = function(Sender,Args)
		if Args.Action == 162 then  -- Updates when enter is pressed
			cItemInfoControl:Focus();
		end
	end

	-- Armour Value --
	lblItemArmour = NewWindowLabel(wItemWin,80,18,20,lblItemLevel:GetTop()+28,_LABELS[16][LANGID]);

	tItemArmour = NewWindowTextBox(wItemWin,80,18,lblItemArmour:GetLeft()+lblItemArmour:GetWidth()+10,lblItemArmour:GetTop(),"");
	tItemArmour.FocusGained = function ()
		tItemArmour:SetWantsKeyEvents(true);
	end
	tItemArmour.FocusLost = function()
		tItemArmour:SetWantsKeyEvents(false);
		UpdateShortcut();
	end
	tItemArmour.KeyDown = function(Sender,Args)
		if Args.Action == 162 then  -- Updates when enter is pressed
			cItemInfoControl:Focus();
		end
	end

	-- Min Level --
	lblMinLevel = NewWindowLabel(wItemWin,80,18,20,lblItemArmour:GetTop()+28,_LABELS[17][LANGID]);

	tMinLevel = NewWindowTextBox(wItemWin,80,18,lblMinLevel:GetLeft()+lblMinLevel:GetWidth()+10,lblMinLevel:GetTop(),"");
	tMinLevel.FocusGained = function ()
		tMinLevel:SetWantsKeyEvents(true);
	end
	tMinLevel.FocusLost = function()
		tMinLevel:SetWantsKeyEvents(false);
		UpdateShortcut();
	end
	tMinLevel.KeyDown = function(Sender,Args)
		if Args.Action == 162 then  -- Updates when enter is pressed
			cItemInfoControl:Focus();
		end
	end


	btnPreview = Turbine.UI.Lotro.Button();
	btnPreview:SetParent(wItemWin);
	btnPreview:SetWidth(80);
	btnPreview:SetPosition(20,lblMinLevel:GetTop()+28);
	btnPreview:SetText(_LABELS[18][LANGID]);

	btnPreview.Click = function ()
		UpdateShortcut(true);
	end


	local _channels = {};

	for i=1, 18 do
		_channels[i] = _CHATCHANNELS[i][LANGID];
	end


	ddChannel = Utils.DropDown(_channels);
	ddChannel:SetParent(wItemWin);
	ddChannel:SetPosition(20,parentHeight-60);
	ddChannel:SetWidth(120);
	ddChannel:SetAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	ddChannel.ItemChanged = function (Sender,Args)
		UpdateShortcut();
	end

	qsPostItem = Turbine.UI.Lotro.Quickslot();
	qsPostItem:SetParent(wItemWin);
	qsPostItem:SetPosition(150,ddChannel:GetTop());
	qsPostItem:SetSize(96,18);
	qsPostItem:SetZOrder(1);
	scPostItem = Turbine.UI.Lotro.Shortcut();
	scPostItem:SetType(Turbine.UI.Lotro.ShortcutType.Alias);

	btnSend = Turbine.UI.Window();
	btnSend:SetParent(wItemWin);
	btnSend:SetSize(96,18);
	btnSend:SetPosition(qsPostItem:GetPosition());
	btnSend:SetBackground(RESOURCEDIR.."send_up.jpg");
	btnSend:SetVisible(true);
	btnSend:SetZOrder(50);
	btnSend:SetMouseVisible(false);


	-- Window events
	wItemWin.PositionChanged = function()
		SETTINGS.ITEMWIN.X = wItemWin:GetLeft();
		SETTINGS.ITEMWIN.Y = wItemWin:GetTop();
	end


	ExplorerSetItem(defaultItem);

end


function ExplorerSetItem(itemID)

	if itemID == nil then return end;

	local itemInfo = _ITEMSDB[itemID];

	cItemInfoControl:SetItem(itemID);

	tItemName:SetForeColor(_QUALITYCOLORS[itemInfo[4]]);
	tItemName:SetText(itemInfo[1]);

	UpdateShortcut();

end

function UpdateShortcut(preview)

	local sChannel = _CHATCOMMANDS[ddChannel:GetIndex()][LANGID];
	local itemID = cItemInfoControl.ItemID;
	local hexID = "0x"..Utils.TO_HEX(cItemInfoControl.ItemID);
	local itemLevel = tonumber(tItemLevel:GetText());
	local itemArmour = tonumber(tItemArmour:GetText());
	local minLevel = tonumber(tMinLevel:GetText());

	if tMinLevel:GetText() == "" then minLevel = nil end;
	if tItemArmour:GetText() == "" then itemArmour = nil end;

	-- Codec_Encode (vItem_ID, vPlayer_Lvl, vItem_Lvl, vExtra_count, vArmour, vMaxDmg, tEssences)
	local data = Utils.Decode.Codec_Encode(itemID, minLevel,itemLevel,2,itemArmour,nil);
	local out = "<ExamineItemInstance:ItemInfo:"..data..">["..tItemName:GetText().."]<\ExamineItemInstance>"

	if preview == true then Turbine.Shell.WriteLine(_LABELS[19][LANGID]..":\n" .. out) end;

	scPostItem:SetData(sChannel.." "..out);
	qsPostItem:SetShortcut(scPostItem);

end

