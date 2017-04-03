; free octicons from github, can be used when adding a menu item via a plugin
IconInstall() {
	
	if !FileExist("icons") 
		FileCreateDir icons
	
	if !FileExist("icons\octicons")
		FileCreateDir icons\octicons
	
	FileInstall, icons\powerplay.ico, icons\powerplay.ico
	
	FileInstall, D:\Documents\Scripts\octicons\arrow-up.ico, icons\octicons\arrow-up.ico
	FileInstall, D:\Documents\Scripts\octicons\gear.ico, icons\octicons\gear.ico
	FileInstall, D:\Documents\Scripts\octicons\x.ico, icons\octicons\x.ico
	FileInstall, D:\Documents\Scripts\octicons\bug.ico, icons\octicons\bug.ico
	FileInstall, D:\Documents\Scripts\octicons\person.ico, icons\octicons\person.ico
	FileInstall, D:\Documents\Scripts\octicons\device-desktop.ico, icons\octicons\device-desktop.ico
	FileInstall, D:\Documents\Scripts\octicons\plus.ico, icons\octicons\plus.ico
	FileInstall, D:\Documents\Scripts\octicons\dash.ico, icons\octicons\dash.ico
	
}