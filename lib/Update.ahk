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
	if !FileExist("PowerPlay-installer.zip") {
		TrayTip("Failed downloading update")
		return
	}
	
	; unzip
	Unz(A_WorkingDir "\PowerPlay-installer.zip", A_WorkingDir "\PowerPlay-installer\")
	
	; check it unzipped properly
	if !FileExist("PowerPlay-installer\PowerPlay-installer.exe") {
		TrayTip("Failed extracting updater")
		return
	}
	
	; save current version comparison after updating
	Settings.UpdateVersion := SubStr(AppVersionString, 2)
	Settings.Save()
	
	; run the installer in silent mode, installing to the current dir
	if !Run("PowerPlay-Installer\PowerPlay-installer.exe /VERYSILENT /DIR=""" A_WorkingDir """")
		TrayTip("Failed running updater")
}