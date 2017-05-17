#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1
OnExit, Exit
#Include pluginlib\PowerPlay.ahk

#Include ..\lib\Class OnMouseMove.ahk
#Include ..\lib\Class MouseTip.ahk

Duration := 1000
TrayTipMsg := true
UploaderTipMsg := true
DisableTrayTips := false

global Power, Listener, Duration

if !Power := PowerPlay()
	ExitApp

Listener := new Power.EventListener(Power)

if TrayTipMsg
	Listener.Listen("TrayTip", Func("OnTrayTip"), DisableTrayTips)

if UploaderTipMsg
	Listener.Listen("UploaderStatusText", Func("OnUploaderStatusText"))

Power.Finished()
return

Exit:
ExitApp

/*
	---------------------------
	ClipMessages.ahk
	---------------------------
	Error:  0x80010108 - The object invoked has disconnected from its clients.
	
	Specifically: __Delete
	
	Line#
	020: ExitApp
	022: Listener := new Power.EventListener(Power)
	024: if TrayTipMsg  
	025: Listener.Listen("TrayTip", Func("OnTrayTip"), DisableTrayTips)  
	027: if UploaderTipMsg  
	028: Listener.Listen("UploaderStatusText", Func("OnUploaderStatusText"))  
	030: Power.Finished()  
	--->	031: Return
	033: {
		034: MouseTip.Create(Msg, Duration)  
		035: }
		037: {
			038: MouseTip.Create(Status, Duration)  
			039: }
			040: Exit
			
			Continue running the script?
			---------------------------
			Yes   No   
			---------------------------
			
*/

OnTrayTip(Title, Msg) {
	MouseTip.Create(Msg, Duration)
}

OnUploaderStatusText(Status) {
	MouseTip.Create(Status, Duration)
}