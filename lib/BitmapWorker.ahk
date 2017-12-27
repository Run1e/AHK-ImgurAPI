; this uses the Imgur.Queue bundled with the Imgur library.

Class BitmapWorker extends Imgur.Queue {
	__New(Width, Height, Debug := "") {
		try {
			this.Thread := AhkThread(FileOpen("lib\BitmapThread.ahk", "r").Read())
			Loop 30
				sleep 20
			until this.Thread.ahkgetvar.finished			
		} catch e
			throw Exception("Failed starting BitmapThread", {Error: e})
		
		this.SafeReference := new IndirectReference(this)
		
		this.Width := Width
		this.Height := Height
		this.Debug := Debug
		
		this.Print(this.__Class " created")
	}
	
	__Delete() {
		ahkthread_free(this.BitmapWorker.Thread)
		this.BitmapWorker.Thread := ""
		this.Print(this.__Class " released")
	}
	
	SafeRef {
		get {
			return this.SafeReference
		}
	}
	
	Print(x*) {
		this.Debug.Call(x*)
	} 
	
	Add(File, Callback) { ; *to queue
		this.AddQueue(this.SafeRef.Go.Bind(this.SafeRef, File, Callback, this.Width, this.Height))
		this.Next()
	}
	
	Go(File, Callback, Width, Height) {
		Callback := ObjShare(Callback)
		this.Thread.ahkPostFunction("CreateBitmap", File, Callback, Width, Height)
	}
}