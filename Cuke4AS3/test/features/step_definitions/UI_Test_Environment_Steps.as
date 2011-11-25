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
import com.flashquartermaster.cuke4as3.utilities.StepsBase;

import flash.display.Sprite;
	import flash.events.Event;
	
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.fluint.uiImpersonation.UIImpersonator;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.isTrue;
	import org.hamcrest.object.notNullValue;
	
	public class UI_Test_Environment_Steps extends StepsBase
	{
		private var _sprite:Sprite;
		
		public function UI_Test_Environment_Steps()
		{
			super();
		}
		
		[Given (/^I have a visible asset$/ )]
		public function createSprite():void
		{
			_sprite = new Sprite();
			_sprite.graphics.beginFill( 0xFF0000 );
			_sprite.graphics.drawRect( 0, 0, 100, 20 );
			_sprite.graphics.endFill();
		}
		
		[When ( /^I add it to the UI test environment$/, "async")]
		public function addToDisplayList():void
		{
			Async.proceedOnEvent( this, _sprite, Event.ADDED_TO_STAGE );
			UIImpersonator.addChild( _sprite );
		}
		
		[Then ( /^it can be seen$/ )]
		public function verifySprite():void
		{
			assertThat( _sprite.stage, notNullValue() );
			assertThat( _sprite.visible, isTrue() );
			
//			fail("To make sure that destroy() is called");
		}
		
		override public function destroy():void
		{
			UIImpersonator.removeChild( _sprite );
			_sprite = null;
		}
	}
}