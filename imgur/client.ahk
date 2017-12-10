#Include %A_LineFile%\..\lib\third-party\JSON.ahk
#Include %A_LineFile%\..\request\request.ahk

Class Imgur {
	
	#Include %A_LineFile%\..\image.ahk
	
	#Include %A_LineFile%\..\worker.ahk
	#Include %A_LineFile%\..\errors.ahk
	
	
	#Include %A_LineFile%\..\uploadworker.ahk
	
	static Endpoint := "https://api.imgur.com/3/"
	
	__New(client_id) {
		this.Print("Creating new client (" client_id ")")
		
		this.id := client_id
		
		this.Events := 
		(LTrim Join
		{
			OnUploadResponse: [],
			OnUploadProgress: [],
			OnGetImageResponse: []
		}
		)
		
		;this.Requester := new Imgur.RequestWorker(this)
		this.Uploader := new Imgur.UploadWorker(this)
		this.Requester := new Imgur.RequestWorker(this)
	}
	
	__Delete() {
		this.Print("Client instance removed: (" this.id ")")
	}
	
	Print(x*) {
		p(x*)
	}
	
	Free() {
		this.Uploader := ""
		this.Requester := ""
		this.Events := ""
	}
	
	; create new ImageType instance
	Image(File := "") {
		return new Imgur.ImageType(this, File)
	}
	
	; upload image
	Upload(Image, Callback := "") {
		; check the input passed is an ImageType instance
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.Errors.TypeError("Input has to be an Imgur.ImageType instance.")
		
		; make sure the ImageType instance was instantiated from this Client
		if (&(Image.Client) != &this)
			throw new Imgur.Errors.ClientMismatch
		
		if !FileExist(Image.File)
			throw new Imgur.Errors.MissingFileError(Image.File)
		
		this.Uploader.Upload(Image, Callback)
	}
	
	GetImage(ImageHash, Callback := "") {
		this.Print("GetImage for " ImageHash)
		
		Image := this.Image()
		Image.id := ImageHash
		
		g := new Request.Get(this.Endpoint "image/" Image.id)
		g.OnResponse(this.GetImageResponse.Bind(this, Image, Callback))
		g.AddHeader("Authorization", "Client-ID " this.id)
		g.Send()
	}
	
	RegisterEvent(Event, Func) {
		this.Events[Event].Push(Func)
	}
	
	ClearEvent(Event) {
		this.Events[Event] := []
	}
	
	/*
		!!! PRIVATE METHODS !!!
	*/
	
	CallEvent(Event, Callback, Param*) {
		if Callback
			Callback.Call(Param*)
		else
			for i, f in this.Events[Event]
				f.Call(Param*)
	}
	
	UploadResponse(Image, Callback, Data, Headers, Error) {
		if Error
			Error := ObjShare(Error)
		
		if Error {
			this.Client.CallEvent("OnUploadResponse", Callback, Image, Error)
			return
		}
		
		try
			DataObj := JSON.Load(Data)
		catch e
			throw new Imgur.Errors.BadResponse(e.Message)
		
		for Key, Value in DataObj.data
			Image[Key] := Value
		
		this.Print("Image successfully uploaded (" Image.File ", " Image.id ")")
		
		this.Client.CallEvent("OnUploadResponse", Callback, Image, false)
		this.Next(true)
	}
	
	GetImageResponse(Image, Callback, Data, Headers, Error) {
		this.Print("GetImageResponse for " Image.id " " (Error ? "failed" : "succeeded"))
		
		if Error {
			this.CallEvent("OnGetImageResponse", Callback, Image, new Imgur.Errors.BadRequest(Error))
			return
		}
		
		try
			DataObj := JSON.Load(Data.ResponseText)
		catch e {
			this.CallEvent("OnGetImageResponse", Callback, Image, new Imgur.Errors.MalformedJSON(e.Message))
			return
		}
		
		for Key, Val in DataObj.data
			Image[Key] := Val
		
		this.CallEvent("OnGetImageResponse", Callback, Image, false)
		
	}
}

; checks if Instance is an instance of Class
isinstance(Instance, Base) {
	return Instance.base.__Class = Base.__Class
}

; checks if a normal array has a value
ArrayHasValue(Array, Value) {
	for k, v in Array
		if (v = Value)
			return true
	return false
}