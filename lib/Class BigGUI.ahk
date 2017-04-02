Class BigGUI extends GUI {
	static BindHistory := [], GamesHistory := [], MonitorHWND := []
	static HALF_WIDTH := 270, TAB_HEIGHT := 32, LV_HEIGHT := 240, BUTTON_HEIGHT := 26, TAB_WIDTH := 180
	static AnimatedImages := {}
	static AnimatedPositions := {}
	static AnimatedEnabled := false
	
	/*
		*** IMGUR ***
	*/
	
	; drag/drop
	DropFiles(FileList, FileCount, ControlHWND, GuiX, GuiY) {
		for Index, File in StrSplit(FileList, "`n") {
			SplitPath, File,,, ext
			if (ext ~= Screenshot.AllowedExt)
				Screenshot.Upload(File)
			else 
				Screenshot.QueueErrors.Push(ext " files are not allowed on imgur!")
		}
	}
	
	ImgurGetSelected() {
		this.SetDefault()
		this.Options("ListView", this.ImgurListViewHWND)
		
		Indexes := []
		
		while (i:=LV_GetNext(i)) {
			LV_GetText(index, i, 2)
			Indexes[A_Index] := index
		}
		
		return Indexes
	}
	
	ImgurAnimate(Toggle) {
		if Toggle && !this.AnimatedEnabled
			SetTimer, ImgurAnimateTick, % Settings.Imgur.GifPeriod
		else if this.AnimatedEnabled
			SetTimer, ImgurAnimateTick, Off
		return
		
		ImgurAnimateTick:
		Big.ImgurAnimateTick()
		return
	}
	
	UpdateImgurList() {
		Critical 500
		
		this.SetDefault()
		this.Options("ListView", this.ImgurListViewHWND)
		
		this.LV_Colors_OnMessage(false)
		
		this.ImgurImageWidth:=124
		this.ImgurImageHeight:=70
		
		this.ImgurImageList := new CustomImageList(this.ImgurImageWidth, this.ImgurImageHeight, 0x20, 50, 5) ; custom res imagelist
		
		this.ImgurImageList.GifPeriod := Settings.Imgur.GifPeriod
		
		LV_SetImageList(this.ImgurImageList.ImageList, 0)
		LV_Delete()
		
		for Date, Image in Images, New := []
			New.Push(Date)
		
		Loop % Settings.Imgur.ListViewMax
			this.ImgurListAdd(New[New.MaxIndex() - A_Index + 1], false, false)
		
		this.ImgurFixOrder()
		
		sep:=5 ; separator between images
		
		LV_EX_SetIconSpacing(this.ImgurListViewHWND, this.ImgurImageWidth + sep, this.ImgurImageHeight + sep)
		
		this.ImgurListViewSelection()
		
		this.ImgurStatus(i?i "/" ArraySize(Images) " image" (i>1?"s":"") " loaded!":"Uploads appear here!")
		
		this.LV_Colors_OnMessage(true)
	}
	
	ImgurListAdd(Index, FixOrder := true, Insert := true) {
		
		this.SetDefault()
		this.Options("ListView", this.ImgurListViewHWND)
		
		if !Images.HasKey(Index)
			return false
		
		this.Control("-Redraw", this.ImgurListViewHWND)
		
		Image := Images[Index]
		
		if (Image.extension = "gif") {
			IconList := this.ImgurImageList.AddGif(Screenshot.ImgurImageFolder "\" Image.id "." image.extension)
			this.AnimatedImages[Index] := IconList
			this.AnimatedPositions[Index] := 1
			IconNumber := IconList.1
		} else
			IconNumber := this.ImgurImageList.AddImage(Screenshot.ImgurImageFolder "\" Image.id "." image.extension)
		
		if IconNumber {
			if Insert
				LV_Insert(1, "Icon" . IconNumber,, Index)
			else
				LV_Add("Icon" . IconNumber,, Index)
		}
		
		if FixOrder
			this.ImgurFixOrder()
		
		return !!IconNumber
	}
	
	ImgurListRemove(Index) {
		this.SetDefault()
		this.Options("ListView", this.ImgurListViewHWND)
		
		this.Control("-Redraw", this.ImgurListViewHWND)
		
		Loop % LV_GetCount()
		{
			LV_GetText(LV_Index, A_Index, 2)
			if (LV_Index = Index)
				LV_Delete(A_Index)
		}
		
		this.ImgurFixOrder()
		
		return
	}
	
	; when inserting to the first item position in a listview in icon mode, it doesn't add the item to the correct location (the first index).
	; so to fix, we change it to report view and back. and poof. magic.
	ImgurFixOrder() {
		this.SetDefault()
		this.Options("ListView", this.ImgurListViewHWND)
		
		this.Control("+Report", this.ImgurListViewHWND)
		sleep 1
		this.Control("+Icon", this.ImgurListViewHWND)
		sleep 1
		this.Control("+Redraw", this.ImgurListViewHWND)
		sleep 1
		
		LV_Modify(1, "Vis")
	}
	
	ImgurAnimateTick() {
		this.SetDefault()
		this.Options("ListView", this.ImgurListViewHWND)
		
		; find the next image to show for each animated image
		for Index, Pos in this.AnimatedPositions {
			if this.AnimatedImages[Index].HasKey(Pos+1)
				this.AnimatedPositions[Index] := Pos+1
			else
				this.AnimatedPositions[Index] := 1
		} 
		
		; change to the next image for each gif
		; later: figure out which images are onscreen and update accordingly
		Loop {
			LV_GetText(text, A_Index, 2)
			if this.AnimatedPositions.HasKey(text)
				LV_Modify(A_Index, "Icon" . this.AnimatedImages[text][this.AnimatedPositions[text]]) 
		} until !StrLen(text)
	}
	
	ImgurListViewSelection(GuiEvent) {
		if (GuiEvent = "DoubleClick")
			this.ImgurCopyLinks()
	}
	
	ImgurDelete() {
		Selected := this.ImgurGetSelected()
		
		MsgBox, 308, Image deletion, % Selected.MaxIndex() " image" (Selected.MaxIndex()>1?"s":"") " selected.`nProceed with deletion?"
		ifMsgBox no
		return
		
		for Index, ImageIndex in Selected
			Screenshot.Delete(ImageIndex)
	}
	
	ImgurOpenLinks() {
		Selected := this.ImgurGetSelected()
		
		if (ArraySize(Selected) > 7) { ; display a warning at 8+ images
			MsgBox,262196,Warning!,% "Are you sure you want to open " ArraySize(Selected) " images?"
			ifMsgBox no
			return
		}
		
		for Index, ImageIndex in this.ImgurGetSelected()
			run % Images[ImageIndex].link
		
		if Settings.Imgur.CloseOnOpen && Index
			this.Close()
	}
	
	ImgurCopyLinks() {
		for Index, ImageIndex in Selected := this.ImgurGetSelected()
			links .= Images[ImageIndex].link " "
		
		if !StrLen(links)
			return
		
		clipboard := rtrim(links, " ")
		
		Size := ArraySize(Selected)
		
		TrayTip, % "Link" (Size>1?"s":"") " copied!", % (Size>1?Size " links were copied to your clipboard":clipboard)
		
		if Settings.Imgur.CloseOnCopy && StrLen(links)
			this.Close()
	}
	
	StartStopQueue() {
		if Screenshot.RunQueue
			Screenshot.StopQueue()
		else if !Screenshot.Busy
			Screenshot.StartQueue()
	}
	
	ClearQueue() {
		if Screenshot.Busy ; uploader is working, don't do anything
			return
		
		this.SetText(this.StartStopButtonHWND, "Stop")
		this.QueueControl(false)
		Screenshot.ClearQueue()
	}
	
	ClearQueueControl(Toggle) {
		this.Control(Toggle?"Enable":"Disable", this.ClearButtonHWND)
	}
	
	QueueControl(Toggle) {
		this.Control(Toggle?"Enable":"Disable", this.StartStopButtonHWND)
	}
	
	ImgurStatus(Status) {
		this.SetText(this.ImgurStatusHWND, Status)
	}
	
	/*
		*** GAMES ***
	*/
	
	; probably temporary (right?????)
	AddProg() {
		Critical 500
		
		this.Disable()
		this.Options("+OwnDialogs")
		
		FileSelectFile, Game, 3, % A_ProgramFiles, Select an .exe file, *.exe
		
		
		if ErrorLevel
			return this.Enable()
		
		if IsObject(GameRules[Game]) {
			MsgBox,48,Duplicate entry, This program is already in the list.
			Settings.GuiState.GameListPos := GameRules.HasKey(Game)
			this.GameListSelection()
			this.Enable()
			return
		}
		
		GameRules[Game] := {BlockAltTab:false, BlockWinKey:true, Vibrancy:50}
		
		JSONSave("GameRules", GameRules)
		
		this.UpdateGameList(Game)
		
		Loop % LV_GetCount() {
			LV_GetText(LVKey, A_Index, 2)
			if (LVKey = Game) {
				this.GamesHistory.Insert({Event:"Addition", Key:Game, Pos:A_Index})
				break
			}
		}
		
		this.Enable()
	}
	
	DeleteProg() {
		this.SetDefault()
		this.Options("ListView", this.GameListViewHWND)
		
		LV_GetText(Key, Pos:=LV_GetNext(), 2)
		
		if (Key = "path") ; header is called path, defaults to "path" when none selected
			return
		
		if !IsObject(GameRules[Key]) {
			Error("Attempted deletion doesn't exist in GameRules", A_ThisFunc, "Pos: " pos "`nKey: " Key)
			return
		}
		
		LV_Delete(Pos)
		LV_Modify((LV_GetCount()<Pos?LV_GetCount():Pos), "Focus Select Vis")
		
		if !IsObject(Prog:=GameRules.Remove(Key)) {
			; shit
			return
		}
		
		this.GamesHistory.Insert({Event:"Deletion", Key:Key, Prog:Prog, Pos:Pos})
		
		this.GameListViewSize()
	}
	
	RegretProg() {
		this.SetDefault()
		this.Options("ListView", this.GameListViewHWND)
		
		Info := this.GamesHistory.Pop()
		
		if !IsObject(Info)
			return
		
		if (Info.Event = "Deletion") {
			GameRules[Info.Key] := Info.Prog
			this.UpdateGameList()
			LV_Modify(Info.Pos, "Focus Vis Select")
		} else if (Info.Event = "Addition") {
			GameRules.Remove(Info.Key)
			LV_Delete(Info.Pos)
			LV_Modify(Info.Pos>LV_GetCount()?LV_GetCount():Info.Pos, "Select Focus Vis")
		} this.GameListViewSize()
	}
	
	SelectScreen(Screen) {
		for Index, HWND in this.MonitorHWND
			CtlColors.Change(HWND, ((Screen = Index) ? Settings.Color.Tab : "FFFFFF"), ((Screen = Index) ? "FFFFFF" : "000000"))
		Settings.VibrancyScreen := Screen-1
	}
	
	GamesWinBlock() {
		if (Key := this.GamesGetKey())
			GameRules[Key].BlockWinKey := Big.GuiControlGet(, "Button3")
	}
	
	GamesAltTabBlock() {
		if (Key := this.GamesGetKey())
			GameRules[Key].BlockAltTab := Big.GuiControlGet(, "Button4")
	}
	
	GamesSlider() {
		if (Key := this.GamesGetKey())
			GameRules[Key].Vibrancy := Big.GuiControlGet(, "msctls_trackbar321")
	}
	
	GamesGetKey() {
		this.SetDefault()
		this.Options("ListView", this.GameListViewHWND)
		
		LV_GetText(Key, LV_GetNext(), 2)
		
		if (Key = "path")
			return 
		else if !IsObject(GameRules[Key]) {
			Error("Key not found in GameRules Array", A_ThisFunc, "Key: " Key)
			return
		} else
			return Key
	}
	
	UpdateGameList(FocusKey := "") {
		Critical 500
		
		this.SetDefault()
		this.Options("ListView", this.GameListViewHWND)
		
		this.LV_Colors_OnMessage(false)
		
		ImageList := IL_Create(5)
		LV_SetImageList(ImageList)
		
		this.Control("-Redraw", this.GameListViewHWND)
		
		LV_Delete()
		
		for Process, Info in GameRules {
			if StrLen(Info.Title)
				Title := Info.Title
			else
				SplitPath, Process,,,, Title
			
			img := IL_Add(ImageList, StrLen(Info.Icon)?Info.Icon:Process)
			
			Pos := LV_Add("Icon" . img, StrLen(Title)?Title:FileName, Process)
			
			if (FocusKey = Process)
				Settings.GuiState.GameListPos := Pos
		}
		
		
		this.LV_Colors_OnMessage(true)
		
		this.GameListViewSelection()
		this.GameListViewSize()
		
		this.Control("+Redraw", this.GameListViewHWND)
		
		return
	}
	
	GameListViewSelection() {
		this.SetDefault()
		this.Options("ListView", this.GameListViewHWND)
		
		Pos:=LV_GetNext()
		
		LV_Modify(Pos?Settings.GuiState.GameListPos:=Pos:Settings.GuiState.GameListPos, "Select Vis Focus")
		
		if Pos {
			LV_GetText(Key, Pos, 2)
			this.SetText("msctls_trackbar321", GameRules[Key].Vibrancy)
			this.SetText("Button3", GameRules[Key].BlockWinKey)
			this.SetText("Button4", GameRules[Key].BlockAltTab)
		}
		
		return
	}
	
	GameListViewSize() {
		Critical 500
		
		this.SetDefault()
		this.Options("ListView", this.GameListViewHWND)
		
		if ((LV_EX_GetRowHeight(this.GameListViewHWND) * LV_GetCount()) > this.LV_HEIGHT)
			LV_ModifyCol(1, this.HALF_WIDTH - VERT_SCROLL - 1)
		else
			LV_ModifyCol(1, this.HALF_WIDTH - 1)
		
		LV_ModifyCol(2, 0)
	}
	
	/*
		*** BINDER ***
	*/
	
	AddBind() {
		this.Disable()
		CreateNugget(this.BindCallback.Bind(this), true, this.hwnd) ; callback, hotkeycontrol, owner
	}
	
	; bug, when overwriting, it doesn't default the focus to the window
	BindCallback(Bind := "", Key := "") {
		
		if !IsObject(Bind)
			return this.Enable()
		
		if IsObject(Keybinds[Key]) { ; key is already bound
			MsgBox, 52, Duplicate Hotkey, % "This key is already in use!`n`nPrevious function: " Keybinds[Key].Desc "`n`nOverwrite previous function?"
			ifMsgBox no ; regret
			return this.Enable()
			else ; remove the previous key nuggeterino
				Keybinds.Remove(Key)
		}
		
		Keybinds[Key] := Bind
		
		this.UpdateBindList(Key)
		
		this.SetDefault()
		this.Options("ListView", this.BindListViewHWND)
		
		Loop % LV_GetCount() {
			LV_GetText(LVKey, A_Index, 3)
			if (LVKey = Key) {
				this.BindHistory.Insert({Event:"Addition", Key:Key, Pos:A_Index})
				break
			}
		}
		
		this.Enable()
		this.Activate()
		
		return
	}
	
	DeleteBind() {
		Critical 500
		
		this.SetDefault()
		this.Options("ListView", this.BindListViewHWND)
		
		LV_GetText(RealKey, Pos:=LV_GetNext(), 3)
		
		if (RealKey = "realkey") ; if list is empty, output defaults to header which is 'realkey'
			return
		
		this.BindHistory.Insert({Event:"Deletion", Key:RealKey, Bind:Keybinds[RealKey], Pos:Pos})
		Keybinds.Remove(RealKey)
		LV_Delete(Pos)
		
		LV_Modify((LV_GetCount()<Pos?LV_GetCount():Pos), "Focus Select Vis") ; select closest new row
		
		this.BindListViewSize()
	}
	
	RegretBind() {
		this.SetDefault()
		this.Options("ListView", this.BindListViewHWND)
		
		Info := this.BindHistory.Pop()
		
		if !IsObject(Info)
			return
		
		if (Info.Event = "Deletion") {
			Keybinds[Info.Key] := Info.Bind
			LV_Insert(Info.Pos, "Focus Select Vis", HotkeyToString(Info.Key), Info.Bind.Desc, Info.Key)
		} else if (Info.Event = "Addition") { ; a fine one
			Keybinds.Remove(Info.Key)
			LV_Delete(Info.Pos)
		}
		
		this.BindListViewSize()
	}
	
	UpdateBindList(FocusKey:= "") {
		Critical 500
		
		static icon_func := { "Screenshot":140
						, "Open":15}
		
		static icon_instr := {"Launch website: ":13
						, "Launch: ":24
						, "Play/Pause":178
						, "Previous Song":178
						, "Next Song":178}
		
		
		this.SetDefault()
		this.Options("ListView", this.BindListViewHWND)
		
		this.LV_Colors_OnMessage(false)
		
		this.Control("-Redraw", this.BindListViewHWND)
		
		ImageList := IL_Create(10, 2, false)
		;LV_SetImageList(ImageList)
		
		LV_Delete()
		
		for Key, Bind in Keybinds {
			
			if icon_func[Bind.Func]
				Icon := IL_Add(ImageList, "shell32.dll", icon_func[Bind.Func])
			else if (InStr(Bind.Desc, icon_instr[Bind.Desc]) = 1)
				Icon := IL_Add(ImageList, "shell32.dll", icon_instr[Bind.Desc])
			
			Pos := LV_Add("Icon" . Icon, HotkeyToString(Key), Keybinds[Key].Desc, Key)
			
			if (Key = FocusKey)
				Settings.GuiState.BindListPos := Pos
		}
		
		this.Control("+Redraw", this.BindListViewHWND)
		
		this.LV_Colors_OnMessage(true)
		
		this.BindListViewSelection()
		this.BindListViewSize()
		
		
		return
	}
	
	BindListViewSelection() {
		this.SetDefault()
		this.Options("ListView", this.BindListViewHWND)
		
		Pos:=LV_GetNext()
		
		LV_Modify(Pos?Settings.GuiState.BindListPos:=Pos:Settings.GuiState.BindListPos, "Select Vis Focus")
	}
	
	BindListViewSize() {
		Critical 500
		
		this.SetDefault()
		this.Options("ListView", this.BindListViewHWND)
		
		if (LV_EX_GetRowHeight(this.BindListViewHWND)*LV_GetCount() > this.LV_HEIGHT)
			LV_ModifyCol(2, this.HALF_WIDTH - VERT_SCROLL)
		else
			LV_ModifyCol(2, this.HALF_WIDTH)
		
		LV_ModifyCol(1, this.HALF_WIDTH)
		LV_ModifyCol(3, 0)
	}
	
	/*
		*** TABS / OTHER ***
	*/
	
	LV_Colors_OnMessage(toggle) {
		this.GameListViewCLV.OnMessage(toggle)
		this.BindListViewCLV.OnMessage(toggle)
	}
	
	TabAction() {
		this.SetDefault()
		this.SetTab(this.GuiControlGet(, "SysTabControl321"))
	}
	
	SetTab(tab) {
		this.SetDefault()
		
		for Index, HWND in [Big.GamesHWND, Big.ImgurHWND, Big.KeybindsHWND]
			CtlColors.Change(HWND, ((tab = A_Index) ? Settings.Color.Tab : "FFFFFF"), ((tab = A_Index) ? "FFFFFF" : "000000"))
		
		this.ActiveTab := tab
		this.Control("Choose", "SysTabControl321", tab)
		
		Hotkey.Disable("Delete")
		Hotkey.Disable("^z")
		this.DropFilesToggle(false)
		this.SetTitle(AppName " v" AppVersion)
		
		if (tab = 1) {
			Hotkey.Bind("Delete", this.DeleteProg.Bind(this), this.hwnd)
			Hotkey.Bind("^z", this.RegretProg.Bind(this), this.hwnd)
			this.Control("Focus", "SysListView321")
			this.ImgurAnimate(false)
		} else if (tab = 2) {
			this.DropFilesToggle(true)
			this.ImgurAnimate(true) ; animate gifs
			this.Options("ListView", this.ImgurListViewHWND)
			LV_Modify(1, "Vis") ; show first item
		} else if (tab = 3) {
			Hotkey.Bind("Delete", this.DeleteBind.Bind(this), this.hwnd)
			Hotkey.Bind("^z", this.RegretBind.Bind(this), this.hwnd)
			this.Control("SysListView323")
			this.SetTitle(AppName " v" AppVersion " (Keybinds are disabled while window is open)")
			this.ImgurAnimate(false)
		}
	}
	
	Open(tab := "") {
		static IsShown := false ; fix ctlcolor issue :'(
		
		if this.IsVisible
			return WinActivate(this.ahkid)
		
		if SetGUI.IsVisible
			return
		
		for Key in Keybinds ; disable all hotkeys
			Hotkey.Disable(Key)
		
		this.LV_Colors_OnMessage(true)
		
		if tab
			this.SetTab(tab)
		
		this.Show("x" A_ScreenWidth/2 - this.HALF_WIDTH " y" A_ScreenHeight/2 - 164 " w" this.HALF_WIDTH*2)
		
		if !tab
			this.SetTab(Settings.GuiState.ActiveTab)
		
		if !IsShown {
			if FileExist("icon.ico") && !A_IsCompiled {
				hIcon := DllCall( "LoadImage", UInt,0, Str, A_WorkingDir "\icon.ico", UInt,1, UInt,0, UInt,0, UInt,0x10 )
				SendMessage, 0x80, 0, hIcon ,, % this.ahkid  ; One affects Title bar and
				SendMessage, 0x80, 1, hIcon ,, % this.ahkid  ; the other the ALT+TAB menu
			}
			
			IsShown := true
		}
	}
	
	Save() {
		JSONSave("Settings", Settings)
		JSONSave("Keybinds", Keybinds)
		JSONSave("GameRules", GameRules)
	}
	
	Escape() {
		this.Close()
	}
	
	Close() {
		Settings.GuiState.ActiveTab := this.ActiveTab
		
		this.Save()
		this.Hide()
		
		this.ImgurAnimate(false)
		
		this.LV_Colors_OnMessage(false)
		
		for Key, Bind in Keybinds ; rebind hotkeys
			Hotkey.Bind(Key, Actions[Bind.Func].Bind(Actions, Bind.Param*))
	}
	
	ImageButtonApply(hwnd) {
		static RoundPx := 3
		static ButtonStyle:= [[3, "0xEEEEEE", "0xDDDDDD", "Black", RoundPx,, "Gray"] ; normal
						, [3, "0xFFFFFF", "0xDDDDDD", "Black", RoundPx,, "Gray"] ; hover
						, [3, "White", "White", "Black", RoundPx,, "Gray"] ; click
						, [3, "Gray", "Gray", "0x505050", RoundPx,, "Gray"]] ; disabled
		
		If !ImageButton.Create(hwnd, ButtonStyle*)
			MsgBox, 0, ImageButton Error Btn2, % ImageButton.LastError
	}
}

CreateBigGUI() {
	
	Big := new BigGUI
	
	Big.Font("s14", Settings.Font)
	Big.Color("FFFFFF")
	Big.Margin(0, 0)
	
	HALF_WIDTH := Big.HALF_WIDTH
	TAB_WIDTH := Big.TAB_WIDTH
	TAB_HEIGHT := Big.TAB_HEIGHT
	LV_HEIGHT := Big.LV_HEIGHT
	BUTTON_HEIGHT := Big.BUTTON_HEIGHT
	
	Big.GamesHWND := Big.Add("Text", "x0 y0 w" TAB_WIDTH-1 " h" TAB_HEIGHT-1 " 0x200 gSelectTab Center", "Games")
	Big.ImgurHWND := Big.Add("Text", "x" TAB_WIDTH " y0 w" TAB_WIDTH-1 " h" TAB_HEIGHT-1 " 0x200 gSelectTab Center", "Imgur")
	Big.KeybindsHWND := Big.Add("Text", "x" TAB_WIDTH*2 " y0 w" TAB_WIDTH " h" TAB_HEIGHT-1 " 0x200 gSelectTab Center", "Keybinds")
	
	Big.Add("Text", "x0 y" TAB_HEIGHT-1 " h1 0x08 w" HALF_WIDTH*2+5) ; big-ass sep
	
	Big.Add("Text", "x" TAB_WIDTH - 1 " y0 w1 h" TAB_HEIGHT-1 " 0x08") ; first sep
	Big.Add("Text", "x" TAB_WIDTH*2 - 1 " y0 w1 h" TAB_HEIGHT-1 " 0x08") ; second sep
	
	CtlColors.Attach(Big.GamesHWND,, "000000")
	CtlColors.Attach(Big.ImgurHWND,, "000000")
	CtlColors.Attach(Big.KeybindsHWND,, "000000")
	
	Big.Add("Tab2", "x0 y0 w0 h0 -Wrap Choose2 AltSubmit", "Games|Imgur|Keybinds", Big.TabAction.Bind(Big))
	
	; ==========================================
	
	Big.Tab(1)
	Big.Font("s11")
	Big.GameListViewCLV := new LV_Colors(Big.GameListViewHWND := Big.Add("ListView", "x" 0 " y" TAB_HEIGHT " w" HALF_WIDTH - 1 " h" LV_HEIGHT " -HDR -Multi -E0x200 AltSubmit -TabStop", "name|path", Big.GameListViewSelection.Bind(Big)))
	Big.Font("s10")
	
	Button := Big.Add("Button", "x1 y" TAB_HEIGHT + LV_HEIGHT + 1 " w" Round(HALF_WIDTH/5*2) - 2 " h" BUTTON_HEIGHT - 1, "Remove", Big.DeleteProg.Bind(Big))
	Big.ImageButtonApply(Button)
	
	Button := Big.Add("Button", "x" Round(HALF_WIDTH/5*2) + 1 " yp w" HALF_WIDTH - Round(HALF_WIDTH/5*2) - 1 " h" BUTTON_HEIGHT - 1, "Add Program", Big.AddProg.Bind(Big))
	Big.ImageButtonApply(Button)
	
	Big.Add("Text", "x" HALF_WIDTH-1 " y" TAB_HEIGHT " w1 h" LV_HEIGHT " 0x08") ; skille
	Big.Add("Text", "x" HALF_WIDTH " y" TAB_HEIGHT + LV_HEIGHT/2 " w" HALF_WIDTH " h1 0x08") ; skille
	
	Big.Font("s11")
	
	Big.Margin(6, 4) ; nicerino margerino
	Big.VibranceTextHWND := Big.Add("Text", "x" HALF_WIDTH " y" TAB_HEIGHT + 8 " w" HALF_WIDTH " Center", "NVIDIA Vibrancy Boost")
	Big.BoostSliderHWND := Big.Add("Slider", "x" HALF_WIDTH + 12 " yp+25 w" HALF_WIDTH - 24 " Range50-100 ToolTip Center",, Big.GamesSlider.Bind(Big))
	Big.Add("CheckBox", "yp+56", "Block Windows Key", Big.GamesWinBlock.Bind(Big))
	Big.AltTabBlockHWND := Big.Add("CheckBox", "x430 yp", "Block Alt-Tab", Big.GamesAltTabBlock.Bind(Big))
	
	Big.Add("Text", "x" HALF_WIDTH + 6 " y" 158 " W" HALF_WIDTH - 12 " Center", "Select Screen:")
	
	SysGet, MonitorCount, MonitorCount
	
	Big.Font(MonitorCount>1?"s16":"s13")
	
	for MonID, Mon in MonitorSetup(HALF_WIDTH - 12, 100, 4) {
		HWND := Big.Add("Text"
					, "x" HALF_WIDTH + 6 + Mon.X
					. " y" 186 + Mon.Y
					. " w" Mon.W
					. " h" Mon.H
					. " +Border 0x200 Center gSelectScreen", MonitorCount>1?MonID:"Primary Selected!")
		Big.MonitorHWND[MonID] := HWND
	}
	
	Big.Font("s11")
	
	Big.SelectScreen(Settings.VibrancyScreen+1)
	
	if Settings.NvAPI_InitFail { ; no nvidia card detected, grey out/disable some controls..
		Big.Control("Disable", Big.BoostSliderHWND)
		Big.Control("Disable", Big.DefaultSliderHWND)
		Big.Font("c808080")
		Big.Control("Font", "Static9")
		Big.Font("cBlack")
	}
	
	if (MonitorCount = 1) || (Settings.NvAPI_InitFail) {
		Big.Control("Disable", "Static10")
		for MonitorID, HWND in Big.MonitorHWND
			Big.Control("Disable", HWND)
		CtlColors.Change(Big.MonitorHWND.1, "FFFFFF", "000000")
	}
	
	Big.GameListViewCLV.SelectionColors("0x" . Settings.Color.Selection, "0xFFFFFF")
	Big.GameListViewCLV.Critical := 500
	
	Big.UpdateGameList()
	
	
	; ==========================================
	
	Big.Tab(2)
	Big.Font("s1")
	Big.ImgurListViewHWND := Big.Add("ListView", "x0 y" TAB_HEIGHT " w" HALF_WIDTH*2 " h" LV_HEIGHT " -HDR +Multi +Icon AltSubmit cWhite -E0x200 -TabStop gImgurListViewAction +Background" Settings.Color.Dark, "empty|index") ; LVS_EX_HIDELABELS 0x00020000
	
	Big.Font("s10")
	
	SIXTH_WIDTH := HALF_WIDTH*2/6
	
	Big.StartStopButtonHWND := Big.Add("Button", "x" TAB_WIDTH " y" TAB_HEIGHT + LV_HEIGHT + 1 " w" SIXTH_WIDTH*3/4 - 1 " h" BUTTON_HEIGHT - 1 " Disabled", "Pause", Big.StartStopQueue.Bind(Big))
	;this.ImageButtonApply(Big.StartStopButtonHWND)
	
	Big.ClearButtonHWND := Big.Add("Button", "x" TAB_WIDTH + SIXTH_WIDTH*3/4 " yp w" SIXTH_WIDTH*3/4 " h" BUTTON_HEIGHT - 1 " Disabled", "Clear", Big.ClearQueue.Bind(Big))
	;this.ImageButtonApply(Big.ClearButtonHWND)
	
	Button := Big.Add("Button", "x" TAB_WIDTH + SIXTH_WIDTH*3/2 " yp w" HALF_WIDTH/2 - 1 " h" BUTTON_HEIGHT - 1, "Open in Browser", Big.ImgurOpenLinks.Bind(Big))
	Big.ImageButtonApply(Button)
	
	Button := Big.Add("Button", "x" TAB_WIDTH + SIXTH_WIDTH*3/2 + HALF_WIDTH/2 " yp w" SIXTH_WIDTH " h" BUTTON_HEIGHT - 1, "Delete", Big.ImgurDelete.Bind(Big))
	Big.ImageButtonApply(Button)
	
	Big.Font("s11")
	
	Big.ImgurStatusHWND := Big.Add("Text", "x" 6 " yp+2 w" TAB_WIDTH - 6 " h" BUTTON_HEIGHT - 2)
	
	Big.UpdateImgurList()
	
	; ==========================================
	
	Big.Tab(3)
	Big.Margin(0, 0)
	Big.Font("s11")
	Big.BindListViewHWND := Big.Add("ListView", "x0 y" TAB_HEIGHT " w" HALF_WIDTH*2+1 " h" LV_HEIGHT " -HDR -Multi AltSubmit -E0x200 -TabStop", "desc|key|realkey", Big.BindListViewSelection.Bind(Big))
	Big.BindListViewCLV := new LV_Colors(Big.BindListViewHWND)
	Big.BindListViewCLV.Critical := 500
	Big.BindListViewCLV.SelectionColors("0x" Settings.Color.Selection, "0xFFFFFF")
	Big.Font("s10")
	
	Button := Big.Add("Button", "x1 y" TAB_HEIGHT + LV_HEIGHT + 1 " w" HALF_WIDTH - 2 " h" BUTTON_HEIGHT - 1 " Center", "Delete Keybind", Big.DeleteBind.Bind(Big))
	Big.ImageButtonApply(Button)
	
	Button := Big.Add("Button", "x" HALF_WIDTH + 1 " yp w" HALF_WIDTH - 2 " h" BUTTON_HEIGHT - 1 " Center", "Add a Keybind", Big.AddBind.Bind(Big))
	Big.ImageButtonApply(Button)
	
	Big.UpdateBindList()
	
	; ==========================================
	
	Big.LV_Colors_OnMessage(false)
	Big.Options("-MinimizeBox")
	return
	
	ImgurListViewAction:
	Big.ImgurListViewSelection(A_GuiEvent)
	return
	
	SelectScreen:
	Big.SelectScreen(A_GuiControl)
	return
	
	SelectTab:
	Big.SetTab(A_GuiControl="Games"?1:(A_GuiControl="Imgur"?2:3))
	return
}