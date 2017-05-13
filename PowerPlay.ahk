#SingleInstance force
#MaxHotkeysPerInterval 200
#UseHook
#NoEnv
#Persistent
#NoTrayIcon
DetectHiddenWindows On
SetRegView 64
SetWinDelay -1
SetKeyDelay -1
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
SetTitleMatchMode 2
SetWorkingDir % A_ScriptDir
OnExit("Exit")

QPC(true)

; only compiled and tested in 32-bit.
if (A_PtrSize = 8) {
	msgbox Please run this script as 32-bit.
	ExitApp
}

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
2. Overwrite the old executable (PowerPlay)
3. Launch PowerPlay
*/

/*
	bugs:
	- after adding bind/game the lv isn't focused
*/

/*
- Lowered gifperiod to 3fps
Reported by noname:
- Fixed case where JSON arrays didn't start off as objects
*/

global AppName, AppVersion, AppVersionString ; app info
global Big, Binder, Settings, Prog, SetGUI ; GUI
global Settings, Keybinds, GameRules, Images ; JSON
global Actions, Plugin, Uploader, Tray ; objects
global VERT_SCROLL, ForceConsole, AutoExec, pToken ; other

ForceConsole := false

AppName := "Power Play"
AppVersion := [0, 9, 73]
AppVersionString := "v" AppVersion.1 "." AppVersion.2 "." AppVersion.3

; make necessary sub-folders
MakeFolders()

; if compiled, install necessary files
if A_IsCompiled
	InstallFiles()

pToken := Gdip_Startup()

; contains user settings
Settings := new JSONFile("data\Settings.json")
Settings.Fill(DefaultSettings()) ; fill missing keys

; contains keybind information
Keybinds := new JSONFile("data\Keybinds.json")
if !Keybinds.FileExist()
	Keybinds.Fill(DefaultKeybinds())

; contains game rules
GameRules := new JSONFile("data\GameRules.json")
if !GameRules.FileExist()
	Keybinds.Fill(DefaultGameRules())

; contains list of uploaded imgur images
Images := new JSONFile("data\Images.json")

Uploader := new Uploader
Plugin := new Plugin

; init nvidia api wrapper
InitNvAPI()

; get vertical scrollbar width, used in listviews
VERT_SCROLL := SysGet(2)

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

if IsFunc("Custom")
	Custom()

p("Startup time: " QPC(false) "s")

Autoexec := true
return

#Include lib\ApplySettings.ahk
#Include lib\CheckForUpdates.ahk
#Include lib\Class Actions.ahk
#Include lib\Class AppSelectGUI.ahk
#Include lib\Class BigGUI.ahk
#Include lib\Class BinderGUI.ahk
#Include lib\Class Capture.ahk
#Include lib\Class CustomImageList.ahk
#Include lib\Class GUI.ahk
#Include lib\Class Hotkey.ahk
#Include lib\Class HTTP.ahk
#Include lib\Class JSONFile.ahk
#Include lib\Class Menu.ahk
#Include lib\Class MouseTip.ahk
#Include lib\Class OnMouseMove.ahk
#Include lib\Class Plugin.ahk
#Include lib\Class SettingsGUI.ahk
#Include lib\Class Tray.ahk
#Include lib\Class Uploader.ahk
#Include lib\CreateTrayMenu.ahk
#Include lib\DefaultGameRules.ahk
#Include lib\DefaultKeybinds.ahk
#Include lib\DefaultSettings.ahk
#Include lib\Error.ahk
#Include lib\Exit.ahk
#Include lib\Functions.ahk
#Include lib\GetActionsList.ahk
#Include lib\GetApplications.ahk
#Include lib\InitNvAPI.ahk
#Include lib\InstallFiles.ahk
#Include lib\Keybinds.ahk
#Include lib\MakeFolders.ahk
#Include lib\MonitorSetup.ahk
#Include lib\PastebinUpload.ahk
#Include lib\WinActiveChange.ahk

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
#Include lib\third-party\SetCueBanner.ahk
#Include lib\third-party\WinGetPosEx.ahk
