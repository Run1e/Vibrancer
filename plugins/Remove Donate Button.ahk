; Remove 'Donate' button from tray menu
; RUNIE
#NoTrayIcon
try
	Vib := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp
Vib.Get("Tray").Delete("Donate")
Vib.Finished()
ExitApp