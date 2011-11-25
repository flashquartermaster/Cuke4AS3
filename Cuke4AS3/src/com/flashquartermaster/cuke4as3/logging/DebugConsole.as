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
 *Based on Hello world and intro to DConsole64 by Andreas Rønning
 * @author Tom Coxen
 * @version
 **/
package com.flashquartermaster.cuke4as3.logging
{
	import com.furusystems.dconsole2.DConsole;
	import com.furusystems.dconsole2.core.gui.maindisplay.ConsoleView;
	import com.furusystems.dconsole2.plugins.plugcollections.AllPlugins;
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	import com.furusystems.logging.slf4as.global.debug;
	import com.furusystems.logging.slf4as.global.error;
	import com.furusystems.logging.slf4as.global.fatal;
	import com.furusystems.logging.slf4as.global.info;
	import com.furusystems.logging.slf4as.global.warn;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import mx.core.UIComponent;

	public class DebugConsole extends UIComponent 
	{	
		public function DebugConsole():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
//			DConsole.clearPersistentData();
			addChild(DConsole.view);
//			DConsole.registerPlugins(BasicPlugins);
			DConsole.registerPlugins(AllPlugins);
//			DConsole.show();
			
			
			DConsole.createCommand("myCommand", myMethod, "My commands", "My helpful string"); 
			

			DConsole.setTitle("Cuke4AS3 Console");
		}
		
		private function myMethod(input:String):Array
		{
			return input.split("");
		}
	}
	
}