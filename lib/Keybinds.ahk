; passing false disables every hotkey
; passing true disables every hotkey and then enables user keybinds
Keybinds(Enable) {
	for Key in Hotkey.Keys
		Hotkey.Disable(Key)
	if Enable
		for Key, Bind in Keybinds ; rebind hotkeys
			Hotkey.Bind(Key, Actions[Bind.Func].Bind(Actions, Bind.Param*))
}