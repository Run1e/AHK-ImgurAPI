#Include %A_LineFile%\..\lib\third-party\JSON.ahk
#Include %A_LineFile%\..\request\request.ahk

Class Imgur {
	
	#Include %A_LineFile%\..\image.ahk
	#Include %A_LineFile%\..\errors.ahk
	#Include %A_LineFile%\..\uploadworker.ahk
	
	; imgurs API endpoint
	static Endpoint := "https://api.imgur.com/3/"
	
	__New(client_id) {
		this.Print("Creating new client (" client_id ")")
		
		this.id := client_id
		
		; holds arrays of events for each event
		this.Events := 
		(LTrim Join
		{
			OnUploadResponse: [],
			OnUploadProgress: [],
			OnGetImageResponse: []
		}
		)
		
		; create the image upload worker
		this.Uploader := new Imgur.UploadWorker(this)
	}
	
	__Delete() {
		this.Print("Client instance removed: (" this.id ")")
	}
	
	Print(x*) {
		p(x*)
	}
	
	Free() {
		this.Uploader := ""
		this.Events := ""
	}
	
	; create new ImageType instance used for uploading images
	Image(File := "") {
		return new Imgur.ImageType(this, File)
	}
	
	; upload image
	Upload(Image, Callback := "") {
		; check the Image parameter is an Image type
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.Errors.TypeError("Input has to be an Imgur.ImageType instance.")
		
		; throw ClientMismatch if Image stems from another client
		if (&(Image.Client) != &this)
			throw new Imgur.Errors.ClientMismatch
		
		Image.Upload(Callback)
	}
	
	GetImage(ImageHash, Callback := "") {
		Image := this.Image(ImageHash)
		Image.Get(Callback)
	}
	
	/*
		register an event.
		
		valid events:
		OnUploadResponse - runs when an image upload response is received
		OnUploadProgress - runs when an image being uploaded progresses
		OnGetImageResponse - runs when a GetImage request returns a response
	*/
	RegisterEvent(Event, Func) {
		this.Events[Event].Push(Func)
	}
	
	; clear a type of event
	ClearEvent(Event) {
		this.Events[Event] := []
	}
	
	/*
		!!! PRIVATE METHODS !!!
	*/
	
	/*
		call an event.
		
		callback provided? the event should not be raised.
		not? then run the event.
	*/
	CallEvent(Event, Callback, Param*) {
		if Callback
			Callback.Call(Param*)
		else
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