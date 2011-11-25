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
package com.flashquartermaster.cuke4as3.reflection
{
    import com.flashquartermaster.cuke4as3.events.InvokeMethodEvent;
    import com.flashquartermaster.cuke4as3.util.CucumberMessageMaker;
    import com.flashquartermaster.cuke4as3.vo.InvokeInfo;

    import flash.events.EventDispatcher;
    import flash.system.ApplicationDomain;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.core.isA;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.text.containsString;

    public class StepInvoker_Test
    {
        private var _sut:StepInvoker;

        [Before]
        public function setUp():void
        {
            _sut = new StepInvoker();
        }

        [After]
        public function tearDown():void
        {
            _sut.destroy();
            assertThat( _sut.stepsObject, nullValue() );
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
            assertThat( _sut, instanceOf( StepInvoker ) );
            assertThat( _sut, instanceOf( EventDispatcher ) );
        }

        [Test(async)]
        public function should_fail_to_invoke_if_given_bad_data():void
        {
            //invoke accepts a data object containg args and an id
            //The id references an xml representation of a function
            //derived from analysing describeType()
            //Format e.g. {"args":["3"],"id":0}

            var passThroughData:Object = new Object();
            passThroughData.args = null;
            passThroughData.id = 0;

            var badDataObject:Object = {};

            Async.handleEvent( this, _sut, InvokeMethodEvent.RESULT, onInvokeWithBadData, 500, passThroughData );

            _sut.invoke( badDataObject );

        }

        [Test(async)]
        public function should_fail_to_invoke_if_given_bad_id():void
        {
            var passThroughData:Object = new Object();
            passThroughData.args = ["a string arg"];
            passThroughData.id = 0;

            var badDataObject:Object = {"args":["a string arg"], "id":0};

            Async.handleEvent( this, _sut, InvokeMethodEvent.RESULT, onInvokeWithBadData, 500, passThroughData );

            _sut.invoke( badDataObject );

        }

        [Test(async)]
        public function should_invoke_and_run_a_function_and_fail_when_there_is_an_argument_mismatch():void
        {
            _sut.applicationDomain = ApplicationDomain.currentDomain;

            var invokeId:int = _sut.getInvokationId( getTestMethodXml() );

            var goodData:Object = {"args":[], "id":invokeId};

            Async.handleEvent( this, _sut, InvokeMethodEvent.RESULT, onFailedInvokation );

            _sut.invoke( goodData );
        }

        [Test(async)]
        public function should_invoke_and_run_a_function_marked_as_async_successfully():void
        {
            _sut.applicationDomain = ApplicationDomain.currentDomain;

            var invokeId:int = _sut.getInvokationId( getAsyncTestMethodXml() );

            var goodData:Object = {"args":["a string arg"], "id":invokeId};

            Async.handleEvent( this, _sut, InvokeMethodEvent.RESULT, onSuccessfulInvokation );

            _sut.invoke( goodData );
        }

        [Test(async)]
        public function should_invoke_and_run_a_function_marked_as_async_and_fail_if_there_is_and_argument_mismatch():void
        {
            _sut.applicationDomain = ApplicationDomain.currentDomain;

            var invokeId:int = _sut.getInvokationId( getAsyncTestMethodXml() );

            var goodData:Object = {"args":[], "id":invokeId};

            Async.handleEvent( this, _sut, InvokeMethodEvent.RESULT, onFailedAsyncInvokation );

            _sut.invoke( goodData );
        }

        [Test(async)]
        public function should_resetState():void
        {
            _sut.applicationDomain = ApplicationDomain.currentDomain;

            var invokeId:int = _sut.getInvokationId( getTestMethodXml() );

            var goodData:Object = {"args":["a string arg"], "id":invokeId};

            Async.handleEvent( this, _sut, InvokeMethodEvent.RESULT, onSuccessfulInvokation );

            _sut.invoke( goodData );

            assertThat( _sut.stepsObject, notNullValue() );

            _sut.resetState();

            assertThat( _sut.stepsObject, nullValue() );
        }

        [Test]
        public function should_destroy():void
        {
            _sut.destroy();

            //methods to invoke XML Vector and the XML are inaccessible
            //application domain is set but cannot be read
            //and therefore not tested

            //Mock to check resetState is called

            assertThat( _sut.stepsObject, nullValue() );
        }

        //Accessors

        [Test]
        public function should_set_applicationDomain():void
        {
            //verify no errors, setter only function
            _sut.applicationDomain = new ApplicationDomain( ApplicationDomain.currentDomain );
        }

        [Test]
        public function should_get_invokationId():void
        {
            //In reality we could give it any old xml to test it since
            //the xml is not verified but this is what normally goes in
            var methodXml:XML = <method name="pushNumber" declaredBy="features.step_definitions::Calculator_Steps" returnType="void">
                <parameter index="1" type="Number" optional="false"/>
                <metadata name="Given">
                    <arg key="" value="/^I have entered (\d+) into the calculator$/g"/>
                </metadata>
            </method>;

            var result1:uint = _sut.getInvokationId( methodXml );

            assertThat( result1, equalTo( 0 ) );

            var result2:uint = _sut.getInvokationId( methodXml );

            assertThat( result2, equalTo( 1 ) );
        }

        [Test]
        public function should_get_stepsObject():void
        {
            var stepsObject:* = _sut.stepsObject;
            //Default is null
            assertThat( stepsObject, nullValue() );
        }

        //Support

        private function onInvokeWithBadData( event:InvokeMethodEvent, passThroughData:Object ):void
        {
            assertThat( event.type, equalTo( InvokeMethodEvent.RESULT ) );
            assertThat( event.result, instanceOf( InvokeInfo) );

            var invokeInfo:InvokeInfo = event.result;

            assertThat( invokeInfo.isError(), isTrue() );
            assertThat( invokeInfo.errorMessage, containsString("No invokable method found") );
            assertThat( invokeInfo.isPending(), isFalse() );
            assertThat( invokeInfo.isSuccess(), isFalse() );
        }

        private function onSuccessfulInvokation( event:InvokeMethodEvent, passThroughData:Object ):void
        {
            assertThat( event.type, equalTo( InvokeMethodEvent.RESULT ) );
            assertThat( event.result, instanceOf( InvokeInfo) );

            var invokeInfo:InvokeInfo = event.result;

            assertThat( invokeInfo.isSuccess(), isTrue() );
            assertThat( invokeInfo.isPending(), isFalse() );
            assertThat( invokeInfo.isError(), isFalse() );
        }

        private function onFailedInvokation( event:InvokeMethodEvent, passThroughData:Object ):void
        {
            assertThat( event.type, equalTo( InvokeMethodEvent.RESULT ) );
            assertThat( event.result, instanceOf( InvokeInfo) );

            var invokeInfo:InvokeInfo = event.result;

            assertThat( invokeInfo.isError(), isTrue() );
            assertThat( invokeInfo.errorMessage, containsString("Error #1063") );
            assertThat( invokeInfo.errorName, equalTo( "ArgumentError" ) );
            assertThat( invokeInfo.isPending(), isFalse() );
            assertThat( invokeInfo.isSuccess(), isFalse() );
        }

        private function onFailedAsyncInvokation( event:InvokeMethodEvent, passThroughData:Object ):void
        {
            assertThat( event.type, equalTo( InvokeMethodEvent.RESULT ) );
            assertThat( event.result, instanceOf( InvokeInfo) );

            var invokeInfo:InvokeInfo = event.result;

            assertThat( invokeInfo.isError(), isTrue() );
            assertThat( invokeInfo.errorMessage, containsString("Error #1063") );
            assertThat( invokeInfo.errorName, equalTo( "ArgumentError" ) );
            assertThat( invokeInfo.isPending(), isFalse() );
            assertThat( invokeInfo.isSuccess(), isFalse() );
        }

        private function getTestMethodXml():XML
        {
            //Note it is one of the methods on this class below
            return <method name="myTestFunction" declaredBy="com.flashquartermaster.cuke4as3.reflection::StepInvoker_Test" returnType="void">
                <parameter index="1" type="String" optional="false"/>
            </method>;
        }

        private function getAsyncTestMethodXml():XML
        {
            //Note it is one of the methods on this class below
            return <method name="myAsyncTestFunction" declaredBy="com.flashquartermaster.cuke4as3.reflection::StepInvoker_Test" returnType="void">
                <parameter index="1" type="String" optional="false"/>
                <metadata name="Given">
                    <arg key="" value="/^I have entered (\d+) into the calculator$/g"/>
                    <arg key="" value="async"/>
                </metadata>
            </method>;
        }

        public function myTestFunction( s:String ):void
        {
            trace( s );
        }

        public function myAsyncTestFunction( s:String ):void
        {
            Async.delayCall( this, onDelayCall, 100 );
            trace( s );
        }

        private function onDelayCall():void
        {
            trace( "Delayed Method Call" );
        }
    }
}