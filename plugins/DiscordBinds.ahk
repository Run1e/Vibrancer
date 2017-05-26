#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1
SetKeyDelay -1

#Include %A_ScriptDir%
#Include ..\lib\Class Hotkey.ahk
#Include ..\lib\Class HTTP.ahk
#Include ..\lib\third-party\Class JSON.ahk
#Include ..\lib\Debug.ahk

global NICK := "your discord id here"
global LANG := "AutoHotkey"

if (A_ComputerName = "DESKTOP-AAVK743")
	NICK := "<@265644569784221696>"

Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
Power.OnExit(Func("Exit"))

new Hotkey("~F2", Func("DiscordCode"))
new Hotkey("~F3", Func("DiscordCode").Bind(false))
new Hotkey("~F4", Func("DiscordNP"))
new Hotkey("~*XButton1", Func("DiscordChannelMove").Bind("Down"))
new Hotkey("~*XButton2", Func("DiscordChannelMove").Bind("Up"))

Power.Finished()
return

DiscordNP() {
	static EndPoint := "https://api.spotify.com/v1/search?q="
	WinGetTitle, Title, ahk_exe Spotify.exe
	if !WinActive("ahk_exe Discord.exe") || !StrLen(Title) || (Title = "Spotify")
		return
	
	trackpre := RegExReplace(SubStr(Title, InStr(Title, " - ") + 3), "[^(a-zA-Z|\s)]", "")
	artistpre := RegExReplace(SubStr(Title, 1, InStr(Title, " - ") - 1), "[^(a-zA-Z|\s)]", "")
	
	if HTTP.Get(EndPoint
			. "track:" . HTTP.UriEncode(trackpre)
			. "+artist:" . HTTP.UriEncode(artistpre)
			. "&type=track", Data)

	URL := JSON.Load(Data.ResponseText).tracks.items.1.external_urls.spotify
	
	SendInput % NICK " is listening to **" Title "** " URL "{Enter}"
}

DiscordChannelMove(Direction) {
	MouseGetPos,,, hwnd
	WinGetTitle, Title, % "ahk_id" hwnd
	if InStr(Title, " - Discord") {
		SendInput {CTRL Down}{ALT Down}
		sleep 1
		ControlSend, ahk_parent, % "{" Direction "}", % "ahk_id" hwnd
		sleep 1
		SendInput {Alt Up}{CTRL Up}
	}
}

DiscordCode(Paste := true) {
	if hwnd := WinActive("ahk_exe Discord.exe") {
		SendInput % "`````` " LANG "`n" (Paste ? "^v" : "") "`n`````` "
		sleep 20
		ControlSend, ahk_parent, % "{" (Paste ? "Enter" : "Up") "}", % "ahk_id" hwnd
	}
}

Exit() {
	ExitApp
}