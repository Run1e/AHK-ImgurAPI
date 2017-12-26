Class BaseException {
	Message := "An error occured."
	
	__New(Data := "") {
		ex := Exception(this.Message)
		ex.Delete("File", "Line", "What")
		ex.base := this.base
		if IsObject(Data) {
			for Key, Val in Data
				ex[Key] := Val
		} else if StrLen(Data)
			ex.Extra := Data
		return ex
	}
}

; REQUEST // HTTP ERRORS

Class 400HTTPError extends Imgur.BaseException {
	Message := "400 Bad Request: Required input parameter/file missing or out of bounds."
}

Class 401HTTPError extends Imgur.BaseException {
	Message := "401 Unauthorized: Request requires user authentication."
}

Class 403HTTPError extends Imgur.BaseException {
	Message := "403 Forbidden: You do not have access to this action."
}

Class 404HTTPError extends Imgur.BaseException {
	Message := "404 Not Found: Requested data does not exist."
}

Class 429HTTPError extends Imgur.BaseException {
	Message := "429 Too Many Requests: Rate limit on application or IP reached."
}

Class 500HTTPError extends Imgur.BaseException {
	Message := "500 Internal Server Error: Something is broken with Imgur."
}

Class RequestError extends Imgur.BaseException {
	Message := "Request thread threw an error."
}

Class BadResponse extends Imgur.BaseException {
	Message := "Bad response: Response from Imgur unintelligble."
}

; UPLOADER

Class WorkerLaunchFailure extends Imgur.BaseException {
	; the upload worker failed to launch.
	Message := "Worker failed to launch."
}

; MISC

Class TypeError extends Imgur.BaseException {
	; an instance passed has the wrong type.
	Message := "Incompatible type specified."
}

Class MalformedJSON extends Imgur.BaseException {
	; JSON data is malformed.
	Message := "JSON data from API is malformed."
}

; FILES

Class FileTypeError extends Imgur.BaseException {
	; the file specified has a file extension that is not allowed.
	Message := "File type specified is incompatible."
}

Class MissingFileError extends Imgur.BaseException {
	; the file specified does not exist.
	Message := "File specified does not exist."
}

Class FileSizeError extends Imgur.BaseException {
	; the file specified is too large.
	Message := "File is too large."
}

; CLIENT

Class MissingID extends Imgur.BaseException {
	Message := "Missing ID."
}

Class ClientNotInstantiated extends Imgur.BaseException {
	Message := "You have to create an instance of Imgur first."
}

Class ClientMismatch extends Imgur.BaseException {
	; the instance specified originates from another client.
	Message := "Client instance mismatch."
}