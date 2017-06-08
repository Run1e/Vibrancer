Update(URL) {
	
	SetGUI.Close(false)
	
	; download the newest installer
	try
		URLDownloadToFile, % URL, Vibrancer-installer.zip
	catch e {
		ErrorEx(e)
		TrayTip("Failed downloading update")
		return
	}
	
	; check that zip is downloaded
	if !FileExist("Vibrancer-installer.zip")
		return TrayTip("Failed downloading update")
	
	if !UnZip(A_WorkingDir "\Vibrancer-installer.zip", A_WorkingDir "\Vibrancer-installer\")
		return TrayTip("Failed Unzipping installer")
	
	; check it unzipped properly
	if !FileExist("Vibrancer-installer\Vibrancer-installer.exe")
		return TrayTip("Failed extracting updater")
	
	; run the installer in silent mode, installing to the current dir
	try
		Run("Vibrancer-Installer\Vibrancer-installer.exe /verysilent /noicons ""/dir=" A_WorkingDir "")
	catch e
		return TrayTip("Failed running updater")
	
	ExitApp
}