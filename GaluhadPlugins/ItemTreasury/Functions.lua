
function RegisterEditEvent(control)	 -- Filters numbers only
	if control == nil then return end;

	control.TextChanged = function ()
		control:SetText(string.match(control:GetText(),'%d*%,*%d*%.*%d*')); 	-- eg 1,000 or 102.5 or 1,263.87
	end

	control.FocusGained = function()
		control:SetWantsKeyEvents(true);
	end

	control.FocusLost = function()
		control:SetWantsKeyEvents(false);
	end
end


_replaceStr={[128]="A",[129]="A",[130]="A",[131]="A",[132]="A",[133]="A",[134]="AE",[135]="C",[136]="E",[137]="E",[138]="E",[139]="E",[140]="I",[141]="I",[142]="I",[143]="I",[144]="",[145]="N",[146]="O",[147]="O",[148]="O",[149]="O",[150]="O",[151]="",[152]="O",[153]="U",[154]="U",[155]="U",[156]="U",[157]="Y",[158]="Y",[159]="sz",[160]="a",[161]="a",[162]="a",[163]="a",[164]="a",[165]="a",[166]="ae",[167]="c",[168]="e",[169]="e",[170]="e",[171]="e",[172]="i",[173]="i",[174]="i",[175]="i",[176]="o",[177]="n",[178]="o",[179]="o",[180]="o",[181]="o",[182]="o",[183]="",[184]="o",[185]="u",[186]="u",[187]="u",[188]="u",[189]="y",[190]="y",[191]="y"};

function StripAccent(str)	-- Function by Garan
	local ret = "";
	local replace=false
	for i,v in ipairs({str:byte(1,-1)}) do
		if replace then
			replace=false
			if _replaceStr[v]~=nil then
				ret=ret.._replaceStr[v]
			end
		else
			if (v==195) then
				replace=true
			else
				ret = ret .. string.char(v);
			end
		end
	end
	return ret;
end


function NewPagenateButton()
	local btn = Turbine.UI.Lotro.Button();
	btn:SetSize(22,20);
	return btn;
end


function NewItemInfo(itemID)
	if itemID == nil then return end;

	local cItemInspect = Turbine.UI.Lotro.Quickslot();
	cItemInspect:SetSize(36,36);
	cItemInspect:SetVisible(true);

	local cItemInfo = Turbine.UI.Lotro.ItemInfoControl();
	cItemInfo:SetSize(36,36);
	cItemInfo:SetAllowDrop(false);
	cItemInfo:SetVisible(true);
	cItemInfo["ItemID"] = 0;

	cItemInfo.SetItem = function (sender, newItemID)
		if newItemID == nil then return end;
		local itemHex = Utils.TO_HEX(newItemID);

		local function SetInspectIcon() 	-- PCALL THIS incase item does not exist
			cItemInspect:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Item, "0x0,0x" .. itemHex));
		end

		if pcall(SetInspectIcon) then
			cItemInspect:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Item, "0x0,0x" .. itemHex)); -- works u23
			local itemInfo = cItemInspect:GetShortcut():GetItem():GetItemInfo();
			cItemInfo:SetItemInfo(itemInfo);
			cItemInfo:SetQuantity(1);
			cItemInfo.ItemID = newItemID;
		end

	end

	cItemInfo:SetItem(itemID);

	return cItemInfo;
end


-- Creates a desktop icon to use for opening windows rather than relying on commands
-- windows will need to be assigned to the icon to open when clicked using the AssignToDesktopIcon() funcion
function CreateDesktopIcon(image)
	if image == nil then
		print("CreateDesktopIcon(image) - No image assigned");
		return;
	end

	if SETTINGS.DESKICON == nil then
		SETTINGS.DESKICON = {};
		SETTINGS.DESKICON["X"] = 5;
		SETTINGS.DESKICON["Y"] = 5;
	end

	cDeskIcon = Turbine.UI.Window();
	cDeskIcon:SetSize(32,32);
	cDeskIcon:SetPosition(SETTINGS.DESKICON.X,SETTINGS.DESKICON.Y);
	cDeskIcon:SetBackground(image);
	cDeskIcon:SetBlendMode(0);
	cDeskIcon:SetToolTip(PLUGINNAME);
	cDeskIcon:SetVisible(true);
	cDeskIcon:SetHideF12(true);
	cDeskIcon:SetCloseEsc(false);
	cDeskIcon:SetWantsKeyEvents(true);
	cDeskIcon["Windows"] = {};

	Utils.Onscreen(cDeskIcon);


	-- WINDOW MOUSE EVENTS ---------------------------------------------------------------------------------------------------
	local blDragging = false;
	local relX = 0;
	local relY = 0;

	cDeskIcon.MouseDown = function (sender, args)
		blDragging = true;
		relX = args.X;
		relY = args.Y;
	end

	cDeskIcon.MouseUp = function (sender, args)
		blDragging = false;
	end

	cDeskIcon.MouseMove = function (sender, args)
		if blDragging == true then
			local scX = Turbine.UI.Display.GetMouseX();
			local scY = Turbine.UI.Display.GetMouseY();
			SETTINGS.DESKICON.X = scX - relX;
			SETTINGS.DESKICON.Y = scY - relY;

			if SETTINGS.DESKICON.X < 0 then SETTINGS.DESKICON.X = 0 end
			if SETTINGS.DESKICON.X > (SCREENWIDTH-32) then SETTINGS.DESKICON.X = (SCREENWIDTH-32) end
			if SETTINGS.DESKICON.Y < 0 then SETTINGS.DESKICON.Y = 0 end
			if SETTINGS.DESKICON.Y > (SCREENHEIGHT-32) then SETTINGS.DESKICON.Y = (SCREENHEIGHT-32) end

			cDeskIcon:SetPosition(SETTINGS.DESKICON.X,SETTINGS.DESKICON.Y);
		end
	end

	cDeskIcon.MouseDoubleClick = function (sender, args)
		if (args.Button == Turbine.UI.MouseButton.Left) then
			if type(cDeskIcon.Windows) ~= 'table' then return end;
			for k,v in pairs(cDeskIcon.Windows) do
				v:SetVisible(true);
				v:Activate();
			end
		end
	end

end


-- Once an icon has been created, windows can be assigned to it using this function
function Turbine.UI.Window.AssignToDesktopIcon(sender,add)
	if sender == nil or add == false then return end;

	if type(cDeskIcon.Windows) ~= 'table' then cDeskIcon.Windows = {} end;
	local added = false;

	for k,v in pairs (cDeskIcon.Windows) do -- check to make sure it's not entered twice
		if v == sender then
			added = true;
			break;
		end
	end

	if added == false then table.insert(cDeskIcon.Windows,sender) end;
end


function NewWindowTextBox(parent,width,height,left,top,text)
	textbox = Turbine.UI.Lotro.TextBox();
	if width == nil then width = 120 end;
	if height == nil then height = 22 end;
	if left == nil then left = 0 end;
	if top == nil then top = 0 end;
	if text == nil then text = "" end;
	if parent ~= nil then textbox:SetParent(parent) end;
	textbox:SetPosition(left,top);
	textbox:SetSize(width,height);
	textbox:SetSelectable(true);
	textbox:SetMultiline(false);
	textbox:SetForeColor(Turbine.UI.Color.Ivory);
	textbox:SetFont(Turbine.UI.Lotro.Font.Verdana14);
	textbox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	textbox:SetText(text);
	return textbox;
end


function NewItemContainer(width,height)
	if width == nil then width = 100 end;
	if height == nil then height = 12 end;
	local newContainer = Turbine.UI.Control();
	newContainer:SetSize(width,height);
	return newContainer;
end


function NewScrollBar(control,orientation,parent)
	if control == nil then return end;
	if orientation == nil then orientation = "vertical" end;
	scrollBar = Turbine.UI.Lotro.ScrollBar();
	if parent ~= nil then scrollBar:SetParent(parent) end;
	if orientation == "horizontal" then
		scrollBar:SetSize(control:GetWidth(),11);
		scrollBar:SetPosition(control:GetLeft(),control:GetTop()+control:GetHeight()+1);
		scrollBar:SetOrientation(Turbine.UI.Orientation.Horizontal);
		control:SetHorizontalScrollBar(scrollBar);
	else	-- vertical
		scrollBar:SetSize(11,control:GetHeight());
		scrollBar:SetPosition(control:GetLeft()+control:GetWidth()+1,control:GetTop());
		scrollBar:SetOrientation(Turbine.UI.Orientation.Vertical);
		control:SetVerticalScrollBar(scrollBar);
	end
	scrollBar:SetVisible(false);
	return scrollBar;
end


function NewWindowLabel(parent,width,height,left,top,text)
	label = Turbine.UI.Label();
	if width == nil then width = 150 end;
	if height == nil then height = 18 end;
	if left == nil then left = 0 end;
	if top == nil then top = 0 end;
	if text == nil then text = "" end;
	if parent ~= nil then label:SetParent(parent) end;
	label:SetSize(width,height);
	label:SetPosition(left,top);
	label:SetFont(Turbine.UI.Lotro.Font.Verdana14);
	label:SetForeColor(Turbine.UI.Color.Khaki);
	label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	label:SetText(text);
	return label;
end


function NewWarningLabel(parent,width,height,left,top,text)
	label = Turbine.UI.Label();
	if width == nil then width = 150 end;
	if height == nil then height = 18 end;
	if left == nil then left = 0 end;
	if top == nil then top = 0 end;
	if text == nil then text = "" end;
	if parent ~= nil then label:SetParent(parent) end;
	label:SetSize(width,height);
	label:SetPosition(left,top);
	label:SetFont(Turbine.UI.Lotro.Font.Verdana14);
	label:SetForeColor(Turbine.UI.Color.Red);
	label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
	label:SetText(text);
	return label;
end


function NewCustomButton(width,height,imageSelectedNormal,imageSelectedOver,imageUnselectedNormal,imageUnselectedOver,parent)
	local newButton = Turbine.UI.Control();
	if parent ~= nil then newButton:SetParent(parent) end;
	if width == nil then width = 40 end;
	if height == nil then height = 20 end;

	newButton:SetSize(width,height);
	newButton:SetMouseVisible(true);
	newButton["Selected"] = false;
	newButton:SetBackground(imageUnselectedNormal); -- default, unselected and not over.
	newButton:SetBlendMode(0);

	-- mouse events
	newButton.MouseEnter = function ()
		if newButton.Selected == true then -- Switch background image to 'Over' state
			newButton:SetBackground(imageSelectedOver);
		else
			newButton:SetBackground(imageUnselectedOver);
		end
	end

	newButton.MouseLeave = function ()
		if newButton.Selected == true then -- Switch background image to 'Normal' state
			newButton:SetBackground(imageSelectedNormal);
		else
			newButton:SetBackground(imageUnselectedNormal);
		end
	end

	local newButtonClick = function ()
		newButton.Selected = not newButton.Selected; -- inverse selected state
		newButton.MouseEnter(); --redo background
	end

	newButton.SetSelected = function (sender, args)
		newButton.Selected = args;
		newButton.MouseLeave();
	end

	newButton.IsSelected = function ()
		return newButton.Selected;
	end

	AddCallback(newButton,"MouseClick",newButtonClick);

	return newButton;
end

