MakeFolders() {
	for Index, Folder in ["data", "menus", "logs", "images", "images\imgur", "images\local", "images\deleted", "icons", "icons\octicons"] {
		if !FileExist(Folder) {
			FileCreateDir % Folder
			if ErrorLevel {
				MsgBox,48,Permissions error,Unable to create necessary subfolders.`n`nMake sure Power Play is installed a place where it has the permissions it needs (for example: C:\PowerPlay\), 10000
				run % A_ScriptDir
				ExitApp
			}
		}
	}
}