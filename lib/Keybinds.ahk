; passing false deletes every hotkey
; passing true deletes every hotkey and then enables user keybinds and if Big is open, the tab hotkeys
Keybinds(Enable := true) {
	Hotkey.DeleteAll()
	
	if Enable
		for Key, Bind in Keybinds.Object()
			BindKey(Key, Bind)
}

BindKey(Key, Bind) {
	if Bind.Class {
		if Actions[Bind.Class].HasKey("__Class") ; wow that worked?
			try new Hotkey(Key, Actions[Bind.Class, Bind.Func].Bind(Actions[Bind.Class], Bind.Param*))
		else
			try new Hotkey(Key, Actions[Bind.Class, Bind.Func].Bind(Bind.Param*))
	} else
		new Hotkey(Key, Func(Bind.Func).Bind(Bind.Param*))
}