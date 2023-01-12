

function RegisterCommands()

	---------------------------------------------------------------------------------------------

	-- /item
	-- /item <item name or item id>

	itemCommand = Turbine.ShellCommand();

	function itemCommand:Execute(command,args)

		if args == "" then
			if Windows.wMainWin:IsVisible() == false then
				Windows.wMainWin:SetVisible(true);
				Windows.wMainWin:Activate();
			else
				Windows.wMainWin:SetVisible(false);
			end
		else
			Windows.ClearSearchControls();
			if tonumber(args) ~= nil and _ITEMSDB[tonumber(args)] ~= nil then
				_SEARCHRESULTS = {tonumber(args)};
				PAGE = 1;
				Windows.PagenateResults(PAGE);
				Windows.wMainWin:SetVisible(true);
				Windows.wMainWin:Activate();
			else
				Windows.txtSearch:SetText(args);
				Windows.PrepareSearch();
				Windows.wMainWin:SetVisible(true);
				Windows.wMainWin:Activate();
			end
		end
	end

	function itemCommand:GetHelp()
		return _STRINGS[1][5][LANGID];
	end

	function itemCommand:GetShortHelp()
		return _STRINGS[1][5][LANGID];
	end

	Turbine.Shell.AddCommand( "item", itemCommand);

	-- Item Windows
	explorerCommand = Turbine.ShellCommand();

	function explorerCommand:Execute(command,args)
		if Windows.wItemWin:IsVisible() == false then
			Windows.wItemWin:SetVisible(true);
			Windows.wItemWin:Activate();
		else
			Windows.wItemWin:SetVisible(false);
		end
	end

	Turbine.Shell.AddCommand("ITexplorer", explorerCommand);

end





