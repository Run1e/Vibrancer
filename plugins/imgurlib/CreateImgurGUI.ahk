CreateImgurGUI() {
	Img := new ImgurGUI("Power Play - Imgur Uploader", "+Border +Resize +MinSize500x250")
	
	Img.WIDTH := WIDTH := 1117 ; Settings.Size.Width
	Img.HEIGHT := HEIGHT := 750 ; Settings.Size.Height
	Img.BUTTON_HEIGHT := BUTTON_HEIGHT := 26
	Img.BUTTON_WIDTH := BUTTON_WIDTH := WIDTH/4
	Img.BUTTON_TOTAL_HEIGHT := BUTTON_TOTAL_HEIGHT := 104
	Img.SB_HEIGHT := SB_HEIGHT := 23
	Img.ImageWidth := ImageWidth := 260
	Img.ImageHeight := ImageHeight := Round(ImageWidth*9/16)
	Img.HorizontalSeparator := HorizontalSeparator := 10
	Img.VerticalSeparator := VerticalSeparator := 8
	Img.GifPeriod := GifPeriod := 333
	
	Img.Font("s1")
	Img.ImgurLV := new Gui.ListView(Img, "-HDR +Multi +Icon AltSubmit cWhite -E0x200 -TabStop +Background353535", "empty|index", Img.ImageListViewAction.Bind(Img))
	Img.ImgurLV.ModifyCol(1, 0)
	Img.ImgurLV.ModifyCol(2, 0)
	
	Img.ImgurLV.IL := new CustomImageList(ImageWidth, ImageHeight, 0x20, 50, 5)
	Img.ImgurLV.SetImageList(Img.ImgurLV.IL.ID, true)
	Img.ImgurLV.IL.GifPeriod := GifPeriod
	
	Img.Font("s10")
	
	Img.Add("Button", "Disabled", "Start queue", Uploader.StartStop.Bind(Uploader))
	Img.Add("Button", "Disabled", "Clear queue", Uploader.ClearQueue.Bind(Uploader))
	Img.Add("Button", "Disabled", "Clear failed items", Uploader.ClearFailedQueue.Bind(Uploader))
	Img.Add("Button", "Disabled", "Settings", Func("Settings"))
	
	Img.SB := new Gui.StatusBar(Img, "0x100", "Ready")
	Img.SB.SetParts(120, 100)
	Img.SB.SetText("Ready", 1)
	Img.SB.SetText("Queue: 0", 2)
	Img.SB.SetText("Keybinds can be bound in Power Play.", 3)
	
	Img.SetIcon(Power.Call("Icon"))
	Img.Margin(0, 0)
	Img.DropFilesToggle(true)
}