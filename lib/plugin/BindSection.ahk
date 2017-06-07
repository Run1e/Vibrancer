Class BindSection {
	__New(COM, Name, Class) {
		this.COM := COM
		try
			this.Binder := this.COM.Get("Binds")
		catch Exception
			throw Exception
		this.Name := Name
		this.Class := Class
		this.Funcs := []
		this.Binds := []
	}
	
	AddFunc(FuncName, FuncRef) {
		this.Funcs.Push(FuncName, FuncRef)
	}
	
	AddBind(Description, FuncName, Params*) {
		Bind := ["Desc", Description, "Class", this.Class, "Func", FuncName]
		if Params.MaxIndex()
			Bind.Push("Param", this.COM.Array(Params*))
		this.Binds.Push(this.COM.Object(Bind*))
	}
	
	Register() {
		this.Binder.NewClass(this.Name, this.Class, this.COM.Object(this.Funcs*))
		for Index, Bind in this.Binds
			this.Binder.Add(this.Name, Bind)
	}
}