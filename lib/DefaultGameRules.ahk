DefaultGameRules() {
	Games := []
	for Index, Game in GetSteamGames()
		Games[Game.InstallLocation] := {Icon:Game.DisplayIcon, Title:Game.DisplayName, BlockAltTab:false, BlockWinKey:true, Vibrancy:50}
	
	SteamDir := GetSteamDir()
	Games[SteamDir "\steamapps\common\Counter-Strike Global Offensive"].Vibrancy := 85
	Games[SteamDir "\steamapps\common\H1Z1 King of the Kill"].Vibrancy := 75
	return Games
}