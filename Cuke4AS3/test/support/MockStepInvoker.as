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
    import com.flashquartermaster.cuke4as3.events.InvokeMethodEvent;
    import com.flashquartermaster.cuke4as3.reflection.IStepInvoker;
    import com.flashquartermaster.cuke4as3.vo.InvokeInfo;

    import flash.events.EventDispatcher;
    import flash.system.ApplicationDomain;

    public class MockStepInvoker extends EventDispatcher implements IStepInvoker
    {
        public function MockStepInvoker()
        {
        }

        public function invoke( data:Object ):void
        {
            var invokeInfo:InvokeInfo = new InvokeInfo();

            switch( data.id )
            {
                case "1":
                    invokeInfo.errorMessage = "The wires are down";
                    invokeInfo.errorName = "Error";
                    break;
                case "2":
                    invokeInfo.pendingMessage = "I'll do it later";
                    break;
            }

            dispatchEvent( new InvokeMethodEvent( InvokeMethodEvent.RESULT, invokeInfo ) );
        }

        public function getInvokationId( methodXml:XML ):uint
        {
            return 0;
        }

        public function set applicationDomain( applicationDomain:ApplicationDomain ):void
        {
        }

        public function get stepsObject():*
        {
            //just using this for the duplicate step match in the StepMatcher_Steps
            return ( new Calculator_Steps() as Class );
        }

        public function resetState():void
        {
        }

        public function isExecutingClass( declaredBy:String ):Boolean
        {
            return ( declaredBy == "support::Calculator_Steps" );
        }

        public function isExecutingScenario():Boolean
        {
            return true;
        }

        public function destroy():void
        {
        }
    }
}
