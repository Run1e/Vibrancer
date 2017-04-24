; octicons from github, can be used when adding a menu item via a plugin
InstallFiles() {
	ico_sha := "52614380F058B92408A9125AA4EA7EE023364865"
	exe_sha := "1951CF372BE01143FE75E06377CEC686F892BC7C"
	
	if !FileExist("icons") 
		FileCreateDir icons
	
	if !FileExist("icons\octicons")
		FileCreateDir icons\octicons
	
	if (FileSHA1("icons\powerplay.ico") != ico_sha)
		FileInstall, icons\powerplay.ico, icons\powerplay.ico
	
	if A_IsCompiled {
		FileInstall, D:\Documents\Scripts\octicons\arrow-up.ico, icons\octicons\arrow-up.ico
		FileInstall, D:\Documents\Scripts\octicons\gear.ico, icons\octicons\gear.ico
		FileInstall, D:\Documents\Scripts\octicons\x.ico, icons\octicons\x.ico
		FileInstall, D:\Documents\Scripts\octicons\bug.ico, icons\octicons\bug.ico
		FileInstall, D:\Documents\Scripts\octicons\person.ico, icons\octicons\person.ico
		FileInstall, D:\Documents\Scripts\octicons\device-desktop.ico, icons\octicons\device-desktop.ico
		FileInstall, D:\Documents\Scripts\octicons\plus.ico, icons\octicons\plus.ico
		FileInstall, D:\Documents\Scripts\octicons\dash.ico, icons\octicons\dash.ico
		
		; install uploader exe if compiled and file has changed
		if (FileSHA1("PowerPlayUploader.exe") != exe_sha) {
			FileInstall, D:\Documents\Scripts\PowerPlay\PowerPlayUploader.exe, PowerPlayUploader.exe, 1
			while !FileExist("PowerPlayUploader.exe")
				sleep 50
		}
	}
}

Icon(name := "") {
	if (name = "icon")
		return "icons\powerplay.ico"
	return "icons\octicons\" name ".ico"
}