#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off
SetBatchLines -1
SetWorkingDir % A_ScriptDir

global x

x := new Imgur("45a0e7fa6727f61")

x.RegisterEvent("OnUploadSuccess", Func("OnUpload"))
x.RegisterEvent("OnUploadProgress", Func("OnUploadProgress"))
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