Exit() {
	CtlColors.Free() ; free ctlcolors
	Uploader.Free() ; close upload helper
	
	Plugin.Exit()
	
	Gdip_Shutdown(pToken) ; shut down gdip
	
	; revoke COM objects
	ObjRegisterActive(Plugin, "")
	ObjRegisterActive(Uploader, "")
	ExitApp
}