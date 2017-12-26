Class StatusBarControl extends GuiBase.ControlBase {
	Type := "StatusBar"
	
	SetText(NewText, PartNumber := 1, Style := "") {
		this.Gui.SetDefault()
		if (PartNumber = 1)
			NewText := " " NewText
		return SB_SetText(NewText, PartNumber, Style)
	}
	
	SetParts(Width*) {
		this.Gui.SetDefault()
		return SB_SetParts(Width*)
	}
	
	SetIcon(File, IconNumber := "", PartNumber := "") {
		this.Gui.SetDefault()
		return SB_SetIcon(File, IconNumber, PartNumber)
	}
	
	SetProgress(Value := 0, Seg := 1, Ops := "") {
		this.Gui.SetDefault()
		try Func("SB_SetProgress").Call(Value, Seg, Ops)
	}
}