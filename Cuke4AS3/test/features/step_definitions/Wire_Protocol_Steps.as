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
import com.flashquartermaster.cuke4as3.utilities.StepsBase;
import com.furusystems.logging.slf4as.global.debug;
	
	import flash.filesystem.File;

	public class Wire_Protocol_Steps extends StepsBase
	{
		public function Wire_Protocol_Steps()
		{
		}
		
		private var _workingDir:File;
		
//		Background:
//		Given a standard Cucumber project directory structure
		[Given (/^a standard Cucumber project directory structure$/)]
		public function background_standardCucumberProjectStructure():void
		{
			debug( "*** Wire_Protocol_Steps : background_standardCucumberProjectStructure :",File.applicationDirectory.nativePath);
			_workingDir = File.applicationDirectory;
			
			var featuresDir:File = new File( _workingDir.nativePath + File.separator + "features" );
			
			if( featuresDir.exists )
				featuresDir.deleteDirectory( true );
			
			featuresDir.createDirectory();
			
			var stepsDir:File = new File( featuresDir.nativePath + File.separator + "step_definitions" );
			stepsDir.createDirectory();
			
			var supportDir:File = new File( featuresDir.nativePath + File.separator + "support" );
			supportDir.createDirectory();
		}
		
//		And a file named "features/step_definitions/some_remote_place.wire" with:
		[Given (/^a file named "([^"]*)" with:$/)]
		public function background_writeFileWith( fileName:String, fileContent:String ):void
		{
			debug( "*** Wire_Protocol_Steps : writeFileWith : ",fileName,fileContent);
//			var wireFile:File = new File( _workingDir
		}
//		Given /^a file named "([^"]*)" with:$/ do |file_name, file_content|
//		  create_file(file_name, file_content)
//		end
//		"""
//		Feature: High strung
//		Scenario: Wired
//		Given we're all wired
//		
//		"""
//		And a file named "features/step_definitions/some_remote_place.wire" with:
//		"""
//		host: localhost
//		port: 54321
//		
//		"""

    override public function destroy():void
    {
        super.destroy();
    }
}
}