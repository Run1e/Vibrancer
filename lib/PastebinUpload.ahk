PastebinUpload() {
	static EndPoint := "https://pastebin.com/api/api_post.php"
	
	if !StrLen(clipboard)
		return TrayTip("Your clipboard does not contain any text.")
	
	if !StrLen(Settings.PastebinKey)
		return TrayTip("No Pastebin key!", "Please enter your Pastebin API key in the settings.")
	
	POST := {api_dev_key:Settings.PastebinKey, api_option:"paste", api_paste_code:clipboard}
	
	; timeout of 6 should (emphasis on SHOULD) be enough for pretty much any paste
	Response := POST(EndPoint, POST, 6)
	
	if (InStr(Response, "https://pastebin.com") = 1) {
		Title := "Clipboard pasted!"
		Msg := "Link copied to clipboard."
		
		if !Big.IsVisible {
			for Key, Bind in Keybinds {
				if (Bind.Func = "RunClipboard") {
					Msg .= "`nClipboard Keybind: " HotkeyToString(Key)
					break
				}
			}
		}
		
		clipboard := StrReplace(Response, "https://pastebin.com/", "https://pastebin.com/raw/")
		
	} else
		Title := "Paste failed!", Msg := (Response?"Error: " Response:"Request timed out.")
	
	TrayTip(Title, Msg)
}