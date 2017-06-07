Area() {
	if Working
		return
	RectClass.Start()
}

Window() {
	if Working
		return
	Working := true
	
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
	
	if !WinGetPosEx(WinActive("A"), x, y, w, h)
		return Working := false
	
	if (x < Left)
		w -= Left-x, x := Left
	if (y < Top)
		h -= Top-y, y := Top
	if ((x+w) > Right)
		w -= x+w-Right
	if ((y+h) > Bottom)
		h -= y+h-Bottom
	
	if (w<0) || (h<0)
		return Working := false
	
	Working := false
	Func := Func("Capture").Bind(x, y, w, h)
	SetTimer, % Func, -1
}

Screen() {
	if Working
		return
	ScreenClass.Start()
}