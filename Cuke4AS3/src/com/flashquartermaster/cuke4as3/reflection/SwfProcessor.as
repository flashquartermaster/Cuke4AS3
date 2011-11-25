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
    import com.flashquartermaster.cuke4as3.Config;
    import com.flashquartermaster.cuke4as3.util.StringUtilities;
    import com.furusystems.logging.slf4as.global.debug;
    import com.furusystems.logging.slf4as.global.error;
    import com.furusystems.logging.slf4as.global.info;

    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.system.ApplicationDomain;
    import flash.utils.describeType;

    public class SwfProcessor extends EventDispatcher
    {
        private var _stepDirectoryFiles:Array;
        private var _applicationDomain:ApplicationDomain;
        private var _stepMatcher:IStepMatcher;

        public function SwfProcessor()
        {
        }

        public function processLoadedClasses():void
        {
            var stepFile:File;
            var name:String;

            try
            {
                //Read the files in the directory to ensure that they have been compiled into the suite
                for( var i:uint = 0; i < _stepDirectoryFiles.length; i++ )
                {
                    stepFile = ( _stepDirectoryFiles[i] as File );

                    name = stepFile.name;

                    if( isActionScriptFile( name ) && isNotSuite( name ) )
                    {
                        processStepClass( getFullyQualifiedClassName( name ) );
                    }
                }

                dispatchEvent( new Event( Event.COMPLETE ) );
            }
            catch( e:Error )
            {
                error( "SwfProcessor : processLoadedClasses :", e );
                var message:String = getFullyQualifiedClassName( name ) + " not compiled into suite : " + e.message;
                dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, message ) );
            }
        }

        private function getFullyQualifiedClassName( name:String ):String
        {
            //When we come to use sub directories this should be
            //File.nativePath with the srcDir path removed instead of
            //Config.STEP_DEFINITIONS_DIR
            return StringUtilities.replaceFilePathWithClassPath( Config.STEP_DEFINITIONS_DIR, name );
        }

        private function isActionScriptFile( name:String ):Boolean
        {
            return StringUtilities.isActionScriptFileExtension( name );
        }

        private function isNotSuite( name:String ):Boolean
        {
            return name.indexOf( StringUtilities.removeFileExtension( Config.SUITE_NAME ) ) == -1;
        }

        private function processStepClass( fullyQualifiedClassName:String ):void
        {
            //FP incubator: ApplicationDomain.getDefinitions();

            var clazz:Class = _applicationDomain.getDefinition( fullyQualifiedClassName ) as Class;//Throws a reference error if not found

            var classDescription:XML = describeType( clazz );

            //NOTE: Works only if there is one metadata node per method!
            //This needs changing but at the moment YAGNI
            if( _stepMatcher.matchableSteps != null )
            {
                _stepMatcher.matchableSteps += classDescription..method.( hasOwnProperty( "metadata" ) && ( metadata.@name == "Given" || metadata.@name == "When" || metadata.@name == "Then" ) );
            }
            else
            {
                _stepMatcher.matchableSteps = classDescription..method.( hasOwnProperty( "metadata" ) && ( metadata.@name == "Given" || metadata.@name == "When" || metadata.@name == "Then" ) );
            }
        }

        public function set stepDirectoryFiles( value:Array ):void
        {
            _stepDirectoryFiles = value;
        }

        public function set applicationDomain( value:ApplicationDomain ):void
        {
            _applicationDomain = value;
        }

        public function set stepMatcher( value:IStepMatcher ):void
        {
            _stepMatcher = value;
        }

        public function destroy():void
        {
            info( "SwfProcessor : destroy" );
            _stepDirectoryFiles = null;
            _applicationDomain = null;
            _stepMatcher = null;
        }
    }
}