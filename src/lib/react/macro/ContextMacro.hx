package react.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class ContextMacro {
	public static inline var REACT_CONTEXT_BUILDER = 'ReactContext';

	public static function buildComponent(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		if (inClass.isExtern) return fields;
		if (!inClass.meta.has(ReactMeta.ContextMeta)) return fields;

		var meta = inClass.meta.extract(ReactMeta.ContextMeta)[0];
		if (meta.params.length != 1) {
			Context.error(
				'@${ReactMeta.ContextMeta} expects an argument: the instance of'
				+ 'the context provider',
				meta.pos
			);
		}

		var contextProvider = meta.params[0];
		var ctContext = switch (Context.typeof(contextProvider)) {
			case TAbstract(_.toString() => "react.ReactContext", [t]):
				TypeTools.toComplexType(t);

			case _:
				Context.error(
					'Context provider should be of type react.ReactContext<T>',
					contextProvider.pos
				);
		};

		return fields.concat((macro class {
			@:keep static var contextType = $contextProvider;
			var context:$ctContext;
		}).fields);
	}
}
