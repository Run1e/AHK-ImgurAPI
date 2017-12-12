Class ImageType extends Imgur.ClientChild {
	
	; allowed file extensions by imgur
	static Extensions := ["JPG", "JPEG", "PNG", "GIF", "APNG", "TIFF", "PDF"]
	
	__New(Client, FileOrID := "") {
		this.Client := Client
		
		; do file checks if a file is specified.
		if FileExist(FileOrID) {
			SplitPath, FileOrID,,, Ext
			
			; check if its filetype is recognized by imgur
			if !ArrayHasValue(this.Extensions, Ext)
				throw new Imgur.FileTypeError(Ext)
			
			; make sure file is under 10mb large
			FileGetSize, Size, % FileOrID
			if (Size > 10480000)
				throw new Imgur.FileSizeError(Size)
			
			this.File := FileOrID
		} else 
			this.id := FileOrID
		
		this.Print(type(this) " created")
	}
	
	; upload the file. this is shorthand for:
	; Client.Upload(Image, Callback := "")
	Upload(Callback := "") {
		; throw MissingFileError if file doesn't exist
		if !FileExist(this.File)
			throw new Imgur.MissingFileError(this.File)
		
		; pass the Image and the (potential) callback to the Uploader
		this.Uploader.Upload(this, Callback)
	}
	
	UploadProgress(Current, Total) {
		this.CallEvent("UploadProgress", "", this, Current, Total)
	}
	
	UploadResponse(Callback, Data, Header, Error) {
		; get the exception object if there is one
		if Error {
			Error := ObjShare(Error)
			this.Print(A_ThisFunc ": Error when uploading - " Error.Message)
			this.CallEvent("UploadResponse", Callback, this, Error)
			return
		}
		
		; try to get the JSON encoded data, raise BadResponse if the data is unreadable
		try
			DataObj := JSON.Load(Data)
		catch e
			throw new Imgur.BadResponse(e.Message)
		
		; put the data k/v pairs in the Image instance
		for Key, Value in DataObj.data
			this[Key] := Value
		
		; call the event (or callback)
		this.CallEvent("UploadResponse", Callback, this, false)
		
		this.Client.Uploader.Next(true)
	}
	
	Get(Callback := "") {
		this.Print("Getting image (" this.id ")")
		
		if !this.id
			throw new Imgur.MissingID()
		
		; form a new request
		Req := new Request.Get(this.Endpoint "image/" this.id , this.GetResponse.Bind(this, Callback))
		; add the auth header
		Req.SetHeader("Authorization", "Client-ID " this.apikey)
		; send the request
		Req.Send()
	}
	
	GetResponse(Callback, Resp) {
		this.Print("GetImageResponse: " this.id)
		
		Data := this.ParseResponse(Resp)
		
		; put in Image instance
		for Key, Val in Data.data 
			this[Key] := Val
		
		; call event
		this.CallEvent("GetImageResponse", Callback, this, Resp)
	}
}