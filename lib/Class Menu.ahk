Class Menu {
	static BoundFuncMap := {}
	
	; create new menu
	__New(Name) {
		this.Name := Name
		return this
	}
	
	; add a new item or another sub-menu object
	Add(Item := "", BoundFunc := "", Icon := "") {
		if IsObject(Item)
			Menu % this.Name, Add, % Item.Name, % ":" Item.Name
		else {
			if Menu.BoundFuncMap[this.Name].HasKey(Item)
				return
			Menu % this.Name, Add, % Item, MenuHandler
			if BoundFunc
				Menu.BoundFuncMap[this.Name, Item] := BoundFunc
		} if Icon
			this.Icon(IsObject(Item) ? Item.Name : Item, Icon)
	}
	
	Insert(Pos, Item := "", BoundFunc := "", Icon := "") {
		if IsObject(Item)
			Menu % this.Name, Insert, % Pos, % Item.Name, % ":" Item.Name
		else {
			if Menu.BoundFuncMap[this.Name].HasKey(Item)
				return
			Menu % this.Name, Insert, % Pos, % Item, MenuHandler
			if BoundFunc
				Menu.BoundFuncMap[this.Name, Item] := BoundFunc
		} if Icon
			this.Icon(IsObject(Item) ? Item.Name : Item, Icon)
	}
	
	Delete(Item := "") {
		Menu % this.Name, Delete, % Item
		Menu.BoundFuncMap[this.Name].Delete(Item)
	}
	
	DeleteAll() {
		Menu % this.Name, DeleteAll
	}
	
	Icon(Item := "", Icon := "") {
		Menu % this.Name, Icon, % Item, % Icon
	}
	
	Default(ItemName) {
		Menu % this.Name, Default, % ItemName
		this.Default := ItemName
	}
	
	Show(x := "", y := "") {
		Menu % this.Name, Show, % x, % y
	}
	
	GetCount() {
		return DllCall("GetMenuItemCount", "ptr", this.Handle)
	}
	
	Handle[] {
		get {
			return MenuGetHandle(this.Name)
		}
	}
}

MenuHandler(MenuItem, MenuPos, MenuName) {
	if (MenuName = "Tray") && (MenuItem = "Open")
		Big.Open()
	else
		try Menu.BoundFuncMap[MenuName, MenuItem].Call()
}

; singleton class for the Tray menu
Class Tray extends Menu {
	static _init := Tray.Init()
	
	Init() {
		this.Name := "Tray"
	}
	
	Tip(TipText) {
		Menu, Tray, Tip, % TipText
	}
	
	NoDefault() {
		Menu, Tray, NoDefault
	}
	
	Standard() {
		Menu, Tray, Standard
	}
	
	NoStandard() {
		Menu, Tray, NoStandard
	}
}