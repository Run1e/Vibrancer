Exit() {
	CtlColors.Free() ; free ctlcolors
	Uploader.Free() ; close upload helper
	
	Gdip_Shutdown(pToken) ; shut down gdip
	
	; revoke COM objects
	ObjRegisterActive(Plugin, "")
	ObjRegisterActive(Uploader, "")
	
	; destroy all imageslists and references
	for hwnd, Instance in Gui.ImageList.Instances
		Instance.Destroy()
	
	; destroy all guis and references
	for hwnd, Instance in Gui.Instances
		Instance.Destroy()

	ExitApp
}