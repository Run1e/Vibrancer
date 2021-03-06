﻿Class Big extends GUI {
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
		
		GameRules.Save(true)
		this.UpdateGameList(Info.InstallLocation)
		
		Loop % this.GameLV.GetCount() {
			LVKey := this.GameLV.GetText(A_Index, 2)
			if (LVKey = Info.InstallLocation) {
				this.GamesHistory.Insert({Event:"Addition", Key:Info.InstallLocation, Pos:A_Index})
				break
			}
		}
		
		this.Activate()
	}
	
	GameDelete() {
		Key := this.GameLV.GetText(Pos := this.GameLV.GetNext(), 2)
		
		if (Key = "path") || !StrLen(Key)
			return
		
		if !IsObject(GameRules[Key]) {
			Debug.Log(Exception("Attempted deletion doesn't exist in GameRules", -1, "Pos: " pos "`nKey: " Key))
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
		
		if this.MultiSelect || GetKeyState("CTRL", "P") || GetKeyState("SHIFT", "P")
			Multi := !(this.MultiSelect := false)
		
		if Multi
			for Index, Screen in Settings.VibrancyScreens
				Mons[Screen] := true
		
		for Screen in Mons, Screens := []
			Screens.Push(Screen)
		
		Settings.VibrancyScreens := Screens
		this.ColorScreens()
	}
	
	ColorScreens() {
		;msgbox
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
			GameRules[Key].BlockWinKey := Big.GuiControlGet(, this.WinKeyBlockHWND) + 0
	}
	
	GamesAltTabBlock() {
		if (Key := this.GamesGetKey())
			GameRules[Key].BlockAltTab := Big.GuiControlGet(, this.AltTabBlockHWND) + 0
	}
	
	GamesSlider() {
		if (Key := this.GamesGetKey())
			GameRules[Key].Vibrancy := Big.GuiControlGet(, this.VibrancySliderHWND) + 0
	}
	
	GamesGetKey() {
		Key := this.GameLV.GetText(this.GameLV.GetNext(), 2)
		
		; check if key clicked
		if (Key = "path") || !StrLen(Key)
			return 
		
		; check if key exists in gamerules
		if !IsObject(GameRules[Key])
			return Debug.Log(Exception("Key not found in GameRules Array", -1, "Key: " Key))
		else
			return Key
	}
	
	UpdateGameList(FocusKey := "") {
		Critical 500
		
		IL := new Gui.ImageList(this.GameLV)
		
		this.GameLV.Redraw(false)
		this.GameLV.SetImageList(IL.ID)
		this.GameLV.Delete()
		
		for Process, Info in GameRules.Object() {
			if StrLen(Info.Title)
				Title := Info.Title
			else
				SplitPath, Process,,,, Title
			Pos := this.GameLV.Add("Icon" . IL.Add(StrLen(Info.Icon)?Info.Icon:Process), StrLen(Title)?Title:FileName, Process)
		}
		
		this.GameLV.Modify(Settings.GuiState.GameListPos, "Select Vis")
		this.GameListViewAction("", "C", Settings.GuiState.GameListPos)
		this.GameListViewSize()
		this.GameLV.ModifyCol(1, "Sort")
		Loop % this.GameLV.GetCount()
		{
			if (this.GameLV.GetText(A_Index, 2) = FocusKey) {
				this.GameLV.Modify(A_Index, "Select Focus Vis")
				break
			}
		}
		this.GameLV.Redraw(true)
	}
	
	GameListViewAction(Control, GuiEvent, EventInfo) {
		static ControlsDisabled
		if (GuiEvent = "C") || (GuiEvent = "I") {
			Pos := (EventInfo ? EventInfo : this.GameLV.GetNext())
			if Pos {
				Key := this.GameLV.GetText(Pos, 2)
				if (Key = "path") || !StrLen(Key) {
					this.Control("Disable", this.VibrancySliderHWND)
					this.Control("Disable", this.WinKeyBlockHWND)
					this.Control("Disable", this.AltTabBlockHWND)
					this.SetText(this.VibrancySliderHWND, 50)
					this.SetText(this.WinKeyBlockHWND, false)
					this.SetText(this.AltTabBlockHWND, false)
					ControlsDisabled := true
					return
				} else if ControlsDisabled {
					if !Settings.NvAPI_InitFail
						this.Control("Enabled", this.VibrancySliderHWND)
					this.Control("Enabled", this.WinKeyBlockHWND)
					this.Control("Enabled", this.AltTabBlockHWND)
					ControlsDisabled := false
				}
				this.SetText(this.VibrancySliderHWND, GameRules[Key].Vibrancy)
				this.SetText(this.WinKeyBlockHWND, GameRules[Key].BlockWinKey)
				this.SetText(this.AltTabBlockHWND, GameRules[Key].BlockAltTab)
				Settings.GuiState.GameListPos := Pos
			}
			
			if (GuiEvent = "C")
				this.GameLV.Modify(Pos?Pos:Settings.GuiState.GameListPos, "Select Vis Focus")
		}
	}
	
	GameListViewSize() {
		Critical 500
		static VERT_SCROLL := SysGet(2)
		
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
			this.SetTabHotkeys(this.ActiveTab)
			this.Enable()
			this.Activate()
			return
		}
		
		Keybinds[Key] := Bind
		Keybinds(true)
		this.SetTabHotkeys(this.ActiveTab)
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
			NewPos := this.BindLV.Insert(Info.Pos, "Focus Select Vis Icon" . (Actions[Info.Bind.Class].HasKey("__Class") ? 1 : 2), HotkeyToString(Info.Key), Info.Bind.Desc, Info.Key)
			BindKey(Info.Key, Info.Bind)
		} else if (Info.Event = "Addition") { ; a fine one
			Keybinds.Remove(Info.Key)
			this.BindLV.Delete(NewPos := Info.Pos)
			Hotkey.GetKey(Info.Key).Delete()
		}
		
		this.BindListViewSize()
		this.BindListViewAction("", "C", (NewPos > ArraySize(Keybinds) ? ArraySize(Keybinds) : NewPos))
	}
	
	UpdateBindList(FocusKey := "") {
		Critical 500
		
		this.BindLV.Redraw(false)
		this.BindLV.Delete()
		
		IL := new Gui.ImageList(this.GameLV)
		IL.Add(Icon("device-desktop"))
		IL.Add(Icon("plug"))
		
		this.BindLV.SetImageList(IL.ID)
		
		for Key, Bind in Keybinds.Object() {
			Pos := this.BindLV.Add("Icon" . (Actions[Bind.Class].HasKey("__Class") ? 1 : 2), HotkeyToString(Key), Keybinds[Key].Desc, Key)
			
			;m(Bind, Actions[Bind.Class].HasKey("__Class"))
			
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
		static VERT_SCROLL := SysGet(2)
		
		if (LV_EX_GetRowHeight(this.BindLV.hwnd)*this.BindLV.GetCount() > this.LV_HEIGHT)
			this.BindLV.ModifyCol(2, this.HALF_WIDTH - VERT_SCROLL + 1)
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
		Tab := Control = this.GamesTabHWND ? 1 : 2
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
			this.Control("Focus", this.GameLV.hwnd)
		} else {
			this.DropFilesToggle(false)
			this.Control("Focus", this.BindLV.hwnd)
		}
	}
	
	SetTabHotkeys(tab) {
		if (tab = 1) {
			new Hotkey("Delete", this.GameDelete.Bind(this), this.ahkid)
			new Hotkey("^z", this.GameRegret.Bind(this), this.ahkid)
		} else {
			new Hotkey("Delete", this.BindDelete.Bind(this), this.ahkid)
			new Hotkey("^z", this.BindRegret.Bind(this), this.ahkid)
		}
	}
	
	SetTabColor(tab) {
		for Index, TabCtrl in [this.GamesTabHWND, this.KeybindsTabHWND] {
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
		
		OnMessage(0x201, "LButton")
		OnMessage(0x204, "RButton")
		
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
		Settings.Save(true)
		Keybinds.Save(true)
		GameRules.Save(true)
	}
	
	Escape() {
		this.Close()
	}
	
	Close() {
		Event("GuiClose")
		this.Hide()
		OnMessage(0x201, "")
		OnMessage(0x204, "")
		Keybinds(true)
		this.Save()
	}
}

; for some reason the message doesn't unregsiter if the target is a boundfunc, fix?

; change the stupid tab IMMEDIATELY NICE HACK RUNE
; edit 22/06/2017: using system messages now, not really hack anymore!
; v(^_^)v (>^_^)> ^(^_^)> ^(^_^)^ <(^_^<) <(^_^)^ (>^_^)> <(^_^<) :D
LButton() {
	MouseGetPos,,, hwnd, Ctrl
	if (Ctrl ~= "^(Button(1|2))$") && (hwnd = Big.hwnd) ; returns true so the gui doesn't get the lbuttondown msg and the color changes immediately
		return true, Big.SetTab(SubStr(Ctrl, 7))
}

RButton() {
	MouseGetPos,,,, ctrl, 2
	for Index, Control in Big.MonitorHWND {
		if (Control+0 = ctrl) {
			Big.MultiSelect := true
			ControlClick,, % "ahk_id" ctrl
		}
	}
}