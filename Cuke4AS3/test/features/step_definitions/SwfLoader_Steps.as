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
    import com.flashquartermaster.cuke4as3.Config;
    import com.flashquartermaster.cuke4as3.net.BinarySwfLoader;
    import com.flashquartermaster.cuke4as3.utilities.StepsBase;

    import features.support.FixtureConfig;

    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;

    import org.flexunit.async.Async;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.isTrue;

    import support.FileHelper;

    public class SwfLoader_Steps extends StepsBase
    {
        private var _sut:BinarySwfLoader;

        private var _validity:String;
        private var _filehelper:FileHelper;

        private var _goodComplete:Boolean = false;
        private var _errorComplete:Boolean = false;

        public function SwfLoader_Steps()
        {
        }

        [Given(/^I have initialised the swfloader correctly$/)]
        public function should_initialise_correctly():void
        {
            _sut = new BinarySwfLoader();

            _sut.init();

            _sut.addEventListener( Event.COMPLETE, onSwfLoaderComplete );
            _sut.addEventListener( ErrorEvent.ERROR, onSwfLoaderError );
        }

        [Given(/^I have added an? (valid|invalid) path to a swf$/)]
        public function should_add_a_path_to_a_swf( validity:String ):void
        {
            _validity = validity;

            _filehelper = new FileHelper();

            if( validity == "valid" )
            {
                // Please note: This makes a class at runtime and writes the bytes to a tmp swf file that we load in
                _sut.swfToLoad = "file://" + _filehelper.getValidSwfPath( Config.OUTPUT_SWF );
            }
            else if( validity == "invalid" )
            {
                _sut.swfToLoad = "somecrap";
            }
            else
            {
                throw new Error( "Unknown value for validity: " + validity )
            }
        }

        [When(/^I run it I can tell it is running$/,"async")]
        public function should_run():void
        {
            if( _validity == "valid" )
            {
                Async.proceedOnEvent( this, _sut, Event.COMPLETE);
			    Async.failOnEvent( this, _sut, ErrorEvent.ERROR );
            }
            else if( _validity == "invalid" )
            {
                Async.proceedOnEvent( this, _sut, ErrorEvent.ERROR );
                Async.failOnEvent( this, _sut, Event.COMPLETE);
            }

            _sut.load();
            assertThat( _sut.running, isTrue() );
        }

        [Then(/^on completion it exits cleanly and reports (success|the error)$/)]
        public function should_exit_cleanly_and_report_success_status( status:String ):void
        {
//          Exits cleanly means no exceptions to catch

            if( status == "success" )
            {
                assertThat( _goodComplete, isTrue() );
            }
            else if( status == "the error" )
            {
                assertThat( _errorComplete, isTrue() );
            }
            else
            {
                throw new Error( "Unknown status: " + status );
            }
        }

        override public function destroy():void
        {
            super.destroy();

            _sut.removeEventListener( Event.COMPLETE, onSwfLoaderComplete );
            _sut.removeEventListener( ErrorEvent.ERROR, onSwfLoaderError );

            _sut.destroy();
            _sut = null;

            _filehelper.destroy();
			_filehelper = null;
        }

        private function onSwfLoaderComplete( event:Event ):void
        {
            _goodComplete = true;
        }

        private function onSwfLoaderError( event:Event ):void
        {
            _errorComplete = true;
        }
    }
}
