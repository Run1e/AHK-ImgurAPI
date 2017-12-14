GuiClose(GuiHwnd) {
	if Gui := Object(GuiBase.Guis[GuiHwnd])
		return Gui.Close.Call(Gui)
}

GuiEscape(GuiHwnd) {
	if Gui := Object(GuiBase.Guis[GuiHwnd])
		return Gui.Escape.Call(Gui)
}

GuiSize(GuiHwnd, EventInfo, Width, Height) {
	if Gui := Object(GuiBase.Guis[GuiHwnd])
		return Gui.Size.Call(Gui, EventInfo, Width, Height)
}

GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
	if Gui := Object(GuiBase.Guis[GuiHwnd])
		return Gui.DropFiles.Call(Gui, FileArray, CtrlHwnd, X, Y)
}

GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y) {
	if Gui := Object(GuiBase.Guis[GuiHwnd])
		return Gui.ContextMenu.Call(Gui, CtrlHwnd, EventInfo, IsRightClick, X, Y)
}