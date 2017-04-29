; all methods return false on failure
Class Hotkey {
	static Keys := {} ; keep track of instances
	static KeyEnabled := {} ; keep track of state of hotkeys
	
	__New(Key, Target, Win := false, Type := "Active") {
		
		; check input
		if !StrLen(Key)
			return false, ErrorLevel := 2
		if !(Bind := IsLabel(Target) ? Target : this.Handler.Bind(this))
			return false, ErrorLevel := 1
		if !(Type ~= "i)(Active|NotActive|Exist|NotExist)$")
			return false, ErrorLevel := 4
		
		; set values
		this.Key := Key
		this.Target := Target
		this.Win := Win
		this.Type := Type
		
		; enable if previously disabled
		if (Hotkey.KeyEnabled[Type, Win, Key] = false)
			this.Apply("On")
		
		; bind the key
		if !this.Apply(Bind)
			return false
		
		this.Enabled := true ; set to enabled
		Hotkey.Keys[Type, Win, Key] := this ; save instance in Keys object
		return this
	}
	
	; 'delete' a hotkey. call this when you're done with a hotkey
	; this is superior to Disable() as it releases the function references
	Delete() {
		if this.Disable() {
			Hotkey.Keys[this.Type, this.Win].Remove(this.Key)
			return true
		} return false
	}
	
	; enable hotkey
	Enable() {
		if this.Apply("On")
			return this.Enabled := true
		return false
	}
	
	; disable hotkey
	Disable() {
		if this.Apply("Off") {
			this.Enabled := false
			return true
		} return false
	}
	
	; toggle enabled/disabled
	Toggle() {
		return this.Apply(this.Enabled ? "Off" : "On")
	}
	
	; ===== CALLED VIA BASE OBJECT =====
	
	; enable all hotkeys
	EnableAll() {
		Hotkey.CallAll("Enable")
	}
	
	; disable all hotkeys
	DisableAll() {
		Hotkey.CallAll("Disable")
	}
	
	; delete all hotkeys
	DeleteAll() {
		Hotkey.CallAll("Delete")
	}
	
	; get a global hotkey from it's key name
	GetGlobal(Key) {
		return Hotkey.Keys["Active", false, Key]
	}
	
	; ===== PRIVATE =====
	
	Enabled[] {
		get {
			return Hotkey.KeyEnabled[this.Type, this.Win, this.Key]
		}
		
		set {
			return Hotkey.KeyEnabled[this.Type, this.Win, this.Key] := value
		}
	}
	
	Handler() {
		this.Target.Call()
	}
	
	Apply(Label) {
		Hotkey, % "IfWin" this.Type, % this.Win ? this.Win : ""
		if ErrorLevel
			return false
		Hotkey, % this.Key, % Label, UseErrorLevel
		if ErrorLevel
			return false
		return true
	}
	
	CallAll(Method) {
		Instances := []
		for Index, Type in Hotkey.Keys
			for Index, Win in Type
				for Index, Htk in Win
					Instances.Push(Htk)
		for Index, Instance in Instances
			Instance[Method].Call(Instance)
	}
}