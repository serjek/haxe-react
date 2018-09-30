package react.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

using haxe.macro.Tools;

class MacroUtil {
	static public function isEmpty(type:ComplexType):Bool
	{
		return switch (type) {
			case TPath({name: "Dynamic", sub: null, pack: [], params: []}):
				true;

			case TPath({name: "Empty", sub: null, pack: ["react"], params: []}):
				true;

			default:
				false;
		};
	}

	static public function tryFollow(t:Type):Type
	{
		var t1 = t.follow();

		return try {
			var ct = TypeTools.toComplexType(t1);
			Context.typeExpr(macro (null :$ct));
			t1;
		} catch (e:Dynamic) {
			null;
		};
	}

	static public function tryMapFollow(t:Type):Type
	{
		var t1 = t.map(function(t) return t.follow());

		return try {
			var ct = TypeTools.toComplexType(t1);
			Context.typeExpr(macro (null :$ct));
			t1;
		} catch (e:Dynamic) {
			null;
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
