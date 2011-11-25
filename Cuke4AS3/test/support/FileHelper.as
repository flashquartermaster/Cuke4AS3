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
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class FileHelper
    {
        private var _tmpDir:File;
        private var _mxmlc:File;
        private var _cucumber:File;

        public function FileHelper()
        {
        }

        public function getValidTmpDirectory():String
        {
            if( _tmpDir == null )
            {
                makeTmpDir();
            }

            return _tmpDir.nativePath;
        }

        public function getMockValidMxmlcExecutable():String
        {
            if( _tmpDir == null )
            {
                makeTmpDir();
            }
            _mxmlc = File.createTempFile(); //new File( _tmpDir.nativePath + File.separator + "mxmlc");
//			_mxmlc.createDirectory();

            return _mxmlc.nativePath;
        }

        public function getMockValidCucumberExecutable():String
        {
            if( _tmpDir == null )
            {
                makeTmpDir();
            }

            _cucumber = File.createTempFile();//new File( _tmpDir.nativePath + File.separator + "cucumber");
//			_cucumber.createDirectory();

            return _cucumber.nativePath;
        }

        private function makeTmpDir():void
        {
            _tmpDir = File.createTempDirectory();
        }

        public function makeValidfeaturesAndSteps():void
        {
            getValidTmpDirectory();

            var feat:File = new File( _tmpDir.nativePath + File.separator + "features" );
            feat.createDirectory();

            var steps:File = new File( feat.nativePath + File.separator + "step_definitions" );
            steps.createDirectory();
        }

        public function makeValidWireFile( host:String, port:int ):void
        {
            makeValidfeaturesAndSteps();

            var wireFile:File = new File( _tmpDir.nativePath + File.separator
                                                  + "features" + File.separator + "step_definitions" ).resolvePath( "com.flashquartermaster.cuke4as3.Cuke4AS3.wire" );

            var stream:FileStream = new FileStream();
            stream.open( wireFile, FileMode.WRITE );
            stream.writeUTFBytes( "host: " + host + "\nport: " + port );
            stream.close();

            wireFile = null;
            stream = null;
        }

        public function getValidSwfPath( name:String, packag:String = "mypackage", clazzName:String = "MyClass" ):String
        {

            getValidTmpDirectory();

            var fullPath:String = _tmpDir.nativePath + File.separator + name;

            var swf:File = new File( fullPath );

            var stream:FileStream = new FileStream();
            stream.open( swf, FileMode.WRITE );

            var cm:ClassMaker = new ClassMaker();
            var ba:ByteArray = cm.makeStepsClassAndGetBytes( packag, clazzName );

            stream.writeBytes( ba );
            stream.close();

            swf = null;
            stream = null;

            return fullPath;
        }

        public function getStepsDir( classNames:Array ):Array
        {
            // Mock the directory structure and files.
            // Return an array of file objects that have a name
            // that refers to the classes loaded into the application domain
            // Using a directory as a mock rather than creating an actionscript file
            // because swf processor is only interested in the name

            var stepsDir:Array = [];

            var tmpStepsDir:File = File.createTempDirectory();
            var i:uint = classNames.length;
            while(--i > -1 )
            {
                var step:File = new File( tmpStepsDir.nativePath + File.separator + classNames[i] + ".as" );
                step.createDirectory();
                stepsDir.push( step );
            }
            return stepsDir;
        }

        public function destroy():void
        {
            if( _tmpDir != null )
            {
                _tmpDir.deleteDirectory( true );//delete dir and contents
                _tmpDir = null
            }

        }
    }
}