#SingleInstance force
#Persistent

global HTTP, Req, Res, Out

HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")

Req := {Method: "", Timeout: 5, Post: {}}

Ready := true

AddHeader(Header, Value) {
	HTTP.SetRequestHeader(Header, Value)
}

SetMethod(Method) {
	Req.Method := Method
}

SetURL(URL) {
	Req.URL := URL
}

SetCallback(Callback) {
	Req.Callback := ObjShare(Callback)
}

Open() {
	HTTP.Open(Req.Method, Req.URL, true)
}

Send() {
	for Key, Val in Req.Post
		Post .= "&" Key "=" UriEncode(Val)
	
	HTTP.Send(SubStr(Post, 2))
	
	if !HTTP.WaitForResponse(Req.Timeout)
		return Req.Callback.Call("", "", "Request timed out")
	
	Res := {}
	for Index, Value in ["Status", "StatusText", "ResponseText", "ResponseBody"]
		Res[Value] := HTTP[Value]
	
	for Index, Header in StrSplit(HTTP.GetAllResponseHeaders(), "`n"), Out := {}
		if StrLen((HDR := StrSplit(Header, ": ")).1)
			Out[HDR.1] := HDR.2
		
	if (Res.Status = 200)
		Req.Callback.Call(Res, Out, false)
	else
		Req.Callback.Call(Res, Out, "Request status is " Res.Status)
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