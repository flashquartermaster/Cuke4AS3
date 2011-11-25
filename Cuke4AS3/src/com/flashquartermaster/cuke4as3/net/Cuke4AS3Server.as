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
    import com.flashquartermaster.cuke4as3.events.InvokeMethodEvent;
    import com.flashquartermaster.cuke4as3.events.ProcessedCommandEvent;
    import com.flashquartermaster.cuke4as3.reflection.IStepInvoker;
    import com.flashquartermaster.cuke4as3.reflection.IStepMatcher;
    import com.flashquartermaster.cuke4as3.util.CucumberMessageMaker;
    import com.flashquartermaster.cuke4as3.vo.InvokeInfo;
    import com.flashquartermaster.cuke4as3.vo.MatchInfo;
    import com.furusystems.logging.slf4as.global.debug;
    import com.furusystems.logging.slf4as.global.error;
    import com.furusystems.logging.slf4as.global.fatal;
    import com.furusystems.logging.slf4as.global.info;
    import com.furusystems.logging.slf4as.global.warn;

    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.ServerSocket;
    import flash.net.Socket;

    public class Cuke4AS3Server extends EventDispatcher
    {
        private var _server:ServerSocket;
        private var _cucumber:Cucumber;

        private var _commandProcessor:ICommandProcessor;

        private var _host:String;
        private var _port:int;



        public function Cuke4AS3Server()
        {
            if( ServerSocket.isSupported )
            {
                init();
            }
            else
            {
                throw new Error( "Cannot run, ServerSocket is not supported on this platform", Config.SERVER_CANNOT_RUN_ERROR );
            }
        }

        private function init():void
        {
            info( "Cuke4AS3Server : init" );
            _server = new ServerSocket();
            _server.addEventListener( ServerSocketConnectEvent.CONNECT, onConnect );
            _server.addEventListener( Event.CLOSE, onClose );
        }

        public function run():void
        {
            try
            {
                if( _commandProcessor == null )
                {
                    throw new Error("No command processor, cannot process commands");
                }
                
                if( _server == null )
                {
                    init();
                }

                runDebug();

                if( _server.listening && isChangedAddress() )
                {
                    destroyServer();
                    init();
                }

                if( !_server.listening )
                {
                    _server.bind( _port, _host );
                    _server.listen();
                }

                info( "Cuke4AS3Server : running on :", _server.localAddress + ":" + _server.localPort );

                dispatchEvent( new Event( Event.COMPLETE ) );
            }
            catch( e:Error )
            {
                fatal( "Cuke4AS3Server : run :", e, e.getStackTrace() );
                dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.message, Config.SERVER_RUN_ERROR ) );
            }
        }

        //Server events
        private function onConnect( event:ServerSocketConnectEvent ):void
        {
            info( "Cuke4AS3Server : onConnect : Connected to cucumber ", event );

            var socket:Socket = event.socket as Socket;
            // Note: This Class is responsible for maintaining a reference to the client Socket object.
            // If you don't, the object is eligible for garbage collection and may be destroyed by the
            // runtime without warning.
            _cucumber = new Cucumber( socket );

            _cucumber.socket.addEventListener( ProgressEvent.SOCKET_DATA, receiveCucumberData );
            _cucumber.socket.addEventListener( Event.CLOSE, onCucumberClientClose );
            _cucumber.socket.addEventListener( IOErrorEvent.IO_ERROR, onCucumberIOError );
        }

        private function onClose( event:Event ):void
        {
            info( "Cuke4AS3Server : onClose:", event );
        }

        //Socket events

        private function receiveCucumberData( event:ProgressEvent ):void
        {
            var message:String = _cucumber.rawSocketData;

            //Cucumber on windows responds with an additional
            //End Of Transmission and nothing else between steps
            //We need to ignore this in order to proceed
            if( message != Cucumber.EOT )
            {
                var json_decoded:Array = _cucumber.jsonDecodeSocketData();
                var action:String = json_decoded[0];
                var data:Object = json_decoded[1] as Object;
                
                _commandProcessor.processCommand( action,  data );
            }
        }

        private function onCommandProcessedSuccess( event:ProcessedCommandEvent ):void
        {
            sendResultToCucumber( event.result );
        }

        private function onCommandProcessedError( event:ProcessedCommandEvent ):void
        {
            sendResultToCucumber( CucumberMessageMaker.failMessage( event.result[0]) );
        }

        private function sendResultToCucumber( return_array:Array ):void
        {
            _cucumber.jsonEncodeAndSend( return_array );
        }

        private function onCucumberIOError( event:IOErrorEvent ):void
        {
            warn( "Cuke4AS3Server : onCucumberIOError:", event.text );
        }

        private function onCucumberClientClose( event:Event ):void
        {
            info( "Cuke4AS3Server : onCucumberClientClose:", event );
            removeSocketConnection();
        }

        private function isChangedAddress():Boolean
        {
            if( host != _server.localAddress )
            {
                return true;
            }
            if( port != _server.localPort )
            {
                return true;
            }

            return false;
        }

        public function destroy():void
        {
            info("Cuke4AS3Server : destroy");

            destroyServer();
            _host = null;
            _port = 0;
            
            if( _commandProcessor != null)
            {
                _commandProcessor.removeEventListener( ProcessedCommandEvent.SUCCESS, onCommandProcessedSuccess);
                _commandProcessor.removeEventListener( ProcessedCommandEvent.ERROR, onCommandProcessedError);
                _commandProcessor.destroy();
                _commandProcessor = null;
            }
        }

        private function destroyServer():void
        {
            info( "Cuke4AS3Server : destroyServer" );

            //It is possible for the wire file to indicate a different host or port
            //facilitating a destroy and recreation of the server and cucumber sockets
            //but also for cucumber to require no step definitions e.g. where --tags is set but no tags exist
            //and therefore not connect to the server and consequently not create a cucumber socket instance
            //This must be removed

            removeSocketConnection();

            if( _server != null )
            {
                if( _server.listening )
                {
                    _server.close();
                }

                _server.removeEventListener( ServerSocketConnectEvent.CONNECT, onConnect );
                _server.removeEventListener( Event.CLOSE, onClose );
                _server = null;
            }
        }

        private function removeSocketConnection():void
        {
            if( _cucumber != null )
            {
                _cucumber.socket.removeEventListener( ProgressEvent.SOCKET_DATA, receiveCucumberData );
                _cucumber.socket.removeEventListener( Event.CLOSE, onCucumberClientClose );
                _cucumber.socket.removeEventListener( IOErrorEvent.IO_ERROR, onCucumberIOError );
                _cucumber.destroy();
                _cucumber = null;
            }
        }

        public function get server():ServerSocket
        {
            return _server;
        }

        public function get cucumber():Cucumber
        {
            return _cucumber;
        }

        public function get port():int
        {
            return _port;
        }

        public function set port( value:int ):void
        {
            _port = value;
        }

        public function get host():String
        {
            return _host;
        }

        public function set host( value:String ):void
        {
            _host = value;
        }

        public function set commandProcessor( value:ICommandProcessor ):void
        {
            _commandProcessor = value;
            _commandProcessor.addEventListener( ProcessedCommandEvent.SUCCESS, onCommandProcessedSuccess);
            _commandProcessor.addEventListener( ProcessedCommandEvent.ERROR, onCommandProcessedError)
        }

        private function runDebug():void
        {
            debug( "Cuke4AS3Server : run : listening :", _server.listening, ",Changed address :",
                    isChangedAddress(), ",Host :", host, ",Current host :", _server.localAddress,
                    ",Port :", port, ",Current port :", _server.localPort );
        }
    }
}