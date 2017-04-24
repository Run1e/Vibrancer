; only supports TWO layers. I don't see why more would be needed and I don't plan on implementing it atm.
CreateTrayMenu() {
	static Menus := []
	
	; contains the order of the tray menu item/submenus
	try
		TrayMenu := JSONFile("TrayMenu")
	catch e
		ErrorEx((e, e.extra := "Failed loading data\TrayMenu.json"), true)
	
	; clear all menus
	for Index, MenuInstanceName in Menus
		Menu.Instances[MenuInstanceName].Clear()
	
	Menus := ["Tray"]
	
	; menu object
	Tray := new Menu("Tray", "TrayMenuHandler")
	
	Tray.Add("Open", Actions.Open.Bind(Actions), Icon("device-desktop"))
	Tray.Add("Settings", Actions.Settings.Bind(Actions), Icon("gear"))
	Tray.Add()
	
	Tray.SetDefault("Open")
	
	for Index, TrayObj in TrayMenu {
		if TrayObj.HasKey("File") { ; points to another file, it's a submenu
			
			; load the json
			try
				SubMenuObj := JSON.Load(FileRead("menus\" TrayObj.File ".json"))
			catch e {
				ErrorEx((e, e.extra := "Failed loading JSON in menus\" TrayObj.File ".json"), true)
				continue ; skip this submenu
			}
			
			; create a temp menu to create the submenu in
			TempMenu := new Menu(TrayObj.Desc)
			
			; add the menu name to the static Menus array so we know we need to clear it before refreshing the menus
			Menus.Insert(TrayObj.Desc)
			
			; populate the submenu
			for Index, MenuItem in SubMenuObj
				TempMenu.Add(MenuItem.Desc, Actions[MenuItem.Func].Bind(Actions, MenuItem.Param*), Icon(MenuItem.Icon))
			
			; add the submenu to the tray menu
			Tray.Add(TempMenu,, Icon(TrayObj.Icon))
			TempMenu := ""
			
		} else { ; it's a single menu item
			Tray.Add(TrayObj.Desc, Actions[TrayObj.Func].Bind(Actions, TrayObj.Param*), Icon(TrayObj.Icon))
		}
	}
	
	if Index
		Tray.Add()
	
	Tray.Add("Exit", Actions.Exit.Bind(Actions), Icon("x"))
}