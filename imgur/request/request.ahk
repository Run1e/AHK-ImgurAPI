Class Request {
	Class RequestBase {
		ThreadFile := A_LineFile "\..\requestthread.ahk"
		
		__New(URL) {
			try
				this.Script := FileOpen(this.ThreadFile, "r").Read()
			catch e
				throw Exception("Failed reading thread script data", -1, this.ThreadFile)
			
			this.URL := URL
			this.Thread := AhkThread(this.Script)
			
			while !(this.Thread.ahkgetvar.Ready)
				continue
			
			this.Thread.ahkFunction("SetMethod", this.Method)
			this.Thread.ahkFunction("SetURL", URL)
			this.Thread.ahkFunction("Open")
			this.Thread.ahkFunction("AddHeader", "Content-Type", "application/x-www-form-urlencoded")
			Callback := ObjShare(this.Response.Bind(this))
			this.Thread.ahkFunction("SetCallback", Callback)
		}
		
		__Delete() {
			ahkthread_free(this.Thread)
			this.Thread := ""
		}
		
		AddHeader(Header, Value) {
			this.Thread.ahkFunction("AddHeader", Header, Value)
		}
		
		Response(Data, Headers) {
			try this.Callback.Call(Data, Headers, Error)
			ahkthread_free(this.Thread)
			this.Thread := ""
		}
		
		OnResponse(Func) {
			this.Callback := Func
		}
		
		Send() {
			this.Thread.ahkPostFunction("Send")
		}
	}
	
	Class Get extends Request.RequestBase {
		Method := "GET"
	}
	
	Class Post extends Request.RequestBase {
		Method := "POST"
	}
}