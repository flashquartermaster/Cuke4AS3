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
    import org.flexunit.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;

    public class ServerInfo_Test
	{		
		private var _sut:ServerInfo;
		
		[Before]
		public function setUp():void
		{
			_sut = new ServerInfo();
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
			assertThat( _sut, notNullValue() );
			assertThat( _sut, instanceOf( ServerInfo ) );
		}
		
		[Test]
		public function should_destroy():void
		{
			_sut.destroy();
			
			assertThat( _sut.host, nullValue() );
			assertThat( _sut.port, equalTo( 0 ) );
		}
		
		[Test]
		public function should_get_host():void
		{
			//Test default host
			assertThat( _sut.host, equalTo( "0.0.0.0" ) );
		}
		
		[Test]
		public function should_set_host():void
		{
			var host:String = "127.0.0.1"
			_sut.host = host;
			assertThat( _sut.host, equalTo( host ) );
		}
		
		[Test]
		public function should_get_port():void
		{
			assertThat( _sut.port, equalTo( 54321 ) );
		}
		
		[Test]
		public function should_set_port():void
		{
			var port:int = 8081;
			_sut.port = port;
			assertThat( _sut.port, equalTo( port ) );
		}
	}
}