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
	import com.flashquartermaster.cuke4as3.util.deepTrace;
	import com.furusystems.logging.slf4as.global.debug;
	import com.furusystems.logging.slf4as.global.info;
	import com.furusystems.logging.slf4as.global.warn;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TextEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;

	public class CompilerProcess extends Process
	{
		private var _mxmlcPath:String;
		private var _step_definitionsDirectoryListing:Array;
		
		private var _isUseBundledFlexUnit:Boolean = true;
		private var _isUseBundledDConsole:Boolean = true;
		
		public function CompilerProcess()
		{
			super();
		}
		
		override protected function validate():void
		{
			super.validate();
			
			var mxmlc:File = validateFilePath( _mxmlcPath, "mxmlc" );
			
			_executable = mxmlc;
			
			//stepsDirectory resolves to your src directory plus "features/step_definitions/"
			var stepsDir:String = _srcDir + File.separator + Config.STEP_DEFINITIONS_DIR;
			var stepsDirectory:File = validateFilePath( stepsDir, "steps_directory" );
			
			_step_definitionsDirectoryListing = stepsDirectory.getDirectoryListing();
		}
		
		override protected function constructCompilerArgs():void
		{
			super.constructCompilerArgs();
			
			_processArgs.push( "-keep-as3-metadata+=Given,When,Then" );
			_processArgs.push( "-omit-trace-statements=false" );//Allows our *_Steps.as to trace to console
			_processArgs.push( "-static-link-runtime-shared-libraries" );
			
//			compiler.include-libraries alias -include-libraries
//			a list of libraries (SWCs) to completely include in the SWF (repeatable)
//			_processArgs.push( "-compiler.include-libraries" );
			
//			compiler.external-library-path alias -el 
//			list of SWC files or directories to compile against but to omit from linking (repeatable)
//			_processArgs.push( "-compiler.external-library-path" );
			
//			-compiler.library-path alias -l
//			list of SWC files or directories that contain SWC files (repeatable)
			
			//Use Cuke4AS3Lib and other default bundled libs
			_processArgs.push( "-compiler.library-path" );
			_processArgs.push( File.applicationDirectory.resolvePath( "bundled_libs"+ File.separator ).nativePath );
			
			if( isUseBundledFlexUnit )
			{
				_processArgs.push( "-compiler.library-path" );
				
				//Flexunit bundle includes hamcrest-as3-flex-1.1.3.swc, lexunit_0.9.swc, flexunit-4.1.0-8-as3_4.1.0.16076.swc
				//And should be included in the installer
				debug( "CompilerProcess : constructCompilerArgs : bundled flexunit :",File.applicationDirectory.resolvePath( "bundled_libs"+ File.separator +"flexunit" + File.separator ).nativePath);
				
				_processArgs.push( File.applicationDirectory.resolvePath( "bundled_libs"+ File.separator +"flexunit"+ File.separator ).nativePath );
			}
			
			if( isUseBundledDConsole )
			{
				_processArgs.push( "-compiler.library-path" );
				
				//should be included in the installer
				debug( "CompilerProcess : constructCompilerArgs : bundled dconsole :",File.applicationDirectory.resolvePath( "bundled_libs/dconsole/" ).nativePath);
				
				_processArgs.push( File.applicationDirectory.resolvePath( "bundled_libs"+ File.separator +"dconsole" + File.separator ).nativePath );
			}
			
			_processArgs.push( "-compiler.verbose-stacktraces" );
			
//			-output <filename> alias -o
//			the filename of the SWF movie to create
			_processArgs.push( "-output" );
			_processArgs.push( _srcDir + File.separator + Config.OUTPUT_SWF );
			
//			-compiler.source-path [path-element] [...] 
//			alias -sp list of path elements that form the roots of ActionScript class hierarchies (repeatable)
			_processArgs.push( "-compiler.source-path" );//-sp
			_processArgs.push( _srcDir );
			
//			_processArgs.push( "-define=CONFIG::useFlexClasses,false" );
			
//			-file-specs a list of source files to compile, the last file specified will be
//			used as the target application (repeatable, default variable)
			_processArgs.push( "-file-specs" );
			_processArgs.push( _srcDir + File.separator + Config.STEP_DEFINITIONS_DIR + Config.SUITE_NAME );
			
//			for (var i:uint = 0; i < _directoryListing.length; i++) {
////				trace("CompilerProcess : constructCompilerArgs : Steps dir:", ( directoryListing[i] as File ).nativePath );
//				_processArgs.push( ( _directoryListing[i] as File ).nativePath );
//			}
			
//			_processArgs.push( "--target-player=10.2.0" );
			
//			_processArgs.push( "-dump-config" );
//			_processArgs.push( _srcDir + File.separator + Config.COMPILER_CONFIG );
			
			deepTrace("CompilerProcess : args :", _processArgs, 1 );
		}
		
		override protected function shellExit( event:NativeProcessExitEvent ):void
		{
			var exitCode:Number = event.exitCode;
			
			if( exitCode == 0 )
			{
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
			else if( exitCode > 0 )//Compiler exits the shell with the number of compile errors
			{
				dispatchEvent( new ErrorEvent( PROCESS_ERROR_EVENT, false, false, "Shell Exited with \"" + exitCode + "\" errors", Config.COMPILER_ERRORS ) );
			}
			else if( isNaN( exitCode ) )
			{
				warn( "CompilerProcess : shellExit : Forced Exit from native process" );
				dispatchEvent( new ErrorEvent( PROCESS_ERROR_EVENT, false, false, "Process forced exit", Config.FORCED_SHELL_EXIT ) );
			}
			else
			{
				dispatchEvent( new ErrorEvent( PROCESS_ERROR_EVENT,false,false,"Exited with unknown Exit code, exitCode: " + exitCode, Config.SHELL_EXIT_UNKNOWN_EXIT_CODE) );
			}
		}
		
		override public function destroy():void
		{
			info("CompilerProcess : destroy");
			super.destroy();
			
			_mxmlcPath = null;
			_step_definitionsDirectoryListing = null;
		}
		
		//Accessors
		
		public function get step_definitionsDirectoryListing():Array
		{
			return _step_definitionsDirectoryListing;
		}

		public function get mxmlcPath():String
		{
			return _mxmlcPath;
		}

		public function set mxmlcPath(value:String):void
		{
			_mxmlcPath = value;
		}

		public function get isUseBundledFlexUnit():Boolean
		{
			return _isUseBundledFlexUnit;
		}

		public function set isUseBundledFlexUnit(value:Boolean):void
		{
			_isUseBundledFlexUnit = value;
		}

		public function get isUseBundledDConsole():Boolean
		{
			return _isUseBundledDConsole;
		}

		public function set isUseBundledDConsole(value:Boolean):void
		{
			_isUseBundledDConsole = value;
		}
	}
}