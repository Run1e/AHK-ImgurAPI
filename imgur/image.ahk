Class ImageType {
	static Extensions := ["JPG", "JPEG", "PNG", "GIF", "APNG", "TIFF", "PDF"]
	
	__New(Client, File := "") {
		SplitPath, File,,, Ext
		
		; check if file exists
		if !FileExist(File)
			throw new Imgur.Errors.MissingFileError(File)
		
		; check if its filetype is recognized by imgur
		if !ArrayHasValue(this.Extensions, Ext)
			throw new Imgur.Errors.FileTypeError(Ext)
		
		
		this.Client := Client
		this.File := File
	}
	
	Upload() {
		this.Client.Upload(this)
	}
	
	__Delete() {
		this.Client.Print("Removing ImageType instance.")
	}
}