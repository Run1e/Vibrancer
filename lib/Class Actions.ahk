﻿Class Actions {
	Class BuiltIn {
		Open(tab := "") {
			Big.Open(tab)
		}
		
		; if running the clipboard fails (ie, not a file/link), it googles the clipboard text
		RunClipboard() {
			if (clipboard = "")
				return TrayTip("Clipboard is empty!")
			
			try
				Run(clipboard)
			catch e
				Run("https://www.google.com/#q=" HTTP.UriEncode(clipboard))
		}
		
		Settings() {
			Settings()
		}
		
		Plugins() {
			Plugins()
		}
	}
	
	Class Multimedia {
		PlayPause() {
			SendInput % "{Media_Play_Pause}"
		}
		
		Next() {
			SendInput % "{Media_Next}"
		}
		
		Prev() {
			SendInput % "{Media_Prev}"
		}
		
		VolUp() {
			SendInput % "{Volume_Up}"
		}
		
		VolDown() {
			SendInput % "{Volume_Down}"
		}
		
		VolMute() {
			SendInput % "{Volume_Mute}"
		}
	}
	
	Class Spotify {
		PlayPause() {
			this.Msg(0xE0000)
		}
		
		Next() {
			this.Msg(0xB0000)
		}
		
		Prev() {
			this.Msg(0xC0000)
		}
		
		Msg(Msg) {
			PostMessage, 0x319,, % Msg,, ahk_exe Spotify.exe ; 0x319 = WM_APPCOMMAND
		}
	}
}