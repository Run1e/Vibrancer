Class Debug {
	__New(Param*) {
		return false
	}
	
	LogFolder(LogFolder) {
		if !FileExist(LogFolder) {
			FileCreateDir % LogFolder
			if ErrorLevel
				throw Exception("Failed setting log folder", -1, LogFolder)
		}
		
		this.LogFolder := LogFolder
	}
	
	Log(Ex, Announce := false) {
		Format := A_Hour ":" A_Min ":" A_Sec " (" A_DD "/" A_MM "/" A_YYYY ")"
		. "`n`nMessage: " Ex.Message
		. "`nWhat: " Ex.What
		. "`nExtra:`n" Ex.Extra
		. "`n`nFile: " Ex.File
		. "`nLine: " Ex.Line
		Format := StrReplace(Format, "`n", "`r`n")
		
		FileOpen(this.LogFolder "\" A_Now A_MSec ".txt", "w").Write(Format)
		
		if Announce
			MsgBox, 48, Vibrancer, % "An error occured at " Format "`n`nA log has been saved in the 'logs' folder."
	}
	
	Class Console {
		Alloc() {
			DllCall("AllocConsole", int)
		}
		
		Print(Str) {
			FileAppend, % Str, CONOUT$
		}
	}
	
	Class Timer {
		static _init := Debug.Timer.Init()
		static Timers := []
		
		Init() {
			DllCall("QueryPerformanceFrequency", "Int64P", F)
			this.Freq := F
		}
		
		Current() {
			DllCall("QueryPerformanceCounter", "Int64P", Timer)
			return Timer
		}
		
		Start(ID) {
			this.Timers[ID] := this.Current()
		}
		
		Stop(ID) {
			return ((this.Current() - this.Timers[ID]) / this.Freq), this.Timers.Delete(ID)
		}
	}
	
	Class Print extends Debug.Functor {
		Call(Param*) {
			for Index, Var in Param
				Print .= (IsObject(Var) ? this.Object(Var) : Var) "`n"
			
			return Print
		}
		
		Object(Object, Depth := 5, Indent := "        ") {
			try {
				for Key, Value in Object {
					ret .= "`n" Indent "[" Key "]"
					if (IsObject(Value) && Depth>1)
						ret .= "`n" this.Object(Value, Depth-1, Indent . "       ")
					else
						ret .= " -> " Value
				} return SubStr(ret, 2)
			} return
		}
	}
	
	Class Functor {
		__Call(NewEnum, Param*) {
			return (new this).Call(Param*)
		}
	}
}

m(x*) {
	msgbox % Debug.Print(x*)
}