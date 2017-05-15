#NoEnv
#NoTrayIcon
SetRegView 64
SetBatchLines -1

#Include ..\lib\Functions.ahk
#Include ..\lib\GetApplications.ahk

Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
Menu := Power.CreateMenu("Steam games")
for Index, Info in GetSteamGames()
	Menu.Add(Info.DisplayName, Power.Func("Run").Bind(Info.Run), Info.DisplayIcon)
Power.TrayAdd(Menu,, GetSteamDir() "\Steam.exe")
Power.Finished()
ExitApp