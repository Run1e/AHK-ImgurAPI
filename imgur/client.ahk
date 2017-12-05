Class Imgur {
	
	Print(x*) {
		static Print := Func("p")
		try Print.Call(x*)
	}
	
	
	__New(client_id) {
		this.client_id := client_id
		this.Worker := new Imgur.Worker(this)
		this.Events := {"OnUploadProgress": [], "OnUploadSuccess": [], "OnUploadFail": []}
		
		this.Print("New client created with key " this.client_id)
	}
	
	__Delete() {
		this.Print("Client instance removed.")
	}
	
	Free() {
		this.Worker := ""
		this.Events := ""
	}
	
	; upload image
	Upload(Image) {
		; check the input passed is an ImageType instance
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.Errors.TypeError("Input has to be an Imgur.ImageType instance.")
		
		; make sure the ImageType instance was instantiated from this Client
		if (&(Image.Client) != &this)
			throw new Imgur.Errors.ClientMismatch
		
		if !FileExist(Image.File)
			throw new Imgur.Errors.MissingFileError(Image.File)
		
		this.Print("Uploading image: " Image.File)
		
		this.CallEvent("OnUploadSuccess", Image)
	}
	
	; create new ImageType instance
	Image(File) {
		return new Imgur.ImageType(this, File)
	}
	
	CallEvent(Event, Param*) {
		this.Print("Event: " Event, Param*)
		for i, f in this.Events[Event]
			f.Call(Param*)
	}
	
	RegisterEvent(Event, Func) {
		this.Events[Event].Push(Func)
	}
	
	ClearEvent(Event) {
		this.Events[Event] := []
	}
	
	#Include imgur\worker.ahk
	#Include imgur\image.ahk
	#Include imgur\errors.ahk
}

; checks if Instance is an instance of Class
IsInstance(Instance, Base) {
	return Instance.base.__Class = Base.__Class
}

; checks if a normal array has a value
ArrayHasValue(Array, Value) {
	for k, v in Array
		if (v = Value)
			return true
	return false
}