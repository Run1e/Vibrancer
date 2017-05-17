Class Plugin {
	__New() {
		this.Listeners := []
		this.CloseOnExit := []
		this.CLSID := "{40677552-fdbd-444d-a9dd-6dce43b0cd56}"
		
		this.AppName := AppName
		this.Version := AppVersion
		this.VersionString := AppVersionString
		this.Directory := A_WorkingDir
		
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
	
	AddListener(hwnd) {
		return (this.Listeners[hwnd] := {})
	}
	
	CreateMenu(Name) {
		return new Menu(Name)
	}
	
	TrayAdd(Name, Call := "", Icon := "") {
		static Added := 1, DefItemCount := 4
		if !Tray.Insert(DefItemCount + Added "&", Name, Call, Icon)
			return
		Added++
		if (Added = 2)
			Tray.Insert("Exit", "")
	}
	
	; === PRIVATE METHODS ===
	
	Event(Event, Param*) {
		for Listener, Events in this.Listeners {
			if Events.HasKey(Event) {
				try {
					Listener.OnEvent(Event, Param*) ; fails here if plugin has exited
					if Events[Event]
						Return := true
				} catch e
					this.Listeners.Delete(Listener)
			}
		} return Return
	}
	
	Launch(Index) {
		static MaxWait := 800 ; max amount of time a plugin has to declare it has finished its autoexec
		if (Plg := Settings.Data().Plugins[Index]) {
			if A_IsCompiled {
				;Run()
			} else
				Run(A_WorkingDir "\plugins\" Plg ".ahk")
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

Event(Event, Param*) {
	return Plugin.Event(Event, Param*)
}