; Add a CS:GO shortcut to tray menu
; RUNIE
#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1

#Include %A_ScriptDir%
#Include ..\lib\Functions.ahk
#Include ..\lib\Debug.ahk

RegRead, SteamUninstall, HKLM, SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam, DisplayIcon
SplitPath, SteamUninstall,, SteamDir

; === CONFIGURATION ===
CSGO_DIR := SteamDir "\steamapps\common\Counter-Strike Global Offensive"
CSGO_CFG := CSGO_DIR "\csgo\cfg\cfg.cfg"
CSGO_EXE := CSGO_DIR "\csgo.exe"
CSGO_LAUNCH := "steam://rungameid/730"
; === END ===

Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
Power.TrayAdd("Edit CS:GO Config", Power.Func("Run").Bind(CSGO_CFG), Power.Call("Icon", "file"))
Power.TrayAdd("Launch CS:GO", Power.Func("Run").Bind(CSGO_LAUNCH), CSGO_EXE)
Power.Finished()
ExitApp