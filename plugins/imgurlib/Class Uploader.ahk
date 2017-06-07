Class Uploader {
	__New() {
		this.AllowedExt := "i)(png|jpg|jpeg|gif|bmp)$"
		this.client_id := Settings.client_id ? Settings.client_id : "45a0e7fa6727f61"
		this.WorkerScript := "imgurlib\Uploader.ahk"
		
		this.Queue := new Queue
		this.QueueFail := [] ; failed items go here
		
		this.Uploaded := 0
		this.Deleted := 0
		
		this.ImgurFolder :=  "..\data\imgur\image\uploaded"
		this.DeletedFolder := "..\data\imgur\image\deleted"
		this.LocalFolder := "..\data\imgur\image\local"
		
		; launch the uploader
		this.LaunchWorker()
		
		; set as idle (ie, ready)
		this.SetStatus(0)
	}
	
	Upload(Index, File) {
		Info := {Event: "Upload", File: File, Index: Index}
		
		if !FileExist(File)
			return
		
		FileGetSize, Size, % File
		if (Size > 10480000)
			return TrayTip("Files larger than 10MB can not be uploaded to imgur.")
		
		this.AddQueue(Info)
	}
	
	Delete(Index) {
		Info := {Event: "Delete", Index: Index, DeleteHash: Images[Index].deletehash}
		if Images[Index]
			this.AddQueue(Info)
	}
	
	AddQueue(Info) {
		this.Queue.Add(Info)
		if (this.Status = 0)
			this.StartQueue()
	}
	
	; adds an item to the queue of failed items
	AddFail(Info, Error) {
		this.QueueFail.InsertAt(1, (Info, Info.Error := Error))
	}
	
	StartStop() {
		if (this.Status = 1)
			this.SetStatus(2), Img.Control(, "Button1", "Pausing.."), this.AllowPause(false)
		else if (this.Status = 0) && (this.Queue.Count())
			this.StartQueue()
	}
	
	; set to running if we're idling
	StartQueue() {
		if (this.Status = 0) {
			this.SetStatus(1)
			this.StepQueue()
		}
	}
	
	StepQueue() {
		if (this.Status = 2)
			return this.SetStatus(0), Img.Control(, "Button1", "Start queue"), this.StatusText("Paused..")
		
		if (this.Status != 1)
			return
		
		if !Info := this.Queue.Current()
			return this.FinishQueue()
		
		if (Info.Event = "Upload") {
			this.Worker.ahkPostFunction["Upload", Info.File]
			this.StatusText("Starting..")
		} else if (Info.Event = "Delete") {
			this.Worker.ahkPostFunction["Delete", Info.DeleteHash]
			this.StatusText("Deleting..")
		}
	}
	
	ClearQueue() {
		if (this.Status = 1)
			return
		this.Queue.Clear()
		this.AllowClear(false)
		this.FinishQueue()
	}
	
	ClearFailedQueue() {
		if (this.Status = 1)
			return
		this.QueueFail := []
		this.AllowClearFailed(false)
	}
	
	; response from imgur
	UploadResponse(Data) {
		try
			res := JSON.Load(Data)
		
		if res.status { ; response from imgur
			if (res.status = 200) 
				this.UploadSuccess(res)
			else ; other status code
				this.ImgurError({Event:"Upload", Index:Index}, res)
		} else
			this.UploadFailure(Data)
	}
	
	; successful upload
	UploadSuccess(res) {
		Info := this.Queue.Current()
		SplitPath, % Info.File,,, extension
		Images[Info.Index] := {link:res.data.link, deletehash:res.data.deletehash, extension:extension}
		
		if (InStr(Info.File, this.LocalFolder) = 1)
			FileMove % Info.File, % this.ImgurFolder "\" Info.Index "." extension
		else
			FileCopy % Info.File, % this.ImgurFolder "\" Info.Index "." extension
		
		this.Uploaded++
		this.Queue.OnStep(true, res)
		this.StepQueue()
	}
	
	; upload failed
	UploadFailure(Error) {
		this.AddFail(this.Queue.Current(), Error)
		Error("Failed uploading image", A_ThisFunc, Error)
		this.Queue.OnStep(false)
		this.StepQueue()
	}
	
	DeleteResponse(Data) {
		try
			res := JSON.Load(Data)
		
		if res.status { ; response from imgur
			if (res.status = 200) ; success
				this.DeleteSuccess()
			else ; other status code
				this.ImgurError({Event:"Delete", ID:ID}, res)
		} else
			this.DeleteFailure(Data)
	}
	
	DeleteSuccess() {
		Info := this.Queue.Current()
		Image := Images.Delete(Info.Index)
		
		; move the image regardless of whether saveimages is enabled or not
		if FileExist(this.ImgurFolder "\" Info.Index "." Image.extension)
			FileMove, % this.ImgurFolder "\" Info.Index "." Image.extension, % this.DeletedFolder "\" Info.Index "." Image.extension
		
		this.Deleted++
		this.Queue.OnStep(true)
		this.StepQueue() ; advance in queue and continue
	}
	
	; deletion failed
	DeleteFailure(Error) {
		this.AddFail(this.Queue.Current(), Error)
		Error("Failed deleting image", A_ThisFunc, Error)
		this.Queue.OnStep(false)
		this.StepQueue()
	}
	
	; takes an imgur error status and decides what to do
	ImgurError(Info, res) {
		status := res.status
		error := (IsObject(res.data.error)?res.data.error.message:res.data.error)
		
		Error("Imgur threw an error", A_ThisFunc, "Error: " error "`nFile: " file "`n`nRes:`n" pa(res) "`n`nHeaders:`n" pa(this.LastHeaders))
		
		if (status = "400") {
			
			if (InStr(error, "You are uploading too fast. Please wait ") = 1) { ; rate limit, fake it as status 429
				res.status := 429
				this.ImgurError(Info, res)
			} else {
				TrayTip("Imgur error!", """" error """")
				this.SetStatus(2)
			}
			
		} else if (status = 429) { ; rate limit reached or ip temporarily blocked
			
			Time := this.LastHeaders["X-Post-Rate-Limit-Reset"]
			
			if (this.LastHeaders["X-RateLimit-UserRemaining"] = 0) ; user has spent all credits
				TrayTip("Imgur error!", "You've uploaded too much.`nImgur will allow more uploads in " Round(Time/60) " minutes.")
			
			else if (this.LastHeaders["X-RateLimit-ClientRemaining"] = 0) ; client_id credits is empty, we need a new one, kinda bad tbh
				TrayTip("Imgur error!", "Client rate limits have been reached.`nEmail me at runar-borge@hotmail.com if this continues happening.")
			
			else ; last error is IP spam prevention
				TrayTip("Imgur is panicking!", "Imgur doesn't like you requesting this fast.`nImgur will allow more uploads in " Round(Time/60) " minutes.")
			
			this.SetStatus(0)
			this.StatusText("Imgur error!")
			
			if !this.RateAlertTimer {
				this.RateAlertTimer := true
				RateAlert := this.RateLimitAlert.Bind(this)
				SetTimer, % RateAlert, % "-" Time * 1000
			}
			
		} else if (status ~= "^(401|403|404)$") { ; step on 40x and 500 errors
			
			this.Queue.Advance()
			this.StepQueue()
			
		} else if (status = 500) {
			if (Info.Event = "Upload")
				this.UploadFailure(error)
			else
				this.DeleteFailure(error)
		}
	}
	
	RateLimitAlert() {
		this.AllowPause(true)
		this.RateAlertTimer := false
		TrayTip("Rate limit cleared.`nYou can now upload.")
	}
	
	HeaderInfo(header) { ; save headers to this.LastHeaders
		for index, text in StrSplit(header, "`n"), hdr := [] {
			line := StrSplit(text, ": ")
			if (InStr(line[1], "X-") = 1)
				hdr[line[1]] := line[2]
		} this.LastHeaders := hdr
	}
	
	; craft msg and clear vars/objs
	FinishQueue() {
		this.SetStatus(0)
		
		if ((this.Uploaded = 1 && !this.Deleted) || (this.Deleted = 1 && !this.Uploaded)) && (!this.QueueFail.MaxIndex()) { ; one succeeded item
			
			if (this.Uploaded) {
				Title := "Upload succeeded!"
				Msg := ((Settings.CopyOnUpload = 2) || (Settings.CopyOnUpload = 1 && !Img.IsVisible)) ? "Link copied to clipboard." : ""
			} else {
				Title := "Deletion succeeded!"
				Msg := "Image has been removed from imgur."
			}
		}
		
		else { ; several succeeded items
			Title := "Queue report:"
			
			; craft msg
			if this.Uploaded
				Msg := this.Uploaded " images uploaded.`n"
			if this.Deleted
				Msg .= this.Deleted " images deleted.`n"
			if this.QueueFail.MaxIndex()
				Msg .= this.QueueFail.MaxIndex() " items failed."
			
			Msg := trim(Msg, "`n")
		}
		
		this.Uploaded := 0
		this.Deleted := 0
		this.QueueFail := []
		
		if !Img.IsVisible
			TrayTip(Title, Msg)
		
		
		Images.Save()
		this.StatusText("Queue finished")
	}
	
	UploadUpdate(Per) {
		static Prog := false
		if (Per > 0) && !Prog {
			Prog := true
			Img.SB.SetText("", 3)
			Img.SB.SetProgress("", 3, "Show")
			this.StatusText("Uploading..")
		} else if (Per = 200) && Prog {
			Prog := false
			Img.SB.SetProgress(0, 3)
			Img.SB.SetProgress(0, 3, "Hide")
		} else
			Img.SB.SetProgress(Per, 3)
		
		if (Per > 94)
			this.StatusText("Working..")
		return
		
		test:
		return
	}
	
	SetStatus(Status) {
		this.Status := Status
		
		if (Status = 0) {
			Img.Control(, "Button1", "Start queue")
			this.AllowPause(this.Queue.Count() > 0 ? true : false)
			this.AllowClear(this.Queue.Count() > 0 ? true : false)
			this.AllowClearFailed(this.QueueFail.MaxIndex() > 0 ? false : false)
		}
		
		else if (Status = 1) {
			Img.Control(, "Button1", "Stop queue")
			this.AllowPause(this.Queue.Count() > 1 ? true : false)
			this.AllowClear(false)
			this.AllowClearFailed(false)
		}
	}
	
	AllowPause(Toggle) {
		Img.Control(Toggle ? "Enable" : "Disable", "Button1")
	}
	
	AllowClear(Toggle) {
		Img.Control(Toggle ? "Enable" : "Disable", "Button2")
	}
	
	AllowClearFailed(Toggle) {
		Img.Control(Toggle ? "Enable" : "Disable", "Button3")
	}
	
	StatusText(Text) {
		Img.SB.SetText(" " Text, 1)
	}
	
	; launch worker thread
	LaunchWorker() {
		this.Worker := AhkThread("Main := ObjShare(" ObjShare(this) ")`n" UploaderScript(),,, "..\lib\AutoHotkey.dll")
	}
	
	Free() {
		ahkthread_free(this.Worker), this.Worker := ""
	}
}