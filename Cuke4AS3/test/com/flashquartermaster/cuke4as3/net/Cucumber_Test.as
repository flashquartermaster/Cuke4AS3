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
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.Socket;

    import org.flexunit.assertThat;
    import org.hamcrest.collection.hasItem;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.object.strictlyEqualTo;

    public class Cucumber_Test
	{		
		private var _sut:Cucumber;
		private var _socket:Socket;
		
		[Before]
		public function setUp():void
		{
			_socket = new Socket();
			_sut = new Cucumber( _socket );
		}
		
		[After]
		public function tearDown():void
		{
			_sut.destroy();
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
		public function should_construct():void
		{
			assertThat( _sut.socket, notNullValue() );
			assertThat( _sut.socket, strictlyEqualTo( _socket ) );
			assertThat( _sut.socket.hasEventListener( Event.CONNECT ), isTrue() );
			assertThat( _sut.socket.hasEventListener( ProgressEvent.SOCKET_DATA ), isTrue() );
		}
		
		[Test]
		public function should_destroy():void
		{
			_sut.destroy();
			
			assertThat( _sut.socket, nullValue() );
			assertThat( _sut.rawSocketData, nullValue() );
		}
		
		[Test]
		public function should_decode_json():void
		{
			var inputElement:String = "begin_scenario";
			var input:String = "[\""+inputElement+"\"]\n";
			var expectedResult:Array = ["begin_scenario"];
			
			_sut.rawSocketData = input;
			
			var result:Array = _sut.jsonDecodeSocketData();
			
			assertThat( result, equalTo( expectedResult ) );
			assertThat( result, hasItem( inputElement ) );
		}
		
		[Test]
		public function should_encode_and_send_json():void
		{
			_socket.connect("0.0.0.0.",54321);
			_socket.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			_sut.jsonEncodeAndSend( ["success"] );
		}
		
		protected function onIOError(event:IOErrorEvent):void
		{
			trace("Cucumber_Test : onIOError : From : test_jsonEncodeAndSend");
		}
		
		//Accessors
		
		[Test]
		public function should_get_socket():void
		{
			assertThat( _sut.socket, notNullValue() );
			assertThat( _sut.socket, strictlyEqualTo( _socket ) );
		}
		
		[Test]
		public function should_get_rawSocketData():void
		{
			assertThat( _sut.rawSocketData, nullValue() );
		}
		
		[Test]
		public function should_set_rawSocketData():void
		{
			var expectedResult:String = "[\"begin_scenario\"]\n";
			
			_sut.rawSocketData = expectedResult;
			
			assertThat( _sut.rawSocketData, equalTo( expectedResult ) );
		}
	}
}