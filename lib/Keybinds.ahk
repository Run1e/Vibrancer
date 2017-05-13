; passing false disables every hotkey
; passing true disables every hotkey and then enables user keybinds and if Big is open, the tab hotkeys
Keybinds(Enable) {
	
	; special case! :( Capture.ScreenClass uses a hotkey to close so if it's open, we close it manually before doing hotkey stuff
	if Capture.ScreenClass.Capturing
		return Capture.ScreenClass.Close()
	
	Hotkey.DeleteAll()
	
	if Enable && Settings.Keybinds
		for Key, Bind in Keybinds.Data() ; rebind hotkeys
			new Hotkey(Key, Actions[Bind.Func].Bind(Actions, Bind.Param*))
	
	; enable hotkeys for active tab if main gui is open
	if Big.IsVisible
		Big.SetTabHotkeys(Big.ActiveTab)
}