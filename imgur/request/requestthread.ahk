#SingleInstance force
#Persistent

global HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
global Request := {Method: "", Timeout: 5}
Ready := true
return

AddHeader(Header, Value) {
	HTTP.SetRequestHeader(Header, Value)
}

SetMethod(Method) {
	Request.Method := Method
}

SetURL(URL) {
	Request.URL := URL
}

SetResponse(Response) {
	Request.Response := ObjShare(Response)
}

Open() {
	HTTP.Open(Request.Method, Request.URL, true)
}

Send() {
	HTTP.Send()
	
	if !HTTP.WaitForResponse(Request.Timeout) {
		Request.Response.SetError(Exception("Request timed out.",, "HTTPTimeout"))
		return Go()
	}
	
	for Index, Value in ["Status", "StatusText", "ResponseText"] ; "ResponseBody"
		Request.Response[Value] := HTTP[Value]
	
	for Index, Signature in StrSplit(HTTP.GetAllResponseHeaders(), "`n") {
		HDR := StrSplit(Signature, ": ")
		Header := trim(HDR.1, "`t`r`n")
		Value := trim(HDR.2, "`t`r`n")
		if StrLen(Header)
			Request.Response.Headers[Header] := Value
	}
	
	Go()
}

Go() {
	Request.Response.Finished()
	Request := ""
	ExitApp
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