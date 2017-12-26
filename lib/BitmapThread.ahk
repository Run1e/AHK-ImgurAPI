#SingleInstance force
#Persistent
#NoTrayIcon
#WarnContinuableException Off
SetBatchLines -1

#Include lib\third-party\Gdip.ahk

finished := true
return

CreateBitmap(x*) {
	func := Func("CreateBitmapGo").Bind(x*)
	SetTimer % func, -1
}

CreateBitmapGo(File, Callback, Width, Height) {
	Callback := ObjShare(Callback)
	pBitmap := Gdip_CreateBitmapFromFile(File)
	if (pBitmap < 1) ; failed at creating bitmap from file
		return Callback.Call(false)
	pResizedBitmap := ScaleBitmap(pBitmap, Width, Height)
	Gdip_DisposeImage(pBitmap)
	Callback.Call(pResizedBitmap)
}

ScaleBitmap(pBitmap, Width, Height) {
	; get dimensions
	BigWidth := Gdip_GetImageWidth(pBitmap)
	BigHeight := Gdip_GetImageHeight(pBitmap)
	
	; make a new bitmap and size it up
	pBitmapResized := Gdip_CreateBitmap(Width, Height)
	G := Gdip_GraphicsFromImage(pBitmapResized)
	Gdip_SetInterpolationMode(G, 7)
	
	; figure out aspect ratio stuffs
	if (Width/Height > BigWidth/BigHeight) ; target thumbnail size is wider than original image, limit by height
		h := Height, w := Round(Width * ((BigWidth/BigHeight) / (Width/Height)))
	else if (Width/Height < BigWidth/BigHeight) ; target thumbnail size is higher than original image, limit by width
		w := Width, h := Round(Height * ((BigHeight/BigWidth) / (Height/Width)))
	else ; aspects are equal
		h := Height, w := Width
	
	; spit out a resized bitmap on top of that new bitmap
	Gdip_DrawImage(G, pBitmap, Width/2 - w/2, Height/2 - h/2, w, h)
	
	; return the resized bitmap
	return pBitmapResized
}