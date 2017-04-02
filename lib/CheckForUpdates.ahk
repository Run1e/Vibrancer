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
	NewVersion := SubStr(temp[temp.MaxIndex() - 2], 2)
	
	if (NewVersion > AppVersion) {
		Msg := "Do you want to visit the download page?`n`nYour version: " AppVersion "`nLatest version: " NewVersion
		
		MsgBox, 68, %AppName% - New update avaliable!, % Msg
		ifMsgBox yes
		run % URL . "/tag/v" NewVersion
	}
	
	return
}