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
    import com.flashquartermaster.cuke4as3.reflection.StepInvoker;
    import com.flashquartermaster.cuke4as3.reflection.StepMatcher;

    import flash.events.EventDispatcher;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;

    public class CommandProcessor_Test
    {

        private var _sut:CommandProcessor;

        [Before]
        public function setUp():void
        {
            _sut = new CommandProcessor();
        }

        [After]
        public function tearDown():void
        {
            _sut.destroy();
            _sut = null;
        }

        [Test]
        public function should_construct():void
        {
            assertThat( _sut, notNullValue() );
            assertThat( _sut, instanceOf( CommandProcessor ) );
            assertThat( _sut, instanceOf( EventDispatcher ) );
        }

        [Test]
        public function should_process_command():void
        {
            //This main functionality is covered in the command-processor.feature
            assertThat( true, isTrue() );
        }

        [Test]
        public function should_destroy():void
        {
            _sut.destroy();
        }

        //Accessors

        [Test]
		public function should_set_stepInvoker():void
		{
			var expectedResult:StepInvoker = new StepInvoker();

			_sut.stepInvoker = expectedResult;
		}

		[Test]
		public function should_set_stepMatcher():void
		{
			var expectedResult:StepMatcher = new StepMatcher( new StepInvoker() );

			_sut.stepMatcher = expectedResult;
		}
    }
}
