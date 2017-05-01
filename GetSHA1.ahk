#Include lib\third-party\FileSHA1.ahk

clipboard := "uploader: " FileSHA1(A_ScriptDir "\PowerPlayUploader.exe") "`nicon: " FileSHA1(A_ScriptDir "\icons\powerplay.ico")
soundbeep
ExitApp
/*
uploader: AA6D31F4531E7B3A91845C1ED40495C3F784E60B
icon: 52614380F058B92408A9125AA4EA7EE023364865