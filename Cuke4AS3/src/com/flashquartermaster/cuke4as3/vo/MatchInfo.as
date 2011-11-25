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
    public class MatchInfo
    {
        private var _errorMessage:String;

        private var _id:int = -1;
        private var _args:Array;
        private var _className:String;
        private var _regExp:String;

        public function MatchInfo()
        {
        }

        public function isError():Boolean
        {
            return _errorMessage != null;
        }

        public function isMatch():Boolean
        {
            return _id > -1;
        }

        public function isUndefined():Boolean
        {
            return ( !isError() && !isMatch() );
        }

        public function destroy():void
        {
            _errorMessage = null;
            _id = -1;
            _args = null;
            _className = null;
            _regExp = null;
        }

        public function get errorMessage():String
        {
            return _errorMessage;
        }

        public function set errorMessage( value:String ):void
        {
            _errorMessage = value;
        }

        public function get id():int
        {
            return _id;
        }

        public function set id( value:int ):void
        {
            _id = value;
        }

        public function get args():Array
        {
            return _args;
        }

        public function set args( value:Array ):void
        {
            _args = value;
        }

        public function get className():String
        {
            return _className;
        }

        public function set className( value:String ):void
        {
            _className = value;
        }

        public function get regExp():String
        {
            return _regExp;
        }

        public function set regExp( value:String ):void
        {
            _regExp = value;
        }
    }
}
