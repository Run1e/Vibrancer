; Event listener and more
; RUNIE
#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1

#Include %A_ScriptDir%
#Include ..\lib\plugin\EventListener.ahk
#Include ..\lib\Debug.ahk

#Include ..\lib\Class HTTP.ahk
#Include ..\lib\Debug.ahk
#Include ..\lib\third-party\Class JSON.ahk

Events := ["RulesEnable", "RulesDisable", "AppSelectCallback", "BindCallback", "GuiOpen", "GuiClose", "GuiSetTab", "CheckForUpdates", "Updating", "SetScreens"]

global Vib, Listener

try
	Vib := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Vib.OnExit(Func("Exit"))

Listener := new EventListener(Vib)
for Index, Event in Events
	Listener.Listen(Event, Func("Events").Bind(Event))

Menu := Vib.CreateMenu("Debugger")
Menu.Add("Open directory", Vib.Func("Run").Bind(Vib.Directory))
Menu.Add("Open data folder", Vib.Func("Run").Bind(Vib.Directory "\data"))
Menu.Add("Get download count", Func("GetDownloadCount"))

Vib.TrayAdd(Menu,, Vib.Call("Icon", "bug"))
Vib.TrayAdd("reload", Vib.Func("reload"))

Vib.Finished()
return

Events(Event, Params*) {
	for Index, Param in Params, Print := {}
		Print[Index] := Param
	p("EVENT: " Event, Print, "-------------------------------------------------------------------------------")
	if (Event = "RulesEnable")
		s(Params.2.Title)
}

GetDownloadCount() {
	static URL := "https://api.github.com/repos/Run1e/Vibrancer/releases"
	if !HTTP.Get(URL, Data)
		return Vib.Call("TrayTip", "Failed getting DL count", "shit")
	JSONData := JSON.Load(Data.ResponseText)
	for a, b in JSONData
		count += b.assets.1.download_count
	Vib.Call("TrayTip", "Download count", count)
}

p(x*) {
	static _:=DllCall("AllocConsole")
	for a, b in x
		out .= (IsObject(b) ? (t:=pa(b)) (StrLen(t) ? "`n" : "") : b "`n")
	FileOpen("CONOUT$", "w").Write(out)
}

s(text := "") {
	static oVoice := ComObjCreate("SAPI.SpVoice")
	oVoice.Speak(text, 1)
}

Exit() {
	ExitApp
}