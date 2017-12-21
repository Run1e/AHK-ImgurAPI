m(x*) {
	msgbox % Debug.Printer(x*)
}

p(x*) {
	static First := true ; haha hackety fuckin hack
	Debug.Print((First ? ("", First := false) : "`n") . Debug.Printer(x*))
}

t(x*) {
	static thisfunc := Func("t")
	tooltip % x ? Debug.Printer(x*) : ""
	SetTimer, % thisfunc, % x ? 3500 : "Off"
}

Class Debug {
	__New() {
		static instance := new Debug()
		if instance
			return instance
		class := this.__Class
		%class% := this
		
		try
			Studio := ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
		catch e
			return this.StudioNotRunning()
		
		this.Pane := Studio.GetDebugPane()
		
		;this.Clear()
		this.Show()
	}
	
	Print(Print*) {
		this.Pane.Print(Debug.Printer(Print*))
	}
	
	Clear() {
		this.Pane.Clear()
	}
	Show() {
		this.Pane.Show()
	}
	Hide() {
		this.Pane.Hide()
	}
	
	StudioNotRunning() {
		; runs if program runs and it couldn't connect to the studio output pane
	}
	
	Class Printer extends Debug.Functor {
		static IgnoreKeys := {Client: 0, Thread: 0, Script: 0}
		static Indent := "    "
		static OpenClose := ["[", "]"]
		static Arrow := "->"
		
		Call(Print*) {
			for Index, Value in Print
				text .= "`n" . (IsObject(Value) ? this.Object(Value) : Value)
			return SubStr(text, 2)
		}
		
		Object(Object, Depth := 5, Indent := "", Seen := "") {
			if !Seen
				Seen := []
			if Depth
				try {
					for Key, Value in Object {
						if this.IgnoreKeys.HasKey(Key)
							continue
						out .= "`n" Indent this.OpenClose.1 Key this.OpenClose.2
						if IsObject(Value) {
							if Seen.HasKey(&Value) {
								out .= " " this.Arrow " SKIP"
								continue
							} Seen[&Value] := ""
							out .= "`n" this.Object(Value, Depth - 1, Indent this.Indent, Seen)	
						} else
							out .= " " this.Arrow " " Value
					}
				}
			return SubStr(out, 2) "`n"
		}
	}
	
	Class Log extends Debug.Functor {
		static LogFolder := A_ScriptDir "\logs" 
		
		Call(Exception) {
			if !FileExist(this.LogFolder)
				FileCreateDir % this.LogFolder
			this.Exception(Exception)
		}
		
		Exception(ex, data := "") {
			Format := A_Hour ":" A_Min ":" A_Sec " (" A_DD "/" A_MM "/" A_YYYY ")"
			. "`n`nMessage: " ex.Remove("Message")
			. "`nWhat: " ex.Remove("What")
			. "`nFile: " ex.Remove("File")
			. "`nLine: " ex.Remove("Line")
			
			if StrLen(ex.Extra)
				Format .= "`n`nExtra:`n" ex.Remove("Extra")
			
			for junk in ex {
				Format .= "`n`nAdditional:`n" Debug.Printer(ex)
				break
			}
			
			if IsObject(data)
				Format .= "`n`nObject(s) dump:`n" Debug.Printer(data)
			
			FileOpen(this.LogFolder "\" A_Now A_MSec ".txt", "w").Write(StrReplace(Format, "`n", "`r`n"))
		}
		
		Folder(Folder) {
			this.LogFolder := Folder
		}
	}
	
	Class Functor {
		__Call(Type, Param*) {
			return (new this).Call(Param*)
		}
	}
}

Class Timer {
	__New() {
		static instance := new Timer()
		if instance
			return instance
		class := this.__Class
		%class% := this
		
		DllCall("QueryPerformanceFrequency", "Int64P", F)
		this.Freq := F
		this.Timers := {}
	}
	
	Current() {
		DllCall("QueryPerformanceCounter", "Int64P", Current)
		return Current / this.Freq
	}
	
	Start(ID) {
		this.Timers[ID] := this.Current()
	}
	
	Stop(ID) {
		return (this.Current() - this.Timers[ID]), this.Timers.Delete(ID)
	}
}