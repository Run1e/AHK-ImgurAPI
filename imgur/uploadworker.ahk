Class UploadWorker extends Imgur.Worker {
	ThreadFile := "imgur\uploadthread.ahk"
	
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