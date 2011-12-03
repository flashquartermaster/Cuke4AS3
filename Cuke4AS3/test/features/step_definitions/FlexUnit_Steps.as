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
    import com.flashquartermaster.cuke4as3.utilities.Pending;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;

    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    import org.flexunit.async.Async;
    import org.fluint.sequence.SequenceRunner;
    import org.hamcrest.assertThat;
    import org.hamcrest.number.closeTo;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;

    public class FlexUnit_Steps extends StepsBase
    {
        private var _asyncObject:AsyncObject;

        private var _expectedSuccess:Boolean = false;
        private var _expectedTimeout:Boolean = false;

        private var _expectedTime:int;
        private var _endTimer:int;

        public function FlexUnit_Steps()
        {
        }

        [Given(/^an object that dispatches asynchronous events$/)]
        public function should_an_object_that_dispatches_asynchronous_events():void
        {
            _asyncObject = new AsyncObject();
        }

        private var _method:String;

        [When(/^I listen for an event using (?:an\s)?"([^"]*)"\s?(that will timeout)?$/, "async")]
        public function should_listen_for_an_event( method:String, willTimeout:String ):void
        {
            _method = method;

            var asyncTimeout:int = 500;//ms //FlexUnit default time out 500ms

            var passThroughData:Object = new Object();
            passThroughData.payload = method;

            var timeout:Boolean = (willTimeout != "");
            var timeoutFunction:Function = timeout ? handleExpectedTimeout : handleErrorTimeout;
            var tick:int = timeout ? asyncTimeout + 100 : asyncTimeout - 100;

            var timer:Timer = new Timer( tick, 1 );
            var timerCompleteFunction:Function = dispatchSuccessEvent;

            switch( method )
            {
                case "Async Handler":
                    var handler:Function = Async.asyncHandler( this, handleSuccessEvent, asyncTimeout, passThroughData, timeoutFunction )
                    _asyncObject.addEventListener( AsyncObject.SUCCESS_EVENT, handler, false, 0, true );
                    break;
                case "Handle Event":
                    Async.handleEvent( this, _asyncObject, AsyncObject.SUCCESS_EVENT, handleSuccessEvent, asyncTimeout, passThroughData, timeoutFunction );
                    break;
                case "Fail on event":
                    // Note: If this times out flex unit no longer watches for this event
                    // In order for this to pass we need the fail event not to fire except when after it has timed out
                    Async.handleEvent( this, _asyncObject, AsyncObject.SUCCESS_EVENT, handleSuccessEvent, asyncTimeout, passThroughData, timeoutFunction );
                    Async.failOnEvent( this, _asyncObject, AsyncObject.FAIL_EVENT, asyncTimeout, timeoutFunction );
                    if( timeout )
                    {
                        timerCompleteFunction = dispatchFailEvent;
                    }
                    break;
                case "Proceed on event":
                    Async.proceedOnEvent( this, _asyncObject, AsyncObject.SUCCESS_EVENT, asyncTimeout, timeoutFunction );
                    break;
                case "Register failure event":
                    Async.handleEvent( this, _asyncObject, AsyncObject.SUCCESS_EVENT, handleSuccessEvent, asyncTimeout, passThroughData, timeoutFunction );
                    // These events do not timeout so this event must never fire in order for step to pass
                    Async.registerFailureEvent( this, _asyncObject, AsyncObject.FAIL_EVENT );
                    break;
                case "Async Responder":
                    throw new Pending( "Awaiting implementation" );
                    break;
                case "Async Native Responder":
                    throw new Pending( "Awaiting implementation" );
                    break;
                default:
                    throw new Error( "Unknown async method: " + method );
                    break;
            }

            timer.addEventListener( TimerEvent.TIMER_COMPLETE, timerCompleteFunction );
            timer.start();
        }

        [Then(/^I receive the specified event when it is dispatched$/, "async")]
        public function should_receive_the_specified_event_when_it_is_dispatched():void
        {
            assertThat( _expectedSuccess, isTrue() );
        }

        [Then(/^the timeout method is called$/)]
        public function should_timeout():void
        {
            assertThat( _expectedTimeout, isTrue() );
        }

        [When(/^I delay a call for (\d+) second$/, "async")]
        public function should_delay_a_call( delay:int ):void
        {
            var delayMs:int = toMilliseconds( delay );
            _expectedTime = getTimer() + delayMs;
            Async.delayCall( this, delayedCallHandler, delayMs );
        }

        [Then(/^the delayed call handler is called after (\d+) second$/)]
        public function delayed_call_handler_should_be_called( n1:Number ):void
        {
            //within 50 ms to allow for function execution
            assertThat( _expectedTime, closeTo( _endTimer, 70 ) );
        }

        [Then(/^there is no timeout$/)]
        public function should_there_is_no_timeout():void
        {
            assertThat( _expectedTimeout, isFalse() );
        }

        [Then(/^I do not receive the specified event$/)]
        public function should_i_do_not_receive_the_specified_event_ever():void
        {
            // This comes from the register fail event which must never fire in
            // order for this test to passToFactory, so we check that the success event fired
            // To ensure something happened
            assertThat( _expectedSuccess, isTrue() );
        }

        [When(/^I use a sequence runner$/)]
        public function should_use_a_sequence_runner():void
        {
            throw new Pending( "Awaiting implementation" );

//            var sequence:SequenceRunner = new SequenceRunner( this );
//
//            sequence.addStep( new SequenceSetter( form.usernameTI, {text:passThroughData.username} ) );
//            sequence.addStep( new SequenceWaiter( form.usernameTI, FlexEvent.VALUE_COMMIT, 100 ) );
//
//            sequence.addStep( new SequenceSetter( form.passwordTI, {text:passThroughData.password} ) );
//            sequence.addStep( new SequenceWaiter( form.passwordTI, FlexEvent.VALUE_COMMIT, 100 ) );
//
//            sequence.addStep( new SequenceEventDispatcher( form.loginBtn, new MouseEvent( 'click', true, false ) ) );
//            sequence.addStep( new SequenceWaiter( form, 'loginRequested', 100 ) );
//
//            sequence.addAssertHandler( handleLoginEvent, passThroughData );
//
//            sequence.run();

        }

        [Then(/^the sequence completes successfully$/)]
        public function sequence_should_complete_successfully():void
        {
            throw new Pending( "Awaiting implementation" );
        }

        [When(/^assume, dataprovider, theories and parameterised$/)]
        public function should_assume_dataprovider_theories_and_parameterised():void
        {
            throw new Pending( "Awaiting implementation" );
        }

        override public function destroy():void
        {
            super.destroy();
        }

        private function dispatchSuccessEvent( event:TimerEvent ):void
        {
            var timer:Timer = ( event.target as Timer );
            timer.stop();
            timer.removeEventListener( TimerEvent.TIMER_COMPLETE, dispatchSuccessEvent );

            _asyncObject.succeed();
        }

        private function dispatchFailEvent( event:TimerEvent ):void
        {
            var timer:Timer = ( event.target as Timer );
            timer.stop();
            timer.removeEventListener( TimerEvent.TIMER_COMPLETE, dispatchFailEvent );

            _asyncObject.fail();
        }

        private function handleSuccessEvent( event:Event, passThroughData:Object ):void
        {
            _expectedSuccess = true;
        }

        private function handleExpectedTimeout( passThroughData:Object ):void
        {
            _expectedTimeout = true;
        }

        private function handleErrorTimeout( passThroughData:Object ):void
        {
            throw new Error( "Unexpected Timeout from: " + passThroughData.payload );
        }

        private function delayedCallHandler():void
        {
            _endTimer = getTimer();
        }

        private function toMilliseconds( n:int ):int
        {
            return n * 1000;
        }

    }
}

import flash.events.Event;
import flash.events.EventDispatcher;

internal class AsyncObject extends EventDispatcher
{
    public static const SUCCESS_EVENT:String = "successEvent";
    public static const FAIL_EVENT:String = "failEvent";

    public function AsyncObject()
    {

    }

    public function succeed():void
    {
        dispatchEvent( new Event( SUCCESS_EVENT ) );
    }

    public function fail():void
    {
        dispatchEvent( new Event( FAIL_EVENT ) );
    }
}
