﻿InitNvAPI() {
	if (Code := NvAPI.init := NvAPI.ClassInit()) { ; NvAPI initialization failed, no nvidia card is installed
		if !Settings.NvAPI_InitFail {
			Error := (Code = 2 ? "NvAPI initialization failed!" : "No NVIDIA graphics card found!")
			Debug.Log(Exception("NvAPI init failed, NvAPI features disabled.", -1, Error))
			a := Func("TrayTip").Bind(Error, "Some features have been disabled.")
			SetTimer, % a, -4000
		} Settings.NvAPI_InitFail := Code
	}
	else if Settings.NvAPI_InitFail {
		Settings.Remove("NvAPI_InitFail")
		a := Func("TrayTip").Bind("NVIDIA graphics card found!", "Disabled features have been enabled.")
		SetTimer, % a, -4000
	}
}