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
	Init() {
		try
			this.BitmapWorker := new BitmapWorker(Settings.Image.Width, Settings.Image.Height, this.Debug)
		catch e
			throw "Failed starting BitmapWorker."
		
		this.BackgroundColor := 0x161616
		
		this.Options([{("+MinSize"): "540x256"}, "+Resize", "+Border"])
		
		this.ImageLV := this.AddListView([{x: 0, y: 0, ("+Background"): 161616}, "-Hdr", "-Border"], ["FuckAjitPai|id"])
		this.ImageLV.OnEvent(this.ImageLVEvent.Bind(this))
		this.ImageLV.ModifyCol(1, 0)
		this.ImageLV.ModifyCol(2, 0)
		this.ImageLV.SetImageList(new CustomImageList(Settings.Image.Width, Settings.Image.Height, 0x20))
		
		this.Font([{s: 11}])
		
		this.QueueLV := this.AddListView([{x: 0, y: 0, Background: "0x161616"}, "-Border"], ["File", "Status"])
		this.QueueLV.Pos.W := 400
		this.QueueLV.ModifyCol(1, 300)
		this.QueueLV.ModifyCol(2, 100 - 4)
		
		this.Status := this.AddStatusBar()
		this.Status.Pos.W := 23
		this.Status.SetParts(0, 0)
		this.Status.SetText("Imgur Uploader by RUNIE", 1)
		
		; tab 1, hotkeys
		
		; tab 2, settings
		
		Loop 6 {
			for Index, Image in Images.Object() {
				if (A_Index > 20)
					break
				this.AddImage(Image)
			}
		}	
	}
	
	Release() {
		this.ImageLV := ""
		this.Status := ""
		this.BitmapWorker := ""
	}
	
	Size(EventInfo, Width, Height) {
		this.ImageLV.Pos.W := Width - 400
		this.ImageLV.Pos.H := Height - 23
		
		this.QueueLV.Pos.X := Width - 400
		this.QueueLV.Pos.Y := 420 - 23
		this.QueueLV.Pos.H := Height - 420
		
		this.Status.SetParts(200, Width - 200)
		
		Settings.Window.Width := Width
		Settings.Window.Height := Height
		Settings.Window.State := EventInfo
		this.FixOrder()
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
		this.BitmapWorker.Add(ImageToPath(Image), this.SafeRef.AddImageCallback.Bind(this.SafeRef, Image, Top))
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
	
	ImgurResponse(Image, Response, Error) {
		if Error {
			m("Error", class(error), Error.Message)
			return
		}
		
		m(Image)
	}
	
	UploadProgress(Image, Current, Total) {
		t(Current/Total)
	}
	
	Escape() {
		Exit()
	}
}