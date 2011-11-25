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

import com.flashquartermaster.cuke4as3.Cuke4AS3;
import com.flashquartermaster.cuke4as3.process.Process;
import com.flashquartermaster.cuke4as3.utilities.Pending;
import com.flashquartermaster.cuke4as3.utilities.StepsBase;
    import com.flashquartermaster.cuke4as3.utilities.Table;
    import com.furusystems.logging.slf4as.global.debug;

    import features.support.FixtureConfig;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TextEvent;
import flash.filesystem.File;
    import flash.system.Capabilities;

    import org.flexunit.async.Async;
import org.hamcrest.assertThat;
import org.hamcrest.object.isTrue;

public class Core_Steps extends StepsBase
{

	private var _sut:Cuke4AS3;

	private var _shellData:Vector.<String> = new Vector.<String>();
	private var _cucumberComplete:Boolean = false;
	private var _cukeError:Boolean = false;
	private var _compilerEvent:Boolean = false;
	private var _cucumberEvent:Boolean = false;
	private var _swfLoaderEvent:Boolean = false;
	private var _wireServerEvent:Boolean = false;

	public function Core_Steps()
	{
	}

	[Given (/^Cuke4AS3 is set up correctly$/,"async")]
	public function cuke4as3_should_be_set_up_correctly():void
	{
		_sut = new Cuke4AS3( true );
        // Despite the fact that this has no UI we tell the app that it does so that
        // it does not run the onInvoke function used for commandline runs
		Async.failOnEvent( this, _sut, ErrorEvent.ERROR );
		_sut.init();
	}

	[When (/^I run it against the Calculator example$/,"async")]
	public function should_run_the_calculator_example():void
	{
		_sut.cucumberProcess.addEventListener( Process.SHELL_DATA_EVENT, onCucumberShellData );
		_sut.compilerProcess.addEventListener( Event.COMPLETE, onCompilerProcessComplete );
		_sut.swfLoader.addEventListener( Event.COMPLETE, onSwfLoaderComplete );
		_sut.cuke4AS3Server.addEventListener( Event.COMPLETE, onServerRunning );
		_sut.cucumberProcess.addEventListener( Event.COMPLETE, onCucumberProcessComplete );

        Async.proceedOnEvent( this, _sut.cucumberProcess, Event.COMPLETE, 10 * 1000 );
		// In actual fact the process is complete when cucumber closes its connection
        // which can be seen in the Developer UI implementation however we need to go
        // through a couple of steps to achieve this
        // Listen to the ServerSocketConnectEvent.CONNECT on cuke4AS3Server.server once
        // it is running then listen to Event.CLOSE on cuke4AS3Server.cucumber.socket
        // TODO: This could have a nicer API
        //  Async.proceedOnEvent( this, _sut.cuke4AS3Server.cucumber.socket, Event.CLOSE );

        _sut.srcDir = FixtureConfig.EXAMPLE_CALCULATOR_DIR;
		_sut.mxmlcPath = FixtureConfig.MXMLC_EXE;
		_sut.cucumberPath = FixtureConfig.CUCUMBER_EXE;
		_sut.mxmlcArgs = "";
		_sut.cucumberArgs = "";

        if( Capabilities.os.indexOf("Windows") != -1 )
        {
            _sut.cucumberArgs = FixtureConfig.WIN_CUCUMBER_EXE;
        }
        else
        {
            _sut.cucumberArgs = "";
        }

		_sut.run();
	}

	[Then (/^the cucumber process exits without error$/)]
	public function cucumber_should_exit_without_error():void
	{
		assertThat( _cucumberComplete, isTrue() );
	}

	[Then (/^the output from cucumber contains$/)]
	public function output_should_contain( data:Array ):void
	{
        var table:Table = new Table( data );
        
		var i:uint = _shellData.length;
		var b:Boolean = false;

        var shellData:String;

		while( --i > -1 )
		{
            shellData = _shellData[i];
			b = ( shellData.indexOf( table.getItem(0,0) )  > -1 ) && ( shellData.indexOf( table.getItem(0,1) )  > -1);
			if(b) break;
		}

		assertThat( b, isTrue() );
	}

	[When (/^I run it without correctly configuring it$/,"async")]
	public function should_not_run_when_incorrectly_configured():void
	{
		_sut.addEventListener( ErrorEvent.ERROR, onCuke4AS3Error );
		Async.proceedOnEvent( this,_sut, ErrorEvent.ERROR, 1 * 1000 );
		_sut.run();
	}

	[Then (/^an error is raised$/)]
	public function error_should_be_raised():void
	{
		assertThat( _cukeError, isTrue() );
	}

	[Then (/^I receive events from (?:the\s)?"([^"]*)"/)]
	public function should_receive_event_from_the_compiler( component:String ):void
	{
		switch( component )
		{
			case "compiler":
				assertThat( _compilerEvent, isTrue() );
				break;
			case "swf loader":
				assertThat( _swfLoaderEvent, isTrue() );
				break;
			case "wire server":
				assertThat( _wireServerEvent, isTrue() );
				break;
			case "cucumber":
				assertThat( _cucumberEvent, isTrue() );
				break;
			default:
				throw new Error("Unexpected input: " + component);
				break;
		}
	}

	override public function destroy():void
	{
        super.destroy();

        _sut.cucumberProcess.removeEventListener( Process.SHELL_DATA_EVENT, onCucumberShellData );
        _sut.compilerProcess.removeEventListener( Event.COMPLETE, onCompilerProcessComplete );
        _sut.swfLoader.removeEventListener( Event.COMPLETE, onSwfLoaderComplete );
        _sut.cuke4AS3Server.removeEventListener( Event.COMPLETE, onServerRunning );
        _sut.onExiting();
		_sut = null;
		_shellData = null;
	}

	//Support

	private function onCucumberShellData( event:TextEvent ):void
	{
		_shellData.push(event.text);
	}

	private function onCucumberProcessComplete( event:Event ):void
	{
		_cucumberComplete = true;
		_cucumberEvent = true;
	}

	private function onCuke4AS3Error( event:ErrorEvent ):void
	{
		_cukeError = true;
	}

	private function onCompilerProcessComplete( event:Event ):void
	{
		_compilerEvent = true;
	}

	private function onSwfLoaderComplete( event:Event ):void
	{
		_swfLoaderEvent = true;
	}

	private function onServerRunning( event:Event ):void
	{
		_wireServerEvent = true;
	}
}
}
