Class EventListener {
	__New(COM) {
		this.COM := COM
		this.Events := {}
		this.Listener := this.COM.AddListener(this)
		return this
	}
	
	Listen(Event, Call) {
		this.Listener[Event] := false
		this.Events[Event] := Call
	}
	
	StopListen(Event) {
		this.Listener.Delete(Event)
		this.Events.Delete(Event)
	}
	
	OnEvent(Event, Param) {
		Func := this.Call.Bind(this, this.Events[Event], Param*)
		SetTimer, %Func%, -1
	}
	
	Call(BoundFunc, Param*) {
		BoundFunc.Call(Param*)
	}
	
	Object(Param*) {
		return Object(Param*)
	}
}