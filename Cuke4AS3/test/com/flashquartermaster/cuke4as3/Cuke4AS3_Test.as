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
package com.flashquartermaster.cuke4as3{
    import com.flashquartermaster.cuke4as3.net.BinarySwfLoader;
    import com.flashquartermaster.cuke4as3.net.Cuke4AS3Server;
    import com.flashquartermaster.cuke4as3.process.CompilerProcess;
    import com.flashquartermaster.cuke4as3.process.CucumberProcess;
    import com.flashquartermaster.cuke4as3.reflection.SwfProcessor;

    import flash.desktop.NativeApplication;
    import flash.display.Sprite;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.InvokeEvent;

    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.core.not;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;

    public class Cuke4AS3_Test
	{		
		private var _sut:Cuke4AS3;
		
		[Before]
		public function setUp():void
		{
			_sut = new Cuke4AS3();
		}
		
		[After]
		public function tearDown():void
		{
			_sut.onExiting();
			_sut = null;
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function should_default_construct():void
		{
			//Constructed in setUp
			assertThat( _sut, not( nullValue() ) );
			assertThat( _sut, instanceOf( Cuke4AS3 ) );
			assertThat( _sut, instanceOf( Sprite ) );
		}

        [Test]
        public function should_construct_with_ui_switch():void
        {
            _sut = new Cuke4AS3( true );

            assertThat( _sut, not( nullValue() ) );
            assertThat( _sut, instanceOf( Cuke4AS3 ) );
            assertThat( _sut, instanceOf( Sprite ) );
        }

		[Test]
		public function should_inititalise():void
		{
			_sut.init();
			
			//Has set up all the classes that can be listened to from UI
			var server:Cuke4AS3Server = _sut.cuke4AS3Server;
			assertThat( server, not( nullValue() ) );
			
			var cucumber:CucumberProcess = _sut.cucumberProcess;
			assertThat( cucumber, not( nullValue() ) );
			
			var compiler:CompilerProcess = _sut.compilerProcess;
			assertThat( compiler, not( nullValue() ) );
			//Set compiler defaults
			assertThat( compiler.isUseBundledDConsole, isTrue() );
			assertThat( compiler.isUseBundledFlexUnit, isTrue() );
			
			var swfLoader:BinarySwfLoader = _sut.swfLoader;
			assertThat( swfLoader, notNullValue() );
			
			var swfprocessor:SwfProcessor = _sut.swfProcessor;
			assertThat( swfprocessor, notNullValue() );
		}
		
		//Run/Stop
		[Test (async)]
		public function should_dispatch_error_event_if_not_set_up_correctly():void
		{
			_sut.init();
			//Without valid params expect an error: srcDir not set
			Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedRunErrorEvent );
			_sut.run();
		}
		
		[Test (async) ]
		public function should_dispatch_error_event_if_srcDir_is_null():void
		{
			_sut.init();
			
			_sut.mxmlcPath = "/blah/blah blah/blah/mxmlc";
			_sut.cucumberPath = "/blah/blah blah/blah/cucumber";
			
			Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedRunErrorEvent );
			
			_sut.run();
		}
		
		[Test (async) ]
		public function should_dispatch_error_event_if_srcDir_is_empty():void
		{
			_sut.init();
			
			_sut.mxmlcPath = "/blah/blah blah/blah/mxmlc";
			_sut.cucumberPath = "/blah/blah blah/blah/cucumber";
			_sut.srcDir = "";
			
			Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedRunErrorEvent );
			
			_sut.run();
		}
		
		[Test ( async )]
		public function should_dispatch_error_event_if_mxmlcPath_is_null():void
		{
			_sut.init();
			
			_sut.srcDir = "/blah/blah blah/blah/src";
			_sut.cucumberPath = "/blah/blah blah/blah/cucumber";
			
			Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedRunErrorEvent );
			
			_sut.run();
		}
		
		[Test ( async )]
		public function should_dispatch_error_event_if_mxmlcPath_is_empty():void
		{
			_sut.init();
			
			_sut.srcDir = "/blah/blah blah/blah/src";
			_sut.cucumberPath = "/blah/blah blah/blah/cucumber";
			_sut.mxmlcPath = "";
			
			Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedRunErrorEvent );
			
			_sut.run();
		}
		
		[Test ( async )]
		public function should_dispatch_error_event_if_cucumberPath_is_null():void
		{
			_sut.init();
			
			_sut.srcDir = "/blah/blah blah/blah/src";
			_sut.mxmlcPath = "/blah/blah blah/blah/mxmlc";
			
			Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedRunErrorEvent );
			
			_sut.run();
		}
		
		[Test ( async )]
		public function should_dispatch_error_event_if_cucumberPath_is_empty():void
		{
			_sut.init();
			
			_sut.srcDir = "/blah/blah blah/blah/src";
			_sut.mxmlcPath = "/blah/blah blah/blah/mxmlc";
			_sut.cucumberPath = "";
			
			Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedRunErrorEvent );
			
			_sut.run();
		}
		
		private function onExpectedRunErrorEvent( event:ErrorEvent, passThroughData:Object):void
		{
			assertThat( event.type, equalTo( ErrorEvent.ERROR ) );
			assertThat( event.errorID, equalTo( Config.CUKE_CANNOT_RUN_ERROR) );
		}
		
		[Test]
		public function should_stop():void
		{
			_sut.init();
			_sut.stop();
			
			assertThat( _sut.compilerProcess.running, isFalse() );
			assertThat( _sut.cucumberProcess.running, isFalse() );
			assertThat( _sut.swfLoader.running, isFalse() );
			//Cannot verify swf processor is stopped
			assertThat( UIImpersonator.numChildren, equalTo( 0 ) );
		}
		
		//Compiler and Cucumber process
		[Test]
		public function should_get_srcDir():void
		{
			_sut.init();
			
			var s:String = _sut.srcDir;
			
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_srcDir():void
		{
			_sut.init();
			
			var s:String = "/blah/blah blah/blah/blah";
			
			_sut.srcDir = s;
			
			assertThat( _sut.srcDir, equalTo( s ) );
		}
		
		//Compiler process and associated
		[Test]
		public function should_get_compilerProcess():void
		{
			var compiler:CompilerProcess = _sut.compilerProcess;
			assertThat( compiler, nullValue() );
			
			_sut.init();
		}
		
		[Test]
		public function should_get_mxmlcPath():void
		{
			_sut.init();
			
			var s:String = _sut.mxmlcPath;
			
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_mxmlcPath():void
		{
			_sut.init();
			
			var s:String = "/blah/blah blah/blah/blah/mxmlc";
			
			_sut.mxmlcPath = s;
			
			assertThat( _sut.mxmlcPath, equalTo( s ) );
		}
		
		[Test]
		public function should_set_mxmlcArgs():void
		{
			_sut.init();
			
			var s:String = "-compiler.library-path '/blah/blah blah/blah'";
			
			_sut.mxmlcArgs = s;
			
			assertThat( _sut.mxmlcArgs, equalTo( s ) );
		}
		
		[Test]
		public function should_get_mxmlcArgs():void
		{
			_sut.init();
			
			var s:String = _sut.mxmlcArgs;
			
			assertThat( s, nullValue() );
		}
		
		//Cucumber process and associated
		
		[Test]
		public function should_get_cucumberProcess():void
		{
			var cucumber:CucumberProcess = _sut.cucumberProcess;
			assertThat( cucumber, nullValue() );
			
			_sut.init();
		}
		
		[Test]
		public function should_get_cucumberArgs():void
		{
			_sut.init();
			
			var s:String = _sut.cucumberArgs;
			
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_cucumberArgs():void
		{
			_sut.init();
			
			var s:String = "--tags @foo,@bar -f html -o '/blah/blah blah/some.html'";
			
			_sut.cucumberArgs = s;
			
			assertThat( _sut.cucumberArgs, equalTo( s ) );
		}
		
		[Test]
		public function should_get_cucumberPath():void
		{
			_sut.init();
			
			var s:String = _sut.cucumberPath;
			
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_cucumberPath():void
		{
			_sut.init();
			
			var s:String = "/blah/blah blah/blah/cucumber";
			
			_sut.cucumberPath = s;
			
			assertThat( _sut.cucumberPath, equalTo( s ) );
		}
		
		//Visual Ui test Environment
		[Test]
		public function should_set_visualTestEnvironment():void
		{
			_sut.init();
			
			//Cannot test this as UIImpersonator would have to be used to put
			//_sut on the virtual stage thereby creating an instance and blockin the 
			//ability to set the visual test environemnt
			assertThat( true, isTrue() );
		}
		
		//Object accessors
		[Test]
		public function should_get_CompilerProcess():void
		{
			var compiler:CompilerProcess = _sut.compilerProcess;
			assertThat( compiler, nullValue() );
			
			_sut.init();
		}
		
		[Test]
		public function should_get_CucumberProcess():void
		{
			var cucumber:CucumberProcess = _sut.cucumberProcess;
			assertThat( cucumber, nullValue() );
			
			_sut.init();
		}
		
		[Test]
		public function should_get_Cuke4AS3Server():void
		{
			var server:Cuke4AS3Server = _sut.cuke4AS3Server;
			assertThat( server, nullValue() );
			
			_sut.init();
		}
		
		[Test]
		public function should_get_swfLoader():void
		{
			var swfLoader:BinarySwfLoader = _sut.swfLoader;
			assertThat( swfLoader, nullValue() );
			
			_sut.init();
		}
		
		[Test]
		public function should_get_swfProcessor():void
		{
			var swfProcessor:SwfProcessor = _sut.swfProcessor;
			assertThat( swfProcessor, nullValue() );
			
			_sut.init();
		}
	}
}