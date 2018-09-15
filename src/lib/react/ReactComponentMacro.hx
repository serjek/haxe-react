package react;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

typedef Builder = ClassType -> Array<Field> -> Array<Field>;

class ReactComponentMacro {
	static var builders:Array<Builder> = [
		react.ReactMacro.buildComponent,
		react.ReactTypeMacro.alterComponentSignatures,

		// Disable unneeded builders for completion
		#if !display
		react.jsx.JsxStaticMacro.disallowInReactComponent,
		#end

		react.wrap.ReactWrapperMacro.buildComponent,

		// Disable unneeded builders for completion
		#if !display
		#if !react_ignore_empty_render
		react.ReactTypeMacro.ensureRenderOverride,
		#end

		#if (debug && react_runtime_warnings)
		react.ReactDebugMacro.buildComponent,
		#end
		#end
	];

	static public function appendBuilder(builder:Builder):Void builders.push(builder);
	static public function prependBuilder(builder:Builder):Void builders.unshift(builder);

	static public function build():Array<Field>
	{
		var inClass = Context.getLocalClass().get();

		return Lambda.fold(
			builders,
			function(builder, fields) return builder(inClass, fields),
			Context.getBuildFields()
		);
	}
}
#end

