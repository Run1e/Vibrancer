Class PluginGUI extends GUI {
	DropFiles(FileArray, CtrlHwnd, X, Y) {
		for Index, File in FileArray {
			SplitPath, File, FileName,, Ext
			if (Ext != "ahk")
				continue
			FileMove, % File, % "plugins\" FileName
			Update := true
		} if Update
			this.UpdatePluginList()
	}
	
	ListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "C")
			this.SetList()
		
		else if (GuiEvent = "DoubleClick") { ; launch plugin
			if !(Pos := this.LV.GetNext())
				return
			Plg := this.LV.GetText(Pos)
			MsgBox,68,Run plugin?,Do you want to run %Plg%?
			ifMsgBox no
			return
			Run(A_WorkingDir "\plugins\" this.LV.GetText(this.LV.GetNext()) ".ahk")
		}
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
	
	SetList() {
		i:=0, Checked := {}
		
		while i:=this.LV.GetNext(i, "Checked")
			Checked.Push(this.LV.GetText(i))
		
		
		if !Checked.MaxIndex() {
			if !Settings.Plugins.MaxIndex()
				return
			Settings.Plugins := {}
			this.UpdatePluginList()
			return
		}
		
		for Index, Plg in Checked {
			if (Settings.Data().Plugins[index] != Plg) || (Settings.Plugins.MaxIndex() > Checked.MaxIndex()) {
				Settings.Plugins := Checked
				this.UpdatePluginList(this.LV.GetNext())
				return
			}
		}
	}
	
	UpdatePluginList(Select := 1) {
		this.LV.Delete()
		
		for Index, Plg in Settings.Plugins, Added := [] {
			if !FileExist("plugins\" Plg ".ahk") {
				Settings.Plugins.RemoveAt(Index)
				continue
			} this.LV.Add("Check1", Plg), Added[Plg] := ""
		}
		
		Loop, Files, plugins\*.ahk
			if !Added.HasKey(File := rtrim(A_LoopFileName, ".ahk"))
				this.LV.Add("Check0", File)
		
		if Select
			this.LV.Modify(Select, "Select Vis")
	}
	
	Restart() {
		this.Close()
		reload
	}
	
	OpenFolder() {
		Run("plugins")
	}
	
	Close() {
		this.Destroy()
		Plug := ""
		Settings.Save()
	}
}

; game: how many variations of "plugin" can I come up with?
Plugins() {
	
	if IsObject(Plug)
		return
	
	if IsObject(SetGUI)
		SetGUI.Close(false)
	
	WIDTH := 220
	HEIGHT := 230
	BUTTON_HEIGHT := 26
	
	Plug := new PluginGUI("Plugins", "-MinimizeBox")
	
	Plug.Color("FFFFFF")
	Plug.Font("s10")
	Plug.DropFilesToggle(true)
	
	Plug.LV := new Gui.ListView(Plug, "x0 y0 w" WIDTH " h" HEIGHT - 66 " -Hdr -Multi Checked AltSubmit -E0x200 -TabStop", "Plugin", Plug.ListViewAction.Bind(Plug))
	Plug.CLV := new LV_Colors(Plug.LV.hwnd)
	Plug.CLV.SelectionColors("0x" Settings.Color.Selection, 0xFFFFFF)
	
	Plug.UpdatePluginList()
	
	Plug.Add("Text", "x0 y" HEIGHT - 66 " h1 w" WIDTH " 0x08")
	Plug.Add("Text", "x8 yp+9", "Load order:")
	
	Plug.Font("s8")
	Plug.Add("Button", "x80 yp-4 w63 h" BUTTON_HEIGHT, "Move up", Plug.Move.Bind(Plug, -1))
	Plug.Add("Button", "x145 yp w72 h" BUTTON_HEIGHT, "Move down", Plug.Move.Bind(Plug, 1))
	
	Plug.Add("Button", "x6 yp+30 w" WIDTH/2 - 6 " h" BUTTON_HEIGHT, "Open plugin folder", Plug.OpenFolder.Bind(Plug))
	Plug.Add("Button", "x" WIDTH/2 + 3 " yp w" WIDTH/2 - 6 " h" BUTTON_HEIGHT, "Apply (reload)", Plug.Restart.Bind(Plug))
	
	Plug.Show("w" WIDTH " h" HEIGHT)
}