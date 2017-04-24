#SingleInstance force
#MaxHotkeysPerInterval 200
#UseHook
#NoEnv
#Persistent
#NoTrayIcon
DetectHiddenWindows On
SetRegView 64
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
SetTitleMatchMode 2
OnExit, Exit

/*
todo:
console
rate limiting for imgur api (which will be impossible)	
*/

/*
[size=150]v0.9.3[/size]

[list][/list]

[size=150][url=https://github.com/Run1e/PowerPlay/releases/latest]Download[/url][/size]
[url=https://github.com/Run1e/PowerPlay]GitHub repo[/url]
[url=https://github.com/Run1e/PowerPlay/wiki]GitHub wiki[/url]
*/

/*
To update:
1. Exit PowerPlay
2. Overwrite the old executables (PowerPlay, PowerPlayUploader) with the new downloaded ones
3. Launch PowerPlay.exe again
*/

/*
	Queue manager features:
	- Delete queue items (all except running queue item!)
	- Queue errors turn red and stay around until queue manager is cleared
	- Active queue items can be cleared, or the whole queue can be cleared
	
	bugs:
	- after adding bind/game the lv isn't focused
*/

/*

*/

global NvAPI, Settings, Keybinds, AppName, AppVersion, AppVersionString, Big, Binder, GameRules, VERT_SCROLL, Actions, Images, Plugin, SetGUI, Prog, ForceConsole, Autoexec, Uploader

AppName := "Power Play"
AppVersion := [0, 9, 6]
AppVersionString := "v" AppVersion.1 "." AppVersion.2 "." AppVersion.3

ForceConsole := false

; only compiled and tested in 32-bit.
if (A_PtrSize = 8) {
	msgbox Please run this script as 32-bit.
	ExitApp
}

SetWorkingDir % A_ScriptDir
if !FileExist(A_WorkingDir "\data") {
	FileCreateDir % A_WorkingDir "\data"
	if ErrorLevel { ; failed creating subfolder
		MsgBox, 48, % AppName, Unable to create necessary subfolders.`n`nPlease run PowerPlay as administrator or in a directory where it has the rights it needs (for example C:\PowerPlay\).
		run % A_ScriptDir
		ExitApp
	}
}

if !FileExist(A_WorkingDir "\menus")
	FileCreateDir % A_WorkingDir "\menus"

pToken := Gdip_Startup()

Plugin := new Plugin
Uploader := new Uploader

Settings := JSONFile("Settings", DefaultSettings())

if NvAPI.InitFail { ; NvAPI initialization failed, no nvidia card is installed
	if !Settings.NvAPI_InitFail {
		Error("NvAPI init failed, NvAPI features disabled.", A_ThisFunc, NvAPI.InitFail = 2 ? "NvAPI initialization failed!" : "No NVIDIA graphics card found!")
		a := Func("TrayTip").Bind(NvAPI.InitFail = 2 ? "NvAPI initialization failed!" : "No NVIDIA graphics card found!", "Some features have been disabled.")
		SetTimer, % a, -4000
	} Settings.NvAPI_InitFail := NvAPI.InitFail ; NvAPI.InitFail
}
else if Settings.NvAPI_InitFail {
	Settings.Remove("NvAPI_InitFail")
	a := Func("TrayTip").Bind("NVIDIA graphics card found!", "Disabled features have been enabled.")
	SetTimer, % a, -4000
}

JSONSave("Settings", Settings)

Keybinds := JSONFile("Keybinds", DefaultKeybinds(), false)
JSONSave("Keybinds", Keybinds)

; contains game rules
GameRules := JSONFile("GameRules", DefaultGameRules(), false)
JSONSave("GameRules", GameRules)

; contains list of uploaded imgur images
Images := JSONFile("Images", {})
JSONSave("Images", Images)

; install icons
IconInstall()

; get vertical scrollbar width, used in listviews
VERT_SCROLL := SysGet(2)

/*
	DllCall("LoadLibrary", str, A_WorkingDir "\USkin.dll")
	DllCall("USkin.dll" . "\USkinInit", Int,0, Int,0, AStr, A_WorkingDir "\snas.msstyles")
*/
; milikymac
; snas
; pantherS
; relapse


; create main gui
CreateBigGUI()

; init menu from json file
CreateTrayMenu()

; apply/reenforce settings that do something external
ApplySettings()

if FileExist(Icon("icon"))
	Menu, Tray, Icon, % Icon("icon")

Menu, Tray, Tip, % AppName
Menu, Tray, Icon ; show trayicon

; detect window activations
DllCall("RegisterShellHookWindow", "ptr", A_ScriptHwnd)
OnMessage(DllCall("RegisterWindowMessage", "Str", "SHELLHOOK"), "WinActiveChange")

; bind hotkeys
Keybinds(true)

p()

Autoexec := true
return

Exit:
CtlColors.Free() ; free ctlcolors
Uploader.Free() ; close upload helper
Gdip_Shutdown(pToken) ; shut down gdip
; revoke COM objects
ObjRegisterActive(Plugin, "")
ObjRegisterActive(Uploader, "")
/*
	DllCall("USkin.dll\USkinExit")
*/
ExitApp
return ; super unnecessary return

returnlabel:
return

p(text := "") {
	static Handle, LastSpacer
	if !ForceConsole && !Settings.Debug
		return
	if !Handle
		Handle := DllCall("GetStdHandle", "UInt", (-11,DllCall("AllocConsole")), "UPtr")
	Spacer := !!InStr(text, "`n")
	FileOpen("CONOUT$", "w").Write((!LastSpacer&&Spacer?"`n":"") . text "`n" . (Spacer?"`n":""))
	LastSpacer := Spacer
	return
}

#Include lib\CheckForUpdates.ahk
#Include lib\Class Actions.ahk
#Include lib\Class BigGUI.ahk
#Include lib\Class BinderGUI.ahk
#Include lib\Class Capture.ahk
#Include lib\Class CustomImageList.ahk
#Include lib\Class AppSelectGUI.ahk
#Include lib\Class GUI.ahk
#Include lib\Class Hotkey.ahk
#Include lib\Class HTTP.ahk
#Include lib\Class Menu.ahk
#Include lib\Class MouseTip.ahk
#Include lib\Class OnMouseMove.ahk
#Include lib\Class Plugin.ahk
#Include lib\Class SettingsGUI.ahk
#Include lib\Class Uploader.ahk
#Include lib\CreateTrayMenu.ahk
#Include lib\DefaultKeybinds.ahk
#Include lib\DefaultSettings.ahk
#Include lib\DefaultGameRules.ahk
#Include lib\Error.ahk
#Include lib\Functions.ahk
#Include lib\JSONfunctions.ahk
#Include lib\Keybinds.ahk
#Include lib\MonitorSetup.ahk
#Include lib\PastebinUpload.ahk
#Include lib\WinActiveChange.ahk
#Include lib\IconInstall.ahk
#Include lib\GetActionsList.ahk
#Include lib\GetApplications.ahk
#Include lib\ApplySettings.ahk

#Include *i lib\client_id.ahk
#Include *i Custom.ahk

; thanks fams
#Include lib\third-party\Class CtlColors.ahk
#Include lib\third-party\Class ImageButton.ahk
#Include lib\third-party\Class JSON.ahk
#Include lib\third-party\Class LV_Colors.ahk
#Include lib\third-party\Class NvAPI.ahk
#Include lib\third-party\FrameShadow.ahk
#Include lib\third-party\Gdip_All.ahk
#Include lib\third-party\LV_EX.ahk
#Include lib\third-party\ObjRegisterActive.ahk
#Include lib\third-party\FileSHA1.ahk																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																		


