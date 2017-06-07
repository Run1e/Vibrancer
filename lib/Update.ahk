Update(URL) {
	
	SetGUI.Close(false)
	
	; download the newest installer
	try
		URLDownloadToFile, % URL, PowerPlay-installer.zip
	catch e {
		ErrorEx(e)
		TrayTip("Failed downloading update")
		return
	}
	
	; check that zip is downloaded
	if !FileExist("PowerPlay-installer.zip")
		return TrayTip("Failed downloading update")
	
	Unz(A_WorkingDir "\PowerPlay-installer.zip", A_WorkingDir "\PowerPlay-installer\")
	
	; check it unzipped properly
	if !FileExist("PowerPlay-installer\PowerPlay-installer.exe")
		return TrayTip("Failed extracting updater")
	
	; run the installer in silent mode, installing to the current dir
	try
		Run("PowerPlay-Installer\PowerPlay-installer.exe /verysilent /noicons ""/dir=" A_WorkingDir "")
	catch e
		return TrayTip("Failed running updater")
	
	ExitApp
}