package react;

import react.BaseProps;
import react.ReactComponent;

/**
	See https://reactjs.org/docs/strict-mode.html
*/
#if (!react_global)
@:jsRequire("react", "StrictMode")
#end
@:native('React.StrictMode')
extern class StrictMode extends ReactComponentOfProps<BasePropsWithOptChildren> {}

