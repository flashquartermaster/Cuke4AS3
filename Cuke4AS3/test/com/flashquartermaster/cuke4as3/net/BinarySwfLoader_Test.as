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
package com.flashquartermaster.cuke4as3.net
{
    import com.flashquartermaster.cuke4as3.Config;

    import flash.events.ErrorEvent;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.filesystem.File;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;

    import support.FileHelper;

    public class BinarySwfLoader_Test
	{		
		private var _sut:BinarySwfLoader;
		private var _filehelper:FileHelper;
		
		[Before]
		public function setUp():void
		{
			_sut = new BinarySwfLoader();
			_filehelper = new FileHelper();
		}
		
		[After]
		public function tearDown():void
		{
			_sut.destroy();
			_sut = null;
			
			_filehelper.destroy();
			_filehelper = null;
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
		public function should_construct():void
		{
			assertThat( _sut, notNullValue() );
			assertThat( _sut, instanceOf( EventDispatcher ) );
			assertThat( _sut, instanceOf( BinarySwfLoader ) );
			assertThat( _sut.running, isFalse() );
		}
		
		[Test]
		public function should_initialise():void
		{
			//Just makes the urlloader and the loader
			_sut.init();
		}
		
		[Test (async) ]
		public function should_throw_IOError_if_loading_from_bad_filepath():void
		{
			_sut.init();
			_sut.swfToLoad = "crap" + File.separator + Config.OUTPUT_SWF;
			
			Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedIOError );
			Async.failOnEvent( this, _sut, Event.COMPLETE );
			
			_sut.load();
		}
		
		[Test (async) ]
		public function should_load_if_filepath_is_good():void
		{
			_sut.init();
			
			//Please note: This makes a class at runntime and writes the bytes to a tmp swf file that we load in
			_sut.swfToLoad = _filehelper.getValidSwfPath( Config.OUTPUT_SWF );
			
			Async.handleEvent( this, _sut, Event.COMPLETE, onBinarySwfLoaderComnplete );
			Async.failOnEvent( this, _sut, ErrorEvent.ERROR );
//			Async.failOnEvent( this, _sut, SecurityErrorEvent.SECURITY_ERROR );
			
			_sut.load();
		}
		
		[Test]
		public function should_report_that_it_has_stopped_correctly():void
		{
			assertThat( _sut.running, isFalse() );
			
			_sut.stop();
			
			assertThat( _sut.running, isFalse() );
		}
		
		[Test]
		public function should_destroy():void
		{
			_sut.destroy();
		}
		
		//Accessors
		
		[Test (async) ]
		public function should_get_running():void
		{
			//Default is false
			assertThat("Default running", _sut.running, isFalse() );
			
			_sut.init();
			_sut.swfToLoad = "";
			
			Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedIOError );
			
			_sut.load();
			
			assertThat("After load call running", _sut.running, isTrue() );
		}
		
		[Test]
		public function should_get_swfToProcess():void
		{
			assertThat( _sut.swfToLoad, nullValue() );
		}
		
		[Test]
		public function should_set_swfToProcess():void
		{
			var filePath:String = File.separator + "blah" + File.separator + Config.OUTPUT_SWF;
			var expectedResult:String = "file://" + filePath;
			
			assertThat( _sut.swfToLoad, nullValue() );
			
			_sut.swfToLoad = filePath;
			
			assertThat( _sut.swfToLoad, equalTo( expectedResult ) );
		}
		
		[Test]
		public function should_get_applicationDomain():void
		{
			assertThat( _sut.applicationDomain, nullValue() );
		}
		
		private function onBinarySwfLoaderComnplete( event:Event, passThroughData:Object ):void
		{
			assertThat( _sut.applicationDomain, notNullValue() );
		}
		
		//Support
		
		private function onExpectedIOError( event:ErrorEvent, passThroughData:Object ):void
		{
            assertThat( event.errorID, equalTo(2032) );//Stream error
		}
	}
}