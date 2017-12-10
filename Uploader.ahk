#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off
SetBatchLines -1
SetWorkingDir % A_ScriptDir

#Include imgur\client.ahk
#Include *i <Debug>

Debug.Clear()

x := new Imgur("45a0e7fa6727f61")

x.RegisterEvent("OnUploadProgress", Func("Progress"))
x.RegisterEvent("OnUploadResponse", Func("OnUpload"))
x.RegisterEvent("OnGetImageResponse", Func("OnGetImage"))

/*
	Image := x.Image("bwbgRxz")
	Image.Get()
*/

/*
	Image := x.Image("pic.jpg")
	Image.Upload()
*/
return


GetImage(Image, Error) {
	m(A_ThisFunc, "", Image)
}

Progress(Image, Current, Total) {
	t(Floor((current / total) * 100))
}

OnGetImage(Image, Error) {
	m(A_ThisFunc, "", Image)
}

OnUpload(Image, Error) {
	m(A_ThisFunc, "", Image)
}