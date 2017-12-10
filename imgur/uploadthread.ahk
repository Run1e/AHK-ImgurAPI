#SingleInstance force
#Persistent
;#NoTrayIcon
#WarnContinuableException off
SetBatchLines -1

#Include *i <Debug>

finished := true
return

Upload(Image, Callback, ProgressCallback) {
	Image := ObjShare(Image)
	Callback := ObjShare(Callback)
	ProgressCallback := ObjShare(ProgressCallback)
	
	if !UploadFile(Client.Endpoint "image", Data := "", Headers := {Authorization: "Client-ID " Client.id}, Image.File, ProgressCallback)
		Error := "No response"
	
	if Error
		Callback.Call(Data, Headers, Error)
	else
		Callback.Call(Data, Headers, false)
}


; only tested on x32 ahk_h unicode
UploadFile(URL, ByRef Data := "", ByRef Headers := "", File := "", Callback := "") {
	W_A := "W"
	DW := "UInt" ; shorthand or DWORD
	Ptr := "Ptr" ; shorthand for Ptr
	
	Port := InStr(URL, "https") = 1 ? 443 : 80
	Host := SubStr(URL, InStr(URL, "://") + 3)
	Path := SubStr(Host, InStr(Host, "/") + 1)
	Host := SubStr(Host, 1, InStr(Host, "/") - 1)
	
	Method := "POST"
	Flags := 2696949760 ; no idea
	Internet_Open_Type := 1
	Convert_POST_To_Codepage := 65001
	
	; create file
	if !FileObj := DllCall("CreateFile" W_A, Ptr, &File, DW, 0x80000000, DW, 0, Ptr, 0, DW, 4, DW, 0, Ptr, 0, Ptr)
		throw Exception("CreateFile failed", -1, File)
	
	; get size of file
	if !DllCall("GetFileSizeEx", Ptr, FileObj, "Int64*", FileSize)
		throw Exception("Failed getting file size", -1, File)
	
	; set contentlength to file size and set type to octet-stream
	Header["Content-Length"] := FileSize
	Header["Content-Type"] := "application/octet-stream"
	
	pos := 24 + A_PtrSize * 4 ; 40 bytes on x86 systems, 56 bytes on x64
	VarSetCapacity(INTERNET_BUFFERS, pos, 0)
	NumPut(pos, INTERNET_BUFFERS, 0, DW)
	NumPut(FileSize, INTERNET_BUFFERS, pos - 12, DW)
	
	; load WinINet.dll
	if !hWinINet := DllCall("LoadLibrary" W_A, "Str", "WinINet.dll", Ptr)
		throw Exception("Failed loading WinINet.dll", -1, hWinINet)
	
	; initialize WinINet
	if !hInternet := DllCall("WinINet\InternetOpen" W_A, Ptr, 0, DW, Internet_Open_Type, Ptr, 0, Ptr, 0, DW, 0, Ptr)
		throw Exception("InternetOpen failed", -1, hInternet)
	
	; open a HTTP session
	if !hConnection := DllCall("WinINet\InternetConnect" W_A, Ptr, hInternet, Ptr, &Host, DW, Port, Ptr, "", Ptr, "", DW, 3, DW, Flags, DW, 0, Ptr)
		throw Exception("InternetConnect failed", -1, hConnection)
	
	if !hRequest := DllCall("WinINet\HttpOpenRequest" W_A, Ptr, hConnection, Ptr, &Method, Ptr, &Path, "Str", "HTTP/1.1", Ptr, 0, Ptr, 0, DW, Flags, Ptr)
		throw Exception("HttpOpenRequest failed", -1, hRequest)
	
	; create header string
	for hdrk, hdrv in Headers
		hdrs .= hdrk ": " hdrv "`n"
	
	; add headers
	if !DllCall("WinINet\HttpAddRequestHeaders" W_A, Ptr, hRequest, Ptr, &hdrs, DW, StrLen(hdrs), DW, 0xA0000000)
		throw Exception("HttpAddRequestHeaders failed", -1)
	
	; begin submitting the request before uploading data
	if !DllCall("WinINet\HttpSendRequestEx" W_A, Ptr, hRequest, Ptr, &INTERNET_BUFFERS, Ptr, 0, DW, 0, Ptr, 0)
		throw Exception("Initial HttpSendRequestEx failed", -1)
	
	; set up vars
	VarSetCapacity(dbuffer, 4096, 0)
	dbuffsz := FileSize
	size := 0
	
	; upload file
	Loop {
		; get next chunk position
		pos := &dbuffer + size
		; figure out how much we're uploading
		dtsz := dbuffsz - size < 4096 ? dbuffsz - size : 4096
		
		; if we uploading 0 bytes, we're done
		if !dtsz
			break
		
		; read data from the file
		if !err := DllCall("ReadFile", Ptr, FileObj, Ptr, pos := &dbuffer, DW, dtsz, DW "*", dtsz, Ptr, 0)
			throw Exception("ReadFile - failed reading from file", -1, err)
		
		; add it to post
		if !err := DllCall("WinINet\InternetWriteFile", Ptr, hRequest, Ptr, pos, DW, dtsz + 0, DW "*", dtsz)
			throw Exception("InterWriteFile - failed uploading POST data", -1, pos "`n" dtsz)
		
		; add total uploaded data
		size += dtsz
		
		Callback.Call(size, FileSize)
	}
	
	; end request
	DllCall("WinINet\HttpEndRequest" W_A, Ptr, hRequest, Ptr, 0, DW, 0, Ptr, 0)
	
	; close file handle
	if !DllCall("CloseHandle", Ptr, FileObj)
		throw Exception("CloseHandle failed", -1)
	
	; check how much data is avaliable
	DllCall("WinINet\InternetQueryDataAvailable", Ptr, hRequest, DW "*", FileSize, DW, 0, Ptr, 0)
	
	; set memory for header string
	VarSetCapacity(hdr, hdrsz := 4096, 0)
	
	if !DllCall("WinINet\HttpQueryInfo" W_A, Ptr, hRequest, DW, 22, Ptr, &hdr, DW "*", hdrsz, Ptr, 0)
		throw Exception("HttpQueryInfo - failed getting headers", -1)
	
	; put output headers in Headers
	for Index, Text in StrSplit(hdr, "`n") {
		if (InStr(Text, "Content-Length") = 1) {
			len := SubStr(Text, InStr(Text, " ") + 1, -1)
			break
		}
	}
	
	; if theres any response data, get it
	if len {
		size := 0
		VarSetCapacity( dbuffer, dbuffsz := len, 0 )
		
		Loop {
			pos := &dbuffer + size
			if !DllCall( "WinINet\InternetReadFile", Ptr, hRequest, Ptr, pos, DW, 4096, DW "*", dtsz )
				throw Exception("InternetReadFile - failed getting data", -1)
			size += dtsz
			
			if (size >= len)
				break
		}
		
		rbuffsz := DllCall( "MultiByteToWideChar", DW, Convert_POST_To_Codepage, DW, 0, Ptr, &dbuffer, DW, size, Ptr, 0, DW, 0 )
		VarSetCapacity( rbuffer, rbuffsz + 1 << 1 )
		DllCall( "MultiByteToWideChar", DW, Convert_POST_To_Codepage, DW, 0, Ptr, &dbuffer, DW, size, Ptr, pos := &rbuffer, DW, rbuffsz )
		
		VarSetCapacity( out, rbuffsz + 1 << 1, 0 )
		DllCall( "RtlMoveMemory", Ptr, &out, Ptr, &rbuffer, DW, rbuffsz << 1 )
		VarSetCapacity( out, -1 )
		Data := out
	}
	
	; close handles
	DllCall("WinINet\InternetCloseHandle", Ptr, hRequest)
	DllCall("WinINet\InternetCloseHandle", Ptr, hConnection)
	DllCall("WinINet\InternetCloseHandle", Ptr, hInternet)
	DllCall("FreeLibrary", Ptr, hWinINet)
	
	return size
}