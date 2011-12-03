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
    import com.flashquartermaster.cuke4as3.process.CompilerProcess;
    import com.flashquartermaster.cuke4as3.process.Process;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;

    import features.support.FixtureConfig;

    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.TextEvent;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.isTrue;

    public class Compiler_Steps extends StepsBase
    {
        private var _sut:CompilerProcess;

        private var _goodComplete:Boolean = false;
        private var _errorComplete:Boolean = false;
        private var _goodShellData:Boolean = false;
        private var _errorShellData:Boolean = false;
        private var _codeType:String = "";

        public function Compiler_Steps()
        {
        }

        [Given(/^I have initialised the compiler correctly$/)]
        public function should__initialise_my_compiler_correctly():void
        {
            _sut = new CompilerProcess();
            _sut.init();
            _sut.mxmlcPath = FixtureConfig.MXMLC_EXE;
            //Progress
            _sut.addEventListener( Process.SHELL_DATA_EVENT, onCompilerShellData );
            _sut.addEventListener( Process.SHELL_ERROR_EVENT, onCompilerShellError );
            //Completion
            _sut.addEventListener( Event.COMPLETE, onCompilerProcessComplete );
            _sut.addEventListener( Process.PROCESS_ERROR_EVENT, onCompilerProcessError );
        }

        [When(/^I run the compiler against (good|bad) code$/, "async")]
        public function should_run_the_compiler_against_good_code( codeType:String ):void
        {
            _codeType = codeType;
            if( codeType == "good" )
            {
                _sut.srcDir = FixtureConfig.EXAMPLE_CALCULATOR_DIR;
                Async.proceedOnEvent( this, _sut, Process.SHELL_DATA_EVENT, 5 * 1000 );
            }
            else if( codeType == "bad" )
            {
                _sut.srcDir = FixtureConfig.EXAMPLE_CALCULATOR_BAD_DIR;
                Async.proceedOnEvent( this, _sut, Process.SHELL_ERROR_EVENT, 5 * 1000 );
            }
            else
            {
                throw new Error( "Unknown code type : " + codeType );
            }

            _sut.run();
        }

        [Then(/^compiler reports its progress$/, "async")]
        public function should_it_reports_its_progress():void
        {
            //Extra conditionals are here because the test flickers. This is
            //because process error or complete event can fire before we get
            //to this point :(

            if( _codeType == "good" )
            {
                assertThat( "Reports compiler progress", _goodShellData, isTrue() );
                if( !_goodComplete )
                {
                    Async.proceedOnEvent( this, _sut, Event.COMPLETE, 5 * 1000 );
                }
            }
            else if( _codeType == "bad" )
            {
                assertThat( "Reports error progress", _errorShellData, isTrue() );

                if( !_errorComplete )
                {
                    Async.proceedOnEvent( this, _sut, Process.PROCESS_ERROR_EVENT, 5 * 1000 );
                }
            }
            else
            {
                throw new Error( "Unknown code type : " + _codeType );
            }
        }

        [Then(/^compiler exits cleanly and reports (errors|success)$/)]
        public function should_exit_cleanly_and_report_success_state( result:String ):void
        {
//          Exits cleanly means not exceptions to catch

            if( result == "success" )
            {
                assertThat( "Exits successfully", _goodComplete, isTrue() );
            }
            else if( result == "errors" )
            {
                assertThat( "Exits with errors", _errorComplete, isTrue() );
            }
        }

        [Given(/^I have added valid additional compiler arguments$/)]
        public function should_give_valid_additional_compiler_arguments():void
        {
            _sut.additionalArgs = "-external-library-path+=" + FixtureConfig.FLEX_HOME + "/frameworks/libs/";
        }

        override public function destroy():void
        {
            super.destroy();

            _sut.removeEventListener( Process.SHELL_DATA_EVENT, onCompilerShellData );
            _sut.removeEventListener( Process.SHELL_ERROR_EVENT, onCompilerShellError );
            _sut.removeEventListener( Event.COMPLETE, onCompilerProcessComplete );
            _sut.removeEventListener( Process.PROCESS_ERROR_EVENT, onCompilerProcessError );

            _sut.destroy();
            _sut = null;
        }

        //support

        private function onCompilerProcessComplete( event:Event ):void
        {
            _goodComplete = true;
        }

        private function onCompilerProcessError( event:ErrorEvent ):void
        {
            _errorComplete = true;
        }

        private function onCompilerShellData( event:TextEvent ):void
        {
            _goodShellData = true;
        }

        private function onCompilerShellError( event:TextEvent ):void
        {
            _errorShellData = true;
        }
    }
}
