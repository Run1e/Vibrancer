JSONFile(Name, Default := "", Fill := true) {
	File := A_WorkingDir "\data\" Name ".json"
	
	if !FileExist(File) {
		if Default
			DefaultObj := Default.Call()
		else
			DefaultObj := {}
		FileAppend, % JSON.Dump(DefaultObj,, A_Tab), % File
		Save := true
	}
	
	try
		JSONobj := JSON.Load(FileRead(File))
	catch error ; failed getting object from file, quit program
		ErrorEx(error,, true)
	
	if Fill {
		if !DefaultObj {
			if Default
				DefaultObj := Default.Call()
			else
				DefaultObj := {}
		} FillArr(JSONobj, DefaultObj)
		Save := true
	}
	
	if Save
		JSONSave(Name, JSONobj)
	
	return JSONobj
}

JSONSave(Name, Obj) {
	File := A_WorkingDir "\data\" Name ".json"
	FileRead, Contents, % File
	FileDelete % File
	
	try
		JSONdump := JSON.Dump(Obj,, A_Tab)
	catch error {
		FileAppend, % Contents, % File
		ErrorEx(error,, true)
		return
	}
	
	FileAppend % JSONdump, % A_WorkingDir "\data\" Name ".json"
}

; fill missing key/val pairs in ArrToFill, parsed over from ReferenceArr
FillArr(ByRef FillArr, ReferenceArr, path:="") {
	if !IsObject(path)
		path:=[]
	for Key, Value in ReferenceArr {
		HasKey := (path.MaxIndex()?FillArr[path*].HasKey(Key):FillArr.HasKey(Key))
		if IsObject(Value) && HasKey
			path.Insert(Key), FillArr(FillArr, Value, path), path.Pop()
		else {
			if !HasKey {
				if path.MaxIndex()
					FillArr[path*][Key] := Value
				else
					FillArr[Key] := Value
			}
		}
	}
}