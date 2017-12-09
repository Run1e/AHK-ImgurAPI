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
			OnUploadProgress: [],
			OnUploadSuccess: [],
			OnUploadFailure: [],
			OnGetImageSuccess: [],
			OnGetImageFailure: []
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
		
		this.Uploader.Upload(Image)
	}
	
	; create new ImageType instance
	NewImage(File := "") {
		return new Imgur.ImageType(this, File)
	}
	
	GetImage(ImageHash, Callback := "") {
		this.Print("Getting image: " ImageHash)
		
		g := new Request.Get(this.Endpoint "image/" ImageHash)
		g.OnResponse(this.GetImageResponse.Bind(this, ImageHash, Callback))
		g.AddHeader("Authorization", "Client-ID " x.ID)
		g.Send()
	}
	
	/*
		event recipient signature:
		on success:
		ImageType, false
		on failure:
		ImageHash, Exception
	*/
	GetImageResponse(ImageHash, Callback, Success, Data, Headers) {
		this.Print("GetImage response for " ImageHash ": " (Success ? "success" : "failure"))
		
		if Success {
			Img := this.Image()
			
			try
				DataObj := JSON.Load(Data.ResponseText)
			catch e {
				err := new Imgur.Errors.MalformedJSON(e.Message)
				this.CallEvent("OnGetImageFailure", ImageHash, err)
				Callback.Call(ImageHash, err)
				return
			}
				
			for Key, Val in DataObj.data
				Img[Key] := Val	
				
			this.CallEvent("OnGetImageSuccess", Img)
			Callback.Call(true, Img)
		}
		
		this.CallEvent("OnGetImageFailure", ImageHash)
		Callback.Call(ImageHash, true)
	}
	
	RegisterEvent(Event, Func) {
		this.Events[Event].Push(Func)
	}
	
	ClearEvent(Event) {
		this.Events[Event] := []
	}
	
	CallEvent(Event, Param*) {
		for i, f in this.Events[Event]
			f.Call(Param*)
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