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
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;
    import flash.system.ApplicationDomain;

    import org.flexunit.assertThat;
    import org.flexunit.async.Async;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.text.containsString;

    import support.ClassMaker;

    public class SwfProcessor_Test
    {
        private var _sut:SwfProcessor;

        [Before]
        public function setUp():void
        {
            _sut = new SwfProcessor()
        }

        [After]
        public function tearDown():void
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
            assertThat( _sut, instanceOf( SwfProcessor ) );
            assertThat( _sut, instanceOf( EventDispatcher ) );
        }

        [Test]
        public function should_destroy():void
        {
            _sut.destroy();
        }

        [Test(async)]
        public function should_dispatch_an_error_event_if_not_set_up_correctly():void
        {
            var applicationDomain:ApplicationDomain = new ApplicationDomain( ApplicationDomain.currentDomain );
            _sut.applicationDomain = applicationDomain;

            Async.proceedOnEvent( this, _sut, ErrorEvent.ERROR, 5 * 1000 );

            //You have to put something in the application domain as a referencing error will not
            //be raised on an empty application domain
            var cm:ClassMaker = new ClassMaker();

            Async.failOnEvent( this, cm.abcBuilder, IOErrorEvent.IO_ERROR );
            Async.failOnEvent( this, cm.abcBuilder, IOErrorEvent.VERIFY_ERROR );

            //a valid set of classes loaded into a specific application domain
            cm.applicationDomain = applicationDomain;
            cm.makeStepsClass( "features.step_definitions", "Class_Steps" );

            var f:File = File.createTempDirectory();
            var step:File = new File( f.nativePath + File.separator + "Missing_Steps.as" );
            step.createDirectory();//A directory and not an actionscript file but swf processor is only interested in the name

            _sut.stepDirectoryFiles = [ step ];
            _sut.stepMatcher = new StepMatcher( new StepInvoker() );


            _sut.processLoadedClasses();
        }

        [Test(async)]
        public function should_process_loaded_classes_if_valid_steps_directory_and_application_domain_is_given():void
        {
            //a specific application domain
            var applicationDomain:ApplicationDomain = new ApplicationDomain( ApplicationDomain.currentDomain );
            _sut.applicationDomain = applicationDomain;

            var cm:ClassMaker = new ClassMaker();

            Async.handleEvent( this, cm.abcBuilder, Event.COMPLETE, onClassMakerComplete );
            Async.failOnEvent( this, _sut, ErrorEvent.ERROR );
            Async.failOnEvent( this, cm.abcBuilder, IOErrorEvent.IO_ERROR );
            Async.failOnEvent( this, cm.abcBuilder, IOErrorEvent.VERIFY_ERROR );

            //a valid set of classes loaded into a specific application domain
            cm.applicationDomain = applicationDomain;
            cm.makeStepsClass( "features.step_definitions", "Class_Steps" );

            //An array of file objects that have a names
            //that refers to the classes loaded into the application domain
            var f:File = File.createTempDirectory();
            var step:File = new File( f.nativePath + File.separator + "Class_Steps.as" );
            step.createDirectory();//A directory and not an actionscript file but swf processor is only interested in the name

            _sut.stepDirectoryFiles = [ step ];

            //Any old steps matcher
            _sut.stepMatcher = new StepMatcher( new StepInvoker() );
        }

        private function onClassMakerComplete( event:Event, passThroughData:Object ):void
        {
            _sut.processLoadedClasses();
        }

        [Test]
        public function should_set_stepDirectoryFiles():void
        {
            //This method accepts an array of File objects
            //but does no verification on them
            var files:Array = [File.applicationDirectory, File.desktopDirectory, File.documentsDirectory];
            _sut.stepDirectoryFiles = files;
        }

        [Test]
        public function should_set_stepMatcher():void
        {
            _sut.stepMatcher = new StepMatcher( new StepInvoker() );
        }

        [Test]
        public function should_set_applicationDomain():void
        {
            _sut.applicationDomain = new ApplicationDomain( ApplicationDomain.currentDomain );
        }

        //Support

        private function onExpectedError( event:ErrorEvent, passThroughData:Object ):void
        {
            assertThat( event.type, equalTo( ErrorEvent.ERROR ) );
            assertThat( event.text, containsString( "not compiled into suite" ) );
        }
    }
}