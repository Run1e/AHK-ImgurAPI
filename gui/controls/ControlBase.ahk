Class ControlBase {
	__New(Gui, Options := "", Text := "") {
		this.Gui := new IndirectReference(Gui)
		
		Gui % this.Gui.hwnd ":Add", % this.Type, % "hwndhwnd " Options, % Text
		this.hwnd := hwnd
		this.Position := new GuiBase.ControlPosition(this.hwnd)
		
		this.Gui.Print(this.__Class " created")
	}
	
	__Delete() {
		this.Gui.Print(this.__Class " released")
	}
	
	Pos {
		get {
			return this.Position
		}
	}
	
	Options(Options) {
		GuiControl % this.Gui.hwnd ":" this.Gui.CraftOptions(Options), % this.hwnd
	}
	
	Control(Command := "", ControlOptions := "") {
		GuiControl % this.Gui.hwnd ":" Command, % this.hwnd, % ControlOptions
	}
	
	SetText(Text := "") {
		GuiControl,, % this.hwnd, % Text
	}
	
	GetText() {
		ControlGetText, ControlText,, % "ahk_id" this.hwnd
		return ControlText
	}
	
	OnEvent(Func := "") {
		if Func
			this.Gui.Control("+g", this, Func)
		else
			this.Gui.Control("-g", this)
	}
}