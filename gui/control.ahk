Class ControlType {
	__New(Gui, Options := "", Text := "") {
		this.Gui := new indirectReference(Gui)
		
		Gui % this.Gui.hwnd ":Add", % this.Type, % "hwndhwnd " Options, % Text
		this.hwnd := hwnd
		this.Position := new GuiBase.ControlPosition(this.hwnd)
		
		this.Init()
		
		this.Gui.Print(type(this) " created")
	}
	
	__Delete() {
		GuiControl, -g, % this.hwnd
		this.Gui.Print(type(this) " destroyed")
	}
	
	Pos {
		get {
			return this.Position
		}
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