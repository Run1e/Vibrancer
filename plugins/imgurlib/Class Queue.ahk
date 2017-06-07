Class Queue {
	__New() {
		this.Queue := []
		return this
	}
	
	OnStep(Success := true, res := "") {
		Info := this.Advance()
		if (Info.Event = "Upload") {
			; remove gray image
			if Success {
				if Settings.CopyOnUpload
					if !(Settings.CopyOnUpload = 1 && Img.IsVisible)
						Clipboard(res.data.link . ((SubStr(res.data.link, -2) = "gif") && Settings.UseGifv ? "v" : ""))
				
				Img.AddImage(Info.Index)
			} else {
				; replace with error image
			}
		} else if (Info.Event = "Delete") {
			if Success {
				Loop % Img.ImgurLV.GetCount()
					if (Img.ImgurLV.GetText(A_Index, 2) = Info.Index)
						Img.ImgurLV.Delete(A_Index)
				Images.Delete(Info.Index)
				Img.FixOrder()
			} else {
				; do nuttin
			}
		}
	}
	
	Count() {
		return this.Queue.MaxIndex()
	}
	
	Add(Info) {
		this.Queue.Push(Info)
		this.CheckAllowPause()
		this.TextCount()
		if (Info.Event = "Upload") {
			; add greyed out with arrow
		}
	}
	
	Advance() {
		return this.Queue.RemoveAt(1), this.CheckAllowPause(), this.TextCount()
	}
	
	Current() {
		return this.Queue.1
	}
	
	TextCount() {
		Img.SB.SetText("Queue: " (this.Count() ? this.Count() : 0), 2)
	}
	
	CheckAllowPause() {
		Uploader.AllowPause(((this.Count() > 1) && (Uploader.Status = 1)) ? true : false)
	}
	
	Clear() {
		this.Queue := []
		this.TextCount()
	}
}