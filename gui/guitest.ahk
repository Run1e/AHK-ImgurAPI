#SingleInstance force
#Persistent
#Include *i <Debug>

Debug.Clear()

g := new GuiBase("Title", ["-MinimizeBox"])

t := g.AddText([{x:100}], "Sup?")

g.AddButton()
g.show([{w:200, h:500}])

g.Controls := ""

g := ""

return

#Include gui.ahk