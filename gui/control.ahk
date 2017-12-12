Class ControlType {
	__New(Gui, Options := "", Text := "") {
		this.Gui := Gui
		this.Type := SubStr(this.base.__Class, 9, -7)
		
		Gui % this.Gui.hwnd ":Add", % this.Type, % "hwndhwnd " CraftOptions(Options), % Text
		this.hwnd := hwnd
		
		this.Pos := new GuiBase.ControlPosition(this.hwnd)
		
		p(this.base.__Class " created")
	}
	
	__Delete() {
		p(this.base.__Class " destroyed")
	}
	
	OnEvent(Func) {
		GuiControl, +g, % this.hwnd, % Func
	}
}