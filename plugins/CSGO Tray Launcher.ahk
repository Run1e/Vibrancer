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

Vib := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
Vib.TrayAdd("Edit CS:GO Config", Vib.Func("Run").Bind(CSGO_CFG), Vib.Call("Icon", "file"))
Vib.TrayAdd("Launch CS:GO", Vib.Func("Run").Bind(CSGO_LAUNCH), CSGO_EXE)
Vib.Finished()
ExitApp