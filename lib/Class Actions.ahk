Class Actions {
	static List := GetActionsList()
	
	Send(Input) {
		SendInput % Input
	}
	
	SendRaw(Input) {
		SendRaw % Input
	}
	
	Run(param) {
		if !Run(param)
			Error("Run() failed.", A_ThisFunc, param, true)
	}
	
	Screenshot(Size) {
		if (Size = "Area")
			Capture.Rect()
		else if (Size = "Window")
			Capture.Window()
		else if (Size = "Full")
			Capture.Screen()
	}
	
	; if running the clipboard fails (ie, not a file/link), it googles it
	RunClipboard() {
		if !StrLen(clipboard)
			return TrayTip("Clipboard is empty!")
		
		if !Run(clipboard) ; running the clipboard failed, just google the contents
			Run("https://www.google.com/#q=" HTTP.UriEncode(clipboard))
	}
	
	UploadClip() {
		PastebinUpload()
	}
	
	Open(tab := "") {
		Big.Open(tab)
	}
	
	Settings() {
		Settings()
	}
	
	ListVars() {
		ListVars
	}
	
	CheckForUpdates() {
		CheckForUpdates()
	}
	
	PrintHeaders() {
		for a, b in Uploader.LastHeaders
			if InStr(a, "X-Post-Rate-Limit")
				temp .= a ": " b "`n"
		if StrLen(temp)
			TrayTip("IMGUR HEADERS", temp)
		else
			TrayTip("No headers stored.")
	}
	
	PrintSettings() {
		m(Settings)
	}
	
	PrintKeybinds() {
		m(Keybinds)
	}
	
	PrintHotkeys() {
		m(Hotkey.Keys)
	}
	
	GetDownloadCount() {
		static URL := "https://api.github.com/repos/Run1e/PowerPlay/releases"
		if !HTTP.Get(URL, Data)
			return TrayTip("Failed getting download count")
		JSONData := JSON.Load(Data.ResponseText)
		for a, b in JSONData
			count += b.assets.1.download_count
		MouseTip.Create(count)
	}
	
	OpenConsole() {
		ForceConsole := true
		p()
	}
	
	Reload() {
		reload
		ExitApp
	}
	
	Exit() {
		ExitApp
	}
}