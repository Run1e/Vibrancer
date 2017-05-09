Class Capture {
	static Upload := true
	static ImageQuality := 100 ; in %
	
	
	Rect() {
		this.RectClass.Start()
	}
	
	Class RectClass {
		
		static CD := 160
		static CircleLuma := 1
		static RectLuma := 70
		
		Start() {
			Keybinds(false)
			
			this.Finishing := false
			this.Dragging := false
			
			; create the circle gui
			this.Vis := new this.RectGUI
			this.Vis.Parent := this
			
			this.Vis.Color(727272)
			this.Vis.Options("-E0x20 +AlwaysOnTop -Caption +Border +ToolWindow") ; border makes it update nicer for some reason
			this.Vis.WinSet("Region", "w" this.CD " h" this.CD " 0-0 R" this.CD "-" this.CD)
			this.Vis.WinSet("Transparent", this.CircleLuma)
			
			MouseGetPos, x, y
			this.Vis.Show("x" x - this.CD/2 " y" y - this.CD/2 " w" this.CD " h" this.CD)
			
			Cursor("IDC_CROSS")
			
			new Hotkey("LButton", this.StartDrag.Bind(this))
			
			this.MouseHook := new OnMouseMove(this.OnMouseMove.Bind(this))
		}
		
		StartDrag() {
			this.Dragging := true
			
			ShowCursor(false)
			
			MouseGetPos, x, y
			this.sx := x, this.sy := y
			
			this.Vis.Pos(0, 0, 0, 0) ; "hide" for a sec while changing stuff
			this.Vis.WinSet("Region", "") ; make rect again
			this.Vis.WinSet("Transparent", this.RectLuma)
			
			this.OnMouseMove(x, y)
			
			new Hotkey("LButton Up", this.Close.Bind(this, true))
		}
		
		; add a small offset so we never get a 0x0 size image
		OnMouseMove(x, y) {
			static Offset := 2
			if this.Dragging { ; draggin
				this.Vis.Pos(	  this.dx := (x>=this.sx?this.sx:x-Offset)
							, this.dy := (y>=this.sy?this.sy:y-Offset)
							, this.dw := abs(x-this.sx) + Offset
							, this.dh := abs(y-this.sy) + Offset)
			} else {
				this.Vis.Pos(	  x - this.CD/2
							, y - this.CD/2
							, this.CD
							, this.CD)
			}
		}
		
		Close(Upload) {
			if this.Finishing
				return
			
			this.Finishing := true
			
			; unhook mouse hook
			this.MouseHook := ""
			
			; destroy window
			this.Vis.Destroy()
			this.Vis := ""
			
			ShowCursor(true)
			Cursor() ; reset cursor
			
			Keybinds(true)
			
			; capture
			if Upload {
				func := Capture.Capture.Bind(	  Capture
										, this.dx
										, this.dy
										, this.dw
										, this.dh)
				
				SetTimer, %func%, -1 ; start upload init in a new thread, this one freaks out if we don't.
			}
		}
		
		; listen for escape key press
		Class RectGUI extends GUI {
			Escape() {
				this.Parent.Close(false)
			}
		}
	}
	
	Window() {
		Mon := []
		SysGet, MonitorCount, MonitorCount
		Loop, %MonitorCount%
		{
			SysGet, Monitor, Monitor, %A_Index%
			Mon[A_Index] := {Top:MonitorTop, Left: MonitorLeft, Bottom:MonitorBottom, Right:MonitorRight}
		}
		
		Left := MonGetLow(Mon, "Left")
		Right := MonGetHigh(Mon, "Right")
		Top := MonGetLow(Mon, "Top")
		Bottom := MonGetHigh(Mon, "Bottom")
		
		if !(WinGetPosEx(WinActive("A"), x, y, w, h))
			return
		
		if (x < Left)
			w -= Left-x, x := Left
		if (y < Top)
			h -= Top-y, y := Top
		if ((x+w) > Right)
			w -= x+w-Right
		if ((y+h) > Bottom)
			h -= y+h-Bottom
		
		if (w<0) || (h<0)
			return
		
		this.Capture(x, y, w, h)
	}
	
	Screen() {
		this.ScreenClass.Start()
	}
	
	Class ScreenClass {
		
		static Width := A_ScreenWidth / 1.35
		static Height := A_ScreenHeight / 1.35
		static Margin := 10
		static Outline := 2
		static OutlineColor := 0xFFFFFFFF ; white with no transparency
		static Separator := 10
		
		Start() {
			if (SysGet("MonitorCount") = 1)
				return this.CaptureMonitor(1)
			
			Keybinds(false)
			
			this.Capturing := true
			
			new Hotkey("Escape", this.Close.Bind(this))
			
			this.Vis := new GUI
			this.Vis.Parent := this
			this.Vis.Options("-Caption +ToolWindow +AlwaysOnTop +Border +E0x80000")
			
			this.Vis.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight)
			
			hbm := CreateDIBSection(this.Width, this.Height)
			hdc := CreateCompatibleDC()
			obm := SelectObject(hdc, hbm)
			G := Gdip_GraphicsFromHDC(hdc)
			Gdip_SetInterpolationMode(G, 7)
			
			pPen := Gdip_CreatePen(this.OutlineColor, this.Outline) ; outline pen
			
			Bitmaps := []
			
			for MonitorID, Mon in MonitorSetup(this.Width-this.Margin*2, this.Height-this.Margin*2, this.Separator) {
				
				pBitmap := Gdip_BitmapFromScreen(MonitorID)
				
				bWidth := Gdip_GetImageWidth(pBitmap)
				bHeight := Gdip_GetImageHeight(pBitmap)
				
				Gdip_DrawRectangle(G, pPen
								, this.Margin + Mon.x
								, this.Margin + Mon.y
								, Mon.w, Mon.h)
				
				Gdip_DrawImage(G, pBitmap
							, this.Margin + Mon.x + this.Outline - 1
							, this.Margin + Mon.y + this.Outline - 1
							, Mon.w - this.Outline*2 + 1
							, Mon.h - this.Outline*2 + 1
							, 0, 0, bWidth, bHeight)
				
				Bitmaps.Push(pBitmap)
				
				HWND := this.Vis.Add("Text"
								, "x" this.Margin + Mon.x
								. " y" this.Margin + Mon.y
								. " w" Mon.w
								. " h" Mon.h
								. " +Border 0x200 Center", MonitorID, this.CaptureMonitor.Bind(this, MonitorID, true))
			}
			
			UpdateLayeredWindow(this.Vis.hwnd, hdc
							, A_ScreenWidth / 2 - this.Width / 2
							, A_ScreenHeight / 2 - this.Height / 2
							, this.Width, this.Height)
			
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
		File := Uploader.LocalFolder "\" Name ".png" ; save to local image folder
		
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
		
		if !FileExist(File)
			return Error("Failed creating file for upload.", A_ThisFunc, "Name: " name)
		
		if this.Upload
			Uploader.Upload(File)
		
		return Name
	}
}

; found base code somewhere, I cleaned up it *drastically*
ShowCursor(Show) {
	static Init := false, DefaultCurs := [], BlankCurs := []
	static SysCurs := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]
	
	if !Init {
		VarSetCapacity(AndMask, 32*4, 0xFF)
		VarSetCapacity(XorMask, 32*4, 0)
		for Index, Curs in SysCurs {
			DefaultCurs[A_Index] := DllCall("CopyImage", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", Curs), "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)
			BlankCurs[A_Index] := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", &AndMask, "Ptr", &XorMask)
		}
	}
	
	for Index, Curs in SysCurs
		DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", (Show ? DefaultCurs : BlankCurs)[A_Index], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", Curs)
}

; https://autohotkey.com/boards/viewtopic.php?t=29793 ty jNizM
GetCursorInfo() ; https://msdn.microsoft.com/en-us/library/ms648381(v=vs.85).aspx
{
	NumPut(VarSetCapacity(CURSORINFO, 16 + A_PtrSize, 0), CURSORINFO, "uint")
	if !(DllCall("user32\GetCursorInfo", "ptr", &CURSORINFO))
		return A_LastError
	return NumGet(CURSORINFO, 8, "ptr") ; hCursor
}