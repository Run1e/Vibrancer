Class BigGUI extends GUI {
	static BindHistory := [], GamesHistory := [], MonitorHWND := []
	static HALF_WIDTH := 270, TAB_HEIGHT := 32, LV_HEIGHT := 240, BUTTON_HEIGHT := 26, TAB_WIDTH := 180
	static EXPAND_SIZE := 206
	static AnimatedImages := {}
	static AnimatedPositions := {}
	static AnimatedEnabled := false
	
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
			} if StrLen(AddFile) {
				this.Activate()
				this.UpdateGameList(AddFile)
			} else
				TrayTip("Only exe and lnk files are allowed!")
		}
		
		else if (this.ActiveTab = 2) {
			for Index, File in FileArray {
				if (File ~= Uploader.AllowedExt)
					Uploader.Upload(File)
				else 
					Uploader.QueueErrors.Push(ext " files are not allowed on imgur!")
			} if !Uploader.RunQueue
				Uploader.StartQueue()
		}
	}
	
	ContextMenu(CtrlHwnd, EventInfo, IsRightClick, X, Y) {
		static Context
		
		if (IsRightClick) && (CtrlHwnd = this.ImgurLV.hwnd) {
			if GetKeyState("SHIFT", "P") || GetKeyState("CTRL", "P")
				return
			return
			Index := this.ImgurLV.GetText(EventInfo, 2)
			
			Context := new Menu("ImgurContext")
			Context.Add("Copy link", this.ImgurCopyLinks.Bind(this))
			Context.Add("Open Image", Func("Run").Bind(Uploader.ImgurFolder "\" Images[Index].id "." Images[Index].extension))
			Context.Show()
			return
		}
	}
	
	ImgurMenuHandler(ItemName, ItemPos, MenuName) {
		m(itemname, itempos, menuname)
	}
	
	/*
		*** IMGUR ***
	*/
	
	ImgurGetSelected() {
		Indexes := []
		
		while (i:=this.ImgurLV.GetNext(i)) {
			Index := this.ImgurLV.GetText(i, 2)
			Indexes[A_Index] := Index
		}
		
		return Indexes
	}
	
	UpdateImgurList() {
		Critical 500
		
		this.ImgurImageWidth:=124
		this.ImgurImageHeight:=70
		
		this.ImgurLV.IL := new CustomImageList(this.ImgurImageWidth, this.ImgurImageHeight, 0x20, 50, 5) ; custom res imagelist
		
		this.ImgurLV.IL.GifPeriod := 200 ; 5fps
		
		this.ImgurLV.SetImageList(this.ImgurLV.IL.ID, true)
		this.ImgurLV.Delete()
		
		New := [], Rem := []
		for Date, Image in Images {
			if (FileExist(Uploader.ImgurFolder "\" Image.id  "." Image.extension) != "A")
				Rem.Push(Date)
			else
				New.Push(Date)
		}
		
		for Index, Date in Rem
			Images.Remove(Date)
		
		Loop % Settings.Imgur.ListViewMax
			this.ImgurListAdd(New[New.MaxIndex() - A_Index + 1], false, false)
		
		this.ImgurFixOrder()
		
		sep:=5 ; separator between images
		
		LV_EX_SetIconSpacing(this.ImgurLV.hwnd, this.ImgurImageWidth + sep, this.ImgurImageHeight + sep)
		
		this.ImgurListViewSelection()
	}
	
	ImgurListAdd(Index, FixOrder := true, Insert := true) {
		
		if !Images.HasKey(Index)
			return false
		
		this.ImgurLV.Redraw(false)
		
		Image := Images[Index]
		
		if (Image.extension = "gif") {
			IconList := this.ImgurLV.IL.AddGif(Uploader.ImgurFolder "\" Image.id "." Image.extension)
			this.AnimatedImages[Index] := IconList
			this.AnimatedPositions[Index] := 1
			IconNumber := IconList.1
		} else
			IconNumber := this.ImgurLV.IL.AddImage(Uploader.ImgurFolder "\" Image.id "." Image.extension)
		
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
		
		if this.AnimatedImages.HasKey(Index) {
			this.AnimatedImages.Delete(Index)
			this.AnimatedPositions.Delete(Index)
		}
		
		; note: is it possible removing images from an imagelist?
		; ^ would free memory when deleting images and especially large gifs
		
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
	
	ImgurAnimate(Toggle) {
		if Toggle && !this.AnimatedEnabled {
			SetTimer, ImgurAnimateTick, % this.ImgurLV.IL.GifPeriod
			this.AnimatedEnabled := true
		} else if this.AnimatedEnabled {
			SetTimer, ImgurAnimateTick, Off
			this.AnimatedEnabled := false
		} return
		
		ImgurAnimateTick:
		Big.ImgurAnimateTick()
		return
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
		
		for Index, ImageIndex in this.ImgurGetSelected() {
			link := Images[ImageIndex].link
			if Settings.Imgur.UseGifv
				if (SubStr(link, -2) = "gif")
					link .= "v"
			Run(link)
		}
		
		if Settings.Imgur.CloseOnOpen && Index
			this.Close()
	}
	
	ImgurCopyLinks() {
		for Index, ImageIndex in Selected := this.ImgurGetSelected() {
			link := Images[ImageIndex].link
			if Settings.Imgur.UseGifv
				if (SubStr(link, -2) = "gif")
					link .= "v"
			links .= link . (StrLen(Settings.Imgur.CopySeparator) ? Settings.Imgur.CopySeparator : " ")
		}
		
		if !StrLen(links)
			return
		
		Clipboard(rtrim(links, " "))
		
		Size := ArraySize(Selected)
		
		TrayTip("Link" (Size>1?"s":"") " copied!", (Size>1?Size " links were copied to your clipboard.":clipboard))
		
		if Settings.Imgur.CloseOnCopy && StrLen(links)
			this.Close()
	}
	
	StartStopQueue() {
		Uploader.StartStop()
	}
	
	ClearQueue() {
		Uploader.ClearQueue()
	}
	
	ClearFailedQueue() {
		Uploader.ClearFailedQueue()
	}
	
	ImgurStatus(Status) {
		this.QueueLV.ModifyCol(1,, "Status: " Status)
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
		
		Settings.VibrancyScreens := Screens
		this.ColorScreens()
	}
	
	ColorScreens() {
		for ColorScreen, HWND in this.MonitorHWND {
			for Index, SavedScreen in Settings.VibrancyScreens {
				if (ColorScreen = SavedScreen) {
					CtlColors.Change(HWND, Settings.Color.Tab, "FFFFFF")
					continue 2
				} 
			} CtlColors.Change(HWND, "FFFFFF", "000000")
		}
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
		
		
		this.GameListViewAction("", "C", Settings.GuiState.GameListPos)
		this.GameListViewSize()
		this.GameLV.Redraw(true)
	}
	
	GameListViewAction(Control, GuiEvent, EventInfo) {
		static ControlsDisabled
		if (GuiEvent = "C") || (GuiEvent = "I") {
			Pos := (EventInfo?EventInfo:this.GameLV.GetNext())
			if Pos {
				Key := this.GameLV.GetText(Pos, 2)
				if (Key = "path") || !StrLen(Key) {
					this.Control("Disable", "msctls_trackbar321")
					this.Control("Disable", "Button3")
					this.Control("Disable", "Button4")
					ControlsDisabled := true
					return
				} else if ControlsDisabled {
					if !Settings.NvAPI_InitFail
						this.Control("Enabled", "msctls_trackbar321")
					this.Control("Enabled", "Button3")
					this.Control("Enabled", "Button4")
					ControlsDisabled := false
				}
				this.SetText("msctls_trackbar321", GameRules[Key].Vibrancy)
				this.SetText("Button3", GameRules[Key].BlockWinKey)
				this.SetText("Button4", GameRules[Key].BlockAltTab)
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
		CreateNugget(this.BindCallback.Bind(this), true, this.hwnd) ; callback, hotkeycontrol, owner
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
		Keybinds.Remove(RealKey)
		this.BindLV.Delete(Pos)
		
		this.BindLV.Modify((this.BindLV.GetCount()<Pos?this.BindLV.GetCount():Pos), "Focus Select Vis") ; select closest new row
		
		this.BindListViewSize()
		
		Hotkey.GetKey(RealKey).Disable()
	}
	
	BindRegret() {
		Info := this.BindHistory.Pop()
		
		if !IsObject(Info)
			return
		
		if (Info.Event = "Deletion") {
			Keybinds[Info.Key] := Info.Bind
			NewPos := this.BindLV.Insert(Info.Pos, "Focus Select Vis", HotkeyToString(Info.Key), Info.Bind.Desc, Info.Key)
			new Hotkey(Info.Key, Actions[Info.Bind.Func].Bind(Actions, Info.Bind.Param*))
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
		
		for Key, Bind in Keybinds {
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
		this.SetDefault()
		this.SetTab(Control=this.GamesHWND?1:(Control=this.ImgurHWND?2:3))
	}
	
	SetTab(tab) {
		this.SetDefault()
		
		this.ActiveTab := tab
		this.Control("Choose", "SysTabControl321", tab)
		
		this.SetTabColor(tab)
		this.SetTabHotkeys(tab)
		
		if (tab = 1) {
			this.ColorScreens()
			this.ImgurAnimate(false)
			this.DropFilesToggle(true)
			this.Pos(,,, this.TAB_HEIGHT + this.LV_HEIGHT + this.BUTTON_HEIGHT + 1)
			this.Control("Focus", "SysListView321")
		} else if (tab = 2) {
			this.ImgurLV.Modify(1, "Vis")
			this.ImgurLV.Modify(0, "-Vis")
			this.ImgurAnimate(true) ; animate gifs
			this.DropFilesToggle(true)
			this.ImgurExpand(this.ExpandState)
			this.Control("Focus", "SysListView322")
		} else if (tab = 3) {
			this.ImgurAnimate(false)
			this.DropFilesToggle(false)
			this.Pos(,,, this.TAB_HEIGHT + this.LV_HEIGHT + this.BUTTON_HEIGHT + 1)
			this.Control("Focus", "SysListView324")
		}
	}
	
	SetTabHotkeys(tab) {
		if (tab = 1) {
			new Hotkey("Delete", this.GameDelete.Bind(this), this.ahkid)
			new Hotkey("^z", this.GameRegret.Bind(this), this.ahkid)
			Hotkey.GetKey("Space", this.ahkid).Delete()
		} else if (tab = 2) {
			new Hotkey("Delete", this.ImgurDelete.Bind(this), this.ahkid)
			new Hotkey("Space", this.ImgurExpandToggle.Bind(this), this.ahkid)
			Hotkey.GetKey("^z", this.ahkid).Delete()
		} else if (tab = 3) {
			new Hotkey("Delete", this.BindDelete.Bind(this), this.ahkid)
			new Hotkey("^z", this.BindRegret.Bind(this), this.ahkid)
			Hotkey.GetKey("Space", this.ahkid).Delete()
		}
	}
	
	SetTabColor(tab) {
		for Index, HWND in [Big.GamesHWND, Big.ImgurHWND, Big.KeybindsHWND]
			CtlColors.Change(HWND, ((tab = A_Index) ? Settings.Color.Tab : "FFFFFF"), ((tab = A_Index) ? "FFFFFF" : "000000"))
	}
	
	ImgurExpandToggle() {
		this.ImgurExpand(this.ExpandState := !this.ExpandState)
	}
	
	ImgurExpand(Expand) {
		this.Pos(,,, this.TAB_HEIGHT + this.LV_HEIGHT + this.BUTTON_HEIGHT + (Expand?this.EXPAND_SIZE+1:25))
		this.ExpandState := Expand
	}
	
	Open(tab := "") {
		if this.IsVisible {
			this.LVRedraw(false)
			this.Activate()
			this.LVRedraw(true)
			return
		}
		
		if SetGUI.IsVisible
			return
		
		;this.Animate(0xa0000)
		
		this.LVRedraw(false)
		this.Pos(A_ScreenWidth/2 - this.HALF_WIDTH, A_ScreenHeight/2 - 164, this.HALF_WIDTH*2)
		this.SetTab(tab?tab:this.ActiveTab)
		this.Show()
		this.LVRedraw(true)
		
		if (this.ActiveTab = 1)
			this.ColorScreens()
		
		this.SetTabColor(tab?tab:this.ActiveTab)
		
		; init CLV here
		if !this.GameLV.CLV {
			this.GameLV.CLV := new LV_Colors(this.GameLV.hwnd)
			this.GameLV.CLV.Critical := 500
			this.GameLV.CLV.SelectionColors("0x" . Settings.Color.Selection, "0xFFFFFF")
		}
		
		if !this.BindLV.CLV {
			this.BindLV.CLV := new LV_Colors(this.BindLV.hwnd)
			this.BindLV.CLV.Critical := 500
			this.BindLV.CLV.SelectionColors("0x" . Settings.Color.Selection, "0xFFFFFF")
		}
	}
	
	LVRedraw(Redraw) {
		for Index, LV in [this.GameLV.hwnd, this.QueueLV.hwnd, this.BindLV.hwnd]
			this.Control((Redraw ? "+" : "-") "Redraw", LV)
	}
	
	Save() {
		Settings.GuiState.ActiveTab := this.ActiveTab
		Settings.GuiState.ExpandState := this.ExpandState
		JSONSave("Settings", Settings)
		JSONSave("Keybinds", Keybinds)
		JSONSave("GameRules", GameRules)
	}
	
	Escape() {
		this.Close()
	}
	
	Close() {
		this.Hide()
		this.ImgurAnimate(false)
		Keybinds(true)
		this.Save()
	}
	
	QueueListViewAction(Control, GuiEvent, EventInfo) {
		
		if (GuiEvent ~= "^(Normal|C|I)$")
			this.QueueLV.Modify(EventInfo, "-Select")
		
		if (GuiEvent = "DoubleClick") {
			if (Uploader.Status = 1)
				return
			
			Type := this.QueueLV.GetText(EventInfo, 1)
			ID := this.QueueLV.GetText(EventInfo, 3)
			
			if (ID != "id") {
				for Index, Info in Uploader.QueueFail {
					if (Info.ID = ID) {
						Uploader.QueueFail.RemoveAt(Index)
						Uploader.Queue.Push({Event:Type, ID:ID})
						Uploader.GuiUpdate()
						Uploader.GuiCheckButtons()
						break
					}
				}
			}
		}
	}
}

CreateBigGUI() {
	
	Big := new BigGUI(AppName " " AppVersionString)
	
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
	Big.GamesHWND := Big.Add("Text", "x0 y0 w" TAB_WIDTH-1 " h" TAB_HEIGHT-1 " 0x200 Center", "Games", Big.TabAction.Bind(Big))
	Big.ImgurHWND := Big.Add("Text", "x" TAB_WIDTH " y0 w" TAB_WIDTH-1 " h" TAB_HEIGHT-1 " 0x200 Center", "Imgur", Big.TabAction.Bind(Big))
	Big.KeybindsHWND := Big.Add("Text", "x" TAB_WIDTH*2 " y0 w" TAB_WIDTH " h" TAB_HEIGHT-1 " 0x200 Center", "Keybinds", Big.TabAction.Bind(Big))
	
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
	Big.GameLV := new Big.ListView(Big, "x" 0 " y" TAB_HEIGHT " w" HALF_WIDTH - 1 " h" LV_HEIGHT " -HDR -Multi +LV0x4000 -E0x200 AltSubmit -TabStop", "name|path", Big.GameListViewAction.Bind(Big))
	
	Big.Font("s10")
	
	Button := Big.Add("Button", "x1 y" TAB_HEIGHT + LV_HEIGHT + 1 " w" Round(HALF_WIDTH/5*2) - 2 " h" BUTTON_HEIGHT - 1, "Remove", Big.GameDelete.Bind(Big))
	ImageButtonApply(Button)
	
	Button := Big.Add("Button", "x" Round(HALF_WIDTH/5*2) + 1 " yp w" HALF_WIDTH - Round(HALF_WIDTH/5*2) - 1 " h" BUTTON_HEIGHT - 1, "Add Program", Big.AddGame.Bind(Big))
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
	
	MonitorCount := SysGet("MonitorCount")
	
	Big.Font(MonitorCount>1?"s16":"s13")
	
	if (MonitorCount = 1) {
		Big.Add("Text", "x" HALF_WIDTH+1 " y" TAB_HEIGHT + LV_HEIGHT*3/4 " w" HALF_WIDTH - 12 " Center", "Primary screen selected!")
		Settings.VibrancyScreens := [SysGet("MonitorPrimary")] ; reset it so it doesn't get messed up and the user is stuck and can't change
	} else {
		for MonID, Mon in MonitorSetup(HALF_WIDTH - 12, 100, 4) {
			HWND := Big.Add("Text"
					, "x" HALF_WIDTH + 6 + Mon.X
					. " y" 186 + Mon.Y
					. " w" Mon.W
					. " h" Mon.H
					. " +Border 0x200 Center", MonID, Big.SelectScreen.Bind(Big, MonID))
			Big.MonitorHWND[MonID] := HWND
		}	
	}
	
	if Settings.NvAPI_InitFail { ; no nvidia card detected, grey out/disable some controls..
		Big.Control("Disable", Big.BoostSliderHWND)
		Big.Control("Disable", Big.DefaultSliderHWND)
		Big.Font("c808080")
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
	Big.Font("s1")
	Big.ImgurLV := new Big.ListView(Big, "x0 y" TAB_HEIGHT " w" HALF_WIDTH*2 " h" LV_HEIGHT + BUTTON_HEIGHT + 1 " -HDR +Multi +Icon AltSubmit cWhite -E0x200 -TabStop +Background" Settings.Color.Dark, "empty|index", Big.ImgurListViewAction.Bind(Big))
	Big.Font("s10")
	
	Big.QueueTextHWND := Big.Add("Button", "x0 y" TAB_HEIGHT + LV_HEIGHT + BUTTON_HEIGHT + 1 " w" TAB_WIDTH*2 " h24 +Left", " Press space to view queue manager", Big.ImgurExpandToggle.Bind(Big))
	
	Big.Add("Button", "x" TAB_WIDTH*2 " y" TAB_HEIGHT + LV_HEIGHT + BUTTON_HEIGHT + 1 " w" TAB_WIDTH/2 " h24", "Copy link(s)", Big.ImgurCopyLinks.Bind(Big))
	Big.Add("Button", "x" TAB_WIDTH*2 + TAB_WIDTH/2 " y" TAB_HEIGHT + LV_HEIGHT + BUTTON_HEIGHT + 1 " w" TAB_WIDTH/2 " h24", "Open link(s)", Big.ImgurOpenLinks.Bind(Big))
	
	Big.Font("s11")
	
	Big.QueueLV := new Big.ListView(Big, "x0 y" TAB_HEIGHT + LV_HEIGHT + BUTTON_HEIGHT + 25 " w" HALF_WIDTH*2 " h" EXPAND_SIZE - BUTTON_HEIGHT - 24 " AltSubmit NoSort -Hdr -Multi +LV0x4000 -E0x200 -LV0x10 -TabStop cWhite +Background" Settings.Color.Dark, "updown|filename|id", Big.QueueListViewAction.Bind(Big))
	Big.QueueLV.CLV := new LV_Colors(Big.QueueLV.hwnd)
	
	Big.Font("s10")
	
	Big.PauseButtonHWND := Big.Add("Button", "x0 y" TAB_HEIGHT + LV_HEIGHT + EXPAND_SIZE + 1 " w" TAB_WIDTH " h" BUTTON_HEIGHT " Disabled", "Pause", Big.StartStopQueue.Bind(Big))
	Big.ClearButtonHWND := Big.Add("Button", "x" TAB_WIDTH " y" TAB_HEIGHT + LV_HEIGHT + EXPAND_SIZE + 1 " w" TAB_WIDTH " h" BUTTON_HEIGHT " Disabled", "Clear queue", Big.ClearQueue.Bind(Big))
	Big.ClearFailedButtonHWND := Big.Add("Button", "x" TAB_WIDTH*2 " y" TAB_HEIGHT + LV_HEIGHT + EXPAND_SIZE + 1 " w" TAB_WIDTH " h" BUTTON_HEIGHT " Disabled", "Clear failed items", Big.ClearFailedQueue.Bind(Big))
	
	Big.UpdateImgurList()
	
	; ==========================================
	
	Big.Tab(3)
	Big.Margin(0, 0)
	Big.Font("s11")
	
	Big.BindLV := new Big.ListView(Big, "x0 y" TAB_HEIGHT " w" HALF_WIDTH*2+1 " h" LV_HEIGHT " -HDR -Multi AltSubmit -E0x200 -TabStop","desc|key|realkey", Big.BindListViewAction.Bind(Big))
	
	Big.Font("s10")
	
	Button := Big.Add("Button", "x1 y" TAB_HEIGHT + LV_HEIGHT + 1 " w" HALF_WIDTH - 2 " h" BUTTON_HEIGHT - 1 " Center", "Delete Keybind", Big.BindDelete.Bind(Big))
	ImageButtonApply(Button)
	
	Button := Big.Add("Button", "x" HALF_WIDTH + 1 " yp w" HALF_WIDTH - 2 " h" BUTTON_HEIGHT - 1 " Center", "Add a Keybind", Big.AddBind.Bind(Big))
	ImageButtonApply(Button)
	
	Big.UpdateBindList()
	
	Big.ActiveTab := Settings.GuiState.ActiveTab
	Big.ExpandState := Settings.GuiState.ExpandState
	
	Big.Options("-MinimizeBox")
	Big.SetIcon(Icon("icon"))
	
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
	
	return
}