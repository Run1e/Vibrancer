; return an array of monitor x/y/w/h coords that fit into the parameter dimensions
MonitorSetup(MaxWidth, MaxHeight, Separator := 2) {
	
	; get monitor count
	SysGet, MonitorCount, MonitorCount
	
	; loop through the monitors to get their coords
	mon := []
	Loop, %MonitorCount%
	{
		SysGet, Monitor, Monitor, %A_Index%
		mon[A_Index] := {Top:MonitorTop, Left: MonitorLeft, Bot:MonitorBottom, Right:MonitorRight}
	}
	
	; get the lowest x, y pos which will act as x0 and y0 later
	MonLowX := MonGetLow(mon, "left")
	MonLowY := MonGetLow(mon, "top")
	
	; find maximum width and height of all screens combined
	MonWidth := MonGetHigh(mon, "right") - MonLowX
	MonHeight := MonGetHigh(mon, "bot") - MonLowY
	
	; holds the offset of each monitor (for separating)
	adds_x:=[]
	adds_y:=[]
	
	; figure out which screens have to be offset to make the separators
	for a, s in mon {
		for z, x in mon {
			if (s.left = x.right) { ; shared vertical side, offset x
				adds_x[a] := (adds_x[z]?adds_x[z]:0) + Separator
				add_x += Separator
			} if (s.top = x.bot) { ; shared horizontal side, offset y
				adds_y[a] := (adds_y[z]?adds_y[z]:0) + Separator
				add_y += Separator
			}
		}
	}
	
	; subtract the maxwidth/height used in further calculations because of the separators we added
	MaxWidth -= add_x
	MaxHeight -= add_y
	
	; figure out if we need to restrict the size because of the height or width
	if (MonWidth/MonHeight > MaxWidth/MaxHeight)
		tick := MonWidth/MaxWidth, Type:=1 ; limited by width
	else
		tick := MonHeight/MaxHeight, Type:=2 ; limited by height
	
	; figure out the final positions of everything before sending them back for drawing
	for a, b in mon, Monitors:={} {
		Monitors[a] := { X: Round(((b.left - MonLowX) / tick) + (Type=2?(MaxWidth - MonWidth/tick)/2:0) + (adds_x[a]?adds_x[a]:0))
					, Y: Round(((b.top - MonLowY) / tick) + (Type=1?(MaxHeight - MonHeight/tick)/2:0) + (adds_y[a]?adds_y[a]:0))
					, W: Round((b.right - b.left) / tick)
					, H: Round((b.bot - b.top) / tick)}
	}
	
	return Monitors
}

MonGetLow(obj, key) {
	low:=obj.1[key]
	for a, b in obj
		if (low > b[key])
			low := b[key]
	return low
}

MonGetHigh(obj, key) {
	high:=obj.1[key]
	for a, b in obj
		if (high < b[key])
			high := b[key]
	return high
}