package react;

import react.ReactComponent;

/**
	https://reactjs.org/docs/test-utils.html
**/
@:jsRequire("react-dom/test-utils")
extern class ReactTestUtils {
	/**
		To prepare a component for assertions, wrap the code rendering it and
		performing updates inside an act() call. This makes your test run closer
		to how React works in the browser.

		https://reactjs.org/docs/test-utils.html#act
	**/
	public static function act(task:Void->Void):Void;

	/**
		Returns true if element is any React element.

		https://reactjs.org/docs/test-utils.html#iselement
	**/
	public static function isElement(element:ReactFragment):Bool;

	/**
		Returns true if element is a React element whose type is of a React
		componentClass.

		https://reactjs.org/docs/test-utils.html#iselementoftype
	**/
	public static function isElementOfType(
		element:ReactFragment,
		componentClass:ReactType
	):Bool;

	/**
		Returns true if instance is a DOM component (such as a <div> or <span>).

		https://reactjs.org/docs/test-utils.html#isdomcomponent
	**/
	public static function isDOMComponent(element:ReactFragment):Bool;

	/**
		Returns true if instance is a user-defined component, such as a class or
		a function.

		https://reactjs.org/docs/test-utils.html#iscompositecomponent
	**/
	public static function isCompositeComponent(element:ReactFragment):Bool;

	/**
		Returns true if instance is a component whose type is of a React
		componentClass.

		https://reactjs.org/docs/test-utils.html#iscompositecomponentwithtype
	**/
	public static function isCompositeComponentWithType(
		element:ReactFragment,
		componentClass:ReactType
	):Bool;

	/**
		Traverse all components in tree and accumulate all components where
		test(component) is true. This is not that useful on its own, but it’s
		used as a primitive for other test utils.

		https://reactjs.org/docs/test-utils.html#findallinrenderedtree
	**/
	public static function findAllInRenderedTree(
		tree:ReactFragment,
		predicate:ReactFragment->Bool
	):Array<ReactFragment>;

	/**
		Finds all DOM elements of components in the rendered tree that are DOM
		components with the class name matching className.

		https://reactjs.org/docs/test-utils.html#scryrendereddomcomponentswithclass
	**/
	public static function scryRenderedDOMComponentsWithClass(
		tree:ReactFragment,
		className:String
	):Array<ReactFragment>;

	/**
		Like scryRenderedDOMComponentsWithClass() but expects there to be one
		result, and returns that one result, or throws exception if there is any
		other number of matches besides one.

		https://reactjs.org/docs/test-utils.html#findrendereddomcomponentwithclass
	**/
	public static function findRenderedDOMComponentWithClass(
		tree:ReactFragment,
		className:String
	):ReactFragment;

	/**
		Finds all DOM elements of components in the rendered tree that are DOM
		components with the tag name matching tagName.

		https://reactjs.org/docs/test-utils.html#scryrendereddomcomponentswithtag
	**/
	public static function scryRenderedDOMComponentsWithTag(
		tree:ReactFragment,
		tagsName:String
	):Array<ReactFragment>;

	/**
		Like scryRenderedDOMComponentsWithTag() but expects there to be one
		result, and returns that one result, or throws exception if there is any
		other number of matches besides one.

		https://reactjs.org/docs/test-utils.html#findrendereddomcomponentwithtag
	**/
	public static function findRenderedDOMComponentWithTag(
		tree:ReactFragment,
		tagsName:String
	):ReactFragment;

	/**
		Finds all instances of components with type equal to componentClass.

		https://reactjs.org/docs/test-utils.html#scryrenderedcomponentswithtype
	**/
	public static function scryRenderedComponentsWithType(
		tree:ReactFragment,
		componentClass:ReactType
	):Array<ReactFragment>;

	/**
		Same as scryRenderedComponentsWithType() but expects there to be one
		result and returns that one result, or throws exception if there is any
		other number of matches besides one.

		https://reactjs.org/docs/test-utils.html#findrenderedcomponentwithtype
	**/
	public static function findRenderedComponentWithType(
		tree:ReactFragment,
		componentClass:ReactType
	):ReactFragment;

	/**
		Render a React element into a detached DOM node in the document. This
		function requires a DOM.

		It is effectively equivalent to:

		```haxe
		var domContainer = js.Browser.document.createElement('div');
		ReactDOM.render(element, domContainer);
		```

		https://reactjs.org/docs/test-utils.html#renderintodocument
	**/
	public static function renderIntoDocument(element:ReactFragment):ReactFragment;
}

@:jsRequire("react-dom/test-utils", "Simulate")
extern class Simulate {
	// TODO
}
