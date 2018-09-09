package support.sub;

import react.ReactComponent;

@:ignoreEmptyRender
class CompModule extends ReactComponent
{
	static public var defaultProps = {
		defA:'B',
		defB:43
	}

	public function new()
	{
		super();
	}

}
