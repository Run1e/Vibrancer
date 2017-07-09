SelectObjects(Obj, Key, Val) {
	return ObjSelect.Get(Obj, "Object", Key, Val)
}

SelectKeys(Obj, Key, Val) {
	return ObjSelect.Get(Obj, "Key", Key, Val)
}

SelectValues(Obj, Key, Val) {
	return ObjSelect.Get(Obj, "Value", Key, Val)
}

Class ObjSelect {
	static ObjectRE := "i)^(Object|Obj|O)$"
	static KeyRE := "i)^(Key|K)$"
	static ValueRE := "i)^(Value|Val|V)$"
	
	Get(Obj, Type := "O", KeyMatcher := "", ValueMatcher := "", Results := "") {
		if IsObject(KeyMatcher) {
			if IsFunc(KeyMatcher.1)
				KeyFunc := Func(KeyMatcher.1)
			else if this.Funcs.HasKey(KeyMatcher.1)
				KeyFunc := this.Funcs[KeyMatcher.1].Bind(this)
			else
				throw KeyMatcher.1 " is not a function or ObjSelect method."
			KeyMatch := KeyMatcher.2
		} else
			KeyFunc := this.Match.Bind(this), KeyMatch := KeyMatcher
		
		if IsObject(ValueMatcher) {
			if IsFunc(ValueMatcher.1)
				ValueFunc := Func(ValueMatcher.1)
			else if this.Funcs.HasKey(ValueMatcher.1)
				ValueFunc := this.Funcs[ValueMatcher.1].Bind(this)
			else
				throw ValueFunc.1 " is not a function or ObjSelect method."
			ValueMatch := ValueMatcher.2
		} else
			ValueFunc := this.Match.Bind(this), ValueMatch := ValueMatcher
		
		if !IsObject(Results)
			Results := []
		
		for Key, Value in Obj {
			if IsObject(Value)
				this.Get(Value, Type, KeyMatcher, ValueMatcher, Results)
			else if KeyFunc.Call(Key, KeyMatch) && ValueFunc.Call(Value, ValueMatch) {
				if (Type ~= this.ObjectRE)
					return Results, Results.Push(Obj)
				Results.Push(Type ~= this.KeyRE ? Key : (Type ~= this.ValueRE ? Value : ""))
			}
		}
		
		return Results
	}
	
	Match(Obj, User) {
		if (Obj = User) || (User = "*" || User = "")
			return true
		return false
	}
	
	Class Funcs {
		IsTrueAHK(Obj, User) {
			return Obj
		}
		
		IsFalseAHK(Obj, User) {
			return !Obj
		}
		
		IsTrue(Obj, User) {
			return Obj = true
		}
		
		IsFalse(Obj, User) {
			return Obj = false
		}
		
		MoreThan(Obj, User) {
			return Obj > User
		}
		
		LessThan(Obj, User) {
			return Obj < User
		}
		
		Contains(Obj, User) {
			return InStr(Obj, User)
		}
		
		StartsWith(Obj, User) {
			return InStr(Obj, User) = 1
		}
		
		EndsWith(Obj, User) {
			return SubStr(Obj, -1 - StrLen(User)) = Obj
		}
	}
}