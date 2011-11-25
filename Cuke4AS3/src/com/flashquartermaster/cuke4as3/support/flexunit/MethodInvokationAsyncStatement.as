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
package com.flashquartermaster.cuke4as3.support.flexunit
{
	import org.flexunit.internals.runners.statements.AsyncStatementBase;
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.token.AsyncTestToken;
	import org.flexunit.token.ChildResult;
	import org.flexunit.utils.ClassNameUtil;
	
	public class MethodInvokationAsyncStatement extends AsyncStatementBase implements IAsyncStatement
	{
		private var _method:Function;
		private var _args:Array;
		private var _stepsObject:*;
		
		public function evaluate( parentToken:AsyncTestToken ):void
		{
			var returnVal:Object;
			try {
				if ( _args.length > 0 ) {
					returnVal = _method.apply( _stepsObject, _args );
				} else {
					returnVal = _method.apply( _stepsObject );
				}
				parentToken.sendResult();
			} catch ( error:Error ) {
				parentToken.sendResult( error );
			}
		}

		public function set method(value:Function):void
		{
			_method = value;
		}

		public function set args(value:Array):void
		{
			_args = value;
		}

		public function set stepsObject(value:*):void
		{
			_stepsObject = value;
		}

		public function get method():Function
		{
			return _method;
		}

		public function get args():Array
		{
			return _args;
		}

		public function get stepsObject():*
		{
			return _stepsObject;
		}

		
		//based On
//		var meth:Method = new Method( methodToRun, false );
//		var fmethod:FrameworkMethod = new FrameworkMethod( meth );
//		var statement:IAsyncStatement = new InvokeMethod(fmethod, _stepsObject);
		
//		public function MethodInvokationAsyncStatement():void
//		{
//			myToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
//			myToken.addNotificationMethod( handleMethodExecuteComplete );
//		}
		
//		protected function handleMethodExecuteComplete( result:ChildResult ):void {
//			trace("MethodInvokationAsyncStatement : handleMethodExecuteComplete :", result.error);
//			parentToken.sendResult( null );
//		}
	}
}