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
    import com.adobe.serialization.json.JSON;
    import com.flashquartermaster.cuke4as3.events.ProcessedCommandEvent;
    import com.flashquartermaster.cuke4as3.net.CommandProcessor;
    import com.flashquartermaster.cuke4as3.reflection.IStepInvoker;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.arrayWithSize;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasPropertyWithValue;
    import org.hamcrest.text.containsString;

    import support.MockStepInvoker;
    import support.MockStepMatcher;

    public class CommandProcessor_Steps extends StepsBase
    {
        private var _sut:CommandProcessor;

        private var _currentCommand:String;
        private var _currentData:Object;
        private var _currentProcessedCommandEvent:ProcessedCommandEvent;

        public function CommandProcessor_Steps()
        {
        }

        [Given(/^a valid command processor$/)]
        public function should_a_valid_command_processor():void
        {
            _sut = new CommandProcessor();
            var stepInvoker:IStepInvoker = new MockStepInvoker();
            _sut.stepInvoker = stepInvoker;
            _sut.stepMatcher = new MockStepMatcher( stepInvoker );
        }

        [When(/^I send an? (valid|invalid) (\[.*)$/, "async")]
        public function should_send_request( validity:String, request:String ):void
        {
            var json_decoded:Array = JSON.decode( request );
            var command:String = json_decoded[0];
            var data:Object = json_decoded[1] as Object;

            if( validity == "valid" )
            {
                Async.handleEvent( this, _sut, ProcessedCommandEvent.SUCCESS, onCommand );
                Async.failOnEvent( this, _sut, ProcessedCommandEvent.ERROR );
            }
            else if( validity == "invalid" )
            {
                Async.handleEvent( this, _sut, ProcessedCommandEvent.ERROR, onCommand );
                Async.failOnEvent( this, _sut, ProcessedCommandEvent.SUCCESS );
            }

            _currentCommand = command;
            _currentData = data;

            _sut.processCommand( command, data );
        }

        [Then(/^I receive (\[.*)$/)]
        public function should_receive_response( jsonResponse:String ):void
        {
            var expectedResult:Array = JSON.decode( jsonResponse );
            var result:Array = _currentProcessedCommandEvent.result;

            switch( _currentCommand )
            {
                case CommandProcessor.BEGIN_SCENARIO:
                    assertThat( result, equalTo( expectedResult ) );
                    break;
                case CommandProcessor.STEP_MATCHES:
                    assertStepMatchResult( result, expectedResult );
                    break;
                case CommandProcessor.INVOKE:
                    assertInvokeResult( expectedResult, result );
                    break;
                case CommandProcessor.END_SCENARIO:
                    assertThat( result, equalTo( expectedResult ) );
                    break;
                case CommandProcessor.SNIPPET_TEXT:
                        assertThat( "Success", result[0], equalTo( expectedResult[0] ) );
                        assertThat( "Body", result[1], equalTo( expectedResult[1] ) );
                    break;
            }
        }

        [Then(/^I receive:$/)]
        public function should_receive_snippet_response( docstring:String ):void
        {
            var expectedResult:Array = JSON.decode( docstring );
            var result:Array = _currentProcessedCommandEvent.result;
            assertThat( "Success", result[0], equalTo( expectedResult[0] ) );
            assertThat( "Body", result[1], equalTo( expectedResult[1] ) );
        }

        [Then(/^I receive an error$/)]
        public function should_receive_an_error():void
        {
            assertThat( _currentProcessedCommandEvent.type, equalTo( ProcessedCommandEvent.ERROR ) );
            assertThat( _currentProcessedCommandEvent.result[0], containsString( "Unknown Command" ) );
        }

        override public function destroy():void
        {
            super.destroy();

            _sut.destroy();
            _sut = null;
        }

        private function onCommand( event:ProcessedCommandEvent, passThroughData:Object ):void
        {
            _currentProcessedCommandEvent = event;
        }

        private function assertInvokeResult( expectedResult:Array, result:Array ):void
        {
            var mainResponse:String = expectedResult[0];

            if( mainResponse == "success" )
            {
                assertThat( _currentProcessedCommandEvent.result, equalTo( expectedResult ) );
            }
            else if( mainResponse == "fail" )
            {
                assertThat( "Message", result[1].message, equalTo( expectedResult[1].message ) );
                assertThat( "Exception", result[1].exception, equalTo( expectedResult[1].exception ) );
            }
            else if( mainResponse == "pending" )
            {
                assertThat( "Pending Message", result[1], equalTo( expectedResult[1] ) );
            }
        }

        private function assertStepMatchResult( result:Array, expectedResult:Array ):void
        {
            if( _currentData.name_to_match == "I have entered 6 into the calculator" )
            {
                assertThat( "Success", result[0], equalTo( expectedResult[0] ) );
                assertThat( "Id", result[1][0].id, equalTo( expectedResult[1][0].id ) );
                assertThat( "RegExp", result[1][0].regexp, equalTo( expectedResult[1][0].regexp ) );
                assertThat( "Source", result[1][0].source, equalTo( expectedResult[1][0].source ) );
                assertThat( "Args size", result[1][0].args, arrayWithSize( 1 ) );
                assertThat( "Args val", result[1][0].args[0], hasPropertyWithValue( "val", expectedResult[1][0].args[0].val ) );
                assertThat( "Args pos", result[1][0].args[0], hasPropertyWithValue( "pos", expectedResult[1][0].args[0].pos ) );
            }
            else
            {
                assertThat( _currentProcessedCommandEvent.result, equalTo( expectedResult ) );
            }
        }
    }
}
