Class OnMouseMove {
	__New(Callback) {
		this.Callback := Callback
		this.MouseHook := DllCall( "SetWindowsHookEx"
							, "int", 14 ; WH_MOUSE_LL
							, "uint", RegisterCallback("MouseEventProc", "F",, &this)
							, "uint", 0
							, "uint", 0)
	}
	
	__Delete() {
		DllCall("UnhookWindowsHookEx", "Uint", this.MouseHook)
	}
}

MouseEventProc(nCode, wParam, lParam) {
	Critical
	
	this := Object(A_EventInfo)
	
	if (wParam = 0x200) ; WM_MOUSEMOVE
		this.Callback.Call(NumGet(lParam+0, 0, "int"), NumGet(lParam+4, 0, "int"))
	
	return DllCall("CallNextHookEx", "uint", this.MouseHook, "int", nCode, "uint", wParam, "uint", lParam)
}