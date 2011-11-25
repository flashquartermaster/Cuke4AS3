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
    import flash.display.Sprite;

    public class Cuke4AS3_Suite extends Sprite
    {
        public function Cuke4AS3_Suite()
        {
            var ui:UI_Test_Environment_Steps;
            var features:Feature_Files_Steps;
            var wire_protocol:Wire_Protocol_Steps;
            var core:Core_Steps;
            var compiler:Compiler_Steps;
            var swfloader:SwfLoader_Steps;
            var swfprocessor:SwfProcessor_Steps;
            var server:Server_Steps;
            var wirefile:WireFile_Steps;
            var cucumber:Cucumber_Steps;
            var stepmatcher:StepMatcher_Steps;
            var stepinvoker:StepInvoker_Steps;
            var serverOnly:ServerOnly_Steps;
            var flexunit:FlexUnit_Steps;
            var commandprocessor:CommandProcessor_Steps;
        }
    }
}