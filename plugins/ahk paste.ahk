; Upload Clipboard to Pastebin
; RUNIE
#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1
SetKeyDelay -1

#Include %A_ScriptDir%
#Include ..\lib\plugin\BindSection.ahk
#Include ..\lib\Class HTTP.ahk
#Include ..\lib\Functions.ahk

global Vib, Binds

try
	Vib := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Vib.OnExit(Func("Exit"))

Binds := new BindSection(Vib, "AHK Paste", "ahkpaste")
Binds.AddFunc("UploadClip", Func("UploadClip"))
Binds.AddBind("Upload Clipboard", "UploadClip")
Binds.Register()

Vib.Finished()
return

TrayTip(Title, Msg := "") {
	if !StrLen(Msg)
		Msg := Title, Title := "p.ahkscript.org"
	Vib.Call("TrayTip", Title, Msg)
}

Exit() {
	ExitApp
}

UploadClip() {
	static EndPoint := "https://p.ahkscript.org/"
	
	if !StrLen(clipboard)
		return TrayTip("Clipboard is empty.")
	
	; default timeout is 5000ms
	if !HTTP.Post(EndPoint, POST := {code:clipboard})
		return TrayTip("Failed uploading paste.")
	
	Link := HTTP.HTTP.Option(1)
	
	if (POST.Status = 200) {
		Title := "Clipboard uploaded!"
		Msg := "Link copied to clipboard."
		Clipboard(Link)
	} else {
		Title := "Paste failed!"
		Msg := (Response ? "Error: " Response : "Request timed out.")
	}
	
	TrayTip(Title, Msg)
}