Class Uploader {
	
	__New() {
		
		this.ImgurErrors := { 400: "Invalid parameters specified"
						, 401: "User authentication required to perform action"
						, 403: "Forbidden request"
						, 404: "Non-existent resource"
						, 429: "Rate limit reached"
						, 500: "Internal error"}
		
		this.AllowedExt := "png|jpg|jpeg|gif|bmp"
		this.CLSID := "{9cd4083e-4f48-42e9-9b89-f1fc463b43b8}"
		this.api_access := IsFunc("client_id")?Func("client_id").Call():""
		this.AllowedExt := "png|jpg|jpeg|gif|bmp" 
		
		this.Queue := []
		this.QueueErrors := []
		this.RunQueue := false
		this.Busy := false
		
		this.UploadCount := 0
		this.DeleteCount := 0
		
		this.ImageFolder := A_WorkingDir "\images"
		this.ImgurImageFolder := this.ImageFolder "\imgur"
		this.DeletedImageFolder := this.ImageFolder "\deleted"
		this.LocalImageFolder := this.ImageFolder "\local"
		
		for Index, Folder in [this.ImageFolder, this.DeletedImageFolder, this.LocalImageFolder, this.ImgurImageFolder]
			if !FileExist(Folder)
				FileCreateDir % Folder
		
		; setup com object
		ObjRegisterActive(this, this.CLSID)
		
		; launch the uploader
		this.LaunchWorker()
	}
	
	Upload(File) {
		if !FileExist(File)
			return Error("File specified for upload doesn't exist", A_ThisFunc, "File: " File, true)
		if !StrLen(this.api_access)
			return this.NoClientID()
		this.AddQueue({Event:"Upload", File:File})
		if !this.RunQueue
			this.StartQueue()
	}
	
	Delete(Index) {
		Image := Images[Index]
		if !IsObject(Image)
			return Error("Failed to find image in Images", A_ThisFunc, "Index: " Index)
		if !StrLen(this.api_access)
			return this.NoClientID()
		this.AddQueue({Event:"Delete", DeleteHash:Image.deletehash, Index:Index})
		if !this.RunQueue
			this.StartQueue()
	}
	
	NoClientID() {
		TrayTip("Can't upload, no client_id specified.`n`nRead the GitHub README for instructions!")
		Error("No client_id", A_ThisFunc, "File: " file)
	}
	
	HeaderInfo(header) { ; save headers to this.LastHeaders
		for index, text in StrSplit(header, "`n"), hdr := [] {
			line := StrSplit(text, ": ")
			if (InStr(line[1], "X-") = 1)
				hdr[line[1]] := line[2]
		} this.LastHeaders := hdr
	}
	
	UploadUpdate(Percentage) {
		if (Percentage > 99)
			Msg := "Waiting.."
		else
			Msg := Percentage "%"
		this.SetStatus(Msg)
	}
	
	AddQueue(Pop) {
		this.Queue.InsertAt(1, Pop)
		
		this.SetStatus() ; update queue counter
		if (this.Queue.MaxIndex() > 1)
			this.AllowPause(true)
		else
			this.AllowPause(false)
	}
	
	StartQueue() {
		if this.RunQueue
			return
		this.RunQueue := true
		Big.SetText(Big.StartStopButtonHWND, "Pause")
		this.StepQueue()
	}
	
	StopQueue() { ; stops queue at next StepQueue
		this.RunQueue := false
		
		Big.SetText(Big.StartStopButtonHWND, "Start")
		
		Fin := (this.Queue.MaxIndex() > 0)
		this.AllowPause(Fin)
		this.AllowClear(Fin)
	}
	
	ClearQueue() {
		this.Queue := []
		this.FinishQueue()
	}
	
	StepQueue(Advance := false) {
		
		; check that uploader is running
		if !this.CheckAlive()
			return
		
		if Advance
			this.Queue.Pop()
		
		if !this.RunQueue ; user paused
			return this.StopQueue(), this.SetStatus("Paused..")
		else
			this.AllowClear(false)
		
		Pop := this.Queue[this.Queue.MaxIndex()]
		
		if !IsObject(Pop) ; nothing left, stop runqueue
			return this.FinishQueue()
		
		this.Busy := true ; indicates the Uploader is working
		
		if (this.Queue.MaxIndex() > 1)
			this.AllowPause(true)
		else
			this.AllowPause(false)
		
		this.SetStatus(Pop.Event="Delete"?"Deleting..":"Starting..")
		
		if (Pop.Event = "Upload")
			this.Worker.Upload(Pop.File)
		else if (Pop.Event = "Delete")
			this.Worker.Delete(Pop.Index, Pop.DeleteHash)
	}
	
	; text representation of what's going on (which is shown in the main gui)
	SetStatus(Status := "") {
		static CurrentStatus
		if this.Queue.MaxIndex()
			QueueText := "Queue: " this.Queue.MaxIndex()
		Big.ImgurStatus((StrLen(QueueText)?QueueText " - ":"") . (StrLen(Status)?Status:CurrentStatus))
		CurrentStatus := Status
	}
	
	AllowPause(Toggle) {
		Big.QueueControl(Toggle)
	}
	
	AllowClear(Toggle) {
		Big.ClearQueueControl(Toggle)
	}
	
	UploadResponse(file, JSON_DATA) {
		res := JSON.Load(JSON_DATA)
		
		this.Busy := false
		
		if (res.status = 200) { ; successful upload
			
			Index := A_Now "_" A_MSec
			
			SplitPath, file,,, extension
			
			if (extension = "gif") && Settings.Imgur.UseGifv
				res.data.link .= "v"
			
			Images[Index] := {link:res.data.link, deletehash:res.data.deletehash, id:res.data.id, extension:extension}
			
			JSONSave("Images", Images)
			
			if (InStr(file, this.LocalImageFolder) = 1)
				FileMove % file, % this.ImgurImageFolder "\" res.data.id "." extension, 1
			else
				FileCopy, % file, % this.ImgurImageFolder "\" res.data.id "." extension, 1
			
			clipboard := res.data.link
			
			Big.LV_Colors_OnMessage(false)
			Big.ImgurListAdd(Index)
			Big.LV_Colors_OnMessage(true)
			
			this.UploadCount++
			
			this.StepQueue(true) ; advance in queue and continue
			
		} else ; post request succeeded, imgur threw an error
			this.UploadFailure(file, res)
		
	}
	
	UploadFailure(file, res) {
		if IsObject(res) { ; imgur threw the error
			this.ImgurError(res)
		} else { ; uploader threw the error
			Error("Uploader threw an error when uploading", A_ThisFunc, "File: " file "`n`n" res)
			this.QueueErrors.Push(res)
			this.StepQueue(true)
		} return
	}
	
	DeleteResponse(Index, JSON_DATA) {
		res := JSON.Load(JSON_DATA)
		
		this.Busy := false
		
		if (res.status = 200) { ; successful deletion
			
			Image := Images.Delete(Index)
			JSONSave("Images", Images)
			
			FileMove, % this.ImgurImageFolder "\" Image.id "." Image.extension, % this.DeletedImageFolder "\" Image.id "." Image.extension
			
			Big.LV_Colors_OnMessage(false)
			Big.ImgurListRemove(Index)
			Big.LV_Colors_OnMessage(true)
			
			this.DeleteCount++
			
			this.StepQueue(true) ; advance in queue and continue
			
		} else
			this.DeleteFailure(Index, res)
		
	}
	
	DeleteFailure(Index, res) {
		if IsObject(res) { ; imgur threw the error
			this.ImgurError(res)
		} else {
			Error("Program threw an error when deleting", A_ThisFunc, "Image: " pa(Images[Index]) "`n`n" res)
			this.QueueErrors.Push(res)
			this.StepQueue(true)
		}
	}
	
	ImgurError(res) { ; takes an imgur error status and decides what to do
		
		status := res.status
		error := (IsObject(res.data.error)?res.data.error.message:res.data.error)
		
		Error("Imgur threw an error: " this.ImgurErrors[status], A_ThisFunc, "File: " file "`n`nRes:`n" pa(res) "`n`nHeaders:`n" pa(this.LastHeaders))
		
		if (status = "400") {
			
			if (InStr(error, "You are uploading too fast. Please wait ") = 1) { ; rate limit, fake it as status 429 and recurse it (yes that's a verb)
				res.status := 429
				this.ImgurError(res)
			} else {
				this.QueueErrors.Push(error)
				this.StepQueue(true) ; skip and continue
			}
			
		} else if (status ~= "401|403|404") {
			
			this.QueueErrors.Push(error)
			this.StepQueue(true) ; skip and continue
			
		} else if (status = 429) { ; rate limit reached or ip temporarily blocked
			
			; this.QueueErrors.Push("Imgur: " error)
			
			if (this.LastHeaders["X-RateLimit-UserRemaining"] = 0) ; user has spent all credits
				TrayTip("Imgur error!", "You've uploaded too much.`nImgur will allow more uploads in " Round(this.LastHeaders["X-Post-Rate-Limit-Reset"] / 60) " minutes.")
			else if (this.LastHeaders["X-RateLimit-ClientRemaining"] = 0) ; client_id credits is empty, we need a new one
				TrayTip("Imgur error!", "Client rate limits have been reached.`nEmail me at runar-borge@hotmail.com if this continues happening.")
			else ; last error is IP spam prevention
				TrayTip("Imgur is panicking!", "Imgur doesn't like you uploading this fast.`nImgur will allow more uploads in " Round(this.LastHeaders["X-Post-Rate-Limit-Reset"] / 60) " minutes.")
			
			this.StopQueue()
			this.SetStatus("Imgur timeout/limit")
			
		} else if (status = 500) { ; imgur internal error
			
			this.QueueErrors.Push(error)
			this.StepQueue(true) ; skip, continue
			
		}
	}
	
	; clean up and craft a message for the user
	FinishQueue() {
		
		; craft queue message
		if (!this.UploadCount && !this.DeleteCount && this.QueueErrors.MaxIndex()) { ; everything failed :(
			
			for Index, Error in this.QueueErrors
				Errors .= Error "`n"
			
			if (this.QueueErrors.MaxIndex() < 4) {
				Title := "Queue error" . (this.QueueErrors.MaxIndex()>1?"s":"") . ":"
				Msg := Errors
			} else { ; many errors
				MsgBox, 64, List of failed queue items:, % Errors
				Shown := true
			}
			
			AllFail := true
			
		}
		else if (this.UploadCount && !this.DeleteCount) { ; only uploads
			
			Title := (this.UploadCount>1?this.UploadCount " i":"I")"mage" (this.UploadCount>1?"s":"") " uploaded!"
			if (this.UploadCount=1) {
				
				Msg := "Link copied to clipboard."
				
				; check for hotkey pointing to Action.RunClipboard()
				; and show it in the traytip in that case to remind user that they have that hotkey
				if !Big.IsVisible {
					for Key, Bind in Keybinds {
						if (Bind.Func = "RunClipboard") {
							Msg .= "`nClipboard Keybind: " HotkeyToString(Key)
							break
				}}} ; I've never done this before. How exiting.
				
			} else
				Msg := "Open the Imgur tab to see images."
			
		}
		else if (this.DeleteCount && !this.UploadCount) { ; only deletions
			Title := (this.DeleteCount>1?this.DeleteCount " i":"I") "mage" (this.DeleteCount>1?"s":"") " deleted!"
			Msg := "Image" (this.DeleteCount>1?"s":"") " have been deleted from imgur."
		}
		else { ; both
			Title := "Queue report:"
			Msg := this.UploadCount " image" (this.UploadCount>1?"s":"") " uploaded.`n" this.DeleteCount  " image" (this.DeleteCount>1?"s":"") " deleted."
		}
		
		if this.QueueErrors.MaxIndex() && !AllFail
			Msg .= "`n`nQueue errors: " this.QueueErrors.MaxIndex()
		
		if !Shown
			TrayTip(Title, Msg)
		
		; reset info
		this.QueueErrors := []
		this.UploadCount:=this.DeleteCount:=0
		
		this.StopQueue()
		this.SetStatus("Queue finished!")
	}
	
	Handshake(UploaderObj) {
		static Shaked
		this.Worker := UploaderObj
		if Shaked
			this.StartQueue()
		Shaked := true
		return
	}
	
	LaunchWorker() {
		Run % A_WorkingDir "\PowerPlayUploader." (A_IsCompiled?"exe":"ahk"),, UseErrorLevel
		if (ErrorLevel = "ERROR")
			Error("Failed to run Uploader Helper", A_ThisFunc, "Uploader." (A_IsCompiled?"exe":"ahk") " failed to run, please e-mail me at runar-borge@hotmail.com if this issue persists.",, true)
		sleep 500 ; should be enough, maybe get a less hacky solution
	}
	
	CheckAlive() {
		try
			this.Worker.ArbitraryMethodNameToLureOutAnError()
		catch e {
			this.LaunchWorker()
			return false
		} return true
	}
	
	RuntimeError(Msg) {
		m("Runtime error in Uploader`n`nPlease e-mail me at runar-borge@hotmail.com if this continues to happen.")
		Error("Runtime error in Uploader", A_ThisFunc, Msg,, true)
	}
	
	Free() {
		this.Worker.Exit() ; close upload helper
		sleep 50
		DllCall("oleaut32\RevokeActiveObject", "uint", this.cookie, "ptr", 0) ; revoke plugin object
	}
}