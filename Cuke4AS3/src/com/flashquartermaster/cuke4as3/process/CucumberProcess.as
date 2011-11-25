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
    import com.flashquartermaster.cuke4as3.Config;
    import com.flashquartermaster.cuke4as3.util.deepTrace;
    import com.furusystems.logging.slf4as.global.info;

    import flash.events.ErrorEvent;
    import flash.filesystem.File;

    public class CucumberProcess extends Process
    {
        private var _cucumberPath:String;

        private var _argValidator:CucumberArgsValidator;

        public function CucumberProcess()
        {
            super();
        }

        override protected function validate():void
        {
            super.validate();

            var cucumber:File = validateFilePath( _cucumberPath, "cucumber" );

            _executable = cucumber;
        }

        override protected function constructCompilerArgs():void
        {
            super.constructCompilerArgs();

            _processArgs.push( _srcDir );

            deepTrace( "CucumberProcess : args :", _processArgs, 1 );

            _argValidator = new CucumberArgsValidator();

            if( !_argValidator.validate( _processArgs ) )
            {
                dispatchEvent( new ErrorEvent( PROCESS_ERROR_EVENT, false, false, "Invalid Arguments: " + additionalArgs, Config.ARGUMENTS_VALIDATION_ERROR ) );
            }
        }

        override public function destroy():void
        {
            info( "CucumberProcess : destroy" );
            super.destroy();

            _cucumberPath = null;

            if( _argValidator != null )
            {
                _argValidator.destroy();
                _argValidator = null;
            }
        }

        //Accessors

        public function get cucumberPath():String
        {
            return _cucumberPath;
        }

        public function set cucumberPath( value:String ):void
        {
            _cucumberPath = value;
        }

        public function get argValidator():CucumberArgsValidator
        {
            return _argValidator;
        }
    }
}