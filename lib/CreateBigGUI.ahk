﻿CreateBigGUI() {
	Big := new Big(App.Name, "-MinimizeBox")
	
	Big.Font("s14", Settings.Font)
	Big.Color("FFFFFF")
	Big.Margin(0, 0)
	
	Big.HALF_WIDTH := HALF_WIDTH := 280
	Big.TAB_HEIGHT := TAB_HEIGHT := 32
	Big.LV_HEIGHT := LV_HEIGHT := 264
	Big.BUTTON_HEIGHT := BUTTON_HEIGHT := 26
	
	; ==========================================
	
	; tab text controls
	Big.GamesTabHWND := Big.Add("Button", "x0 y0 w" HALF_WIDTH - 1 " h" TAB_HEIGHT - 1)
	Big.KeybindsTabHWND := Big.Add("Button", "x" HALF_WIDTH " y0 w" HALF_WIDTH " h" TAB_HEIGHT - 1)
	
	bordermix := 0xFFEEEEEE ;CK
	NORMAL := [  [0, 0x80FFFFFF, , 0xD3000000, 0, , 0xFFFFFFFF, 1] ; normal
			,  [0, bordermix, , 0xD3000000, 0, , bordermix, 1] ; hover
			,  [0, bordermix , , 0xD3000000, 0, , bordermix, 1] ; pressed
			,  [0, Settings.Color.Tab, , 0xFFFFFF, 0, , Settings.Color.Tab, 1] ; disabled
			,  [0, 0xFFFFFFFF, , 0xFF000000, 0, , 0xFFFFFFFF, 1]] ; default
	
	for Index, TabberBOYE in [Big.GamesTabHWND, Big.KeybindsTabHWND]
		ImageButton.Create(TabberBOYE, NORMAL*)
	
	; separators
	Big.Add("Text", "x0 y" TAB_HEIGHT - 1 " h1 w" HALF_WIDTH*2 + 5 " 0x08") ; big-ass sep
	Big.Add("Text", "x" HALF_WIDTH - 1 " y0 w1 h" TAB_HEIGHT - 1 " 0x08") ; first sep
	
	Big.Add("Tab2", "x0 y0 w0 h0 -Wrap Choose2 AltSubmit", "Games|Keybinds", Big.TabAction.Bind(Big))
	
	; ==========================================
	
	Big.Tab(1)
	Big.Font("s11")
	Big.GameLV := new Big.ListView(Big, "x" 0 " y" TAB_HEIGHT " w" HALF_WIDTH - 1 " h" LV_HEIGHT " -HDR -Multi +LV0x4000 -E0x200 AltSubmit -TabStop", "name|path", Big.GameListViewAction.Bind(Big))
	
	Big.Font("s10")
	
	Big.GameDeleteHWND := Big.Add("Button", "x1 y" TAB_HEIGHT+LV_HEIGHT + 1 " w" Round(HALF_WIDTH/5*2) - 2 " h" BUTTON_HEIGHT - 1,, Big.GameDelete.Bind(Big))
	Big.GameAddHWND := Big.Add("Button", "x" Round(HALF_WIDTH/5*2) + 1 " yp w" HALF_WIDTH-Round(HALF_WIDTH/5*2) - 1 " h" BUTTON_HEIGHT - 1,, Big.AddGame.Bind(Big))
	
	Big.Add("Text", "x" HALF_WIDTH - 1 " y" TAB_HEIGHT " w1 h" LV_HEIGHT " 0x08") ; skille
	Big.Add("Text", "x" HALF_WIDTH " y" TAB_HEIGHT + LV_HEIGHT/2 + 8 " w" HALF_WIDTH " h1 0x08") ; skille
	
	Big.Font("s11")
	
	Big.Margin(6, 4) ; nicerino margerino
	Big.VibrancySliderTextHWND := Big.Add("Text", "x" HALF_WIDTH " y" TAB_HEIGHT + 8 " w" HALF_WIDTH " Center")
	Big.VibrancySliderHWND := Big.Add("Slider", "x" HALF_WIDTH + 12 " yp+25 w" HALF_WIDTH - 24 " Range50-100 ToolTip Center",, Big.GamesSlider.Bind(Big))
	
	Big.WinKeyBlockHWND := Big.Add("CheckBox", "x" HALF_WIDTH + 16 " yp+54 w122 h40",, Big.GamesWinBlock.Bind(Big)) ; egt 70
	Big.AltTabBlockHWND := Big.Add("CheckBox", "x" HALF_WIDTH/2*3 + 6 " yp w125 h40",, Big.GamesAltTabBlock.Bind(Big))
	
	Big.VibrancyScreenHWND := Big.Add("Text", "x" HALF_WIDTH + 6 " y" 182 " W" HALF_WIDTH - 12 " Center")
	
	MonitorCount := SysGet("MonitorCount")
	
	Big.Font(MonitorCount>1?"s16":"s14")
	
	if (MonitorCount = 1) {
		Big.PrimarySelectedHWND := Big.Add("Text", "x" HALF_WIDTH + 1 " y" TAB_HEIGHT + LV_HEIGHT*3/4 " w" HALF_WIDTH - 12 " Center")
		Settings.VibrancyScreens := [SysGet("MonitorPrimary")] ; reset it so it doesn't get messed up and the user is stuck and can't change
	} else {
		for MonID, Mon in MonitorSetup(HALF_WIDTH - 16, 100, 4) {
			HWND := Big.Add("Text"
					, "x" HALF_WIDTH + 8 + Mon.X
					. " y" 210 + Mon.Y
					. " w" Mon.W
					. " h" Mon.H
					. " +Border 0x200 Center", MonID, Big.SelectScreen.Bind(Big, MonID))
			Big.MonitorHWND[MonID] := HWND
		}	
	}
	
	if Settings.NvAPI_InitFail { ; no nvidia card detected, grey out/disable some controls..
		Big.Control("Disable", Big.VibrancySlider)
		Big.Font("s11 c808080")
		Big.Control("Font", "Static9")
		Big.Font("cBlack")
		Big.Control("Disable", "Static10")
		Big.Control("Disable", "Static11")
		for MonitorID, HWND in Big.MonitorHWND
			Big.Control("Disable", HWND)
		CtlColors.Change(Big.MonitorHWND.1, "FFFFFF", "000000")
	}
	
	Big.UpdateGameList()
	
	; ==========================================
	
	Big.Tab(2)
	Big.Margin(0, 0)
	Big.Font("s11")
	
	Big.BindLV := new Big.ListView(Big, "x0 y" TAB_HEIGHT " w" HALF_WIDTH*2 + 1 " h" LV_HEIGHT " -HDR -Multi AltSubmit -E0x200 -TabStop", "desc|key|realkey", Big.BindListViewAction.Bind(Big))
	
	Big.Font("s10")
	
	Big.BindDeleteHWND := Big.Add("Button", "x1 y" TAB_HEIGHT + LV_HEIGHT + 1 " w" HALF_WIDTH - 2 " h" BUTTON_HEIGHT - 1,, Big.BindDelete.Bind(Big))
	Big.BindAddHWND := Big.Add("Button", "x" HALF_WIDTH + 1 " yp w" HALF_WIDTH - 2 " h" BUTTON_HEIGHT - 1 " Center",, Big.AddBind.Bind(Big))
	
	Big.UpdateBindList()
	
	Big.ActiveTab := Settings.GuiState.ActiveTab
	
	if (Settings.GuiState.GameListPos > ArraySize(GameRules))
		Pos := ArraySize(GameRules)
	else if !Settings.GuiState.GameListPos
		Pos := 1
	else
		Pos := Settings.GuiState.GameListPos
	Big.GameListViewAction("", "C", Pos)
	
	if (Settings.GuiState.BindListPos > ArraySize(Keybinds))
		Pos := ArraySize(Keybinds)
	else if !Settings.GuiState.BindListPos
		Pos := 1
	else
		Pos := Settings.GuiState.BindListPos
	Big.BindListViewAction("", "C", Pos)
	
	Big.SetIcon(Icon())
	Big.Margin(0, 1) ; bottom pixel
	return
}