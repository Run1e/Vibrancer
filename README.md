[Download here](https://github.com/Run1e/PowerPlay/releases/latest)   [Source code](https://github.com/Run1e/PowerPlay)
# <img src="http://i.imgur.com/OX90ale.png"> Power Play

Power Play is a Windows application which allows you to:
- Boost ingame vibrancy for any game/program via NVIDIA's API
- Block alt-tab/windows key when ingame
- Capture and upload images to imgur
- Delete and manage uploaded images
- Easily create powerful keybinds such as multimedia controls

<img src="https://i.imgur.com/hyqhjUx.png">
<img src="https://i.imgur.com/YgIuvRg.png">
<img src="https://i.imgur.com/0KCxFLG.png">

Currently WIP, installer will be avaliable at "launch".

If you want to try the code, you'll need to create a function called client_id which returns your [Imgur API OAuth2.0](https://api.imgur.com/oauth2/addclient) client id as such:

	client_id() {
		return "client_id_here"
	}

# Thanks to:

- jNizM for his [NvAPI wrapper](https://github.com/jNizM/AHK_NVIDIA_NvAPI)
- 'just me' for his [LV_Colors class](https://github.com/AHK-just-me/Class_LV_Colors), [ImageButton class](https://github.com/AHK-just-me/Class_ImageButton), [CtlColors class](https://github.com/AHK-just-me/Class_CtlColors) and [LV_EX library](https://autohotkey.com/boards/viewtopic.php?t=1256)
- Coco for his [JSON class](https://github.com/cocobelgica/AutoHotkey-JSON)
- tic for his [Gdip wrapper](https://autohotkey.com/boards/viewtopic.php?t=6517)
- VxE for his [HTTPRequest function](https://autohotkey.com/board/topic/67989-func-httprequest-for-web-apis-ahk-b-ahk-lunicodex64/)
- Klark92 for his [FrameShadow function](https://autohotkey.com/boards/viewtopic.php?f=6&t=29117)
- tidbit for creative help!

# Written in [AutoHotkey_L](https://autohotkey.com/)
