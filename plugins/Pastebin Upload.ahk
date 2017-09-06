; Upload Clipboard to Pastebin
; RUNIE
#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1
SetKeyDelay -1
SetWorkingDir % A_ScriptDir

#Include %A_ScriptDir%
#Include ..\lib\plugin\BindSection.ahk
#Include ..\lib\Class HTTP.ahk
#Include ..\lib\Functions.ahk
#Include ..\lib\Debug.ahk

global Vib, Binds, Key

try
	Vib := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Vib.OnExit(Func("Exit"))

Binds := new BindSection(Vib, "Pastebin", "Pastebin")
Binds.AddFunc("UploadClip", Func("UploadClip"))
Binds.AddBind("Upload Clipboard", "UploadClip")
Binds.Register()

Vib.Finished()
return

TrayTip(Title, Msg := "") {
	if !StrLen(Msg)
		Msg := Title, Title := "Pastebin Plugin"
	Vib.Call("TrayTip", Title, Msg)
}

Exit() {
	ExitApp
}

GetKey() {
	FileRead, Key, ..\data\PastebinKey.txt
	return Key
}

SetKey() {
	Run("https://pastebin.com/api")
	InputBox, Key, Pastebin Developer API Key, Input your Developer API Key here:,, 280, 130
	if !ErrorLevel {
		FileDelete ..\data\PastebinKey.txt
		FileAppend % Key, ..\data\PastebinKey.txt
		MsgBox,64,Success!,You can now upload text to pastebin.
	}
}

UploadClip() {
	static EndPoint := "https://pastebin.com/api/api_post.php"
	
	if !StrLen(clipboard)
		return TrayTip("Clipboard is empty.")
	
	Key := GetKey()
	
	if !StrLen(Key)
		return SetKey()
	
	POST := {api_dev_key:Key, api_option:"paste", api_paste_private:true, api_paste_code:clipboard}
	
	; default timeout is 5000ms
	if !HTTP.Post(EndPoint, POST)
		return TrayTip("Failed uploading paste.")
	
	Response := POST.ResponseText
	
	if (InStr(Response, "https://pastebin.com") = 1) {
		Title := "Clipboard uploaded!"
		Msg := "Link copied to clipboard."
		Clipboard(StrReplace(Response, "https://pastebin.com/", "https://pastebin.com/raw/"))
	} else {
		Title := "Paste failed!"
		Msg := (Response ? "Error: " Response : "Request timed out.")
	}
	
	TrayTip(Title, Msg)
}