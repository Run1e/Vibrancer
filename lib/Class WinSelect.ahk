Class WinSelect extends GUI {
	Close(Info := "") {
		this.IL.Destroy()
		this.CLV := ""
		this.Destroy()
		
		p("App selected: ", Info)
		
		this.Callback.Call(Info)
	}
	
	Escape() {
		this.Close()
	}
	
	AppListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "DoubleClick") {
			id := this.LV.GetText(this.LV.GetNext(), 2)
			if id && StrLen(id)
				this.Close(WinSelect.WinList[id])
		}
	}
}

WinSelect(Callback, Owner := "") {
	static VERT_SCROLL := SysGet(2)
	
	WinSelect := new WinSelect(LANG.PROGRAM.TITLE)
	
	WinSelect.Default()
	
	WinSelect.Font("s10", Settings.Font)
	WinSelect.Color("FFFFFF", "FFFFFF")
	
	WinSelect.WinList := GetWindows()
	WinSelect.Callback := Callback
	WinSelect.Owner := Owner
	
	WinSelect.LV := new WinSelect.ListView(WinSelect, "w250 h265 -HDR -Multi", "prog|id", WinSelect.AppListViewAction.Bind(WinSelect))
	
	WinSelect.CLV := new LV_Colors(WinSelect.LV.hwnd)
	WinSelect.CLV.SelectionColors(Settings.Color.Selection, 0xFFFFFF)
	
	IL := new Gui.ImageList
	WinSelect.IL := IL
	WinSelect.LV.SetImageList(IL.ID)
	
	WinSelect.LV.ModifyCol(1, 250 - VERT_SCROLL - 5)
	WinSelect.LV.ModifyCol(2, 0)
	
	for Index, Application in WinSelect.WinList
		if !GameRules.HasKey(Application.Path)
			WinSelect.LV.Add("Icon" . IL.Add(Application.Path), Application.Title, Index)
	
	WinSelect.Options("+AlwaysOnTop -MinimizeBox +Owner" Owner)
	WinSelect.Show()
	return
}