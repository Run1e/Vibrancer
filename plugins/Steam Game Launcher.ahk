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
	Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Menu := Power.CreateMenu("Steam games")

for Index, Info in GetSteamGames()
	Menu.Add(Info.DisplayName, Power.Func("Run").Bind(Info.Run), Info.DisplayIcon)

if (Menu.GetCount() < 1) ; empty menu
	Menu.Add("No games found")

Power.TrayAdd(Menu,, GetSteamDir() "\Steam.exe")
Power.Finished()
ExitApp