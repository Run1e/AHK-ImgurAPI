#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off
SetBatchLines -1
SetWorkingDir % A_ScriptDir

#Include *i <Debug>

x := new Imgur("45a0e7fa6727f61")
x.Image("pic.jpg").Upload(Func("OnUpload"))
return

OnUpload(Image, Error) {
	m(Image)
}

#Include imgur\client.ahk