; Remove 'Donate' button from tray menu
; RUNIE
#NoTrayIcon
try
	Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp
Power.Get("Tray").Delete("Donate")
Power.Finished()
ExitApp