package react.jsx;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;

#if (haxe_ver < 4)
private typedef ObjectField = {field:String, expr:Expr};
#end

class JsxPropsBuilder
{

	static public function makeProps(spread:Array<Expr>, attrs:Array<ObjectField>, pos:Position)
	{
		#if (!debug && !react_no_inline)
		flattenSpreadProps(spread, attrs);
		#end

		return spread.length > 0
			? makeSpread(spread, attrs, pos)
			: attrs.length == 0 ? macro {} : {pos:pos, expr:EObjectDecl(attrs)}
	}

	/**
	 * Attempt flattening spread/default props into the user-defined props
	 */
	static function flattenSpreadProps(spread:Array<Expr>, attrs:Array<ObjectField>)
	{
		function hasAttr(name:String) {
			for (prop in attrs) if (prop.field == name) return true;
			return false;
		}
		var mergeProps = getSpreadProps(spread, []);
		if (mergeProps.length > 0)
		{
			for (prop in mergeProps)
				if (!hasAttr(prop.field)) attrs.push(prop);
		}
	}

	static function makeSpread(spread:Array<Expr>, attrs:Array<ObjectField>, pos:Position)
	{
		// single spread, no props
		if (spread.length == 1 && attrs.length == 0)
			return spread[0];

		// combine using Object.assign
		var args = [macro {}].concat(spread);
		if (attrs.length > 0) args.push({pos:pos, expr:EObjectDecl(attrs)});
		return macro (untyped Object).assign($a{args});
	}

	/**
	 * Flatten literal objects into the props
	 */
	static function getSpreadProps(spread:Array<Expr>, props:Array<ObjectField>)
	{
		if (spread.length == 0) return props;
		var last = spread[spread.length - 1];
		return switch (last.expr) {
			case ECheckType({expr: EObjectDecl(fields)}, ct):
				spread.pop();
				var newProps = props.concat(fields.map(function(f) {
					var fname = f.field;
					var fct = TypeTools.toComplexType(
						Context.typeof(
							macro @:pos(f.expr.pos) (null :$ct).$fname
						)
					);

					return {
						expr: {expr: ECheckType(f.expr, fct), pos: f.expr.pos},
						field: fname,
						#if (haxe_ver >= 4) quotes: f.quotes #end
					}
				}));
				// push props and recurse in case another literal object is in the list
				getSpreadProps(spread, newProps);

			case EObjectDecl(fields):
				spread.pop();
				var newProps = props.concat(fields);
				// push props and recurse in case another literal object is in the list
				getSpreadProps(spread, newProps);
			default:
				props;
		}
	}
}
#end
