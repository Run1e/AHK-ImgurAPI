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
		if (Image.base.__Class != "Imgur.ImageType")
			throw Exception("Input has to be an instance of Imgur.ImageType", -1)
		
	}
}

/*
	this.Thread.ahkPostFunction[]
	
	POST {
		Endpoint
		Headers
	}
*/