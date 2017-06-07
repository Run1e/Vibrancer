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

global Power, Listener

try
	Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Power.OnExit(Func("Exit"))

Listener := new EventListener(Power)
for Index, Event in Events
	Listener.Listen(Event, Func("Events").Bind(Event))

Menu := Power.CreateMenu("Debugger")
Menu.Add("Open directory", Power.Func("Run").Bind(Power.Directory))
Menu.Add("Open data folder", Power.Func("Run").Bind(Power.Directory "\data"))
Menu.Add("Get download count", Func("GetDownloadCount"))

Power.TrayAdd(Menu,, Power.Call("Icon", "bug"))
Power.TrayAdd("reload", Power.Func("reload"))

Power.Finished()
return

Events(Event, Params*) {
	for Index, Param in Params, Print := {}
		Print[Index] := Param
	p("EVENT: " Event, Print, "-------------------------------------------------------------------------------")
	if (Event = "RulesEnable")
		s(Params.2.Title)
}

GetDownloadCount() {
	static URL := "https://api.github.com/repos/Run1e/PowerPlay/releases"
	if !HTTP.Get(URL, Data)
		return Power.Call("TrayTip", "Failed getting DL count", "shit")
	JSONData := JSON.Load(Data.ResponseText)
	for a, b in JSONData
		count += b.assets.1.download_count
	Power.Call("TrayTip", "Download count", count)
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