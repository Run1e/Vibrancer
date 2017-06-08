Class ImgurGUI extends Gui {
	static AnimatedImages := {}
	static AnimatedPositions := {}
	static AnimatedEnabled := false
	
	Open() {
		this.Show("w" this.WIDTH " h" this.HEIGHT)
		new Hotkey("Delete", this.Delete.Bind(this), this.ahkid)
		this.Animate(true)
	}
	
	Close() {
		this.Hide()
		this.ImgurLV.Modify(0, "-Select")
		this.ImgurLV.Modify(1, "Vis")
		this.Animate(false)
		Settings.Size.Width := this.WIDTH
		Settings.Size.Height := this.HEIGHT
	}
	
	Escape() {
		this.Close()
	}
	
	DropFiles(FileArray, Poop*) {
		for Index, File in FileArray
			if (File ~= Uploader.AllowedExt)
				Uploader.Upload(A_Now "_" A_MSec, File)
	}
	
	
	Size(Event, w, h) {
		this.Control("Move", this.ImgurLV.hwnd, "x0 y0 w" w " h" h - this.SB_HEIGHT - this.BUTTON_HEIGHT)
		this.Control("MoveDraw", "Button1", "x0 y" h - this.SB_HEIGHT - this.BUTTON_HEIGHT " w" w/4 " h" this.BUTTON_HEIGHT)
		this.Control("MoveDraw", "Button2", "x" w/4 " y" h - this.SB_HEIGHT - this.BUTTON_HEIGHT " w" w/4 " h" this.BUTTON_HEIGHT)
		this.Control("MoveDraw", "Button3", "x" w/4*2 " y" h - this.SB_HEIGHT - this.BUTTON_HEIGHT " w" w/4 " h" this.BUTTON_HEIGHT)
		this.Control("MoveDraw", "Button4", "x" w/4*3 " y" h - this.SB_HEIGHT - this.BUTTON_HEIGHT " w" w/4 " h" this.BUTTON_HEIGHT)
		this.SB.SetProgress("", 3, "Hide")
		this.SB.SetParts(120, 100, w - 220)
		this.WIDTH := w, this.HEIGHT := h
		this.FixOrder()
	}
	
	LoadImages() {
		this.ImgurLV.Redraw(false)
		for Index in Images.Data()
			this.AddImage(Index, false)
		this.FixOrder()
		this.ImgurLV.Redraw(true)
	}
	
	AddImage(Index, FixOrder := true, Bitmap := false) {
		static Spaced
		
		File := Uploader.ImgurFolder "\" Index "." Images[Index].extension
		
		if (Images[Index].extension = "gif") {
			IconList := this.ImgurLV.IL.AddGif(File)
			this.AnimatedImages[Index] := IconList
			this.AnimatedPositions[Index] := 1
			Icon := IconList.1
		} else {
			if !Icon := this.ImgurLV.IL.AddImage(File)
				return
		}
		
		this.ImgurLV.Insert(1, "Icon" . Icon,, Index)
		
		if !Spaced
			LV_EX_SetIconSpacing(this.ImgurLV.hwnd, this.ImageWidth + this.HorizontalSeparator, this.ImageHeight + this.VerticalSeparator), Spaced := true
		
		if FixOrder
			this.FixOrder()
	}
	
	; when inserting to the first item position in a listview in icon mode, it doesn't add the item to the correct location (the first index).
	; so to fix, we change it to report view and back. and poof. magic.
	FixOrder() {
		this.Control("+Report", this.ImgurLV.hwnd)
		this.Control("+Icon", this.ImgurLV.hwnd)
		this.ImgurLV.Modify(1, "Vis")
	}
	
	Delete() {
		Selected := this.GetSelected()
		
		if !Selected.MaxIndex()
			return
		
		MsgBox, 52, Image deletion, % Selected.MaxIndex() " image" (Selected.MaxIndex()>1?"s":"") " selected.`nProceed with deletion?"
		ifMsgBox no
		return
		
		for Index, ImageIndex in Selected
			Uploader.Delete(ImageIndex)
	}
	
	CopyLinks() {
		for Index, ImageIndex in Selected := this.GetSelected() {
			link := Images[ImageIndex].link
			if (SubStr(link, -2) = "gif") && Settings.UseGifv
				link .= "v"
			links .= link . (StrLen(Settings.CopySeparator) ? Settings.CopySeparator : " ")
		}
		
		if !StrLen(links)
			return
		
		Clipboard(rtrim(links, " "))
		TrayTip("Link" ((Size := ArraySize(Selected))>1?"s":"") " copied!", (Size>1?Size " links were copied to your clipboard.":clipboard))
		
		if Settings.CloseOnCopy && StrLen(links)
			this.Close()
	}
	
	ImageListViewAction(Control, GuiEvent, EventInfo) {
		if (GuiEvent = "DoubleClick")
			this.CopyLinks()
	}
	
	GetSelected() {
		Indexes := []
		while (i:=this.ImgurLV.GetNext(i)) {
			Index := this.ImgurLV.GetText(i, 2)
			Indexes[A_Index] := Index
		} return Indexes
	}
	
	Animate(Toggle) {
		if Toggle && !this.AnimatedEnabled {
			SetTimer, AnimateTick, % this.GifPeriod
			this.AnimatedEnabled := true
		} else if this.AnimatedEnabled {
			SetTimer, AnimateTick, Off
			this.AnimatedEnabled := false
		} return
		
		AnimateTick:
		Img.AnimateTick()
		return
	}
	
	AnimateTick() {
		; find the next image to show for each animated image
		for Index, Pos in this.AnimatedPositions {
			if this.AnimatedImages[Index].HasKey(Pos+1)
				this.AnimatedPositions[Index] := Pos+1
			else
				this.AnimatedPositions[Index] := 1
		} 
		
		; change to the next image for each gif
		Loop {
			text := this.ImgurLV.GetText(A_Index, 2)
			if this.AnimatedPositions.HasKey(text)
				this.ImgurLV.Modify(A_Index, "Icon" . this.AnimatedImages[text][this.AnimatedPositions[text]]) 
		} until !StrLen(text)
	}
}