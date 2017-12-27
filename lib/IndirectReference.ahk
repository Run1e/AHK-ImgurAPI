Class IndirectReference {
	static Storage := {}
	
	__New(Obj) {
		for RefPtr, ObjPtr in IndirectReference.Storage
			if (ObjPtr = &Obj)
				return Object(RefPtr)
		
		IndirectReference.Storage[&this] := &Obj
		Obj.base := {__Class: Obj.base.__Class, __Delete: Func("IndirectReferenceDelete"), base: Obj.base}
	}
	
	__Delete() {
		IndirectReference.Storage.Delete(&this)
	}
	
	__Call(Method, Params*) {
		if Ptr := IndirectReference.Storage[&this]
			return Object(Ptr)[Method](Params*)
	}
	
	__Get(Key) {
		if Ptr := IndirectReference.Storage[&this]
			return Object(Ptr)[Key]
	}
	
	__Set(Key, Value) {
		if Ptr := IndirectReference.Storage[&this]
			return Object(Ptr)[Key] := Value
	}
}

IndirectReferenceDelete(this) {
	for RefPtr, ObjPtr in IndirectReference.Storage
		if (&this = ObjPtr)
			IndirectReference.Storage.Delete(RefPtr)
	
	base := this.base
	while (base := base.base)
		if base.HasKey("__Delete")
			return Func(base.__Class ".__Delete").Call(this)
}