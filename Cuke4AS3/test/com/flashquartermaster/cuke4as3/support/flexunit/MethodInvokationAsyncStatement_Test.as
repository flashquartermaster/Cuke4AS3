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
package com.flashquartermaster.cuke4as3.support.flexunit
{
    import org.flexunit.assertThat;
    import org.flexunit.internals.runners.statements.AsyncStatementBase;
    import org.flexunit.internals.runners.statements.IAsyncStatement;
    import org.flexunit.token.AsyncTestToken;
    import org.flexunit.token.ChildResult;
    import org.hamcrest.collection.array;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.object.strictlyEqualTo;

    public class MethodInvokationAsyncStatement_Test
	{		
		private var _sut:MethodInvokationAsyncStatement;
		private var _asyncTestToken:AsyncTestToken;
		
		[Before]
		public function setUp():void
		{
			_sut = new MethodInvokationAsyncStatement();
		}
		
		[After]
		public function tearDown():void
		{
			if( _asyncTestToken != null )
			{
				_asyncTestToken = null;
			}
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
			assertThat( _sut, instanceOf( MethodInvokationAsyncStatement ) );
			assertThat( _sut, instanceOf( AsyncStatementBase ) );
			assertThat( _sut, instanceOf( IAsyncStatement ) );
		}
		
		[Test]
		public function should_set_args():void
		{
			var args:Array = [4,"word"];
			
			_sut.args = args;
			
			assertThat( _sut.args, array( equalTo( 4 ), equalTo( "word" ) ) );
		}
		
		[Test]
		public function should_get_args():void
		{
			assertThat( _sut.args, nullValue() );
		}
		
		[Test]
		public function should_have_a_null_child_result_after_successful_evaluation():void
		{
			_sut.stepsObject = this;
			_sut.method =  myTestFunction;
			_sut.args = [4,"word"];
			
			_asyncTestToken = new AsyncTestToken();
			_asyncTestToken.addNotificationMethod( mySuccessfulEvaluateNotification );
				
			_sut.evaluate( _asyncTestToken );
		}
		
		private function mySuccessfulEvaluateNotification( childResult:ChildResult ):void
		{
			assertThat( childResult.error, nullValue() );
			assertThat( childResult.token, equalTo( _asyncTestToken ) );
		}
		
		[Test]
		public function should_have_an_error_in_the_child_result_after_failed_evaluation():void
		{
			_sut.stepsObject = this;
			_sut.method =  myTestFunction;
			_sut.args = ["Incorrect number of args"];
			
			_asyncTestToken = new AsyncTestToken();
			_asyncTestToken.addNotificationMethod( myFailEvaluateNotification );
			
			_sut.evaluate( _asyncTestToken );
		}
		
		private function myFailEvaluateNotification( childResult:ChildResult ):void
		{
			assertThat( childResult.error, instanceOf( Error ) );
			assertThat( childResult.error, instanceOf( ArgumentError ) );
			assertThat( childResult.token, equalTo( _asyncTestToken ) );
		}
		
		[Test]
		public function should_set_method():void
		{
			var f:Function = myTestFunction;
			
			_sut.method = f;
			
			assertThat( _sut.method, equalTo( f ) );
		}
		
		[Test]
		public function should_get_method():void
		{
			assertThat( _sut.method, nullValue() );
		}
		
		[Test (async) ]
		public function should_set_stepsObject():void
		{
			_sut.stepsObject = this;
			
			assertThat( _sut.stepsObject, strictlyEqualTo( this ) );
		}
		
		[Test]
		public function should_get_stepsObject():void
		{
			assertThat( _sut.stepsObject, nullValue() );
		}
		
		//Support
		public function myTestFunction( n:Number, s:String ):String
		{
			return n.toString() + s;
		}
	}
}