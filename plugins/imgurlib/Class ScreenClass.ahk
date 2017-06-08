Class ScreenClass {
	
	static SizeDiv := 1.2
	static Width := A_ScreenWidth / ScreenClass.SizeDiv
	static Height := A_ScreenHeight / ScreenClass.SizeDiv
	static Margin := 10
	static Outline := 2
	static OutlineColor := 0xFFFFFFFF
	static Separator := 10
	
	Start() {
		SysGet, MonitorCount, MonitorCount
		MonitorCOunt = 1
		if (MonitorCount = 1)
			return this.CaptureMonitor(1)
		
		Working := true
		
		this.Vis := new this.ScreenGUI
		this.Vis.Parent := this
		this.Vis.Options("-Caption +ToolWindow +AlwaysOnTop +Border +E0x80000")
		
		this.Vis.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight)
		
		hbm := CreateDIBSection(this.Width, this.Height)
		hdc := CreateCompatibleDC()
		obm := SelectObject(hdc, hbm)
		G := Gdip_GraphicsFromHDC(hdc)
		Gdip_SetInterpolationMode(G, 7)
		
		pPen := Gdip_CreatePen(this.OutlineColor, this.Outline) ; outline pen
		
		this.MonHtk := []
		Bitmaps := []
		
		for MonitorID, Mon in MonitorSetup(this.Width-this.Margin*2, this.Height-this.Margin*2, this.Separator) {
			
			Bitmaps.Push(pBitmap := Gdip_BitmapFromScreen(MonitorID))
			
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
			
			Gdip_TextToGraphics(G, MonitorID
							, "x" Mon.x " y" Mon.y + Mon.h/2 - 56 " w" Mon.w " h" Mon.h " Centre s96 cFFFFFFFF"
							, Settings.Font
							, this.Width
							, this.Height)
			
			CloseBind := this.Close.Bind(this, MonitorID)
			
			HWND := this.Vis.Add("Text"
							, "x" this.Margin + Mon.x
							. " y" this.Margin + Mon.y
							. " w" Mon.w
							. " h" Mon.h
							. " +Border 0x200 Center", MonitorID, CloseBind)
			
			this.MonHtk.Push(new Hotkey(MonitorID, CloseBind))
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
		
		Bitmaps := ""
	}
	
	Close(MonitorID := false) {
		for Index, Htk in this.MonHtk
			Htk.Delete()
		this.MonHtk := ""
		this.Vis.Destroy()
		this.Vis := ""
		
		Working := false
		if MonitorID {
			SysGet, Monitor, Monitor, % MonitorID
			Func := Func("Capture").Bind(   MonitorLeft
									, MonitorTop
									, MonitorRight - MonitorLeft
									, MonitorBottom - MonitorTop)
			SetTimer, % Func, -1
		} else
			Working := false
	}
	
	CaptureMonitor(MonitorID) {
		Working := false
		SysGet, Monitor, Monitor, % MonitorID
		Func := Func("Capture").Bind(   MonitorLeft
									, MonitorTop
									, MonitorRight - MonitorLeft
									, MonitorBottom - MonitorTop)
		SetTimer, % Func, -1
	}
	
	Class ScreenGUI extends GUI {
		Escape() {
			this.Parent.Close()
		}
	}
}