﻿Class ListViewControl extends GuiBase.ControlBase {
	Type := "ListView"
	
	Add(Options := "", Fields*) {
		this.SetDefault()
		return LV_Add(this.Gui.CraftOptions(Options), Fields*)
	}
	
	Insert(Row, Options := "", Col*) {
		this.SetDefault()
		return LV_Insert(Row, this.Gui.CraftOptions(Options), Col*)
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
		return this.Gui.Control((Toggle?"+":"-") "Redraw", this.hwnd)
	}
	
	SetImageList(ImageList) {
		this.SetDefault()
		this.ImageList := ImageList
		return LV_SetImageList(this.ImageList.id, !ImageList.LargeIcons)
	}
	
	SetDefault() {
		this.Gui.SetDefault()
		this.Gui.SetDefaultListView(this)
	}
	
	IL {
		get {
			return this.ImageList
		}
	}
}