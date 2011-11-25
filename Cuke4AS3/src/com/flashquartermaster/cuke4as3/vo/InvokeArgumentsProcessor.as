/**
 * Copyright (c) 2011 FlashQuartermaster Ltd
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * @author Tom Coxen
 * @version
 **/
package com.flashquartermaster.cuke4as3.vo
{
	import com.furusystems.logging.slf4as.global.error;

	public class InvokeArgumentsProcessor
	{
		private var _args:Array;
		private var _srcDir:String;
		private var _mxmlc:String;
		private var _cucumber:String;
		private var _headless:String;
		private var _mxmlcArgs:String;
		private var _cucumberArgs:String;
		
		public function InvokeArgumentsProcessor()
		{
		}
		
		public function processArguments( args:Array ):Boolean
		{
			if( args == null || args.length == 0)
				return false;
			else
			{
				_args = args;
				return process();
			}
		}
		
		private function process():Boolean
		{
			//Valid args -srcDir -mxmlc -cucumber -headless -mxmlcArgs -cucumberArgs
			var lastArg:int = _args.length;
			var lastKey:String;
			
			try
			{
				for( var i:uint = 0; i < lastArg ; i++)
				{
					var keyValue:String = _args[i];
					if( keyValue.indexOf( "-" ) == 0 )//hyphen at the start of the string
					{
						var noHyphen:String = keyValue.substring(1);
						this[ noHyphen ];
						lastKey = noHyphen;
					}
					else
					{
						this[ lastKey ] = keyValue;
	//					argsObj[ lastKey ] = ( argsObj[ lastKey ] != null ? argsObj[ lastKey ] + "," + keyValue : keyValue );//For multiple args e.g. multiple srcDirs
					}
				}
				return true;
			}
			catch( e:ReferenceError )
			{
				//Found arg with no accessor or hyphen is missing
				error("InvokeArgumentsProcessor : process :",e);
			}
			return false;
		}
		
		public function get srcDir():String
		{
			return _srcDir;
		}

		public function set srcDir(value:String):void
		{
			_srcDir = value;
		}

		public function get mxmlc():String
		{
			return _mxmlc;
		}

		public function set mxmlc(value:String):void
		{
			_mxmlc = value;
		}

		public function get cucumber():String
		{
			return _cucumber;
		}

		public function set cucumber(value:String):void
		{
			_cucumber = value;
		}

		public function get headless():String
		{
			return _headless;
		}

		public function set headless(value:String):void
		{
			_headless = value;
		}

		public function get mxmlcArgs():String
		{
			return _mxmlcArgs;
		}

		public function set mxmlcArgs(value:String):void
		{
			_mxmlcArgs = value;
		}

		public function get cucumberArgs():String
		{
			return _cucumberArgs;
		}

		public function set cucumberArgs(value:String):void
		{
			_cucumberArgs = value;
		}
		
		public function destroy():void
		{
			_args = null;
			_srcDir= null;
			_mxmlc= null;
			_cucumber= null;
			_headless= null;
			_mxmlcArgs= null;
			_cucumberArgs= null;
		}
	}
}