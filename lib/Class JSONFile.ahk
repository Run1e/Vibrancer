; wraps coco's JSON class and handles everything I need in regards to JSON files
Class JSONFile {
	static Instances := []
	
	__New(File) {
		JSONFile.Instances[this] := []
		Contents := "{}"
		if FileExist(File)
			FileRead, Contents, % File
		try
			JSONFile.Instances[this].Data := JSON.Load(Contents)
		catch e
			JSONFile.Instances[this].Data := {}
		if !IsObject(JSONFile.Instances[this].Data)
			JSONFile.Instances[this].Data := {}
		JSONFile.Instances[this].File := File
		return this
	}
	
	__Destroy() {
		JSONFile.Instances.Remove(this)
	}
	
	__Call(Func, Param*) {
		if (JSONFile.Instances[this].HasKey(Func))
			return JSONFile.Instances[this][Func]
		
		; fill from specified array into the JSON array
		else if (Func = "Fill") {
			if !IsObject(Param.2)
				Param.2 := []
			for Key, Val in Param.1 {
				if (A_Index > 1)
					Param.2.Pop()
				HasKey := (Param.2.MaxIndex() ? this.Data()[Param.2*].HasKey(Key) : this.Data().HasKey(Key))
				Param.2.Push(Key)
				if IsObject(Val) && HasKey
					this.Fill(Val, Param.2), Param.2.Pop()
				else if !HasKey
					this.Data()[Param.2*] := Val
			} return
		}
		
		; save the json file
		else if (Func = "Save") {
			FileRead, Contents, % this.File()
			FileDelete, % this.File()
			try
				FileAppend, % this.JSON(), % this.File()
			catch e {
				FileAppend, % Contents, % this.File()
				throw e
			} return
		}
		
		; reset the object from file
		else if (Func = "Refresh") {
			FileRead, Contents, % this.File()
			JSONFile.Instances[this].Data := JSON.Load(Contents)
		}
		
		; get the plain text json
		else if (Func = "JSON")
			return JSON.Dump(this.Data(),, A_Tab)
		
		; check if files exists
		else if (Func = "FileExist")
			return !!FileExist(this.File())
		
		; else, call the object method on the data object
		else
			return Obj%Func%(this.Data(), Param*)
	}
	
	__Set(Key, Val) {
		return this.Data()[Key] := Val
	}
	
	__Get(Key) {
		return this.Data()[Key]
	}
}