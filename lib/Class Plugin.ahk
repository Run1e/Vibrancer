Class Plugin {
	__New() {
		this.CLSID := "{40677552-fdbd-444d-a9dd-6dce43b0cd56}"
		ObjRegisterActive(this, this.CLSID)
	}
	
	; get a global variable/object
	Get(ref) {
		return _:=%ref%
	}
	
	; call a function
	Call(func, param*) {
		return %func%(param*)
	}
}