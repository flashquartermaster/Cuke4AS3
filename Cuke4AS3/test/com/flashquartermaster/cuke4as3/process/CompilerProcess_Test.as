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

    import flash.events.ErrorEvent;

    import org.flexunit.asserts.fail;
    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.core.anyOf;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.text.containsString;

    import support.FileHelper;

    public class CompilerProcess_Test
    {
        private var _sut:CompilerProcess;
        private static var _fileHelper:FileHelper;

        [Before]
        public function setUp():void
        {
            _sut = new CompilerProcess();
            _sut.init();
        }

        [After]
        public function tearDown():void
        {
            _sut.destroy();
            _sut = null;
            _fileHelper.destroy();
        }

        [BeforeClass]
        public static function setUpBeforeClass():void
        {
            _fileHelper = new FileHelper();
        }

        [AfterClass]
        public static function tearDownAfterClass():void
        {
            _fileHelper.destroy();
            _fileHelper = null;
        }

        [Test]
        public function should_construct():void
        {
            assertThat( _sut, notNullValue() );
            assertThat( _sut, instanceOf( CompilerProcess ) );
            assertThat( _sut, instanceOf( Process ) );
            assertThat( _sut, instanceOf( IProcess ) );
        }

        [Test]
        public function should_destroy():void
        {
            _sut.destroy();

            assertThat( _sut.mxmlcPath, nullValue() );
            assertThat( _sut.step_definitionsDirectoryListing, nullValue() );
        }

        //Validate mxmlc path

        [Test(async)]
        public function should_validate_mxmlc_is_null():void
        {
            _sut.srcDir = _fileHelper.getValidTmpDirectory();
            assertThat( _sut.mxmlcPath, nullValue() );

            Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedProcessError );

            _sut.run();
        }

        [Test(async)]
        public function should_validate_mxmlc_is_empty():void
        {
            _sut.srcDir = _fileHelper.getValidTmpDirectory();
            _sut.mxmlcPath = "";

            Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedProcessError );

            _sut.run();
        }

        [Test(async)]
        public function should_validate_mxmlc_is_invalid():void
        {
            _sut.srcDir = _fileHelper.getValidTmpDirectory();
            _sut.mxmlcPath = "/blah/blah blah/mxmlc";

            Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedProcessError );

            _sut.run();
        }

        private function onExpectedProcessError( event:ErrorEvent, passThroughData:Object ):void
        {
            assertThat( event.errorID, equalTo( Config.VALIDATION_ERROR ) );
            assertThat( event.text, anyOf( containsString( "mxmlc must be set" ), containsString( "Path to mxmlc \"" ) ) );
        }

        [Test(async)]
        public function should_validate_mxmlc_is_valid():void
        {
            assertThat( _sut.mxmlcPath, nullValue() );

            _sut.srcDir = _fileHelper.getValidTmpDirectory();
            _sut.mxmlcPath = _fileHelper.getMockValidMxmlcExecutable();

            //Will still get a validation error but a differnet one
            Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedPostMxmlcValidationProcessError );

            _sut.run();
        }

        //Validate path to step_definitions

        [Test(async)]
        public function should_validate_step_definitions_is_invalid():void
        {
            _sut.srcDir = _fileHelper.getValidTmpDirectory();
            _sut.mxmlcPath = _fileHelper.getMockValidMxmlcExecutable();

            Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedPostMxmlcValidationProcessError );

            _sut.run();
        }

        private function onExpectedPostMxmlcValidationProcessError( event:ErrorEvent, passThroughData:Object ):void
        {
            assertThat( event.errorID, equalTo( Config.VALIDATION_ERROR ) );
            assertThat( event.text, containsString( "Path to steps_directory \"" ) );
        }

        [Test(async)]
        public function should_validate_step_definitions_is_valid():void
        {
            _sut.srcDir = _fileHelper.getValidTmpDirectory();
            _sut.mxmlcPath = _fileHelper.getMockValidMxmlcExecutable();

            _fileHelper.makeValidfeaturesAndSteps();

            Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedPostStepsDirectoryProcessError );

            _sut.run();
        }

        private function onExpectedPostStepsDirectoryProcessError( event:ErrorEvent, passThroughData:Object ):void
        {
            assertThat( event.errorID, equalTo( Config.VALIDATION_ERROR ) );
            assertThat( event.text, anyOf( containsString( "Error #3214" ), containsString( "Error #3219" ) ) );
        }

        //Validate compiler args

        [Ignore("mxmlc currently validates the compiler args and reports back")]
        [Test]
        public function should_NOT_raise_argument_validation_error_if_args_are_invalid():void
        {
            fail( "Not yet implemented" );
        }

        [Ignore("mxmlc currently validates the compiler args and reports back")]
        [Test]
        public function should_raise_argument_validation_error_if_args_are_invalid():void
        {
            fail( "Not yet implemented" );
        }

        [Ignore("Todo")]
        [Test]
        public function should_exit_shell_correctly():void
        {
            fail( "Not yet implemented" );
        }

        [Ignore("Todo")]
        [Test(async)]
        public function should_exit_shell_with_compiler_errors_cleanly():void
        {
            //note exit code is the amount of errors
            fail( "Not yet implemented" );
        }

        [Ignore("Todo")]
        [Test(async)]
        public function should_exit_shell_with_unknown_exit_code_cleanly():void
        {
            fail( "Not yet implemented" );
        }

        [Ignore("Todo")]
        [Test(async)]
        public function should_exit_shell_with_forced_exit_cleanly():void
        {
            //exit code isNan()
            fail( "Not yet implemented" );
        }

        //Accessors

        [Test]
        public function should_get_directoryListing():void
        {
            assertThat( _sut.step_definitionsDirectoryListing, nullValue() );
        }

        [Test]
        public function should_get_isUseBundledDConsole():void
        {
            assertThat( _sut.isUseBundledDConsole, isTrue() );
        }

        [Test]
        public function should_set_isUseBundledDConsole():void
        {
            _sut.isUseBundledDConsole = false;
            assertThat( _sut.isUseBundledDConsole, isFalse() );
        }

        [Test]
        public function should_get_isUseBundledFlexUnit():void
        {
            assertThat( _sut.isUseBundledFlexUnit, isTrue() );
        }

        [Test]
        public function should_set_isUseBundledFlexUnit():void
        {
            _sut.isUseBundledFlexUnit = false;
            assertThat( _sut.isUseBundledFlexUnit, isFalse() );
        }

        [Test]
        public function should_get_mxmlcPath():void
        {
            assertThat( _sut.mxmlcPath, nullValue() );
        }

        [Test]
        public function should_set_mxmlcPath():void
        {
            var s:String = "/blah/blah blah/mxmlc";
            _sut.mxmlcPath = s;
            assertThat( _sut.mxmlcPath, equalTo( s ) );
        }
    }
}