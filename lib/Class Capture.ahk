Class Capture {
	static Upload := true
	static ImageQuality := 100 ; in %
	
		; gdip solution later maybe?
	Rect() {
		static abort
		color=999999
		r:=2
		w:=120
		Gui 55: -Caption +AlwaysOnTop +Border +LastFound hwndmousehover -E0x20
		Gui 55: Show
		WinSet, Region,0-0 w%w% h%w% R300-300, % "ahk_id" mousehover
		WinSet, Transparent, 5, ahk_id %mousehover%
		Loop 4 {
			num:=50+A_Index
			Gui %num%: Color, % color
			Gui %num%: -Caption +ToolWindow +AlwaysOnTop
		} Cursor("IDC_CROSS")
		while (!GetKeyState("LButton", "P")) {
			MouseGetPos, xn, yn
			Gui 55: Show, % "NA X" xn - w/2 " Y" yn - w/2 " W" w " H" w
			if GetKeyState("Escape", "P") {
				abort:=true
				goto abort
			} sleep 16
		} MouseGetPos, x, y
		while (GetKeyState("LButton", "P")) {
			MouseGetPos, xn, yn
			Gui 51: Show, % "NA X" (xn < x ? xn : x) " Y" y " W" abs(xn-x) + r " H" r ; CD
			Gui 52: Show, % "NA X" (xn < x ? xn : x) " Y" yn " W" abs(xn-x) + r " H" r ; AB
			Gui 53: Show, % "NA X" x " Y" (yn < y ? yn : y) " W" r " H" abs(yn-y) ; AD
			Gui 54: Show, % "NA X" xn " Y" (yn < y ? yn : y) " W" r " H" abs(yn-y) ; BC
			Gui 55: Show, % "NA X" xn - w/2 " Y" yn - w/2
			if GetKeyState("Escape", "P") {
				abort:=true
				goto abort
			} sleep 16
		}
		abort:
		Loop 5 {
			num:=50+A_Index
			Gui %num%: Destroy
		} Cursor()
		if !abort
			Capture.Capture(x < xn ? x : xn, y < yn ? y : yn, abs(xn-x), abs(yn-y))
		abort:=false
		return
	}
	
	Window() {
		WinGetPos, x, y, w, h, A
		if ErrorLevel {
			TrayTip("Failed getting active window position.")
			return Error("Failed to get WinPos", A_ThisFunc, "ErrorLevel set by WinGetPos: " ErrorLevel)
		}
		Capture.Capture(x, y, w, h)
	}
	
	Screen() {
		Capture.Capture(0, 0, A_ScreenWidth, A_ScreenHeight)
	}
	
	Capture(x, y, w, h) {
		if !StrLen(x) || !StrLen(y) || !StrLen(w) || !StrLen(h)
			return Error("Invalid parameters passed", A_ThisFunc, x ", " y ", " w ", " h, true)
		
		Name := A_Now A_MSec
		File := this.LocalImageFolder "\" Name ".png" ; save to local image folder
		
		pBitmap := Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
		
		Gdip_Success := Gdip_SaveBitmapToFile(pBitmap, File, this.ImageQuality)
		if (Gdip_Success < 0) {
			Error := {  -1:"Extension supplied is not a supported file format"
					, -2:"Could not get a list of encoders on system"
					, -3:"Could not find matching encoder for specified file format"
					, -4:"Could not get WideChar name of output file"
					, -5:"Could not save file to disk"}[Gdip_Success]
			return Error(Error, A_ThisFunc ": Gdip_SaveBitmapToFile", "File: " File "`nImageQuality: " this.ImageQuality, true)
		}
		
		Gdip_DisposeImage(pBitmap)
		
		Uploader.Upload(File)
		
		return Name
	}
}