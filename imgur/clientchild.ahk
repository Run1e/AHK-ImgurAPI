Class ClientChild {
	__Get(Key) {
		if this.Client.HasKey(Key)
			return this.Client[Key]
		if this.Client.base.HasKey(Key)
			return this.Client.base[Key]
	}
	
	__Call(Method, Params*) {
		if (Method != "_NewEnum")
			return this.Client[Method].Bind(this.Client, Params*).Call()
	}
	
	__Delete() {
		this.Print(type(this) " destroyed")
	}
}