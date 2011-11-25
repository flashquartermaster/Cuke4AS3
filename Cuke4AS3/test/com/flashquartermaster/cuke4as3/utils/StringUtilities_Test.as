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
package com.flashquartermaster.cuke4as3.utils
{
    import com.flashquartermaster.cuke4as3.util.StringUtilities;

    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.collection.arrayWithSize;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;

    public class StringUtilities_Test
	{		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
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
		public function should_strip_single_quotes_at_start_and_end_of_string():void
		{
			var input:String = "'some content 'some content in quotes''";
			var expectedOutput:String = "some content 'some content in quotes'";
			
			var output:String = StringUtilities.stripSingleQuotesAtStartAndEndOfString( input );
			
			assertThat( output, equalTo( expectedOutput ) );
		}
		
		[Test]
		public function should_test_strip_single_quotes_at_start_and_end_of_string():void
		{
			var trueInput:String = "'some content 'some content in quotes''";
			var falseInput:String = "no quotes here";
			
			var result:Boolean = StringUtilities.testStripSingleQuotesAtStartAndEndOfString( trueInput );
			
			assertThat("True Input", result, isTrue() );
			
			result = StringUtilities.testStripSingleQuotesAtStartAndEndOfString( falseInput );
			
			assertThat("False input", result, isFalse() );
		}
		
		[Test]
		public function should_detect_not_null_and_not_empty_string():void
		{
			var invalidInput1:String = null;
			var invalidInput2:String = "";
			var validInput:String = "A";
			
			var willBeFalse:Boolean = StringUtilities.isNotNullAndNotEmptyString( invalidInput1 );
			assertThat("invalid input 1", willBeFalse, isFalse() );
			
			willBeFalse = StringUtilities.isNotNullAndNotEmptyString( invalidInput2 );
			assertThat("Invalid input 2", willBeFalse, isFalse() );
			
			var willBeTrue:Boolean = StringUtilities.isNotNullAndNotEmptyString( validInput );
			assertThat("Valid Input", willBeTrue, isTrue() );
		}
		
		[Test]
		public function should_strip_white_space_except_where_enclosed_by_single_quotes():void
		{
			var testString:String = "-compiler.library-path '/Applications/Adobe Flash Builder 4.5/sdks/4.5.0/frameworks/libs/air/'";
			var result1:String = "-compiler.library-path";
			var result2:String = "'/Applications/Adobe Flash Builder 4.5/sdks/4.5.0/frameworks/libs/air/'";
			
			var result:Array = StringUtilities.stripWhiteSpaceExceptWhereEnclosedBySingleQuotes( testString );
			
			assertThat( result, arrayWithSize( 2 ) );
			assertThat( result, array( equalTo( result1 ), equalTo( result2 ) ) );
		}
		
		[Test]
		public function should_test_if_file_has_actionscript_extension():void
		{
			var valid:String = "filename.as";
			var invalid1:String = "filename.a";
			var invalid2:String = "filename.ass";
			
			var result:Boolean = StringUtilities.isActionScriptFileExtension( valid );
			
			assertThat("Valid file name", result, isTrue() );
			
			var result1:Boolean = StringUtilities.isActionScriptFileExtension( invalid1 );
			
			assertThat("Invalid file name 1", result1, isFalse() );
			
			var result2:Boolean = StringUtilities.isActionScriptFileExtension( invalid2 );
			
			assertThat("Invalid file name 2", result2, isFalse() );
		}
		
		[Test]
		public function should_get_class_name_from_declared_by():void
		{
			var validClassName:String = "features.step_definitions::Calculator_Steps";
			var expectedResult:String = "features.step_definitions.Calculator_Steps";
			
			var result:String = StringUtilities.getClassNameFromDeclaredBy( validClassName );
			assertThat( result, equalTo( expectedResult ) );
			
		}
		
		[Test]
		public function should_replace_file_path_with_class_path():void
		{
			var className:String = "Class_Name.as";
			var winPath:String = "features\\step_definitions\\";//Note the escaped slashes
			var nixPath:String = "features/step_definitions/";
			var expectedResult:String = "features.step_definitions.Class_Name";
			
			var winResult:String = StringUtilities.replaceFilePathWithClassPath( winPath, className );
			var nixResult:String = StringUtilities.replaceFilePathWithClassPath( nixPath, className );
			
			assertThat("Nix result", nixResult, equalTo( expectedResult ) );
			assertThat("Win result", winResult, equalTo( expectedResult ) );
			
		}
		
		[Test]
		public function should_remove_file_extension():void
		{
			var inputValue:String = "My_Class_as.as"
			var expected:String = "My_Class_as"
				
			var result:String = StringUtilities.removeFileExtension( inputValue );
			
			assertThat( result, equalTo( expected ) ) ;
		}
		
		[Test]
		public function should_convert_string_to_lower_case_and_insert_underscores_in_place_of_spaces_and_strip_quotes():void
		{
			var inputValue:String = "I am 'a' STRING in \"need\" of 1 conversion";
			var expected:String = "i_am_a_string_in_need_of_number_conversion";
			
			var result:String = StringUtilities.formatStepToFunctionName( inputValue );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_convert_text_in_quotes_to_reg_exp_capturing_group():void
		{
			var inputValue:String = "I click the \"add\" button \"twice\"";
			var expected:String = "I click the \"([^\"]*)\" button \"([^\"]*)\"";
			
			var result:String = StringUtilities.createCapturingGroups( inputValue );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_convert_numbers_to_reg_exp_capturing_group():void
		{
			var inputValue:String = "I enter 6 and 5";
			var expected:String = "I enter (\\d+) and (\\d+)";
			
			var result:String = StringUtilities.createCapturingGroups( inputValue );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_convert_text_in_quotes_and_numbers_to_reg_exp_capturing_group():void
		{
			var inputValue:String = "I click the \"add\" button 2 times";
			var expected:String = "I click the \"([^\"]*)\" button (\\d+) times";
			
			var result:String = StringUtilities.createCapturingGroups( inputValue );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_return_no_data_types_when_there_are_no_capturing_groups():void
		{
			var inputValue:String = "I click the \"add\" button 2 times";
			var expectedArray:Array = [];
			var expectedNumber:int = 0;
			
			var result:Array = StringUtilities.getCapturingGroupDataTypes( inputValue );
			
			assertThat( result, arrayWithSize( expectedNumber ) );
			assertThat( result, equalTo( expectedArray ) );
		}
		
		[Test]
		public function should_return_data_types_for_capturing_groups():void
		{
			var inputValue:String = "I click the \"([^\"]*)\" button (\\d+) times";
			var expectedArray:Array = ["String","Number"];
			var expectedNumber:int = 2;
			
			var result:Array = StringUtilities.getCapturingGroupDataTypes( inputValue );
			
			assertThat( result, arrayWithSize( expectedNumber ) );
			assertThat( result, equalTo( expectedArray ) );
		}
	}
}