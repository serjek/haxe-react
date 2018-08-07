package react;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;
#end

class ReactDebugMacro
{
	public static var firstRenderWarning:Bool = true;

	#if macro
	public static function buildComponent(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		var pos = Context.currentPos();
		var propsType:Null<ComplexType> = macro :Dynamic;
		var stateType:Null<ComplexType> = macro :Dynamic;

		switch (inClass.superClass)
		{
			case {params: params, t: _.toString() => "react.ReactComponentOf"}:
				propsType = TypeTools.toComplexType(params[0]);
				if (isEmpty(propsType)) propsType = null;

				stateType = TypeTools.toComplexType(params[1]);
				if (isEmpty(stateType)) stateType = null;

			default:
		}

		if (!updateComponentUpdate(fields, inClass, propsType, stateType))
			addComponentUpdate(fields, inClass, propsType, stateType);

		return fields;
	}

	static function isEmpty(type:ComplexType):Bool
	{
		return switch (type) {
			case TPath({name: "Empty", sub: null, pack: ["react"], params: []}):
				true;

			default:
				false;
		};
	}

	static function updateComponentUpdate(
		fields:Array<Field>,
		inClass:ClassType,
		propsType:Null<ComplexType>,
		stateType:Null<ComplexType>
	) {
		for (field in fields)
		{
			if (field.name == "componentDidUpdate")
			{
				switch (field.kind) {
					case FFun(f):
						if (f.args.length != 2)
							return Context.error('componentDidUpdate should accept two arguments', inClass.pos);

						var expr = exprComponentDidUpdate(
							inClass,
							f.args[0].name,
							f.args[1].name,
							propsType != null,
							stateType != null
						);

						f.expr = macro {
							${expr}
							${f.expr}
						};

						return true;
					default:
				}
			}
		}

		return false;
	}

	static function addComponentUpdate(
		fields:Array<Field>,
		inClass:ClassType,
		propsType:Null<ComplexType>,
		stateType:Null<ComplexType>
	) {
		var expr = exprComponentDidUpdate(
			inClass,
			"prevProps",
			"prevState",
			propsType != null,
			stateType != null
		);

		var componentDidUpdate = {
			args: [
				{
					meta: [],
					name: "prevProps",
					type: propsType == null ? macro :react.Empty : propsType,
					opt: false,
					value: null
				},
				{
					meta: [],
					name: "prevState",
					type: stateType == null ? macro :react.Empty : stateType,
					opt: false,
					value: null
				}
			],
			ret: macro :Void,
			expr: expr
		}

		fields.push({
			name: 'componentDidUpdate',
			access: [APublic, AOverride],
			kind: FFun(componentDidUpdate),
			pos: inClass.pos
		});
	}

	static function exprComponentDidUpdate(
		inClass:ClassType,
		prevProps:String,
		prevState:String,
		hasProps:Bool,
		hasState:Bool
	) {
		if (!hasProps && !hasState) return macro {};

		return macro {
			${hasProps
				? macro var propsAreEqual = react.ReactUtil.shallowCompare(this.props, $i{prevProps})
				: macro {}
			};

			${hasState
				? macro var statesAreEqual = react.ReactUtil.shallowCompare(this.state, $i{prevState})
				: macro {}
			};

			var cond = ${!hasProps
				? macro statesAreEqual
				: !hasState
					? macro propsAreEqual
					: macro (propsAreEqual && statesAreEqual)
			};

			if (cond)
			{
				${hasProps ? macro {
					// Using Object.create(null) to avoid prototype for clean output
					var debugProps = untyped Object.create(null);
					debugProps.currentProps = this.props;
					debugProps.prevProps = $i{prevProps};

					js.Browser.console.warn(
						'Warning: avoidable re-render of `${$v{inClass.name}}`.\n',
						debugProps
					);
				} : macro {
					js.Browser.console.warn(
						'Warning: avoidable re-render of `${$v{inClass.name}}`.'
					);
				}};

				if (react.ReactDebugMacro.firstRenderWarning)
				{
					react.ReactDebugMacro.firstRenderWarning = false;

					js.Browser.console.warn(
						'Make sure your props are flattened, or implement shouldComponentUpdate.\n' +
						'See https://facebook.github.io/react/docs/optimizing-performance.html#shouldcomponentupdate-in-action'
					);
				}
			}
		}
	}
	#end
}
