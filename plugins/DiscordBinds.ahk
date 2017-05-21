#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1
SetKeyDelay -1

#Include %A_ScriptDir%
#Include ..\lib\Class Hotkey.ahk
#Include ..\lib\Debug.ahk

global NICK

if (A_ComputerName = "DESKTOP-AAVK743")
	NICK := "<@265644569784221696>"
else
	NICK := "your username here"

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
	WinGetTitle, Song, ahk_exe Spotify.exe
	if !WinActive("ahk_exe Discord.exe") || !StrLen(Song)
		return
	SendInput % NICK " is playing **" Song "**{Enter}"
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
		SendInput % "`````` " "AutoHotkey`n" (Paste ? "^v" : "") "`n`````` "
		sleep 20
		ControlSend, ahk_parent, % "{" (Paste ? "Enter" : "Up") "}", % "ahk_id" hwnd
	}
}

Exit() {
	ExitApp
}