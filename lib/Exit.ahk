Exit(Exit := true) {
	CtlColors.Free() ; free ctlcolors
	Plugin.Exit()
	
	Gdip_Shutdown(pToken) ; shut down gdip
	ObjRegisterActive(Plugin, "") ; revoke COM objects
	
	Settings.Save(true)
	Keybinds.Save(true)
	GameRules.Save(true)
	
	Settings := ""
	Keybinds := ""
	GameRules := ""
	
	if Exit
		ExitApp
}