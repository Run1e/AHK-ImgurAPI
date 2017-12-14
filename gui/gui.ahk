#Include %A_LineFile%\..\guievents.ahk

Class GuiBase {
	
	; misc
	#Include %A_LineFile%\..\pos.ahk
	#Include %A_LineFile%\..\imagelist.ahk
	
	; controls
	#Include %A_LineFile%\..\control.ahk
	#Include %A_LineFile%\..\text.ahk
	#Include %A_LineFile%\..\button.ahk
	#Include %A_LineFile%\..\edit.ahk
	#Include %A_LineFile%\..\listview.ahk
	
	static Guis := {}
	
	Controls := []
	
	__New(Title := "AutoHotkey Window", Options := "") {
		this.Title := Title
		
		Gui, New, % "+hwndhwnd " this.CraftOptions(Options), % this.Title
		
		this.hwnd := hwnd
		this.ahkid := "ahk_id" hwnd
		GuiBase.Guis[this.hwnd] := &this
		
		this.Position := this.Pos := new GuiBase.WindowPosition(this.hwnd)
		
		this.DropFilesToggle(false) ; disable drag-drop by default
		
		this.Init()
		
		p(this.base.__Class " created")
	}
	
	__Delete() {
		this.Controls := ""
		if this.Visible
			this.Destroy()
		p(this.base.__Class " destroyed")
	}
	
	Show(Options := "") {
		Gui % this.hwnd ":Show", % this.CraftOptions(Options), % this.TitleValue
	}
	
	Hide(Options := "") {
		Gui % this.hwnd ":Hide", % this.CraftOptions(Options)
	}
	
	Destroy() {
		this.Controls := ""
		Gui % this.hwnd ":Destroy"
	}
	
	SetDefault() {
		if (A_DefaultGui != this.hwnd)
			Gui % this.hwnd ":Default"
	}
	
	SetDefaultListView(ListView) {
		if (A_DefaultListView != ListView.hwnd)
			Gui % this.hwnd ":ListView", % ListView.hwnd
	}
	
	GetControl(hwnd) {
		for Index, Ctrl in this.Controls
			if Ctrl.hwnd = hwnd
				return Ctrl
	}
	
	Options(Options) {
		Gui % this.hwnd ":" Options
	}
	
	DropFilesToggle(Toggle) {
		this.Options((Toggle ? "+" : "-") . "E0x10")
	}
	
	Control(Command := "", Control := "", ControlParams := "") {
		GuiControl % this.hwnd ":" Command, % Control, % ControlParams
	}
	
	Margins(x := "", y := "") {
		Gui % this.hwnd ":Margin", % x, % y
	}
	
	Focus() {
		WinActivate % this.ahkid
	}
	
	Disable() {
		Gui % this.hwnd ":+Disabled"
	}
	
	Enable() {
		Gui % this.hwnd ":-Disabled"
	}
	
	SetIcon(Icon) {
		hIcon := DllCall("LoadImage", UInt,0, Str, Icon, UInt, 1, UInt, 0, UInt, 0, UInt, 0x10)
		SendMessage, 0x80, 0, hIcon ,, % this.ahkid  ; One affects Title bar and
		SendMessage, 0x80, 1, hIcon ,, % this.ahkid  ; the other the ALT+TAB menu
	}
	
	; ADD CONTROLS
	
	AddText(Options := "", Text := "") {
		Control := new GuiBase.TextControl(this, this.CraftOptions(Options), Text)
		return this.Controls[this.Controls.Push(Control)]
	}
	
	AddEdit(Options := "", Text := "") {
		Control := new GuiBase.EditControl(this, this.CraftOptions(Options), Text)
		return this.Controls[this.Controls.Push(Control)]
	}
	
	AddButton(Options := "", Text := "") {
		Control := new GuiBase.ButtonControl(this, this.CraftOptions(Options), Text)
		return this.Controls[this.Controls.Push(Control)]
	}
	
	AddListView(Options := "", Headers := "") {
		for Index, Header in Headers
			HeaderText .= "|" Header
		Control := new GuiBase.ListViewControl(this, this.CraftOptions(Options), SubStr(HeaderText, 2))
		return this.Controls[this.Controls.Push(Control)]
	}
	
	; DEFAULT EVENT HANDLERS
	
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
	
	Title {
		set {
			WinSetTitle, % this.ahkid,, % value
			this.TitleValue := value
		}
		
		get {
			return this.TitleValue
		}
	}
	
	; Gui % this.hwnd ":Color", % BackgroundColor, % ControlColor
	
	BackgroundColor {
		set {
			Gui % this.hwnd ":Color", % value
			this.BackgroundColorValue := value
		}
		
		get {
			return this.BackgroundColorValue
		}
	}
	
	ControlColor {
		set {
			Gui % this.hwnd ":Color",, % value
			this.ControlColorValue := value
		}
		
		get {
			return this.ControlColorValue
		}
	}
	
	; base
	
	GetGui(hwnd) {
		for Index, Gui in GuiBase.Guis
			if Gui.hwnd = hwnd
				return Gui
	}
	
	; INTERNAL
	
	CraftOptions(Obj) {
		if IsObject(Obj) {
			for Index, Option in Obj {
				if (Index != A_Index)
					throw Exception("Option string has to be wrapped in an indexed array.")
				if IsObject(Option) {
					for Key, Val in Option 
						Opt .= " " Key . Val
				} else
					Opt .= " " Option
			}
		} return SubStr(Opt, 2)
	}
}

/*
	
	

	
	Font(Options := "", Font := "") {
		Gui % this.hwnd ":Font", % Options, % Font
	}
	
	DropFilesToggle(Toggle) {
		this.Options((Toggle ? "+" : "-") . "E0x10")
	}

	Tab(num) {
		Gui % this.hwnd ":Tab", % num
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