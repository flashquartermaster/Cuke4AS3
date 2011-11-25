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

    import flash.events.ErrorEvent;
    import flash.events.EventDispatcher;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;

    import flexunit.framework.Assert;

    import org.flexunit.asserts.fail;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.core.anyOf;
    import org.hamcrest.core.not;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.text.containsString;

    import support.FileHelper;

    public class Process_Test
	{		
		private var _sut:Process;
		private static var _fileHelper:FileHelper;
		
		[Before]
		public function setUp():void
		{
			_sut = new Process();
		}
		
		[After]
		public function tearDown():void
		{
			_sut.destroy();
			_sut = null;
			_fileHelper.destroy();
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			_fileHelper = new FileHelper();
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
			_fileHelper.destroy();
			_fileHelper = null;
		}
		
		[Test]
		public function should_construct():void
		{
			assertThat( _sut, not( nullValue() ) );
			assertThat( _sut, instanceOf( IProcess ) );
			assertThat( _sut, instanceOf( EventDispatcher ) );
			assertThat( _sut, instanceOf( Process ) );	
		}
		
		[Test]
		public function should_initialise():void
		{
			//Please note: This is bad practice and should be avoided
			//however the success of this class depends on the NativeProcess object
			//So I'm making an exception. :-p
			
			var exposer:Process = new ProcessExposer();
			exposer.init();
			
			assertThat( ProcessExposer( exposer ).nativeProcess, not( nullValue() ) );
			assertThat( ProcessExposer( exposer ).nativeProcess.hasEventListener( ProgressEvent.STANDARD_OUTPUT_DATA ), isTrue() );
			assertThat( ProcessExposer( exposer ).nativeProcess.hasEventListener( ProgressEvent.STANDARD_ERROR_DATA ), isTrue() );
			assertThat( ProcessExposer( exposer ).nativeProcess.hasEventListener( NativeProcessExitEvent.EXIT ), isTrue() );
		}
		
		[Test (async) ]
		public function should_dispatch_an_error_event_when_run_without_proper_set_up():void
		{
			_sut.init();
			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedRunError );
			_sut.run();
		}
		
		private function onExpectedRunError( event:ErrorEvent, passThroughData:Object):void
		{
			assertThat("Event type is process error", event.type, equalTo( Process.PROCESS_ERROR_EVENT ) );
			assertThat("Event errorId", event.errorID, equalTo( Config.VALIDATION_ERROR ) );
		}
		
		[Test (async) ]
		public function should_destroy():void
		{
			_sut.destroy();//No errors test
		}
		
		//Validate src directory and consequently the implementation 
		//of validateFilePath(...) for classes that extend Process
		
		[Test (async) ]
		public function should_validate_srcDir_is_valid():void
		{
			assertThat( _sut.srcDir, nullValue() );
			
			_sut.srcDir = _fileHelper.getValidTmpDirectory();
			
			//Will still get a validation error but a different one
			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedExecutableProcessError);
			_sut.init();
			_sut.run();
		}
		
		[Test (async) ]
		public function should_validate_srcDir_is_null():void
		{
			assertThat( _sut.srcDir, nullValue() );
			
			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedProcessError);
			
			_sut.init();
			_sut.run();
		}
		
		[Test (async) ]
		public function should_validate_srcDir_is_empty():void
		{
			_sut.srcDir = "";
			
			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedProcessError);
			
			_sut.init();
			_sut.run();
		}
		
		[Test (async) ]
		public function should_validate_srcDir_is_invalidDirectory():void
		{
			_sut.srcDir = "/blah/blah blah/src";
			
			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedProcessError);
			
			_sut.init();
			_sut.run();
		}

        //Validate shell exit events

		[Ignore( "Todo" )]
		[Test]
		public function should_exit_shell_correctly():void
		{
			fail( "Not yet implemented" );
		}

		[Ignore( "Todo" )]
		[Test (async) ]
		public function should_exit_shell_with_compiler_errors_cleanly():void
		{
			//note exit code is the amount of errors
			fail( "Not yet implemented" );
		}

		[Ignore( "Todo" )]
		[Test (async) ]
		public function should_exit_shell_with_unknown_exit_code_cleanly():void
		{
			fail( "Not yet implemented" );
		}

		[Ignore( "Todo" )]
		[Test (async) ]
		public function should_exit_shell_with_forced_exit_cleanly():void
		{
			//exit code isNan()
			fail( "Not yet implemented" );
		}

		private function onExpectedProcessError( event:ErrorEvent, passThroughData:Object):void
		{
			assertThat( event.errorID, equalTo( Config.VALIDATION_ERROR ) );
			assertThat( event.text, anyOf( containsString("srcDir must be set"), containsString("Path to srcDir \"") ) );
		}
		
		private function onExpectedExecutableProcessError( event:ErrorEvent, passThroughData:Object):void
		{
			assertThat( event.errorID, equalTo( Config.VALIDATION_ERROR ) );
			assertThat( event.text, anyOf( containsString( "Error #3214" ), containsString( "Error #3219") ) );
		}
		
		//Accessors
		
		[Test]
		public function should_get_running():void
		{
			assertThat("Default is not running", _sut.running, isFalse() );
			
			_sut.destroy();
			
			assertThat("After destroy there is no null error", _sut.running, isFalse() );
		}
		
		[Test]
		public function should_get_srcDir():void
		{
			assertThat( _sut.srcDir, nullValue() );
		}
		
		[Test]
		public function should_set_srcDir():void
		{
			var s:String = "/blah/blah blah/src";
			_sut.srcDir = s;
			assertThat( _sut.srcDir, equalTo( s ) );
		}
		
		[Test]
		public function should_get_additionalArgs():void
		{
			assertThat( _sut.additionalArgs, nullValue() );
		}
		
		[Test]
		public function should_set_additionalArgs():void
		{
			var additionalArgs:String = "arg1 arg2 arg3";
			_sut.additionalArgs = additionalArgs;
			assertThat( _sut.additionalArgs, equalTo( additionalArgs ) );
		}
	}
	
}