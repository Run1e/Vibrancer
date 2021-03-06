﻿DefaultSettings() {
	Defaults := 
	( LTrim Join Comments ;
	{
		StartUp: true,
		Font: "Segoe UI Light",
		Color: {Selection: 0x44C6F6, Tab: 0xFE9A2E},
		GuiState: {ActiveTab: 1, GameListPos: 1, BindListPos: 1},
		Language: "English",
		Plugins: ["Vibrancy Control"],
		VibrancyScreens: [SysGet("MonitorPrimary")],
		VibrancyDefault: 50
	}
	)
	return Defaults
}