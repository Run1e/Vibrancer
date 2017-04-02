CheckForUpdates() {
	URL := "https://github.com/Run1e/PowerPlay/releases"
	
	; get innertext of class release-mate
	wb := ComObjCreate("InternetExplorer.Application")
	wb.Visible := false
	wb.Navigate(URL)
	
	; wait for it to start loading
	Loop
		Sleep 50
	Until (wb.busy)
	
	; wait for it to end loading
	Loop
		Sleep 50
	Until (!wb.busy && (wb.Document.ReadyState = "Complete"))
	
	try
		inner := wb.Document.getElementsByClassName("release-meta")[0].innerText
	catch e {
		TrayTip("Error!", "Failed fetching version number.")
		wb.Quit()
		wb := ""
		return
	}
	wb.Quit()
	wb := ""
	
	; get the version number
	temp := StrSplit(StrSplit(inner, "`n")[1], " ")
	VersionString := SubStr(temp[temp.MaxIndex() - 2], 2)
	NewVersion := StrSplit(VersionString, ".")
	
	for Index, Ver in AppVersion {
		if (Ver < NewVersion[Index])
			NewUpdate := true
		else if (Var > NewVersion[Index]) ; we're ahead of the update, break
			return
	}
	
	if (NewUpdate) {
		Msg := "Do you want to visit the download page?`n`nYour version: v" AppVersion.1 "." AppVersion.2 "." AppVersion.3 "`nLatest version: v" VersionString
		
		MsgBox, 68, %AppName% - New update avaliable!, % Msg
		ifMsgBox yes
		run % URL . "/tag/v" VersionString
	}
	
	return
}