#SingleInstance force
#NoEnv
#Persistent
#WarnContinuableException off

; JSON
global Settings, Images

; GUIS
global IG, asdf

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
	Request.SetDebug(Func("p"))
	
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
	
	Client := new Imgur(Settings.client_id, Func("p"))
	Client.Debug := Func("p")
	Client.OnEvent("UploadProgress", IG.SafeRef.UploadProgress.Bind(IG.SafeRef))
	Client.OnEvent("UploadResponse", IG.SafeRef.ImgurResponse.Bind(IG.SafeRef))
	Client.OnEvent("GetImageResponse", IG.SafeRef.ImgurResponse.Bind(IG.SafeRef))
	
	Client.Image("89F8arh").Get(Func("ImageGet"))
	
	;Client.Image("pic.jpg").Upload()
}

ImageGet(Image, Response, Error) {
	if Error
		throw Error
	m(Image)
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

Exit() {
	IG.Destroy(), IG := ""
	Client := ""
	Settings.Save(true), Settings := ""
	Images.Save(true), Images := ""
	Gdip_Shutdown(pToken)
	ExitApp
}

RefCount(obj) {
	ptr := &obj, obj := ""
	count := ObjAddRef(ptr)
	ObjRelease(ptr)
	return count - 1
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
#Include lib\third-party\LV_Colors.ahk