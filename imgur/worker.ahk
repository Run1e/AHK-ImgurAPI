Class Worker {
	static API := "https://api.imgur.com/3/"
	
	__New(Client) {
		this.Client := Client
		;this.Thread := AhkThread()
	}
	
	POST(Endpoint, Data, Headers) {
		URL := this.API . Endpoint
	}
	
	GET(Endpoint, Data, Headers) {
		
	}
	
	UPLOAD(Image) {
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.Errors.TypeError("Input has to be Imgur.ImageType")
		
	}
}

/*
	this.Thread.ahkPostFunction[]
	
	POST {
		Endpoint
		Headers
	}
*/