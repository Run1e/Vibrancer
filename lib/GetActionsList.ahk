GetActionsList() {
	BuiltIn :=		{ 1: {Desc:"Run Clipboard", Func:"RunClipboard"}
					, 2: {Desc:"Upload Clipboard Text", Func:"UploadClip"}
					, 3: {Desc:"Open GUI", Func:"Open"}
					, 4: {Desc:"Open Games Tab", Func:"Open", Param:[1]}
					, 5: {Desc:"Open Imgur Tab", Func:"Open", Param:[2]}
					, 6: {Desc:"Open Keybinds Tab", Func:"Open", Param:[3]}
					, 7: {Desc:"Open Settings", Func:"Settings"}
					, 8: {Desc:"Open Plugins", Func:"Plugins"}}
	
	Imgur :=			{ 1: {Desc:"Capture/Upload Screen", Func:"Screenshot", Param:["Full"]}
					, 2: {Desc:"Capture/Upload Window", Func:"Screenshot", Param:["Window"]}
					, 3: {Desc:"Capture/Upload Selection", Func:"Screenshot", Param:["Area"]}}
	
	Multimedia :=		{ 1: {Desc:"Play/Pause", Func:"Send", Param:["{Media_Play_Pause}"]}
					, 2: {Desc:"Next", Func:"Send", Param:["{Media_Next}"]}
					, 3: {Desc:"Previous", Func:"Send", Param:["{Media_Prev}"]}
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
	
	Spotify :=		{ 1: {Desc:"Play/Pause", Func:"Spotify", Param:[0xE0000]}
					, 2: {Desc:"Next", Func:"Spotify", Param:[0xB0000]}
					, 3: {Desc:"Previous", Func:"Spotify", Param:[0xC0000]}
					, 4: {Desc:"Volume Up", Func:"SpotifyItem", Param:["Playback", "Volume Up"]}
					, 5: {Desc:"Volume Down", Func:"SpotifyItem", Param:["Playback", "Volume Down"]}}
	
	LaunchApplication :={ 1: {Desc:"Task Manager", Func:"Run", Param:["Taskmgr"]}
					, 2: {Desc:"Control Panel", Func:"Run", Param:["control"]}
					, 3: {Desc:"Command Prompt", Func:"Run", Param:["cmd"]}
					, 4: {Desc:"My Computer", Func:"Run", Param:["::{20d04fe0-3aea-1069-a2d8-08002b30309d}"]}
					, 5: {Desc:"Recycle Bin", Func:"Run", Param:["::{645ff040-5081-101b-9f08-00aa002f954e}"]}
					, 6: {Desc:"Notepad", Func:"Run", Param:["notepad"]}
					, 7: {Desc:"Registry Editor", Func:"Run", Param:["regedt32"]}
					, 8: {Desc:"Event Viewer", Func:"Run", Param:["eventvwr"]}
					, 9: {Desc:"Windows Features", Func:"Run", Param:["OptionalFeatures"]}}
	
	return {"Built-in": BuiltIn, "Imgur": Imgur, "Multimedia": Multimedia, "Mouse Function": MouseFunction, "Spotify": Spotify, "Launch Application": LaunchApplication}
}