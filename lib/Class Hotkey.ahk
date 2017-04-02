class Hotkey {
	static Keys := [] ; keep track of hotkeys
	
	; bind a hotkey to a function/label
	Bind(Key, Target, HWND := "") { ; target = label or function reference
		if this.Keys[Key].Disabled ; disable if hotkey already exists
			this.Enable(Key)
		Hotkey, IfWinActive, % ((HWND+=0) ? "ahk_id" HWND : "") ; HWND+=0 forces hex to dec
		Hotkey, % Key, % (IsLabel(Target) ? Target : "HotkeyHandler"), UseErrorLevel
		return !ErrorLevel ? this.Keys[Key] := {Target:Target, HWND:HWND} : ErrorLevel
	}
	
	; enable a hotkey
	Enable(Key) {
		Hotkey, IfWinActive, % (this.Keys[Key].HWND ? "ahk_id" this.Keys[Key].HWND : "")
		Hotkey, % Key, On, UseErrorLevel
		return ErrorLevel ? ErrorLevel : this.Keys[Key].Remove("Disabled")
	}
	
	; disable a hotkey
	Disable(Key) {
		Hotkey, IfWinActive, % (this.Keys[Key].HWND ? "ahk_id" this.Keys[Key].HWND : "")
		Hotkey, % Key, Off, UseErrorLevel
		return ErrorLevel ? ErrorLevel : !(this.Keys[Key].Disabled := true)
	}
	
	; rebind an existing hotkey
	Rebind(Key, NewKey) {
		if a := this.Disable(Key)
			return a
		return this.Bind(NewKey, this.Keys[Key].target, this.Keys[Key].HWND)
	}
}

HotkeyHandler:
Hotkey.Keys[A_ThisHotkey].Target.Call()
return