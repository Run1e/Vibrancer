#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1

#Include pluginlib\PowerPlay.ahk

#Include ..\lib\Class OnMouseMove.ahk
#Include ..\lib\Class MouseTip.ahk

global MaxLen := 30
global MaxLines := 4

if !Power := PowerPlay()
	ExitApp

OnClipboardChange("ClipTip")
Power.Finished()
return

ClipTip() {
	for Index, Line in (Split := StrSplit(Clipboard, "`r`n")), Added := 1
		if (Added <= MaxLines) && StrLen(Line)
			Tip .= SubStr(Line, 1, MaxLen) . (StrLen(Line) > MaxLen ? "..." : "") . "`n", Added++, LastAdd := Index
	MouseTip.Create(rtrim(Tip, "`n") . (Split.MaxIndex() > LastAdd ? "`n..." : ""))
}