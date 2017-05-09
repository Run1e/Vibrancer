Class Tray extends Menu {
	__New() {
		Name := "Tray"
		this.Name := Name
		this.Map := {}
		Menu.Instances[Name] := this
		this.Clear()
	}
	
	PluginAdd() {
		
	}
}