Exit(Exit := true) {
	CtlColors.Free() ; free ctlcolors
	PluginConnector.Exit()
	
	Gdip_Shutdown(pToken) ; shut down gdip
	ObjRegisterActive(PluginConnector, "") ; revoke COM objects
	
	Settings.Save(true)
	Keybinds.Save(true)
	GameRules.Save(true)
	
	Settings := ""
	Keybinds := ""
	GameRules := ""
	
	if Exit
		ExitApp
}