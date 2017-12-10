Class UploadWorker {
	
	__New(Client) {
		; the code of the worker thread
		this.ThreadFile := A_LineFile "\..\uploadthread.ahk"
		
		; throw WorkerLaunchFailure if we fail at reading the file
		if !File := FileOpen(this.ThreadFile, "r")
			throw new Imgur.Errors.WorkerLaunchFailure("Failed opening " this.ThreadFile)
		
		this.Client := Client
		this.Print := this.Client.Print
		
		this.Queue := []
		this.Busy := false
		
		; set up the environment variables for the worker
		for var, val in {Client: Client, Worker: this}
			this.Script .= "global " var " := ObjShare(" ObjShare(val) ")`n"
		
		; read the file contents and close file object
		this.Script .= File.Read()
		File.Close()
		
		; launch thread
		this.Thread := AhkThread(this.Script)
		
		; wait until thread if finished initiating, max of ~600ms
		Loop 30
			sleep 20
		until this.Thread.ahkgetvar.finished
		
		this.Print("Worker started: " this.ThreadFile)
	}
	
	; move to the next item in the queue
	Next(Pop := false) {
		; remove the last queue item if told to
		if Pop
			this.Queue.RemoveAt(1)
		; stop queue if there's nothing left
		if this.Busy && !this.Queue.Length()
			return this.Busy := false
		; otherwise, call the next queue boundfunc and set this.Busy accordingly
		if this.Queue.Length()
			this.Busy := true, this.Queue[1].Call()
		else
			this.Busy := false
	}
	
	; add an image to the upload queue
	Upload(Image, Callback := "") {
		
		; make sure the Image provided is ImageType
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.Errors.TypeError("Input has to be instance of Imgur.ImageType")
		
		this.Print("Added image upload to queue (" Image.File ")")
		
		; push the boundfunc containing this Image and callback to the queue
		this.Queue.Push(this.UploadGo.Bind(this, Image, Callback))
		
		; start the queue if it's idle
		if !this.Busy
			this.Next()
	}
	
	; tell worker thread to upload
	UploadGo(Image, Callback) {
		this.Print("Uploading image (" Image.File ")")
		
		; make objects ready for sharing with uploader thread
		ImageShare := ObjShare(Image)
		CallbackShare := ObjShare(Image.UploadResponse.Bind(Image, Callback))
		CallbackProgressShare := ObjShare(Image.UploadProgress.Bind(Image))
		
		; tell the workerthread to upload the image
		this.Thread.ahkPostFunction("Upload", ImageShare, CallbackShare, CallbackProgressShare)
	}
}