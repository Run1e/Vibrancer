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
			Screenshot.CaptureRect()
		else if (Size = "Window")
			Screenshot.CaptureWindow()
		else if (Size = "Full")
			Screenshot.CaptureScreen()
	}
	
	; if running the clipboard fails (ie, not a file/link), it googles it
	RunClipboard() {
		if !StrLen(clipboard) {
			TrayTip, Oops!, Clipboard is empty!
			return
		}
		
		if !Run(clipboard) ; running the clipboard failed, just google the contents
			run % "https://www.google.com/#q=" UriEncode(clipboard)
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
	
	Reload() {
		reload
		ExitApp
	}
	
	Exit() {
		ExitApp
	}
}