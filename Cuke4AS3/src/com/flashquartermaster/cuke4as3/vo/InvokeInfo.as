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
    public class InvokeInfo
    {
        private var _errorMessage:String;
        private var _errorName:String;
        private var _errorTrace:String;

        private var _pendingMessage:String;

        public function InvokeInfo()
        {
        }

        public function isError():Boolean
        {
            return _errorMessage != null;
        }

        public function isPending():Boolean
        {
            return _pendingMessage != null;
        }

        public function isSuccess():Boolean
        {
            return ( !isError() && !isPending() );
        }

        public function destroy():void
        {
            _errorMessage = null;
            _errorName = null;
            _errorTrace = null;
            _pendingMessage = null;
        }

        public function get errorMessage():String
        {
            return _errorMessage;
        }

        public function set errorMessage( value:String ):void
        {
            _errorMessage = value;
        }

        public function get errorName():String
        {
            return _errorName;
        }

        public function set errorName( value:String ):void
        {
            _errorName = value;
        }

        public function get errorTrace():String
        {
            return _errorTrace;
        }

        public function set errorTrace( value:String ):void
        {
            _errorTrace = value;
        }

        public function get pendingMessage():String
        {
            return _pendingMessage;
        }

        public function set pendingMessage( value:String ):void
        {
            _pendingMessage = value;
        }
    }
}
