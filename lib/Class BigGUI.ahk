Class BigGUI extends GUI {
	static BindHistory := [], GamesHistory := [], MonitorHWND := []
	static HALF_WIDTH := 270, TAB_HEIGHT := 32, LV_HEIGHT := 240, BUTTON_HEIGHT := 26, TAB_WIDTH := 180
	static EXPAND_SIZE := 206
	static AnimatedImages := {}
	static AnimatedPositions := {}
	static AnimatedEnabled := false
	
	/*
		*** IMGUR ***
	*/
	
	; drag/drop
	DropFiles(FileList, FileCount, ControlHWND, GuiX, GuiY) {
		if (this.ActiveTab = 1) {
			for Index, File in StrSplit(FileList, "`n") {
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
			} if StrLen(AddFile) {
				JSONSave("GameRules", GameRules)
				this.UpdateGameList(AddFile)
			} else
				TrayTip("Only exe and lnk files are allowed!")
		} else if (this.ActiveTab = 2) {
			for Index, File in StrSplit(FileList, "`n") {
				SplitPath, File,,, ext
				if (ext ~= Uploader.AllowedExt)
					Uploader.Upload(File)
				else 
					Uploader.QueueErrors.Push(ext " files are not allowed on imgur!")
			} if !Uploader.RunQueue
				Uploader.StartQueue()
		}
	}
	
	ImgurGetSelected() {
		Indexes := []
		
		while (i:=this.ImgurLV.GetNext(i)) {
			Index := this.ImgurLV.GetText(i, 2)
			Indexes[A_Index] := Index
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
		
		this.LV_Colors_OnMessage(false)
		
		this.ImgurImageWidth:=124
		this.ImgurImageHeight:=70
		
		this.ImgurLV.IL := new CustomImageList(this.ImgurImageWidth, this.ImgurImageHeight, 0x20, 50, 5) ; custom res imagelist
		
		this.ImgurLV.IL.GifPeriod := Settings.Imgur.GifPeriod
		
		this.ImgurLV.SetImageList(this.ImgurLV.IL.ID, true)
		this.ImgurLV.Delete()
		
		for Date, Image in Images, New := []
			New.Push(Date)
		
		Loop % Settings.Imgur.ListViewMax
			this.ImgurListAdd(New[New.MaxIndex() - A_Index + 1], false, false)
		
		this.ImgurFixOrder()
		
		sep:=5 ; separator between images
		
		LV_EX_SetIconSpacing(this.ImgurLV.hwnd, this.ImgurImageWidth + sep, this.ImgurImageHeight + sep)
		
		this.ImgurListViewSelection()
		
		this.LV_Colors_OnMessage(true)
	}
	
	ImgurListAdd(Index, FixOrder := true, Insert := true) {
		
		if !Images.HasKey(Index)
			return false
		
		this.ImgurLV.Redraw(false)
		
		Image := Images[Index]
		
		if (Image.extension = "gif") {
			IconList := this.ImgurLV.IL.AddGif(Uploader.ImgurImageFolder "\" Image.id "." image.extension)
			this.AnimatedImages[Index] := IconList
			this.AnimatedPositions[Index] := 1
			IconNumber := IconList.1
		} else
			IconNumber := this.ImgurLV.IL.AddImage(Uploader.ImgurImageFolder "\" Image.id "." image.extension)
		
		if IconNumber {
			if Insert
				this.ImgurLV.Insert(1, "Icon" . IconNumber,, Index)
			else
				this.ImgurLV.Add("Icon" . IconNumber,, Index)
		}
		
		if FixOrder
			this.ImgurFixOrder()
		
		return !!IconNumber
	}
	
	ImgurListRemove(Index) {
		this.ImgurLV.Redraw(false)
		
		Loop % this.ImgurLV.GetCount()
		{
			LV_Index := this.ImgurLV.GetText(A_Index, 2)
			if (LV_Index = Index)
				this.ImgurLV.Delete(A_Index)
		}
		
		this.ImgurFixOrder()
	}
	
	; when inserting to the first item position in a listview in icon mode, it doesn't add the item to the correct location (the first index).
	; so to fix, we change it to report view and back. and poof. magic.
	ImgurFixOrder() {
		
		this.Control("+Report", this.ImgurLV.hwnd)
		sleep 1
		this.Control("+Icon", this.ImgurLV.hwnd)
		sleep 1
		this.ImgurLV.Redraw(true)
		sleep 1
		
		this.ImgurLV.Modify(1, "Vis")
	}
	
	ImgurAnimateTick() {
		
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
			text := this.ImgurLV.GetText(A_Index, 2)
			if this.AnimatedPositions.HasKey(text)
				this.ImgurLV.Modify(A_Index, "Icon" . this.AnimatedImages[text][this.AnimatedPositions[text]]) 
		} until !StrLen(text)
	}
	
	ImgurListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "DoubleClick")
			this.ImgurCopyLinks()
	}
	
	ImgurDelete() {
		Selected := this.ImgurGetSelected()
		
		if !Selected.MaxIndex()
			return
		
		MsgBox, 52, Image deletion, % Selected.MaxIndex() " image" (Selected.MaxIndex()>1?"s":"") " selected.`nProceed with deletion?"
		ifMsgBox no
		return
		
		for Index, ImageIndex in Selected
			Uploader.Delete(ImageIndex)
	}
	
	ImgurOpenLinks() {
		Selected := this.ImgurGetSelected()
		
		if (ArraySize(Selected) > 7) { ; display a warning at 8+ images
			MsgBox,262196,Warning!,% "Are you sure you want to open " ArraySize(Selected) " images?"
			ifMsgBox no
			return
		}
		
		for Index, ImageIndex in this.ImgurGetSelected()
			Run(Images[ImageIndex].link)
		
		if Settings.Imgur.CloseOnOpen && Index
			this.Close()
	}
	
	ImgurCopyLinks() {
		for Index, ImageIndex in Selected := this.ImgurGetSelected()
			links .= Images[ImageIndex].link . Settings.Imgur.CopySeparator
		
		if !StrLen(links)
			return
		
		clipboard := rtrim(links, " ")
		
		Size := ArraySize(Selected)
		
		TrayTip("Link" (Size>1?"s":"") " copied!", (Size>1?Size " links were copied to your clipboard":clipboard))
		
		if Settings.Imgur.CloseOnCopy && StrLen(links)
			this.Close()
	}
	
	StartStopQueue() {
		if Uploader.RunQueue
			Uploader.StopQueue()
		else if !Uploader.Busy
			Uploader.StartQueue()
	}
	
	ClearQueue() {
		if Uploader.Busy ; uploader is working, don't do anything
			return
		
		this.SetText(this.StartStopButtonHWND, "Stop")
		this.QueueControl(false)
		Uploader.ClearQueue()
	}
	
	ClearQueueControl(Toggle) {
		this.Control(Toggle?"Enable":"Disable", this.ClearButtonHWND)
	}
	
	QueueControl(Toggle) {
		this.Control(Toggle?"Enable":"Disable", this.StartStopButtonHWND)
	}
	
	ImgurStatus(Status) {
		this.QueueLV.ModifyCol(1,, "Status: " Status)
	}
	
	/*
		*** GAMES ***
	*/
	
	; probably temporary (right?????)
	AddProg() {
		this.Disable()
		AppSelect(this.AddProgCallback.Bind(this), this.hwnd)
	}
	
	AddProgCallback(Info) {
		
		this.Enable()
		this.Activate()
		
		if !IsObject(Info)
			return
		
		Game := {BlockAltTab:false, BlockWinKey:true, Vibrancy:50}
		
		if StrLen(Info.DisplayName)
			Game.Title := Info.DisplayName
		
		if StrLen(Info.DisplayIcon)
			Game.Icon := Info.DisplayIcon
		
		GameRules[Info.InstallLocation] := Game
		
		JSONSave("GameRules", GameRules)
		
		this.UpdateGameList(Info.InstallLocation)
		
		Loop % this.GameLV.GetCount() {
			LVKey := this.GameLV.GetText(A_Index, 2)
			if (LVKey = Info.InstallLocation) {
				this.GamesHistory.Insert({Event:"Addition", Key:Info.InstallLocation, Pos:A_Index})
				break
			}
		}
	}
	
	DeleteProg() {
		Key := this.GameLV.GetText(Pos := this.GameLV.GetNext(), 2)
		
		if (Key = "path") || !StrLen(Key)
			return
		
		if !IsObject(GameRules[Key]) {
			Error("Attempted deletion doesn't exist in GameRules", A_ThisFunc, "Pos: " pos "`nKey: " Key)
			return
		}
		
		this.GameLV.Delete(Pos)
		this.GameLV.Modify((this.GameLV.GetCount()<Pos?this.GameLV.GetCount():Pos), "Focus Select Vis")
		
		if !IsObject(Prog:=GameRules.Remove(Key)) {
			; shit
			return
		}
		
		this.GamesHistory.Insert({Event:"Deletion", Key:Key, Prog:Prog, Pos:Pos})
		
		this.GameListViewSize()
	}
	
	RegretProg() {
		Info := this.GamesHistory.Pop()
		
		if !IsObject(Info)
			return
		
		if (Info.Event = "Deletion") {
			GameRules[Info.Key] := Info.Prog
			this.UpdateGameList()
			this.GameLV.Modify(Info.Pos, "Focus Vis Select")
		} else if (Info.Event = "Addition") {
			GameRules.Remove(Info.Key)
			this.GameLV.Delete(Info.Pos)
			this.GameLV.Modify(Info.Pos>this.GameLV.GetCount()?this.GameLV.GetCount():Info.Pos, "Select Focus Vis")
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
		LV_GetText(Key, LV_GetNext(), 2)
		
		Key := this.GameLV.GetText(this.GameLV.GetNext(), 2)
		
		if (Key = "path") || !StrLen(Key)
			return 
		else if !IsObject(GameRules[Key])
			return Error("Key not found in GameRules Array", A_ThisFunc, "Key: " Key)
		else
			return Key
	}
	
	UpdateGameList(FocusKey := "") {
		Critical 500
		
		this.LV_Colors_OnMessage(false)
		
		IL := new this.ImageList(this.GameLV)
		
		this.GameLV.SetImageList(IL.ID)
		
		this.GameLV.Redraw(false)
		
		this.GameLV.Delete()
		
		for Process, Info in GameRules {
			if StrLen(Info.Title)
				Title := Info.Title
			else
				SplitPath, Process,,,, Title
			
			img := IL.Add(StrLen(Info.Icon)?Info.Icon:Process)
			
			Pos := this.GameLV.Add("Icon" . img, StrLen(Title)?Title:FileName, Process)
			
			if (FocusKey = Process)
				Settings.GuiState.GameListPos := Pos
		}
		
		
		this.LV_Colors_OnMessage(true)
		
		this.GameListViewSelection()
		this.GameListViewSize()
		
		this.GameLV.Redraw(true)
	}
	
	GameListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "C") {
			Pos := (EventInfo?EventInfo:this.GameLV.GetNext())
			this.GameLV.Modify(Pos, "Select Vis Focus")
			if Pos {
				Key := this.GameLV.GetText(Pos, 2)
				this.SetText("msctls_trackbar321", GameRules[Key].Vibrancy)
				this.SetText("Button3", GameRules[Key].BlockWinKey)
				this.SetText("Button4", GameRules[Key].BlockAltTab)
			}
		}
	}
	
	GameListViewSize() {
		Critical 500
		
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
		Keybinds(false)
		CreateNugget(this.BindCallback.Bind(this), true, this.hwnd) ; callback, hotkeycontrol, owner
	}
	
	; bug, when overwriting, it doesn't default the focus to the window
	BindCallback(Bind := "", Key := "") {
		
		
		if !IsObject(Bind) {
			this.Enable(), Keybinds(true)
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
	
	DeleteBind() {
		Critical 500
		
		RealKey := this.BindLV.GetText(Pos:=this.BindLV.GetNext(), 3)
		
		if (RealKey = "realkey") || !StrLen(RealKey) ; if list is empty, it EITHER output defaults to header which is 'realkey', OR gets empty. it's weird
			return
		
		this.BindHistory.Insert({Event:"Deletion", Key:RealKey, Bind:Keybinds[RealKey], Pos:Pos})
		Keybinds.Remove(RealKey)
		this.BindLV.Delete(Pos)
		
		this.BindLV.Modify((this.BindLV.GetCount()<Pos?this.BindLV.GetCount():Pos), "Focus Select Vis") ; select closest new row
		
		this.BindListViewSize()
		
		; disable the hotkey if it isn't a gui hotkey
		if (RealKey != "Delete") && (RealKey != "^z")
			Hotkey.Disable(RealKey)
	}
	
	RegretBind() {
		Info := this.BindHistory.Pop()
		
		if !IsObject(Info)
			return
		
		if (Info.Event = "Deletion") {
			Keybinds[Info.Key] := Info.Bind
			this.BindLV.Insert(Info.Pos, "Focus Select Vis", HotkeyToString(Info.Key), Info.Bind.Desc, Info.Key)
		} else if (Info.Event = "Addition") { ; a fine one
			Keybinds.Remove(Info.Key)
			this.BindLV.Delete(Info.Pos)
		}
		
		this.BindListViewSize()
		
		if (Info.Key != "Delete") && (Info.Key != "^z")
			Hotkey.Bind(Info.Key, Actions[Info.Bind.Func].Bind(Actions, Info.Bind.Param*))
	}
	
	UpdateBindList(FocusKey:= "") {
		Critical 500
		
		this.LV_Colors_OnMessage(false)
		
		this.BindLV.Redraw(false)
		
		this.BindLV.Delete()
		
		for Key, Bind in Keybinds {
			Pos := this.BindLV.Add(, HotkeyToString(Key), Keybinds[Key].Desc, Key)
			if (Key = FocusKey)
				Settings.GuiState.BindListPos := Pos
		}
		
		this.BindLV.Redraw(true)
		
		this.LV_Colors_OnMessage(true)
		
		this.BindListViewSelection()
		this.BindListViewSize()
	}
	
	BindListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "C")
			this.BindLV.Modify(this.BindLV.GetNext(), "Select Vis Focus")
	}
	
	BindListViewSize() {
		Critical 500
		
		if (LV_EX_GetRowHeight(this.BindLV.hwnd)*LV_GetCount() > this.LV_HEIGHT)
			this.BindLV.ModifyCol(2, this.HALF_WIDTH - VERT_SCROLL)
		else
			this.BindLV.ModifyCol(2, this.HALF_WIDTH)
		
		this.BindLV.ModifyCol(1, this.HALF_WIDTH)
		this.BindLV.ModifyCol(3, 0)
	}
	
	/*
		*** TABS / OTHER ***
	*/
	
	LV_Colors_OnMessage(toggle) {
		this.GameLV.CLV.OnMessage(toggle)
		this.BindLV.CLV.OnMessage(toggle)
	}
	
	TabAction() {
		this.SetDefault()
		this.SetTab(this.GuiControlGet(, "SysTabControl321"))
	}
	
	SetTab(tab) {
		this.SetDefault()
		
		this.ActiveTab := tab
		this.Control("Choose", "SysTabControl321", tab)
		
		if (tab = 1) {
			this.Control("Focus", "SysListView321")
			this.SelectScreen(Settings.VibrancyScreen + 1)
			this.ImgurAnimate(false)
			this.DropFilesToggle(true)
			this.Pos(,,, this.TAB_HEIGHT + this.LV_HEIGHT + this.BUTTON_HEIGHT + 1)
		} else if (tab = 2) {
			this.Options("ListView", this.ImgurLV.hwnd)
			LV_Modify(1, "Vis") ; show first item
			LV_Modify(0, "-Select") ; show first item
			this.ImgurAnimate(true) ; animate gifs
			this.DropFilesToggle(true)
			this.ImgurExpand(this.ExpandState)
		} else if (tab = 3) {
			this.Control("Focus", "SysListView323")
			this.ImgurAnimate(false)
			this.DropFilesToggle(false)
			this.Pos(,,, this.TAB_HEIGHT + this.LV_HEIGHT + this.BUTTON_HEIGHT + 1)
		}
		
		this.SetTabHotkeys(tab)
		this.SetTabColor(tab)
	}
	
	SetTabHotkeys(tab) {
		if (tab = 1) {
			Hotkey.Bind("Delete", this.DeleteProg.Bind(this), this.hwnd)
			Hotkey.Bind("^z", this.RegretProg.Bind(this), this.hwnd)
		} else if (tab = 2) {
			Hotkey.Bind("Delete", this.ImgurDelete.Bind(this), this.hwnd)
			Hotkey.Disable("^z")
		} else if (tab = 3) {
			Hotkey.Bind("Delete", this.DeleteBind.Bind(this), this.hwnd)
			Hotkey.Bind("^z", this.RegretBind.Bind(this), this.hwnd)
		}
	}
	
	ImgurExpand(Expand) {
		if Expand {
			this.Pos(,,, this.TAB_HEIGHT + this.LV_HEIGHT + this.BUTTON_HEIGHT + this.EXPAND_SIZE + 1)
		} else {
			this.Pos(,,, this.TAB_HEIGHT + this.LV_HEIGHT + this.BUTTON_HEIGHT + 25)
		} this.ExpandState := Expand
	}
	
	QueueListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "ColClick") ; clicked on header
			this.ImgurExpand(this.ExpandState := !this.ExpandState)
	}
	
	SetTabColor(tab) {
		for Index, HWND in [Big.GamesHWND, Big.ImgurHWND, Big.KeybindsHWND]
			CtlColors.Change(HWND, ((tab = A_Index) ? Settings.Color.Tab : "FFFFFF"), ((tab = A_Index) ? "FFFFFF" : "000000"))
	}
	
	Open(tab := "") {
		static IsShown := false
		
		if this.IsVisible
			return this.Activate()
		
		if SetGUI.IsVisible
			return
		
		this.LV_Colors_OnMessage(true)
		
		this.Show("x" A_ScreenWidth/2 - this.HALF_WIDTH " y" A_ScreenHeight/2 - 164 " w" this.HALF_WIDTH*2)
		
		if tab
			this.SetTab(tab)
		
		this.SetTabColor(tab?tab:this.ActiveTab)
		this.SetTabHotkeys(tab?tab:this.ActiveTab)
		
		if !IsShown {
			this.SetTitle(AppName " " AppVersionString)
			this.SetTab(tab?tab:this.ActiveTab)
			this.SetIcon(Icon("icon"))
			IsShown := true
		}
	}
	
	Save() {
		Settings.GuiState.ActiveTab := this.ActiveTab
		Settings.GuiState.ExpandState := this.ExpandState
		JSONSave("Settings", Settings)
		JSONSave("Keybinds", Keybinds)
		JSONSave("GameRules", GameRules)
	}
	
	Escape() {
		if (this.ActiveTab = 2) && (this.ExpandState)
			this.ImgurExpand(false)
		else
			this.Close()
	}
	
	Close() {
		this.Save()
		this.Hide()
		this.ImgurAnimate(false)
		this.LV_Colors_OnMessage(false)
		Keybinds(true)
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
	EXPAND_SIZE := Big.EXPAND_SIZE
	
	; ==========================================
	
	; tab text controls
	Big.GamesHWND := Big.Add("Text", "x0 y0 w" TAB_WIDTH-1 " h" TAB_HEIGHT-1 " 0x200 gSelectTab Center", "Games")
	Big.ImgurHWND := Big.Add("Text", "x" TAB_WIDTH " y0 w" TAB_WIDTH-1 " h" TAB_HEIGHT-1 " 0x200 gSelectTab Center", "Imgur")
	Big.KeybindsHWND := Big.Add("Text", "x" TAB_WIDTH*2 " y0 w" TAB_WIDTH " h" TAB_HEIGHT-1 " 0x200 gSelectTab Center", "Keybinds")
	
	; separators
	Big.Add("Text", "x0 y" TAB_HEIGHT-1 " h1 0x08 w" HALF_WIDTH*2+5) ; big-ass sep
	Big.Add("Text", "x" TAB_WIDTH - 1 " y0 w1 h" TAB_HEIGHT-1 " 0x08") ; first sep
	Big.Add("Text", "x" TAB_WIDTH*2 - 1 " y0 w1 h" TAB_HEIGHT-1 " 0x08") ; second sep
	
	; attach to ctlcolors
	CtlColors.Attach(Big.GamesHWND,, "000000")
	CtlColors.Attach(Big.ImgurHWND,, "000000")
	CtlColors.Attach(Big.KeybindsHWND,, "000000")
	
	Big.Add("Tab2", "x0 y0 w0 h0 -Wrap Choose2 AltSubmit", "Games|Imgur|Keybinds", Big.TabAction.Bind(Big))
	
	; ==========================================
	
	Big.Tab(1)
	Big.Font("s11")
	Big.GameLV := new Big.ListView(Big, "x" 0 " y" TAB_HEIGHT " w" HALF_WIDTH - 1 " h" LV_HEIGHT " -HDR -Multi -E0x200 AltSubmit -TabStop", "name|path", Big.GameListViewAction.Bind(Big))
	Big.GameLV.CLV := new LV_Colors(Big.GameLV.hwnd)
	Big.Font("s10")
	
	Button := Big.Add("Button", "x1 y" TAB_HEIGHT + LV_HEIGHT + 1 " w" Round(HALF_WIDTH/5*2) - 2 " h" BUTTON_HEIGHT - 1, "Remove", Big.DeleteProg.Bind(Big))
	ImageButtonApply(Button)
	
	Button := Big.Add("Button", "x" Round(HALF_WIDTH/5*2) + 1 " yp w" HALF_WIDTH - Round(HALF_WIDTH/5*2) - 1 " h" BUTTON_HEIGHT - 1, "Add Program", Big.AddProg.Bind(Big))
	ImageButtonApply(Button)
	
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
	
	Big.GameLV.CLV.SelectionColors("0x" . Settings.Color.Selection, "0xFFFFFF")
	Big.GameLV.CLV.Critical := 500
	
	Big.UpdateGameList()
	
	; ==========================================
	
	/*
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
		
		Big.ImgurStatusHWND := Big.Add("Text", "x" 6 " yp+2 w" TAB_WIDTH - 6 " h" BUTTON_HEIGHT - 2, "Uploads appear here!")
	*/
	
	Big.Tab(2)
	Big.Font("s1")
	Big.ImgurLV := new Big.ListView(Big, "x0 y" TAB_HEIGHT " w" HALF_WIDTH*2 " h" LV_HEIGHT + BUTTON_HEIGHT + 1 " -HDR +Multi +Icon AltSubmit cWhite -E0x200 -TabStop +Background" Settings.Color.Dark, "empty|index", Big.ImgurListViewAction.Bind(Big))
	Big.Font("s10")
	Big.QueueLV := new Big.ListView(Big, "x0 y" TAB_HEIGHT + LV_HEIGHT + BUTTON_HEIGHT + 1 " w" HALF_WIDTH*2 " h" EXPAND_SIZE - BUTTON_HEIGHT " NoSort -Multi +LV0x4000 -E0x200 -LV0x10 -TabStop cWhite +Background" Settings.Color.Dark, "Click to open queue manager.", Big.QueueListViewAction.Bind(Big))
	;Big.QueueLV.CLV := new LV_Colors(Big.QueueLV.hwnd)
	
	Big.StartStopButtonHWND := Big.Add("Button", "x0 y" TAB_HEIGHT + LV_HEIGHT + EXPAND_SIZE + 1 " w" HALF_WIDTH " h" BUTTON_HEIGHT, "Pause", Big.StartStopQueue.Bind(Big))
	Big.ClearButtonHWND := Big.Add("Button", "x" HALF_WIDTH " y" TAB_HEIGHT + LV_HEIGHT + EXPAND_SIZE + 1 " w" HALF_WIDTH " h" BUTTON_HEIGHT, "Clear queue", Big.ClearQueue.Bind(Big))
	
	Big.UpdateImgurList()
	
	; ==========================================
	
	Big.Tab(3)
	Big.Margin(0, 0)
	Big.Font("s11")
	Big.BindLV := new Big.ListView(Big, "x0 y" TAB_HEIGHT " w" HALF_WIDTH*2+1 " h" LV_HEIGHT " -HDR -Multi AltSubmit -E0x200 -TabStop","desc|key|realkey", Big.BindListViewAction.Bind(Big))
	Big.BindLV.CLV := new LV_Colors(Big.BindLV.hwnd)
	Big.BindLV.CLV.Critical := 500
	Big.BindLV.CLV.SelectionColors("0x" Settings.Color.Selection, "0xFFFFFF")
	Big.Font("s10")
	
	Button := Big.Add("Button", "x1 y" TAB_HEIGHT + LV_HEIGHT + 1 " w" HALF_WIDTH - 2 " h" BUTTON_HEIGHT - 1 " Center", "Delete Keybind", Big.DeleteBind.Bind(Big))
	ImageButtonApply(Button)
	
	Button := Big.Add("Button", "x" HALF_WIDTH + 1 " yp w" HALF_WIDTH - 2 " h" BUTTON_HEIGHT - 1 " Center", "Add a Keybind", Big.AddBind.Bind(Big))
	ImageButtonApply(Button)
	
	Big.UpdateBindList()
	
	Big.ActiveTab := Settings.GuiState.ActiveTab
	Big.ExpandState := Settings.GuiState.ExpandState
	
	; fake gui event to init lv positions
	Big.GameListViewAction("", "C", Settings.GuiState.GameListPos)
	Big.BindListViewAction("", "C", Settings.GuiState.BindListPos)
	
	Big.LV_Colors_OnMessage(false)
	Big.Options("-MinimizeBox")
	return
	
	SelectScreen:
	Big.SelectScreen(A_GuiControl)
	return
	
	SelectTab:
	Big.SetTab(A_GuiControl="Games"?1:(A_GuiControl="Imgur"?2:3))
	return
}