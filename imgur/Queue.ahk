Class Queue extends IndirectReferenceCompatible {
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
				;t(this.Queue.MaxIndex())
			}
		} else {
			this.Busy := false
		}
	}
}