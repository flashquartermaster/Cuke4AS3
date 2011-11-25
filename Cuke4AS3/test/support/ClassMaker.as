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
package support
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.describeType;

    import org.as3commons.bytecode.abc.BaseMultiname;
    import org.as3commons.bytecode.abc.enum.MultinameKind;

    import org.as3commons.bytecode.abc.enum.Opcode;
	import org.as3commons.bytecode.emit.IAbcBuilder;
	import org.as3commons.bytecode.emit.IClassBuilder;
	import org.as3commons.bytecode.emit.ICtorBuilder;
	import org.as3commons.bytecode.emit.IMetadataBuilder;
	import org.as3commons.bytecode.emit.IMethodBuilder;
	import org.as3commons.bytecode.emit.IPackageBuilder;
	import org.as3commons.bytecode.emit.impl.AbcBuilder;
	import org.as3commons.bytecode.emit.impl.MetadataArgument;
	import org.as3commons.bytecode.emit.impl.MethodArgument;
	import org.as3commons.bytecode.util.AbcSpec;

	public class ClassMaker extends EventDispatcher
	{
		private var _abcBuilder:IAbcBuilder;
		private var _applicationDomain:ApplicationDomain;
		private var _packag:String;
		private var _name:String;
		private var _instance:*;
		
		public function ClassMaker()
		{
			_abcBuilder = new AbcBuilder();
		}
		
		public function makeStepsClass( packag:String, name:String ):void
		{
			_packag = packag;
			_name = name;
			
			addEventListeners();
			
			//Package
			var packageBuilder:IPackageBuilder = abcBuilder.definePackage( packag );
			//Name
			var classBuilder:IClassBuilder = packageBuilder.defineClass( name );
			//Constructor
//			var ctorBuilder:ICtorBuilder = classBuilder.defineConstructor();
			
			makeClass( classBuilder );
			
			//Make it
			abcBuilder.buildAndLoad(ApplicationDomain.currentDomain, _applicationDomain);
		}
		
		public function makeStepsClassAndGetBytes( packag:String, name:String ):ByteArray
		{
			_packag = packag;
			_name = name;
			addEventListeners();
			var packageBuilder:IPackageBuilder = abcBuilder.definePackage( packag );
			var classBuilder:IClassBuilder = packageBuilder.defineClass( name );
			makeClass( classBuilder );
			return abcBuilder.buildAndExport();
		}
		
		private function makeClass(classBuilder:IClassBuilder):void
		{
			//Given Method
			var givenMethodBuilder:IMethodBuilder = classBuilder.defineMethod("doGiven");
			var givenMetadataBuilder:IMetadataBuilder = givenMethodBuilder.defineMetadata("Given");
			givenMetadataBuilder.arguments = [];
			var givenMetadataArgument:MetadataArgument = givenMetadataBuilder.defineArgument();
			givenMetadataArgument.key = "key";
			givenMetadataArgument.value = "/^I have something$/";
			
			//When Method
			var whenMethodBuilder:IMethodBuilder = classBuilder.defineMethod("doWhen");

			var whenMetadataBuilder:IMetadataBuilder = whenMethodBuilder.defineMetadata("When");
			whenMetadataBuilder.arguments = [];
			var whenMetadataArgument:MetadataArgument = whenMetadataBuilder.defineArgument();
			whenMetadataArgument.key = "";
			whenMetadataArgument.value = "/^I do something with (\\d+)$/";
            
            var argument:MethodArgument = whenMethodBuilder.defineArgument("int");
            whenMethodBuilder.returnType = "int";

            whenMethodBuilder.addOpcode(Opcode.getlocal_0)
             .addOpcode(Opcode.pushscope)
             .addOpcode(Opcode.getlocal_1)
             .addOpcode(Opcode.pushint, [100])
             .addOpcode(Opcode.multiply)
             .addOpcode(Opcode.setlocal_1)
             .addOpcode(Opcode.getlocal_1)
             .addOpcode(Opcode.returnvalue);

//            AKA
//            public function doWhen(value:int):int {
//              value = (value * 100);
//              return value;
//            }
			
			//Then Method
			var thenMethodBuilder:IMethodBuilder = classBuilder.defineMethod("doThen");
			var thenMetadataBuilder:IMetadataBuilder = thenMethodBuilder.defineMetadata("Then");
			thenMetadataBuilder.arguments = [];
			var thenMetadataArgument:MetadataArgument = thenMetadataBuilder.defineArgument();
			thenMetadataArgument.key = "";
			thenMetadataArgument.value = "/^I expect something$/";

//            public function doTrace():void
//            {
//                trace("a string");
//            }
//
//            function features.step_definitions:StepInvoker_Steps:::doTrace()::void
//            maxStack:2 localCount:1 initScopeDepth:5 maxScopeDepth:6
//                debugfile     	"/Users/coxent01/Documents/Cuke4AS3/Cuke4AS3/test;features/step_definitions;StepInvoker_Steps.as"
//                debugline     	194
//                getlocal0
//                pushscope
//                debugline     	196
//                findpropstrict	:trace
//                pushstring    	"a string"
//                callpropvoid  	:trace (1)
//                debugline     	197
//                returnvoid
//            0 Extras
//            0 Traits Entries
		}
		
		private function loadedHandler( event:Event ):void
		{
			removeEventListeners();
			//Verify
//			trace("ClassMaker : loadedHandler :",event);
			var clazz:Class = _applicationDomain.getDefinition(_packag + "." + _name) as Class;
			_instance = new clazz();
			var classDescription:XML = describeType( clazz );
//			trace(classDescription.toXMLString() );
		}
		
		private function errorHandler( event:IOErrorEvent ):void
		{
//			trace("ClassMaker : errorHandler :",event);
			removeEventListeners();
		}
		
		//event Listeners
		
		private function addEventListeners():void
		{
			_abcBuilder.addEventListener(Event.COMPLETE, loadedHandler);
			_abcBuilder.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_abcBuilder.addEventListener(IOErrorEvent.VERIFY_ERROR, errorHandler);
		}
		
		private function removeEventListeners():void
		{
			_abcBuilder.removeEventListener(Event.COMPLETE, loadedHandler);
			_abcBuilder.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_abcBuilder.removeEventListener(IOErrorEvent.VERIFY_ERROR, errorHandler);
		}
		
		//Accessors

		public function get abcBuilder():IAbcBuilder
		{
			return _abcBuilder;
		}

		public function set applicationDomain(value:ApplicationDomain):void
		{
			_applicationDomain = value;
		}

		public function getInstanceOfGeneratedClass():*
		{
			return _instance;
		}
		
		//Handlers
		
		private function cancelHandler(event:Event):void {
			trace("cancelHandler: " + event);
		}
		
		private function completeHandler(event:Event):void {
			trace("completeHandler: " + event);
		}
		
		private function uploadCompleteDataHandler(event:DataEvent):void {
			trace("uploadCompleteData: " + event);
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			trace("httpStatusHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}
		
		private function openHandler(event:Event):void {
			trace("openHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			var file:FileReference = FileReference(event.target);
			trace("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}
		
		private function selectHandler(event:Event):void {
//			var file:FileReference = FileReference(event.target);
//			trace("selectHandler: name=" + file.name + " URL=" + uploadURL.url);
//			file.upload(uploadURL);
		}
		//Opcode example
//			var methodBuilder:IMethodBuilder = classBuilder.defineMethod("multiplyByHundred");
//			var argument:MethodArgument = methodBuilder.defineArgument("int");
//			methodBuilder.returnType = "int";
//			methodBuilder.addOpcode(Opcode.getlocal_0)
//				.addOpcode(Opcode.pushscope)
//				.addOpcode(Opcode.getlocal_1)
//				.addOpcode(Opcode.pushint, [100])
//				.addOpcode(Opcode.multiply)
//				.addOpcode(Opcode.setlocal_1)
//				.addOpcode(Opcode.getlocal_1)
//				.addOpcode(Opcode.returnvalue);
	}
}