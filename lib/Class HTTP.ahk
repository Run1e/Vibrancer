Class HTTP {
	static HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	static Timeout := 5
	
	; returns true on success and false on failure, data in Post, headers in Headers
	Post(URL, ByRef Post, ByRef Headers := "") {
		if !this.IsConnected()
			return false
		
		if IsObject(Post)
			for Key, Value in Post
				Post .= (A_Index > 1 ? "&" : "") Key "=" this.UriEncode(Value)
		
		this.HTTP.Open("POST", URL, true)
		this.SetHeaders(Headers)
		this.AutoProxy()
		this.HTTP.Send(Post)
		
		try {
			if this.HTTP.WaitForResponse(this.Timeout) {
				Post := this.GetData()
				Headers := this.GetHeaders()
				this.Log("POST request SUCCESS`nURL: " URL "`nStatus: " Post.Status " (" Post.StatusText ")")
				return true
			}
		}
		
		this.Log("POST request FAILED (" URL ")")
		return false
	}
	
	; returns true on success and false on failure, data in OutData, headers in Headers
	Get(URL, ByRef OutData := "", ByRef Headers := "") {
		if !this.IsConnected()
			return false
		
		this.HTTP.Open("GET", URL, true)
		this.SetHeaders(Headers)
		this.AutoProxy()
		this.HTTP.Send()
		
		try {
			if this.HTTP.WaitForResponse(this.Timeout) {
				OutData := this.GetData()
				Headers := this.GetHeaders()
				this.Log("GET request SUCCESS`nURL: " URL "`nStatus: " OutData.Status " (" OutData.StatusText ")")
				return true
			}
		}
		
		this.Log("GET request FAILED (" URL ")")
		return false
	}
	
	SetTimeout(Timeout) {
		this.Timeout := Timeout
	}
	
	SetProxy(Proxy) {
		this.Proxy := Proxy
	}
	
	/*
		*** INTERNAL METHODS ***
	*/
	
	Log(Text) {
		
	}
	
	GetData() {
		return 	{ ResponseText:this.HTTP.ResponseText
				, Status:this.HTTP.Status
				, StatusText:this.HTTP.StatusText}
	}
	
	SetHeaders(Headers) {
		if IsObject(HEADERS) {
			for Header, Value in Headers
				this.HTTP.SetRequestHeader(Header, Value)
		} else
			this.HTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	}
	
	GetHeaders() {
		for Index, Header in StrSplit(this.HTTP.GetAllResponseHeaders(), "`n"), Out := {}
			if StrLen((HDR := StrSplit(Header, ": ")).1)
				Out[HDR.1] := HDR.2
		return Out
	}
	
	AutoProxy() {
		if this.Proxy
			this.HTTP.SetProxy(2, this.Proxy)
		else {
			RegRead ProxyEnable, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable
			if ProxyEnable {
				RegRead ProxyServer, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyServer
				this.HTTP.SetProxy(2, ProxyServer)
			}
		}
	}
	
	IsConnected() {
		return DllCall("Wininet.dll\InternetGetConnectedState", "Str", 0x40,"Int",0)
	}
	
	UriEncode(Uri) {
		VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0)
		StrPut(Uri, &Var, "UTF-8")
		f := A_FormatInteger
		SetFormat, IntegerFast, H
		while Code := NumGet(Var, A_Index - 1, "UChar")
			if (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
				Res .= Chr(Code)
		else
			Res .= "%" . SubStr(Code + 0x100, -1)
		SetFormat, IntegerFast, %f%
		return, Res
	}
}