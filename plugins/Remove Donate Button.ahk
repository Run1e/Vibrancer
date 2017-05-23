#SingleInstance force
#NoEnv
#NoTrayIcon

Power:=ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
Power.Get("Tray").Delete("Donate")
Power.Finished()
ExitApp