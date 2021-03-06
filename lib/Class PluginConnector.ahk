﻿Class PluginConnector {
	static _init := PluginConnector.Init()
	
	Init() {
		this.Listeners := []
		this.OnExits := []
		
		this.Name := App.Name
		this.Version := App.Version
		this.VersionString := App.VersionString
		this.Directory := A_WorkingDir
		
		ObjRegisterActive(this, "{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
	}
	
	Print(Str) {
		p(Str)
	}
	
	p(str) {
		p(str)
	}
	
	; create an object in here if you need to pass to pp and still have it be for-loopable
	Object(Param*) {
		return Object(Param*)
	}
	
	Array(Param*) {
		return Array(Param*)
	}
	
	; call if you want vibrancer to close your plugin when it exits
	OnExit(Func) {
		this.OnExits.Push(Func)
	}
	
	; call this when your plugin autoexec is finished. it tells vibrancer to launch the next plugin
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
			Debug.Log(Exception, true)
		
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
		p("EVENT: " Event, Param)
		for Listener, Events in this.Listeners {
			if Events.HasKey(Event) {
				try
					Listener.OnEvent(Event, this.MakeLoopable(Listener, this.MakeIndexed(Param)))
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
	
	Launch(Index) {
		static MaxWait := 2500 ; max amount of time a plugin has to declare it has finished its autoexec
		
		if StrLen(RunPlug := Settings.Object().Plugins[Index]) {
			try
				Run(A_WorkingDir "\Vibrancer.exe """ A_WorkingDir "\plugins\" RunPlug ".ahk""")
			catch e {
				p("Plugin " RunPlug " not found, removing from list")
				Settings.Plugins.Delete(Index)
			}
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
	return PluginConnector.Event(Event, Param*)
}