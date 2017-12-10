Class Errors {
	Class BaseException {
		Message := "An error occured."
		
		__New(Extra := "") {
			return (ex := Exception(this.Message, "", Extra), ex.base := this.base)
		}
	}
	
	; REQUEST
	
	Class BadResponse extends Imgur.Errors.BaseException {
		; response was not intelligible.
		Message := "HTTP error occured."
	}
	
	; UPLOADER
	
	Class WorkerLaunchFailure extends Imgur.Errors.BaseException {
		; the upload worker failed to launch.
		Message := "Worker failed to launch."
	}
	
	; MISC
	
	Class TypeError extends Imgur.Errors.BaseException {
		; an instance passed has the wrong type.
		Message := "Incompatible type specified."
	}
	
	Class MalformedJSON extends Imgur.Errors.BaseException {
		; JSON data is malformed.
		Message := "JSON data from API is malformed."
	}
	
	; FILES
	
	Class FileTypeError extends Imgur.Errors.BaseException {
		; the file specified has a file extension that is not allowed.
		Message := "File type specified is incompatible."
	}
	
	Class MissingFileError extends Imgur.Errors.BaseException {
		; the file specified does not exist.
		Message := "File specified does not exist."
	}
	
	Class FileSizeError extends Imgur.Errors.BaseException {
		; the file specified is too large.
		Message := "File is too large."
	}
	
	; CLIENT
	
	Class MissingID extends Imgur.Errors.BaseException {
		Message := "Missing ID."
	}
	
	Class ClientMismatch extends Imgur.Errors.BaseException {
		; the instance specified originates from another client.
		Message := "Client instance mismatch."
	}
}