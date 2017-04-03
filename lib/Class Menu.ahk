Class Menu {
	static Instances := []
	
	__New(MenuName, Handler := "MenuHandler") {
		this.Name := MenuName
		this.Handler := Handler
		this.Menu := {}
		Menu.Instances[MenuName] := this
		if (MenuName = "Tray")
			this.Clear()
	}
	
	Show(x := "", y := "") {
		Menu % this.Name, Show, % x, % y
	}
	
	Add(Item := "") {
		if IsObject(Item) { ; add menu
			this.Menu.Insert(Item.Menu)
			Menu % this.Name, Add, % Item.Name, % ":" Item.Name
		} else { ; add item
			Menu % this.Name, Add, % Item, % this.Handler
			this.Menu.Insert(Item)
		}
	}
	
	Delete(ItemName) {
		Menu % this.Name, Delete, % ItemName
		for Index, Item in this.Menu
			if (Item = ItemName)
				return this.Menu.RemoveAt(Index)
	}
	
	Icon(Item, Icon) {
		if !FileExist(Icon)
			return false
		Menu % this.Name, Icon, % Item , % Icon
		return ErrorLevel
	}
	
	Color(Color) {
		Menu % this.Name, Color, % Color
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