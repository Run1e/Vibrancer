PowerPlay() {
	try 
		Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
	catch e
		return false
	Power.AutoClose(A_ScriptHwnd)
	return Power
}