Class JSONFile {
	static Instances := []
	
	__New(File) {
		FileExist := FileExist(File)
		JSONFile.Instances[this] := {File: File, Object: {}}
		ObjRelease(&this)
		FileObj := FileOpen(File, "rw")
		if !IsObject(FileObj)
			throw Exception("Can't access file for JSONFile instance: " File, -1)
		if FileExist {
			try
				JSONFile.Instances[this].Object := JSON.Load(FileObj.Read())
			catch e {
				this.__Delete()
				throw e
			} if (JSONFile.Instances[this].Object = "")
				JSONFile.Instances[this].Object := {}
		} else
			JSONFile.Instances[this].IsNew := true
		return this
	}
	
	__Delete() {
		if JSONFile.Instances.HasKey(this) {
			ObjAddRef(&this)
			JSONFile.Instances.Delete(this)
		}
	}
	
	__Call(Func, Param*) {
		; return instance value (File, Object, FileObj, IsNew)
		if JSONFile.Instances[this].HasKey(Func)
			return JSONFile.Instances[this][Func]
		
		; return formatted json
		if (Func = "JSON")
			return StrReplace(JSON.Dump(this.Object(),, Param.1 ? A_Tab : ""), "`n", "`r`n")
		
		; save the json file
		if (Func = "Save") {
			try
				New := this.JSON(Param.1)
			catch e
				return false
			FileObj := FileOpen(this.File(), "w")
			FileObj.Length := 0
			FileObj.Write(New)
			FileObj.__Handle
			return true
		}
		
		; fill from specified array into the JSON array
		if (Func = "Fill") {
			if !IsObject(Param.2)
				Param.2 := []
			for Key, Val in Param.1 {
				if (A_Index > 1)
					Param.2.Pop()
				HasKey := Param.2.MaxIndex()
						? this.Object()[Param.2*].HasKey(Key) 
						: this.Object().HasKey(Key)
				Param.2.Push(Key)
				if IsObject(Val) && HasKey
					this.Fill(Val, Param.2), Param.2.Pop()
				else if !HasKey
					this.Object()[Param.2*] := Val
			} return
		}
		
		if (Func = "Select") {
			Type := Param.1, Where := Param.2, Is := Param.3
			Obj := Param.4, Results := Param.5
			if !IsObject(Obj)
				Obj := this.Object()
			if !IsObject(Results)
				Results := []
			for Key, Value in Obj {
				if IsObject(Value)
					this.Select(Type, Where, Is, Value, Results)
				else {
					if (Where = "*" && (Value = Is || Is = "*")) 
					|| (Is = "*" && (Key = Where || Where = "*")) 
					|| (Where = Key && Is = Value) {
						if (Type = "Object")
							return Results.Push(Obj)
						else
							Results.Push(Type = "Key" ? Key : Value)
					}
				}
			} return Results
		}
		
		return Obj%Func%(this.Object(), Param*)
	}
	
	__Set(Key, Val) {
		return this.Object()[Key] := Val
	}
	
	__Get(Key) {
		return this.Object()[Key]
	}
}