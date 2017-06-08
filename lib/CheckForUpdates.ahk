CheckForUpdates() {
	static URL := "https://api.github.com/repos/Run1e/Vibrancer/releases/latest"
	
	Event("CheckForUpdates")
	
	; get github api info on the vibrancer repo
	if !HTTP.Get(URL, Data)
		return TrayTip("Failed getting update info")
	
	if (Data.Status != 200)
		return TrayTip("GitHub request failed")
	
	; load into obj
	GitJSON := JSON.Load(Data.ResponseText)
	Installer := "https://github.com/Run1e/Vibrancer/releases/download/" GitJSON.tag_name "/Vibrancer-installer.zip"
	
	if (GitJSON.tag_name > SubStr(AppVersionString, 2)) {
		if A_IsCompiled {
			MsgBox, 68, % AppName " " AppVersionString, % "Newest version: v" GitJSON.tag_name "`n`nDo you want to update?"
			ifMsgBox yes
			Update(Installer)
		} else {
			MsgBox, 68, % AppName " " AppVersionString, % "Newest version: v" GitJSON.tag_name "`n`nDo you want to visit download page?"
			ifMsgBox yes
			Run("https://github.com/Run1e/Vibrancer/releases/latest")
		}
	} else
		TrayTip("You're up to date!")
	
	return
}