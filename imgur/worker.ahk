Class WorkerBase {
	;#Include imgur\queuer.ahk
	
	__New(Client) {
		if !File := FileOpen("imgur\http.ahk", "r")
			throw new Imgur.Errors.WorkerLaunchFailure("Failed opening File Object")
		
		this.Queue := []
		this.Busy := false
		
		this.Script := File.Read()
		File.Close()
		
		this.Client := Client
		this.Print := this.Client.Print
		
		this.Thread := AhkThread("global Client := ObjShare(" ObjShare(this.Client) ")`n" this.Script)
		sleep 200
		this.Print("Worker started")
	}
	
	Next(Pop := false) {
		if Pop
			this.Queue.RemoveAt(1)
		if this.Busy && !this.Queue.Length()
			return this.Busy := false
		if this.Queue.Length()
			this.Busy := true, this.Queue[1].Call()
		else
			this.Busy := false
	}
	
	Upload(Image) {
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.Errors.TypeError("Input has to be instance of Imgur.ImageType")
		
		this.Print("Added image upload to queue (" Image.File ")")
		this.Queue.Push(this.UploadGo.Bind(this, Image))
		if !this.Busy
			this.Next()
	}
	
	UploadGo(Image) {
		this.Print("Uploading image (" Image.File ")")
		ImageShare := ObjShare(Image)
		Callback := ObjShare(this.UploadProgress.Bind(this, Image))
		this.Thread.ahkPostFunction("Upload", ImageShare, Callback)
	}
	
	UploadProgress(Image, Current, Total) {
		this.Client.CallEvent("OnUploadProgress", Image, Current, Total)
	}
	
	UploadSuccess(Image, Data) {
		try
			DataObj := JSON.Load(Data)
		catch e
			throw new Imgur.Errors.MalformedJSON(e.Message)
		
		for Key, Value in DataObj.data
			Image[Key] := Value
		
		this.Print("Image successfully uploaded (" Image.File ", " Image.id ")")
		
		this.Client.CallEvent("OnUploadSuccess", Image)
		this.Next(true)
	}
	
	UploadFailure(Image, Error := "") {
		this.Print("Image upload failed (" Image.File ")")
		
		this.Client.CallEvent("OnUploadFailure", Image, Error)
		this.Next(true)
	}
}