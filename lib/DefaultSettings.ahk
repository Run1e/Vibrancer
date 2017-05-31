DefaultSettings() {
	return 	{ StartUp: true
			, Font: "Segoe UI Light"
			, Color: {Selection: 0x44C6F6, Tab: 0xFE9A2E, Dark: 0x353535} ; FE9A2E
			, GuiState: {ActiveTab: 1, GameListPos: 1, BindListPos: 1, ExpandState: 0}
			, Imgur: {CloseOnOpen: true, CloseOnCopy: true, ListViewMax: 100, CopySeparator: " ", UseGifv: true, client_id: ""}
			, Plugins: {}
			, VibrancyScreens: [SysGet("MonitorPrimary")]
			, VibrancyDefault: 50}
}