Class Request {
	Class Get extends Request.RequestBase {
		Method := "GET"
	}
	
	Class Post extends Request.RequestBase {
		Method := "POST"
	}
	
	Class RequestBase {
		__New(URL, Callback, Debug := "") {
			try
				this.Script := FileOpen(A_LineFile "\..\requestthread.ahk", "r").Read()
			catch e
				throw Exception("Failed reading thread script data", -1, this.ThreadFile)
			
			this.URL := URL
			this.Callback := Callback
			this.Headers := {}
			this.Debug := Debug
			
			this.Print(type(this) " created: " URL)
		}
		
		__Delete() {
			this.Print(type(this) " destroyed")
		}
		
		Print(x*) {
			try this.Debug.Call(x*)
		}
		
		SetHeader(Header, Value) {
			this.Headers[Header] := Value
			this.Print(type(this) ".SetHeader: " Header " -> " Value)
		}
		
		Send() {
			this.Thread := AhkThread(this.Script)
			
			while !(this.Thread.ahkgetvar.Ready)
				continue
			
			Response := new Request.Response(this.Callback, this.Debug)
			Response.Request := this
			ResponseShare := ObjShare(Response)
			
			this.Thread.ahkFunction("SetResponse", ResponseShare)
			this.Thread.ahkFunction("SetMethod", this.Method)
			this.Thread.ahkFunction("SetURL", this.URL)
			this.Thread.ahkFunction("SetTimeout", 10)
			
			for Header, Value in this.Headers
				this.Thread.ahkFunction("AddHeader", Header, Value)
			
			this.Thread.ahkPostFunction("Send")
			
			this.Print(type(this) ".Send")
		}
	}
	
	Class Response {
		Headers := {}
		
		__New(Callback, Debug := "") {
			this.Callback := Callback
			this.Debug := Debug
			
			this.Debug.Call(type(this) " created")
		}
		
		__Delete() {
			this.Debug.Call(type(this) " destroyed")
		}
		
		SetError(Error) {
			Error := ObjShare(Error)
			this.Error := {Message: Error.Message, What: Error.What, Extra: Error.Extra}
			this.Go()
		}
		
		Go() {
			this.Callback.Call(this)
		}
	}
}