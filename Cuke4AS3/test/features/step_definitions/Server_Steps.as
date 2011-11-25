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
package features.step_definitions
{
    import com.flashquartermaster.cuke4as3.net.Cuke4AS3Server;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;
    import com.flashquartermaster.cuke4as3.utilities.Table;

    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.Socket;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.core.allOf;
    import org.hamcrest.core.not;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.text.containsString;

    import support.MockCommandProcessor;

    public class Server_Steps extends StepsBase
    {
        private var _sut:Cuke4AS3Server;

        private var _mockCucumber:Socket;

        private var _error:Boolean = false;
        private var _running:Boolean = false;

        private var _newHost:String;
        private var _newPort:int;

        public function Server_Steps()
        {
        }

        [Given(/^I have initialised the server on:$/)]
        public function should__initialise_the_server( array:Array ):void
        {
            var table:Table = new Table( array );

            _sut = new Cuke4AS3Server();
            _sut.commandProcessor = new MockCommandProcessor();

            _sut.host = table.getRowItemByHeader( "host", 0 );
            _sut.port = int( table.getRowItemByHeader( "port", 0 ) );

            _sut.addEventListener( ErrorEvent.ERROR, onServerError );
            _sut.addEventListener( Event.COMPLETE, onServerRunning );

        }

        [When(/^I run the server$/, "async")]
        public function server_should_run():void
        {
            Async.proceedOnEvent( this, _sut, Event.COMPLETE, 1 * 1000 );
            Async.failOnEvent( this, _sut, ErrorEvent.ERROR );
            _sut.run();
        }

        [Then(/^it reports that it is running successfully$/)]
        public function should_report_status():void
        {
            assertThat( _running, isTrue() );
            assertThat( _sut.server.bound, isTrue() );
            assertThat( _sut.server.listening, isTrue() );
        }

        [Given(/^it is running successfully$/, "async")]
        public function should_run_successfully():void
        {
            Async.proceedOnEvent( this, _sut, Event.COMPLETE, 1 * 1000 );
            Async.failOnEvent( this, _sut, ErrorEvent.ERROR );
            _sut.run();
        }

        [When(/^cucumber connects to it$/, "async")]
        public function cucumber_should_connect():void
        {
            _mockCucumber = new Socket();

            Async.proceedOnEvent( this, _sut.server, ServerSocketConnectEvent.CONNECT );

            _mockCucumber.connect( _sut.host, _sut.port );
        }

        [Then(/^cucumber communicates with the server$/, "async")]
        public function cucumber_should_communicate_with_the_server():void
        {
//            The cucumber socket reference in the server is our mock cucumber reference

            assertThat( "Server Bound", _sut.server.bound, isTrue() );
            assertThat( "Listening", _sut.server.listening, isTrue() );
            assertThat( "Socket reference not null", _sut.cucumber.socket, notNullValue() );
            assertThat( "Socket connected", _mockCucumber.connected, isTrue() );
            assertThat( "socket connected (server reference)", _sut.cucumber.socket.connected, isTrue() );

            var passThoughData:Object = new Object();
            passThoughData.content = "Hello Wire Server!";
            passThoughData.message = "[\"" + passThoughData.content + "\",{}]\n";

            Async.handleEvent( this, _sut.cucumber.socket, ProgressEvent.SOCKET_DATA, onDataFromCucumber, 500, passThoughData );

            Async.handleEvent( this, _mockCucumber, ProgressEvent.SOCKET_DATA, onServerResponse, 500, passThoughData );

            _mockCucumber.writeUTFBytes( passThoughData.message );
            _mockCucumber.flush();
        }

        [When(/^cucumber closes its connection$/, "async")]
        public function cucumber_should_close_connection():void
        {
            Async.proceedOnEvent( this, _sut.cucumber.socket, Event.CLOSE );
            _mockCucumber.close();

        }

        [When(/^cucumber reconnects to it$/, "async")]
        public function cucumber_should_cucumber_reconnect():void
        {
            _mockCucumber = null;
            _mockCucumber = new Socket();

            Async.proceedOnEvent( this, _sut.server, ServerSocketConnectEvent.CONNECT );

            _mockCucumber.connect( _sut.host, _sut.port );
        }

        [When(/^I specify a different (.*) of (.*)$/)]
        public function should_specify_different_info( item:String, value:String ):void
        {
            var port:int;

            if( item == "host" )
            {
                assertChangedServerValue( value, _sut.host, _sut.server.localAddress );

                _sut.host = value;
                _newHost = value;
            }
            else if( item == "port" )
            {
                port = int( value );

                assertChangedServerValue( port, _sut.port, _sut.server.localPort );

                _sut.port = port;
                _newPort = port;
            }
            else if( item == "host & port" )
            {
                var array:Array = value.split( ":" );
                var host:String = array[0];
                port = int( array[1] );

                assertChangedServerValue( host, _sut.host, _sut.server.localAddress );

                assertChangedServerValue( port, _sut.port, _sut.server.localPort );

                _sut.host = host;
                _newHost = host;

                _sut.port = port;
                _newPort = port;
            }
            else
            {
                throw new Error( "Unknown item: " + item );
            }
        }

        [Then(/^the server listens on (.*) (.*)$/)]
        public function should_listen_on( item:String, value:String ):void
        {
            assertThat( "Server Bound", _sut.server.bound, isTrue() );
            assertThat( "Listening", _sut.server.listening, isTrue() );

            var port:int;

            if( item == "host" )
            {
                assertNewServerValues( "Host", _sut.server.localAddress, _sut.host, _newHost );
            }
            else if( item == "port" )
            {
                port = int( value );

                assertNewServerValues( "Host", _sut.server.localPort, _sut.port, _newPort );
            }
            else if( item == "host & port" )
            {
                var array:Array = value.split( ":" );
                var host:String = array[0];
                port = int( array[1] );

                assertNewServerValues( "Host", _sut.server.localAddress, _sut.host, _newHost );
                assertNewServerValues( "Host", _sut.server.localPort, _sut.port, _newPort );
            }
            else
            {
                throw new Error( "Unknown item: " + item );
            }
        }

        override public function destroy():void
        {
            super.destroy();

            if( _mockCucumber != null )
            {
                if( _mockCucumber.connected )
                {
                    _mockCucumber.close();
                }
                _mockCucumber = null;
            }

            _sut.removeEventListener( ErrorEvent.ERROR, onServerError );
            _sut.removeEventListener( Event.COMPLETE, onServerRunning );
            _sut.destroy();
            _sut = null;
        }

//        Support

        private function onServerError( event:ErrorEvent ):void
        {
            _error = true;
        }

        private function onServerRunning( event:Event ):void
        {
            _running = true;
        }

        private function onDataFromCucumber( event:ProgressEvent, passThroughData:Object ):void
        {
            assertThat( _sut.cucumber.rawSocketData, equalTo( passThroughData.message ) );
        }

        private function onServerResponse( event:ProgressEvent, passThroughData:Object ):void
        {
            var socket:Socket = ( event.target as Socket );
            var result:String = socket.readUTFBytes( socket.bytesAvailable );

            assertThat( result,
                    allOf( containsString( "fail" ),
                            containsString( "Unknown Command" ),
                            containsString( passThroughData.content ) ) );
        }

        private function assertChangedServerValue( value:*, expected1:*, expected2:* ):void
        {
            assertThat( value, allOf(
                    not( equalTo( expected1 ) ),
                    not( equalTo( expected2 ) )
            ) );
        }

        private function assertNewServerValues( identifier:String, result:*, expected1:*, expected2:* ):void
        {
            assertThat( identifier, result, allOf(
                    equalTo( expected1 ),
                    equalTo( expected2 ) )
            );
        }
    }
}
