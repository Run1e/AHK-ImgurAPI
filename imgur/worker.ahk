Class WorkerBase {
	__New(Client) {
		if !File := FileOpen("imgur\http.ahk", "r")
			throw new Imgur.Errors.WorkerLaunchFailure
		
		this.Script := File.Read()
		File.Close()
		
		this.Client := Client
		
		this.Thread := AhkThread("global Client := ObjShare(" ObjShare(this.Client) ")`n" this.Script)
		sleep 500
	}
	
	POST(Endpoint, Data, Headers) {
		URL := this.API . Endpoint
	}
	
	GET(Endpoint, Data, Headers) {
		
	}
	
	UPLOAD(Image) {
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.Errors.TypeError("Input has to be Imgur.ImageType")
		
		Image := ObjShare(Image)
		Callback := ObjShare(this.UploadProgress.Bind(this, Image))
		this.Thread.ahkPostFunction("UPLOAD", Image, Callback)
	}
	
	UploadProgress(Image, Current, Total) {
		this.Client.CallEvent("OnUploadProgress", Image, Current, Total)
	}
	
	UploadSuccess(Image, Data) {
		DataObj := JSON.Load(Data)
		
		for Key, Value in DataObj.data
			Image[Key] := Value
		
		this.Client.CallEvent("OnUploadSuccess", Image)
	}
	
	UploadFailure(Image, Error := "") {
		m(error)
	}
}