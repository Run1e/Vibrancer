Update(URL) {
	
	Keybinds(false)
	Big.Destroy(), Big := ""
	SetGUI.Destroy(), SetGUI := ""
	Plug.Destroy(), Plug := ""
	Tray.DeleteAll()
	OnMessage(Rules.OnMsgMsg, Rules.OnMsgFunc, 0)
	
	; maybe also disable winactivechange
	
	; download the newest installer
	try
		URLDownloadToFile, % URL, Vibrancer-installer.zip
	catch e {
		ErrorEx(e)
		UpdateFail("Failed downloading update.")
		return
	}
	
	; check that zip is downloaded
	if !FileExist("Vibrancer-installer.zip") ; this should honestly never happen
		return UpdateFail("Failed downloading update.")
	
	if !UnZip(A_WorkingDir "\Vibrancer-installer.zip", A_WorkingDir "\Vibrancer-installer\")
		return UpdateFail("UnZip failed.")
	
	; check it unzipped properly
	if !FileExist("Vibrancer-installer\Vibrancer-installer.exe")
		return UpdateFail("Failed extracting updater.")
	
	; run the installer in silent mode, installing to the current dir
	try
		Run("Vibrancer-Installer\Vibrancer-installer.exe /verysilent /noicons ""/dir=" A_WorkingDir "")
	catch e
		return UpdateFail("Failed running updater.")
	
	ExitApp
}

UpdateFail(Reason) {
	Run(A_ScriptFullPath " /UPDATEFAIL """ Reason """")
	ExitApp
}