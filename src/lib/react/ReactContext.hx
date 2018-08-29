package react;

extern interface ReactContext<T>
{
	var Consumer:ReactContext<T>;
	var Provider:ReactProviderType<T>;

	var unstable_read:Void->T;
	var _calculateChangedBits:Null<T->T->Int>;

	var _currentValue:T;
	var _currentValue2:T;

	#if debug
	@:optional var _currentRenderer:Null<Dynamic>;
	@:optional var _currentRenderer2:Null<Dynamic>;
	#end
}

extern interface ReactProviderType<T>
{
	var _context:ReactContext<T>;
}
