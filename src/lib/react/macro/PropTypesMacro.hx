package react.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class PropTypesMacro {
	static function addBuilder() react.macro.ReactComponentMacro.appendBuilder(buildComponent);

	static function buildComponent(inClass:ClassType, fields:Array<Field>):Array<Field> {
		// trace(inClass);
		// trace(Context.getLocalType());
		// trace(Context.getLocalModule());
		// trace(Context.getLocalTVars());

		// Abort if prop types are already defined
		for (f in fields) if (f.name == "propTypes")
			return fields;

		switch (inClass.superClass) {
			case {t: t, params: [tprops, tstate]}:
				// var t = TypeTools.applyTypeParameters(tprops, inClass.params);
				switch (tprops) {
					case TInst(t, params):
						// trace(t.get());

					case TType(t, params):
						switch (t.get().type) {
							case TAnonymous(t):
								// trace(t.get().fields);
								for (f in t.get().fields) {
									// trace(f.name, f.type, f.meta.get());
								}

							default:
						}

					default:
				}

			default:
		}

		return fields;
	}

	static function buildPropTypes() {
		// TODO
	}
}
