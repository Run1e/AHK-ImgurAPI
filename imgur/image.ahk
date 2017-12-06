Class ImageType {
	static Extensions := ["JPG", "JPEG", "PNG", "GIF", "APNG", "TIFF", "PDF"]
	
	__New(Client, File := "") {
		this.Client := Client
		
		if File {
			SplitPath, File,,, Ext
			
		; check if its filetype is recognized by imgur
			if !ArrayHasValue(this.Extensions, Ext)
				throw new Imgur.Errors.FileTypeError(Ext)
			
		; check if file exists
			if !FileExist(File)
				throw new Imgur.Errors.MissingFileError(File)
			
		; make sure file is under 10mb large
			FileGetSize, Size, % File
			if (Size > 10480000)
				throw new Imgur.Errors.FileSizeError(Size)
			
			this.File := File
		}
	}
	
	__Delete() {
		this.Client.Print("ImageType instance removed: " this.File "(" this.id ")")
	}
	
	Upload() {
		this.Client.Upload(this)
	}
}