InitNvAPI() {
	try {
		NV := new NvAPI
		if Settings.NvAPI_InitFail
			Settings.Remove("NvAPI_InitFail")
	} catch e {
		Debug.Log(e, true)
		Settings.NvAPI_InitFail := true
		Msg := Func("TrayTip").Bind(e.Message)
		SetTimer, % Msg, -4000
	}
}