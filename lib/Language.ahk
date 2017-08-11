SetLanguage() {
	
	Lang := GetLanguageInfo()
	
	Big.SetText(Big.GamesTabHWND, Lang.BIG.TAB_GAMES)
	Big.SetText(Big.KeybindsTabHWND, Lang.BIG.TAB_KEYBINDS)
	
	Big.SetText(Big.GameAddHWND, Lang.BIG.GAME_ADD)
	Big.SetText(Big.GameDeleteHWND, Lang.BIG.GAME_REMOVE)
	Big.SetText(Big.WinKeyBlockHWND, Lang.BIG.BLOCK_WINDOWS)
	Big.SetText(Big.AltTabBlockHWND, Lang.BIG.BLOCK_ALT_TAB)
	Big.SetText(Big.BindDeleteHWND, Lang.BIG.BIND_REMOVE)
	Big.SetText(Big.BindAddHWND, Lang.BIG.BIND_ADD)
	Big.SetText(Big.VibrancySliderTextHWND, Lang.BIG.VIB_BOOST)
	Big.SetText(Big.VibrancyScreenHWND, Lang.BIG.VIB_SCREEN)
	Big.SetText(Big.PrimaryScreenHWND, Lang.BIG.VIB_PRIMARY_SELECTED)
	
	for Index, Button in [Big.GameDeleteHWND, Big.GameAddHWND, Big.BindDeleteHWND, Big.BindAddHWND]
		ImageButtonApply(Button)
	
	bordermix := 0xFFEEEEEE ;CK
	NORMAL := [  [0, 0x80FFFFFF, , 0xD3000000, 0, , 0xFFFFFFFF, 1] ; normal
			,  [0, bordermix, , 0xD3000000, 0, , bordermix, 1] ; hover
			,  [0, bordermix , , 0xD3000000, 0, , bordermix, 1] ; pressed
			,  [0, Settings.Color.Tab, , 0xFFFFFF, 0, , Settings.Color.Tab, 1] ; disabled
			,  [0, 0xFFFFFFFF, , 0xFF000000, 0, , 0xFFFFFFFF, 1]] ; default
	
	for Index, TabberBOYE in [Big.GamesTabHWND, Big.KeybindsTabHWND]
		ImageButton.Create(TabberBOYE, NORMAL*)
	
}

GetLanguageInfo() {
	if !FileExist("language\" Settings.Language ".ini") {
		if !FileExist("language\english.ini") {
			m("Your language files are missing, please redownload the installer and run it.")
			run("http://www.vibrancer.com/")
			return
		} Settings.Language := "english"
		return GetLanguageInfo()
	}
	return ParseIni(FileOpen("language\" Settings.Language ".ini", "r").Read())
}

; super quick and ugly asf ini parser
ParseIni(contents) {
	obj := []
	for Index, Line in StrSplit(contents, "`n") {
		if !InStr(Line := trim(Line), "=") && StrLen(Line) && (InStr(Line, "[") = 1)
			obj[Section := trim(Line, "[]`r`n")] := []
		else if StrLen(Section)
			if StrLen(Key := SubStr(Line, 1, InStr(Line, "=") - 1))
				obj[Section][Key] := trim(SubStr(Line, InStr(Line, "=") + 1), "`r`n")
	} return obj
}