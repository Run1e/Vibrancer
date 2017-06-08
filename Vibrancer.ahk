#NoTrayIcon
#SingleInstance force
#MaxHotkeysPerInterval 200
#UseHook
#Persistent
#WarnContinuableException Off
DetectHiddenWindows On
SetRegView 64
SetWinDelay -1
SetKeyDelay -1
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
SetTitleMatchMode 2
SetWorkingDir % A_ScriptDir

; has to elevate itself to admin so it can create folders/files when installed in program files
if !A_IsAdmin && A_IsCompiled {
	Loop %0%
		pToken .= " " . (InStr(%A_Index%, " ") ? """" : "") . %A_Index% . (InStr(%A_Index%, " ") ? """" : "")
	Run *RunAs "%A_ScriptFullPath%" %pToken%
	ExitApp
}

global Args := []
Loop %0%
	Args.Push(%A_Index%)

; only compiled and tested in 32-bit.
if (A_PtrSize=8) {
	m("Please run script as 32-bit.")
	ExitApp
	return
}

OnExit("Exit")

global AppName, AppVersion, AppVersionString ; app info
global Big, Binder, Settings, Prog, SetGUI ; GUI
global Settings, Keybinds, GameRules ; JSON
global Actions, Plug, Uploader, Tray, Binds ; objects
global VERT_SCROLL, pToken ; other

AppName := "Vibrancer"
AppVersion := [0, 9, 91]
AppVersionString := "v" AppVersion.1 "." AppVersion.2 "." AppVersion.3

; make necessary sub-folders
MakeFolders()

pToken := Gdip_Startup()

; contains user settings
Settings := new JSONFile("data\Settings.json")
Settings.Fill(DefaultSettings()), Settings.Save()

; contains keybind information
Keybinds := new JSONFile("data\Keybinds.json")
if !Keybinds.FileExist()
	Keybinds.Fill(DefaultKeybinds()), Keybinds.Save()

; contains game rules
GameRules := new JSONFile("data\GameRules.json")
if !GameRules.FileExist()
	GameRules.Fill(DefaultGameRules()), GameRules.Save()

Plugin := new Plugin

; init nvidia api wrapper
InitNvAPI()

; get vertical scrollbar width, used in listviews
VERT_SCROLL := SysGet(2)

; create main gui
CreateBigGUI()

; tray menu
Tray.NoStandard()
Tray.Add("Open", Big.Open.Bind(Big), Icon("device-desktop"))
Tray.Add("Plugins", Func("Plugins"), Icon("plug"))
Tray.Add("Settings", Func("Settings"), Icon("gear"))
Tray.Add()
Tray.Add("Donate", Func("Donate"), Icon("link"))
Tray.Add("Exit", Func("Exit"), Icon("x"))
Tray.Default("Open")

if FileExist(Icon())
	Tray.Icon(Icon())

Tray.Tip(AppName " " AppVersionString)
Tray.Icon()

; apply/reenforce settings that do something external
ApplySettings()

Plugin.Launch(1)
return

; runs after plugins have finished launching
PluginsLaunched() {
	
	for Index, Arg in Args {
		
		if (Arg = "/UPDATED") {
			FileDelete Vibrancer-installer\Vibrancer-installer.exe
			FileRemoveDir Vibrancer-installer, 1
			
			TrayTip("Update successful!", AppName " has been updated to " AppVersionString)
		}
		
		else if (Arg = "/OPEN") { ; run imgur uploader on users first launch
			Big.Open()
		}
	}
	
	DllCall("RegisterShellHookWindow", "ptr", Big.hwnd)
	OnMessage(DllCall("RegisterWindowMessage", "Str", "SHELLHOOK"), Rules.WinChange.Bind(Rules))
	Rules.WinChange(32772, WinActive("A"))
	
	Keybinds(true)
}

TrayTip(Title, Msg := "") {
	if !StrLen(Msg)
		Msg := Title, Title := AppName " " AppVersionString
	TrayTip, % Title, % Msg
}

reload() {
	Exit(false)
	reload
}

Donate() {
	Run("https://www.paypal.me/RUNIE")
}

Icon(name := "") {
	if (name = "")
		return A_WorkingDir . "\icons\vibrancer.ico"
	return A_WorkingDir . "\icons\octicons\" name ".ico"
}

BugReport() {
	MsgBox, 68, GitHub, Do you have a GitHub account?
	ifMsgBox yes
		Run("https://github.com/Run1e/Vibrancer/issues")
	else
		Run("https://gitreports.com/issue/Run1e/Vibrancer")
}

Print(text := "") {
	Event("Print", IsObject(text) ? pa(text) : text)
}

ImageButtonApply(hwnd) {
	static RoundPx := 2
	static ButtonStyle:= [[3, "0xEEEEEE", "0xDDDDDD", "Black", RoundPx,, "Gray"] ; normal
					, [3, "0xFFFFFF", "0xDDDDDD", "Black", RoundPx,, "Gray"] ; hover
					, [3, "White", "White", "Black", RoundPx,, "Gray"] ; click
					, [3, "Gray", "Gray", "0x505050", RoundPx,, "Gray"]] ; disabled
	
	If !ImageButton.Create(hwnd, ButtonStyle*)
		MsgBox, 0, ImageButton Error Btn2, % ImageButton.LastError
}

#Include lib\ApplySettings.ahk
#Include lib\CheckForUpdates.ahk
#Include lib\Class Actions.ahk
#Include lib\Class AppSelectGUI.ahk
#Include lib\Class BigGUI.ahk
#Include lib\Class BinderGUI.ahk
#Include lib\Class Binds.ahk
#Include lib\Class GUI.ahk
#Include lib\Class Hotkey.ahk
#Include lib\Class HTTP.ahk
#Include lib\Class JSONFile.ahk
#Include lib\Class Menu.ahk
#Include lib\Class Plugin.ahk
#Include lib\Class PluginGUI.ahk
#Include lib\Class Rules.ahk
#Include lib\Class SettingsGUI.ahk
#Include lib\CreateBigGUI.ahk
#Include lib\Debug.ahk
#Include lib\DefaultGameRules.ahk
#Include lib\DefaultKeybinds.ahk
#Include lib\DefaultSettings.ahk
#Include lib\Error.ahk
#Include lib\Exit.ahk
#Include lib\Functions.ahk
#Include lib\GetApplications.ahk
#Include lib\InitNvAPI.ahk
#Include lib\Keybinds.ahk
#Include lib\MakeFolders.ahk
#Include lib\MonitorSetup.ahk
#Include lib\PastebinUpload.ahk
#Include lib\Update.ahk


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