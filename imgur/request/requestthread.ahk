#SingleInstance force
#Persistent

global HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
global Info := {Headers: {}}
Ready := true
return

AddHeader(Header, Value) {
	Info.Headers[Header] := Value
}

SetMethod(Method) {
	Info.Method := Method
}

SetURL(URL) {
	Info.URL := URL
}

SetTimeout(Timeout) {
	Info.Timeout := Timeout
}

SetResponse(ResponseShare) {
	Info.Response := ObjShare(ResponseShare)
}

Send() {
	try {
		HTTP.Open(Info.Method, Info.URL, true)
		
		for Header, Value in Info.Headers
			HTTP.SetRequestHeader(Header, Value)
		
		HTTP.Send()
		
		if !HTTP.WaitForResponse(Info.Timeout)
			Error(Exception("Info timed out.", -1))
		
		for Index, Value in ["Status", "StatusText", "ResponseText"]
			Info.Response[Value] := HTTP[Value]
		
		for Index, Signature in StrSplit(HTTP.GetAllResponseHeaders(), "`n") {
			HDR := StrSplit(Signature, ": ")
			Header := trim(HDR.1, "`t`r`n")
			Value := trim(HDR.2, "`t`r`n")
			if StrLen(Header)
				Info.Response.Headers[Header] := Value
		}
	} catch e
		Error(e)
	
	Go()
}

Error(Error) {
	Info.Response.SetError(ObjShare(Error))
	Exit()
}

Go() {
	Info.Response.Go()
	Exit()
}

Exit() {
	Info := ""
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