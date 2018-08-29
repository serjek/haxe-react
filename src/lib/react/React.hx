package react;

import react.ReactComponent.ReactElement;
import react.ReactComponent.ReactFragment;
import react.ReactComponent.ReactSingleFragment;

/**
	https://facebook.github.io/react/docs/react-api.html
**/
#if (!react_global)
@:jsRequire("react")
#end
@:native('React')
extern class React
{
	// Warning: react.React.PropTypes is deprecated, reference as react.ReactPropTypes

	/**
		https://reactjs.org/docs/react-api.html#createelement
	**/
	public static function createElement(type:CreateElementType, ?attrs:Dynamic, children:haxe.extern.Rest<Dynamic>):ReactFragment;

	/**
		https://reactjs.org/docs/react-api.html#cloneelement
	**/
	public static function cloneElement(element:ReactElement, ?attrs:Dynamic, children:haxe.extern.Rest<Dynamic>):ReactElement;

	/**
		https://reactjs.org/docs/react-api.html#isvalidelement
	**/
	public static function isValidElement(object:Dynamic):Bool;

	/**
		https://reactjs.org/docs/react-api.html#reactcreateref

		Note: this API has been introduced in React 16.3
		If you are using an earlier release of React, use callback refs instead
		https://reactjs.org/docs/refs-and-the-dom.html#callback-refs
	**/
	public static function createRef<TRef>():ReactRef<TRef>;

	/**
		https://reactjs.org/docs/react-api.html#reactforwardref
		See also https://reactjs.org/docs/forwarding-refs.html

		Note: this API has been introduced in React 16.3
		If you are using an earlier release of React, use callback refs instead
		https://reactjs.org/docs/refs-and-the-dom.html#callback-refs
	**/
	public static function forwardRef<TProps, TRef>(render:TProps->ReactRef<TRef>->ReactElement):CreateElementType;

	/**
		https://reactjs.org/docs/react-api.html#reactchildren
	**/
	public static var Children:ReactChildren;

	public static var version:String;
}

/**
	https://reactjs.org/docs/react-api.html#reactchildren
**/
extern interface ReactChildren
{
	/**
		https://reactjs.org/docs/react-api.html#reactchildrenmap
	**/
	function map(children:Dynamic, fn:ReactFragment->ReactFragment):Null<Array<ReactFragment>>;

	/**
		https://reactjs.org/docs/react-api.html#reactchildrenforeach
	**/
	function foreach(children:Dynamic, fn:ReactFragment->Void):Void;

	/**
		https://reactjs.org/docs/react-api.html#reactchildrencount
	**/
	function count(children:ReactFragment):Int;

	/**
		https://reactjs.org/docs/react-api.html#reactchildrenonly
	**/
	function only(children:ReactFragment):ReactSingleFragment;

	/**
		https://reactjs.org/docs/react-api.html#reactchildrentoarray
	**/
	function toArray(children:ReactFragment):Array<ReactFragment>;
}

@:deprecated
typedef CreateElementType = ReactNode;

