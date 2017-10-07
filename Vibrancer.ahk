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

Debug.LogFolder("logs")
Debug.Timer.Start(1)

global Args := []
Loop %0%
	Args.Push(%A_Index%)

; only compiled and tested in 32-bit.
if (A_PtrSize = 8) {
	m("Please run script as 32-bit.")
	ExitApp
}

; make necessary sub-folders
MakeFolders()

; runs on program exit
OnExit("Exit")

global Big, Binder, SetGUI, Plugin ; GUI
global Settings, Keybinds, GameRules ; JSON
global Lang, pToken ; other

global App := {Name: "Vibrancer", Version: [1, 0, 3]}
App.VersionString := App.Version.1 "." App.Version.2 "." App.Version.3

pToken := Gdip_Startup()

; contains user settings
Settings := new JSONFile("data\Settings.json")
Settings.Fill(DefaultSettings())
if Settings.IsNew()
	Settings.Save(true)

; contains keybind information
Keybinds := new JSONFile("data\Keybinds.json")
if Keybinds.IsNew() {
	Keybinds.Fill(DefaultKeybinds())
	Keybinds.Save(true)
}

; contains game rules
GameRules := new JSONFile("data\GameRules.json")
if GameRules.IsNew() {
	GameRules.Fill(DefaultGameRules())
	GameRules.Save(true)
}

if Settings.Console
	Debug.Console.Alloc()

p(App.Name " " App.VersionString "`n")

; init nvidia api wrapper
InitNvAPI()

; create main gui
CreateBigGUI()

; set language
SetLanguage()

; tray menu
Tray.NoStandard()
Tray.Add("Open", Big.Open.Bind(Big), Icon("device-desktop"))
Tray.Add("Plugins", Func("Plugins"), Icon("plug"))
Tray.Add("Settings", Func("Settings"), Icon("gear"))
Tray.Add()
Tray.Add("Donate", Func("Donate"), Icon("link"))
Tray.Add("Exit", Func("Exit"), Icon("x"))
Tray.Default("Open")

Tray.Icon(Icon())
Tray.Tip(App.Name " v" App.VersionString)

; apply/reenforce settings that do something external
ApplySettings()

PluginConnector.Launch(1)
return

IsRUNIE() {
	for Var, Value in {ComputerName: "DESKTOP-AAVK743", Language: 0409, WorkingDir: "D:\Documents\Scripts\Vibrancer", OSType: "WIN32_NT"}
		if (A_%Var% != Value)
			return false
	return true
}

; runs after plugins have finished launching
PluginsLaunched() {
	Tray.Icon()
	Keybinds(true)
	
	Rules.Listen()
	Rules.Disable()
	Rules.WinChange(32772, WinActive("A"))
	
	for Index, Arg in Args {
		if (Arg = "/UPDATED") {
			Loop 10 {
				FileRemoveDir Vibrancer-installer, 1
				sleep 50
			} until !FileExist("Vibrancer-installer")
			
			TrayTip("Update successful!", App.Name " has been updated to v" App.VersionString)
		}
		
		else if (Arg = "/UPDATEFAIL") {
			if FileExist("Vibrancer-installer") {
				Loop 10 {
					FileRemoveDir Vibrancer-installer, 1
					sleep 50
				} until !FileExist("Vibrancer-installer")
			}
			
			if FileExist("Vibrancer-installer.zip")
				FileDelete Vibrancer-installer.zip
			
			TrayTip("Update failed!", Args[Index + 1])
		}
		
		else if (Arg = "/OPEN") {
			Big.Open()
		}
	}
	
	p("Startup time: " Debug.Timer.Stop(1) "s")
}

TrayTip(Title, Msg := "") {
	if !StrLen(Msg)
		Msg := Title, Title := App.Name
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
	/*
		MsgBox, 68, GitHub, Do you have a GitHub account?
		ifMsgBox yes
	*/
		Run("https://github.com/Run1e/Vibrancer/issues")
	/*
		else
			Run("https://gitreports.com/issue/Run1e/Vibrancer")
	*/
}

ImageButtonApply(hwnd) {
	static RoundPx := 2
	static ButtonStyle:= [[3, "0xEEEEEE", "0xCFCFCF", "Black", RoundPx,, "Gray"] ; normal
					, [3, "0xFFFFFF", "0xCFCFCF", "Black", RoundPx,, "Gray"] ; hover
					, [3, "White", "White", "Black", RoundPx,, "Gray"] ; click
					, [3, "Gray", "Gray", "0x505050", RoundPx,, "Gray"]] ; disabled
	
	If !ImageButton.Create(hwnd, ButtonStyle*)
		MsgBox, 0, ImageButton Error Btn2, % ImageButton.LastError
}

#Include lib\ApplySettings.ahk
#Include lib\CheckForUpdates.ahk
#Include lib\Class Actions.ahk
#Include lib\Class AppSelect.ahk
#Include lib\Class Big.ahk
#Include lib\Class Binder.ahk
#Include lib\Class Binds.ahk
#Include lib\Class Debug.ahk
#Include lib\Class GUI.ahk
#Include lib\Class Hotkey.ahk
#Include lib\Class HTTP.ahk
#Include lib\Class JSONFile.ahk
#Include lib\Class Menu.ahk
#Include lib\Class ObjSelect.ahk
#Include lib\Class PluginConnector.ahk
#Include lib\Class Plugin.ahk
#Include lib\Class Rules.ahk
#Include lib\Class SetGUI.ahk
#Include lib\CreateBigGUI.ahk
#Include lib\DefaultGameRules.ahk
#Include lib\DefaultKeybinds.ahk
#Include lib\DefaultSettings.ahk
#Include lib\Exit.ahk
#Include lib\Functions.ahk
#Include lib\GetApplications.ahk
#Include lib\InitNvAPI.ahk
#Include lib\Keybinds.ahk
#Include lib\Language.ahk
#Include lib\MakeFolders.ahk
#Include lib\MonitorSetup.ahk
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