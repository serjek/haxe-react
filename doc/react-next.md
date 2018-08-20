# React #next

Branch `#next` of my haxe-react fork aims to move haxe-react forward to 2.0.0+
with an improved freedom to break things until I get them right.

This version of haxe-react can be considered unstable (even though it is
currently being used in production) due to these huge changes it can go through.

## Different jsx parser

Based off [back2dos](https://github.com/back2dos)'s
[PR #95](https://github.com/massiveinteractive/haxe-react/pull/95), tink_hxx is
used to handle jsx.

This implies some little syntax changes:
* `prop=$42` and such are no longer allowed, use `prop=${42}` or `prop={42}`
* `prop=${true}` can now be expressed as simply `prop`

Other changes introduced by tink_hxx:
* Props are type-checked against the component's `TProps`
* You cannot pass props not recognized by the target component

Further changes added in `#next`:
* [`6e8fe8d`](https://github.com/kLabz/haxe-react/commit/6e8fe8d) Allow String variables as jsx node
* [`d173de0`](https://github.com/kLabz/haxe-react/commit/d173de0) Fix error position when using invalid nodes in jsx
* [`578c55d`](https://github.com/kLabz/haxe-react/commit/578c55d) Disallow invalid values inside jsx when a fragment is expected

## ReactComponentOf cleanup

Cherry-picked
[PR #108](https://github.com/massiveinteractive/haxe-react/pull/108), which
removed the legacy `TRefs` from `ReactComponent`, so now we have:
* `ReactComponentOf<TProps, TState>`
* `ReactComponentOfProps<TProps>`
* `ReactComponentOfState<TState>`
* `ReactComponentOfNothing`, for when you cannot use a static component and are
 using neither props nor state
* And still `ReactComponent` which has untyped props and state

This is actually a big change, since `ReactComponentOfProps` and
`ReactComponentOfState` use `react.Empty` type as `TState` (resp. `TProps`).

`react.Empty` is an empty typedef, disabling state access/update on
`ReactComponentOfProps`, and props access in `ReactComponentOfState`.

`ReactComponentOfPropsAndState` is still available with the compilation flag
`-D react_deprecated_refs`. Other TRefs-related typedefs have been removed.

## `ReactFragment`

`ReactFragment` (in `react.ReactComponent` module) tries to be closer to react
in describing a valid element. It replaces `ReactElement` in most API, allowing
them to use other types allowed by react.

`ReactFragment` unifies with either:
* `ReactElement`
* `String`
* `Float` (and `Int`)
* `Bool`
* `Array<ReactFragment>`

## `ReactNode` and `ReactNodeOf`

`ReactNode` replaces `CreateElementType` and allows:
* `String`
* `Void->ReactFragment`
* `TProps->ReactFragment`
* `Class<ReactComponent>`
* `@:jsxStatic` components

There is also `ReactNodeOf<TProps>`, for cases when you want a component
accepting some specific props.

## More debug tools

* [`98233c3`](https://github.com/kLabz/haxe-react/commit/98233c3) Add warning if ReactComponent's render has no override
* [`ef0b0f1`](https://github.com/kLabz/haxe-react/commit/ef0b0f1) React runtime warnings: add check for state initialization
