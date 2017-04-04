DefaultSettings() {
	return 	{ StartUp: true
			, Font: "Segoe UI Light"
			, Color: {Selection: "44C6F6", Tab: "FE9A2E", Dark: "353535"} ; FE9A2E
			, GuiState: {ActiveTab: 1, GameListPos: 1, BindListPos: 1}
			, Imgur: {CloseOnOpen: true, CloseOnCopy: true, ListViewMax:100, UseGifv:true, GifPeriod:800}
			, VibrancyScreen: SysGet("MonitorPrimary") - 1 ; proper arrays apparently start at 0. who would've known.
			, VibrancyDefault: 50}
}