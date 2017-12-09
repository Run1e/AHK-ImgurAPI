#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off
SetBatchLines -1
SetWorkingDir % A_ScriptDir

#Include *i <Debug>

global x

x := new Imgur("45a0e7fa6727f61")

x.RegisterEvent("OnUploadSuccess", Func("OnUpload"))
x.RegisterEvent("OnUploadProgress", Func("OnUploadProgress"))
x.RegisterEvent("OnGetImageSuccess", Func("ImgResp"))

x.GetImage("FGXVWwa", Func("test"))
return

test(Image, Error := "") {
	if Error {
		
	}
}

ImgResp(Image, Error := "") {
	p(Image)
}

OnUpload(Image) {
	tooltip
	clipboard := Image.link
	TrayTip, Upload successful!, Clipboard osv
}

OnUploadProgress(Image, Uploaded, Total) {
	t(Image.File, Ceil(Uploaded / Total * 100))
}

#Include imgur\client.ahk