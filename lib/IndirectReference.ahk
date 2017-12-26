Class IndirectReferenceCompatible {
	__IndirectReferenceVar := IndirectReferenceCompatible.__New.Call(this)
	
	__New() {
		; replace the top __Delete with this base class' __Delete
		base := this.base
		Loop {
			if deletebase && (base.__Class = "IndirectReferenceCompatible") {
				deletebase.__Delete := base.__Delete
				break
			} else if !deletebase && base.HasKey("__Delete")
				deletebase := base
			base := base.base
		} until !base
	}
	
	__Delete() {
		; delete the object ref in the Storage
		for ReferencePtr, ObjectPtr in IndirectReference.Storage
			if (ObjectPtr = &this)
				IndirectReference.Storage.Pop(ReferencePtr)
		
		; find the top level __Delete and call it
		base := this.base
		Loop {
			if base.HasKey("__Delete") && (base.__Class != "IndirectReferenceCompatible") {
				Func(base.__Class ".__Delete").Call(this)
				break
			} base := base.base
		} until !base
	}
}

Class IndirectReference {
	
	static Storage := []
	
	__New(Obj) {
		IndirectReference.Storage[&this] := &Obj
	}
	
	__Call(Method, Params*) {
		if ptr := IndirectReference.Storage[&this]
			return Object(ptr)[Method](Params*)
		
	}
	
	__Get(Key) {
		if ptr := IndirectReference.Storage[&this]
			return Object(ptr)[Key]
	}
	
	__Set(Key, Value) {
		if ptr := IndirectReference.Storage[&this]
			return Object(ptr)[Key] := Value
	}
}