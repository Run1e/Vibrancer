Class Uploader {
	__New() {
		this.AllowedExt := "i)(png|jpg|jpeg|gif|bmp)$"
		this.client_id := IsFunc("client_id")?Func("client_id").Call():""
		this.WorkerScript := A_WorkingDir "\PowerPlayUploader." (A_IsCompiled?"exe":"ahk")
		
		this.Queue := [] ; contains items waiting to be ran
		this.QueueSucceed := []
		this.QueueFail := [] ; failed items go here
		
		this.ImgurFolder :=  "images\imgur"
		this.DeletedFolder := "images\deleted"
		this.LocalFolder := "images\local"
		
		; setup com object
		ObjRegisterActive(this, "{9cd4083e-4f48-42e9-9b89-f1fc463b43b8}")
		
		; launch the uploader
		this.LaunchWorker()
		
		; set as idle (ie, ready)
		this.SetStatus(0)
	}
	
	Upload(File) {
		p("UPLOAD: " file)
		Info := {Event: "Upload", ID: File}
		if FileExist(File)
			this.AddQueue(Info)
	}
	
	Delete(Index) {
		p("DELETE: " index)
		Info := {Event: "Delete", ID: Index, DeleteHash: Images[Index].deletehash}
		if Images[Index]
			this.AddQueue(Info)
	}
	
	; adds an item to the queue
	; also starts the queue if it's idling
	AddQueue(Info) {
		p("adding to queue: " Info.ID)
		this.Queue.Push(Info)
		
		; start queue if we're idling
		if (this.Status = 0)
			this.StartQueue()
		
		if (this.Status = 1)
			this.GuiAllowPause((this.Queue.MaxIndex() > 1))
		
		this.GuiUpdate()
	}
	
	AddSucceed(Info) {
		this.QueueSucceed.InsertAt(1, Info)
	}
	
	; adds an item to the queue of failed items
	AddFail(Info, Error) {
		this.QueueFail.InsertAt(1, {Error: Error, Event: Info.Event, ID: Info.ID})
	}
	
	StartStop() {
		if (this.Status = 1) {
			Uploader.StopQueue()
			Big.Control("Disable", Big.PauseButtonHWND)
			Big.SetText(Big.PauseButtonHWND, "Pausing..")
		} else if (this.Status = 0) && (this.Queue.MaxIndex())
			this.StartQueue()
	}
	
	; set to running if we're idling
	StartQueue() {
		if (this.Status = 0) {
			p("starting queue")
			this.SetStatus(1)
			this.GuiCheckButtons()
			this.GuiUpdate()
			this.StepQueue()
		}
	}
	
	; set to pause if we're running
	StopQueue() {
		if (this.Status = 1) {
			p("stopping queue")
			this.SetStatus(2)
		}
	}
	
	StepQueue() {
		p("stepping queue")
		
		; stop if we said to stop, or if the queue is empty
		if (this.Status = 2)
			this.SetStatus(0), this.GuiSetStatus("Paused..")
		
		if !this.CheckAlive()
			return
		
		this.GuiCheckButtons()
		this.GuiUpdate()
		
		if (this.Status != 1)
			return
		
		if  !this.Queue.MaxIndex()
			return this.FinishQueue()
		
		this.GuiAllowPause((this.Queue.MaxIndex() > 1))
		
		; get the next queue item
		Info := this.Queue.1
		
		this.GuiSetStatus(Info.Event="Upload"?"Starting..":"Deleting..")
		
		; pass them to the worker
		if (Info.Event = "Upload") {
			this.Worker.Upload(Info.ID)
			p("Uploading " Info.ID)
		}
		
		else if (Info.Event = "Delete") {
			this.Worker.Delete(Info.ID, Info.DeleteHash)
			p("Deleting " Info.ID " (" Info.DeleteHash ")")
		}
	}
	
	AdvanceQueue() {
		this.Queue.RemoveAt(1)
	}
	
	ClearQueue() {
		if (this.Status = 1)
			return
		
		this.Queue := []
		this.GuiUpdate()
		this.FinishQueue()
		this.GuiCheckButtons()
	}
	
	ClearFailedQueue() {
		if (this.Status = 1)
			return
		
		this.QueueFail := []
		this.GuiUpdate()
		this.GuiCheckButtons()
	}
	
	; response from imgur
	UploadResponse(ID, Data) {
		try
			res := JSON.Load(Data)
		
		if res.status { ; response from imgur
			if (res.status = 200) 
				this.UploadSuccess(ID, res)
			else ; other status code
				this.ImgurError({Event:"Upload", ID:ID}, res)
		} else
			this.UploadFailure(ID, Data, true)
	}
	
	; successful upload
	UploadSuccess(ID, res) {
		
		Index := A_Now "_" A_MSec
		SplitPath, ID,,, extension
		
		Images[Index] := {link:res.data.link, deletehash:res.data.deletehash, id:res.data.id, extension:extension}
		
		if (InStr(ID, this.LocalFolder) = 1)
			FileMove % ID, % this.ImgurFolder "\" res.data.id "." extension
		else
			FileCopy % ID, % this.ImgurFolder "\" res.data.id "." extension
		
		; add to the queuesucceed queue
		this.AddSucceed({Event:"Upload", Index: Index, ID: ID}) ; ID is filename
		
		Clipboard(res.data.link . ((SubStr(res.data.link, -2) = "gif")&&Settings.Imgur.UseGifv?"v":""))
		
		this.GuiAddImage(Index)
		
		p("Uploaded successfully")
		
		this.AdvanceQueue()
		this.StepQueue() ; advance in queue and continue
	}
	
	; upload failed
	UploadFailure(ID, Error) {
		this.AdvanceQueue()
		this.AddFail({Event:"Upload", ID:ID}, Error)
		p("Upload failed")
		Error("Failed uploading image", A_ThisFunc, Error)
	}
	
	DeleteResponse(ID, Data) {
		try
			res := JSON.Load(Data)
		
		if res.status { ; response from imgur
			if (res.status = 200) ; success
				this.DeleteSuccess(ID, res)
			else ; other status code
				this.ImgurError({Event:"Delete", ID:ID}, res)
		} else
			this.DeleteFailure(ID, Data, true)
	}
	
	DeleteSuccess(ID) {
		
		Image := Images.Delete(ID)
		
		; move the image regardless of whether saveimages is enabled or not
		if FileExist(this.ImgurFolder "\" Image.id "." Image.extension)
			FileMove, % this.ImgurFolder "\" Image.id "." Image.extension, % this.DeletedFolder "\" Image.id "." Image.extension
		
		p("del " id)
		this.GuiRemoveImage(ID)
		this.AddSucceed({Event: "Delete", ID: ID}) ; ID is index
		p("Deleted successfully")
		
		this.AdvanceQueue()
		this.StepQueue() ; advance in queue and continue
	}
	
	; deletion failed
	DeleteFailure(ID, Error, UploadError := true) {
		
		this.Queue.RemoveAt(1)
		
		this.AddFail({Event:"Delete", ID: ID}, UploadError?"Failed connecting to imgur":Error)
		p("Deletion failed")
		
		if !UploadError
			Error("Failed deleting image", A_ThisFunc, Error)
		else
			this.ImgurError(Error)
		
		this.StepQueue()
	}
	
	; takes an imgur error status and decides what to do
	ImgurError(Info, res) {
		
		status := res.status
		error := (IsObject(res.data.error)?res.data.error.message:res.data.error)
		
		p("IMGUR ERROR " status " " error)
		
		Error("Imgur threw an error", A_ThisFunc, "Error: " error "`nFile: " file "`n`nRes:`n" pa(res) "`n`nHeaders:`n" pa(this.LastHeaders))
		
		if (status = "400") {
			
			if (InStr(error, "You are uploading too fast. Please wait ") = 1) { ; rate limit, fake it as status 429
				res.status := 429
				this.ImgurError(Info, res)
			} else {
				this.AdvanceQueue()
				this.StepQueue()
			}
			
		} else if (status = 429) { ; rate limit reached or ip temporarily blocked
			
			Time := this.LastHeaders["X-Post-Rate-Limit-Reset"]
			
			this.ResetTime := A_Now
			this.ResetTime += Time, Seconds
			
			if (this.LastHeaders["X-RateLimit-UserRemaining"] = 0) ; user has spent all credits
				this.GuiNotify("Imgur error!", "You've uploaded too much.`nImgur will allow more uploads in " Round(Time/60) " minutes.")
			
			else if (this.LastHeaders["X-RateLimit-ClientRemaining"] = 0) ; client_id credits is empty, we need a new one, kinda bad tbh
				this.GuiNotify("Imgur error!", "Client rate limits have been reached.`nEmail me at runar-borge@hotmail.com if this continues happening.")
			
			else ; last error is IP spam prevention
				this.GuiNotify("Imgur is panicking!", "Imgur doesn't like you uploading this fast.`nImgur will allow more uploads in " Round(Time/60) " minutes.")
			
			this.SetStatus(0)
			this.GuiSetStatus("Imgur rate limit reached.")
			this.GuiUpdate()
			this.GuiCheckButtons()
			
			if !this.RateAlertTimer {
				this.RateAlertTimer := true
				RateAlert := this.RateLimitAlert.Bind(this)
				SetTimer, % RateAlert, % "-" Time * 1000
			}
			
		} else if (status ~= "^(401|403|404)$") { ; step on 40x and 500 errors
			
			this.AdvanceQueue()
			this.StepQueue()
			
		} else if (status = 500) {
			
			if (Info.Event = "Upload")
				this.UploadFailure(Info.ID, error)
			else
				this.DeleteFailure(Info.ID, error)
			
			this.AdvanceQueue()
			this.StepQueue()
			
		}
	}
	
	RateLimitAlert() {
		this.RateAlertTimer := false
		TrayTip("Rate limit removed", "Ready to upload!")
		this.GuiSetStatus("Ready to upload!")
	}
	
	HeaderInfo(header) { ; save headers to this.LastHeaders
		for index, text in StrSplit(header, "`n"), hdr := [] {
			line := StrSplit(text, ": ")
			if (InStr(line[1], "X-") = 1)
				hdr[line[1]] := line[2]
		} this.LastHeaders := hdr
	}
	
	; run when queue is paused/finished
	FinishQueue() {
		
		p("finish queue")
		
		this.SetStatus(0)
		
		if (this.QueueSucceed.MaxIndex() = 1) && (!this.QueueFail.MaxIndex()) { ; one succeeded item
			Title := AppName " " AppVersionString
			
			if (this.QueueSucceed.1.Event = "Upload")
				Msg := "Upload succeeded!" . RunClipboardKeybindText()
			else
				Msg := "Deletion succeeded!"
		}
		
		else if (this.QueueSucceed.MaxIndex() > 1) { ; several succeeded items
			Title := "Queue report:"
			
			; get upload count
			for Index, Info in this.QueueSucceed {
				if (Info.Event = "Upload")
					Upload++
				else
					Delete++
			}
			
			; craft msg
			if Upload
				Msg := Upload " images uploaded.`n"
			if Delete
				Msg .= Delete " images deleted.`n"
			if this.QueueFail.MaxIndex()
				Msg .= this.QueueFail.MaxIndex() " items failed."
			
			Msg := trim(Msg, "`n")
		}
		
		this.GuiNotify(Title, Msg)
		
		; save images file
		JSONSave("Images", Images)
		
		; reset infos
		this.QueueSucceed := []
		
		this.GuiCheckButtons()
		this.GuiSetStatus("Queue finished!")
		this.GuiUpdate()
	}
	
	/*
		0 = idle
		1 = running
		2 = stop after next item
		3 = restarting launcher, then restart queue
	*/
	SetStatus(Status) {
		this.Status := Status
		p("status: " status)
	}
	
	LaunchWorker() {
		Run % this.WorkerScript,, UseErrorLevel
		if (ErrorLevel = "ERROR")
			Error("Failed to run Uploader Helper", A_ThisFunc, this.WorkerScript " failed to run, please e-mail me at runar-borge@hotmail.com if this issue persists.",, true)
	}
	
	CheckAlive() {
		try
			this.Worker.ArbitraryMethodNameToLureOutAnError()
		catch e {
			this.SetStatus(3)
			this.LaunchWorker()
			return false
		} return true
	}
	
	Handshake(Worker) {
		this.Worker := Worker
		
		; start queue if the queue is waiting
		if (this.Status = 3) {
			this.SetStatus(1)
			this.StepQueue(false)
		}
	}
	
	Free() {
		try ; attempt to close worker
			this.Worker.Exit()
		sleep 50
	}
	
	/*
		=== GUI CONTROL METHODS ===
	*/
	
	GuiAddImage(Index) {
		Big.ImgurListAdd(Index)
	}
	
	GuiRemoveImage(Index) {
		Big.ImgurListRemove(Index)
	}
	
	/*
		when to allow pause:
		when status = 0 and there's queue items in the list
		when status = 1 and there's more than one item in the list
		
		when to allow clear:
		when status = 0 and there's items in the list
		
		when to allow failed clear
		when status = 1 and there's items in the list
	*/
	
	GuiCheckButtons() {
		this.GuiAllowPause(!!((this.Status = 0 && this.Queue.MaxIndex())||(this.Status = 1 && (this.Queue.MaxIndex() > 1))))
		this.GuiAllowClear(!!(this.Queue.MaxIndex() && this.Status = 0))
		this.GuiAllowClearFailed(!!(this.QueueFail.MaxIndex() && this.Status = 0))
	}
	
	UploadUpdate(per) {
		this.GuiSetStatus(Per > 99 ? "Working.." : "Progress: " (Per) "%")
		if Settings.ToolMsg && !Big.IsVisible
			MouseTip.Create(Per > 99 ? "Working.." : Per "%")
	}
	
	GuiUpdate() {
		Big.QueueLV.Delete()
		
		for Index, Arr in [this.Queue, this.QueueFail] {
			Color := [Settings.Color.Selection, "FF2525", "25AA25"][Index]
			for Index2, Info in Arr {
				SplitPath, % Info.ID, FileName
				Pos := Big.QueueLV.Add(, Info.Event, (Info.Error?Info.Error:(FileName?FileName:Info.ID)), Info.ID)
				FileName:=""
				Big.QueueLV.CLV.Row(Pos, "0x" (Index=1?(this.Status = 1 && Index2 = 1?Color:"505050"):Color[2]), 0xFFFFFF)
			}
		}
		
		Big.QueueLV.ModifyCol(1, 100)
		Big.QueueLV.ModifyCol(2, (Big.HALF_WIDTH*2) - 100 - (Big.QueueLV.GetCount() > 6 ? VERT_SCROLL : 0))
		Big.QueueLV.ModifyCol(3, 0)
		
		this.GuiAllowFailedClear(!!this.QueueFail.MaxIndex())
	}
	
	GuiNotify(Title, Msg) {
		if !Big.IsVisible
			TrayTip(Title, Msg)
	}
	
	GuiSetStatus(Status) {
		Big.SetText(Big.QueueTextHWND, " " Status)
	}
	
	GuiAllowPause(Allow) {
		Big.Control(Allow?"Enable":"Disable", Big.PauseButtonHWND)
		Big.SetText(Big.PauseButtonHWND, (this.Status = 1?"Pause":"Start"))
	}
	
	GuiAllowClear(Allow) {
		Big.Control(Allow?"Enable":"Disable", Big.ClearButtonHWND)
	}
	
	GuiAllowClearFailed(Allow) {
		Big.Control(Allow?"Enable":"Disable", Big.ClearFailedButtonHWND)
	}
}