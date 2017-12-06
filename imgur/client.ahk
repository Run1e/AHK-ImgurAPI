#Include imgur\lib\third-party\Class JSON.ahk

Class Imgur {
	
	#Include imgur\worker.ahk
	#Include imgur\image.ahk
	#Include imgur\errors.ahk
	
	static Endpoint := "https://api.imgur.com/3/"
	
	Print(x*) {
		static Print := Func("p")
		try Print.Call(x*)
	}
	
	
	__New(client_id) {
		this.Print("Creating new client with key " client_id)
		this.client_id := client_id
		this.Worker := new Imgur.WorkerBase(this)
		this.Events := 
		(LTrim Join
		{
			OnUploadProgress: [],
			OnUploadSuccess: [],
			OnUploadFailure: []
		}
		)
	}
	
	__Delete() {
		this.Print("Client instance removed")
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
		
		this.Worker.Upload(Image)
	}
	
	; create new ImageType instance
	Image(File) {
		return new Imgur.ImageType(this, File)
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