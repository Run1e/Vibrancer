DefaultKeybinds() {
	return 	{ "^Delete": 	Binds.List.Spotify.1
			, "^End": 	Binds.List.Spotify.3
			, "^PgDn": 	Binds.List.Spotify.2
			, "!C": 		Binds.List["Built-in"].1
			, "+^1":		{Class: "ImgurUploader", Desc: "Imgur: Open GUI", Func: "Open"}
			, "+^2":		{Class: "ImgurUploader", Desc: "Imgur: Capture Monitor", Func: "Screen"}
			, "+^3":		{Class: "ImgurUploader", Desc: "Imgur: Capture Window", Func: "Window"}
			, "+^4":		{Class: "ImgurUploader", Desc: "Imgur: Capture Area", Func: "Area"}}
}