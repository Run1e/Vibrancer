# Power Play
A Windows application which allows you to:
- Boost ingame vibrancy for any game/program via NVIDIA's API
- Block alt-tab/windows key when ingame
- Capture and upload images to imgur
- Delete and manage uploaded images
- Easily create powerful keybinds such as multimedia controls

<img src="https://cloud.githubusercontent.com/assets/5571284/24335157/4c76bf46-1278-11e7-9833-19710ba22a5c.png"></img> <img src="https://cloud.githubusercontent.com/assets/5571284/24335158/4c938c02-1278-11e7-9e35-5e22c066a39b.png"></img> <img src="https://cloud.githubusercontent.com/assets/5571284/24335159/4ca5b29c-1278-11e7-857d-93aad70e9e5c.png"></img>

Currently WIP, installer will be avaliable at "launch".

If you want to try the code, you'll need to create a function called client_id which returns your [Imgur API OAuth2.0](https://api.imgur.com/oauth2/addclient) client id as such:

	client_id() {
		return "client_id_here"
	}
And also remove the include to client_id.ahk

# Thanks to:

- jNizM for his [NvAPI wrapper](https://github.com/jNizM/AHK_NVIDIA_NvAPI)
- 'just me' for his [CtlColors class](https://github.com/AHK-just-me/Class_CtlColors), [ImageButton class](https://github.com/AHK-just-me/Class_ImageButton) and [LV_EX library](https://autohotkey.com/boards/viewtopic.php?t=1256)
- Coco for his [JSON class](https://github.com/cocobelgica/AutoHotkey-JSON)
- tic for his [Gdip wrapper](https://autohotkey.com/boards/viewtopic.php?t=6517)
- VxE for his [HTTPRequest function](https://autohotkey.com/board/topic/67989-func-httprequest-for-web-apis-ahk-b-ahk-lunicodex64/)
- Klark92 for his [FrameShadow function](https://autohotkey.com/boards/viewtopic.php?f=6&t=29117)
- tidbit for creative help!

# Written in [AutoHotkey_L](https://autohotkey.com/)
