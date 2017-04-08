Class Capture {
	static Upload := true
	static ImageQuality := 100 ; in %
	
	
	Rect() {
		this.RectClass.Start()
	}
	
	Class RectClass {
		Start() {
			static WH_MOUSE_LL := 14
			
			Keybinds(false)
			
			this.CD := 33 ; circle diameter
			this.CircleLuma := 1
			this.RectLuma := 25
			
			this.Finishing := false
			this.Dragging := false
			
			; create the circle gui
			this.Vis := new this.RectGUI
			this.Vis.Parent := this
			
			this.Vis.Options("-E0x20 +AlwaysOnTop -Caption +Border +ToolWindow")
			this.Vis.WinSet("Region", "w" this.CD " h" this.CD " 0-0 R" this.CD "-" this.CD)
			this.Vis.WinSet("Transparent", this.CircleLuma)
			
			MouseGetPos, x, y
			this.Vis.Show("x" x - this.CD/2 " y" y - this.CD/2 " w" this.CD " h" this.CD)
			
			Cursor("IDC_CROSS")
			
			this.MouseHook := DllCall("SetWindowsHookEx", "int", WH_MOUSE_LL, "uint", RegisterCallback("MouseProc"), "uint", 0, "uint", 0)
		}
		
		OnMouseMove(x, y) {
			if GetKeyState("LButton", "P") { ; draggin
				
				; set initial vars
				if !this.Dragging {
					this.Dragging := true
					this.sx:=x
					this.sy:=y
					this.Vis.Pos(0, 0, 0, 0) ; "hide" for a sec
					this.Vis.WinSet("Transparent", this.RectLuma)
					this.Vis.WinSet("Region", "") ; make rect again
				}
				
				; move rect
				this.Vis.Pos(	  nx := (this.sx<x?this.sx:x)
							, ny := (this.sy<y?this.sy:y)
							, abs(this.sx-x) + (nx>this.sx?-1:1)
							, abs(this.sy-y) + (ny>this.sy?-1:1))
				
			} else if this.Dragging
				this.Close(true)
			else ; not started dragging
				this.Vis.Pos(x - this.CD/2, y - this.CD/2, this.CD, this.CD)
		}
		
		Close(Upload := false) {
			
			if this.Finishing
				return
			
			this.Finishing := true
			
			; unhook mouse hook
			DllCall("UnhookWindowsHookEx", "Uint", this.MouseHook)
			
			; destroy window
			this.Vis.Destroy()
			this.Vis := ""
			
			Cursor() ; reset cursor
			
			Keybinds(true)
			
			; capture
			if this.Dragging && Upload {
				MouseGetPos, x, y
				func := Capture.Capture.Bind(Capture, (this.sx<x?this.sx:x), (this.sy<y?this.sy:y), abs(this.sx-x), abs(this.sy-y))
				SetTimer, %func%, -1 ; start upload init in a new thread, this one freaks out if we don't.
			}
		}
		
		; listen for escape key press
		Class RectGUI extends GUI {
			Escape() {
				this.Parent.Close()
			}
		}
	}
	
	Window() {
		Pos := WinGetPos("A")
		if !Pos {
			TrayTip("Failed getting active window position.")
			return Error("Failed to get WinPos", A_ThisFunc, "ErrorLevel set by WinGetPos: " ErrorLevel)
		} this.Capture(Pos.x, Pos.y, Pos.w, Pos.h)
	}
	
	Screen() {
		this.ScreenClass.Start()
	}
	
	Class ScreenClass {
		Start() {
			static Size := 1.8
				, Width := A_ScreenWidth / Size
				, Height := A_ScreenHeight / Size
				, Margin := 10
				, Outline := 2
				, OutlineColor := 0x85AAAAAA
				, Separator := 10
			
			SysGet, MonitorCount, MonitorCount
			
			if (MonitorCount = 1)
				return this.CaptureMonitor(1)
			
			Keybinds(false)
			
			this.Capturing := true
			
			Hotkey.Bind("Escape", this.Close.Bind(this))
			
			this.Vis := new GUI
			this.Vis.Parent := this
			this.Vis.Options("-Caption +ToolWindow +AlwaysOnTop +Border +E0x80000")
			
			this.Vis.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight)
			
			hbm := CreateDIBSection(Width, Height)
			hdc := CreateCompatibleDC()
			obm := SelectObject(hdc, hbm)
			G := Gdip_GraphicsFromHDC(hdc)
			Gdip_SetInterpolationMode(G, 7)
			
			pPen := Gdip_CreatePen(OutlineColor, Outline) ; outline pen
			
			Bitmaps := []
			
			for MonitorID, Mon in MonitorSetup(Width-Margin*2, Height-Margin*2, Separator) {
				
				pBitmap := Gdip_BitmapFromScreen(MonitorID)
				
				bWidth := Gdip_GetImageWidth(pBitmap)
				bHeight := Gdip_GetImageHeight(pBitmap)
				
				Gdip_DrawRectangle(G, pPen, Margin + Mon.x, Margin + Mon.y, Mon.w, Mon.h)
				
				Gdip_DrawImage(G, pBitmap, Margin + Mon.x + Outline - 1, Margin + Mon.y + Outline - 1, Mon.w - Outline*2 + 1, Mon.h - Outline*2 + 1, 0, 0, bWidth, bHeight)
				
				Bitmaps.Push(pBitmap)
				
				HWND := this.Vis.Add("Text"
								, "x" Margin + Mon.x
								. " y" Margin + Mon.y
								. " w" Mon.w
								. " h" Mon.h
								. " +Border 0x200 Center", MonitorID, this.CaptureMonitor.Bind(this, MonitorID, true))
			}
			
			UpdateLayeredWindow(this.Vis.hwnd, hdc, A_ScreenWidth / 2 - Width / 2, A_ScreenHeight / 2 - Height / 2, Width, Height)
			
			Gdip_DeletePen(pPen)
			SelectObject(hdc, obm)
			DeleteObject(hbm)
			DeleteDC(hdc)
			Gdip_DeleteGraphics(G)
			
			for Index, Bitmap in Bitmaps
				Gdip_DisposeImage(Bitmap)
			
			Bitmaps := []
		}
		
		Close() {
			this.Vis.Destroy()
			this.Vis := ""
			this.Capturing := false
			Keybinds(true)
		}
		
		CaptureMonitor(MonitorID, Close := false) {
			if Close
				this.Close()
			
			SysGet, Monitor, Monitor, % MonitorID
			
			Capture.Capture( MonitorLeft
						, MonitorTop
						, MonitorRight - MonitorLeft
						, MonitorBottom - MonitorTop)
		}
	}
	
	Capture(x, y, w, h) {
		if !StrLen(x) || !StrLen(y) || !StrLen(w) || !StrLen(h)
			return Error("Invalid parameters passed", A_ThisFunc, x ", " y ", " w ", " h, true)
		
		Name := A_Now A_MSec
		File := Uploader.LocalImageFolder "\" Name ".png" ; save to local image folder
		
		pBitmap := Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
		
		Gdip_Success := Gdip_SaveBitmapToFile(pBitmap, File, Uploader.ImageQuality)
		if (Gdip_Success < 0) {
			Error := {  -1:"Extension supplied is not a supported file format"
					, -2:"Could not get a list of encoders on system"
					, -3:"Could not find matching encoder for specified file format"
					, -4:"Could not get WideChar name of output file"
					, -5:"Could not save file to disk"}[Gdip_Success]
			return Error(Error, A_ThisFunc ": Gdip_SaveBitmapToFile", "File: " File "`nImageQuality: " Uploader.ImageQuality, true)
		}
		
		Gdip_DisposeImage(pBitmap)
		
		if !FileExist(File)
			return Error("Failed creating file for upload.", A_ThisFunc, "Name: " name)
		
		if this.Upload
			Uploader.Upload(File)
		
		return Name
	}
}

MouseProc(nCode, wParam, lParam) {
	Critical
	
	if (wParam = 0x200) ; WM_MOUSEMOVE
		Capture.RectClass.OnMouseMove(NumGet(lParam+0,0,"int"), NumGet(lParam+4,0,"int"))
	
	return DllCall("CallNextHookEx", "uint", Capture.RectClass.MouseHook, "int", nCode, "uint", wParam, "uint", lParam)
}