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
    import com.flashquartermaster.cuke4as3.reflection.IStepInvoker;
    import com.flashquartermaster.cuke4as3.reflection.IStepMatcher;
    import com.flashquartermaster.cuke4as3.vo.MatchInfo;

    import org.hamcrest.object.isFalse;

    public class MockStepMatcher implements IStepMatcher
    {
        private var _invokableStepsCalled:Boolean = false;

        public function MockStepMatcher( stepInvoker:IStepInvoker )
        {
        }

        public function match( matchString:String ):MatchInfo
        {
            var matchInfo:MatchInfo = new MatchInfo();

            if ( matchString == "I have entered 6 into the calculator")
            {
                matchInfo.id = 0//This is the id returned by the mock step invoker
                matchInfo.args = [{"val":6, "pos": 15}];//the number 6 will be found at character 15 in the string, this is for cucumbers highlighting
                matchInfo.className = "features.step_definitions.Calculator_Steps";
                matchInfo.regExp = "/^I have entered (\\d+) into the calculator$/g";
            }

            return matchInfo;
        }

        public function destroy():void
        {
        }

        public function get matchableSteps():XMLList
        {
            return null;
        }

        public function set matchableSteps( value:XMLList ):void
        {
            _invokableStepsCalled = true;
        }

        public function verifyInvokableSteps():Boolean
        {
            return _invokableStepsCalled;
        }
    }
}
