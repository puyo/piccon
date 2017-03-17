package {
	import flash.external.ExternalInterface;

	public class Log {

		//================================================================== 
		// CONSTANTS

		public static const LEVEL_NONE:Number = 0;
		public static const LEVEL_ERROR:Number = 10;
		public static const LEVEL_WARN:Number = 20;
		public static const LEVEL_INFO:Number = 30;
		public static const LEVEL_DEBUG:Number = 40;

		public static const LEVELS:Object = {
			'NONE': LEVEL_NONE,
			'ERROR': LEVEL_ERROR,
			'WARN': LEVEL_WARN,
			'INFO': LEVEL_INFO,
			'DEBUG': LEVEL_DEBUG
		};
		
		//================================================================== 
		// PUBLIC METHODS

		public static function get level():Number{
			return _level;
		}

		public static function set level(value:*):void{
			if(value is Number){
				_level = value;
			}else if (value is String){
				_level = LEVELS[value];
			}
		}

		public static function debugMode():Boolean{
			return _level == LEVEL_DEBUG;
		}

		private static function call(cmd:String, args:Array):Object{
			try{
				return ExternalInterface.call.apply(ExternalInterface, [cmd].concat(args));
			}catch(e:Error){
				// May not be running in a web browser. That's okay.
			}
			return null;
		}

		public static function object2String(obj:Object, indent:String = ""):String{
			var result:String;
			if(obj is String){
				result = '"' + obj + '"';
			}else if(obj is Number || obj is uint || obj is int || obj is Boolean){
				result = String(obj);
			}else if(obj is Array){
				result = "[";
				for(var i:uint = 0; i < obj.length; i++){
					result += "\n" + indent + i + ": " + object2String(obj[i], indent + "  ") + ",\n";
				}
				result += indent + "]";
			}else if(obj is Object){
				result = "{";
				for(var key:String in obj){
					result += "\n" + indent + key + ": " + object2String(obj[key], indent + "  ") + ",\n";
				}
				result += indent + "}";
			}
			return result;
		}

		private static function log(tracePrefix:String, firebugFunc:String, requiredLevel:Number, args:Array):void{
			if(_level >= requiredLevel){
				if(args[0] is Function && args.length == 1){
					args = args[0].call() as Array;
				}
				trace.apply(null, [tracePrefix].concat(args));
				call(firebugFunc, args);
			}
		}

		public static function logStackTrace(...rest):void{
			debug(function():Array{
				try{ 
					throw new Error("STACK TRACE");
				}catch(e:Error){ 
					return rest.concat([e.getStackTrace()]);
				}
				return []; // avoids a compiler error re. no return value
			});
		}

		public static function debug(...rest):void{
			log("[DEBUG]", "console.debug", LEVEL_DEBUG, rest);
		}

		public static function info(...rest):void{
			log(" [INFO]", "console.info", LEVEL_INFO, rest);
		}

		public static function warn(...rest):void{
			log(" [WARN]", "console.warn", LEVEL_WARN, rest);
		}

		public static function error(...rest):void{
			log("[ERROR]", "console.error", LEVEL_ERROR, rest);
		}

		public static function assert(expression:Boolean, ...rest):void{
			call("console.assert", [expression].concat(rest));
		}

		public static function dir(object:Object):void{
			call("console.dir", [object]);
		}

		public static function group(...rest):void{
			call("console.group", rest);
		}

		public static function groupEnd():void{
			call("console.groupEnd", []);
		}

		public static function time(name:String):void{
			call("console.time", [name]);
		}

		public static function timeEnd(name:String):void{
			call("console.timeEnd", [name]);
		}

		public static function profile(title:String):void{
			call("console.profile", [title]);
		}

		public static function profileEnd():void{
			call("console.profileEnd", []);
		}

		public static function count(name:String = null):void{
			call("console.count", name ? [name] : []);
		}

		//================================================================== 
		// PRIVATE PROPERTIES

		private static var _level:uint = LEVEL_INFO;
	}
}
