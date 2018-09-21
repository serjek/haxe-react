package react.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class MacroUtil {
	static public function isEmpty(type:ComplexType):Bool
	{
		return switch (type) {
			case TPath({name: "Empty", sub: null, pack: ["react"], params: []}):
				true;

			default:
				false;
		};
	}

	static public function getField(fields:Array<Field>, name:String)
	{
		for (field in fields)
			if (field.name == name)
				return field;

		return null;
	}
}
