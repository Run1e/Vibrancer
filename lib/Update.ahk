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
	
	; unzip
	if !UnZip(A_WorkingDir "\PowerPlay-installer.zip", A_WorkingDir "\PowerPlay-installer\")
		return TrayTip("Failed unzipping updater")
	
	; check it unzipped properly
	if !FileExist("PowerPlay-installer\PowerPlay-installer.exe")
		return TrayTip("Failed extracting updater")
	
	; run the installer in silent mode, installing to the current dir
	if !Run("PowerPlay-Installer\PowerPlay-installer.exe /verysilent /noicons ""/dir=" A_WorkingDir "")
		return TrayTip("Failed running updater")
	
	ExitApp
}