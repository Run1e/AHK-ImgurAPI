/*
	image previewer {
		basically as my previous one, with moving gif images and image previews
		double-clicking copies image link to clipboard
		maybe a right click context menu? for deleting and other stuff
	}
	
	save control {
		whether to save locally or to upload to imgur
	}
	
	main gui buttons {
		queue control {
			start
			stop
			pause
			clear queue
		}
		
		hotkeys
		settings
	}
*/

ImageToPath(Image) {
	static Assoc := {"image/jpeg": "jpg"}
	return "data/images/uploaded/" Image.id "." Assoc[Image.type]
}

GetImage(id) {
	for Index, Image in Images.Object()
		if (Image.id = id)
			return Image
	
	Debug.Log(Exception(A_ThisFunc " failed for " id))
}

Class ImgurGUI extends GuiBase {
	New() {
		try
			this.BitmapWorker := new BitmapWorker(Settings.Image.Width, Settings.Image.Height)
		catch e
			throw "Failed starting BitmapWorker."
		
		this.Debug := Func("p")
		this.BitmapWorker.Debug := this.Debug
		
		this.BackgroundColor := 0x161616
		
		this.Options([{("+MinSize"): "540x256"}, "+Resize", "+Border"])
		
		this.ImageLV := this.AddListView([{x: 0, y: 0, ("+Background"): 161616}, "-Hdr", "-Border"], ["FuckAjitPai|id"])
		this.ImageLV.OnEvent(this.ImageLVEvent.Bind(this))
		this.ImageLV.ModifyCol(1, 0)
		this.ImageLV.ModifyCol(2, 0)
		this.ImageLV.SetImageList(new CustomImageList(Settings.Image.Width, Settings.Image.Height, 0x20))
		
		this.Font([{s:11}])
		
		this.Status := this.AddStatusBar()
		this.Status.Pos.W := 23
		this.Status.SetParts(0, 0)
		this.Status.SetText("Imgur Uploader by RUNIE", 1)
		
		
		Loop 4 {
			for Index, Image in Images.Object() {
				if (A_Index > 20)
					break
				this.AddImage(Image)
			}
		}	
	}
	
	Delete() {
		this.BitmapWorker := ""
		this.ImageLV := ""
		this.Status := ""
	}
	
	ImageLVEvent(hwnd, Event, LVPos) {
		ids := []
		
		while (Pos := this.ImageLV.GetNext(Pos))
			ids.Push(this.ImageLV.GetText(Pos, 2))
		
		for idIndex, id in ids, Imgs := []
			if Image := GetImage(id)
				if !ArrayHasValue(Imgs, Image)
					Imgs.Push(Image)
		
		if (Event = "DoubleClick") {
			; copy link(s) to clipboard
			for Index, Image in Imgs
				Clip .= Settings.CopySeparator . Image.link
			if !Index
				return
			clipboard := SubStr(Clip, StrLen(Settings.CopySeparator))
			AlertText := Index > 1 ? Index " links copied!" : "Link copied!"
			this.Status.SetText(AlertText)
			Alert(AlertText)
		}
	}
	
	AddImage(Image, Top := false) {
		Gui := this.GetGui(this.hwnd)
		this.BitmapWorker.Add(ImageToPath(Image), Gui.AddImageCallback.Bind(Gui, Image, Top))
	}
	
	AddImageCallback(Image, Top, pBitmap) {
		static SpacingSet := false
		
		if !Icon := this.ImageLV.IL.AddBitmap(pBitmap)
			return
		
		if Top
			this.ImageLV.Insert(1, [{Icon: Icon}],, Image.id)
		else
			this.ImageLV.Add([{Icon: Icon}],, Image.id)
		
		if !SpacingSet {
			LV_EX_SetIconSpacing(this.ImageLV.hwnd, Settings.Image.Width + Settings.Image.Spacing, Settings.Image.Height + Settings.Image.Spacing)
			SpacingSet := true
		}
		
		this.FixOrder()
		
		this.BitmapWorker.Next(true)
	}
	
	Show(Options := "") {
		Gui % this.hwnd ":Show", % this.CraftOptions(Options), % this.TitleValue
	}
	
	FixOrder() {
		this.ImageLV.Options(["-Redraw"])
		this.ImageLV.Options(["+Report"])
		this.ImageLV.Options(["+Icon"])
		this.ImageLV.Options(["+Redraw"])
		;this.ImageLV.Modify(1, "Vis")
	}
	
	UploadProgress(Image, Current, Total) {
		t(Image, Current/Total)
	}
	
	Size(EventInfo, Width, Height) {
		this.ImageLV.Pos.W := Width - 250
		this.ImageLV.Pos.H := Height - 23
		
		this.Status.SetParts(200, Width - 200)
		
		Settings.Window.Width := Width
		Settings.Window.Height := Height
		Settings.Window.State := EventInfo
		this.FixOrder()
	}
	
	Escape() {
		Exit()
	}
}