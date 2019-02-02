package react.macro;

import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class ReactTypeMacro
{
	static public inline var ALTER_SIGNATURES_BUILDER = 'AlterSignatures';
	static public inline var ENSURE_RENDER_OVERRIDE_BUILDER = 'EnsureRenderOverride';
	static public inline var CHECK_GET_DERIVED_STATE_BUILDER = 'CheckDerivedState';
	static public inline var IGNORE_EMPTY_RENDER_META = ':ignoreEmptyRender';

	#if macro
	public static function alterComponentSignatures(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		if (inClass.isExtern) return fields;

		var types = MacroUtil.extractComponentTypes(inClass);
		var tprops = types.tprops == null ? macro :Dynamic : types.tprops;
		var tstate = types.tstate == null ? macro :Dynamic : types.tstate;

		// Only alter setState signature for non-dynamic states
		switch (ComplexTypeTools.toType(tstate))
		{
			case TType(_) if (!hasSetState(fields)):
				addSetStateType(fields, inClass, tprops, tstate);

			default:
		}

		return fields;
	}

	public static function ensureRenderOverride(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		if (!(inClass.isExtern || inClass.meta.has(IGNORE_EMPTY_RENDER_META)))
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
			if (field.name == 'setState')
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
	) {
		var partialStateType = switch (ComplexTypeTools.toType(stateType)) {
			case TType(_):
				TPath({
					name: 'Partial',
					pack: ['react'],
					params: [TPType(stateType)]
				});

			default:
				macro :Dynamic;
		};

		var setStateArgs:Array<FunctionArg> = [
			{
				name: 'nextState',
				// TState -> Partial<TState>
				type: TFunction([stateType], partialStateType),
				opt: false
			},
			{
				name: 'callback',
				type: macro :Void->Void,
				opt: true
			}
		];

		fields.push({
			name: 'setState',
			access: [APublic, AOverride],
			meta: [
				{
					// Add @:extern meta so that this code only exist at compile time
					name: ':extern',
					params: null,
					pos: Context.currentPos()
				},
				{
					// First overload:
					// function(nextState:TState -> TProps -> Partial<TState>, ?callback:Void -> Void):Void {}
					name: ':overload',
					params: [generateSetStateOverload(
						TFunction([stateType, propsType], partialStateType)
					)],
					pos: Context.currentPos()
				},
				{
					// Second overload:
					// function(nextState:Partial<TState>, ?callback:Void -> Void):Void {}
					name: ':overload',
					params: [generateSetStateOverload(partialStateType)],
					pos: Context.currentPos()
				}
			],
			kind: FFun({
				args: setStateArgs,
				ret: macro :Void,
				#if haxe4
				expr: null
				#else
				expr: macro { super.setState(nextState, callback); }
				#end
			}),
			pos: inClass.pos
		});
	}

	static function generateSetStateOverload(nextStateType:ComplexType) {
		return {
			expr: EFunction(null, {
				args: [
					{
						name: 'nextState',
						type: nextStateType,
						opt: false
					},
					{
						name: 'callback',
						type: macro :Void->Void,
						opt: true
					}
				],
				expr: macro {},
				params: null,
				ret: macro :Void
			}),
			pos: Context.currentPos()
		};
	}
	#end
}
