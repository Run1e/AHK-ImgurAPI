; libs
#Include %A_LineFile%\..\lib\third-party\JSON.ahk
#Include %A_LineFile%\..\request\request.ahk

Class Imgur {
	
	; misc 
	#Include %A_LineFile%\..\errors.ahk
	#Include %A_LineFile%\..\clientchild.ahk
	#Include %A_LineFile%\..\uploadworker.ahk
	
	; types
	#Include %A_LineFile%\..\image.ahk
	
	; imgurs API endpoint
	static Endpoint := "https://api.imgur.com/3/"
	
	__New(client_id) {
		this.apikey := client_id
		
		; holds arrays of events for each event
		this.Events := 
		(LTrim Join
		{
			UploadResponse: [],
			UploadProgress: [],
			GetImageResponse: []
		}
		)
		
		; create the image upload worker
		this.Uploader := new Imgur.UploadWorker(this)
		
		this.Print(type(this) " created")
	}
	
	__Delete() {
		this.Uploader := ""
		this.Print(type(this) " destroyed")
	}
	
	Print(x*) {
		p(x*)
	}
	
	; shorthand for new Imgur.ImageType(Instance, File)
	Image(File := "") {
		return new Imgur.ImageType(this, File)
	}
	
	; upload image
	Upload(Image, Callback := "") {
		; check the Image parameter is an Image type
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.TypeError("Input has to be an Imgur.ImageType instance.")
		
		; throw ClientMismatch if Image stems from another client
		if (&(Image.Client) != &this)
			throw new Imgur.ClientMismatch
		
		Image.Upload(Callback)
	}
	
	GetImage(ImageHash, Callback := "") {
		if isinstance(ImageHash, Imgur.ImageType)
			Image := ImageHash
		else
			Image := this.Image(ImageHash)
		Image.Get(Callback)
	}
	
	/*
		register an event.
		
		valid events:
		UploadResponse - runs when an image upload response is received
		UploadProgress - runs when an image being uploaded progresses
		GetImageResponse - runs when a GetImage request returns a response
	*/
	OnEvent(Event, Func) {
		this.Events[Event].Push(Func)
	}
	
	; clear a type of event
	ClearEvent(Event) {
		this.Events[Event] := []
	}
	
	/*
		!!! PRIVATE METHODS !!!
	*/
	
	ParseResponse(Resp) {
		Data := JSON.Load(Resp.ResponseText)
		return Data
	}
	
	/*
		call an event.
		
		callback provided? the event should not be raised.
		not? then run the event.
	*/
	CallEvent(Event, Callback, Param*) {
		if Callback
			Callback.Call(Param*)
		else
			for Index, EventFunc in this.Events[Event]
				EventFunc.Call(Param*)
	}
}

; checks if Instance is an instance of Class
isinstance(instance, base) {
	return type(instance) = base.__Class
}

type(instance) {
	return instance.base.__Class
}

; checks if a normal array has a value
ArrayHasValue(Array, Value) {
	for k, v in Array
		if (v = Value)
			return true
	return false
}