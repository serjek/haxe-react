package react;

#if macro
import haxe.macro.Context.*;
import haxe.macro.Expr;
using tink.MacroApi;
#end

@:forward
abstract Partial<T>(T) {
	@:from static macro function ofAny(e:Expr) {
		var expected = getExpectedType();

		var ret = switch followWithAbstracts(expected) {
			case TDynamic(_): e;
			case TAnonymous(_.get().fields => fields):
				var t = TAnonymous([
					for (f in fields) {
						name: f.name,
						pos: e.pos,
						kind: FProp('default', 'never', f.type.toComplex()),
						meta: [{ name: ':optional', params: [], pos: e.pos }]
					}
				]); //TODO: consider caching these

				macro @:pos(e.pos) ($e:$t);
			case v:
				fatalError('Cannot have partial $v', currentPos());
		}

		var et = expected.toComplex();
		return macro @:pos(e.pos) (cast $ret:$et);
	}
}
