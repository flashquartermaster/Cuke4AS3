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
    import com.flashquartermaster.cuke4as3.events.ProcessedCommandEvent;
    import com.flashquartermaster.cuke4as3.net.CommandProcessor;
    import com.flashquartermaster.cuke4as3.net.ICommandProcessor;
    import com.flashquartermaster.cuke4as3.reflection.IStepInvoker;
    import com.flashquartermaster.cuke4as3.reflection.IStepMatcher;
    import com.flashquartermaster.cuke4as3.util.CucumberMessageMaker;

    import flash.events.EventDispatcher;

    public class MockCommandProcessor extends EventDispatcher implements ICommandProcessor
    {
        public function MockCommandProcessor()
        {
        }

        public function processCommand( action:String, data:Object ):void
        {
            if( action == CommandProcessor.BEGIN_SCENARIO || action == CommandProcessor.STEP_MATCHES
                        || action == CommandProcessor.INVOKE  || action == CommandProcessor.END_SCENARIO
                        || action == CommandProcessor.SNIPPET_TEXT )
            {
                dispatchEvent( new ProcessedCommandEvent( ProcessedCommandEvent.SUCCESS, CucumberMessageMaker.successMessage() ) );
            }
            else
            {
                var msg:String = "Unknown Command : " + action + ", with data : " + data;
                dispatchEvent( new ProcessedCommandEvent( ProcessedCommandEvent.ERROR, [msg] ) );
            }
        }

        public function destroy():void
        {
        }

        public function set stepMatcher( value:IStepMatcher ):void
        {
        }

        public function set stepInvoker( value:IStepInvoker ):void
        {
        }
    }
}
