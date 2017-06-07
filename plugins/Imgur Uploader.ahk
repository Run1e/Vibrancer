; Capture, upload and delete images
; RUNIE
#SingleInstance force
#NoEnv
#Persistent
#NoTrayIcon
SetBatchLines -1
SetWorkingDir % A_ScriptDir
DetectHiddenWindows On
SetWinDelay -1
SetKeyDelay -1
CoordMode, Mouse, Screen
OnExit("Exit")

#Include %A_ScriptDir%
#Include ..\lib\plugin\BindSection.ahk

#Include ..\lib\Class GUI.ahk
#Include ..\lib\Class Hotkey.ahk
#Include ..\lib\Class OnMouseMove.ahk
#Include ..\lib\Class JSONFile.ahk
#Include ..\lib\Class Menu.ahk
#Include ..\lib\Debug.ahk
#Include ..\lib\Error.ahk
#Include ..\lib\Functions.ahk
#Include ..\lib\MonitorSetup.ahk
#Include ..\lib\third-party\Class JSON.ahk
#Include ..\lib\third-party\Class LV_Colors.ahk
#Include ..\lib\third-party\Gdip_All.ahk
#Include ..\lib\third-party\LV_EX.ahk
#Include ..\lib\third-party\ObjRegisterActive.ahk

#Include imgurlib\Class CustomImageList.ahk
#Include imgurlib\Class ImgurGUI.ahk
#Include imgurlib\Class Queue.ahk
#Include imgurlib\Class RectClass.ahk
#Include imgurlib\Class ScreenClass.ahk
#Include imgurlib\Class Uploader.ahk
#Include imgurlib\CreateImgurGUI.ahk
#Include imgurlib\DefaultSettings.ahk
#Include imgurlib\Functions.ahk
#Include imgurlib\MakeFolders.ahk
#Include imgurlib\Screencap.ahk
#Include imgurlib\UploaderScript.ahk

#Include imgurlib\third-party\SB_SetProgress.ahk
#Include imgurlib\third-party\WinGetPosEx.ahk

MakeFolders()

Error("", "",,,, "..\logs") ; set error log folder

; port data from pre-v0.9.9
if FileExist("..\data\Images.json") {
	for Index, Image in JSON.Load(FileRead("..\data\Images.json"))
		FileMove, % "..\images\imgur\" Image.id "." Image.extension, % "..\data\imgur\image\uploaded\" Index "." Image.extension, 1
	FileMove, ..\data\Images.json, ..\data\imgur\ImgurImages.json
	FileRemoveDir, ..\images, 1
}

try
	Power := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Power.OnExit(Func("Exit"))

global pToken := Gdip_Startup()
global Working := false, Images, Settings, Img, Power, Uploader

Uploader := new Uploader

; call exit when pp closes

Settings := new JSONFile("..\data\imgur\ImgurSettings.json")
Settings.Fill(DefaultSettings())
if !Settings.FileExist()
	Settings.Save()

; json file containing image data
Images := new JSONFile("..\data\imgur\ImgurImages.json")
if !Images.FileExist()
	Images.Save()

; bind section
Binds := new BindSection(Power, "Imgur", "ImgurUploader")
Binds.AddFunc("Area", Func("Area"))
Binds.AddFunc("Window", Func("Window"))
Binds.AddFunc("Screen", Func("Screen"))
Binds.AddFunc("Open", Func("Open"))
Binds.AddBind("Capture Area", "Area")
Binds.AddBind("Capture Window", "Window")
Binds.AddBind("Capture Monitor", "Screen")
Binds.AddBind("Open GUI", "Open")
Binds.Register()

Power.TrayAdd("Images", Func("Open"), Power.Call("Icon", "device-camera"))

Power.Finished() ; pp can continue on its adventures now it dun have to wait for this plugin to load it's images

; create gui
CreateImgurGUI()
Img.LoadImages()

/*
	Tray.NoStandard()
	Tray.Add("Open", Img.Open.Bind(Img))
	Tray.Add("Exit", Func("Exit"))
	Tray.Default("Open")
	Tray.Icon()
*/
return

Open() {
	Img.Open()
}

TrayTip(Title, Msg := "") {
	if !StrLen(Msg)
		Msg := Title, Title := "Imgur Uploader"
	Power.Call("TrayTip", Title, Msg)
}

Capture(x := "", y := "", w := "", h := "") {
	
	if !StrLen(x)
		return
	
	Name := A_Now "_" A_MSec
	File := Uploader.LocalFolder "\" Name ".png" ; save to local image folder
	
	pBitmap := Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
	
	if ((Gdip_Success := Gdip_SaveBitmapToFile(pBitmap, File, 90)) < 0)
		return
	
	if !FileExist(File)
		return
	
	Gdip_DisposeImage(pBitmap)
	
	Uploader.Upload(Name, File)
	return
}

Exit() {
	Settings.Save()
	Images.Save()
	Uploader.Free()
	Gdip_Shutdown(pToken)
	ExitApp
}