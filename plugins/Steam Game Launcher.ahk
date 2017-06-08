; Launch Steam games through the tray menu
; RUNIE
#SingleInstance force
#NoEnv
#NoTrayIcon
SetRegView 64
SetBatchLines -1

#Include %A_ScriptDir%
#Include ..\lib\Functions.ahk
#Include ..\lib\GetApplications.ahk
#Include ..\lib\Debug.ahk

try
	Vib := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Menu := Vib.CreateMenu("Steam games")

for Index, Info in GetSteamGames()
	Menu.Add(Info.DisplayName, Vib.Func("Run").Bind(Info.Run), Info.DisplayIcon)

if (Menu.GetCount() < 1) ; empty menu
	Menu.Add("No games found")

Vib.TrayAdd(Menu,, GetSteamDir() "\Steam.exe")
Vib.Finished()
ExitApp