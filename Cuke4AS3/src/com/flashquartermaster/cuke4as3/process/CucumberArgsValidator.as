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
package com.flashquartermaster.cuke4as3.process
{
    import com.furusystems.logging.slf4as.global.debug;

    import flash.filesystem.File;

    public class CucumberArgsValidator implements IArgsValidator
    {
        private var _args:Vector.<String>;
        
        private var _htmlFilePath:String;

        public function CucumberArgsValidator()
        {
        }

        public function validate( args:Vector.<String> ):Boolean
        {
            _args = args;
            return true;
        }
        
        public function get htmlFilePath():String
        {
            setHtmlOutput();
            return _htmlFilePath;
        }

        public function destroy():void
        {
            _args = null;
            _htmlFilePath = null;
        }

        private function setHtmlOutput():void
        {
            var i:uint;
            var len:uint = _args.length;
            var arg:String;

            var isFormat:Boolean = false;
            var isHtml:Boolean = false;
            var isOutput:Boolean = false;

            while(i < len )
            {
                arg = _args[i].toLowerCase();

                if( isOutput )
                {
                    _htmlFilePath = _args[i];//Or file path is to lower case
                    break;
                }
                else if(isFormat && !isHtml )
                {
                    isHtml = ( arg == "html");
                }
                else if( isFormat && isHtml )
                {
                    isOutput = ( arg == "-o" || arg == "-out");
                }
                else
                {
                    isFormat = ( arg == "-f" || arg == "-format");
                }

                i++;
            }
        }
    }
}
