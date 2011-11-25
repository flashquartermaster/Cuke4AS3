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
	import com.furusystems.logging.slf4as.global.debug;
	
	import flash.display.Sprite;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.fail;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;

	public class Calculator_Steps
	{
		private var _calculator:Calculator;
		private var _calculatorResult:Number;
		
		public function Calculator_Steps()
		{
			_calculator = new Calculator();
		}
		
		[Given(/^I have entered (\d+) into the calculator$/g)]
		public function pushNumber( n:Number ):void
		{
			_calculator.push( n );
//			debug( "Calculator_Steps : pushNumber :",n);
		}
		
		[When(/^I want it to (add|divide)$/)]
		public function pressButton( button:String ):void
		{
//			debug( "Calculator_Steps : pressButton :",button);
			if( button == "divide" )
			{
				_calculatorResult = _calculator.divide();
			}
			else if( button == "add" )
			{
				_calculatorResult = _calculator.add();
			}
            else
            {
                throw new Error("Unknown operation : " + button);
            }
		}
		
		[Then(/^the current value should be (.*)$/)]
		public function checkValue( value:Number ):void
		{
//			debug( "Calculator_Steps : checkValue :",value);
			
			if (_calculatorResult != value) {
				throw new Error("Expected " + value + ", but got " + _calculatorResult);
			}
			
//			assertThat( value, equalTo( _calculatorResult ) );
//			assertThat( value, not( equalTo( _calculatorResult ) ) );
			
//			Assert.fail("Fail this step!");
		}
		
		public function destroy():void
		{
//			debug("Calculator_Steps : destroy");
			_calculator = null;
		}
	}
}