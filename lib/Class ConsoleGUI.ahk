Class ConsoleGUI extends GUI {
	Input() {
		
	}
	
	Add(text) {
		this.SetDefault()
		LV_Add(, text)
	}
	
	Create() {
		this.Margin(0, 0)
		this.ListViewHWND := this.Add("ListView", "cGreen Background000000 h300 w250 -Hdr", "text")
		this.Add("Edit", "x0 y326 w250 h26")
	}
}