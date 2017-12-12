Class ImageList {
	__New(InitialCount := 5, GrowCount := 2, LargeIcons := false) {
		this.Size := 0
		this.id := IL_Create(InitialCount, GrowCount, LargeIcons)
		p(this.base.__Class " created")
	}
	
	__Delete() {
		IL_Destroy(this.id)
		p(this.base.__Class " destroyed")
	}
	
	Add(Resource, IconNumber := "", ResizeNonIcon := "") {
		if id := IL_Add(this.id, Resource, IconNumber, ResizeNonIcon) {
			this.Size++
			return id
		}
	}
}