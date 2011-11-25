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
    import com.flashquartermaster.cuke4as3.process.CucumberProcess;
    import com.flashquartermaster.cuke4as3.process.Process;
    import com.flashquartermaster.cuke4as3.utilities.Pending;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;
    import com.furusystems.logging.slf4as.global.fatal;

    import features.support.FixtureConfig;

    import flash.events.Event;
    import flash.system.Capabilities;
    import flash.system.System;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.isTrue;

    public class Cucumber_Steps extends StepsBase
    {
        private var _sut:CucumberProcess;

        private var _goodComplete:Boolean = false;
        private var _errorComplete:Boolean = false;
        private var _goodShellData:Boolean = false;
        private var _errorShellData:Boolean = false;
        
        private var _isErrorCase:Boolean = false;

        public function Cucumber_Steps()
        {
        }

        [Given(/^I have initialised cucumber correctly$/)]
        public function should_initialise_correctly():void
        {
            _sut = new CucumberProcess();
            _sut.init();
            _sut.cucumberPath = FixtureConfig.CUCUMBER_EXE;

            if( Capabilities.os.indexOf("Windows") != -1 )
            {
                _sut.additionalArgs = FixtureConfig.WIN_CUCUMBER_EXE;
            }

            _sut.addEventListener( Event.COMPLETE, onCucumberProcessComplete );
            _sut.addEventListener( Process.SHELL_DATA_EVENT, onCucumberShellData );
            _sut.addEventListener( Process.SHELL_ERROR_EVENT, onCucumberShellError );
            _sut.addEventListener( Process.PROCESS_ERROR_EVENT, onCucumberProcessError );
        }

        [When(/^I run cucumber with a valid directory structure and files$/, "async")]
        public function should_run_with_a_valid_directory_structure_and_files():void
        {
            // Use a dir with no wire file so it does not try to connect to the wire
            // server while self testing. We are only interested in progress from cucumber
            _sut.srcDir = FixtureConfig.EXAMPLE_CALCULATOR_NO_WIRE_DIR;
            Async.proceedOnEvent( this, _sut, Process.SHELL_DATA_EVENT, 5 * 1000 );
            _sut.run();
        }

        [Then(/^cucumber reports its progress$/, "async")]
        public function should_report_progress():void
        {
            if(!_isErrorCase ){
                assertThat( "Reports cucumber progress", _goodShellData, isTrue() );
                if( !_goodComplete )
                {
                    Async.proceedOnEvent( this, _sut, Event.COMPLETE, 2 * 1000 );
                }
            }
            else
            {
                assertThat( "Reports cucumber error progress", _errorShellData, isTrue() );
                if( !_errorComplete )
                {
                    Async.proceedOnEvent( this, _sut, Process.PROCESS_ERROR_EVENT, 2 * 1000 );
                }
            }
        }

        [Then(/^cucumber exits cleanly and reports (success|errors)$/)]
        public function should_exit_cleanly_and_report_status( result:String ):void
        {
            if( result == "success" )
            {
                assertThat( "Exits successfully", _goodComplete, isTrue() );
            }
            else if( result == "errors" )
            {
                assertThat( "Exits with errors", _errorComplete, isTrue() );
            }
        }

        

        [When(/^I run the cucumber against erroneous steps$/,"async")]
        public function should_run_against_erroneous_steps():void
        {
            _isErrorCase = true;
            _sut.srcDir = FixtureConfig.EXAMPLE_CALCULATOR_BAD_DIR;
            Async.proceedOnEvent( this, _sut, Process.SHELL_ERROR_EVENT, 5 * 1000 );
            _sut.run();
        }

        [Given(/^I have added valid additional cucumber arguments$/)]
        public function should_have_valid_additional_arguments():void
        {
            var args:String = "";

            if( Capabilities.os.indexOf("Windows") != -1 )
            {
                args += FixtureConfig.WIN_CUCUMBER_EXE + " ";
            }

            args += "-f pretty -f html -o cucumber_steps_output.html";

            _sut.additionalArgs = args;
        }

        override public function destroy():void
        {
            super.destroy();

            _sut.removeEventListener( Event.COMPLETE, onCucumberProcessComplete );
            _sut.removeEventListener( Process.SHELL_DATA_EVENT, onCucumberShellData );
            _sut.removeEventListener( Process.SHELL_ERROR_EVENT, onCucumberShellError );
            _sut.removeEventListener( Process.PROCESS_ERROR_EVENT, onCucumberProcessError );
            _sut.destroy();
            _sut = null;
        }

        //Support
        private function onCucumberProcessComplete( event:Event ):void
        {
            fatal( "onCucumberProcessComplete" );
            _goodComplete = true;
        }

        private function onCucumberShellData( event:Event ):void
        {
            fatal( "onCucumberShellData" );
            _goodShellData = true;
        }

        private function onCucumberShellError( event:Event ):void
        {
            fatal( "onCucumberShellError" );
            _errorShellData = true;
        }

        private function onCucumberProcessError( event:Event ):void
        {
            fatal( "onCucumberProcessError" );
            _errorComplete = true;
        }
    }
}
