#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1

#Include pluginlib\EventListener.ahk

#Include ..\lib\Class OnMouseMove.ahk
#Include ..\lib\Class MouseTip.ahk

Duration := 1000
TrayTipMsg := true
UploaderTipMsg := true
DisableTrayTips := false

global Power, Listener, Duration

Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
Power.OnExit(Func("Exit"))

Listener := new EventListener(Power)

if TrayTipMsg
	Listener.Listen("TrayTip", Func("OnTrayTip"), DisableTrayTips)

if UploaderTipMsg
	Listener.Listen("UploaderStatusText", Func("OnUploaderStatusText"))

Power.Finished()
return

Exit() {
	ExitApp
}

OnTrayTip(Title, Msg) {
	MouseTip.Create(Msg, Duration)
}

OnUploaderStatusText(Status) {
	MouseTip.Create(Status, Duration)
}