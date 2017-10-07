GetApplications() {
	ret := []
	for Index, Info in ObjSortOverKey(GetSteamGames(), "DisplayName")
		ret.Push(Info)
	for Index, Info in ObjSortOverKey(GetPrograms(), "DisplayName")
		ret.Push(Info)
	return ret
}

GetPrograms() {
	ret:=[]
	dir_keywords := ["unin", "driver", "help", "update", "{", "[", "~"]
	for Index, Key in ["HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"]
	{
		Loop, Reg, % Key, R
		{
			if (A_LoopRegName = "DisplayName") && !InStr(A_LoopRegSubKey, "Steam App ") {
				name := RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayName")
				icon := StrSplit(trim(RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayIcon"), """"), ",")[1]
				SplitPath, icon,, icondir, iconext
				if (iconext != "exe")
					continue
				for Index, Word in ["unin", "driver", "help", "update", "{", "[", "~"]
					if InStr(icon, word) || InStr(loc, word)
						continue 2
				for Index, Word in ["unin", "driver", "help", "update", "NVIDIA", "eReg", ".NET", "Microsoft Security Client", "Visual C++", "Battlelog", "AutoHotkey"]
					if InStr(name, word)
						continue 2
				for Index, Word in ["{"]
					if InStr(A_LoopRegSubKey, word)
						continue 2
				if StrLen(name)
					ret.Push({DisplayName:name, InstallLocation:icon, Run: icon})
			}
		}
	} return ret
}

GetSteamGames() {
	ret:=[]
	for Index, Key in ["HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"]
		Loop, Reg, % Key, R
			if (A_LoopRegName = "DisplayName") && InStr(A_LoopRegSubKey, "Steam App ")
				ret.Push(	{ DisplayName: RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayName")
						, InstallLocation: RegRead(A_LoopRegKey, A_LoopRegSubkey, "InstallLocation")
						, DisplayIcon: RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayIcon")
						, Run: "steam://rungameid/" StrSplit(A_LoopRegSubKey, " ")[3]}) ; formatted weirdly because of reasons
	return ret
}

GetSteamDir() {
	SteamUninstall := RegRead("HKLM", "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam", "DisplayIcon")
	SplitPath, SteamUninstall,, SteamDir
	return SteamDir
}

GetWindows() {
	static no_pls := "AutoHotkey.exe|NVIDIA Share.exe|Calculator.exe|SystemSettings.exe"
	HiddenWin := A_DetectHiddenWindows
	DetectHiddenWindows, Off
	WinGet windows, List
	lst := []
	Loop %windows%
	{
		ID := windows%A_Index%
		WinGetTitle title, % "ahk_id" ID
		WinGet, path, ProcessPath, % "ahk_id" ID
		WinGet, exe, ProcessName, % "ahk_id" ID
		WinGet, test, MinMax, % "ahk_id" ID
		if !WinExist("ahk_id" ID) || !StrLen(Title) || InStr(exe, "Host.exe") || (exe ~= "^(" no_pls ")$")
			continue
		lst.Push({Title: title, Path: path})
	}
	
	DetectHiddenWindows % HiddenWin
	return lst
}

ObjSortOverKey(obj, key) {
	ret := []
	for a, b in obj
		ret[b.Delete(key)] := b
	for a, b in ret, ret2:=[]
		ret2[a] := (b, b[key] := a)
	return ret2
}