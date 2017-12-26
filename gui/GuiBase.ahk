#Include %A_LineFile%\..\guievents.ahk

Class GuiBase {
	
	; misc
	#Include %A_LineFile%\..\Position.ahk
	#Include %A_LineFile%\..\ImageList.ahk
	
	; controls
	#Include %A_LineFile%\..\controls\ControlBase.ahk
	#Include %A_LineFile%\..\controls\Text.ahk
	#Include %A_LineFile%\..\controls\Button.ahk
	#Include %A_LineFile%\..\controls\Edit.ahk
	#Include %A_LineFile%\..\controls\ListView.ahk
	
	static Guis := {}
	
	Controls := []
	
	__New(Title := "AutoHotkey Window", Options := "", Debug := "") {
		if !IsObject(indirectReference) {
			run https://github.com/nnnik/indirectReference
			throw "Missing dependency: indirectReference library by nnnik"
		}
		
		this.Title := Title
		this.Debug := Debug
		
		Gui, New, % "+hwndhwnd " this.CraftOptions(Options), % this.Title
		
		this.hwnd := hwnd
		this.ahkid := "ahk_id" hwnd
		
		GuiBase.Guis[this.hwnd] := new indirectReference(this)
		
		this.Position := new GuiBase.WindowPosition(this.hwnd)
		
		this.DropFilesToggle(false) ; disable drag-drop by default
		this.Init()
		
		this.Print(this.__Class " created")
	}
	
	__Delete() {
		this.Destroy()
		this.Print(this.__Class " destroyed")
	}
	
	Print(x*) {
		try this.Debug.Call(x*)
	}
	
	Show(Options := "") {
		Gui % this.hwnd ":Show", % this.CraftOptions(Options), % this.TitleValue
	}
	
	Hide(Options := "") {
		Gui % this.hwnd ":Hide", % this.CraftOptions(Options)
	}
	
	Destroy() {
		this.Controls := ""
		try
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
		return this.Controls[hwnd]
	}
	
	Options(Options) {
		Gui % this.hwnd ":" this.CraftOptions(Options)
	}
	
	DropFilesToggle(Toggle) {
		this.Options((Toggle ? "+" : "-") . "E0x10")
	}
	
	Control(Command := "", Control := "", ControlParams := "") {
		if IsObject(Control) {
			if !Control.HasKey("hwnd")
				throw this.__Class ".Control: provided control object has no hwnd attribute"
			hwnd := Control.hwnd
		} else
			hwnd := Control
		
		GuiControl % this.hwnd ":" Command, % hwnd, % ControlParams
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
		return this.AddControl("Text", Options, Text)
	}
	
	AddEdit(Options := "", Text := "") {
		return this.AddControl("Edit", Options, Text)
	}
	
	AddButton(Options := "", Text := "") {
		return this.AddControl("Button", Options, Text)
	}
	
	AddListView(Options := "", Headers := "") {
		for Index, Header in Headers
			HeaderText .= "|" Header
		return this.AddControl("ListView", Options, SubStr(HeaderText, 2))
	}
	
	AddControl(Control, Options := "", Text := "") {
		ControlClass := GuiBase[Control . "Control"] ; yes, this apparently works
		Ctrl := new ControlClass(this, this.CraftOptions(Options), Text)
		return this.Controls[Ctrl.hwnd] := Ctrl
	}
	
	; DEFAULT EVENT HANDLERS
	
	Close() {
		this.Hide()
	}
	
	Escape() {
		this.Close()
	}
	
	; PROPERTIES
	
	Pos {
		get {
			return this.Position
		}
	}
	
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
	
	
	
	Submit(Hide := false, Options := "") {
		Gui % this.hwnd ":Submit", % (this.IsVisible := !Hide ? "" : "NoHide") " " Options
	}
*/