; Paste code and 'Now Playing'
; RUNIE
#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1
SetKeyDelay -1

#Include %A_ScriptDir%
#Include ..\lib\plugin\BindSection.ahk
#Include ..\lib\Debug.ahk

global NICK := "your discord id here"
global LANG := "AutoHotkey"

if (A_ComputerName = "DESKTOP-AAVK743")
	NICK := "<@265644569784221696>"

try
	Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Power.OnExit(Func("Exit"))

Binds := new BindSection(Power, "Discord", "Discord")

Binds.AddFunc("NowPlaying", Func("NowPlaying"))
Binds.AddFunc("ServerMove", Func("ServerMove"))
Binds.AddFunc("Code", Func("Code"))

Binds.AddBind("Now Playing", "NowPlaying")
Binds.AddBind("Paste Code", "Code")
Binds.AddBind("Paste Markdown", "Code", false)
Binds.AddBind("Server Up", "ServerMove", "Up")
Binds.AddBind("Server Down", "ServerMove", "Down")

Binds.Register()

Power.Finished()
return

NowPlaying() {
	; static EndPoint := "https://api.spotify.com/v1/search?q="
	
	WinGetTitle, Title, ahk_exe Spotify.exe
	if !WinActive("ahk_exe Discord.exe") || !StrLen(Title) || (Title = "Spotify")
		return
	
	/*
		trackpre := RegExReplace(SubStr(Title, InStr(Title, " - ") + 3), "[^(a-zA-Z0-9|\s)]", "")
		artistpre := RegExReplace(SubStr(Title, 1, InStr(Title, " - ") - 1), "[^(a-zA-Z0-9|\s)]", "")
		m(trackpre, artistpre, http.uriencode(trackpre), http.uriencode(artistpre))
		if HTTP.Get(send := EndPoint
				. "track:" . HTTP.UriEncode(trackpre)
				. "+artist:" . HTTP.UriEncode(artistpre)
				. "&type=track", Data)
			clipboard := send
		URL := JSON.Load(Data.ResponseText).tracks.items.1.external_urls.spotify
	*/
	
	SendInput % NICK " is listening to **" Title "** " URL "{Enter}"
}

ServerMove(Direction) {
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

Code(Paste := true) {
	if hwnd := WinActive("ahk_exe Discord.exe") {
		SendInput % "`````` " LANG "`n" (Paste ? "^v" : "") "`n`````` "
		sleep 20
		ControlSend, ahk_parent, % "{" (Paste ? "Enter" : "Up") "}", % "ahk_id" hwnd
	}
}

Exit() {
	ExitApp
}