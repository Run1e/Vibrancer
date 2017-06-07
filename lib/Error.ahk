Error(Message, What, Extra := "", Announce := false, Fatal := false, CustomFolder := "") {
	static LogsFolder := "logs"
	
	if (CustomFolder != "")
		return LogsFolder := CustomFolder
	
	error := Exception(Message, What, Extra)
	
	DateForm := "A " (fatal?"lethal":"non-lethal") " error occured at " . A_Hour ":" A_Min ":" A_Sec " (" A_DD "/" A_MM "/" A_YYYY ")"
	
	ErrorForm := 	"Description: " error.Message 
				. "`nLocation: " error.What 
				. "`nExtra:`n`n" error.Extra
	
	if !FileExist(A_WorkingDir "\" LogsFolder)
		FileCreateDir % A_WorkingDir "\" LogsFolder
	
	FileAppend, % DateForm . "`n`n" . ErrorForm, % A_WorkingDir "\" LogsFolder "\" A_Now A_MSec ".txt"
	
	if Fatal {
		MsgBox,262192,ERROR,% "A fatal error has occured and " AppName " must close.`n`nAn error log has been written to the logs folder.`n`nSpecifically:`n" ErrorForm,5
		ExitApp
	} if Announce
		m("AN ERROR OCCURED:`n`n" ErrorForm)
}

ErrorEx(Exception, Announce := false, Fatal := false) {
	Error(Exception.Message, Exception.What, Exception.Extra, Announce, Fatal)
}