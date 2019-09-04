# Anatomy of a React Component

```haxe
package my.pack;

// I usually put all these in an `import.hx` file
// Note: some of these aren't being used in this example module
import js.lib.Error; // Note: js.Error on haxe < 4.0.0 rc 3
import react.BaseProps;
import react.Empty;
import react.Partial;
import react.PureComponent;
import react.React;
import react.ReactMacro.jsx;
import react.ReactRef;
import react.ReactType;
import react.ReactComponent;

// I use private typedefs to be able to use `State` and `Props` names for all
// my components without any conflict
private typedef Props = {
    var someRequiredProp:String;
    var someCallbackProp:()->Void;
    var someCallbackPropWithArgs:(index:Int, label:String)->Bool;
    @:optional var someOptionalProp:Int;
}

private typedef State = {
    var active:Bool;
}

// See `ReactComponent base classes` below to know which type to `extend`.
// Also see [Converting a Function to a Class](https://reactjs.org/docs/state-and-lifecycle.html#converting-a-function-to-a-class)
// from React docs if needed.
class MyComponent extends ReactComponentOf<Props, State> {
    // Note: you can omit constructor if your component doesn't have any `state`
    public function new(props:Props) {
        super(props);

        // State should be initialized in constructor
        state = {
            active: false
        };
    }

    // See `Lifecycle methods` below
    override function componentDidMount():Void {
        // Do something here
    }

    override function render():ReactFragment {
        return jsx(
            <SomeComponent
                onClick={doSomething}
                someCallback={() -> doSomething()}
                callbackWithArg={(value, _) -> doSomethingElse(value)} // Second argument is ignored
                stringProp="Some string"
                numberProp={42}
                booleanProp={false}
                someFlag // Inferred `someFlag={true}`
            />
        );
    }

    // In haxe, no need to `bind()` to access current instance
    function doSomething() {
        // You can freely use `props` / `state` from here,
        // Or call other instance functions
    }

    function doSomethingElse(value:String) trace(value);
}
```

## ReactComponent base classes

TODO:

* ReactComponentOfProps<Empty> for no props & no state
* ReactComponentOfProps<Props>
* ReactComponentOfState<State>
* ReactComponentOf<Props, State>

## Lifecycle methods

See [React lifecycle methods diagram](http://projects.wojtekmaj.pl/react-lifecycle-methods-diagram/)
for an overview.

Note: replace `TProps` and `TState` by your own props/state types (`Props` and
`State` for above example). If your component opted out of props or state, use
`Empty` (`react.Empty`) instead.

### `componentDidMount()`

```haxe
override function componentDidMount():Void {
	// ...
}
```

> `componentDidMount()` is invoked immediately after a component is mounted
> (inserted into the tree). Initialization that requires DOM nodes should go
> here. If you need to load data from a remote endpoint, this is a good place to
> instantiate the network request. [[read more]](https://reactjs.org/docs/react-component.html#componentdidmount)

### `componentDidUpdate(prevProps, prevState, snapshot)`

```haxe
override function componentDidUpdate(prevProps:TProps, prevState:TState, snapshot:Null<TSnapshot>):Void {
	// ...
}
```

> `componentDidUpdate()` is invoked immediately after updating occurs. This
> method is not called for the initial render. [[read more]](https://reactjs.org/docs/react-component.html#componentdidupdate)

### `componentWillUnmount()`

```haxe
override function componentWillUnmount():Void {
	// ...
}
```

> `componentWillUnmount()` is invoked immediately before a component is
> unmounted and destroyed. Perform any necessary cleanup in this method, such as
> invalidating timers, canceling network requests, or cleaning up any
> subscriptions that were created in `componentDidMount()`. [[read more]](https://reactjs.org/docs/react-component.html#componentwillunmount)

### `shouldComponentUpdate(nextProps, nextState)`

```haxe
override function shouldComponentUpdate(nextProps:TProps, nextState:TState):Bool {
	// ...
	return true;
}
```

> Use `shouldComponentUpdate()` to let React know if a component’s output is not
> affected by the current change in state or props. The default behavior is to
> re-render on every state change, and in the vast majority of cases you should
> rely on the default behavior. [[read more]](https://reactjs.org/docs/react-component.html#shouldcomponentupdate)

### `getDerivedStateFromProps(props, prevState)`

```haxe
static function getDerivedStateFromProps(props:TProps, prevState:TState):Null<Partial<TState>> {
	// ...
	return null;
}
```

> `getDerivedStateFromProps` is invoked right before calling the render method,
> both on the initial mount and on subsequent updates. It should return an
> object to update the state, or null to update nothing. [[read more]](https://reactjs.org/docs/react-component.html#static-getderivedstatefromprops)

### `getDerivedStateFromError(error)`

```haxe
static function getDerivedStateFromError(error:Error):Null<Partial<TState>> {
	// ...
	return null;
}
```

> This lifecycle is invoked after an error has been thrown by a descendant
> component. It receives the error that was thrown as a parameter and should
> return a value to update state. [[read more]](https://reactjs.org/docs/react-component.html#static-getderivedstatefromerror)

### `getSnapshotBeforeUpdate(prevProps, prevState)`

```haxe
override function getSnapshotBeforeUpdate(nextProps:TProps, nextState:TState):Null<TSnapshot> {
	// ...
	return null;
}
```

> `getSnapshotBeforeUpdate()` is invoked right before the most recently
> rendered output is committed to e.g. the DOM. It enables your component to
> capture some information from the DOM (e.g. scroll position) before it is
> potentially changed. Any value returned by this lifecycle will be passed as a
> parameter to `componentDidUpdate()`. [[read more]](https://reactjs.org/docs/react-component.html#getsnapshotbeforeupdate)

### `componentDidCatch(error, info)`

```haxe
override function componentDidCatch(error:Error, info:ReactErrorInfo):Void {
	// ...
}
```

> This lifecycle is invoked after an error has been thrown by a descendant
> component. [[read more]](https://reactjs.org/docs/react-component.html#componentdidcatch)

## State handling

TODO:

* note about state initialization in constructor
* notes about `setState()` overloads
* note about not modifying state directly (not haxe specific, but doesn't hurt)
