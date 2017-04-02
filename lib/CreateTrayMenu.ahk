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
	
	; remove previous items if we've just refreshing
	
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
	
	; add menumap info for hardcoded items
	Menu.Map.Tray.Open := {Func:"Open"}
	Menu.Map.Tray.Settings := {Func:"Settings"}
	Menu.Map.Tray.Exit := {Func:"Exit"}
	
	for Index, MenuName in TrayMenu {
		
		; load the json
		try
			MenuObj := JSON.Load(FileRead("menus\" MenuName ".json"))
		catch e {
			ErrorEx((e, e.extra := "Failed loading JSON in menus\" MenuName ".json"), true)
			continue
		}
		
		if MenuObj.1.HasKey("Desc") { ; it's a list
			
			; create a temp menu to create the submenu in
			TempMenu := new Menu(MenuName)
			
			; add the menu name to the static Menus array so we know we need to clear it before refreshing the menus
			Menus.Insert(MenuName)
			
			; populate the submenu
			for Index, MenuItem in MenuObj {
				TempMenu.Add(MenuItem.Desc)
				Menu.Map[MenuName, MenuItem.Desc] := MenuItem
			}
			
			; add the submenu to the tray menu
			Tray.Add(TempMenu)
			TempMenu := ""
			
		} else if MenuObj.HasKey("Desc") { ; it's a single menu item
			Tray.Add(MenuObj.Desc)
			Menu.Map["Tray", MenuObj.Desc] := MenuObj
		}
	}
	
	if Index
		Tray.Add()
	Tray.Add("Exit")
	
}