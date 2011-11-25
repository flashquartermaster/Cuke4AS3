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
package com.flashquartermaster.cuke4as3.net.support
{
    import com.flashquartermaster.cuke4as3.net.Cuke4AS3Server;

    import support.MockCommandProcessor;

    public class Cuke4AS3Server_Fixture_Support
    {
        private var _sut:Cuke4AS3Server;
        private var _o:Object = new Object();

        public function Cuke4AS3Server_Fixture_Support( sut:Cuke4AS3Server, host:String, port:int )
        {
            _sut = sut;
            fixtureSetUpForRunningServer( host, port );
        }

        private function fixtureSetUpForRunningServer( host:String, port:int ):void
        {
            makeHostPortPassThroughData( host, port );
            setHostAndPort();
            setUpCommandProcessor();
        }

        private function setUpCommandProcessor():void
        {
            _sut.commandProcessor = new MockCommandProcessor();
        }

        private function makeHostPortPassThroughData( host:String, port:int ):void
        {
            _o.host = host;
            _o.port = port;
        }

        private function setHostAndPort():void
        {
            _sut.host = _o.host;
            _sut.port = _o.port;
        }

        //Accessors

        public function get passThroughData():Object
        {
            return _o;
        }

    }
}