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
    import com.flashquartermaster.cuke4as3.util.CucumberMessageMaker;
    import com.flashquartermaster.cuke4as3.vo.MatchInfo;

    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.collection.arrayWithSize;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasProperty;
    import org.hamcrest.object.hasPropertyWithValue;

    public class CucumberMessageMaker_Test
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
		public function should_create_fail_message():void
		{
			//Empty values
			var expectedresult1:Array = ["fail",{"message":"", "exception":"", "backtrace":""}];
			
			var result1:Array = CucumberMessageMaker.failMessage();
			
			assertThat( result1[0], equalTo( "fail" )  );
			assertThat( result1[1], hasPropertyWithValue( "message", "" ) );
			assertThat( result1[1], hasPropertyWithValue( "exception", "" ) );
			assertThat( result1[1], hasPropertyWithValue( "backtrace", "" ) );
			
			//values
			var expectedresult2:Array = ["fail",{"message":"a message", "exception":"ErrorClass", "backtrace":"blah happened at line 4\nin some method dave()\nNot my fault"}];
			
			var result2:Array = CucumberMessageMaker.failMessage("a message", "ErrorClass", "blah happened at line 4\nin some method dave()\nNot my fault");
			
			assertThat( result2[0], equalTo( "fail" )  );
			assertThat( result2[1], hasPropertyWithValue( "message", "a message" ) );
			assertThat( result2[1], hasPropertyWithValue( "exception", "ErrorClass" ) );
			assertThat( result2[1], hasPropertyWithValue( "backtrace", "blah happened at line 4\nin some method dave()\nNot my fault" ) );
			
			//Null values
			var expectedresult3:Array = ["fail",{"message":"", "exception":"", "backtrace":""}];
			
			var result3:Array = CucumberMessageMaker.failMessage(null,null,null);
			
			assertThat( result3[0], equalTo( "fail" )  );
			assertThat( result3[1], hasPropertyWithValue( "message", "" ) );
			assertThat( result3[1], hasPropertyWithValue( "exception", "" ) );
			assertThat( result3[1], hasPropertyWithValue( "backtrace", "" ) );
		}
		
		[Test]
		public function should_create_success_message():void
		{
			var expectedResult:Array = ["success"];
			
			var result:Array = CucumberMessageMaker.successMessage();
			
			assertThat( result, arrayWithSize( 1 ) );
			assertThat( result, array( equalTo("success") ) );
		}
		
		[Test]
		public function should_create_dry_run_success_message():void
		{
			var expectedResult:Array = ["success",[]];
			
			var result:Array = CucumberMessageMaker.dryRunSuccessMessage();
			
			assertThat( result, arrayWithSize( 2 ) );
			assertThat( result, array( equalTo("success"), array() ) );
		}
		
		[Test]
		public function should_create_successful_match_message():void
		{
			var matchInfo:MatchInfo = new MatchInfo();
            matchInfo.id = 6;
            matchInfo.args = [ {"val": "wired", "pos": 15} ];
            matchInfo.className = "features.step_definitions.FeatureFile_Steps";
            matchInfo.regExp = "/^Some regexer said '([^']*)'$/";

			var result:Array = CucumberMessageMaker.foundSuccessfulMatchMessage( matchInfo );
			
			assertThat( result[0], equalTo( "success" )  );
			assertThat( result[1][0], hasPropertyWithValue( "id", 6 ) );
			assertThat( result[1][0], hasProperty( "args") );
			assertThat( result[1][0].args[0], hasPropertyWithValue( "val", "wired" ) );
			assertThat( result[1][0].args[0], hasPropertyWithValue( "pos", 15 ) );
			assertThat( result[1][0], hasPropertyWithValue( "source", "features.step_definitions.FeatureFile_Steps" ) );
			assertThat( result[1][0], hasPropertyWithValue( "regexp", "/^Some regexer said '([^']*)'$/" ) );
		}
		
		[Test]
		public function should_create_pending_message():void
		{
			var expectedresult1:Array = ["pending",""];
			
			var result1:Array = CucumberMessageMaker.pendingMessage();
			
			assertThat( result1[0], equalTo( expectedresult1[0] ) );
			assertThat( result1[1], equalTo( expectedresult1[1] ) );
			
			var message:String = "I'll do it later"
			var expectedresult2:Array = ["pending",message];
			
			var result2:Array = CucumberMessageMaker.pendingMessage( message );
			
			assertThat( result2[0], equalTo( expectedresult2[0] ) );
			assertThat( result2[1], equalTo( expectedresult2[1] ) );
		}
		
		[Test]
		public function should_format_basic_snippet_text_correctly():void
		{
			var value:Object = {"step_keyword":"When","multiline_arg_class":"","step_name":"I have clicked the button"};
			var expected:String = "[When (/^I have clicked the button$/)]\n" +
				"public function should_i_have_clicked_the_button():void\n" +
				"{\n" +
				"\tthrow new Pending(\"Awaiting implementation\");\n" +
				"}";
			
			var result:String = CucumberMessageMaker.snippetTextMessage( value );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_format_step_name_with_quotes_as_capturing_group_and_args_for_snippet_text():void
		{
			var value:Object = {"step_keyword":"When","multiline_arg_class":"","step_name":"I have clicked the \"add\" button"};
			var expected:String = "[When (/^I have clicked the \"([^\"]*)\" button$/)]\n" +
				"public function should_i_have_clicked_the_add_button( s1:String ):void\n" +
				"{\n" +
				"\tthrow new Pending(\"Awaiting implementation\");\n" +
				"}";
			
			var result:String = CucumberMessageMaker.snippetTextMessage( value );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_format_step_name_with_quotes_as_multiple_capturing_groups_with_args_for_snippet_text():void
		{
			var value:Object = {"step_keyword":"When","multiline_arg_class":"","step_name":"I have clicked the \"add\" button \"twice\""};
			var expected:String = "[When (/^I have clicked the \"([^\"]*)\" button \"([^\"]*)\"$/)]\n" +
				"public function should_i_have_clicked_the_add_button_twice( s1:String, s2:String ):void\n" +
				"{\n" +
				"\tthrow new Pending(\"Awaiting implementation\");\n" +
				"}";
			
			var result:String = CucumberMessageMaker.snippetTextMessage( value );
			
			assertThat( result, equalTo( expected ) );
        }
		
		[Test]
		public function should_format_step_name_with_numbers_as_capturing_groups_and_args_for_snippet_text():void
		{
			var value:Object = {"step_keyword":"When","multiline_arg_class":"","step_name":"I have clicked the 5 button 2 times"};
			var expected:String = "[When (/^I have clicked the (\\d+) button (\\d+) times$/)]\n" +
				"public function should_i_have_clicked_the_n_button_n_times( n1:Number, n2:Number ):void\n" +
				"{\n" +
				"\tthrow new Pending(\"Awaiting implementation\");\n" +
				"}";
			
			var result:String = CucumberMessageMaker.snippetTextMessage( value );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_format_step_name_with_mixed_quotes_and_numbers_as_capturing_groups_and_args_for_snippet_text():void
		{
			var value:Object = {"step_keyword":"When","multiline_arg_class":"","step_name":"I have clicked the \"add\" button 2 times"};
			var expected:String = "[When (/^I have clicked the \"([^\"]*)\" button (\\d+) times$/)]\n" +
				"public function should_i_have_clicked_the_add_button_n_times( s1:String, n1:Number ):void\n" +
				"{\n" +
				"\tthrow new Pending(\"Awaiting implementation\");\n" +
				"}";
			
			var result:String = CucumberMessageMaker.snippetTextMessage( value );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_format_function_with_table_arg_and_table_constructor_table_only():void
		{
			var value:Object = {"step_keyword":"When","multiline_arg_class":"Cucumber::Ast::Table","step_name":"I have the following table"};
			var expected:String = "[When (/^I have the following table$/)]\n" +
				"public function should_i_have_the_following_table( array:Array ):void\n" +
				"{\n" +
				"\tvar table:Table = new Table( array );\n" +
				"\tthrow new Pending(\"Awaiting implementation\");\n" +
				"}";
			
			var result:String = CucumberMessageMaker.snippetTextMessage( value );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_format_function_with_additional_table_arg_and_table_constructor():void
		{
			var value:Object = {"step_keyword":"When","multiline_arg_class":"Cucumber::Ast::Table","step_name":"I have clicked the \"add\" button 2 times"};
			var expected:String = "[When (/^I have clicked the \"([^\"]*)\" button (\\d+) times$/)]\n" +
				"public function should_i_have_clicked_the_add_button_n_times( s1:String, n1:Number, array:Array ):void\n" +
				"{\n" +
				"\tvar table:Table = new Table( array );\n" +
				"\tthrow new Pending(\"Awaiting implementation\");\n" +
				"}";
			
			var result:String = CucumberMessageMaker.snippetTextMessage( value );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_format_function_with_docstring_arg_when_docstring_only():void
		{
			var value:Object = {"step_keyword":"When","multiline_arg_class":"Cucumber::Ast::DocString","step_name":"I have the following docstring:"};
			var expected:String = "[When (/^I have the following docstring:$/)]\n" +
				"public function should_i_have_the_following_docstring( docString:String ):void\n" +
				"{\n" +
				"\tthrow new Pending(\"Awaiting implementation\");\n" +
				"}";
			
			var result:String = CucumberMessageMaker.snippetTextMessage( value );
			
			assertThat( result, equalTo( expected ) );
		}
		
		[Test]
		public function should_format_function_with_additional_docstring_arg():void
		{
			var value:Object = {"step_keyword":"When","multiline_arg_class":"Cucumber::Ast::DocString","step_name":"I have clicked the \"add\" button 2 times:"};
			var expected:String = "[When (/^I have clicked the \"([^\"]*)\" button (\\d+) times:$/)]\n" +
				"public function should_i_have_clicked_the_add_button_n_times( s1:String, n1:Number, docString:String ):void\n" +
				"{\n" +
				"\tthrow new Pending(\"Awaiting implementation\");\n" +
				"}";
			
			var result:String = CucumberMessageMaker.snippetTextMessage( value );
			
			assertThat( result, equalTo( expected ) );
		}
	}
}