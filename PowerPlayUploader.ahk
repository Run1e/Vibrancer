#SingleInstance force
#Persistent
#NoTrayIcon

Uploader := new Uploader

global Main

try
	Main := ComObjActive("{9cd4083e-4f48-42e9-9b89-f1fc463b43b8}")
catch e
	ExitApp

Main.Handshake(Uploader)

Uploader.api_access := Main.api_access

return

UploadUpdate(Percent, FileSize) {
	static Sent
	Percent := Round((Percent + 1) * 100)
	Fives := (Round(percent / 5) * 5)
	if (Percent < 5)
		Sent:=0
	if (Fives > Sent)
		Main.UploadUpdate(Sent := Fives)
}

Class Uploader {
	__New() {
		this.EndPoint := "https://api.imgur.com/3/image"
		; this.ADODB := ComObjCreate("ADODB.Stream")
		; this.ADODB.Type := 1 ; binary mode
	}
	
	Upload(file) {
		func := Uploader.UploadFile.Bind(Uploader, file)
		SetTimer, %func%, -1
		return
	}
	
	UploadFile(file) {
		
		FileGetSize, FileSize, %file%
		if (FileSize > 10000000) ; 10mb is limit
			return Main.UploadFailure(file, "Filesize too large (limit: 10mb)")
		
		SplitPath, file,,,, time
		
		DownloadedBytes := HTTPRequest(this.EndPoint "?title=" time
								, data
								, header := "Authorization: Client-ID " . this.api_access "`nContent-Length: " FileSize
								, "Callback: UploadUpdate`nMethod: POST`nUpload: " file)
		
		if (DownloadedBytes > 0) && StrLen(data) {
			Main.HeaderInfo(header)
			Main.UploadResponse(file, data)
		} else
			Main.UploadFailure(file, header)
		
		
		return
	}
	
	Delete(Index, DeleteHash) {
		func := Uploader.DeleteFile.Bind(Uploader, Index, DeleteHash)
		SetTimer, %func%, -1
		return
	}
	
	DeleteFile(Index, DeleteHash) {
		
		DownloadedBytes := HTTPRequest(this.EndPoint "/" DeleteHash
								, data
								, header := "Authorization: Client-ID " . this.api_access
								, "Method: DELETE")
		
		
		if (DownloadedBytes > 0) && StrLen(data) {
			Main.HeaderInfo(header)
			Main.DeleteResponse(Index, data)
		} else
			Main.DeleteFailure(Index, header)
		
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

pa(array, depth=5, indentLevel:="   ") { ; tidbit, this has saved my life
	try {
		for k,v in Array {
			lst.= indentLevel "[" k "]"
			if (IsObject(v) && depth>1)
				lst.="`n" pa(v, depth-1, indentLevel . "    ")
			else
				lst.=" => " v
			lst.="`n"
		} return rtrim(lst, "`r`n `t")	
	} return
}

pap(array) {
	m(pa(array))
}

m(x*){
	for a,b in x
		text.=b "`n"
	MsgBox,0,, % text
}

#Include lib\third-party\HTTPRequest.ahk