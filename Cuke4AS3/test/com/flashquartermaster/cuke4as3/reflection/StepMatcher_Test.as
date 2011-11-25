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
    import com.flashquartermaster.cuke4as3.vo.MatchInfo;

    import org.flexunit.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;

    public class StepMatcher_Test
    {

        private var _sut:StepMatcher;

        [Before]
        public function set_up():void
        {
            _sut = new StepMatcher( new StepInvoker() );
        }

        [After]
        public function tear_down():void
        {
            _sut.destroy();
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
            assertThat( _sut, instanceOf( StepMatcher ) );
        }

        [Test]
        public function should_destroy():void
        {
            _sut.destroy();

            assertThat( _sut.matchableSteps, nullValue() );
        }

        [Test]
        public function should_fail_if_argument_is_null():void
        {
            var expectedResult:MatchInfo = new MatchInfo();
            expectedResult.errorMessage = "No matches found for \"null\"";

            var result:MatchInfo = _sut.match( null );

            assertFailMatch( expectedResult, result );
        }

        [Test]
        public function should_fail_if_argument_is_an_empty_string():void
        {
            var expectedResult:MatchInfo = new MatchInfo();
            expectedResult.errorMessage = "No matches found for \"\"";

            var result:MatchInfo = _sut.match( "" );

            assertFailMatch( expectedResult, result );
        }

        [Test]
        public function should_manage_undefined_content_in_conditional_capturing_groups():void
        {
            var matchableStep:XMLList =
                        new XMLList( <method name="pushNumber" declaredBy="features.step_definitions::Calculator_Steps" returnType="void">
                                        <parameter index="1" type="String" optional="false"/>
                                        <parameter index="1" type="Number" optional="false"/>
                                        <metadata name="Given">
                                            <arg key="" value="/^I have entered (a\s)?(\\d+) into the calculator$/g"/>
                                        </metadata>
                                    </method>);

            _sut.matchableSteps = matchableStep;

            var result:MatchInfo = _sut.match( "I have entered 6 into the calculator" );
        }

        [Test]
        public function should_manage_undefined_content_in_conditional_capturing_groups_control_function():void
        {
            var matchableStep:XMLList =
                        new XMLList( <method name="pushNumber" declaredBy="features.step_definitions::Calculator_Steps" returnType="void">
                                        <parameter index="1" type="String" optional="false"/>
                                        <parameter index="1" type="Number" optional="false"/>
                                        <metadata name="Given">
                                            <arg key="" value="/^I have entered (a\s)?(\\d+) into the calculator$/g"/>
                                        </metadata>
                                    </method>);

            _sut.matchableSteps = matchableStep;

            var result:MatchInfo = _sut.match( "I have entered a 6 into the calculator" );
        }

        [Test]
        public function should_get_matchableSteps():void
        {
            //Note: the setter test uses the getter so we just check defaults
            var returnValue:XMLList = _sut.matchableSteps;

            assertThat( returnValue, nullValue() );
        }

        [Test]
        public function should_set_matchableSteps():void
        {
            //Invokable steps are set by the SwfProcessor
            //when searching through the xml class descriptions
            var inputValue:XMLList = new XMLList( <method name="pushNumber" declaredBy="features.step_definitions::Calculator_Steps" returnType="void">
                <parameter index="1" type="Number" optional="false"/>
                <metadata name="Given">
                    <arg key="" value="/^I have entered (\d+) into the calculator$/g"/>
                </metadata>
            </method> );

            _sut.matchableSteps = inputValue;

            var returnValue:XMLList = _sut.matchableSteps;

            assertThat( inputValue, equalTo( returnValue ) );
        }

        //Support

        private function assertFailMatch( expectedResult:MatchInfo, result:MatchInfo ):void
        {
            assertThat( result.isError(), isTrue() );
            assertThat( result.errorMessage, equalTo( expectedResult.errorMessage ) );
        }

    }
}