MakeFolders() {
	for Index, Folder in ["..\data\imgur", "..\data\imgur\image", "..\data\imgur\image\uploaded", "..\data\imgur\image\deleted", "..\data\imgur\image\local"] {
		if !FileExist(Folder) {
			FileCreateDir % Folder
			if ErrorLevel { ; program will fail here first if the program doesn't have permissions to write to disk
				MsgBox,16,Permission error,Unable to create necessary sub-folders.`nMake sure plugin has the permissions it needs!
				ExitApp
			}
		}
	}
}