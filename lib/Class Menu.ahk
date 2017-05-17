Class Menu {
	static Instances := []
	
	__New(Name) {
		this.Name := Name
		this.Map := {}
		Menu.Instances[Name] := this
	}
	
	__Destroy() {
		this.Delete()
	}
	
	Show(x := "", y := "") {
		Menu % this.Name, Show, % x, % y
	}
	
	Add(Item := "", Target := "", Icon := "") {
		if IsObject(Item) { ; add menu
			try
				Menu % this.Name, Add, % Item.Name, % ":" Item.Name
			catch e
				return false
		} else { ; add item
			try
				Menu % this.Name, Add, % Item, MenuHandler
			catch e
				return false
			this.Map[Item] := Target
		} if StrLen(Icon)
			this.Icon(IsObject(Item)?Item.Name:Item, Icon)
		return true
	}
	
	Insert(Pos, Item := "", Target := "", Icon := "") {
		if IsObject(Item) { ; add menu
			try
				Menu % this.Name, Insert, % Pos, % Item.Name, % ":" Item.Name
			catch e
				return false
		} else { ; add item
			try
				Menu % this.Name, Insert, % Pos, % Item, MenuHandler
			catch e
				return false
			this.Map[Item] := Target
		} if StrLen(Icon)
			this.Icon(IsObject(Item)?Item.Name:Item, Icon)
		return true
	}
	
	Delete(ItemName := "") {
		Menu % this.Name, Delete, % ItemName
	}
	
	Icon(Item, Icon) {
		if !StrLen(Item)
			return false
		if !FileExist(Icon)
			return false
		Menu % this.Name, Icon, % Item , % Icon
		return ErrorLevel
	}
	
	Color(Color) {
		Menu % this.Name, Color, % Color
	}
	
	GetCount() {
		return DllCall("GetMenuItemCount", "ptr", MenuGetHandle(this.Name))
	}
	
	Destroy() {
		this.DeleteAll()
	}
	
	Clear() {
		this.NoStandard()
		this.NoDefault()
		this.DeleteAll()
	}
	
	DeleteAll() {
		Menu, % this.Name, DeleteAll
	}
	
	NoDefault() {
		Menu, % this.Name, NoDefault
	}
	
	NoStandard() {
		Menu, % this.Name, NoStandard
	}
	
	SetDefault(item) {
		Menu, % this.Name, Default, % item
	}
}

MenuHandler(ItemName, ItemPos, MenuName) {
	Menu.Instances[MenuName].Map[ItemName].Call()
}

Class Tray extends Menu {
	__New() {
		Name := "Tray"
		this.Name := Name
		this.Map := {}
		Menu.Instances[Name] := this
		this.Clear()
	}
}