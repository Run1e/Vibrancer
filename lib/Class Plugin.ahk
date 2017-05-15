Class Plugin {
	__New() {
		this.CloseOnExit := []
		this.CLSID := "{40677552-fdbd-444d-a9dd-6dce43b0cd56}"
		ObjRegisterActive(this, this.CLSID)
	}
	
	; call if you want power play to close your plugin when it exits
	AutoClose(hwnd) {
		this.CloseOnExit.Push(hwnd)
	}
	
	; call this when your plugin autoexec is finished. it tells powerplay to launch the next plugin
	Finished() {
		if !IsObject(this.NextFunc)
			return
		NextFunc := this.NextFunc
		SetTimer, % NextFunc, Off
		NextFunc.Call()
	}
	
	; get a global variable
	Get(Name) {
		return _:=%Name%
	}
	
	; call a function
	Call(Func, Param*) {
		return %Func%(Param*)
	}
	
	; return function reference
	Func(Name) {
		return Func(Name)
	}
	
	CreateListener(Events) {
		return new Listener(Events)
	}
	
	CreateMenu(Name) {
		return new Menu(Name)
	}
	
	TrayAdd(Name, Call := "", Icon := "") {
		static Added, DefItemCount := 3
		Added++
		Tray.Insert(DefItemCount + Added "&", Name, Call, Icon)
		if (Added = 1)
			Tray.Insert("Exit", "")
	}
	
	; === PRIVATE METHODS ===
	
	Event(Event, Param*) {
		for Index, Lstn in Listener.Sessions {
			if Lstn.List.HasKey(Event) {
				try {
					(Lstn.Events)[Event](Param*)
					if Lstn.List[Event]
						Return := true
				}
			}
		} return Return
	}
	
	Launch(Index) {
		static MaxWait := 800 ; max amount of time a plugin has to declare it's finished it's autoexec
		if (Plg := Settings.Data().Plugins[Index]) {
			Run(A_WorkingDir "\plugins\" Plg)
			this.NextFunc := NextFunc := this.Launch.Bind(this, Index + 1)
			SetTimer, % NextFunc, % "-" MaxWait
		} else
			this.NextFunc := ""
	}
	
	Exit() {
		for Index, hwnd in this.CloseOnExit
			PostMessage, 0x10,,,, % "ahk_id" hwnd ; WM_CLOSE=0x10
	}
}