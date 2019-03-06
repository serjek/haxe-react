package react.macro;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import react.jsx.JsxStaticMacro;
import react.macro.ReactComponentMacro.ACCEPTS_MORE_PROPS_META;

class ReactWrapperMacro
{
	static public inline var WRAP_BUILDER = 'Wrap';
	static public inline var WRAP_META = ':wrap';
	static public inline var PUBLIC_PROPS_META = ':publicProps';
	static public inline var NO_PUBLIC_PROPS_META = ':noPublicProps';
	static inline var WRAPPED_META = ':wrapped_by_macro';

	static public function buildComponent(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		if (inClass.meta.has(WRAPPED_META)) return fields;
		if (!inClass.meta.has(WRAP_META)) return fields;

		if (inClass.meta.has(JsxStaticMacro.META_NAME))
			Context.fatalError(
				'Cannot use @${WRAP_META} and @${JsxStaticMacro.META_NAME} on the same component',
				inClass.pos
			);

		var wrapperExpr = null;
		var wrappersMeta = inClass.meta.extract(WRAP_META);
		wrappersMeta.reverse();

		var publicProps = extractPublicProps(inClass.meta, wrappersMeta[0].pos);
		if (publicProps != null && inClass.meta.has(ACCEPTS_MORE_PROPS_META)) {
			publicProps = macro :react.ReactComponent.ACCEPTS_MORE_PROPS<$publicProps>;
		}

		var fieldType = publicProps == null
			? null
			: macro :$publicProps->react.ReactComponent.ReactFragment;

		Lambda.iter(wrappersMeta, function(m) {
			if (m.params.length == 0)
				Context.fatalError(
					'Invalid number of parameters for @${WRAP_META}; '
					+ 'expected 1 parameter (hoc expression).',
					m.pos
				);

			var e = m.params[0];
			wrapperExpr = wrapperExpr == null
				? macro @:pos(e.pos) ${e}($i{inClass.name})
				: macro @:pos(e.pos) ${e}(${wrapperExpr});
		});

		var fieldName = '_renderWrapper';
		fields.push({
			access: [APublic, AStatic],
			name: fieldName,
			kind: FVar(fieldType, macro cast (${wrapperExpr} :react.ReactType)),
			doc: null,
			meta: null,
			pos: inClass.pos
		});

		inClass.meta.add(JsxStaticMacro.META_NAME, [macro $v{fieldName}], inClass.pos);
		inClass.meta.add(WRAPPED_META, [], inClass.pos);

		return fields;
	}

	static function extractPublicProps(meta:MetaAccess, wrapPos:Position):Null<ComplexType>
	{
		if (meta.has(PUBLIC_PROPS_META))
		{
			var publicProps = meta.extract(PUBLIC_PROPS_META)[0];
			if (publicProps.params.length == 0)
				Context.fatalError(
					'Invalid number of parameters for @${PUBLIC_PROPS_META}; '
					+ 'expected 1 parameter (props type identifier).',
					publicProps.pos
				);

			var e = publicProps.params[0];
			var tprops = Context.getType(switch (e.expr) {
				case EConst(CString(str)), EConst(CIdent(str)): str;
				case EField(_, _): ExprTools.toString(e);

				default:
					Context.error(
						'@${PUBLIC_PROPS_META}: unsupported argument; '
						+ 'expected a type identifier.',
						publicProps.pos
					);
			});

			return TypeTools.toComplexType(tprops);
		}

		if (meta.has(NO_PUBLIC_PROPS_META)) return macro :{};

		#if react_wrap_strict
		Context.warning(
			'@${WRAP_META}: missing @${PUBLIC_PROPS_META} meta required by '
			+ 'strict mode (`-D react_wrap_strict`).',
			wrapPos
		);
		#end

		return null;
	}
}

