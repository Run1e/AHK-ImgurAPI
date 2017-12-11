#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off
SetBatchLines -1
SetWorkingDir % A_ScriptDir

#Include imgur\client.ahk
#Include *i <Debug>

Debug.Clear()

global x := new Imgur("45a0e7fa6727f61")

x.OnEvent("UploadProgress", Func("OnProgress"))
x.OnEvent("UploadResponse", Func("OnResponse"))
x.OnEvent("GetImageResponse", Func("OnResponse"))

Image := x.Image("pic.jpg")
Image.Upload()

return

OnResponse(Image, Error) {
	m(Image)
}

OnProgress(Image, Current, Total) {
	t(Floor((current / total) * 100))
}