package react.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

@:dce
class ReactTypeMacro
{
	static public inline var ALTER_SIGNATURES_BUILDER = 'AlterSignatures';
	static public inline var ENSURE_RENDER_OVERRIDE_BUILDER = 'EnsureRenderOverride';
	static public inline var CHECK_GET_DERIVED_STATE_BUILDER = 'CheckDerivedState';
	@:deprecated static public inline var IGNORE_EMPTY_RENDER_META = ReactMeta.IgnoreEmptyRender;

	#if macro
	public static function alterComponentSignatures(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		if (inClass.isExtern) return fields;

		var types = MacroUtil.extractComponentTypes(inClass);
		var tprops = types.tprops == null ? macro :Dynamic : types.tprops;
		var tstate = types.tstate == null ? macro :Dynamic : types.tstate;

		// Only alter setState signature for non-dynamic states
		switch (tstate) {
			case TPath({name: "Empty", pack: ["react"]}), TPath({name: "Dynamic", pack: []}):

			case TPath(_) | TAnonymous(_) if (!hasSetState(fields)):
				fields = addSetStateType(fields, inClass, tprops, tstate);

			default:
		}

		return fields;
	}

	public static function ensureRenderOverride(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		if (!(inClass.isExtern || inClass.meta.has(ReactMeta.IgnoreEmptyRender)))
			if (!Lambda.exists(fields, function(f) return f.name == 'render'))
				Context.warning(
					'Component ${inClass.name}: '
					+ 'No `render` method found: you may have forgotten to '
					+ 'override `render` from `ReactComponent`.',
					inClass.pos
				);

		return fields;
	}

	public static function checkGetDerivedState(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		if (!inClass.isExtern) {
			var getDerived = MacroUtil.getField(fields, "getDerivedStateFromProps");

			if (getDerived != null) {
				switch (getDerived.kind)
				{
					case FFun(fun) if (Lambda.has(getDerived.access, AStatic)):
						var types = MacroUtil.extractComponentTypes(inClass);
						var tprops = types.tprops == null ? macro :Dynamic : types.tprops;
						var tstate = types.tstate == null ? macro :Dynamic : types.tstate;

						var expected = macro :$tprops->$tstate->react.Partial<$tstate>;
						var ct = TypeTools.toComplexType(MacroUtil.functionToType(fun));

						Context.typeof(macro @:pos(getDerived.pos) {
							var a:$ct = null;
							var b:$expected = a;
						});

					default:
						Context.warning(
							'Component ${inClass.name}: '
							+ 'Field getDerivedStateFromProps should be a static function '
							+ 'with `props` and `prevState` as arguments.',
							getDerived.pos
						);

				}
			}
		}

		return fields;
	}

	static function hasSetState(fields:Array<Field>) {
		for (field in fields)
		{
			if (field.name == #if react.setStateProfiler '_setState' #else 'setState' #end)
			{
				return switch (field.kind) {
					case FFun(f): true;
					default: false;
				}
			}
		}

		return false;
	}

	static function addSetStateType(
		fields:Array<Field>,
		inClass:ClassType,
		propsType:ComplexType,
		stateType:ComplexType
	):Array<Field> {
		#if react.setStateProfiler
		return fields.concat((macro class C {
			@:native('__setStateProfiler')
			@:overload(function(nextState:react.Partial<$stateType>, ?callback:Void -> Void):Void {})
			@:overload(function(nextState:$stateType -> $propsType -> react.Partial<$stateType>, ?callback:Void -> Void):Void {})
			function setState(nextState:$stateType -> react.Partial<$stateType>, ?callback:Void -> Void):Void {
				var start = haxe.Timer.stamp();
				_setState(nextState, callback);
				var delta = haxe.Timer.stamp() - start;

				if (delta > 0.1) {
					js.Browser.console.warn(
						$v{inClass.name}
						+ '.setState() took more than 100ms (' + Math.round(delta * 1000) + 'ms), '
						+ 'which seems to indicate that it triggered an immediate render'
						// TODO: more documentation on first warning
						// See https://www.bennadel.com/blog/2893-setstate-state-mutation-operation-may-be-synchronous-in-reactjs.htm
					);
				}
			}

			@:extern
			@:native('setState')
			@:overload(function(nextState:react.Partial<$stateType>, ?callback:Void -> Void):Void {})
			@:overload(function(nextState:$stateType -> $propsType -> react.Partial<$stateType>, ?callback:Void -> Void):Void {})
			override public function _setState(nextState:$stateType -> react.Partial<$stateType>, ?callback:Void -> Void):Void
				#if !haxe4
				{ super._setState(nextState, callback); }
				#end
			;
		}).fields);
		#else
		return fields.concat((macro class C {
			@:extern
			@:overload(function(nextState:react.Partial<$stateType>, ?callback:Void -> Void):Void {})
			@:overload(function(nextState:$stateType -> $propsType -> react.Partial<$stateType>, ?callback:Void -> Void):Void {})
			override public function setState(nextState:$stateType -> react.Partial<$stateType>, ?callback:Void -> Void):Void
				#if !haxe4
				{ super.setState(nextState, callback); }
				#end
			;
		}).fields);
		#end
	}

	#end
}
