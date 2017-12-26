Class Request {
	Class Get extends Request.RequestBase {
		Method := "GET"
	}
	
	Class Post extends Request.RequestBase {
		Method := "POST"
	}
	
	Class RequestBase {
		__New(URL, Callback, Debug := "") {
			if !this.Script {
				try
					this.base.Script := FileOpen(A_LineFile "\..\RequestThread.ahk", "r").Read()
				catch e
					throw Exception("Failed reading thread script data", -1)
			}
			
			this.URL := URL
			this.Callback := Callback
			this.Headers := {}
			this.Debug := Debug
			
			this.Print(this.__Class " created: " URL)
		}
		
		__Delete() {
			this.Print(this.__Class " destroyed")
		}
		
		Print(x*) {
			try this.Debug.Call(x*)
		}
		
		SetHeader(Header, Value) {
			this.Headers[Header] := Value
			this.Print(this.__Class ".SetHeader: " Header " -> " Value)
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
			
			this.Print(this.__Class ".Send")
		}
	}
	
	Class Response {
		Headers := {}
		
		__New(Callback, Debug := "") {
			this.Callback := Callback
			this.Debug := Debug
			
			this.Debug.Call(this.__Class " created")
		}
		
		__Delete() {
			this.Debug.Call(this.__Class " destroyed")
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