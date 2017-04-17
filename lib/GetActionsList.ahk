GetActionsList() {
	BuiltIn :=		{ 1: {Desc:"Run Clipboard", Func:"RunClipboard"}
					, 2: {Desc:"Upload Clipboard Text", Func:"UploadClip"}
					, 3: {Desc:"Open GUI", Func:"Open"}
					, 4: {Desc:"Open Games Tab", Func:"Open", Param:[1]}
					, 5: {Desc:"Open Imgur Tab", Func:"Open", Param:[2]}
					, 6: {Desc:"Open Keybinds Tab", Func:"Open", Param:[3]}
					, 7: {Desc:"Open Settings", Func:"Settings"}}
	
	Imgur :=			{ 1: {Desc:"Capture Screen", Func:"Screenshot", Param:["Full"]}
					, 2: {Desc:"Capture Window", Func:"Screenshot", Param:["Window"]}
					, 3: {Desc:"Capture Rectangle", Func:"Screenshot", Param:["Area"]}}
	
	Multimedia :=		{ 1: {Desc:"Play/Pause", Func:"Send", Param:["{Media_Play_Pause}"]}
					, 2: {Desc:"Next Song", Func:"Send", Param:["{Media_Next}"]}
					, 3: {Desc:"Previous Song", Func:"Send", Param:["{Media_Prev}"]}
					, 4: {Desc:"Volume Up", Func:"Send", Param:["{Volume_Up}"]}
					, 5: {Desc:"Volume Down", Func:"Send", Param:["{Volume_Down}"]}
					, 6: {Desc:"Volume Mute", Func:"Send", Param:["{Volume_Mute}"]}}
	
	MouseFunction := 	{ 1: {Desc:"Left Click", Func:"Send", Param:["{LButton}"]}
					, 2: {Desc:"Right Click", Func:"Send", Param:["{RButton}"]}
					, 3: {Desc:"Double Click", Func:"Send", Param:["{LButton}{LButton}"]}
					, 4: {Desc:"Mouse Button 4", Func:"Send", Param:["{XButton1}"]}
					, 5: {Desc:"Mouse Button 5", Func:"Send", Param:["{XButton2}"]}
					, 6: {Desc:"Scroll Click", Func:"Send", Param:["{MButton}"]}
					, 7: {Desc:"Scroll Up", Func:"Send", Param:["{WheelUp}"]}
					, 8: {Desc:"Scroll Down", Func:"Send", Param:["{WheelDown}"]}
					, 9: {Desc:"Scroll Left", Func:"Send", Param:["{WheelLeft}"]}
					, 10:{Desc:"Scroll Right", Func:"Send", Param:["{WheelRight}"]}}
	
	LaunchApplication :={ 1: {Desc:"Launch Task Manager", Func:"Run", Param:["Taskmgr"]}
					, 2: {Desc:"Launch Control Panel", Func:"Run", Param:["control"]}
					, 3: {Desc:"Launch Command Prompt", Func:"Run", Param:["cmd"]}
					, 4: {Desc:"Launch My Computer", Func:"Run", Param:["::{20d04fe0-3aea-1069-a2d8-08002b30309d}"]}
					, 5: {Desc:"Launch Recycle Bin", Func:"Run", Param:["::{645ff040-5081-101b-9f08-00aa002f954e}"]}
					, 6: {Desc:"Launch Notepad", Func:"Run", Param:["notepad"]}
					, 7: {Desc:"Launch Registry Editor", Func:"Run", Param:["regedt32"]}
					, 8: {Desc:"Launch Event Viewer", Func:"Run", Param:["eventvwr"]}
					, 9: {Desc:"Launch Windows Features", Func:"Run", Param:["OptionalFeatures"]}}
	
	return {"Built-in": BuiltIn, "Imgur": Imgur, "Multimedia": Multimedia, "Mouse Function": MouseFunction, "Launch Application": LaunchApplication}
}