/*
	in keybinds:
	"key": {
		func: funcname
		params: [array of parameters]
	}
*/

Class Binds {
	static _init := Binds.Init()
	
	Init() {
		
		Spotify :=	[ {Desc: "Play/Pause", Class: "Spotify", Func: "PlayPause"}
					, {Desc: "Next", Class: "Spotify", Func: "Next"}
					, {Desc: "Previous", Class: "Spotify", Func: "Prev"}
					, {Desc: "Volume Up", Class: "Spotify", Func: "VolUp"}
					, {Desc: "Volume Down", Class: "Spotify", Func: "VolDown"}]
		
		LaunchApp := 	[ {Desc: "Task Manager", Func: "Run", Param:["Taskmgr"]}
					, {Desc: "Control Panel", Func: "Run", Param:["control"]}
					, {Desc: "Command Prompt", Func: "Run", Param:["cmd"]}
					, {Desc: "My Computer", Func: "Run", Param:["::{20d04fe0-3aea-1069-a2d8-08002b30309d}"]}
					, {Desc: "Recycle Bin", Func: "Run", Param:["::{645ff040-5081-101b-9f08-00aa002f954e}"]}
					, {Desc: "Notepad", Func: "Run", Param:["notepad"]}
					, {Desc: "Registry Editor", Func: "Run", Param:["regedt32"]}
					, {Desc: "Event Viewer", Func: "Run", Param:["eventvwr"]}
					, {Desc: "Windows Features", Func: "Run", Param:["OptionalFeatures"]}]
		
		BuiltIn := 	[ {Desc: "Run Clipboard", Class: "BuiltIn", Func: "RunClipboard"}
					, {Desc: "Upload Clipboard (Pastebin)", Func: "PastebinUpload"}
					, {Desc: "Open GUI", Class: "BuiltIn", Func: "Open"}
					, {Desc: "Open Games", Class: "BuiltIn", Func: "Open", Param: [1]}
					, {Desc: "Open Keybinds", Class: "BuiltIn", Func: "Open", Param: [2]}
					, {Desc: "Settings", Func: "Settings"}
					, {Desc: "Plugins", Func: "Plugins"}]
		
		Multimedia := 	[ {Desc: "Play/Pause", Class: "Multimedia", Func: "PlayPause"}
					, {Desc: "Next", Class: "Multimedia", Func: "Next"}
					, {Desc: "Previous", Class: "Multimedia", Func: "Prev"}
					, {Desc: "Volume Up", Class: "Multimedia", Func: "VolUp"}
					, {Desc: "Volume Down", Class: "Multimedia", Func: "VolDown"}
					, {Desc: "Volume Mute", Class: "Multimedia", Func: "VolMute"}]
		
		this.List := {}
		this.List.Spotify := Spotify
		this.List.Multimedia := Multimedia
		this.List["Built-in"] := BuiltIn
		this.List["Launch Application"] := LaunchApp
	}
	
	Add(Name, Bind) {
		this.List[Name].Push(Bind)
	}
	
	NewClass(Name, ClassName, Class) {
		Actions[ClassName] := Class
		return this.List[Name] := []
	}
}