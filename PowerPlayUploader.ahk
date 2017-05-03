#SingleInstance force
#Persistent
#NoTrayIcon

Worker := new Worker

global Main

try
	Main := ComObjActive("{9cd4083e-4f48-42e9-9b89-f1fc463b43b8}")
catch e
	ExitApp

Worker.client_id := Main.client_id

Main.Handshake(Worker)
return

UploadUpdate(Percent, FileSize) {
	static Sent := 0
	Percent := Round((Percent + 1) * 100)
	Fives := (Round(percent / 5) * 5)
	if (Percent < 5)
		Sent:=0
	if (Fives > Sent)
		CallMain("UploadUpdate", Sent := Fives)
}

CallMain(Func, Param*) {
	try
		Main[Func](Param*)
	catch e
		ExitApp
}

Class Worker {
	__New() {
		this.EndPoint := "https://api.imgur.com/3/image"
		; this.ADODB := ComObjCreate("ADODB.Stream")
		; this.ADODB.Type := 1 ; binary mode
	}
	
	Upload(File) {
		func := Worker.UploadFile.Bind(Worker, File)
		SetTimer, %func%, -1
	}
	
	UploadFile(File) {
		FileGetSize, FileSize, %File%
		
		DownloadedBytes := HTTPRequest( this.EndPoint
								, Data
								, Header := "Authorization: Client-ID " . this.client_id "`nContent-Length: " FileSize
								, "Callback: UploadUpdate`nMethod: POST`nUpload: " file)
		
		if (DownloadedBytes > 0) && StrLen(Data) {
			CallMain("HeaderInfo", Header)
			CallMain("UploadResponse", File, Data)
		} else
			CallMain("UploadFailure", File, Header)
	}
	
	Delete(Index, DeleteHash) {
		func := Worker.DeleteFile.Bind(Worker, Index, DeleteHash)
		SetTimer, %func%, -1
	}
	
	DeleteFile(Index, DeleteHash) {
		
		DownloadedBytes := HTTPRequest(this.EndPoint "/" DeleteHash
								, Data
								, Header := "Authorization: Client-ID " . this.client_id
								, "Method: DELETE")
		
		
		if (DownloadedBytes > 0) && StrLen(data) {
			CallMain("HeaderInfo", Header)
			CallMain("DeleteResponse", Index, Data)
		} else
			CallMain("DeleteFailure", Index, Header)
		
		return
	}
	
	/*
		GetBinaryData(file) {
			this.ADODB.Open() ; Open the Stream object to load a file into it
			this.ADODB.LoadFromFile(file) ; Load the contents of the file into the Stream
			Binary := this.ADODB.Read()
			this.ADODB.Close()
			return Binary
		}
	*/
	
	/*
		this.ImageFile := ComObjCreate("WIA.ImageFile")
		
		GetBinaryData(file) {
			this.ImageFile.LoadFile(file)
			binary := this.ImageFile.filedata.binarydata
			return binary
		}
	*/
	
	Exit() {
		SetTimer, Exit, -1
		return
	}
}

Exit:
ExitApp
return

#Include lib\third-party\HTTPRequest.ahk