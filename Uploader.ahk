#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off

global Client, Settings, IG, pToken

; catch startup errors
try
	main()
catch e
	throw e

return

main() {
	SetBatchLines -1
	SetWinDelay, -1
	SetWorkingDir % A_ScriptDir
	
	Debug.Clear()
	
	pToken := Gdip_Startup()
	
	if !FileExist("data")
		FileCreateDir data
	
	Settings := new JSONFile("data/settings.json")
	
	Settings.Fill(DefaultSettings())
	Settings.Save(true)
	
	IG := new ImgurGUI("Imgur Uploader",, Func("P"))
	IG.Show([{w: Settings.Window.Width, h: Settings.Window.Height}])
	
	Client := new Imgur(Settings.client_id, Func("p"))
	Client.OnEvent("UploadProgress", IG.UploadProgress.Bind(IG))
	;Client.Image("pic.jpg").Upload()
	
	
}

DefaultSettings() {
	return _:=
	( LTrim Join
	{
		client_id: "45a0e7fa6727f61",
		Image: {
			Width: 256,
			Height: 144,
			Spacing: 8
		},
		Window: {
			Width: 800,
			Height: 500
		}
	}
	)
}

OnProgress(Image, Current, Total) {
	t(Current / Total)
}

evnt(Image, Response, Error) {
	if Error {
		m("Error", class(error), Error.Message)
		return
	}
	m(Image)
}

Exit() {
	Settings.Save(true)
	Gdip_Shutdown(pToken)
	ExitApp
}

Print(x*) {
	p(x*)
}

; libs
#Include imgur\client.ahk
#Include gui\gui.ahk

; project
#Include lib\ImgurGUI.ahk
#Include lib\JSONFile.ahk

; misc
#Include lib\Debug.ahk
#Include lib\Hotkey.ahk
#Include lib\CustomImageList.ahk

; third party
#Include lib\third-party\Gdip.ahk
#Include lib\third-party\indirectReference.ahk
#Include lib\third-party\LV_EX.ahk