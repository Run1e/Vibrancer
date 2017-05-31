UploaderScript() {
	script =
(

; ==============================================================================================

#SingleInstance force
#Persistent
#NoTrayIcon
#Include lib\third-party\HTTPRequest.ahk

OnExit("Exit")
global Main
global EndPoint := "https://api.imgur.com/3/image"
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

Upload(File) {
	FileGetSize, FileSize, %File%
	
	DownloadedBytes := HTTPRequest( EndPoint
							, Data
							, Header := "Authorization: Client-ID " . Main.client_id "``nContent-Length: " FileSize
							, "Callback: UploadUpdate``nMethod: POST``nUpload: " File)
	
	if (DownloadedBytes > 0) && StrLen(Data) {
		CallMain("HeaderInfo", Header)
		CallMain("UploadResponse", File, Data)
	} else
		CallMain("UploadFailure", File, Header)
}

Delete(Index, DeleteHash) {
	DownloadedBytes := HTTPRequest( EndPoint "/" DeleteHash
							, Data
							, Header := "Authorization: Client-ID " . Main.client_id
							, "Method: DELETE")
	
	
	if (DownloadedBytes > 0) && StrLen(data) {
		CallMain("HeaderInfo", Header)
		CallMain("DeleteResponse", Index, Data)
	} else
		CallMain("DeleteFailure", Index, Header)
}

Exit() {
	ExitApp
}

; ==============================================================================================

)
	return script
}