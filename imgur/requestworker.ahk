Class RequestWorker extends Imgur.Worker {
	ThreadFile := "imgur\requestthread.ahk"

	Get(Path, Callback) {
		this.Queue.Push()
	}
	
	Post(Path, Post, Callback) {
		
	}
	
	GetGo(Path, Callback) {
		
	}
	
	PostGo(Path, Callback) {
		
	}
}