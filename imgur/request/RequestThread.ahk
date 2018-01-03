#SingleInstance force
#Persistent

global Ready := true
return

Send(RequestShare) {
	try {
		Request := ObjShare(RequestShare)
		
		HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		
		HTTP.Open(Request.Method, Request.URL, true)
		
		Request.PutHeaders(ObjShare(Headers := {}))
		
		for Header, Value in Headers
			HTTP.SetRequestHeader(Header, Value)
		
		HTTP.Send()
		
		if !HTTP.WaitForResponse(Request.Timeout)
			throw Exception("Request timed out.", -1, "Timeout: " Request.Timeout)
		
		for Index, Value in ["Status", "StatusText", "ResponseText"]
			Request.Response[Value] := HTTP[Value]
		
		for Index, Signature in StrSplit(HTTP.GetAllResponseHeaders(), "`n") {
			HDR := StrSplit(Signature, ": ")
			Header := trim(HDR.1, "`t`r`n")
			Value := trim(HDR.2, "`t`r`n")
			if StrLen(Header)
				Request.Response.Headers[Header] := Value
		}
	} catch e
		Request.Response.Error := e
	
	Request.ThreadCallback()
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