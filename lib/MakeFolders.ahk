MakeFolders() {
	for Index, Folder in ["data", "logs", "plugins", "icons", "icons\octicons"] {
		if !FileExist(Folder) {
			FileCreateDir % Folder
			if ErrorLevel { ; program will fail here first if the program doesn't have permissions to write to disk
				MsgBox,16,Permission error,Unable to create necessary sub-folders`nTry uninstalling and installing to a different folder. (ex: C:\PowerPlay\)
				ExitApp
			}
		}
	}
}