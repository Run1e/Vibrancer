; Show a MouseTip on clipboard change
; RUNIE
#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1

#Include %A_ScriptDir%
#Include ..\lib\Class OnMouseMove.ahk
#Include ..\lib\Class MouseTip.ahk

global MaxLen := 30
global MaxLines := 4

try
	Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Power.OnExit(Func("Exit"))

OnClipboardChange("ClipTip")
Power.Finished()
return

ClipTip() {
	for Index, Line in (Split := StrSplit(Clipboard, "`r`n")), Added := 1
		if (Added <= MaxLines) && StrLen(Line)
			Tip .= SubStr(Line, 1, MaxLen) . (StrLen(Line) > MaxLen ? "..." : "") . "`n", Added++, LastAdd := Index
	MouseTip.Create(rtrim(Tip, "`n") . (Split.MaxIndex() > LastAdd ? "`n..." : ""))
}

Exit() {
	ExitApp
}