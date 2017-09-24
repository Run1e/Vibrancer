SelectObjects(Obj, Key := "", Val := "") {
	return ObjSelect.Select.Objects(Obj, Key, Val)
}

SelectKeys(Obj, Key := "", Val := "") {
	return ObjSelect.Select.Keys(Obj, Key, Val)
}

SelectValues(Obj, Key := "", Val := "") {
	return ObjSelect.Select.Values(Obj, Key, Val)
}

Class ObjSelect {
	Class Functor {
		__Call(Type, Obj, Key, Val) {
			return (new this(Type, Key, Val)).Parse(Obj, {})
		}
	}
	
	Class Select extends ObjSelect.Functor {
		__New(Type, Key, Val) {
			Type := Type ~= "i)^(Objects|Object|Obj)$" ? "O"
				: (Type ~= "i)^(Keys|Key)$" ? "K"
				: (Type ~= "i)^(Values|Value|Val)$" ? "V" : ""))
			
			if !(Type ~= "i)^(O|K|V)$")
				throw Exception(Type " is not a valid type", -1)
			
			this.Type := Type
			this.Key := Key
			this.Val := Val
		}
		
		Parse(Obj, Res) {
			for Key, Val in Obj {
				if this.Match(this.Key, Key) && this.Match(this.Val, Val)
					Res.Push(this.Type = "O" ? Obj
						: (this.Type = "K" ? Key
						: (this.Type = "V" ? Val : "")))
				
				if IsObject(Val)
					this.Parse(Val, Res)
			}
			
			return Res
		}
		
		Match(Prop, Var) {
			if (Prop = "" || Prop = "*")
				return true
			if (Prop = Var)
				return true
			return false
		}
	}
}