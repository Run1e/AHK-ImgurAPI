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
	
	; FILES
	
	Class FileTypeError extends Imgur.Errors.BaseException {
		Message := "File type specified is incompatible."
	}
	
	Class MissingFileError extends Imgur.Errors.BaseException {
		Message := "File specified does not exist."
	}
	
	; CLIENT
	
	Class ClientMismatch extends Imgur.Errors.BaseException {
		Message := "Client instance mismatch."
	}
	
	; WORKER
	
	Class WorkerLaunchFailure extends Imgur.Errors.BaseException {
		Message := "Worker failed to launch."
	}
}