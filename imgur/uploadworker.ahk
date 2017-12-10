Class UploadWorker extends Imgur.Worker {
	ThreadFile := "imgur\uploadthread.ahk"
	
	Upload(Image, Callback := "") {
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.Errors.TypeError("Input has to be instance of Imgur.ImageType")
		
		this.Print("Added image upload to queue (" Image.File ")")
		
		this.Queue.Push(this.UploadGo.Bind(this, Image, Callback))
		
		if !this.Busy
			this.Next()
	}
	
	UploadGo(Image, Callback) {
		this.Print("Uploading image (" Image.File ")")
		
		ImageShare := ObjShare(Image)
		CallbackShare := ObjShare(this.Client.UploadResponse.Bind(this, Image, Callback))
		CallbackProgressShare := ObjShare(this.UploadProgress.Bind(this, Image))
		
		this.Thread.ahkPostFunction("Upload", ImageShare, CallbackShare, CallbackProgressShare)
	}
	
	UploadProgress(Image, Current, Total) {
		this.Client.CallEvent("OnUploadProgress", "", Image, Current, Total)
	}
}