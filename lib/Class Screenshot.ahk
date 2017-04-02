Class Screenshot {
	
	static ImgurErrors := 	{ 400: "Invalid parameters specified"
						, 401: "User authentication required to perform action"
						, 403: "Forbidden request"
						, 404: "Non-existent resource"
						, 429: "Rate limit reached"
						, 500: "Internal error"}
	
	__New() {
		this.AllowedExt := "png|jpg|jpeg|gif|bmp"
		this.CLSID := "{9cd4083e-4f48-42e9-9b89-f1fc463b43b8}"
		this.api_access := client_id()
		this.AllowedExt := "png|jpg|jpeg|gif|bmp" 
		this.Queue := []
		this.QueueErrors := []
		this.RunQueue := false
		this.ImageQuality := 90 ; in %
		this.ImageFolder := A_WorkingDir "\images"
		this.ImgurImageFolder := this.ImageFolder "\imgur"
		this.DeletedImageFolder := this.ImageFolder "\deleted"
		this.LocalImageFolder := this.ImageFolder "\local"
		this.ThumbnailImageFolder := this.ImageFolder "\thumbnails"
		this.Busy := false
		this.UploadCount := 0
		this.DeleteCount := 0
		this.FailedCount := 0
		
		for Index, Folder in [this.ImageFolder, this.DeletedImageFolder, this.LocalImageFolder, this.ImgurImageFolder, this.ThumbnailImageFolder]
			if !FileExist(Folder)
				FileCreateDir % Folder
		
		; setup com object
		ObjRegisterActive(this, this.CLSID)
		
		this.LaunchUploader()
	}
	
	; gdip solution later maybe?
	CaptureRect() {
		static abort
		color=999999
		r:=2
		w:=120
		Gui 55: -Caption +AlwaysOnTop +Border +LastFound hwndmousehover -E0x20
		Gui 55: Show
		WinSet, Region,0-0 w%w% h%w% R300-300, % "ahk_id" mousehover
		WinSet, Transparent, 5, ahk_id %mousehover%
		Loop 4 {
			num:=50+A_Index
			Gui %num%: Color, % color
			Gui %num%: -Caption +ToolWindow +AlwaysOnTop
		} Cursor("IDC_CROSS")
		while (!GetKeyState("LButton", "P")) {
			MouseGetPos, xn, yn
			Gui 55: Show, % "NA X" xn - w/2 " Y" yn - w/2 " W" w " H" w
			if GetKeyState("Escape", "P") {
				abort:=true
				goto abort
			} sleep 16
		} MouseGetPos, x, y
		while (GetKeyState("LButton", "P")) {
			MouseGetPos, xn, yn
			Gui 51: Show, % "NA X" (xn < x ? xn : x) " Y" y " W" abs(xn-x) + r " H" r ; CD
			Gui 52: Show, % "NA X" (xn < x ? xn : x) " Y" yn " W" abs(xn-x) + r " H" r ; AB
			Gui 53: Show, % "NA X" x " Y" (yn < y ? yn : y) " W" r " H" abs(yn-y) ; AD
			Gui 54: Show, % "NA X" xn " Y" (yn < y ? yn : y) " W" r " H" abs(yn-y) ; BC
			Gui 55: Show, % "NA X" xn - w/2 " Y" yn - w/2
			if GetKeyState("Escape", "P") {
				abort:=true
				goto abort
			} sleep 16
		}
		abort:
		Loop 5 {
			num:=50+A_Index
			Gui %num%: Destroy
		} Cursor()
		if !abort
			Screenshot.Capture(x < xn ? x : xn, y < yn ? y : yn, abs(xn-x), abs(yn-y))
		abort:=false
		return
	}
	
	CaptureWindow() {
		WinGetPos, x, y, w, h, A
		if ErrorLevel {
			TrayTip, Error Occured, Failed getting active window position.
			return Error("Failed to get WinPos", A_ThisFunc, "ErrorLevel set by WinGetPos: " ErrorLevel)
		}
		Screenshot.Capture(x, y, w, h)
	}
	
	CaptureScreen() {
		Screenshot.Capture(0, 0, A_ScreenWidth, A_ScreenHeight)
	}
	
	Capture(x, y, w, h) {
		if !StrLen(x) || !StrLen(y) || !StrLen(w) || !StrLen(h)
			return Error("Invalid parameters passed", A_ThisFunc, x ", " y ", " w ", " h, true)
		
		Name := A_Now A_MSec
		File := this.LocalImageFolder "\" Name ".png" ; save to local image folder
		
		pBitmap := Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
		
		Gdip_Success := Gdip_SaveBitmapToFile(pBitmap, File, this.ImageQuality)
		if (Gdip_Success < 0) {
			Error := {  -1:"Extension supplied is not a supported file format"
					, -2:"Could not get a list of encoders on system"
					, -3:"Could not find matching encoder for specified file format"
					, -4:"Could not get WideChar name of output file"
					, -5:"Could not save file to disk"}[Gdip_Success]
			return Error(Error, A_ThisFunc ": Gdip_SaveBitmapToFile", "File: " File "`nImageQuality: " this.ImageQuality, true)
		}
		
		Gdip_DisposeImage(pBitmap)
		this.Upload(File)
		return Name
	}
	
	
	
	/*
		*** PLUGIN METHODS BELOW ***
	*/
	
	Upload(File) {
		if !FileExist(File)
			return Error("File specified for upload doesn't exist", A_ThisFunc, "File: " File, true)
		this.AddQueue({Event:"Upload", File:File})
		if !this.RunQueue
			this.StartQueue()
	}
	
	Delete(Index) {
		Image := Images[Index]
		if !IsObject(Image)
			return Error("Failed to find image in Images", A_ThisFunc, "Index: " Index)
		this.AddQueue({Event:"Delete", DeleteHash:Image.deletehash, Index:Index})
		if !this.RunQueue
			this.StartQueue()
	}
	
	HeaderInfo(header) { ; save headers to this.LastHeaders
		for index, text in StrSplit(header, "`n"), hdr := [] {
			line := StrSplit(text, ": ")
			if (InStr(line[1], "X-") = 1)
				hdr[line[1]] := line[2]
		} this.LastHeaders := hdr
	}
	
	LaunchUploader() {
		Run % A_WorkingDir "\Uploader." (A_IsCompiled?"exe":"ahk"),, UseErrorLevel
		if (ErrorLevel = "ERROR")
			Error("Failed to run Uploader Helper", A_ThisFunc, "Uploader." (A_IsCompiled?"exe":"ahk") " failed to run, please e-mail me at runar-borge@hotmail.com if this issue persists.",, true)
		sleep 250 ; should be enough, maybe get a less hacky solution
	}
	
	CheckAlive() {
		try
			this.Plugin.ArbitraryMethodNameToLureOutAnError()
		catch e {
			this.LaunchUploader()
			return false
		} return true
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
		this.RunQueue := true
		Big.SetText(Big.StartStopButtonHWND, "Pause")
		this.StepQueue()
	}
	
	StopQueue() { ; stops queue at next StepQueue
		this.RunQueue := false
		Big.SetText(Big.StartStopButtonHWND, "Start")
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
		
		if !this.RunQueue {
			if this.Queue.MaxIndex() {
				this.SetStatus("Paused..")
				this.AllowPause(true)
				this.AllowClear(true)
			}
			return
		} else
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
			this.Plugin.Upload(Pop.File)
		else if (Pop.Event = "Delete")
			this.Plugin.Delete(Pop.Index, Pop.DeleteHash)
	}
	
	; create and show the user the result of the queue
	FinishQueue() {
		this.RunQueue := false
		this.SetStatus("Queue finished!")
		this.AllowPause(false)
		this.AllowClear(false)
		
		if (!this.UploadCount && !this.DeleteCount && this.FailedCount) {
			Title := "Queue items failed"
			Msg := "Failed items: " this.FailedCount
			this.FailedCount := 0
		}
		else if (this.UploadCount && !this.DeleteCount) { ; only uploads
			
			Title := (this.UploadCount>1?this.UploadCount " i":"I")"mage" (this.UploadCount>1?"s":"") " uploaded!"
			if (this.UploadCount=1) {
				
				Msg := "Link copied to clipboard."
				
				; check for hotkey pointing to Action.RunClipboard()
				; and show it in the traytip in that case
				if !Big.IsVisible {
					for Key, Bind in Keybinds {
						if (Bind.Func = "RunClipboard") {
							Msg .= "`nClipboard Keybind: " HotkeyToString(Key)
							break
						}
					}
				}
				
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
		
		if (this.FailedCount)
			Msg .= "`n`nFailed items: " this.FailedCount
		
		TrayTip, % Title, % Msg
		
		this.QueueErrors := []
		this.UploadCount:=this.DeleteCount:=this.FailedCount:=0
		this.StopQueue()
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
		this.FailedCount++
		if IsObject(res) { ; imgur threw the error
			this.ImgurError(res)
		} else { ; uploader threw the error
			Error("Uploader threw an error when uploading", A_ThisFunc, "File: " file "`n`n" res)
			this.QueueErrors.Push("Uploader error: " res)
			this.StepQueue(true)
		} return
	}
	
	DeleteResponse(Index, JSON_DATA) {
		res := JSON.Load(JSON_DATA)
		
		this.Busy := false
		
		if (res.status = 200) {
			
			Image := Images.Delete(Index)
			JSONSave("Images", Images)
			
			FileMove, % this.ImgurImageFolder "\" Image.id "." Image.extension, % this.DeletedImageFolder "\" Image.id "." Image.extension, 1
			
			Big.LV_Colors_OnMessage(false)
			Big.ImgurListRemove(Index)
			Big.LV_Colors_OnMessage(true)
			
			this.DeleteCount++
			
			this.StepQueue(true) ; advance in queue and continue
			
		} else
			this.DeleteFailure(Index, res)
		
	}
	
	DeleteFailure(Index, res) {
		this.FailedCount++
		if IsObject(res) { ; imgur threw the error
			this.ImgurError(res)
		} else {
			Error("Program threw an error when deleting", A_ThisFunc, "Image: " pa(Images[Index]) "`n`n" res)
			this.QueueErrors.Push("Delete error: " res)
			this.StepQueue(true)
		}
	}
	
	ImgurError(res) { ; takes an imgur error status and decides what to do
		
		status := res.status
		error := (IsObject(res.data.error)?res.data.error.message:res.data.error)
		
		Error("Imgur threw an error: " this.ImgurErrors[status], A_ThisFunc, "File: " file "`n`n" pa(res))
		
		if (status = "400") {
			
			if (InStr(error, "You are uploading too fast. Please wait ") = 1) { ; rate limit, fake it as status 429 and recurse it (yes that's a verb)
				res.status := 429
				this.ImgurError(res)
			} else {
				this.QueueErrors.Push("Imgur: " error)
				this.StepQueue(true) ; skip and continue
			}
			
		} else if (status ~= "401|403|404") {
			
			this.QueueErrors.Push("Imgur: " error)
			this.StepQueue(true) ; skip and continue
			
		} else if (status = 429) { ; rate limit reached or ip temporarily blocked
			
			this.QueueErrors.Push("Imgur: " error)
			
			if (this.LastHeaders["X-RateLimit-UserRemaining"] = 0) { ; user has spent all credits
				TrayTip, Imgur error!, % "You've uploaded too much.`nImgur will allow more uploads in " Round(this.Timeout / 60) " minutes."
			} else if (this.LastHeaders["X-RateLimit-ClientRemaining"] = 0) { ; client_id credits is empty, we need a new one
				TrayTip, Imgur error!, % "Client rate limits have been reached.`nEmail me at runar-borge@hotmail.com if this continues happening."
			} else { ; last error is IP spam prevention
				TrayTip, Imgur is panicking!, % "Imgur doesn't like you uploading this fast.`nImgur will allow more uploads in " Round(this.Timeout / 60) " minutes."
			}
			
			this.StopQueue()
			this.SetStatus("Imgur error..")
			
		} else if (status = 500) { ; imgur internal error
			
			this.QueueErrors.Push("Imgur: " error)
			this.StepQueue(true) ; skip, continue
			
		}
	}
	
	Handshake(PluginClass) {
		
		if IsObject(this.Plugin)
			Start := true
		
		this.Plugin := PluginClass
		
		if Start
			this.StartQueue()
		
		return
	}
	
	RuntimeError(Msg) {
		m("Runtime error in Uploader`n`nPlease e-mail me at runar-borge@hotmail.com if this continues to happen.")
		Error("Runtime error in Uploader", A_ThisFunc, Msg,, true)
	}
	
	Free() {
		this.Plugin.Exit() ; close upload helper
		sleep 50
		DllCall("oleaut32\RevokeActiveObject", "uint", this.cookie, "ptr", 0) ; revoke plugin object
	}
}