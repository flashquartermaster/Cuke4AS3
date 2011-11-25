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
    import flash.filesystem.File;

    import mx.rpc.xml.SchemaTypeRegistry;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;

    public class CucumberArgsValidator_Test
    {
        private var _sut:CucumberArgsValidator;

        private var _htmlFilePath:String;

		[Before]
		public function setUp():void
		{
			_sut = new CucumberArgsValidator();
            _htmlFilePath = File.applicationDirectory.nativePath + File.separator + "cucumber_args_validator_output.html";
		}

		[After]
		public function tearDown():void
		{
			_sut.destroy();
			_sut = null;
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
			assertThat( _sut, instanceOf( CucumberArgsValidator ) );
			assertThat( _sut, instanceOf( IArgsValidator ) );
		}
        
        [Test]
        public function should_destroy():void
        {
            _sut.destroy();
        }
        
        [Test]
        public function should_validate_valid_args():void
        {
            var args:Vector.<String> = getHtmlAndJunitArgs();
            
            var result:Boolean = _sut.validate( args );
            
            assertThat( result,  isTrue() );
        }

        [Test]
        public function should_return_null_if_not_html_output_file():void
        {
            var args:Vector.<String> = new Vector.<String>();
            
            var valid:Boolean = _sut.validate( args );
            
            assertThat( valid,  isTrue() );
            
            var result:String = _sut.htmlFilePath;
            
            assertThat( result,  nullValue() );
        }

        [Test]
        public function should_get_html_output_path():void
        {
            var args:Vector.<String> = getHtmlAndJunitArgs();

            var valid:Boolean = _sut.validate( args );

            assertThat( valid,  isTrue() );

            var path:String = _sut.htmlFilePath;

            assertThat( path,  equalTo( _htmlFilePath ) );
        }
        
        //Support

        private function getHtmlAndJunitArgs():Vector.<String>
        {
            var args:Vector.<String> = new Vector.<String>();
            args.push( "-f" );
            args.push( "html" );
            args.push( "-o" );
            args.push( _htmlFilePath );
            args.push( "-f" );
            args.push( "junit" );
            args.push( "-o" );
            args.push( "output" );
            return args;
        }
    }
}
