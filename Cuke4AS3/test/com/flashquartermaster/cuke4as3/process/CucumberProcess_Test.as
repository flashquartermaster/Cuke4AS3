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
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.text.containsString;

    import support.FileHelper;

    public class CucumberProcess_Test
	{		
		private var _sut:CucumberProcess;
		private static var _fileHelper:FileHelper;
		
		[Before]
		public function set_up():void
		{
			_sut = new CucumberProcess();
			_sut.init();
            _fileHelper = new FileHelper();
		}
		
		[After]
		public function tear_down():void
		{
			_sut.destroy();
			_sut = null;
            _fileHelper.destroy();
			_fileHelper = null;
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function should_construct():void
		{
			assertThat( _sut, notNullValue() );
			assertThat( _sut, instanceOf( CucumberProcess ) );
			assertThat( _sut, instanceOf( Process ) );
			assertThat( _sut, instanceOf( IProcess ) );
		}
		
		[Test]
		public function should_destroy():void
		{
			_sut.destroy();
			
			assertThat( _sut.cucumberPath, nullValue() );
		}
		
		//Validate cucumber path
		
		[Test (async) ]
		public function should_raise_validation_error_if_cucumber_path_is_null():void
		{	
			_sut.srcDir = _fileHelper.getValidTmpDirectory();
			assertThat( _sut.cucumberPath, nullValue() );
			
			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedProcessError);
			
			_sut.run();
		}
		
		[Test (async) ]
		public function should_raise_validation_error_if_cucumber_path_is_an_empty_string():void
		{
			_sut.srcDir = _fileHelper.getValidTmpDirectory();
			_sut.cucumberPath = "";
			
			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedProcessError);
			
			_sut.run();
		}
		
		[Test (async) ]
		public function should_raise_validation_error_if_cucumber_path_is_invalid():void
		{
			_sut.srcDir = _fileHelper.getValidTmpDirectory();
			_sut.cucumberPath = "/blah/blah blah/cucumber";
			
			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedProcessError);
			
			_sut.run();
		}

        [Ignore("Not yet fully working")]
        [Test(async)]
        public function should_raise_argument_validation_error_if_args_are_invalid():void
        {
            _sut.srcDir = _fileHelper.getValidTmpDirectory();			
			_sut.cucumberPath = _fileHelper.getMockValidCucumberExecutable();
            _sut.additionalArgs = "-bollox true";

			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedArgumentValidationError);
			
			_sut.run();
        }

        [Ignore( "mxmlc currently validates the compiler args and reports back" )]
		[Test]
		public function should_NOT_raise_argument_validation_error_if_args_are_invalid():void
		{
			fail( "Not yet implemented" );
		}
        
		private function onExpectedProcessError( event:ErrorEvent, passThroughData:Object):void
		{
			assertThat( event.errorID, equalTo( Config.VALIDATION_ERROR ) );
			assertThat( event.text, anyOf( containsString("cucumber must be set"), containsString("Path to cucumber \"") ) );
		}
		
		[Test (async) ]
		public function should_not_raise_validation_error_if_cucumber_path_is_valid():void
		{
			_sut.srcDir = _fileHelper.getValidTmpDirectory();
			
			assertThat( _sut.cucumberPath, nullValue() );
			
			_sut.cucumberPath = _fileHelper.getMockValidCucumberExecutable();
			
			//Will still get a validation error but a different one
			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedValidationError);
			
			_sut.run();
		}
		
		private function onExpectedValidationError( event:ErrorEvent, passThroughData:Object):void
		{
			assertThat( event.errorID, equalTo( Config.VALIDATION_ERROR ) );
			assertThat( event.text, anyOf( containsString( "Error #3214"), containsString("Error #3219") ) );
		}

        private function onExpectedArgumentValidationError( event:ErrorEvent, passThroughData:Object ):void
        {
            assertThat( event.errorID, equalTo( Config.ARGUMENTS_VALIDATION_ERROR ) );
			assertThat( event.text, containsString( "-bollox true") );
        }
		//Accessors
		
		[Test]
		public function should_get_cucumberPath():void
		{
			assertThat( _sut.cucumberPath, nullValue() );
		}
		
		[Test]
		public function should_set_cucumberPath():void
		{
			var s:String = "/blah/blah blah/cucumber";
			_sut.cucumberPath = s;
			assertThat( _sut.cucumberPath, equalTo( s ) );
		}
		
		[Test]
		public function should_get_srcDir():void
		{
			assertThat( _sut.srcDir, nullValue() );
		}
		
		[Test]
		public function should_set_srcDir():void
		{
			var s:String = "/blah/blah blah/src";
			_sut.srcDir = s;
			assertThat( _sut.srcDir, equalTo( s ) );
		}

        [Test(async)]
        public function should_get_argument_validator():void
        {
            assertThat( _sut.argValidator,  nullValue() );
            
            _sut.srcDir = _fileHelper.getValidTmpDirectory();			
			_sut.cucumberPath = _fileHelper.getMockValidCucumberExecutable();
            _sut.additionalArgs = "- pretty -f html -o cucumber_process_test_output.html";

			Async.handleEvent( this, _sut, Process.PROCESS_ERROR_EVENT, onExpectedValidationError);
			
			_sut.run();

            assertThat( _sut.argValidator, notNullValue() );
        }
    }
}