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
    import com.flashquartermaster.cuke4as3.events.ProcessedCommandEvent;
    import com.flashquartermaster.cuke4as3.net.support.Cuke4AS3Server_Fixture_Support;

    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.Socket;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.core.allOf;
    import org.hamcrest.core.not;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;

    import support.MockCommandProcessor;

    public class Cuke4AS3Server_Test
    {
        private var _sut:Cuke4AS3Server;
        private var _mockCucumber:Socket;

        [Before]
        public function set_up():void
        {
            _sut = new Cuke4AS3Server()
        }

        [After]
        public function tear_down():void
        {
            if( _mockCucumber != null )
            {
                if( _mockCucumber.connected )
                {
                    _mockCucumber.close();
                }
                _mockCucumber = null;
            }

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
            assertThat( _sut, instanceOf( Cuke4AS3Server ) );
            assertThat( _sut, instanceOf( EventDispatcher ) );

            assertThat( _sut.server, notNullValue() );
            assertThat( _sut.server.hasEventListener( Event.CONNECT ), isTrue() );
            assertThat( _sut.server.hasEventListener( Event.CLOSE ), isTrue() );
        }

        [Test(async)]
        public function should_successfully_run_with_valid_set_up():void
        {
            Async.handleEvent( this, _sut, Event.COMPLETE, onServerRunning, 1000, new Cuke4AS3Server_Fixture_Support( _sut, "0.0.0.0", 54321 ).passThroughData );
            Async.failOnEvent( this, _sut, ErrorEvent.ERROR );

            _sut.run();
        }

        [Test(async)]
        public function should_raise_error_event_when_using_a_bad_host():void
        {
            //Note: Port increment in case port has not been released
            Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedError, 500, new Cuke4AS3Server_Fixture_Support( _sut, "I am a bad host name", 54322 ).passThroughData );
            Async.failOnEvent( this, _sut, Event.COMPLETE );

            _sut.run();
        }

        [Test(async)]
        public function should_raise_error_event_when_using_a_bad_port():void
        {
            Async.handleEvent( this, _sut, ErrorEvent.ERROR, onExpectedError, 500, new Cuke4AS3Server_Fixture_Support( _sut, "0.0.0.0", 443 ).passThroughData );
            Async.failOnEvent( this, _sut, Event.COMPLETE );

            _sut.run();
        }

        [Test]
        public function should_raise_an_error_if_it_has_no_command_processor():void
        {

        }

        [Test]
        public function should_destroy():void
        {
            _sut.destroy();

            assertThat( _sut.server, nullValue() );
            assertThat( _sut.cucumber, nullValue() );
            assertThat( _sut.host, nullValue() );
            assertThat( _sut.port, equalTo( 0 ) );
        }

        //Accessors

        [Test]
        public function should_get_cucumber():void
        {
            assertThat( _sut.cucumber, nullValue() );
        }

        [Test]
        public function should_get_host():void
        {
            assertThat( _sut.host, nullValue() );
        }

        [Test]
        public function should_set_host():void
        {
            var expectedResult:String = "127.0.0.1";

            _sut.host = expectedResult;

            assertThat( _sut.host, equalTo( expectedResult ) );
        }

        [Test]
        public function should_get_port():void
        {
            assertThat( _sut.port, equalTo( 0 ) );
        }

        [Test]
        public function should_set_port():void
        {
            var expectedResult:int = 54321;

            _sut.port = expectedResult;

            assertThat( _sut.port, equalTo( expectedResult ) );
        }

        [Test]
        public function should_get_server():void
        {
            assertThat( _sut.server, notNullValue() );
            assertThat( _sut.server.hasEventListener( Event.CONNECT ), isTrue() );
            assertThat( _sut.server.hasEventListener( Event.CLOSE ), isTrue() );
        }

        [Test]
        public function should_set_commandProcessor():void
        {
            var expectedResult:ICommandProcessor = new MockCommandProcessor();

            _sut.commandProcessor = expectedResult;

            assertThat( expectedResult.hasEventListener( ProcessedCommandEvent.SUCCESS ), isTrue() );
            assertThat( expectedResult.hasEventListener( ProcessedCommandEvent.ERROR ), isTrue() );
        }

        //Support

        private function onExpectedError( event:ErrorEvent, passThroughData:Object ):void
        {
            assertThat( _sut.server.bound, isFalse() );
            assertThat( _sut.server.listening, isFalse() );

            assertThat( _sut.host, equalTo( passThroughData.host ) );
            assertThat( _sut.host, not( equalTo( _sut.server.localAddress ) ) );

            assertThat( _sut.port, equalTo( passThroughData.port ) );
            assertThat( _sut.port, not( equalTo( _sut.server.localPort ) ) );
        }

        private function onServerRunning( event:Event, passThroughData:Object ):void
        {
            assertThat( _sut.server.bound, isTrue() );
            assertThat( _sut.server.listening, isTrue() );

            assertThat( _sut.host, allOf( equalTo( _sut.server.localAddress ), equalTo( passThroughData.host ) ) );
            assertThat( _sut.port, allOf( equalTo( _sut.server.localPort ), equalTo( passThroughData.port ) ) );
        }
    }
}