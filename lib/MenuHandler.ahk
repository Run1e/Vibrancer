MenuHandler(ItemName, ItemPos, MenuName) {
	
	FuncName := Menu.Map[MenuName, ItemName].Func
	FuncParam := Menu.Map[MenuName, ItemName].Param
	ParamCount := FuncParam.MaxIndex()?FuncParam.MaxIndex():0
	
	if !StrLen(FuncName)
		return
	
	Method := Actions[FuncName]
	
	ErrorMsg := "FuncName: " FuncName "`nFuncParam:`n" pa(FuncParam) "`nItemName: " ItemName "`nItemPos: " ItemPos "`nMenuName: " MenuName
	
	if !IsObject(Method)
		return Error("Tried calling a non-existent Actions method", A_ThisFunc, ErrorMsg, true)
	else if (ParamCount > Method.MaxParams-1)
		return Error("Too many parameters passed to Actions method", A_ThisFunc, ErrorMsg, true)
	else if (ParamCount < Method.MinParams-1)
		return Error("Too few parameters passed to Actions method", A_ThisFunc, ErrorMsg, true)
	
	Method.Call(Actions, FuncParam*)
} ; "ItemName: " ItemName "`nItemPos: " ItemPos "`nMenuName: " MenuName "`nAction: " Action