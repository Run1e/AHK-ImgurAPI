Class ControlType {
	__New(Gui, Options := "", Text := "") {
		this.Gui := Gui
		Gui % this.Gui.hwnd ":Add", % this.Type, % "hwndhwnd " Options, % Text
		this.hwnd := hwnd
		this.Position := this.Pos := new GuiBase.ControlPosition(this.hwnd)
		
		this.Init()
		
		p(this.base.__Class " created")
	}
	
	__Delete() {
		p(this.base.__Class " destroyed")
	}
	
	OnEvent(Func) {
		GuiControl, +g, % this.hwnd, % Func
	}
}