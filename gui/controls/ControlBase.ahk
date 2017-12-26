Class ControlBase {
	__New(Gui, Options := "", Text := "") {
		this.Gui := new indirectReference(Gui)
		
		Gui % this.Gui.hwnd ":Add", % this.Type, % "hwndhwnd " Options, % Text
		this.hwnd := hwnd
		this.Position := new GuiBase.ControlPosition(this.hwnd)
		
		this.Init()
		
		this.Gui.Print(this.__Class " created")
	}
	
	__Delete() {
		GuiControl, -g, % this.hwnd
		this.Gui.Print(this.__Class " destroyed")
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
			GuiControl, +g, % this.hwnd, % Func
		else
			GuiControl, -g, % this.hwnd
	}
}