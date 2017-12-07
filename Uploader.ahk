#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off
SetBatchLines -1
SetWorkingDir % A_ScriptDir

global x

x := new Imgur("45a0e7fa6727f61")

x.SetDebugFunc(Func("P"))

x.RegisterEvent("OnUploadSuccess", Func("OnUpload"))
x.RegisterEvent("OnUploadProgress", Func("OnUploadProgress"))

x.Free()
x := ""
return



OnUpload(Image) {
	tooltip
	clipboard := Image.link
	TrayTip, Upload successful!, Clipboard osv
}

OnUploadProgress(Image, Uploaded, Total) {
	t(Image.File, Ceil(Uploaded / Total * 100))
}

Exit() {
	; exit code
}

#Include imgur\client.ahk
#Include lib\Debug.ahk
#Include imgur\worker.ahk
#Include imgur\lib\Class Thread.ahk