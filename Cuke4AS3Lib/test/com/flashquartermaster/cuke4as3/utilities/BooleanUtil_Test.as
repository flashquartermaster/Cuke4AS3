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
package com.flashquartermaster.cuke4as3.utilities{
	import com.flashquartermaster.cuke4as3.utilities.BooleanUtil;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;

	public class BooleanUtil_Test
	{		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
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
		public function should_evaluate_string_true_as_boolean_true():void
		{
			var s:String = "true";
			var b:Boolean = BooleanUtil.evaluateString( s );
			
			assertThat( b, isTrue() );
		}
		
		[Test]
		public function should_evaluate_string_false_as_boolean_false():void
		{
			var s:String = "false";
			var b:Boolean = BooleanUtil.evaluateString( s );
			
			assertThat( b, isFalse() );
		}
		
		[Test (expects="Error")]
		public function should_throw_an_error_for_invalid_input():void
		{
			var s:String = "garbage";
			var b:Boolean = BooleanUtil.evaluateString( s );
		}
		
		[Test]
		public function should_evaluate_number_1_to_true():void
		{
			var i:int = 1;
			var b:Boolean = BooleanUtil.evaluateNumber( i );
			
			assertThat( b, isTrue() );
		}
		
		[Test]
		public function should_evaluate_number_0_to_false():void
		{
			var i:int = 0;
			var b:Boolean = BooleanUtil.evaluateNumber( i );
			
			assertThat( b, isFalse() );
		}
		
		[Test (expects="Error")]
		public function should_throw_error_for_invalid_minus_number():void
		{
			var i:int = -1;
			var b:Boolean = BooleanUtil.evaluateNumber( i );
		}
		
		[Test (expects="Error")]
		public function should_throw_error_for_invalid_number_higher_than_1():void
		{
			var i:int = 2;
			var b:Boolean = BooleanUtil.evaluateNumber( i );
		}
	}
}