Class Plugin {
	__New() {
		this.Listeners := []
		this.OnExits := []
		
		this.AppName := AppName
		this.Version := AppVersion
		this.VersionString := AppVersionString
		this.Directory := A_WorkingDir
		
		ObjRegisterActive(this, "{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
	}
	
	test() {
		m(Binds.List)
		m(Actions)
	}
	
	; create an object in here if you need to pass to pp and still have it be for-loopable
	Object(Param*) {
		return Object(Param*)
	}
	
	Array(Param*) {
		return Array(Param*)
	}
	
	; call if you want power play to close your plugin when it exits
	OnExit(Func) {
		this.OnExits.Push(Func)
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
	
	AddListener(Listener) {
		return this.Listeners[Listener] := {}
	}
	
	CreateMenu(Name) {
		return new Menu(Name)
	}
	
	TrayAdd(Name := "", Call := "", Icon := "") {
		static Added := 1, DefItemCount := 4
		
		try
			Tray.Insert(Added + DefItemCount "&", Name, Call, Icon)
		catch Exception
			ErrorEx(Exception, true)
		
		Added++
		if (Added = 2) {
			try
				Tray.Insert("Donate", "")
			catch e
				Tray.Insert("Exit", "")
		}
	}
	
	; === PRIVATE METHODS ===
	
	Event(Event, Param*) {
		for Listener, Events in this.Listeners {
			if Events.HasKey(Event) {
				try Listener.OnEvent(Event, this.MakeLoopable(Listener, this.MakeIndexed(Param)))
				catch e
					this.Listeners.Delete(Listener)
			}
		}
	}
	
	MakeLoopable(Listener, Obj) {
		for Key, Value in Obj, Back := []
			Back.Push(IsObject(Value) ? this.MakeLoopable(Listener, Value) : Value)
		return Listener.Object(Back*)
	}
	
	MakeIndexed(Obj) {
		for Key, Value in Obj, Back := []
			Back.Push(Key, IsObject(Value) ? this.MakeIndexed(Value) : Value)
		return Back
	}
	
	Run(Plg) {
		Run(A_WorkingDir "\lib\AutoHotkey.exe """ A_WorkingDir "\plugins\" Plg ".ahk""")
	}
	
	Launch(Index) {
		static MaxWait := 800 ; max amount of time a plugin has to declare it has finished its autoexec
		if (Plg := Settings.Data().Plugins[Index]) {
			try
				this.Run(Plg)
			catch e
				Settings.Plugins.Delete(Index)
			this.NextFunc := NextFunc := this.Launch.Bind(this, Index + 1)
			SetTimer, % NextFunc, % "-" MaxWait
		} else
			PluginsLaunched()
	}
	
	Exit() {
		for Index, Func in this.OnExits
			try Func.Call()
	}
}

Event(Event, Param*) {
	return Plugin.Event(Event, Param*)
}