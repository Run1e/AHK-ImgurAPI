#SingleInstance force
#Persistent
#Include *i <Debug>

Debug.Clear()

g := new GuiBase("Title", ["-MinimizeBox"])
g.Close := Func("Exit")

lv := g.AddListView([{x:0, y:0, w:200, h:500}], ["a", "b", "c"])
lv.OnEvent(Func("Hello"))
lv.SetImageList(new GuiBase.ImageList)

lv.il.add("D:\Documents\Scripts\Vibrancer\icons\vibrancer.ico")
lv.add(lv.il.add("D:\Documents\Scripts\Vibrancer\icons\vibrancer.ico"), "test")

g.show([{w:200, h:500}])

;g.Destroy()
;g := ""

return

Hello(x*) {
	p(x*)
}

Exit() {
	p("Exiting")
	ExitApp
}

#Include gui.ahk