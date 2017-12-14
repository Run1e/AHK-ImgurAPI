Class ControlType {
	__New(Gui, Options := "", Text := "") {
		this.Gui := Gui
		Gui % this.Gui.hwnd ":Add", % this.Type, % "hwndhwnd " Options, % Text
		this.hwnd := hwnd
		this.Position := this.Pos := new GuiBase.ControlPosition(this.hwnd)
		
		this.Init()
		
		p(type(this) " created")
	}
	
	__Delete() {
		GuiControl, -g, % this.hwnd
		p(type(this) " destroyed")
	}
	
	SetText(Text := "") {
		this.Gui.Control(, this.hwnd, Text)
	}
	
	GetText() {
		ControlGetText, ControlText,, % "ahk_id" this.hwnd
		return ControlText
	}
	
	OnEvent(Func) {
		GuiControl, +g, % this.hwnd, % Func
	}
}