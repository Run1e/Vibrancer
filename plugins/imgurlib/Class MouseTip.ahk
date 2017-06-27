Class MouseTip {
	Create(Msg, Duration := 1000) {
		static FinishFunc := MouseTip.Finish.Bind(MouseTip)
		
		this.Msg := Msg
		this.Duration := Duration
		
		MouseGetPos, x, y
		this.OnMouseMove(x, y)
		
		if this.Running {
			SetTimer, % FinishFunc, % "-" Duration
			return
		} else
			this.Running := true
		
		this.MouseHook := new OnMouseMove(this.OnMouseMove.Bind(this))
		
		SetTimer, % FinishFunc, % "-" Duration
	}
	
	OnMouseMove(x, y) {
		ToolTip, % this.Msg
	}
	
	Finish() {
		ToolTip
		this.Running := false
		this.MouseHook := ""
	}
}