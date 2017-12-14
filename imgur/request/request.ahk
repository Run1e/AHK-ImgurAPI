Class Request {
	Class Response {
		Headers := {}
		
		__New(Callback) {
			this.Callback := Callback
			
			p(type(this) " created")
		}
		
		__Delete() {
			p(type(this) " destroyed")
		}
		
		SetError(Error) {
			this.Error := {Message: Error.Message, What: Error.What, Extra: Error.Extra}
		}
		
		Go() {
			this.Callback.Call(this)
		}
	}
	
	Class Get extends Request.RequestBase {
		Method := "GET"
	}
	
	Class Post extends Request.RequestBase {
		Method := "POST"
	}
	
	Class RequestBase {
		ThreadFile := A_LineFile "\..\requestthread.ahk"
		
		__New(URL, Callback) {
			try
				this.Script := FileOpen(this.ThreadFile, "r").Read()
			catch e
				throw Exception("Failed reading thread script data", -1, this.ThreadFile)
			
			this.URL := URL
			this.Callback := Callback
			this.Headers := {}
			
			this.Print(type(this) " created")
		}
		
		__Delete() {
			this.Print(type(this) " destroyed")
		}
		
		Print(x*) {
			p(x*)
		}
		
		OnResponse(Callback) {
			this.Callback := Callback
		}
		
		SetHeader(Header, Value) {
			this.Headers[Header] := Value
		}
		
		SetMethod(Method) {
			this.Method := Method
		}
		
		Send() {
			this.Thread := AhkThread(this.Script)
			
			while !(this.Thread.ahkgetvar.Ready)
				continue
			
			this.Thread.ahkFunction("SetMethod", this.Method)
			this.Thread.ahkFunction("SetURL", this.URL)
			
			this.Thread.ahkFunction("Open")
			
			for Header, Value in this.Headers
				this.Thread.ahkFunction("AddHeader", Header, Value)
			
			Response := new Request.Response(this.Callback)
			Response.Request := this
			ResponseShare := ObjShare(Response)
			
			this.Thread.ahkFunction("SetResponse", ResponseShare)
			this.Thread.ahkPostFunction("Send")
		}
	}
}