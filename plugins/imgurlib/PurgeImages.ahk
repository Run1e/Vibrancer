PurgeImages() {
	MsgBox,52,Warning,Are you sure you want to purge all images?`n`nThis includes permanently deleting failed uploads and deleted images!
	ifMsgBox no
	return
	
	removed := 0
	
	ImageList := []
	
	for File in Images.Object()
		ImageList.Push(File)
	
	for Index, File in ImageList {
		if !FileExist("..\data\imgur\image\uploaded\" File ".*") {
			Images.Remove(file)
			removed++
		}
	}
	
	Images.Save()
	
	count := 0
	
	Loop, Files, ..\data\imgur\image\uploaded\*.*
	{
		if !Images.HasKey(SubStr(A_LoopFileName, 1, InStr(A_LoopFileName, ".") - 1)) {
			FileDelete % A_LoopFileFullPath
			count++
		}
	}
	
	for Index, Path in ["..\data\imgur\image\deleted\*.*", "..\data\imgur\image\local\*.*"] {
		Loop, Files, % Path
		{
			FileDelete % A_LoopFileFullPath
			count++
		}
	}
	
	MsgBox,48,Purge finished,%count% files deleted and %removed% entries removed.
}

FileExistsNoExt(Path) {
	Loop, Files, % Path ".*"
		return true
	return false
}