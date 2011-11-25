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
package
com.flashquartermaster.cuke4as3{
    import com.flashquartermaster.cuke4as3.*;
    import com.flashquartermaster.cuke4as3.Config;
    import com.flashquartermaster.cuke4as3.filesystem.WireFileParser;
    import com.flashquartermaster.cuke4as3.net.BinarySwfLoader;
    import com.flashquartermaster.cuke4as3.net.CommandProcessor;
    import com.flashquartermaster.cuke4as3.net.Cuke4AS3Server;
    import com.flashquartermaster.cuke4as3.process.CompilerProcess;
    import com.flashquartermaster.cuke4as3.process.CucumberProcess;
    import com.flashquartermaster.cuke4as3.process.Process;
    import com.flashquartermaster.cuke4as3.reflection.IStepInvoker;
    import com.flashquartermaster.cuke4as3.reflection.IStepMatcher;
    import com.flashquartermaster.cuke4as3.reflection.StepInvoker;
    import com.flashquartermaster.cuke4as3.reflection.StepMatcher;
    import com.flashquartermaster.cuke4as3.reflection.SwfProcessor;
    import com.flashquartermaster.cuke4as3.util.StringUtilities;
    import com.flashquartermaster.cuke4as3.vo.InvokeArgumentsProcessor;
    import com.flashquartermaster.cuke4as3.vo.ServerInfo;
    import com.furusystems.logging.slf4as.global.*;

    import flash.desktop.NativeApplication;
    import flash.desktop.NativeProcess;
    import flash.display.Sprite;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.InvokeEvent;
    import flash.events.SecurityErrorEvent;
    import flash.filesystem.File;
    import flash.system.ApplicationDomain;
    import flash.system.System;

    import org.fluint.uiImpersonation.IVisualEnvironmentBuilder;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.fluint.uiImpersonation.VisualTestEnvironmentBuilder;

    public class Cuke4AS3 extends Sprite
	{
		//Native processes
		private var _compilerProcess:CompilerProcess;
		private var _cucumberProcess:CucumberProcess;
		
		//Net
		private var _binarySwfLoader:BinarySwfLoader;
		private var _cuke4AS3Server:Cuke4AS3Server;
		
		//Reflection
		private var _swfProcessor:SwfProcessor;
		private var _stepInvoker:IStepInvoker;
		private var _stepMatcher:IStepMatcher;
		
		//Accessors
		private var _srcDir:String;
		private var _mxmlcPath:String;
		private var _mxmlcArgs:String;
		private var _cucumberPath:String;
		private var _cucumberArgs:String;
		private var _headless:String;
		
		public function Cuke4AS3( hasUi:Boolean = false )
		{
            if( expectCommandLineArgs( hasUi ) )
            {
                NativeApplication.nativeApplication.addEventListener( InvokeEvent.INVOKE, onInvoke );
            }

			NativeApplication.nativeApplication.addEventListener( Event.EXITING, onExiting );
			//If using a ui make a new Cuke4AS3( true )
			//Listen for events esp error event coming out of here then call init() and
			//explicitly set the srcDir, mxmlcPath, cucumberPath, mxmlcArgs, cucumberArgs
			//before calling run() to set everything in motion
		}

        private function expectCommandLineArgs( hasUi:Boolean ):Boolean
        {
            return hasUi == false;
        }
		
		public function init():void
		{
			info("Cuke4AS3 : init");
			try
			{
				_cuke4AS3Server = new Cuke4AS3Server();
			}
			catch( e:Error )//E.g. ServerSocket not supported
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.message, e.errorID ) );
			}
			_compilerProcess = new CompilerProcess();
			_compilerProcess.isUseBundledDConsole = true;
			_compilerProcess.isUseBundledFlexUnit = true;
			_cucumberProcess = new CucumberProcess();
			_binarySwfLoader = new BinarySwfLoader();
			_swfProcessor = new SwfProcessor();	
		}
		
		public function run():void
		{
			info("Cuke4AS3 : run");
			if( validateMinimumRunRequirements() )
			{
				houseKeeping();

				runCompiler();
			}
			else
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "Cannot run, ensure you have set srcDir, mxmlcPath and cucumberPath", Config.CUKE_CANNOT_RUN_ERROR ) );
			}
		}
		
		public function stop():void
		{
			info("Cuke4AS3 : stop");
			
			compilerDestroy();
			
			cucumberDestroy();
			
			swfLoaderDestroy();
			
			swfProcessorDestroy();

            //If we have called stop in the middle of a scenario we need
			//to make sure destroy is called on the steps object
			stepInvokerDestroy();
			
			stepMatcherDestroy();

			//Dont need to kill CukeServer since that is all
			//managed withing its run function
//			serverDestroy();
			
			houseKeeping();
		}
		
		//Run Compiler
		//============
		
		private function runCompiler():void
		{
			info("Cuke4AS3 : runCompiler");
			_compilerProcess.init();
			_compilerProcess.srcDir = srcDir;
			_compilerProcess.mxmlcPath = mxmlcPath;
			_compilerProcess.additionalArgs = mxmlcArgs;
			_compilerProcess.addEventListener( Event.COMPLETE, onCompilerProcessComplete );
			_compilerProcess.addEventListener( Process.PROCESS_ERROR_EVENT, onCompilerProcessError );
			_compilerProcess.run();
		}
		
		private function onCompilerProcessComplete(event:Event):void
		{
			info("Cuke4AS3 : onCompilerProcessComplete");
			
			//Destroy later after we have extracted the steps directory listing
			//that the swf processor uses
			removeCompilerProcessEventListeners();
			
			loadCompiledSwf();
		}
		
		private function onCompilerProcessError(event:ErrorEvent):void
		{
			warn("Cuke4AS3 : onCompilerProcessError : shell exited with a compile error :",event);
			
			compilerDestroy();
			
			//Note: UI should be listening for this event and should call stop
			stop();
			exit();
		}
		
		//Load compiled Swf
		//=================
		
		private function loadCompiledSwf():void
		{	
			info("Cuke4AS3 : loadCompiledSwf");
			_binarySwfLoader.init();
			_binarySwfLoader.swfToLoad = srcDir + File.separator + Config.OUTPUT_SWF;
			
			addSwfLoaderListeners();
			
			_binarySwfLoader.load();
		}
		
		private function onSwfLoaderError(event:ErrorEvent):void
		{
			fatal("Cuke4AS3 : onSwfLoaderError :",event.text);
			
			swfLoaderDestroy();
			
			//Note: UI should be listening for this event and should call stop
			stop();
			exit();
		}
		
		private function onSwfLoaderComplete(event:Event):void
		{
			info("Cuke4AS3 : onSwfLoaderComplete");
			
			//the binary swf loader puts all newly comiled swfs into a new application domain
			//in order to avoid conflicting class names and to ensure we invoke the right function on the right object
			var applicationDomain:ApplicationDomain = _binarySwfLoader.applicationDomain;
			
			swfLoaderDestroy();
			
			processCompiledSwf( applicationDomain );
		}
		
		//Post compile/load processing
		//============================
		
		private function processCompiledSwf( applicationDomain:ApplicationDomain ):void
		{
			info("Cuke4AS3 : processCompiledSwf :", applicationDomain);

			_stepInvoker = new StepInvoker();
			_stepInvoker.applicationDomain = applicationDomain;

            //Step matcher sets invokable steps on the invoker once a match has been made
			_stepMatcher = new StepMatcher( _stepInvoker );

			_swfProcessor.applicationDomain = applicationDomain;
            //Swf processor sets a list matchable steps on the step matcher
			_swfProcessor.stepMatcher = _stepMatcher;
			_swfProcessor.stepDirectoryFiles = _compilerProcess.step_definitionsDirectoryListing;
			
			compilerDestroy();
			
			addSwfProcessorListeners();

			_swfProcessor.processLoadedClasses();
		}
		
		protected function onSwfProcessorError(event:Event):void
		{
			info( "Cuke4AS3 : onSwfProcessorError :", event );
			
			swfProcessorDestroy();
				
			//Note: UI should be listening for this event and should call stop
			stop();
			exit();
		}
		
		protected function onSwfProcessorComplete(event:Event):void
		{
			info( "Cuke4AS3 : onSwfProcessorComplete :", event );
			
			swfProcessorDestroy();
			
			runCuke4AS3Server();
		}
		
		private function runCuke4AS3Server():void
		{
			info("Cuke4AS3 : runCuke4AS3Server");

			try
			{
				var wireFileParser:WireFileParser = new WireFileParser();
				var serverInfo:ServerInfo = wireFileParser.getServerInfoFromWireFile( srcDir );
                wireFileParser.destroy();
			}
			catch( e:Error )
			{
				fatal( "Cuke4AS3 : runCuke4AS3Server :", e, e.getStackTrace() );//No wire file so no point in carrying on
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "Cannot run. There is no wire file in your features or step_definitions directories", Config.CUKE_NO_WIRE_FILE ) );
				return;
			}

			_cuke4AS3Server.host = serverInfo.host;
			_cuke4AS3Server.port = serverInfo.port;
			
			serverInfo.destroy();

            var commandProcessor:CommandProcessor = new CommandProcessor();
            //Command processor asks to match steps and invoke them based on
            //Cucumber's requests
            commandProcessor.stepInvoker = _stepInvoker;
            commandProcessor.stepMatcher = _stepMatcher;

            _cuke4AS3Server.commandProcessor = commandProcessor;
			
			addServerListeners();
			
			_cuke4AS3Server.run();
		}
		
		protected function onServerError(event:Event):void
		{
			info( "Cuke4AS3 : onServerError :", event );
			
			serverDestroy();
			
			//Note: UI should be listening for this event and should call stop
			stop();
			exit();
		}
		
		protected function onServerRunning(event:Event):void
		{
			info( "Cuke4AS3 : onServerRunning :", event );
			
			runCucumber();
		}
		
		private function runCucumber():void
		{
			info("Cuke4AS3 : runCucumber");
			//Run cucumber
			_cucumberProcess.init();
			_cucumberProcess.srcDir = srcDir;
			_cucumberProcess.cucumberPath = cucumberPath;
			_cucumberProcess.additionalArgs = cucumberArgs;
			
			_cucumberProcess.addEventListener( Event.COMPLETE, onCucumberProcessComplete );
			_cucumberProcess.addEventListener( Process.PROCESS_ERROR_EVENT, onCucumberProcessError );
			_cucumberProcess.run();
		}
		
		private function onCucumberProcessComplete(event:Event):void
		{
			info("Cuke4AS3 : onCucumberProcessComplete : Cucumber is done :",event);
			
			cucumberDestroy();
			
			//All done: Lets try to get out of here when in headless mode
			exit();
		}
		
		private function onCucumberProcessError(event:ErrorEvent):void
		{
			warn("Cuke4AS3 : onCucumberProcessError : shell exited with a Cucumber error :",event);

			cucumberDestroy();
			
			//Note: UI should be listening for this event and should call stop
			stop();
			exit();
		}
		
		
//		protected function onServerConnect(event:ServerSocketConnectEvent):void
//		{
//			_cuke4AS3Server.server.removeEventListener( ServerSocketConnectEvent.CONNECT, onServerConnect );
//			_cuke4AS3Server.cucumber.socket.addEventListener( Event.CLOSE, onCucumberClientClose );
//		}
//		
//		private function onCucumberClientClose(event:Event):void
//		{
//			_cuke4AS3Server.cucumber.socket.removeEventListener( Event.CLOSE, onCucumberClientClose );
//			//For standalone flashplayer debug version only
//			//Force exit
//			if( _headless == "true")
//			{
//				debug("!!!!!");
//				NativeApplication.nativeApplication.dispatchEvent( new Event( Event.EXITING ) );//Note exiting is not disppatched
//				NativeApplication.nativeApplication.exit();
//			}	
//		}
		
		//Command line runner
		//===================
		
		//To run in headless mode you will need the following command line args in your debug configuration or adl
		//-srcDir "/Users/username/Documents/Adobe Flash Builder 4.5/Calculator/src/" 
		//srcDir must contain a 'features' directory which can in turn contain a 'filename.wire' file 
		//and 'step_definitions' directory for *.as step definitions which can also contain a feature.wire file
		//-mxmlc "/Applications/Adobe Flash Builder 4.5/sdks/4.5.1/bin/mxmlc" path to mxmlc compiler
		//-cucumber "/usr/local/bin/cucumber"   path to cucumber executable
		//-headless true
		//for mxmlc and cucumber args THE WHOLE STRING MUST BE ENCLOSED BY SINGLE QUOTES WITHOUT WHITE SPACE
		//File paths with spaces in MUST BE ENCLOSED IN SINGLE QUOTES
		//-mxmlcArgs "'-compiler-arg arg 'path with spaces' -other-compiler-arg arg'" 
		//-cucumberArgs "'-cucumber-arg arg -other-arg arg'"
		private function onInvoke(event:InvokeEvent):void
		{
			try{
				info("Cuke4AS3 : onInvoke :", event.arguments.length, event.arguments.toString() );
				
				var invokeArgsProcessor:InvokeArgumentsProcessor = new InvokeArgumentsProcessor();
				
				if( invokeArgsProcessor.processArguments( event.arguments ) )
				{
					srcDir = invokeArgsProcessor.srcDir;
					mxmlcPath = invokeArgsProcessor.mxmlc;
					cucumberPath = invokeArgsProcessor.cucumber;
					
					if( invokeArgsProcessor.mxmlcArgs != null)
						mxmlcArgs = StringUtilities.stripSingleQuotesAtStartAndEndOfString( invokeArgsProcessor.mxmlcArgs );
					
					if( invokeArgsProcessor.cucumberArgs != null )
						cucumberArgs = StringUtilities.stripSingleQuotesAtStartAndEndOfString( invokeArgsProcessor.cucumberArgs );
					
					if( invokeArgsProcessor.headless != null )
						_headless = invokeArgsProcessor.headless;
				}
				
				invokeArgsProcessor.destroy();
//				debug("Cuke4AS3 : onInvoke : mxmlcArgs :",mxmlcArgs);
//				debug("Cuke4AS3 : onInvoke : cucumberArgs",cucumberArgs);
				
//				info("Cuke4AS3 : onInvoke : can run? :",NativeProcess.isSupported, invokeArgsProcessor.headless);
				
				if(!NativeProcess.isSupported)
				{
					throw new Error("NativeProcess is not supported please use extendedDesktop profile");
				}
				else
				{
					//Set up fluint visual test environment for UIImpersonator
					var testUI:Sprite = new Sprite();
//					testUI.visible = false;//Cannot detect Video like this :(
					addChild( testUI );
					visualTestEnvironment = testUI;

					init();
					run();
				}
			}
			catch( e:Error )
			{
				fatal("Cuke4AS3 : onInvoke :", e, e.getStackTrace());
			}
		}
		
		//Support
		//=======
		
		private function validateMinimumRunRequirements():Boolean
		{
			//The bare minimum to run is srcDir, mxmlc and cucumber
			return ( StringUtilities.isNotNullAndNotEmptyString( srcDir ) )
			&& ( StringUtilities.isNotNullAndNotEmptyString( mxmlcPath ) ) 
				&& ( StringUtilities.isNotNullAndNotEmptyString( cucumberPath ) );
		}

//		Explain this
		override public function dispatchEvent(event:Event):Boolean
		{
			var b:Boolean = false;
			if( _headless != "true" )//dispatch as normal
			{
				b = super.dispatchEvent( event );
			}
			else
			{
				//Write this top level error to a file for when headless
				debug("Cuke4AS3 : dispatchEvent : In headless mode :", event );
				b = false;
				
				exit();
			}	
			return b;
		}
		
		private function exit():void
		{
			if( _headless == "true")//Can't think of a reason to call exit when using UI
			{
				info("Cuke4AS3 : exit");
				NativeApplication.nativeApplication.dispatchEvent( new Event( Event.EXITING ) );//Note: exiting is not dispatched when we call exit()
				NativeApplication.nativeApplication.exit();//Terminates application, not supported on iOS
			}
		}
		
		//House keeping
		//=============
		
		public function onExiting(event:Event = null):void
		{
			info("Cuke4AS3 : onExiting");
			swfLoaderDestroy();
			_binarySwfLoader = null;
			
			swfProcessorDestroy();
			_swfProcessor = null;
			
			compilerDestroy();
			_compilerProcess = null;
			
			cucumberDestroy();
			_cucumberProcess = null;
			
			serverDestroy();
			_cuke4AS3Server = null;
			
			stepInvokerDestroy();
            _stepInvoker = null;
				
			stepMatcherDestroy();
            _stepMatcher = null
			
			_srcDir = null;
			_mxmlcPath = null;
			_mxmlcArgs = null;
			_cucumberPath = null;
			_cucumberArgs = null;
			
			houseKeeping();
		}

        private function stepMatcherDestroy():void
        {
            if( _stepMatcher != null )//may not have been made
            {
                _stepMatcher.destroy();
            }
        }

        private function stepInvokerDestroy():void
        {
            if( _stepInvoker != null )//May not have been made
            {
                _stepInvoker.destroy();
            }
        }
		
		private function cucumberDestroy():void
		{
            if( _cucumberProcess != null )
            {
                 removeCucumberProcessEventListeners();
                _cucumberProcess.destroy();   
            }
		}
		
		private function compilerDestroy():void
		{
            if( _compilerProcess != null)
            {
                removeCompilerProcessEventListeners();
			    _compilerProcess.destroy();   
            }
		}
		
		private function swfProcessorDestroy():void
		{
            if( _swfProcessor != null )
            {
                removeSwfProcessorListeners();
			    _swfProcessor.destroy();
            }
		}
		
		private function swfLoaderDestroy():void
		{
            if( _binarySwfLoader != null )
            {
                removeSwfLoaderListeners();
			    _binarySwfLoader.destroy();
            }
		}
		
		private function serverDestroy():void
		{
            if( _cuke4AS3Server != null )
            {
                removeServerListeners();
			    _cuke4AS3Server.destroy();
            }
		}
		
		private function houseKeeping():void
		{
			UIImpersonator.removeAllChildren();
			System.gc();
		}
		//Listeners
		//=========
		
		//SwfLoader listeners
		
		private function addSwfLoaderListeners():void
		{
			_binarySwfLoader.addEventListener( Event.COMPLETE, onSwfLoaderComplete );
			_binarySwfLoader.addEventListener( ErrorEvent.ERROR, onSwfLoaderError );
		}
		
		private function removeSwfLoaderListeners():void
		{
			_binarySwfLoader.removeEventListener( Event.COMPLETE, onSwfLoaderComplete );
			_binarySwfLoader.removeEventListener( ErrorEvent.ERROR, onSwfLoaderError );
		}
		
		//Process listeners
		
		private function removeCompilerProcessEventListeners():void
		{
			_compilerProcess.removeEventListener( Event.COMPLETE, onCompilerProcessComplete );
			_compilerProcess.removeEventListener( Process.PROCESS_ERROR_EVENT, onCompilerProcessError );
		}
		
		private function removeCucumberProcessEventListeners():void
		{
			_cucumberProcess.removeEventListener( Event.COMPLETE, onCucumberProcessComplete );
			_cucumberProcess.removeEventListener( Process.PROCESS_ERROR_EVENT, onCucumberProcessError );
		}
		
		//Swf Processor listeners
		
		private function addSwfProcessorListeners():void
		{
			_swfProcessor.addEventListener( Event.COMPLETE, onSwfProcessorComplete );
			_swfProcessor.addEventListener( ErrorEvent.ERROR, onSwfProcessorError );
		}
		
		private function removeSwfProcessorListeners():void
		{
			_swfProcessor.removeEventListener( Event.COMPLETE, onSwfProcessorComplete );
			_swfProcessor.removeEventListener( ErrorEvent.ERROR, onSwfProcessorError );
		}
		
		//Server listeners
		
		private function addServerListeners():void
		{
			_cuke4AS3Server.addEventListener( ErrorEvent.ERROR, onServerError );
			_cuke4AS3Server.addEventListener( Event.COMPLETE, onServerRunning );
			
//			_cuke4AS3Server.server.addEventListener( ServerSocketConnectEvent.CONNECT, onServerConnect );
		}
		
		private function removeServerListeners():void
		{
			_cuke4AS3Server.removeEventListener( ErrorEvent.ERROR, onServerError );
			_cuke4AS3Server.removeEventListener( Event.COMPLETE, onServerRunning );
			
//			_cuke4AS3Server.server.removeEventListener( ServerSocketConnectEvent.CONNECT, onServerConnect );
		}
		
		//Accessors
		//=========
		
		public function get compilerProcess():CompilerProcess
		{
			return _compilerProcess;
		}
		
		public function get cucumberProcess():CucumberProcess
		{
			return _cucumberProcess;
		}
		
		public function get srcDir():String
		{
			return _srcDir;
		}

		public function set srcDir(value:String):void
		{
			_srcDir = value;
		}

		public function get cucumberPath():String
		{
			return _cucumberPath;
		}

		public function set cucumberPath(value:String):void
		{
			_cucumberPath = value;
		}

		public function get mxmlcPath():String
		{
			return _mxmlcPath;
		}

		public function set mxmlcPath(value:String):void
		{
			_mxmlcPath = value;
		}
		
		public function set visualTestEnvironment( visualDisplayRoot:Sprite ):void
		{
			var testEnvironment:IVisualEnvironmentBuilder = VisualTestEnvironmentBuilder.getInstance( visualDisplayRoot );
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

		public function get cuke4AS3Server():Cuke4AS3Server
		{
			return _cuke4AS3Server;
		}

		public function set cuke4AS3Server(value:Cuke4AS3Server):void
		{
			_cuke4AS3Server = value;
		}

		public function get swfLoader():BinarySwfLoader
		{
			return _binarySwfLoader;
		}

		public function get swfProcessor():SwfProcessor
		{
			return _swfProcessor;
		}

	}
}