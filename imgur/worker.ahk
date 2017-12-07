Class Worker {
	__New(Client) {
		if !File := FileOpen(this.ThreadFile, "r")
			throw new Imgur.Errors.WorkerLaunchFailure("Failed opening " this.ThreadFile)
		
		this.Client := Client
		this.Print := this.Client.Print
		
		this.Queue := []
		this.Busy := false
		
		for var, val in {Client: Client, Worker: this}
			this.Script .= "global " var " := ObjShare(" ObjShare(val) ")`n"
		
		this.Script .= File.Read()
		File.Close()
		
		this.Thread := AhkThread(this.Script)
		
		; wait max of ~600ms
		Loop 30
			sleep 20
		until this.Thread.ahkgetvar.finished
		
		this.Print("Worker started: " this.ThreadFile)
	}
	
	__Delete() {
		ahkthread_free(this.Thread)
		this.Thread := ""
	}
	
	Next(Pop := false) {
		if Pop
			this.Queue.RemoveAt(1)
		if this.Busy && !this.Queue.Length()
			return this.Busy := false
		if this.Queue.Length()
			this.Busy := true, this.Queue[1].Call()
		else
			this.Busy := false
	}
}