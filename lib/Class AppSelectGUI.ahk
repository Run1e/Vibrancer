﻿Class AppSelectGUI extends GUI {
	SelectFile() {
		this.Options("+OwnDialogs")
		FileSelectFile, Game, 3, % A_ProgramFiles, % Lang.PROGRAM.SELECT_EXE_LONG, *.exe
		if ErrorLevel
			return
		SplitPath, Game, Name
		this.Close({InstallLocation:Game, Run:Game})
	}
	
	Close(Info := "") {
		this.IL.Destroy()
		this.ListViewCLV := ""
		this.Destroy()
		
		od("App selected: ", Info)
		
		this.Callback.Call(Info)
		Prog := ""
	}
	
	Escape() {
		this.Close()
	}
	
	AppListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "DoubleClick") {
			id := this.AppLV.GetText(this.AppLV.GetNext(), 2)
			if id && StrLen(id)
				this.Close(Prog.AppList[id])
		}
	}
}

AppSelect(Callback, Owner := "", IgnoreGameRules := false) {
	static VERT_SCROLL := SysGet(2)
	Prog := new AppSelectGUI(Lang.PROGRAM.TITLE)
	
	Prog.Default()
	
	Prog.Font("s10", Settings.Font)
	Prog.Color("FFFFFF", "FFFFFF")
	
	Prog.AppList := GetApplications()
	Prog.Callback := Callback
	Prog.Owner := Owner
	
	Prog.Add("Text",, Lang.PROGRAM.SELECT_PROGRAM)
	
	Prog.AppLV := new Prog.ListView(Prog, "w250 h265 -HDR -Multi", "prog|id", Prog.AppListViewAction.Bind(Prog))
	
	Prog.AppLV.CLV := new LV_Colors(Prog.AppLV.hwnd)
	Prog.AppLV.CLV.SelectionColors(Settings.Color.Selection, 0xFFFFFF)
	
	Prog.Add("Text", "y+10", Lang.PROGRAM.MANUAL_PROMPT)
	Prog.Add("Button", "x+m yp-5", Lang.PROGRAM.SELECT_EXE, Prog.SelectFile.Bind(Prog))
	
	IL := new Prog.ImageList
	Prog.IL := IL
	Prog.AppLV.SetImageList(IL.ID)
	
	Prog.AppLV.ModifyCol(1, 250 - VERT_SCROLL - 5)
	Prog.AppLV.ModifyCol(2, 0)
	
	for Index, App in Prog.AppList {
		if GameRules.HasKey(App.InstallLocation) && !IgnoreGameRules
			continue
		Prog.AppLV.Add("Icon" . IL.Add(StrLen(App.DisplayIcon)?App.DisplayIcon:App.InstallLocation), App.DisplayName, Index)
	}
	
	Prog.Options("+AlwaysOnTop -MinimizeBox +Owner" Owner)
	Prog.Show()
	return
}