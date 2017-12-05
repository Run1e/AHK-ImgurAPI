#SingleInstance force
#NoEnv
SetBatchLines -1
SetWorkingDir % A_ScriptDir

cli := new Imgur("45a0e7fa6727f61")
cli.RegisterEvent("OnUploadSuccess", Func("OnUpload"))
cli.Image("pic.jpg").Upload()
cli.Free()
cli := ""
return

OnUpload(Image) {
}

Exit() {
	; exit code
}

#Include imgur\client.ahk
#Include lib\Debug.ahk