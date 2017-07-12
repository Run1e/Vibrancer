Exit(Exit := true) {
	CtlColors.Free() ; free ctlcolors
	Plugin.Exit()
	
	Gdip_Shutdown(pToken) ; shut down gdip
	ObjRegisterActive(Plugin, "") ; revoke COM objects
	
	Settings.Save()
	Keybinds.Save()
	GameRules.Save()
	
	Settings := ""
	Keybinds := ""
	GameRules := ""
	
	if Exit
		ExitApp
}