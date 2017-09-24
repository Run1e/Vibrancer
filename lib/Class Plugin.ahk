Class Plugin extends GUI {
	static WIDTH := 550
	static HEIGHT := 255
	static BUTTON_HEIGHT := 26
	static LV_HEIGHT := Plugin.HEIGHT - 35
	
	DropFiles(FileArray, CtrlHwnd, X, Y) {
		for Index, File in FileArray {
			SplitPath, File, FileName,, Ext
			if (Ext != "ahk")
				continue
			FileMove, % File, % "plugins\" FileName
			Update := true
		} if Update
			this.UpdatePluginList(this.LV.GetNext())
	}
	
	ListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "I") && InStr(ErrorLevel, "C")
			this.SetList(InStr(ErrorLevel, "C", true) ? this.LV.GetText(EventInfo) : this.LV.GetNext())
	}
	
	Move(Dir) {
		if (Pos := this.LV.GetNext()) && (Pos = this.LV.GetNext(Pos-1, "Checked")) {
			NewPos := Pos + Dir
			if (NewPos < 1) || (NewPos > Settings.Plugins.MaxIndex())
				return
			Rem := Settings.Plugins.RemoveAt(NewPos)
			Settings.Plugins.InsertAt(Pos, Rem)
			this.UpdatePluginList(NewPos)
		}
	}
	
	GetChecked() {
		i := 0, Plugs := []
		while i:=this.LV.GetNext(i, "Checked")
			Plugs.Push(this.LV.GetText(i))
		return Plugs
	}
	
	SetList(Item := "") {
		Settings.Plugins := this.GetChecked()
		this.UpdatePluginList(Item)
	}
	
	UpdatePluginList(Select := "") {
		this.LV.Delete()
		this.Control("-g", this.LV.hwnd)
		
		for Index, Plg in Settings.Plugins, Added := [] {
			if !FileExist("plugins\" Plg ".ahk") {
				Settings.Plugins.RemoveAt(Index)
				continue
			}
			
			FileReadLine, Desc, % "plugins\" Plg ".ahk", 1
			FileReadLine, Author, % "plugins\" Plg ".ahk", 2
			Desc := (InStr(Desc, "; ") = 1 ? SubStr(Desc, 3) : "No description")
			Author := (InStr(Author, "; ") = 1 ? SubStr(Author, 3) : " -")
			this.LV.Add("Check1", Plg, Desc, Author), Added[Plg] := ""
			if (Plg = Select)
				Select := A_Index
		}
		
		Loop, Files, plugins\*.ahk
		{
			if !Added.HasKey(File := rtrim(A_LoopFileName, ".ahk")) {
				FileReadLine, Desc, % A_LoopFileFullPath, 1
				FileReadLine, Author, % A_LoopFileFullPath, 2
				Desc := (InStr(Desc, "; ") = 1 ? SubStr(Desc, 3) : "No description")
				Author := (InStr(Author, "; ") = 1 ? SubStr(Author, 3) : " -")
				this.LV.Add("Check0", File, Desc, Author)
			}
		}
		
		this.LV.ModifyCol(1, "AutoHDR")
		this.LV.ModifyCol(2, "AutoHDR")
		this.LV.ModifyCol(3, "AutoHDR")
		
		; this.LV.ModifyCol(1, this.WIDTH - (LV_EX_GetRowHeight(this.LV.hwnd) * this.LV.GetCount() > this.LV_HEIGHT ? VERT_SCROLL : 0))
		
		if Select
			this.LV.Modify(Select, "Select Vis")
		
		this.Control("+g", this.LV.hwnd, this.ListViewAction.Bind(this))
	}
	
	Restart() {
		this.Close()
		reload
	}
	
	OpenFolder() {
		Run("plugins")
	}
	
	Close() {
		this.CLV.OnMessage(False)
		this.CLV := ""
		this.Destroy()
		Settings.Save(true)
	}
}

Plugins() {
	if Plugin.IsVisible
		return
	
	if SetGUI.IsVisible
		SetGUI.Close(false)
	
	WIDTH := Plugin.WIDTH
	HEIGHT := Plugin.HEIGHT
	LV_HEIGHT := Plugin.LV_HEIGHT
	BUTTON_HEIGHT := Plugin.BUTTON_HEIGHT
	
	Plugin := new Plugin(Lang.PLUGIN.PLUGINS, "-MinimizeBox")
	
	Plugin.Color("FFFFFF")
	Plugin.Font("s10")
	Plugin.DropFilesToggle(true)
	
	Plugin.LV := new Gui.ListView(Plugin, "x0 y0 w" WIDTH " h" LV_HEIGHT " -Hdr -Multi Checked AltSubmit -E0x200 -TabStop", "Plugin|Description|Author", Plugin.ListViewAction.Bind(Plugin))
	Plugin.CLV := new LV_Colors(Plugin.LV.hwnd)
	Plugin.CLV.SelectionColors(Settings.Color.Selection, 0xFFFFFF)
	
	Plugin.UpdatePluginList(1)
	
	Plugin.Margin(4, 4)
	
	Plugin.Add("Text", "x0 y" HEIGHT - 35 " h1 w" WIDTH " 0x08")
	Plugin.Add("Text", "x8 yp+9", Lang.PLUGIN.LOAD_ORDER)
	
	Plugin.Font("s8")
	Plugin.Add("Button", "x+m yp-4 h" BUTTON_HEIGHT, Lang.PLUGIN.MOVE_UP, Plugin.Move.Bind(Plugin, -1))
	Plugin.Add("Button", "x+m yp h" BUTTON_HEIGHT, Lang.PLUGIN.MOVE_DOWN, Plugin.Move.Bind(Plugin, 1))
	
	Plugin.Add("Button", "x+m" WIDTH - 180 " yp h" BUTTON_HEIGHT, Lang.PLUGIN.OPEN_FOLDER, Plugin.OpenFolder.Bind(Plugin))
	Plugin.Add("Button", "x+m yp h" BUTTON_HEIGHT, Lang.PLUGIN.APPLY, Plugin.Restart.Bind(Plugin))
	
	Plugin.Show("w" WIDTH " h" HEIGHT)
}