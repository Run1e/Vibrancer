CheckForUpdates() {
	static URL := "https://api.github.com/repos/Run1e/Vibrancer/releases/latest"
	
	od("Checking for updates..")
	
	; get github api info on the vibrancer repo
	if !HTTP.Get(URL, Data)
		return TrayTip("Failed getting update info"), od("Failed getting update info")
	
	if (Data.Status != 200)
		return TrayTip("GitHub request failed"), od("GitHub request failed")
	
	; load into obj
	try
		GitJSON := JSON.Load(Data.ResponseText)
	catch e
		return TrayTip("Update response malformed"), od("Update response malformed")
	
	Installer := "https://github.com/Run1e/Vibrancer/releases/download/" GitJSON.tag_name "/Vibrancer-installer.zip"
	
	if (GitJSON.tag_name > AppVersionString) {
		
		od("Update avaliable: " GitJSON.tag_name)
		
		for Index, Line in StrSplit(GitJSON.Body, "`r`n")
			if (InStr(Line, "- ") = 1)
				Notes .= "`n" Line
		
		if FileExist("Vibrancer.exe") {
			MsgBox, 68, % AppName " v" AppVersionString, % "Newest version: v" GitJSON.tag_name "`n`nUpdate notes:`n" SubStr(Notes, 2) "`n`nDo you want to update?"
			ifMsgBox yes
			Update(Installer)
		} else {
			MsgBox, 68, % AppName " v" AppVersionString, % "Newest version: v" GitJSON.tag_name "`n`nUpdate notes:`n" SubStr(Notes, 2) "`n`nDo you want to visit download page?"
			ifMsgBox yes
			Run("https://github.com/Run1e/Vibrancer/releases/latest")
		}
		
	} else
		TrayTip("You're up to date!"), od("No updates avaliable")
	
	return
}