#NoEnv
#SingleInstance force

cd := "Vibrancer"

Files := 	[ "LICENSE.txt"
		, "msvcr100.dll"
		, "Vibrancer.ahk"
		, "Vibrancer.exe"
		, "plugins\Imgur Uploader.ahk"
		, "plugins\Pastebin Upload.ahk"
		, "plugins\Remove Donate Button.ahk"
		, "plugins\Steam Game Launcher.ahk"
		, "plugins\Vibrancy Control.ahk"
		, "plugins\Window Switcher.ahk"]

Dirs := 	[ "lib"
		, "icons"
		, "language"
		, "plugins\imgurlib"]

FileRemoveDir, % cd, 1
FileCreateDir % cd

for index, dir in Dirs {
	p("Copying dir: " dir)
	FileCopyDir, % dir, % cd "\" dir
	if !FileExist(cd "\" dir)
		Error("Failed copying dir: " dir)
}

for index, file in Files {
	p("Copying file: " file)
	FileCopy, % file, % cd "\" file
	if !FileExist(cd "\" file)
		Error("Failed copying file: " file)
}

/*
	ahk2exe := "C:\Program Files (x86)\AutoHotkey_H\Compiler\Ahk2Exe.ahk"
	bin := "C:\Program Files (x86)\AutoHotkey_H\Win32w\AutoHotkeySC.bin"
	icon := "D:\Documents\Scripts\Vibrancer\icons\vibrancer.ico"
	
	in := "D:\Documents\Scripts\Vibrancer\Vibrancer.ahk"
	out := "D:\Documents\Scripts\Vibrancer\Vibrancer\Vibrancer.exe"
	
	p(), p("Compiling")
	
	RunWait, %ahk2exe% /in "%in%" /out "%out%" /icon "%icon%" /bin "%bin%"
	if !FileExist(out)
		Error("Failed compiling, target does not exist: " out)
*/

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