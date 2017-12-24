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

Class ImgurGUI extends GuiBase {
	Init() {
		
		;this.BitmapLoader := AhkThread()
		
		this.BackgroundColor := 0x161616
		
		this.Options([{("+MinSize"): "540x256"}, "+Resize", "+Border"])
		
		this.ImageLV := this.AddListView([{x: 0, y: 0, ("+Background"): 161616}, "-Hdr", "-Border"], ["FuckAjitPai|id"])
		this.ImageLV.ModifyCol(1, 0)
		this.ImageLV.ModifyCol(2, 0)
		this.ImageLV.SetImageList(new CustomImageList(Settings.Image.Width, Settings.Image.Height, 0x20))
		
		Loop 20
			this.ImageAdd(A_ScriptDir "\pic.jpg")
	}
	
	ImageAdd(File) {
		static SpacingSet := false
		
		if !Icon := this.ImageLV.IL.AddFile(File) {
			Debug.Log(Exception("Couldn't add image to imagelist", -1, File))
			return false
		}
		this.ImageLV.Insert(1, [{Icon: Icon}],, 1)
		
		if !SpacingSet {
			LV_EX_SetIconSpacing(this.ImageLV.hwnd, Settings.Image.Width + Settings.Image.Spacing, Settings.Image.Height + Settings.Image.Spacing)
			SpacingSet := true
		}
		
		this.FixOrder()
	}
	
	Show(Options := "") {
		Gui % this.hwnd ":Show", % this.CraftOptions(Options), % this.TitleValue
	}
	
	FixOrder() {
		this.ImageLV.Options(["+Report"])
		this.ImageLV.Options(["+Icon"])
		;this.ImageLV.Modify(1, "Vis")
	}
	
	UploadProgress(Image, Current, Total) {
		t(Image, Current/Total)
	}
	
	Size(EventInfo, Width, Height) {
		this.ImageLV.Pos.W := Width - 250
		this.ImageLV.Pos.H := Height
		Settings.Window.Width := Width
		Settings.Window.Height := Height
		Settings.Window.State := EventInfo
		this.FixOrder()
	}
	
	Escape() {
		Exit()
	}
}