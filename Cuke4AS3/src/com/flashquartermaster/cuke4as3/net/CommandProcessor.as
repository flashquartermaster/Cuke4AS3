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
package com.flashquartermaster.cuke4as3.net
{
    import com.flashquartermaster.cuke4as3.events.InvokeMethodEvent;
    import com.flashquartermaster.cuke4as3.events.ProcessedCommandEvent;
    import com.flashquartermaster.cuke4as3.reflection.IStepInvoker;
    import com.flashquartermaster.cuke4as3.reflection.IStepMatcher;
    import com.flashquartermaster.cuke4as3.util.CucumberMessageMaker;
    import com.flashquartermaster.cuke4as3.vo.InvokeInfo;
    import com.flashquartermaster.cuke4as3.vo.MatchInfo;
    import com.furusystems.logging.slf4as.global.error;
    import com.furusystems.logging.slf4as.global.info;

    import flash.events.EventDispatcher;

    public class CommandProcessor extends EventDispatcher implements ICommandProcessor
    {
        public static const BEGIN_SCENARIO:String = "begin_scenario";
        public static const STEP_MATCHES:String = "step_matches";
        public static const END_SCENARIO:String = "end_scenario";
        public static const INVOKE:String = "invoke";
        public static const SNIPPET_TEXT:String = "snippet_text";

        private var _stepMatcher:IStepMatcher;
        private var _stepInvoker:IStepInvoker;

        public function CommandProcessor()
        {
        }

        public function processCommand( action:String, data:Object ):void
        {
            switch( action )
            {
                case BEGIN_SCENARIO:
                    beginScenario( data );
                    break;
                case STEP_MATCHES:
                    stepMatch( data );
                    break;
                case INVOKE:
                    invoke( data );
                    break;
                case END_SCENARIO:
                    endScenario( data );
                    break;
                case SNIPPET_TEXT:
                    snippetText( data );
                    break;
                default:
                    var msg:String = "Unknown Command : " + action + ", with data : " + data;
                    dispatchEvent( new ProcessedCommandEvent( ProcessedCommandEvent.ERROR, [msg] ) );
                    break;
            }

        }

        private function beginScenario( data:Object ):void
        {
            //["begin_scenario",{"tags":["dev"]}]
            dispatchEvent( new ProcessedCommandEvent( ProcessedCommandEvent.SUCCESS, CucumberMessageMaker.successMessage() ) );
        }

        private function stepMatch( data:Object ):void
        {
            //["step_matches",{"name_to_match":"we're all wired"}]
            var processedCommandEvent:ProcessedCommandEvent = new ProcessedCommandEvent( ProcessedCommandEvent.SUCCESS );

            var matchInfo:MatchInfo = _stepMatcher.match( data.name_to_match );

            if( matchInfo.isMatch() )
            {
                processedCommandEvent.result = CucumberMessageMaker.foundSuccessfulMatchMessage( matchInfo );
            }
            else if( matchInfo.isUndefined() )
            {
                processedCommandEvent.result = CucumberMessageMaker.dryRunSuccessMessage();
            }
            else if( matchInfo.isError() )
            {
                processedCommandEvent.result = CucumberMessageMaker.failMessage( matchInfo.errorMessage );
            }

            matchInfo.destroy();

            dispatchEvent( processedCommandEvent );
        }

        private function invoke( data:Object ):void
        {
            //["invoke",{"args":["3"],"id":0}]
            _stepInvoker.addEventListener( InvokeMethodEvent.RESULT, onInvokeMethodResult );
            _stepInvoker.invoke( data );
        }

        private function onInvokeMethodResult( invokeMethodEvent:InvokeMethodEvent ):void
        {
            try
            {
                var processedCommandEvent:ProcessedCommandEvent = new ProcessedCommandEvent( ProcessedCommandEvent.SUCCESS );

                _stepInvoker.removeEventListener( InvokeMethodEvent.RESULT, onInvokeMethodResult );

                var invokeInfo:InvokeInfo = invokeMethodEvent.result;

                if( invokeInfo.isSuccess() )
                {
                    processedCommandEvent.result = CucumberMessageMaker.successMessage();
                }
                else if( invokeInfo.isPending() )
                {
                    processedCommandEvent.result = CucumberMessageMaker.pendingMessage( invokeInfo.pendingMessage );
                }
                else if( invokeInfo.isError() )
                {
                    processedCommandEvent.result = CucumberMessageMaker.failMessage( invokeInfo.errorMessage, invokeInfo.errorName, invokeInfo.errorTrace );
                }

                invokeInfo.destroy();

                dispatchEvent( processedCommandEvent );
            }
            catch( e:Error )
            {
                error( "Cuke4AS3Server : onInvokeMethodResult : e :", e );
                dispatchEvent( new ProcessedCommandEvent( ProcessedCommandEvent.ERROR, ["Invoke Method Result Received Out of Sync. Perhaps you have called stop() while a method was still executing"] ) )
            }
        }

        private function snippetText( data:Object ):void
        {
            // ["snippet_text",{"step_keyword":"Then","multiline_arg_class":"","step_name":"the headings will be \"Header A\" and \"Header B\" and \"Header C\""}]
            dispatchEvent( new ProcessedCommandEvent( ProcessedCommandEvent.SUCCESS, ["success", CucumberMessageMaker.snippetTextMessage( data ) ] ) );
        }

        private function endScenario( data:Object ):void
        {
            //Cucumber resets state between scenarios so we shall too :)
            _stepInvoker.resetState();
            dispatchEvent( new ProcessedCommandEvent( ProcessedCommandEvent.SUCCESS, CucumberMessageMaker.successMessage() ) );
        }

        public function destroy():void
        {
            info("CommandProcessor : destroy");
            //It is Cuke4AS3's responsibility to call destroy(); on these
            //As they are instance variables of Cuke4AS3
            _stepInvoker = null;
            _stepMatcher = null;
        }

        public function set stepMatcher( value:IStepMatcher ):void
        {
            _stepMatcher = value;
        }

        public function set stepInvoker( value:IStepInvoker ):void
        {
            _stepInvoker = value;
        }
    }
}
