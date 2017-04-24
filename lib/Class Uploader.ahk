Class Uploader {
	__New() {
		this.AllowedExt := "i)(png|jpg|jpeg|gif|bmp)$"
		this.client_id := IsFunc("client_id")?Func("client_id").Call():""
		this.WorkerScript := A_WorkingDir "\PowerPlayUploader." (A_IsCompiled?"exe":"ahk")
		
		this.Queue := [] ; contains items waiting to be ran
		this.QueueSucceed := []
		this.QueueFail := [] ; failed items go here
		
		this.UpdateGUI := true
		
		this.Folder := A_WorkingDir "\images"
		this.ImgurFolder := this.Folder "\imgur"
		this.DeletedFolder := this.Folder "\deleted"
		this.LocalFolder := this.Folder "\local"
		
		for Index, Folder in [this.Folder, this.DeletedFolder, this.LocalFolder, this.ImgurFolder]
			if !FileExist(Folder)
				FileCreateDir % Folder
		
		; setup com object
		ObjRegisterActive(this, "{9cd4083e-4f48-42e9-9b89-f1fc463b43b8}")
		
		; launch the uploader
		this.LaunchWorker()
		
		; set as idle (ie, ready)
		this.SetStatus(0)
	}
	
	Upload(File) {
		Info := {Event: "Upload", ID: File}
		if !FileExist(File)
			this.AddFail((Info, Info.Error := "File doesn't exist"))
		else if !(File ~= this.AllowedExt)
			this.AddFail((Info, Info.Error := "Disallowed extension: " Ext))
		else
			this.AddQueue(Info)
	}
	
	Delete(Index) {
		Info := {Event: "Delete", ID: Index, DeleteHash: Images[Index].deletehash}
		if !Images[Index]
			this.AddFail((Info, Info.Error := "Image index not found in database"))
		else
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
		FormatTime, Date,, H:m d/M/yyyy
		this.QueueFail.InsertAt(1, {Error: Error, Date: Date, Event: Info.Event, ID: Info.ID})
		this.GuiUpdate()
	}
	
	; set to running if we're idling
	StartQueue() {
		if (this.Status = 0) {
			this.SetStatus(1)
			this.GuiAllowClear(false)
			this.GuiUpdate()
			this.StepQueue()
		}
	}
	
	; set to pause if we're running
	StopQueue() {
		if (this.Status = 1)
			this.SetStatus(2)
	}
	
	StepQueue() {
		p("stepping queue")
		
		; stop if we said to stop, or if the queue is empty
		if (this.Status = 2) || !this.Queue.MaxIndex()
			return this.FinishQueue()
		
		if !this.CheckAlive()
			return
		
		this.GuiAllowPause((this.Queue.MaxIndex() > 1))
		this.GuiSetStaus("Starting..")
		
		; get the next queue item
		Info := this.Queue.1
		
		; pass them to the worker
		if (Info.Event = "Upload")
			this.Worker.Upload(Info.ID), p("Uploading " Info.ID)
		else if (Info.Event = "Delete")
			this.Worker.Delete(Info.ID, Info.DeleteHash), p("Deleting " Info.ID " (" Info.DeleteHash ")")
	}
	
	; response from imgur
	UploadResponse(ID, Data) {
		res := JSON.Load(Data)
		
		if (res.status = 200)
			this.UploadSuccess(ID, res)
		else {
			this.UploadFailure(ID, res.data.error, false)
			Error("Imgur threw an error on upload", A_ThisFunc, pa(res))
		}
		
		this.GuiUpdate()
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
		
		; remove the item from the queue
		this.Queue.RemoveAt(1)
		
		; add to the queuesucceed queue
		this.AddSucceed({Event:"Upload", Index: Index, ID: ID}) ; ID is filename
		
		Clipboard(res.data.link)
		
		this.GuiAddImage(Index)
		
		p("Uploaded successfully")
		this.StepQueue() ; advance in queue and continue
	}
	
	; upload failed
	UploadFailure(ID, Error, UploadError := true) {
		this.Queue.RemoveAt(1)
		
		this.AddFail({Event:"Upload", ID:ID}, UploadError?"Failed connecting to imgur":Error)
		p("Upload failed")
		
		if UploadError
			Error("Failed uploading image", A_ThisFunc, Error)
		
		this.StepQueue()
	}
	
	DeleteResponse(ID, Data) {
		res := JSON.Load(Data)
		
		if (res.status = 200)
			this.DeleteSuccess(ID)
		else {
			this.DeleteFailure(ID, res.data.error, false)
			Error("Imgur threw an error on deleting", A_ThisFunc, pa(res))
		}
		
		this.GuiUpdate()
	}
	
	DeleteSuccess(ID) {
		
		Image := Images.Delete(ID)
		
		; move the image regardless of whether saveimages is enabled or not
		if FileExist(this.ImgurFolder "\" Image.id "." Image.extension)
			FileMove, % this.ImgurFolder "\" Image.id "." Image.extension, % this.DeletedFolder "\" Image.id "." Image.extension
		
		this.GuiRemoveImage(ID)
		this.Queue.RemoveAt(1)
		this.AddSucceed({Event: "Delete", ID: ID}) ; ID is index
		p("Deleted successfully")
		this.StepQueue() ; advance in queue and continue
	}
	
	; deletion failed
	DeleteFailure(ID, Error, UploadError := true) {
		
		this.Queue.RemoveAt(1)
		
		this.AddFail({Event:"Delete", ID: ID}, UploadError?"Failed connecting to imgur":Error)
		p("Deletion failed")
		
		if !UploadError
			Error("Failed deleting image", A_ThisFunc, Error)
		
		this.StepQueue()
	}
	
	ImgurError() {
		
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
		
		;if !Big.IsVisible
		TrayTip(Title, Msg)
		
		; save images file
		JSONSave("Images", Images)
		
		; reset infos
		this.QueueSucceed := []
		
		this.GuiAllowClear(!!this.Queue.MaxIndex())
		this.GuiAllowPause(!!this.Queue.MaxIndex())
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
	
	/*
		=== GUI CONTROL METHODS ===
	*/
	
	GuiAddImage(Index) {
		Big.LV_Colors_OnMessage(false)
		Big.ImgurListAdd(Index)
		Big.LV_Colors_OnMessage(true)
	}
	
	GuiRemoveImage(Index) {
		Big.LV_Colors_OnMessage(false)
		Big.ImgurListRemove(Index)
		Big.LV_Colors_OnMessage(true)
	}
	
	UploadUpdate(per) {
		this.GuiSetStatus(Per > 99 ? "Working.." : "Progress: "(Per) "%")
	}
	
	GuiUpdate() {
		if !this.UpdateGUI
			return
		Big.QueueLV.Delete()
		
		for Index, Arr in [this.Queue, this.QueueFail] {
			Color := [Settings.Color.Selection, "FF2525", "25AA25"][Index]
			for Index2, Info in Arr {
				SplitPath, % Info.ID, FileName
				Pos := Big.QueueLV.Add(, Info.Event, (Info.Error?Info.Error:(FileName?FileName:Info.ID)), Info.Date)
				FileName:=""
				Big.QueueLV.CLV.Row(Pos, "0x" (Index=1?(this.Status = 1?Color:"505050"):Settings.Color.Dark), 0xFFFFFF)
			}
		}
		
		Big.QueueLV.ModifyCol(1, 100)
		Big.QueueLV.ModifyCol(2, Big.HALF_WIDTH*2 - 250)
		Big.QueueLV.ModifyCol(3, 150)
	}
	
	GuiSetStatus(Status) {
		Big.SetText(Big.QueueTextHWND, " " Status)
	}
	
	GuiAllowPause(Allow) {
		Big.Control(Allow?"Enable":"Disable", Big.PauseButtonHWND)
		Big.SetText(Big.PauseButtonHWND, (this.Status=0?"Start":"Pause"))
	}
	
	GuiAllowClear(Allow) {
		Big.Control(Allow?"Enable":"Disable", Big.ClearButtonHWND)
	}
}