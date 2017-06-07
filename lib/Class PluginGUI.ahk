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
		
		/*
			static LastC
			
			if (GuiEvent = "DoubleClick") && !LastC { ; launch plugin
				if !(Pos := this.LV.GetNext())
					return
				Plg := this.LV.GetText(Pos)
				MsgBox,68,Run plugin?,Do you want to run %Plg%?
				ifMsgBox no
				return
				Run(A_WorkingDir "\plugins\" this.LV.GetText(this.LV.GetNext()) ".ahk")
		*/
		
		if (GuiEvent = "C")
			this.SetList()
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
	
	SetList() {
		Settings.Plugins := this.GetChecked()
		this.UpdatePluginList()
	}
	
	UpdatePluginList(Select := 1) {
		this.LV.Delete()
		
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
	
	Plug := new PluginGUI("Plugins", "-MinimizeBox")
	
	Plug.WIDTH := WIDTH := 550
	Plug.HEIGHT := HEIGHT := 250
	Plug.BUTTON_HEIGHT := BUTTON_HEIGHT := 26
	Plug.LV_HEIGHT := LV_HEIGHT := HEIGHT - 33
	
	Plug.Color("FFFFFF")
	Plug.Font("s10")
	Plug.DropFilesToggle(true)
	
	Plug.LV := new Gui.ListView(Plug, "x0 y0 w" WIDTH " h" LV_HEIGHT " -Hdr -Multi Checked AltSubmit -E0x200 -TabStop", "Plugin|Description|Author", Plug.ListViewAction.Bind(Plug))
	Plug.CLV := new LV_Colors(Plug.LV.hwnd)
	Plug.CLV.SelectionColors(Settings.Color.Selection, 0xFFFFFF)
	
	Plug.UpdatePluginList()
	
	Plug.Add("Text", "x0 y" HEIGHT - 35 " h1 w" WIDTH " 0x08")
	Plug.Add("Text", "x8 yp+9", "Load order:")
	
	Plug.Font("s8")
	Plug.Add("Button", "x80 yp-4 w63 h" BUTTON_HEIGHT, "Move up", Plug.Move.Bind(Plug, -1))
	Plug.Add("Button", "x145 yp w72 h" BUTTON_HEIGHT, "Move down", Plug.Move.Bind(Plug, 1))
	
	Plug.Add("Button", "x" WIDTH - 180 " yp h" BUTTON_HEIGHT, "Open plugin folder", Plug.OpenFolder.Bind(Plug))
	Plug.Add("Button", "xp+100 yp h" BUTTON_HEIGHT, "Apply (reload)", Plug.Restart.Bind(Plug))
	
	Plug.Show("w" WIDTH " h" HEIGHT)
}