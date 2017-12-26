#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off

; JSON
global Settings, Images

; GUIS
global IG

; misc
global Client, App, pToken

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
	
	App := {Name: "Imgur Uploader", Author: "RUNIE", Version: "0.1"}
	
	pToken := Gdip_Startup()
	
	if !FileExist("data")
		FileCreateDir data
	
	Settings := new JSONFile("data/settings.json")
	
	Settings.Fill(DefaultSettings())
	Settings.Save(true)
	
	Images := new JSONFile("data/images.json")
	/*
		Images.Fill({2:{id: "89F8arh", link: "https://i.imgur.com/89F8arh.jpg", type: "image/jpeg"}})
		m(Images.Object())
		Images.Save(true)
	*/
	
	IG := new ImgurGUI("Imgur Uploader",, Func("p"))
	IG.Show([{w: Settings.Window.Width, h: Settings.Window.Height}])
	
	/*
		Client := new Imgur(Settings.client_id)
		Client.Debug := Func("p")
		Client.OnEvent("UploadProgress", IG.UploadProgress.Bind(IG))
	*/
	
}

rc(obj) {
	a := ObjAddRef(obj)
	ObjRelease(obj)
	return a - 1
}

Alert(Title, Text := "") {
	if (Settings.AlertMode = 2) {
		if !StrLen(Text)
			Text := Title, Title := App.Name
		TrayTip, % Title, % Text
	} else if (Settings.AlertMode = 1)
		SoundPlay *64
}

DefaultSettings() {
	return _:=
	( LTrim Join
	{
		client_id: "45a0e7fa6727f61",
		CopySeparator: "`n",
		AlertMode: 2,
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

evnt(Image, Response, Error) {
	if Error {
		m("Error", class(error), Error.Message)
		return
	}
	m(Image)
}

Exit() {
	IG.BitmapWorker := ""
	IG.Destroy(), IG := ""
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
#Include lib\CustomImageList.ahk
#Include lib\BitmapWorker.ahk

; misc
#Include lib\IndirectReference.ahk
#Include lib\Debug.ahk
#Include lib\Hotkey.ahk

; third party
#Include lib\third-party\Gdip.ahk
#Include lib\third-party\LV_EX.ahk