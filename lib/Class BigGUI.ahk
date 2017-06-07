Class BigGUI extends GUI {
	static BindHistory := []
	static GamesHistory := []
	static MonitorHWND := []
	
	; drag/drop
	DropFiles(FileArray, CtrlHwnd, X, Y) {
		
		if (this.ActiveTab = 1) {
			for Index, File in FileArray {
				SplitPath, File,,, ext, FileName
				if (ext = "exe")
					GameRules[File] := {BlockAltTab:false, BlockWinKey:true, Vibrancy:50}, AddFile := File
				else if (ext = "lnk") {
					FileGetShortcut, % File, Target,,,, Icon
					GameRules[Target] := {BlockAltTab:false, BlockWinKey:true, Vibrancy:50, Title: FileName}
					if StrLen(Icon)
						GameRules[Target].Icon := Icon
					AddFile := Target
				}
			}
			
			if StrLen(AddFile) {
				this.Activate()
				this.UpdateGameList(AddFile)
			} else
				TrayTip("Only exe and lnk files are allowed!")
		}
	}
	
	/*
		*** GAMES ***
	*/
	
	; probably temporary (right?????)
	AddGame() {
		this.Disable()
		this.Options("+AlwaysOnTop")
		AppSelect(this.AddGameCallback.Bind(this), this.hwnd)
	}
	
	AddGameCallback(Info) {
		
		this.Enable()
		this.Options("-AlwaysOnTop")
		this.Activate()
		
		if !IsObject(Info)
			return
		
		Game := {BlockAltTab:false, BlockWinKey:true, Vibrancy:50}
		
		if StrLen(Info.DisplayName)
			Game.Title := Info.DisplayName
		
		if StrLen(Info.DisplayIcon)
			Game.Icon := Info.DisplayIcon
		
		GameRules[Info.InstallLocation] := Game
		
		GameRules.Save()
		this.UpdateGameList(Info.InstallLocation)
		
		Loop % this.GameLV.GetCount() {
			LVKey := this.GameLV.GetText(A_Index, 2)
			if (LVKey = Info.InstallLocation) {
				this.GamesHistory.Insert({Event:"Addition", Key:Info.InstallLocation, Pos:A_Index})
				break
			}
		}
	}
	
	GameDelete() {
		Key := this.GameLV.GetText(Pos := this.GameLV.GetNext(), 2)
		
		if (Key = "path") || !StrLen(Key)
			return
		
		if !IsObject(GameRules[Key]) {
			Error("Attempted deletion doesn't exist in GameRules", A_ThisFunc, "Pos: " pos "`nKey: " Key)
			return
		}
		
		this.GameLV.Delete(Pos)
		this.GameLV.Modify(NewPos := (this.GameLV.GetCount()<Pos?this.GameLV.GetCount():Pos), "Focus Select Vis")
		
		if !IsObject(Prog:=GameRules.Remove(Key)) {
			return
		}
		
		this.GamesHistory.Insert({Event:"Deletion", Key:Key, Prog:Prog, Pos:Pos})
		
		this.GameListViewSize()
		this.GameListViewAction("", "C", NewPos)
	}
	
	GameRegret() {
		Info := this.GamesHistory.Pop()
		
		if !IsObject(Info)
			return
		
		if (Info.Event = "Deletion") {
			GameRules[Info.Key] := Info.Prog
			this.UpdateGameList()
			this.GameLV.Modify(NewPos := Info.Pos, "Focus Vis Select")
		} else if (Info.Event = "Addition") {
			GameRules.Remove(Info.Key)
			this.GameLV.Delete(Info.Pos)
			this.GameLV.Modify(NewPos := (Info.Pos>this.GameLV.GetCount()?this.GameLV.GetCount():Info.Pos), "Select Focus Vis")
		}
		
		this.GameListViewSize()
		this.GameListViewAction("", "C", NewPos)
	}
	
	SelectScreen(Select) {
		Mons := []
		Mons[Select] := true
		
		if (GetKeyState("CTRL", "P") || GetKeyState("SHIFT", "P")) {
			Multi := true
			for Index, Screen in Settings.VibrancyScreens
				Mons[Screen] := true
		}
		
		for Screen in Mons, Screens := []
			Screens.Push(Screen)
		
		Event("SetScreens", Screens)
		
		Settings.VibrancyScreens := Screens
		this.ColorScreens()
	}
	
	ColorScreens() {
		for ColorScreen, HWND in this.MonitorHWND {
			for Index, SavedScreen in Settings.VibrancyScreens {
				if (ColorScreen = SavedScreen) {
					CtlColors.Change(HWND, SubStr(int2hex(Settings.Color.Tab), 3), "FFFFFF")
					continue 2
				} 
			} CtlColors.Change(HWND, "FFFFFF", "000000")
		}
	}
	
	GamesWinBlock() {
		if (Key := this.GamesGetKey())
			GameRules[Key].BlockWinKey := Big.GuiControlGet(, "Button5")
	}
	
	GamesAltTabBlock() {
		if (Key := this.GamesGetKey())
			GameRules[Key].BlockAltTab := Big.GuiControlGet(, "Button6")
	}
	
	GamesSlider() {
		if (Key := this.GamesGetKey())
			GameRules[Key].Vibrancy := Big.GuiControlGet(, "msctls_trackbar321")
	}
	
	GamesGetKey() {
		Key := this.GameLV.GetText(this.GameLV.GetNext(), 2)
		
		; check if key clicked
		if (Key = "path") || !StrLen(Key)
			return 
		
		; check if key exists in gamerules
		if !IsObject(GameRules[Key])
			return Error("Key not found in GameRules Array", A_ThisFunc, "Key: " Key)
		else
			return Key
	}
	
	UpdateGameList(FocusKey := "") {
		Critical 500
		
		IL := new this.ImageList(this.GameLV)
		
		this.GameLV.Redraw(false)
		this.GameLV.SetImageList(IL.ID)
		this.GameLV.Delete()
		
		for Process, Info in GameRules.Data() {
			if StrLen(Info.Title)
				Title := Info.Title
			else
				SplitPath, Process,,,, Title
			
			Pos := this.GameLV.Add("Icon" . IL.Add(StrLen(Info.Icon)?Info.Icon:Process), StrLen(Title)?Title:FileName, Process)
			
			if (FocusKey = Process)
				Settings.GuiState.GameListPos := Pos
		}
		
		this.GameListViewAction("", "C", Settings.GuiState.GameListPos)
		this.GameListViewSize()
		this.GameLV.Redraw(true)
	}
	
	GameListViewAction(Control, GuiEvent, EventInfo) {
		static ControlsDisabled
		if (GuiEvent = "C") || (GuiEvent = "I") {
			Pos := (EventInfo ? EventInfo : this.GameLV.GetNext())
			if Pos {
				Key := this.GameLV.GetText(Pos, 2)
				if (Key = "path") || !StrLen(Key) {
					this.Control("Disable", "msctls_trackbar321")
					this.Control("Disable", "Button5")
					this.Control("Disable", "Button6")
					this.SetText("msctls_trackbar321", 50)
					this.SetText("Button5", false)
					this.SetText("Button6", false)
					ControlsDisabled := true
					return
				} else if ControlsDisabled {
					if !Settings.NvAPI_InitFail
						this.Control("Enabled", "msctls_trackbar321")
					this.Control("Enabled", "Button5")
					this.Control("Enabled", "Button6")
					ControlsDisabled := false
				}
				this.SetText("msctls_trackbar321", GameRules[Key].Vibrancy)
				this.SetText("Button5", GameRules[Key].BlockWinKey)
				this.SetText("Button6", GameRules[Key].BlockAltTab)
				Settings.GuiState.GameListPos := Pos
			}
			
			if (GuiEvent = "C")
				this.GameLV.Modify(Pos?Pos:Settings.GuiState.GameListPos, "Select Vis Focus")
		}
	}
	
	GameListViewSize() {
		Critical 500
		
		; removed width if scroll is visible
		if ((LV_EX_GetRowHeight(this.GameLV.hwnd) * this.GameLV.GetCount()) > this.LV_HEIGHT)
			this.GameLV.ModifyCol(1, this.HALF_WIDTH - VERT_SCROLL - 1)
		else
			this.GameLV.ModifyCol(1, this.HALF_WIDTH - 1)
		
		this.GameLV.ModifyCol(2, 0)
	}
	
	/*
		*** BINDER ***
	*/
	
	AddBind() {
		this.Disable()
		this.Options("+AlwaysOnTop")
		Keybinds(false)
		CreateNugget(this.BindCallback.Bind(this), this.hwnd) ; callback, owner
	}
	
	; bug, when overwriting, it doesn't default the focus to the window
	BindCallback(Bind := "", Key := "") {
		this.Options("-AlwaysOnTop")
		
		if !IsObject(Bind) {
			Keybinds(true)
			this.Enable()
			this.Activate()
			return
		}
		
		Keybinds[Key] := Bind
		Keybinds(true)
		this.UpdateBindList(Key)
		
		Loop % this.BindLV.GetCount() {
			LVKey := this.BindLV.GetText(A_Index, 3)
			if (LVKey = Key) {
				this.BindHistory.Insert({Event:"Addition", Key:Key, Pos:A_Index})
				break
			}
		}
		
		this.Enable()
		this.Activate()
	}
	
	BindDelete() {
		Critical 500
		
		RealKey := this.BindLV.GetText(Pos:=this.BindLV.GetNext(), 3)
		
		if (RealKey = "realkey") || !StrLen(RealKey) ; if list is empty, it EITHER output defaults to header which is 'realkey', OR gets empty. it's weird
			return
		
		this.BindHistory.Insert({Event:"Deletion", Key:RealKey, Bind:Keybinds[RealKey], Pos:Pos})
		Keybinds.Delete(RealKey)
		this.BindLV.Delete(Pos)
		
		this.BindLV.Modify((this.BindLV.GetCount()<Pos?this.BindLV.GetCount():Pos), "Focus Select Vis") ; select closest new row
		
		this.BindListViewSize()
		
		Hotkey.GetKey(RealKey).Delete()
	}
	
	BindRegret() {
		Info := this.BindHistory.Pop()
		
		if !IsObject(Info)
			return
		
		if (Info.Event = "Deletion") {
			Keybinds[Info.Key] := Info.Bind
			NewPos := this.BindLV.Insert(Info.Pos, "Focus Select Vis", HotkeyToString(Info.Key), Info.Bind.Desc, Info.Key)
			BindKey(Info.Key, Info.Bind)
		} else if (Info.Event = "Addition") { ; a fine one
			Keybinds.Remove(Info.Key)
			this.BindLV.Delete(NewPos := Info.Pos)
			Hotkey.GetKey(Info.Key).Delete()
		}
		
		;p(newpos, ((NewPos > Keybinds.MaxIndex()) ? Keybinds.MaxIndex() : NewPos))
		
		this.BindListViewSize()
		this.BindListViewAction("", "C", (NewPos > ArraySize(Keybinds) ? ArraySize(Keybinds) : NewPos))
	}
	
	UpdateBindList(FocusKey:= "") {
		Critical 500
		
		this.BindLV.Redraw(false)
		this.BindLV.Delete()
		
		for Key, Bind in Keybinds.Data() {
			Pos := this.BindLV.Add(, HotkeyToString(Key), Keybinds[Key].Desc, Key)
			
			if (Key = FocusKey)
				Settings.GuiState.BindListPos := Pos
		}
		
		this.BindListViewSize()
		this.BindListViewAction("", "C", Settings.GuiState.BindListPos)
		this.BindLV.Redraw(true)
	}
	
	BindListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "C") {
			Pos := (EventInfo?EventInfo:this.BindLV.GetNext())
			this.BindLV.Modify(Pos?(Settings.GuiState.BindListPos := Pos):Settings.GuiState.BindListPos, "Select Vis Focus")
		}
	}
	
	BindListViewSize() {
		Critical 500
		
		if (LV_EX_GetRowHeight(this.BindLV.hwnd)*this.BindLV.GetCount() > this.LV_HEIGHT)
			this.BindLV.ModifyCol(2, this.HALF_WIDTH - VERT_SCROLL)
		else
			this.BindLV.ModifyCol(2, this.HALF_WIDTH)
		
		this.BindLV.ModifyCol(1, this.HALF_WIDTH)
		this.BindLV.ModifyCol(3, 0)
	}
	
	/*
		*** TABS / OTHER ***
	*/
	
	TabAction(Control, GuiEvent, EventInfo) {
		this.Default()
		Tab := Control = this.GamesHWND ? 1 : 2
		this.SetTabColor(Tab)
		this.SetTab(Tab)
	}
	
	SetTab(tab) {
		this.Default()
		
		Event("GuiSetTab", tab)
		
		this.Control("Choose", "SysTabControl321", tab)
		
		this.SetTabHotkeys(tab)
		this.SetTabColor(tab)
		
		this.ActiveTab := tab
		
		if (tab = 1) {
			this.ColorScreens()
			this.DropFilesToggle(true)
			this.Control("Focus", "SysListView321")
		} else {
			this.DropFilesToggle(false)
			this.Control("Focus", "SysListView322")
		}
	}
	
	SetTabHotkeys(tab) {
		new Hotkey("~*LButton", this.MouseClick.Bind(this), this.ahkid, "Exist") ; always bound
		if (tab = 1) {
			new Hotkey("Delete", this.GameDelete.Bind(this), this.ahkid)
			new Hotkey("^z", this.GameRegret.Bind(this), this.ahkid)
			Hotkey.GetKey("Space", this.ahkid).Delete()
		} else {
			new Hotkey("Delete", this.BindDelete.Bind(this), this.ahkid)
			new Hotkey("^z", this.BindRegret.Bind(this), this.ahkid)
			Hotkey.GetKey("Space", this.ahkid).Delete()
		}
	}
	
	SetTabColor(tab) {
		for Index, TabCtrl in [this.GamesHWND, this.KeybindsHWND] {
			if (A_Index = tab)
				this.Control("Disable", TabCtrl)
			else
				this.Control("Enable", TabCtrl)
		}
	}
	
	Open(tab := "") {
		if this.IsVisible { ; why redraw? lv_colors fix
			this.LVRedraw(false)
			if tab
				this.SetTab(tab)
			this.Activate()
			this.LVRedraw(true)
			return
		}
		
		if SetGUI.IsVisible
			return
		
		Event("GuiOpen")
		
		this.LVRedraw(false)
		this.Pos(A_ScreenWidth/2 - this.HALF_WIDTH, A_ScreenHeight/2 - 164, this.HALF_WIDTH*2)
		this.SetTab(tab?tab:this.ActiveTab)
		this.Show()
		this.LVRedraw(true)
		
		if (this.ActiveTab = 1)
			this.ColorScreens()
		
		this.Control(, this.ProgressHWND, 50)
		
		; init CLV here
		if !this.GameLV.CLV {
			this.GameLV.CLV := new LV_Colors(this.GameLV.hwnd)
			this.GameLV.CLV.Critical := 500
			this.GameLV.CLV.SelectionColors(Settings.Color.Selection, "0xFFFFFF")
		}
		
		if !this.BindLV.CLV {
			this.BindLV.CLV := new LV_Colors(this.BindLV.hwnd)
			this.BindLV.CLV.Critical := 500
			this.BindLV.CLV.SelectionColors(Settings.Color.Selection, "0xFFFFFF")
		}
	}
	
	LVRedraw(Redraw) {
		for Index, LV in [this.GameLV.hwnd, this.BindLV.hwnd]
			this.Control((Redraw ? "+" : "-") "Redraw", LV)
	}
	
	Save() {
		Settings.GuiState.ActiveTab := this.ActiveTab
		Settings.GuiState.ExpandState := this.ExpandState
		Settings.Save()
		Keybinds.Save()
		GameRules.Save()
	}
	
	Escape() {
		this.Close()
	}
	
	Close() {
		Event("GuiClose")
		this.Hide()
		Keybinds(true)
		this.Save()
	}
	
	; change the stupid tab IMMEDIATELY NICE HACK RUNE
	MouseClick() {
		MouseGetPos,,, hwnd, Ctrl
		if (Ctrl ~= "^(Button(1|2|3))$") && (hwnd = this.hwnd)
			this.SetTab(SubStr(Ctrl, 7, 1))
	}
}