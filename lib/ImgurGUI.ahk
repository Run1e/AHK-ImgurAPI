/*
	image previewer {
		basically as my previous one, with moving gif images and image previews
		double-clicking copies image link to clipboard
		maybe a right click context menu? for deleting and other stuff
	}
	
	save control {
		whether to save locally or to upload to imgur
	}
	
	hotkey gui {
		set up basic like open/close gui
		image capture hotkeys
	}
	
	settings gui {
		
	}
*/

Class ImgurGUI extends GuiBase {
	Init() {
		
		this.Title := this.base.__Class
		this.BackgroundColor := 0xFFFFFF
		
		this.Options(["+Resize", "-MaximizeBox"])
		
		this.AddText(, "TEXTERINO")
		this.AddEdit(, "what is up mein doot!")
		
	}
	
	Escape() {
		Exit()
	}
}