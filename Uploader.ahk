#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off

main()
return

main() {
	SetBatchLines -1
	SetWinDelay, -1
	SetWorkingDir % A_ScriptDir
	
	global Settings, Client
	
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
		Client := new Imgur(Settings.client_id)
	catch e {
		if isinstance(e, Imgur.UploadFailure)
	}
	
	global IG := new ImgurGUI
}

; libs
#Include imgur\client.ahk
#Include gui\gui.ahk

; project
#Include lib\ImgurGUI.ahk
#Include lib\JSONFile.ahk

#Include lib\Debug.ahk