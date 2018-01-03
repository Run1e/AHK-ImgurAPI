Class ImageType {
	
	; allowed file extensions by imgur
	static Extensions := ["JPG", "JPEG", "PNG", "GIF", "APNG", "TIFF", "PDF"]
	
	__New(Client, FileOrID := "") {
		this.Client := new IndirectReference(Client)
		
		; do file checks if a file is specified.
		if FileExist(FileOrID) {
			SplitPath, FileOrID,,, Ext
			
			; check if its filetype is recognized by imgur
			if !ArrayHasValue(this.Extensions, Ext)
				throw new Imgur.FileTypeError(Ext)
			
			this.File := FileOrID
		} else
			this.id := FileOrID
		
		this.Print(this.__Class " created")
	}
	
	__Delete() {
		this.Print(this.__Class " released")
	}
	
	Print(x*) {
		try this.Client.Print(x*)
	}
	
	FileName {
		get {
			static assoc := {"image/jpeg": "jpg"}
			return this.id "." assoc[this.type]
		}
	}
	
	; upload the file. this is shorthand for:
	; Client.Upload(Image, Callback := "")
	Upload(Callback := "") {
		; throw MissingFileError if file doesn't exist
		if !FileExist(this.File)
			throw new Imgur.MissingFileError(this.File)
		
		; make sure file is under 10mb large
		FileGetSize, Size, % FileOrID
		if (Size > 10480000)
			throw new Imgur.FileSizeError(Size)
		
		; pass the Image and the (potential) callback to the Uploader
		this.Client.Uploader.Upload(this, Callback)
	}
	
	UploadProgress(Current, Total) {
		this.Client.CallEvent("UploadProgress", "", this, Current, Total)
	}
	
	UploadResponse(Callback, Data, Header, Error) {
		; get the exception object if there is one
		Result := this.Client.ParseResponse(Resp)
		
		if !Result.Error
			for Key, Value in Result.Data
				this[Key] := Value
		
		; call event
		this.Client.CallEvent("GetImageResponse", Callback, this, Resp, Result.Error)
		
		this.Client.Uploader.Next(true)
	}
	
	Get(Callback := "") {
		this.Client.Print("Getting image (" this.id ")")
		
		if !this.id
			throw new Imgur.MissingID()
		
		; form a new request
		Req := new Request.Get(this.Client.Endpoint "image/" this.id , this.GetResponse.Bind(this, Callback), this.Client.Print.Bind(this.Client))
		; add the auth header
		Req.SetHeader("Authorization", "Client-ID " this.Client.id)
		; send the request
		Req.Send()
	}
	
	GetResponse(Callback, Resp) {
		this.Client.Print("GetImage response (" this.id ")")
		
		Result := this.Client.ParseResponse(Resp)
		
		if !Result.Error
			for Key, Value in Result.Data
				this[Key] := Value
		
		; call event
		this.Client.CallEvent("GetImageResponse", Callback, (this, this.Delete("Client")), Resp, Result.Error)
	}
}