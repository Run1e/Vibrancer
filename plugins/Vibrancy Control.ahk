; Change vibrancy ingame with hotkeys
; RUNIE
#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1
SetKeyDelay -1

#Include %A_ScriptDir%
#Include ..\lib\plugin\BindSection.ahk
#Include ..\lib\Debug.ahk

try
	global Vib := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Vib.OnExit(Func("Exit"))

global Big := Vib.Get("Big")
global Rules := Vib.Get("Rules")
global GameRules := Vib.Get("GameRules").Object()

Binds := new BindSection(Vib, "Vibrancy Control", "VibrancyControl")
Binds.AddFunc("VibChange", Func("VibChange"))
Binds.AddBind("Increase Vibrancy", "VibChange", 2)
Binds.AddBind("Decrease Vibrancy", "VibChange", -2)
Binds.Register()

Vib.Finished()
return

VibChange(Diff) {
	if (Rules.Process = "")
		return
	Prev := GameRules[Rules.Process].Vibrancy
	Vibrance := Prev + Diff
	Vibrance := Vibrance > 100 ? 100 : (Vibrance < 50 ? 50 : Vibrance)
	if (Prev = Vibrance)
		return
	GameRules[Rules.Process].Vibrancy := Vibrance
	Rules.VibSelected(Vibrance)
	if Big.IsVisible && (Big.GameLV.GetText(Big.GameLV.GetNext(), 2) = Rules.Process)
		Big.SetText(Big.VibrancySliderHWND, Vibrance)
	if (Vibrance = 50) || (Vibrance = 100)
		SoundBeep
}

Exit() {
	ExitApp
}

s(text := "") {
	static oVoice := ComObjCreate("SAPI.SpVoice")
	oVoice.Speak(text, 1)
}