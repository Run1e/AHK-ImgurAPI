Class Request {
	static _Init := Request.Init()
	
	SetDebug(Func) {
		this.RequestBase.Debug := Func
	}
	
	Init() {
		try
			Request.RequestBase.Script := FileOpen(A_LineFile "\..\RequestThread.ahk", "r").Read()
		catch e
			throw Exception(this.__Class " init failure", -1, e.Message)
	}
	
	Class Get extends Request.RequestBase {
		Method := "GET"
	}
	
	Class Post extends Request.RequestBase {
		Method := "POST"
	}
	
	Class RequestBase {
		__New(URL, Callback) {
			this.URL := URL
			this.Timeout := 5
			this.Callback := Callback
			this.Headers := {}
			
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
		
		; put headers into a remote object
		PutHeaders(ObjShare) {
			Obj := ObjShare(ObjShare)
			for Header, Value in this.Headers
				Obj[Header] := Value
		}
		
		Send() {
			this.Thread := AhkThread(this.Script)
			
			/*
				while !(this.Thread.ahkgetvar.Ready)
					continue
			*/
			
			sleep 100
			
			this.Response := {Headers: {}}
			thisShare := ObjShare(this)
			
			this.Thread.ahkPostFunction("Send", thisShare)
			
			this.Print(this.__Class ".Send: " this.URL)
		}
		
		ThreadCallback() {
			Response := this.Response
			this.Response := ""
			Response.Request := this
			Error := Response.Delete("Error")
			if IsObject(Error) {
				Error :=
				( LTrim Join
				{
					Message: Error.Message,
					What: Error.What,
					Extra: Error.Extra
				}
				)
			}
			; start a new thread here so we can safely free the worker thread
			OnResponse := this.OnResponse.Bind(this, Response, Error)
			SetTimer, % OnResponse, -1
		}
		
		OnResponse(Response, Error) {
			ahkthread_free(this.Thread)
			this.Thread := ""
			this.Print(this.__Class ".OnResponse: " Response.Status " (" Response.StatusText ")")
			this.Callback.Call(Response, Error)
		}
	}
}