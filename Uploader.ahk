#SingleInstance force
#NoEnv
SetBatchLines -1
SetWorkingDir % A_ScriptDir

x := new Imgur("45a0e7fa6727f61")
x.RegisterEvent("OnUploadSuccess", Func("OnUpload"))


try Imgur.Image("thing")


Imgur.Upload()

return

OnUpload(Image) {
	m("UPLOADED", "", image.file)
}

Exit() {
	; exit code
}

#Include imgur\client.ahk
#Include lib\Debug.ahk