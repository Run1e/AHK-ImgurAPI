Class ImageType {
	
	; allowed file extensions by imgur
	static Extensions := ["JPG", "JPEG", "PNG", "GIF", "APNG", "TIFF", "PDF"]
	
	__New(Client, File := "") {
		this.Client := Client
		
		; do file checks if a file is specified.
		if FileExist(File) {
			SplitPath, File,,, Ext
			
			; check if its filetype is recognized by imgur
			if !ArrayHasValue(this.Extensions, Ext)
				throw new Imgur.Errors.FileTypeError(Ext)
			
			; make sure file is under 10mb large
			FileGetSize, Size, % File
			if (Size > 10480000)
				throw new Imgur.Errors.FileSizeError(Size)
			
			this.File := File
		} else 
			this.id := File
	}
	
	__Delete() {
		this.Client.Print("ImageType instance removed (" this.File ", " this.id ")")
	}
	
	; upload the file. this is shorthand for:
	; Client.Upload(Image, Callback := "")
	Upload(Callback := "") {
		; throw MissingFileError if file doesn't exist
		if !FileExist(this.File)
			throw new Imgur.Errors.MissingFileError(this.File)
		
		; pass the Image and the (potential) callback to the Uploader
		this.Client.Uploader.Upload(this, Callback)
	}
	
	Get(Callback := "") {
		this.Print("Getting image (" ImageHash ")")
		
		if !this.id
			throw new Imgur.Errors.MissingID(A_ThisFunc)
		
		; form a new request
		Req := new Request.Get(this.Client.Endpoint "image/" this.id)
		; add the auth header
		Req.AddHeader("Authorization", "Client-ID " this.Client.id)
		; set the response callback boundfunc
		Req.OnResponse(this.GetResponse.Bind(this, Callback))
		; send the request
		Req.Send()
	}
	
	
	UploadProgress(Current, Total) {
		this.Client.CallEvent("OnUploadProgress", "", this, Current, Total)
	}
	
	UploadResponse(Callback, Data, Header, Error) {
		; get the exception object if there is one
		if Error {
			Error := ObjShare(Error)
			this.Print(A_ThisFunc ": Error when uploading - " Error.Message)
			this.Client.CallEvent("OnUploadResponse", Callback, this, Error)
			return
		}
		
		; try to get the JSON encoded data, raise BadResponse if the data is unreadable
		try
			DataObj := JSON.Load(Data)
		catch e
			throw new Imgur.Errors.BadResponse(e.Message)
		
		; put the data k/v pairs in the Image instance
		for Key, Value in DataObj.data
			this[Key] := Value
		
		this.Print("this successfully uploaded (" this.File ", " this.id ")")
		
		; call the event (or callback)
		this.Client.CallEvent("OnUploadResponse", Callback, this, false)
	}
	
	GetResponse(Callback, Data, Headers, Error) {
		this.Print("GetImageResponse for " this.id " " (Error ? "failed" : "succeeded"))
		
		; call the event with the error if there is one
		if Error
			return this.Client.CallEvent("OnGetImageResponse", Callback, this, ObjShare(Error))
		
		; try to get JSON encoded text
		try
			DataObj := JSON.Load(Data.ResponseText)
		catch e
			return this.Client.CallEvent("OnGetImageResponse", Callback, this, new Imgur.Errors.BadResponse(e.Message))
		
		; put in Image instance
		for Key, Val in DataObj.data
			this[Key] := Val
		
		; call event
		this.Client.CallEvent("OnGetImageResponse", Callback, this, false)
	}
}