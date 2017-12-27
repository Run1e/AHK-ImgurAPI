Class Queue {
	Queue := []
	Busy := false
	
	AddQueue(Do) {
		this.Queue.Push(Do)
	}
	
	Next(Pop := false) {
		; remove the last queue item if told to
		if Pop
			this.Queue.RemoveAt(1)
		
		if this.Queue.Length() {
			if !this.Busy or Pop {
				this.Busy := true
				Func := this.Queue[1]
				SetTimer % Func, -1
			}
		} else {
			this.Busy := false
		}
	}
}