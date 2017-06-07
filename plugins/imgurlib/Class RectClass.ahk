Class RectClass {
	
	static CD := 160
	static CircleLuma := 1
	static RectLuma := 70
	
	Start() {
		Working := true
		
		this.Finishing := false
		this.Dragging := false
		
		; create the circle gui
		this.Vis := new this.RectGUI
		this.Vis.Parent := this
		
		this.Vis.Color(727272)
		this.Vis.Options("-E0x20 +AlwaysOnTop -Caption +Border +ToolWindow") ; +border makes it update nicer for some reason
		this.Vis.WinSet("Region", "w" this.CD " h" this.CD " 0-0 R" this.CD "-" this.CD)
		this.Vis.WinSet("Transparent", this.CircleLuma)
		
		MouseGetPos, x, y
		this.Vis.Show("x" x - this.CD/2 " y" y - this.CD/2 " w" this.CD " h" this.CD)
		
		Cursor("IDC_CROSS")
		
		this.HtkDown := new Hotkey("LButton", this.StartDrag.Bind(this))
		this.MouseHook := new OnMouseMove(this.OnMouseMove.Bind(this))
	}
	
	StartDrag() {
		this.Dragging := true
		this.HtkDown.Delete()
		ShowCursor(false)
		
		MouseGetPos, x, y
		this.sx := x, this.sy := y
		
		/*
			this.AB := this.Vis.Add("Text", "0x6")
			this.BC := this.Vis.Add("Text", "0x6")
			this.DC := this.Vis.Add("Text", "0x6")
			this.AD := this.Vis.Add("Text", "0x6")
		*/
		
		this.Vis.Pos(0, 0, 0, 0) ; "hide" for a sec while changing stuff
		this.Vis.WinSet("Region", "") ; make rect again
		this.Vis.WinSet("Transparent", this.RectLuma)
		
		this.OnMouseMove(x, y)
		
		this.HtkUp := new Hotkey("LButton Up", this.Close.Bind(this))
	}
	
		; add a small offset so we never get a 0x0 size image
	OnMouseMove(x, y) {
		static Offset := 2
		if this.Dragging { ; draggin
			
			this.Vis.Pos(	  this.dx := (x>=this.sx?this.sx:x-Offset)
							, this.dy := (y>=this.sy?this.sy:y-Offset)
							, this.dw := abs(x-this.sx) + Offset
							, this.dh := abs(y-this.sy) + Offset)
			
			/*
				this.Vis.Control("Move", this.AB, "x0 y0 w" this.dw - 2 " h2")
				this.Vis.Control("Move", this.BC, "x" this.dw - 2 " y0 w2 h" this.dh - 2)
				this.Vis.Control("Move", this.DC, "x2 y" this.dh - 2 " w" this.dw - 2 " h2")
				this.Vis.Control("Move", this.AD, "x0 y2 w2 h" this.dh - 2)
			*/
			
		} else {
			this.Vis.Pos(	  x - this.CD/2
							, y - this.CD/2
							, this.CD
							, this.CD)
		}
	}
	
	Close(Escaped := false) {
		if this.Finishing
			return
		
		this.Finishing := true
		this.MouseHook := ""
		
		if Escaped ; escape press, htkdown is still active
			this.HtkDown.Delete()
		this.HtkUp.Delete()
		
		; destroy window
		this.Vis.Destroy()
		this.Vis := ""
		
		ShowCursor(true)
		Cursor() ; reset cursor
		
		Working := false
		if !Escaped {
			Func := Func("Capture").Bind(this.dx, this.dy, this.dw, this.dh)
			SetTimer, % Func, -1
		}
	}
	
		; listen for escape key press
	Class RectGUI extends GUI {
		Escape() {
			this.Parent.Close(true)
		}
	}
}