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

		var meta = inClass.meta.extract(ReactMeta.ContextMeta);
		for (i in 1...meta.length) {
			Context.warning(
				'You can only use one @${ReactMeta.ContextMeta} meta per'
				+ ' component; only the first one will apply.',
				meta[i].pos
			);
		}

		var first = meta[0];
		if (first.params.length != 1) {
			Context.error(
				'@${ReactMeta.ContextMeta} expects an argument: the instance of'
				+ ' the context provider',
				first.pos
			);
		}

		var contextProvider = first.params[0];
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
