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
package com.flashquartermaster.cuke4as3.filesystem
{
    import com.flashquartermaster.cuke4as3.vo.ServerInfo;

    import flash.filesystem.File;

    import org.flexunit.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.notNullValue;

    import support.FileHelper;

    public class WireFileParser_Test
	{		
		
		private var _sut:WireFileParser;
		private var _fileHelper:FileHelper;
		
		[Before]
		public function setUp():void
		{
			_sut = new WireFileParser();
			_fileHelper = new FileHelper();
		}
		
		[After]
		public function tearDown():void
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
			assertThat( _sut, instanceOf( WireFileParser ) );
		}
		
		[Test (expects="ArgumentError") ]
		public function should_throw_argument_error_if_wire_file_srcDir_is_null():void
		{
			_sut.getServerInfoFromWireFile( null );
		}
		
		[Test (expects="Error")]
		public function should_throw_error_if_wire_file_srcDir_is_empty():void
		{
			_sut.getServerInfoFromWireFile( "" );
		}
		
		[Test (expects="ArgumentError") ]
		public function should_throw_argument_error_if_wire_file_srcDir_is_invalid():void
		{
			_sut.getServerInfoFromWireFile( "blah" + File.separator + "blah blah" + File.separator );
		}
		
		[Test (expects="Error") ]
		public function tshould_throw_error_if_wire_file_srcDir_is_valid_but_no_wire_file_exists():void
		{
			_sut.getServerInfoFromWireFile( _fileHelper.getValidTmpDirectory() );
		}
	}
}