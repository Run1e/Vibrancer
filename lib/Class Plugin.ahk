
/*
	through this class you can interact with the program and write plugins.
	
	to connect to the class do:
	pp := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
	
	now you can call Get and Call.
	
	for example to disable keybinds you can use Call to call the Keybinds function
	pp.Call("Keybinds", false)
	and to enable keybinds again:
	pp.Call("Keybinds", true)
	
	you can also get global variables/objects with Get
	gui := pp.Get("Big") ; this is the object for the main window
	
	to hide/show the main gui you can do:
	gui.open()
	gui.close()
	or any other method in the BigGUI class
	
	should be worth noting:
	YOU MIGHT CRASH/MESS UP THE PROGRAM BY CALLING STUFF.
	don't fear contacting me if you want to write something, I'll help you with it.
	
	Email: runar-borge@hotmail.com
	AHK Discord where I'm active: https://discord.gg/0eAZhRs7dgWmObae
*/

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