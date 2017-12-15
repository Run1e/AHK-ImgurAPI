class IndirectReference {
	
	static Storage := {}
	
	__New(obj) {
		this.base.Storage[&this] := &obj
	}
	
	__Delete() {
		this.base.Storage.Delete(&this)
	}
	
	__Set(Key, Val) {
		if IsObject(Object := Object(this.base.Storage[&this]))
			Object[Key] := Val
	}
	
	__Get(Key) {
		if (Key != "base")
			if IsObject(Object := Object(this.base.Storage[&this]))
				return Object[Key]
	}
	
	__Call(Method, Params*) {
		if IsObject(Object := Object(this.base.Storage[&this]))
			return Object[Method](Params*)
	}
}