Class AppSelectGUI extends GUI {
	SelectFile() {
		this.Options("+OwnDialogs")
		FileSelectFile, Game, 3, % A_ProgramFiles, Select an .exe file, *.exe
		if ErrorLevel
			return
		SplitPath, Game, Name
		this.Close({InstallLocation:Game, Run:Game})
	}
	
	ListView(GuiEvent) {
		if (GuiEvent = "DoubleClick") {
			LV_GetText(ID, LV_GetNext(), 2)
			if (ID = "id") ; header name
				return
			this.Close(this.AppList[ID])
		}
	}
	
	Close(Info := "") {
		this.Destroy()
		
		this.ListViewCLV := ""
		
		this.Callback.Call(Info)
		
		Prog := ""
	}
	
	Escape() {
		this.Close()
	}
}

AppSelect(Callback, Owner := "", IgnoreGameRules := false) {
	Prog := new AppSelectGUI("Select an application")
	
	Prog.SetDefault()
	
	Prog.Font("s10", Settings.Font)
	
	Prog.AppList := GetApplications()
	Prog.Callback := Callback
	Prog.Owner := Owner
	
	Prog.Add("Text",, "Select a program:")
	
	Prog.ListViewHWND := Prog.Add("ListView", "w250 h265 -HDR -Multi gProgListView", "prog|id")
	Prog.ListViewCLV := new LV_Colors(Prog.ListViewHWND)
	Prog.ListViewCLV.SelectionColors("0x" Settings.Color.Selection, 0xFFFFFF)
	
	Prog.Add("Text", "y+10", "Not in the list? Select manually: ")
	Prog.Add("Button", "x193 yp-5", "Select exe", Prog.SelectFile.Bind(Prog))
	
	ImageList := IL_Create(20, 2, false)
	
	LV_ModifyCol(1, 250 - VERT_SCROLL - 5)
	LV_ModifyCol(2, 0)
	LV_SetImageList(ImageList, 1)
	
	for Index, App in Prog.AppList {
		if GameRules.HasKey(App.InstallLocation) && !IgnoreGameRules
			continue
		LV_Add("Icon" . IL_Add(ImageList, StrLen(App.DisplayIcon)?App.DisplayIcon:App.InstallLocation), App.DisplayName, Index)
	}
	
	
	Prog.Options("-MinimizeBox +Owner" Owner)
	Prog.Show()
	return
	
	ProgListView:
	Prog.ListView(A_GuiEvent)
	return
}