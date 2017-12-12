Class GuiBase {
	
	;#Include %A_LineFile%\..\listview.ahk
	;#Include %A_LineFile%\..\imagelist.ahk
	;#Include %A_LineFile%\..\statusbar.ahk
	
	; MISC
	#Include %A_LineFile%\..\pos.ahk
	
	; CONTROLS
	#Include %A_LineFile%\..\control.ahk
	#Include %A_LineFile%\..\text.ahk
	#Include %A_LineFile%\..\button.ahk
	
	static Guis := {}
	
	Controls := []
	
	__New(Title := "AutoHotkey Window", Options := "") {
		this.Title := Title
		
		Gui, New, % "+hwndhwnd " CraftOptions(Options), % this.Title
		
		this.hwnd := hwnd
		this.ahkid := "ahk_id" hwnd
		GuiBase.Guis[this.hwnd] := &this
		
		this.Pos := new GuiBase.WindowPosition(this.hwnd)
		
		this.DropFilesToggle(false) ; disable drag-drop by default
		
		p(this.base.__Class " created")
	}
	
	__Delete() {
		this.Pos := ""
		this.Controls := ""
		p(this.base.__Class " destroyed")
	}
	
	Show(Options := "") {
		Gui % this.hwnd ":Show", % CraftOptions(Options), % this.Title
		p("show")
	}
	
	Hide(Options := "") {
		Gui % this.hwnd ":Hide", % CraftOptions(Options)
	}
	
	; ADD CONTROLS
	
	AddText(Options := "", Text := "") {
		return this.Controls[this.Controls.Push(new this.TextControl(this, Options, Text))]
	}
	
	; EVENTS
	
	Close() {
		this.Hide()
	}
	
	Escape() {
		this.Close()
	}
	
	; PROPERTIES
	
	Visible {
		get {
			DHW := A_DetectHiddenWindows
			DetectHiddenWindows, Off
			exist := WinExist(this.ahkid)
			DetectHiddenWindows % DHW
			return !!exist
		}
	}
	
	Margin(x := "", y := "") {
		Gui % this.hwnd ": Margin", % x, % y
	}
	
	Focus() {
		WinActivate % this.ahkid
	}
}

CraftOptions(Obj) {
	if IsObject(Obj) {
		for Index, Option in Obj {
			if (Index != A_Index)
				throw Exception("Option string has to be wrapper in an indexed array.")
			if IsObject(Option) {
				for Key, Val in Option 
					Opt .= " " Key . Val
			} else
				Opt .= " " Option
		}
	} return SubStr(Opt, 2)
}

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

/*
	
	Add(ControlType, Options := "", Params := "", Function := "") {
		Gui % this.hwnd ":Add", % ControlType, % Options " hwndControlHWND", % Params
		if Function {
			GuiControl, +g, % ControlHWND, % Function
			this.Controls.Push(ControlHWND)
		}
		return ControlHWND
	}
	
	Control(Command := "", Control := "", ControlParams := "") {
		GuiControl % this.hwnd ":" Command, % Control, % ControlParams
	}
	
	Show(Options := "", Title := "") {
		Gui % this.hwnd ":Show", % Options, % Title
	}
	
	Hide(Options := "") {
		Gui % this.hwnd ":Hide", % Options
	}
	
	Default() {
		if (A_DefaultGui != this.hwnd)
			Gui % this.hwnd ":Default"
	}
	
	DefaultListView(ListView) {
		if (A_DefaultListView != ListView.hwnd)
			Gui % this.hwnd ":ListView", % ListView.hwnd
	}
	
	SetIcon(Icon) {
		hIcon := DllCall("LoadImage", UInt,0, Str, Icon, UInt, 1, UInt, 0, UInt, 0, UInt, 0x10)
		SendMessage, 0x80, 0, hIcon ,, % this.ahkid  ; One affects Title bar and
		SendMessage, 0x80, 1, hIcon ,, % this.ahkid  ; the other the ALT+TAB menu
	}
	
	Font(Options := "", Font := "") {
		Gui % this.hwnd ":Font", % Options, % Font
	}
	
	DropFilesToggle(Toggle) {
		this.Options((Toggle ? "+" : "-") . "E0x10")
	}
	
	Escape() {
		this.Close()
	}
	
	Activate() {
		WinActivate % this.ahkid
	}
	
	Tab(num) {
		Gui % this.hwnd ":Tab", % num
	}
	
	Disable() {
		Gui % this.hwnd ":+Disabled"
	}
	
	Enable() {
		Gui % this.hwnd ":-Disabled"
	}
	
	ControlGet(Command, Value := "", Control := "") {
		ControlGet, out, % Command, % (StrLen(Value) ? Value : ""), % (StrLen(Control) ? Control : ""), % this.ahkid
		return out
	}
	
	GuiControlGet(Command := "", Control := "", Param := "") {
		GuiControlGet, out, % (StrLen(Command) ? Command : ""), % (StrLen(Control) ? Control : ""), % (StrLen(Param) ? Param : "")
		return out
	}
	
	Pos(x := "", y := "", w := "", h := "") {
		this.Show(  (StrLen(x) ? "x" x : "") . " "
				. (StrLen(y) ? "y" y : "") . " "
				. (StrLen(w) ? "w" w : "") . " "
				. (StrLen(h) ? "h" h : "") . " "
				. (this.IsVisible ? "" : "Hide"))
	}
	
	Destroy() {
		for Index, Control in this.Controls
			GuiControl, -g, % Control
		Gui % this.hwnd ":Destroy"
		this.IsVisible := false
		Gui.Instances[this.hwnd] := ""
	}
	
	Color(BackgroundColor := "", ControlColor := "") {
		Gui % this.hwnd ":Color", % BackgroundColor, % ControlColor
	}
	
	Options(Options) {
		Gui % this.hwnd ":" Options
	}
	
	
	Submit(Hide := false, Options := "") {
		Gui % this.hwnd ":Submit", % (this.IsVisible := !Hide ? "" : "NoHide") " " Options
	}
	
	GetText(Control) {
		ControlGetText, ControlText, % Control, % this.ahkid
		return ControlText
	}
	
	SetText(Control, Text := "") {
		this.Control(, Control, Text)
	}
*/