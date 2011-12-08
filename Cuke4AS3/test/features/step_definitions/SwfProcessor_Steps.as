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
    import com.flashquartermaster.cuke4as3.reflection.IStepInvoker;
    import com.flashquartermaster.cuke4as3.reflection.IStepMatcher;
    import com.flashquartermaster.cuke4as3.reflection.SwfProcessor;
    import com.flashquartermaster.cuke4as3.utilities.Pending;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;

    import support.FileHelper;

    import support.MockStepInvoker;
    import support.MockStepMatcher;

    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;
    import flash.system.ApplicationDomain;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.text.containsString;

    import support.ClassMaker;

    public class SwfProcessor_Steps extends StepsBase
    {
        private var _sut:SwfProcessor;
        private var _mockStepMatcher:IStepMatcher;

        // The application domain would normally be created by the swf loader
        private var _applicationDomain:ApplicationDomain = new ApplicationDomain( ApplicationDomain.currentDomain );
        private var _mockClassName:String = "Class_Steps";
        
        private var _filehelper:FileHelper;

        private var _goodComplete:Boolean = false;
        private var _errorComplete:Boolean = false;
        private var _errorMessage:String;

        public function SwfProcessor_Steps()
        {
        }

        [Given(/^I have initialised the swf processor correctly$/)]
        public function should_initialise_correctly():void
        {
            _sut = new SwfProcessor();

            // Mock collaborators
            var _mockStepInvoker:IStepInvoker = new MockStepInvoker();
            _mockStepInvoker.applicationDomain = _applicationDomain;
            _mockStepMatcher = new MockStepMatcher( _mockStepInvoker );

            _sut.stepMatcher = _mockStepMatcher;

            // Step Invoker uses the application domain to retrieve the correct class object to invoke functions on it
            // Step matcher adds invokable functions to the step invoker when matches are found at runtime if
            // cucumber asks for them.
            // When cucumber wants to match a step, the step matcher will find it
            // The function that goes with the step is then given to the step invoker
            // the step invoker will give it an id and list its args. This info is sent back to cucumber.
            // When cucumber want to invoke the function it will ask for it by this id and pass the args through too

            _sut.applicationDomain = _applicationDomain;
            _sut.stepDirectoryFiles = getStepsDir();

            // When the swf processor is asked to process the loaded classes it adds the invokable functions
            // ( The ones marked with valid Given, When, Then metadata )
            // to the step matcher so that each function can be found and run on the fly as cucumber requests them
        }

        [Given(/^a loaded swf containing step definitions$/, "async")]
        public function should_have_a_loaded_swf_containing_step_definitions():void
        {
            //  Use as3-commons bytecode reflection to mock a loaded swf containing
            //  classes with step definition metadata
            //  Also note that we must put something in the application domain or
            //  referencing errors will not be raised

            var cm:ClassMaker = new ClassMaker();

            Async.proceedOnEvent( this, cm.abcBuilder, Event.COMPLETE );
            Async.failOnEvent( this, cm.abcBuilder, IOErrorEvent.IO_ERROR );
            Async.failOnEvent( this, cm.abcBuilder, IOErrorEvent.VERIFY_ERROR );

            cm.applicationDomain = _applicationDomain;
            cm.makeStepsClass( "features.step_definitions", _mockClassName );
        }

        [When(/^I process the loaded classes$/,"async")]
        public function should_process_the_loaded_classes():void
        {
            _sut.addEventListener( Event.COMPLETE, onSwfProcessorComplete );
            _sut.addEventListener( ErrorEvent.ERROR, onSwfProcessorError );

            _sut.processLoadedClasses();
        }

        [Then(/^I will have steps for cucumber to match$/)]
        public function should_have_steps_for_cucumber_to_match():void
        {
            assertThat( ( _mockStepMatcher as MockStepMatcher ).verifyInvokableSteps(), isTrue() );
        }

        [Then(/^it will exit cleanly and confirm (success|that the class is missing)$/)]
        public function should_exit_cleanly_and_confirm_status( status:String ):void
        {
            // Exit cleanly means no exceptions to catch

            if( status == "success" )
            {
                assertThat( _goodComplete, isTrue() );
            }
            else if( status == "that the class is missing" )
            {
                assertThat( _errorComplete, isTrue() );
                assertThat( _errorMessage, containsString( "not compiled into suite" ) );
            }
            else
            {
                throw new Error( "Unknown status: " + status );
            }
        }

        [Given(/^an ActionScript class file is missing from the suite of step definitions$/)]
        public function should_ensure_file_is_missing():void
        {
            _sut.stepDirectoryFiles = getStepsDir( false );
        }

//       Support

        private function onSwfProcessorComplete( event:Event ):void
        {
            _goodComplete = true;
        }

        private function onSwfProcessorError( event:ErrorEvent ):void
        {
            _errorMessage = event.text;
            _errorComplete = true;
        }

        private function getStepsDir( good:Boolean = true ):Array
        {
            var stepsFiles:Array = [_mockClassName];

            if(!good)
            {
                stepsFiles.push( "Missing_Class_Steps" );
            }

            _filehelper = new FileHelper();

            return _filehelper.getStepsDir( stepsFiles );
        }

        override public function destroy():void
        {
            super.destroy();

            _sut.removeEventListener( Event.COMPLETE, onSwfProcessorComplete );
            _sut.removeEventListener( ErrorEvent.ERROR, onSwfProcessorError );

            _sut.destroy();
            _sut = null;
            _mockStepMatcher = null;
            _applicationDomain = null;
            _mockClassName = null;
            _errorMessage = null;
            
            _filehelper.destroy();
            _filehelper = null;

        }
    }
}
