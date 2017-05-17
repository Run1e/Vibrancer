CheckForUpdates() {
	static URL := "https://api.github.com/repos/Run1e/PowerPlay/releases/latest"
	
	; get github api info on the powerplay repo
	if !HTTP.Get(URL, Data)
		return TrayTip("Failed fetching update info")
	
	; load into obj
	GitJSON := JSON.Load(Data.ResponseText)
	
	; check whether new update is out
	NewVersion := StrSplit(GitJSON.tag_name, ".")
	
	for Index, Ver in AppVersion {
		if (Ver < NewVersion[Index]) {
			NewUpdate := true
			break
		} else if (Ver > NewVersion[Index]) {
			NewUpdate := false
			break
		}
	}
	
	; keep it simple fam. for now at least
	if NewUpdate {
		MsgBox, 68, % AppName " " AppVersionString, % "Newest version: v" GitJSON.tag_name "`n`nDo you want to visit the download page?"
		ifMsgBox yes
		Run(GitJSON.html_url)
	} else
		TrayTip("You're up to date!")
	
	return
}