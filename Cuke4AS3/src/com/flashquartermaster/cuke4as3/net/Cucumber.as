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
    import com.adobe.serialization.json.JSON;
    import com.furusystems.logging.slf4as.global.error;
    import com.furusystems.logging.slf4as.global.info;

    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.net.Socket;

    public class Cucumber
    {
        protected var _socket:Socket;
        private var _rawSocketData:String;
        public static var EOT:String = "\n";

        public function Cucumber( socket:Socket )
        {
            _socket = socket;
            _socket.addEventListener( Event.CONNECT, connectHandler );
            _socket.addEventListener( ProgressEvent.SOCKET_DATA, socketDataHandler );
        }

        public function destroy():void
        {
            info( "Cucumber : destroy" );
            if( _socket != null )
            {
                _socket.removeEventListener( Event.CONNECT, connectHandler );
                _socket.removeEventListener( ProgressEvent.SOCKET_DATA, socketDataHandler );
                if( _socket.connected )
                {
                    _socket.close();
                }
                _socket = null;
            }
            _rawSocketData = null;
        }

        public function jsonEncodeAndSend( a:Array ):void
        {
            var encoded:String = JSON.encode( a );
            socket.writeUTFBytes( encoded + EOT );
            socket.flush();
        }

        public function jsonDecodeSocketData():Array
        {
            var ret:Array = new Array();
            try
            {
                ret = JSON.decode( rawSocketData );
            }
            catch( e:Error )
            {
                error( "Cucumber : jsonDecodedSocketData : Error :", e );
            }
            return ret;
        }

        private function connectHandler( event:Event ):void
        {
            info( "Cucumber : connectHandler :", event );
            _rawSocketData = socket.readUTFBytes( socket.bytesAvailable );
        }

        private function socketDataHandler( event:ProgressEvent ):void
        {
            _rawSocketData = socket.readUTFBytes( socket.bytesAvailable );
        }

        public function get rawSocketData():String
        {
            return _rawSocketData;
        }

        public function set rawSocketData( value:String ):void
        {
            _rawSocketData = value;
        }

        public function get socket():Socket
        {
            return _socket;
        }
    }
}