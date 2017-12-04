Class Imgur {
	
	Print(x*) {
		static Print := Func("p")
		try Print.Call(x*)
	}
	
	Events := {"OnUploadProgress": [], "OnUploadSuccess": [], "OnUploadFail": []}
	
	__New(client_id) {
		this.client_id := client_id
		this.Errors.Client := this
		this.Worker := new Imgur.Worker(this)
		
		this.Print("New client created with key " this.client_id)
	}
	
	; upload image
	Upload(Image) {
		; check the input passed is an ImageType instance
		if !IsInstance(Image, Imgur.ImageType)
			throw new Imgur.Errors.TypeError("Input has to be Imgur.ImageType")
		
		; make sure the ImageType instance was instantiated from this Client
		if (&(Image.Client) != &this)
			throw new Imgur.Errors.ClientMismatch
		
		this.Print("Uploading image: " Image.File)
		
		for i, f in this.Events.OnUploadSuccess
			f.Call(Image)
	}
	
	; create new ImageType instance
	Image(File) {
		return new Imgur.ImageType(this, File)
	}
	
	RegisterEvent(Event, Func) {
		this.Events[Event].Push(Func)
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