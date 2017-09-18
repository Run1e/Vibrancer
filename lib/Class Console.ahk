Class Console {
	static Colors := {"Black":0,"Navy":1,"Green":2,"Teal":3,"Maroon":4,"Purple":5,"Olive":6
	,"Silver":7,"Gray":8,"Blue":9,"Lime":10,"Aqua":11,"Red":12,"Fuchsia":13,"Yellow":14,"White":15}
	static Visible := false
	
	Alloc() {
		DllCall("AllocConsole")
		this.Visible := true
	}
	
	Print(Text) {
		FileOpen("CONOUT$", "w").Write(Text "`n")
	}
}