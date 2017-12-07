Class Errors {
	Class BaseException {
		Message := "An error occured."
		
		__New(Extra := "") {
			return (ex := Exception(this.Message, "", Extra), ex.base := this.base)
		}
	}
	
	Class TypeError extends Imgur.Errors.BaseException {
		Message := "Incompatible type specified."
	}
	
	Class MalformedJSON extends Imgur.Errors.BaseException {
		Message := "JSON data from API is malformed."
	}
	
	; FILES
	
	Class FileTypeError extends Imgur.Errors.BaseException {
		Message := "File type specified is incompatible."
	}
	
	Class MissingFileError extends Imgur.Errors.BaseException {
		Message := "File specified does not exist."
	}
	
	Class FileSizeError extends Imgur.Errors.BaseException {
		Message := "File is too large."
	}
	
	; CLIENT
	
	Class ClientMismatch extends Imgur.Errors.BaseException {
		Message := "Client instance mismatch."
	}
	
	; WORKERS
	
	Class WorkerLaunchFailure extends Imgur.Errors.BaseException {
		Message := "Worker failed to launch."
	}
}