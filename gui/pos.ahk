Class WindowPosition extends GuiBase.Position {
	Set(Coord, Val) {
		Gui := Object(GuiBase.Guis[this.hwnd])
		Gui.Show([{(Coord): Val}, (Gui.Visible ? "" : "Hide")])
	}
	
	Get(Coord) {
		WinGetPos, x, y, w, h, % "ahk_id" this.hwnd
		return _:=%Coord%
	}
}

Class ControlPosition extends GuiBase.Position {
	Set(Coord, Val) {
		GuiControl, MoveDraw, % this.hwnd, % Coord . Val
	}
	
	Get(Coord) {
		ControlGetPos, x, y, w, h,, % "ahk_id" this.hwnd
		return _:=%Coord%
	}
}

Class Position {
	__New(hwnd) {
		this.hwnd := hwnd
	}
	
	X {
		set {
			this.Set("X", value)
		}
		
		get {
			return this.Get("X")
		}
	}
	
	Y {
		set {
			this.Set("Y", value)
		}
		
		get {
			return this.Get("Y")
		}
	}
	
	W {
		set {
			this.Set("W", value)
		}
		
		get {
			return this.Get("W")
		}
	}
	
	H {
		set {
			this.Set("H", value)
		}
		
		get {
			return this.Get("Z")
		}
	}
}