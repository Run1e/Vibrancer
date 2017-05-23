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

; has to elevate itself to admin so it can create folders/files when installed in program files
if !A_IsAdmin && A_IsCompiled {
	Loop %0%
		pToken .= (InStr(%A_Index%, " ") ? """" : "") . %A_Index% . (InStr(%A_Index%, " ") ? """" : "")
	Run *RunAs "%A_ScriptFullPath% " %pToken%
	ExitApp
}

; only compiled and tested in 32-bit.
if (A_PtrSize = 8) {
	msgbox Please run this script as 32-bit.
	ExitApp
}

global AppName, AppVersion, AppVersionString ; app info
global Big, Binder, Settings, Prog, SetGUI ; GUI
global Settings, Keybinds, GameRules, Images ; JSON
global Actions, Plug, Uploader, Tray ; objects
global VERT_SCROLL, pToken ; other

AppName := "Power Play"
AppVersion := [0, 9, 82]
AppVersionString := "v" AppVersion.1 "." AppVersion.2 "." AppVersion.3

; make necessary sub-folders
MakeFolders()

pToken := Gdip_Startup()

; contains user settings
Settings := new JSONFile("data\Settings.json")
Settings.Fill(DefaultSettings())
if !Settings.FileExist()
	Settings.Save()

; contains keybind information
Keybinds := new JSONFile("data\Keybinds.json")
if !Keybinds.FileExist()
	Keybinds.Fill(DefaultKeybinds()), Keybinds.Save()

; contains game rules
GameRules := new JSONFile("data\GameRules.json")
if !GameRules.FileExist()
	GameRules.Fill(DefaultGameRules()), GameRules.Save()

; contains list of uploaded imgur images
Images := new JSONFile("data\Images.json")
if !Images.FileExist()
	Images.Save()

Uploader := new Uploader
Plugin := new Plugin

; init nvidia api wrapper
InitNvAPI()

; get vertical scrollbar width, used in listviews
VERT_SCROLL := SysGet(2)

; create main gui
CreateBigGUI()

; init menu from json file
Tray := new Tray
Tray.Add("Open", Actions.Open.Bind(Actions), Icon("device-desktop"))
Tray.Add("Plugins", Actions.Plugins.Bind(Actions), Icon("plug"))
Tray.Add("Settings", Actions.Settings.Bind(Actions), Icon("gear"))
Tray.Add()
Tray.Add("Donate", Actions.Donate.Bind(Actions), Icon("link"))
Tray.Add("Exit", Actions.Exit.Bind(Actions), Icon("x"))
Tray.SetDefault("Open")

; apply/reenforce settings that do something external
ApplySettings()

if FileExist(Icon("icon"))
	Menu, Tray, Icon, % Icon("icon")

Menu, Tray, Tip, % AppName
Menu, Tray, Icon ; show trayicon

; detect window activations
DllCall("RegisterShellHookWindow", "ptr", Big.hwnd)
OnMessage(DllCall("RegisterWindowMessage", "Str", "SHELLHOOK"), "WinActiveChange")

WinActiveChange(32772, WinActive("A"))

; bind hotkeys
Keybinds(true)

Plugin.Launch(1)

Loop %0%
{
	if (%A_Index% = "/UPDATED") {
		Settings.Delete("UpdateVersion")
		FileRemoveDir PowerPlay-installer, 1
		FileDelete PowerPlay-installer.zip
		TrayTip("Update successful!", "Power Play has been updated to " AppVersionString)
	}
	
	else if (%A_Index% = "/OPEN")
		Big.Open()
}

return

Print(text := "") {
	Event("Print", IsObject(text)?pa(text):text)
}

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
#Include lib\Class PluginGUI.ahk
#Include lib\Class SettingsGUI.ahk
#Include lib\Class Uploader.ahk
#Include lib\Debug.ahk
#Include lib\DefaultGameRules.ahk
#Include lib\DefaultKeybinds.ahk
#Include lib\DefaultSettings.ahk
#Include lib\Error.ahk
#Include lib\Exit.ahk
#Include lib\Functions.ahk
#Include lib\GetActionsList.ahk
#Include lib\GetApplications.ahk
#Include lib\InitNvAPI.ahk
#Include lib\Keybinds.ahk
#Include lib\MakeFolders.ahk
#Include lib\MonitorSetup.ahk
#Include lib\PastebinUpload.ahk
#Include lib\Update.ahk
#Include lib\WinActiveChange.ahk

#Include *i lib\client_id.ahk

; thanks fams
#Include lib\third-party\Class CtlColors.ahk
#Include lib\third-party\Class ImageButton.ahk
#Include lib\third-party\Class JSON.ahk
#Include lib\third-party\Class LV_Colors.ahk
#Include lib\third-party\Class NvAPI.ahk
#Include lib\third-party\FileSHA1.ahk
#Include lib\third-party\FrameShadow.ahk
#Include lib\third-party\Gdip_All.ahk
#Include lib\third-party\LV_EX.ahk
#Include lib\third-party\ObjRegisterActive.ahk
#Include lib\third-party\SetCueBanner.ahk
#Include lib\third-party\WinGetPosEx.ahk