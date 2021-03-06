﻿; libs
#Include %A_LineFile%\..\lib\JSON.ahk
#Include %A_LineFile%\..\request\request.ahk

Class Imgur {
	
	; misc
	#Include %A_LineFile%\..\Errors.ahk
	#Include %A_LineFile%\..\Queue.ahk
	#Include %A_LineFile%\..\UploadWorker.ahk
	#Include %A_LineFile%\..\types\Image.ahk
	
	; imgurs API endpoint
	static Endpoint := "https://api.imgur.com/3/"
	
	__New(client_id, Debug := "") {
		if !IsObject(IndirectReference)
			throw "Missing dependency: IndirectReference"
		
		this.id := client_id
		this.Debug := Debug
		
		; holds arrays of events for each event
		this.Events := 
		(LTrim Join
		{
			UploadResponse: [],
			UploadProgress: [],
			GetImageResponse: []
		}
		)
		
		; create the image upload worker
		this.Uploader := new Imgur.UploadWorker(this)
		
		this.Print(class(this) " created")
	}
	
	__Delete() {
		this.Uploader := ""
		this.Print(class(this) " released")
	}
	
	Print(x*) {
		this.Debug.Call(x*)
	}
	
	/*
		shorthand for new Imgur.ImageType(Instance, File)
	
		
		throws:
		Imgur.FileTypeError - incompatible file type
		Imgur.FileSizeError - file size too large
	*/
	Image(FileOrID := "") {
		return new Imgur.ImageType(this, FileOrID)
	}
	
	ImageFromObj(Obj) {
		Image := this.Image()
		for Key, Value in Obj
			Image[Key] := Value
		return Image
	}
	
	/*
		UPLOAD IMAGE
		
		throws:
		Imgur.FileError - on bad file type
		Imgur.ClientMismatch - on client mismatch between this and Image client
		Imgur.MissingFileError - file specified by Image doesn't exist
	*/
	Upload(Image, Callback := "") {
		; check the Image parameter is an Image type
		if !isinstance(Image, Imgur.ImageType)
			throw new Imgur.TypeError("Input has to be an Imgur.ImageType instance.")
		
		; throw ClientMismatch if Image stems from another client
		if (&(Image.Client) != &this)
			throw new Imgur.ClientMismatch
		
		Image.Upload(Callback)
	}
	
	GetImage(ImageHash, Callback := "") {
		if isinstance(ImageHash, Imgur.ImageType)
			Image := ImageHash
		else
			Image := this.Image(ImageHash)
		Image.Get(Callback)
	}
	
	/*
		register an event.
		
		valid events:
		UploadResponse - runs when an image upload response is received
		UploadProgress - runs when an image being uploaded progresses
		GetImageResponse - runs when a GetImage request returns a response
	*/
	OnEvent(Event, Func) {
		this.Events[Event].Push(Func)
	}
	
	; clear a type of event
	ClearEvent(Event) {
		this.Events[Event] := []
	}
	
	/*
		!!! PRIVATE METHODS !!!
	*/
	
	ParseResponse(Resp) {
		Error := false
		
		try 
			Data := JSON.Load(Resp.ResponseText)
		catch e
			Error := new Imgur.BadResponse({JSONError: e})
		
		if Resp.Error {
			Error := new Imgur.RequestError({What: Resp.Error.Extra, Extra: Resp.Error.Message})
			if IsObject(Data)
				Error.Data := Data
		} else if (Resp.Status != 200) {
			Error := new Imgur[Resp.Status "HTTPError"]
			if IsObject(Data) {
				Error.Data := Data
				Error.What := Data.Status
				Error.Extra := Data.Data.Error
			}
		}
		
		return {Data: Data.data, Error: Error}
	}
	
	/*
			call an event.
		
		callback provided? the event should not be raised.
		not? then run the event.
	*/
	CallEvent(Event, Callback, Param*) {
		if Callback
			Callback.Call(Param*)
		else
			for Index, EventFunc in this.Events[Event]
				EventFunc.Call(Param*)
	}
}

; checks if Instance is an instance of Class
isinstance(instance, class) {
	return class(instance) = class(class)
}

class(instance) {
	return instance.__Class
}

; checks if a normal array has a value
ArrayHasValue(Array, Value) {
	for k, v in Array
		if (v = Value)
			return true
	return false
}