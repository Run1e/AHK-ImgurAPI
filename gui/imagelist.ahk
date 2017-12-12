Class ImageList {
	static Instances := []
	
	__New(InitialCount := 5, GrowCount := 2, LargeIcons := false) {
		this.ID := IL_Create(InitialCount, GrowCount, LargeIcons)
		Gui.ListView.ImageList.Instances[this.ID] := this
		return this
	}
	
	Destroy() {
		Gui.ListView.ImageList.Instances.Remove(this.ID)
		return IL_Destroy(this.ID)
	}
	
	Add(File) {
		return IL_Add(this.ID, File)
	}
}