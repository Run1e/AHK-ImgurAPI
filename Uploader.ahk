#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off

; JSON
global Settings, Images

; GUIS
global IG

; misc
global Client, pToken

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
	
	Images := new JSONFile("data/images.json")
	Images.Fill([{id: "bwbgRxz", link: "https://i.imgur.com/bwbgRxz.jpg", type: "image/jpeg"}])
	Images.Save(true)
	
	IG := new ImgurGUI("Imgur Uploader",, Func("P"))
	IG.Show([{w: Settings.Window.Width, h: Settings.Window.Height}])
	
	Client := new Imgur(Settings.client_id, Func("p"))
	Client.OnEvent("UploadProgress", IG.UploadProgress.Bind(IG))
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
	IG.BitmapWorker := ""
	IG := ""
	Client := ""
	Settings.Save(true), Settings := ""
	Images.Save(true), Images := ""
	Gdip_Shutdown(pToken)
	ExitApp
}

Print(x*) {
	p(x*)
}

; libs
#Include imgur\Imgur.ahk
#Include gui\GuiBase.ahk

; project
#Include lib\ImgurGUI.ahk
#Include lib\JSONFile.ahk

; misc
#Include lib\Debug.ahk
#Include lib\Hotkey.ahk
#Include lib\CustomImageList.ahk
#Include lib\BitmapWorker.ahk

; third party
#Include lib\third-party\Gdip.ahk
#Include lib\third-party\indirectReference.ahk
#Include lib\third-party\LV_EX.ahk