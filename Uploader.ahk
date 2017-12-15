#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off

global Client, Settings, IG

main()
return

main() {
	SetBatchLines -1
	SetWinDelay, -1
	SetWorkingDir % A_ScriptDir
	
	Debug.Clear()
	
	if !FileExist("data")
		FileCreateDir data
	
	Settings := new JSONFile("data/settings.json")
	
	Defaults :=
	( LTrim Join
	{
		client_id: "45a0e7fa6727f61"
	}
	)
	
	Settings.Fill(Defaults)
	Settings.Save(true)
	
	try
		Client := new Imgur(Settings.client_id, Func("p"))
	catch e {
		Debug.Log(e)
		throw e
	}
	
	Client.OnEvent("UploadProgress", Func("OnProgress"))
	
	Client.Image("bwbgRxz").Get(Func("evnt"))
}

OnProgress(Image, Current, Total) {
	t(Current / Total)
}

evnt(Image, Response) {
	m(Image)
}

Exit() {
	IG.Destroy()
	IG := ""
	p("EXITING EXITING DONT KILL ME")
	ExitApp
}

; libs
#Include imgur\client.ahk
#Include gui\gui.ahk

; project
#Include lib\ImgurGUI.ahk
#Include lib\JSONFile.ahk

#Include lib\Debug.ahk
#Include lib\Hotkey.ahk
#Include imgur\lib\IndirectReference.ahk