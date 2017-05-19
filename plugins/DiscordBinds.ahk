#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1

#Include %A_ScriptDir%
#Include ..\lib\Class Hotkey.ahk
#Include ..\lib\Debug.ahk

Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
Power.OnExit(Func("Exit"))

new Hotkey("~F2", Func("DiscordCode"))
new Hotkey("~*XButton1", Func("DiscordMove").Bind("Down"))
new Hotkey("~*XButton2", Func("DiscordMove").Bind("Up"))

Power.Finished()
return

DiscordMove(Direction, Channel := false) {
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

DiscordCode() {
	if WinActive("ahk_exe Discord.exe")
		SendInput % "`````` " "AutoHotkey`n^v`n`````` "
}

Exit() {
	ExitApp
}