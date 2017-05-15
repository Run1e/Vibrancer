Class Listener {
	static Sessions := {}
	
	__New(Events) {
		this.Events := Events
		this.List := {}
		Listener.Sessions.Push(this)
		return this
	}
	
	Delete() {
		for Index, Instance in Listener.Sessions
			if (Instance = this)
				Listener.Sessions.Delete(Index)
	}
	
	Listen(Event, Stop := false) {
		this.List[Event] := Stop
	}
	
	StopListen(Event) {
		this.List.Delete(Event)
	}
}