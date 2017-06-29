#NoEnv
#SingleInstance force

cd := "Vibrancer"

Plugins := ["Imgur Uploader"
		, "Pastebin Upload"
		, "Remove Donate Button"
		, "Steam Game Launcher"
		, "Vibrancy Control"
		, "Window Switcher"]

Libs :=	[ "Class GUI"
		, "Class Hotkey"
		, "Class HTTP"
		, "Class JSONFile"
		, "Class Menu"
		, "Debug"
		, "Error"
		, "Functions"
		, "GetApplications"
		, "MonitorSetup"]

Files := 	[ "LICENSE.txt"
		, "msvcr100.dll"
		, "lib\AutoHotkey.dll"
		, "lib\AutoHotkey.exe"]

Dirs := 	[ "icons"
		, "lib\third-party"
		, "lib\plugin"
		, "plugins\imgurlib"]

FileRemoveDir, % cd, 1

FileCreateDir % cd
FileCreateDir % cd "\lib"

FileCopy, msvcr100.dll, % cd "\lib\msvcr100.dll"
if !FileExist(cd "\lib\msvcr100.dll")
	Error("Failed copying msvcr100.dll")

for index, dir in Dirs {
	p("Copying dir: " dir)
	FileCopyDir, % dir, % cd "\" dir
	if !FileExist(cd "\" dir)
		Error("Failed copying dir: " dir)
}

for index, lib in Libs {
	p("Copying lib: lib\" lib ".ahk")
	FileCopy, % "lib\" lib ".ahk", % cd "\lib\" lib ".ahk"
	if !FileExist(cd "\lib\" lib ".ahk")
		Error("Failed copying lib fail: " lib ".ahk")
}

for index, file in Files {
	p("Copying file: " file)
	FileCopy, % file, % cd "\" file
	if !FileExist(cd "\" file)
		Error("Failed copying file: " file)
}

for index, plug in Plugins {
	p("Copying plugin: " plug ".ahk")
	FileCopy, % "plugins\" plug ".ahk", % cd "\plugins\" plug ".ahk"
	if !FileExist(cd "\plugins\" plug ".ahk")
		Error("Failed copying plugin: " plug ".ahk")
}

ahk2exe := "C:\Program Files (x86)\AutoHotkey_H\Compiler\Ahk2Exe.ahk"
bin := "C:\Program Files (x86)\AutoHotkey_H\Win32w\AutoHotkeySC.bin"
icon := "D:\Documents\Scripts\Vibrancer\icons\vibrancer.ico"

in := "D:\Documents\Scripts\Vibrancer\Vibrancer.ahk"
out := "D:\Documents\Scripts\Vibrancer\Vibrancer\Vibrancer.exe"

p(), p("Compiling")

RunWait, %ahk2exe% /in "%in%" /out "%out%" /icon "%icon%" /bin "%bin%"
if !FileExist(out)
	Error("Failed compiling, target does not exist: " out)
p("Finished!")
sleep 500
ExitApp

Error(text := "") {
	msgbox % text
	ExitApp
}

p(x := "") {
	static _:=DllCall("AllocConsole")
	FileOpen("CONOUT$", "w").Write(x "`n")
}