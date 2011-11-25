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
    import com.flashquartermaster.cuke4as3.reflection.StepMatcher;
    import com.flashquartermaster.cuke4as3.utilities.Pending;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;
    import com.flashquartermaster.cuke4as3.vo.MatchInfo;

    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.collection.arrayWithSize;
    import org.hamcrest.mxml.object.IsFalse;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasPropertyWithValue;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;

    import support.MockStepInvoker;

    public class StepMatcher_Steps extends StepsBase
    {
        private var _sut:StepMatcher;
        
        private var _stepType:String;
        private var _result:MatchInfo;

        // The step matcher matches a scenario step in a feature file
        // with the regular expression found in the metadata
        // in the code behind that step

        // When it has matched a step it asks the Step Invoker
        // to store the method xml and return a position id from the method XML Vector
        // in order to be able to find it later (since this id will be given to cucumber
        // as a reference to the successful match)

        public function StepMatcher_Steps()
        {
        }

        [Given(/^I have set up the step matcher correctly$/)]
        public function should_set_up_the_step_matcher_correctly():void
        {
            _sut = new StepMatcher( new MockStepInvoker() );
        }

        [When(/^I ask for an? (defined|undefined) step$/)]
        public function should_ask_for_a_step( stepType:String ):void
        {
            _stepType = stepType;

            if( _stepType == "undefined" )
            {
                _result = _sut.match( "I an undefined step" );
            }
            else if( _stepType == "defined" )
            {
                //Mock a matchable step that would have been set by the swf processor
                var matchableStep:XMLList = 
                        new XMLList( <method name="pushNumber" declaredBy="features.step_definitions::Calculator_Steps" returnType="void">
                                        <parameter index="1" type="Number" optional="false"/>
                                        <metadata name="Given">
                                            <arg key="" value="/^I have entered (\\d+) into the calculator$/g"/>
                                        </metadata>
                                    </method>);

                _sut.matchableSteps = matchableStep;
                
                _result = _sut.match( "I have entered 6 into the calculator" );
            }
            else
            {
                throw new Error( "Unknown step type: " + stepType );
            }
        }

        [Then(/^I receive relevant information about the step$/)]
        public function should_receive_relevant_information_about_the_step():void
        {
            if( _stepType == "undefined" )
            {
                assertThat( _result.isUndefined(), isTrue() )
            }
            else if( _stepType == "defined" )
            {
                var expectedResult:MatchInfo = new MatchInfo();
                expectedResult.id = 0//This is the id returned by the mock step invoker
                expectedResult.args = [{"val":6, "pos": 15}];//the number 6 will be found at character 15 in the string, this is for cucumbers highlighting
                expectedResult.className = "features.step_definitions.Calculator_Steps";
                expectedResult.regExp = "/^I have entered (\\d+) into the calculator$/g";
                
                assertThat("Success", _result.isMatch(), isTrue() );
                assertThat("Success", _result.isUndefined(), isFalse() );
                assertThat("Success", _result.isError(), isFalse() );
                assertThat("Args size", _result.args, arrayWithSize(1) );
                assertThat("Id", _result.id, equalTo( expectedResult.id ) );
                assertThat("RegExp", _result.regExp, equalTo( expectedResult.regExp ) );
                assertThat("Source", _result.className, equalTo( expectedResult.className ) );
                assertThat("Args val", _result.args[0], hasPropertyWithValue( "val", expectedResult.args[0].val ) );
                assertThat("Args pos", _result.args[0], hasPropertyWithValue( "pos", expectedResult.args[0].pos) );
            }
        }

        override public function destroy():void
        {
            super.destroy();

            _sut.destroy();
            _sut = null;
            
            _stepType = null;
            _result = null;
        }
    }
}
