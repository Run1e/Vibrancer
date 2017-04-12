; only supports TWO layers. I don't see why more would be needed and I don't plan on implementing it atm.
CreateTrayMenu() {
	static Menus := []
	
	; contains the order of the tray menu item/submenus
	try
		TrayMenu := JSONFile("TrayMenu")
	catch e
		ErrorEx((e, e.extra := "Failed loading data\TrayMenu.json"), true)
	
	; holds the nugget information
	Menu.Map := []
	Menu.Map.Tray := {}
	
	; clear all menus
	for Index, MenuInstanceName in Menus
		Menu.Instances[MenuInstanceName].Clear()
	
	Menus := ["Tray"]
	
	; menu object
	Tray := new Menu("Tray")
	Tray.Add("Open")
	Tray.Add("Settings")
	Tray.Add()
	Tray.SetDefault("Open")
	
	; add icons for hardcoded items
	Tray.Icon("Open", Icon("device-desktop"))
	Tray.Icon("Settings", Icon("gear"))
	
	; add menumap info for hardcoded items
	Menu.Map.Tray.Open := {Func:"Open"}
	Menu.Map.Tray.Settings := {Func:"Settings"}
	Menu.Map.Tray.Exit := {Func:"Exit"}
	
	for Index, TrayObj in TrayMenu {
		if TrayObj.HasKey("File") { ; points to another file, it's a submenu
			
			; load the json
			try
				SubMenuObj := JSON.Load(FileRead("menus\" TrayObj.File ".json"))
			catch e {
				ErrorEx((e, e.extra := "Failed loading JSON in menus\" TrayObj.File ".json"), true)
				continue ; cancel this submenu
			}
			
			; create a temp menu to create the submenu in
			TempMenu := new Menu(TrayObj.Desc)
			
			; add the menu name to the static Menus array so we know we need to clear it before refreshing the menus
			Menus.Insert(TrayObj.Desc)
			
			; populate the submenu
			for Index, MenuItem in SubMenuObj {
				TempMenu.Add(MenuItem.Desc)
				TempMenu.Icon(MenuItem.Desc, Icon(MenuItem.Icon))
				Menu.Map[TrayObj.Desc, MenuItem.Desc] := MenuItem
			}
			
			; add the submenu to the tray menu
			Tray.Add(TempMenu)
			Tray.Icon(TrayObj.Desc, Icon(TrayObj.Icon))
			TempMenu := ""
			
		} else { ; it's a single menu item
			Tray.Add(TrayObj.Desc)
			Tray.Icon(TrayObj.Desc, Icon(TrayObj.Icon))
			Menu.Map["Tray", TrayObj.Desc] := TrayObj
		}
	}
	
	if ArraySize(TrayMenu)
		Tray.Add()
	
	Tray.Add("Exit")
	Tray.Icon("Exit", Icon("x"))
}