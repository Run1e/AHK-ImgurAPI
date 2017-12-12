#SingleInstance force
#Persistent
#Include *i <Debug>

Debug.Clear()

global g := new GuiBase("Title", ["-MinimizeBox"])
g.Close := Func("Exit")

lv := g.AddListView([{x:0, y:0, w:200, h:500}], ["a", "b", "c"])
lv.OnEvent(Func("Hello"))
lv.SetImageList(new GuiBase.ImageList)

lv.Add(lv.IL.Add("D:\Documents\Scripts\Vibrancer\icons\vibrancer.ico"), "some text")
g.Margins(0, 0)
g.Show()
return

Hello(hwnd, eventinfo, whatever) {
	p(hwnd ", " eventinfo ", " whatever)
}

Exit() {
	p("Exiting")
	ExitApp
}

#Include gui.ahk