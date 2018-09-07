# Custom compilation flags used by haxe-react

## `-debug` / `-D debug`

This is not a custom compilation flag, but it enables/disables some features in
haxe-react. Basically, you'll want to compile with it when using dev version of
react, and remove it when using prog version.

### Disabled features

#### Inline ReactElements

By default, when building for release (eg. without `-debug`), calls to
`React.createElement` are replaced by inline JS objects (if possible). This can
also be disabled with `-D react_no_inline`.

See: https://github.com/facebook/react/issues/3228

```javascript
// regular
return React.createElement('div', {key:'bar', className:'foo'});

// inlined (simplified)
return {$$typeof:Symbol.for('react.element'), type:'div', props:{className:'foo'}, key:'bar'}
```

### Enabled features

#### Display names

When compiling in debug mode, display names are added for your components, for
use with your browser's react developer tools.

#### React shared internals

Some react shared internals data are only available when compiling in debug mode
(and using dev version of react), for advanced debugging.

#### React runtime warnings

Haxe-react adds some runtime warnings when enabled with both debug mode and
`-D react_runtime_warnings`. There is still work to be done here, especially
with the re-render warnings that have some false positives atm.

This warnings include:

* Runtime warnings about avoidable re-renders, unless you also compile with
 `-D react_runtime_warnings_ignore_rerender` **or** for a specific component if
 you add a `@:ignoreRenderWarning` meta to it. This feature can be disabled
 because it can have false positives when dealing with legacy context API or
 hot reloading.

* Runtime errors when a stateful component does not initialize its state inside
 its constructor. There would be errors thrown by react later in the component
 lifecycle, but without the source cause.

	```haxe
	js.Browser.console.error(
		'Warning: component ${inClass.name} is stateful but its '
		+ '`state` is not initialized inside its constructor.\n\n'

		+ 'Either add a `state = { ... }` statement to its constructor '
		+ 'or define this component as a `ReactComponentOfProps` '
		+ 'if it is only using `props`.\n\n'

		+ 'If it is using neither `props` nor `state`, you might '
		+ 'consider using `@:jsxStatic` to avoid unneeded lifecycle. '
		+ 'See https://github.com/kLabz/haxe-react/blob/next/doc/static-components.md '
		+ 'for more information on static components.'
	);
	```

#### Runtime errors for `null` nodes

`ReactNode` adds a runtime error when a node ends up with a `null` value, which
is usually due to an extern component not resolving to its real value.

## `-D react_global`

Use this compilation flag when you are loading react by embedding react js files
in your HTML page (instead of using `require()` from modular or webpack).

## `-D react_hot`

Adds some data needed for react hot reloading with modular / webpack. See
[haxe-modular documentation](https://github.com/elsassph/haxe-modular/blob/master/doc/hmr-usage.md).

## `-D react_deprecated_context`

The `context` field on `ReactComponent` has been removed because it has been
deprecated in react and its use as a class field is discouraged. You can add it
back with this flag if needed.

## `-D react_wrap_strict`

Enable strict mode for `@:wrap` HOC wrapping. This will ensure you define the
public props type of your component wrapped with `@:wrap` so that jsx type
checking can be done.
See [Wrapping your components in HOCs](./wrapping-with-hoc.md).
