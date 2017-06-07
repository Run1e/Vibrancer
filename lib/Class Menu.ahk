Class Menu {
	static BoundFuncMap := {}
	
	; create new menu
	__New(Name) {
		this.Name := Name
		return this
	}
	
	; add a new item or another sub-menu object
	Add(Item := "", BoundFunc := "", Icon := "") {
		if IsObject(Item) {
			try
				Menu % this.Name, Add, % Item.Name, % ":" Item.Name
			catch Exception
				throw Exception
		} else {
			try {
				Menu % this.Name, Add, % Item, MenuHandler
				if BoundFunc
					Menu.BoundFuncMap[this.Name, Item] := BoundFunc
			} catch Exception
				throw Exception
		} if Icon
			this.Icon(IsObject(Item) ? Item.Name : Item, Icon)
	}
	
	Insert(Pos, Item := "", BoundFunc := "", Icon := "") {
		if IsObject(Item) {
			try
				Menu % this.Name, Insert, % Pos, % Item.Name, % ":" Item.Name
			catch Exception
				throw Exception
		} else {
			try {
				Menu % this.Name, Insert, % Pos, % Item, MenuHandler
				if BoundFunc
					Menu.BoundFuncMap[this.Name, Item] := BoundFunc
			} catch Exception
				throw Exception
		} if Icon
			this.Icon(IsObject(Item) ? Item.Name : Item, Icon)
	}
	
	Delete(Item := "") {
		try
			Menu % this.Name, Delete, % Item
		catch Exception
			throw Exception
	}
	
	Icon(Item := "", Icon := "") {
		try
			Menu % this.Name, Icon, % Item, % Icon
		catch Exception
			throw Exception
	}
	
	Default(ItemName) {
		try {
			Menu % this.Name, Default, % ItemName
			this.Default := ItemName
		} catch Exception
			throw Exception
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
	Menu.BoundFuncMap[MenuName, MenuItem].Call()
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