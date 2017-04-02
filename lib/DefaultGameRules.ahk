DefaultGameRules(){
	Games := []
	for Name, Game in GetSteamGames()
		Games[Game.InstallLocation] := {Icon:Game.DisplayIcon, Title:Name, BlockAltTab:false, BlockWinKey:true, Vibrancy:50}
	
	SteamDir := GetSteamDir()
	Games[SteamDir "\steamapps\common\Counter-Strike Global Offensive"].Vibrancy := 85
	Games[SteamDir "\steamapps\common\H1Z1 King of the Kill"].Vibrancy := 65
	return Games
}

GetSteamGames() {
	ret:=[]
	for Index, Key in ["HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"]
	{
		Loop, Reg, % key, R
		{
			if (A_LoopRegName = "DisplayName") && InStr(A_LoopRegSubKey, "Steam App ") {
				DisplayName := RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayName")
				InstallLocation := RegRead(A_LoopRegKey, A_LoopRegSubkey, "InstallLocation")
				DisplayIcon := RegRead(A_LoopRegKey, A_LoopRegSubKey, "DisplayIcon")
				ret[DisplayName] := {InstallLocation:InstallLocation, appid:StrSplit(A_LoopRegSubKey, " ")[3], DisplayIcon:DisplayIcon} ; formatter weirdly because of reasons
			}
		}
	} return ret
}

GetSteamDir() {
	SteamUninstall := RegRead("HKLM", "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam", "DisplayIcon")
	SplitPath, SteamUninstall,, SteamDir
	return SteamDir
}