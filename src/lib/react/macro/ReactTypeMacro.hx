package react.macro;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;

@:dce
class ReactTypeMacro
{
	static public inline var ALTER_SIGNATURES_BUILDER = 'AlterSignatures';
	static public inline var ENSURE_RENDER_OVERRIDE_BUILDER = 'EnsureRenderOverride';
	static public inline var CHECK_GET_DERIVED_STATE_BUILDER = 'CheckDerivedState';
	static public inline var FIX_ES6_CONSTRUCTOR_BUILDER = 'FixES6Constructor';
	@:deprecated static public inline var IGNORE_EMPTY_RENDER_META = ReactMeta.IgnoreEmptyRender;

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

	public static function fixEs6Constructor(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		var initFields = [for (f in fields) {
			if (Lambda.has(f.access, AInline)) continue;

			switch (f.kind) {
				case FVar(t, e) if (e != null):
					if (t == null) t = TypeTools.toComplexType(Context.typeof(e));
					f.kind = FVar(t, null);
					{name: f.name, expr: e};

				case FProp(g, s, t, e) if (e != null):
					if (t == null) t = TypeTools.toComplexType(Context.typeof(e));
					f.kind = FProp(g, s, t, null);
					{name: f.name, expr: e};

				default: continue;
			}
		}];

		if (initFields.length == 0) return fields;

		var ctor = MacroUtil.getField(fields, "new");
		if (ctor == null) {
			fields.push((macro class {
				public function new(props) {
					super(props);

					@:mergeBlock $b{
						initFields.map(f -> macro $i{f.name} = $e{f.expr})
					}
				}
			}).fields[0]);
		} else {
			switch (ctor.kind) {
				case FFun(fun):
					var fieldsInitAdded = false;
					function map(e:Expr):Expr {
						return switch (e.expr) {
							case ECall({expr: EConst(CIdent("super"))}, params):
								fieldsInitAdded = true;
								macro @:mergeBlock {
									$e{e};

									@:mergeBlock $b{
										initFields.map(f -> macro $i{f.name} = $e{f.expr})
									}
								};

							case EBlock(exprs): macro $b{exprs.map(map)};
							default: e;
						}
					}

					fun.expr = ExprTools.map(fun.expr, map);

					// TODO: Do something if super call not found?
					if (!fieldsInitAdded)
						trace('Failed to find super call for ${inClass.name}');

				default:
					// Let haxe compiler break for invalid ctor
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
		fields.push((macro class C {
			@:extern
			@:overload(function(nextState:$stateType -> react.Partial<$stateType>, ?callback:Void -> Void):Void {})
			@:overload(function(nextState:$stateType -> $propsType -> react.Partial<$stateType>, ?callback:Void -> Void):Void {})
			override public function setState(nextState: react.Partial<$stateType>, ?callback:Void -> Void): Void
				#if haxe4
				// explictly omit function body
				// newer haxe 4 builds (preview 5 and up) don't require a function body – however haxe4 flag is not set until rc1
				#else
				{ super.setState(nextState, callback); }
				#end
			;
		}).fields[0]);
	}

	#end
}
