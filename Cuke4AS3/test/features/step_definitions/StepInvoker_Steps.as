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
    import com.flashquartermaster.cuke4as3.events.InvokeMethodEvent;
    import com.flashquartermaster.cuke4as3.reflection.StepInvoker;
    import com.flashquartermaster.cuke4as3.utilities.Pending;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;
    import com.flashquartermaster.cuke4as3.vo.InvokeInfo;

    import flash.system.ApplicationDomain;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;

    public class StepInvoker_Steps extends StepsBase
    {
        private var _sut:StepInvoker;

        private var _executionType:String;

        private var _successfulInvokeId:int;
        private var _failingInvokeId:int;
        private var _pendingInvokeId:int;

        private var _result:InvokeInfo;

        public function StepInvoker_Steps()
        {
        }

        [Given(/^the step invoker is set up correctly$/)]
        public function should_set_up_step_invoker_correctly():void
        {
            _sut = new StepInvoker();

            // Application domain is normally derived from the Swf Loader
            // We are using the current application domain because we will
            // be invoking functions on this object
            _sut.applicationDomain = ApplicationDomain.currentDomain;

            // getInvokationId is normally called by the step matcher when a step is matched to its definition
            // For the purposes of this test we will use functions on this object for the invoker to call
            // based on the definition of this class
            _successfulInvokeId = _sut.getInvokationId( getSuccessfulTestMethodXml() );
            _failingInvokeId = _sut.getInvokationId( getFailingTestMethodXml() );
            _pendingInvokeId = _sut.getInvokationId( getPendingTestMethodXml() );

            assertThat( _sut.stepsObject, nullValue() );
        }

        [When(/^I ask it to execute some ActionScript (?:that\s)?(?:is\s)?(successfully|fails|pending)$/, "async")]
        public function should_execute_actionscript( executionType:String ):void
        {
            _executionType = executionType;

            // Store the result for verification
            Async.handleEvent( this, _sut, InvokeMethodEvent.RESULT, onInvokeComplete );

            switch( executionType )
            {
                case "successfully":
                    var goodData:Object = {"args":["a string arg"], "id":_successfulInvokeId};
                    _sut.invoke( goodData );
                    break;
                case "fails":
                    var failData:Object = {"args":[147], "id":_failingInvokeId};
                    _sut.invoke( failData );
                    break;
                case "pending":
                    var pendingData:Object = {"args":[], "id":_pendingInvokeId};
                    _sut.invoke( pendingData );
                    break;
                default:
                    throw new Error( "Unknown execution type: " + executionType );
                    break;
            }
        }

        [Then(/^I receive relevant information about the code execution$/)]
        public function should_receive_relevant_information():void
        {
            assertThat( _sut.stepsObject, notNullValue() );
            assertThat( _sut.stepsObject, instanceOf( StepInvoker_Steps ) );

            switch( _executionType )
            {
                case "successfully":
                    assertThat( _result.isSuccess(), isTrue() );
                    break;
                case "fails":
                    assertThat( _result.isError(), isTrue() );
                    assertThat( _result.errorMessage, equalTo( "Failing test function: 147" ) );
                    assertThat( _result.errorName, equalTo( "Error" ) );
                    // backtrace can be empty of full depending on the environment that this is run
                    // if we are running from adl then we get the debug stacktrace but if we are within Air
                    // in the developer ui then the stacktrace is lost
                    break;
                case "pending":
                    assertThat( _result.isPending(), isTrue() );
                    assertThat( _result.pendingMessage, equalTo( "Pending implementation" ) );
                    break;
                default:
                    throw new Error( "Unknown execution type: " + _executionType );
                    break;

            }
        }

        override public function destroy():void
        {
            super.destroy();

            _sut.destroy();
            assertThat( _sut.stepsObject, nullValue() );
            _sut = null;

            _executionType = null;
        }

//       Support

        private function onInvokeComplete( event:InvokeMethodEvent, passThroughData:Object ):void
        {
            _result = event.result;
        }

        private function getSuccessfulTestMethodXml():XML
        {
            return <method name="successfulTestFunction" declaredBy="features.step_definitions::StepInvoker_Steps" returnType="void">
                <parameter index="1" type="String" optional="false"/>
            </method>;
        }

        public function successfulTestFunction( s:String ):void
        {
            trace( s );
        }

        private function getFailingTestMethodXml():XML
        {
            return <method name="failingTestFunction" declaredBy="features.step_definitions::StepInvoker_Steps" returnType="void">
                <parameter index="1" type="Number" optional="false"/>
            </method>;
        }

        public function failingTestFunction( n:Number ):void
        {
            throw new Error( "Failing test function: " + n );
        }

        private function getPendingTestMethodXml():XML
        {
            return <method name="pendingTestFunction" declaredBy="features.step_definitions::StepInvoker_Steps" returnType="void">
            </method>;
        }

        public function pendingTestFunction():void
        {
            throw new Pending( "Pending implementation" );
        }
    }
}
