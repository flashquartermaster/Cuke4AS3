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
    import org.hamcrest.assertThat;
    import org.hamcrest.core.not;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.nullValue;

    public class InvokeArgumentsProcessor_Test
	{		
		private var _sut:InvokeArgumentsProcessor;
		
		[Before]
		public function setUp():void
		{
			_sut = new InvokeArgumentsProcessor();
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
			_sut = null;
			_sut = new InvokeArgumentsProcessor();
			
			assertThat( _sut, not( nullValue() ) );
			assertThat( _sut, instanceOf( InvokeArgumentsProcessor ) );
		}
		
		[Test]
		public function should_process_arguments_when_valid():void
		{
			var srcDir:String = "/Users/coxent01/Documents/Adobe Flash Builder 4.5/Cuke4AS3/src";
			var mxmlc:String = "/Applications/Adobe Flash Builder 4.5/sdks/4.5.0/bin/mxmlc";
			var cucumber:String = "/usr/bin/cucumber";
			var headless:String = "true";
			var mxmlcArgs:String = "'-compiler.library-path '/Users/coxent01/Documents/Adobe Flash Builder 4.5/TestEmpBase/libs/EMF.swc'";
			var cucumberArgs:String = "'--tags @testtag -f html -o /Users/coxent01/Desktop/cuke4AS3.html'";
			
			var success:Boolean = _sut.processArguments( getArgs(srcDir, mxmlc, cucumber, headless, mxmlcArgs, cucumberArgs ) );
			
			assertThat( success, isTrue() );
			
			assertThat( _sut.srcDir, equalTo( srcDir ) );
			assertThat( _sut.mxmlc, equalTo( mxmlc ) );
			assertThat( _sut.cucumber, equalTo( cucumber ) );
			assertThat( _sut.headless, equalTo( headless ) );
			assertThat( _sut.mxmlcArgs, equalTo( mxmlcArgs ) );
			assertThat( _sut.cucumberArgs, equalTo( cucumberArgs ) );
		}
		
		[Test]
		public function should_destroy():void
		{			
			var success:Boolean = _sut.processArguments( getArgs("", "", "", "", "", "" ) );
			
			assertThat( success, isTrue() );
			
			_sut.destroy();
			
			assertThat( _sut.srcDir, nullValue() );
			assertThat( _sut.mxmlc, nullValue() );
			assertThat( _sut.cucumber, nullValue() );
			assertThat( _sut.headless, nullValue() );
			assertThat( _sut.mxmlcArgs, nullValue() );
			assertThat( _sut.cucumberArgs, nullValue() );
		}
		
		[Test]
		public function should_return_false_if_args_are_null():void
		{
			var success:Boolean = _sut.processArguments( null );
			assertThat( success, isFalse() );
		}
		
		[Test]
		public function should_return_false_if_args_are_empty():void
		{
			var success:Boolean = _sut.processArguments( [] );
			assertThat( success, isFalse() );
		}
		
		[Test]
		public function should_return_false_if_invalid_argument_no_hyphen_in_processArguments():void
		{
			var args:Array = [];
			args.push( "srcDir" );
			args.push( "/Users/coxent01/Documents/Adobe Flash Builder 4.5/Cuke4AS3/src" );
			
			var success:Boolean = _sut.processArguments( args );
			assertThat( success, isFalse() );
			
			assertThat( _sut.srcDir, nullValue() );
		} 
		
		[Test]
		public function should_return_false_if_argument_has_no_accessor_in_processArguments():void
		{
			var args:Array = [];
			args.push( "-NotAnArg" );
			args.push( "Not an arg value" );
			
			var success:Boolean = _sut.processArguments( args );
			assertThat( success, isFalse() );
		} 
		//Accessors
		
		[Test]
		public function should_get_cucumber():void
		{
			var s:String = _sut.cucumber;
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_cucumber():void
		{
			var s:String = "/blah/blah blah/blah/cucumber";
			_sut.cucumber = s;
			assertThat( _sut.cucumber, equalTo( s ) );
		}
		
		[Test]
		public function should_get_cucumberArgs():void
		{
			var s:String = _sut.cucumberArgs;
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_cucumberArgs():void
		{
			var s:String = "--tags @foo @bar -f html";
			_sut.cucumberArgs = s;
			assertThat( _sut.cucumberArgs, equalTo( s ) );
		}
		
		[Test]
		public function should_get_headless():void
		{
			var s:String = _sut.headless;
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_headless():void
		{
			var s:String = "true";
			_sut.headless = s;
			assertThat( _sut.headless, equalTo( s ) );
		}
		
		[Test]
		public function should_get_mxmlc():void
		{
			var s:String = _sut.mxmlc;
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_mxmlc():void
		{
			var s:String = "/blah/blah blah/blah/mxmlc";
			_sut.mxmlc = s;
			assertThat( _sut.mxmlc, equalTo( s ) );
		}
		
		[Test]
		public function should_get_mxmlcArgs():void
		{
			var s:String = _sut.mxmlcArgs;
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_mxmlcArgs():void
		{
			var s:String = "'-compiler.library-path '/blah/blah blah/blah/some.swc''";
			_sut.mxmlcArgs = s;
			assertThat( _sut.mxmlcArgs, equalTo( s ) );
		}
		
		[Test]
		public function should_get_srcDir():void
		{
			var s:String = _sut.srcDir;
			assertThat( s, nullValue() );
		}
		
		[Test]
		public function should_set_srcDir():void
		{
			var s:String = "/blah/blah blah/blah/src";
			_sut.srcDir = s;
			assertThat( _sut.srcDir, equalTo( s ) );
		}
		
		//Support
		
		private function getArgs(srcDir:String, mxmlc:String, cucumber:String, headless:String, mxmlcArgs:String, cucumberArgs:String ):Array
		{
			//-srcDir "/Users/aUser/Documents/Adobe Flash Builder 4.5/Cuke4AS3/src" 
			//-mxmlc "/Applications/Adobe Flash Builder 4.5/sdks/4.5.0/bin/mxmlc" 
			//-cucumber "/usr/bin/cucumber" -headless true 
			//-mxmlcArgs "'-compiler.library-path '/Users/aUser/Documents/Adobe Flash Builder 4.5/TestEmpBase/libs/EMF.swc'" 
			//-cucumberArgs "'--tags @testtag -f html -o /Users/aUser/Desktop/cuke4AS3.html'"
			
			var args:Array = [];
			args.push( "-srcDir" );
			args.push( srcDir );
			args.push( "-mxmlc" );
			args.push( mxmlc );
			args.push( "-cucumber" );
			args.push( cucumber );
			args.push( "-headless" );
			args.push( headless );
			args.push( "-mxmlcArgs" );
			args.push( mxmlcArgs );
			args.push( "-cucumberArgs" );
			args.push( cucumberArgs );
			
			return args;
		}
	}
}