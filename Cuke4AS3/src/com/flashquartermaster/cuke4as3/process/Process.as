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
package com.flashquartermaster.cuke4as3.process
{
	import com.flashquartermaster.cuke4as3.Config;
	import com.flashquartermaster.cuke4as3.util.StringUtilities;
	import com.furusystems.logging.slf4as.global.debug;
	import com.furusystems.logging.slf4as.global.error;
	import com.furusystems.logging.slf4as.global.info;
	import com.furusystems.logging.slf4as.global.warn;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TextEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	public class Process extends EventDispatcher implements IProcess
	{
		public static const SHELL_DATA_EVENT:String = "shellData";
		public static const SHELL_ERROR_EVENT:String = "shellError";
		public static const PROCESS_ERROR_EVENT:String = "proccessErrorEvent";
		
		protected var _processArgs:Vector.<String>;
		protected var _additionalArgs:String;
		protected var _executable:File;
		
		protected var _nativeProcess:NativeProcess;
		
		protected var _srcDir:String;
		
		public function Process( target:IEventDispatcher=null )
		{
			super(target);
		}
		
		public function init():void
		{
			_nativeProcess = new NativeProcess();
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		}
		
		public function run():void
		{
			try
			{
				validate();
				
				constructCompilerArgs();
				
				var startUpInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			
				startUpInfo.executable = _executable;
				startUpInfo.arguments = _processArgs;
				
				_nativeProcess.start(startUpInfo);
			}
			catch( e:Error )
			{
				error( "Process : run",e,e.message,e.getStackTrace());
				dispatchEvent( new ErrorEvent( Process.PROCESS_ERROR_EVENT,false, false,e.message,Config.VALIDATION_ERROR) );
			}
		}
		
		protected function validate():void
		{
			validateFilePath( srcDir, "srcDir" );
		}
		
		protected function constructCompilerArgs():void
		{
			_processArgs = new Vector.<String>();
			
			if( additionalArgs != null )
			{
				var result:Array = StringUtilities.stripWhiteSpaceExceptWhereEnclosedBySingleQuotes( additionalArgs );
				
				var lastArg:uint = result.length;
				
				for( var i:uint = 0; i < lastArg; i++)
				{
					var s:String = result[i];
					if( StringUtilities.testStripSingleQuotesAtStartAndEndOfString( s ) )
					{
						_processArgs.push( StringUtilities.stripSingleQuotesAtStartAndEndOfString( s ) );
					}
					else
					{
						_processArgs.push( s );
					}
				}
			}

		}
		
		protected function shellData( event:ProgressEvent ):void 
		{
			var output:IDataInput  = NativeProcess( event.target ).standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			dispatchEvent( new TextEvent(SHELL_DATA_EVENT, false, false, data ) );
			
			debug("Process : shellData :\n", data );
		}
		
		protected function shellExit( event:NativeProcessExitEvent ):void
		{
			info("Process : shellExit : event :", event);
			var exitCode:Number = event.exitCode;
			if( !isNaN( exitCode ) )//Not forced exit
			{
				switch( exitCode )
				{
					case 0:
						dispatchEvent( new Event( Event.COMPLETE ) );
						break;
					case 1:
						dispatchEvent( new ErrorEvent( PROCESS_ERROR_EVENT,false,false,"Process exited with errors, exitCode: 1", Config.SHELL_EXIT_WITH_ERRORS) );
						break;
					default:
						dispatchEvent( new ErrorEvent( PROCESS_ERROR_EVENT,false,false,"Exited with unknown Exit code, exitCode: " + exitCode, Config.SHELL_EXIT_UNKNOWN_EXIT_CODE) );
						break;
				}
			}
			else
			{
				warn( "Process : shellExit : Forced Exit from Native Process" )
				
				dispatchEvent( new ErrorEvent( PROCESS_ERROR_EVENT, false, false, "Process forced exit", Config.FORCED_SHELL_EXIT ) );
			}
		}
		
		protected function shellError( event:ProgressEvent ):void {
			var output:IDataInput = NativeProcess( event.target ).standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			warn("Process : shellError :\n", data );
			
			dispatchEvent( new TextEvent(SHELL_ERROR_EVENT, false, false, data ) );
		}

		public function stop():void
		{
			if( running )
			{
				_nativeProcess.exit( true );
			}
		}
		
		public function destroy():void
		{	
			info("Process : destroy");
			
			if( _nativeProcess != null )
			{
				stop();
				
				_nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			}
			
			_processArgs = null;
			_additionalArgs = null;
			_executable = null;
			
			_nativeProcess = null;
		}
		
		protected function validateFilePath( path:String, debugName:String ):File
		{
			if( !StringUtilities.isNotNullAndNotEmptyString( path ) )
				throw new Error("path to "+debugName+" must be set");
			
			var file:File = new File();
			file = file.resolvePath( path );
			
			if( !file.exists )
				throw new Error("Path to "+debugName+" \"" + file.nativePath + "\" does not exist" );
			
			return file;
		}
		
		//Accessors
		
		public function get srcDir():String
		{
			return _srcDir;
		}
		
		public function set srcDir(value:String):void
		{
			_srcDir = value;
		}
		
		public function get running():Boolean
		{
			return _nativeProcess != null ? _nativeProcess.running : false;
		}
		
		public function get additionalArgs():String
		{
			return _additionalArgs;
		}
		
		public function set additionalArgs(value:String):void
		{
			_additionalArgs = value;
		}
	}
}