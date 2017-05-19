Exit() {
	CtlColors.Free() ; free ctlcolors
	Uploader.Free() ; close upload helper
	
	Plugin.Exit()
	
	ShowCursor(true)
	
	Gdip_Shutdown(pToken) ; shut down gdip
	
	; revoke COM objects
	ObjRegisterActive(Plugin, "")
	ObjRegisterActive(Uploader, "")
	ExitApp
}