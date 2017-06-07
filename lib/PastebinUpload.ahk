PastebinUpload() {
	static EndPoint := "https://pastebin.com/api/api_post.php"
	
	if !StrLen(clipboard)
		return TrayTip("Your clipboard does not contain any text.")
	
	if !StrLen(Settings.PastebinKey)
		return TrayTip("No Pastebin key!", "Please enter your Pastebin API key in the settings.")
	
	Print("Uploading clipboard to pastebin")
	
	POST := {api_dev_key:Settings.PastebinKey, api_option:"paste", api_paste_code:clipboard}
	
	QPC(1)
	
	; timeout of 6 should (emphasis on SHOULD) be enough for pretty much any paste
	if !HTTP.Post(EndPoint, POST)
		return TrayTip("Failed uploading paste")
	
	UploadTime := QPC(0)
	
	Response := POST.ResponseText
	
	
	if (InStr(Response, "https://pastebin.com") = 1) {
		Title := "Clipboard uploaded!"
		Msg := "Link copied to clipboard."
		
		Clipboard(StrReplace(Response, "https://pastebin.com/", "https://pastebin.com/raw/"))
		
		Print("Paste success, uploaded in " UploadTime "s")
		
	} else
		Title := "Paste failed!", Msg := (Response?"Error: " Response:"Request timed out."), Print("Paste failed: " Response)
	
	TrayTip(Title, Msg)
}