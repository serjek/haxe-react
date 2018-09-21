# Custom meta used by haxe-react

## `@:wrap(hoc)`

Wrap current component (must extend `ReactComponent`) in a HOC.

See [Wrapping your components in HOCs](./wrapping-with-hoc.md) for more
information about this meta and the following related meta:

#### `@:publicProps(TProps)`

Set public props type to ensure jsx type checking.

#### `@:noPublicProps`

Disallow public props for this component when used in jsx.

#### `@:wrapped_by_macro`

This special meta is added by the `@:wrap` macro for internal use, do not set it
if you don't want to break the functionality.

## `@:jsxStatic(method)`

Create a static component that you can use in jsx (and where "real" components
are expected) from a static function from a class (**not** a `ReactComponent`
class).

See [Static components](./static-components.md).

## `@:ignoreEmptyRender`

There is a compile-time check for an override of the `render` function in your
components. This helps catching following runtime warning sooner:

	Warning: Index(...): No `render` method found on the returned component
	instance: you may have forgotten to define `render`.

Catching it at compile-time also ensures it does not happen to a component only
visible for a few specific application state.

You can disable this with the `-D react_ignore_empty_render` compilation flag,
or for a specific component by adding `@:ignoreEmptyRender` meta to it.

## `@:pureComponent`

TODO: Documentation for macro implementation of pure components.

## `@:ignoreRenderWarning`

TODO: Documentation for runtime warnings.
