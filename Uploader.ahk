#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off
SetBatchLines -1
SetWorkingDir % A_ScriptDir

x := new Imgur("45a0e7fa6727f61")

x.RegisterEvent("OnUploadSuccess", Func("OnUpload"))
x.RegisterEvent("OnUploadProgress", Func("OnUploadProgress"))

img := x.Image("pic.jpg")

x.upload(img)

return

OnUpload(Image) {
	m("Upload successful", "", Image)
}

OnUploadProgress(Image, a, b) {
	t(a / b)
}

Exit() {
	; exit code
}

#Include imgur\client.ahk
#Include lib\Debug.ahk