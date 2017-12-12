Class ListView {
	__New(Parent, Options, Headers, Function := "") {
		this.Parent := Parent
		this.Function := Function
		this.hwnd := Parent.Add("ListView", Options, Headers, Function)
		return this
	}
	
	Add(Options := "", Fields*) {
		this.SetDefault()
		return LV_Add(Options, Fields*)
	}
	
	Insert(Row, Options := "", Col*) {
		this.SetDefault()
		return LV_Insert(Row, Options, Col*)
	}
	
	Delete(Row := "") {
		this.SetDefault()
		if StrLen(Row)
			return LV_Delete(Row)
		else
			return LV_Delete()
	}
	
	GetCount(Option := "") {
		this.SetDefault()
		return LV_GetCount(Option)
	}
	
	GetNext(Start := "", Option := "") {
		this.SetDefault()
		return LV_GetNext(Start, Option)
	}
	
	GetText(Row, Column := 1) {
		this.SetDefault()
		LV_GetText(Text, Row, Column)
		return Text
	}
	
	Modify(Row, Options := "", NewCol*) {
		this.SetDefault()
		return LV_Modify(Row, Options, NewCol*)
	}
	
	ModifyCol(Column := "", Options := "", Title := "") {
		this.SetDefault()
		return LV_ModifyCol(Column, Options, Title)
	}
	
	Redraw(Toggle) {
		this.SetDefault()
		return this.Parent.Control((Toggle?"+":"-") "Redraw", this.hwnd)
	}
	
	SetImageList(ID, LargeIcons := false) {
		this.SetDefault()
		return LV_SetImageList(ID, !LargeIcons)
	}
	
	SetDefault() {
		this.Parent.Default()
		this.Parent.DefaultListView(this.hwnd)
	}
}