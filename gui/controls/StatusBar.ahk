Class StatusBar {
	__New(Parent, Options, Text, Function := "") {
		this.Parent := Parent
		this.hwnd := Parent.Add("StatusBar", Options, Text, Function)
		return this
	}
	
	SetText(NewText, PartNumber := 1, Style := "") {
		this.SetDefault()
		return SB_SetText(NewText, PartNumber, Style)
	}
	
	SetParts(Width*) {
		this.SetDefault()
		return SB_SetParts(Width*)
	}
	
	SetIcon(File, IconNumber := "", PartNumber := "") {
		this.SetDefault()
		return SB_SetIcon(File, IconNumber, PartNumber)
	}
	
	SetProgress(Value := 0, Seg := 1, Ops := "") {
		this.SetDefault()
		try Func("SB_SetProgress").Call(Value, Seg, Ops)
	}
	
	SetDefault() {
		this.Parent.Default()
	}
}