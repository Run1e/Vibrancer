UploaderScript() {
	script =
(

; ==============================================================================================

#SingleInstance force
#Persistent
#NoTrayIcon
#Include imgurlib\third-party\HTTPRequest.ahk

OnExit("Exit")
global Main
global client_id := Main.client_id
global EndPoint := "https://api.imgur.com/3/image"
return

UploadUpdate(Percent, FileSize) {
	static Sent := 0
	Percent := Round((Percent + 1) * 100)
	Fives := (Round(percent / 2) * 2)
	if (Percent < 2)
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

Upload(File) {
	FileGetSize, FileSize, %File%
	
	DownloadedBytes := HTTPRequest( EndPoint
							, Data
							, Header := "Authorization: Client-ID " client_id "``nContent-Length: " FileSize
							, "Callback: UploadUpdate``nMethod: POST``nUpload: " File)
	
	if (DownloadedBytes > 0) && StrLen(Data) {
		CallMain("HeaderInfo", Header)
		CallMain("UploadResponse", Data)
	} else
		CallMain("UploadFailure", Header)
}

Delete(DeleteHash) {
	DownloadedBytes := HTTPRequest( EndPoint "/" DeleteHash
							, Data
							, Header := "Authorization: Client-ID " client_id
							, "Method: DELETE")
	
	
	if (DownloadedBytes > 0) && StrLen(data) {
		CallMain("HeaderInfo", Header)
		CallMain("DeleteResponse", Data)
	} else
		CallMain("DeleteFailure", Header)
}

Exit() {
	ExitApp
}

; ==============================================================================================

)
	return script
}