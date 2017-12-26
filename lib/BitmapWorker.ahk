; this uses the Imgur.Queue bundled with the Imgur library.

Class BitmapWorker extends Imgur.Queue {
	__New(Width, Height) {
		try {
			this.Thread := AhkThread(FileOpen("lib\BitmapThread.ahk", "r").Read())
			Loop 30
				sleep 20
			until this.Thread.ahkgetvar.finished			
		} catch e
			throw Exception("Failed starting BitmapThread", {Error: e})
		
		this.Width := Width
		this.Height := Height
	}
	
	__Delete() {
		m("sup")
	}
	
	Add(File, Callback) { ; *to queue
		this.AddQueue(this.Go.Bind(this, File, Callback, this.Width, this.Height))
		this.Next()
	}
	
	Go(File, Callback, Width, Height) {
		Callback := ObjShare(Callback)
		this.Thread.ahkPostFunction("CreateBitmap", File, Callback, Width, Height)
	}
}