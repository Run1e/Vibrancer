DefaultKeybinds() {
	return 	{ "^Delete": 	Binds.List.Spotify.1
			, "^End": 	Binds.List.Spotify.3
			, "^PgDn": 	Binds.List.Spotify.2
			, "!C": 		Binds.List["Built-in"].1
			, "^Up":		{Class: "VibrancyControl", Desc: "Vibrancy Control: Increase Vibrancy", Func: "VibChange", Param: [2]}
			, "^Down":	{Class: "VibrancyControl", Desc: "Vibrancy Control: Decrease Vibrancy", Func: "VibChange", Param: [-2]}}
}