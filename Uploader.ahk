#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off
SetBatchLines -1
SetWorkingDir % A_ScriptDir

#Include imgur\client.ahk
#Include *i <Debug>

Debug.Clear()

Client := new Imgur("45a0e7fa6727f61")

Client.OnEvent("UploadProgress", Func("OnProgress"))
Client.OnEvent("UploadResponse", Func("OnResponse"))
Client.OnEvent("GetImageResponse", Func("OnResponse"))

Client.Image("bWHQPld").Get()
Client.Image("2Sh67fS").Get()

/*
	Image := x.Image("pic.jpg")
	Image.Upload()
*/

return

OnResponse(Image, Resp) {
	if Resp.Error {
		Debug.Log(Resp.Error)
		return
	}
	m(image)
}

OnProgress(Image, Current, Total) {
	t(Floor((current / total) * 100))
}
#Include gui\Class GuiBase.ahk