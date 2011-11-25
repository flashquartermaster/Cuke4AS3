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
	import com.adobe.serialization.json.JSON;
	import com.flashquartermaster.cuke4as3.utilities.Pending;
import com.flashquartermaster.cuke4as3.utilities.StepsBase;
import com.flashquartermaster.cuke4as3.utilities.Table;
	
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.collection.everyItem;
	import org.hamcrest.core.allOf;
	import org.hamcrest.core.anyOf;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.instanceOf;
	import org.hamcrest.object.isTrue;
	import org.hamcrest.object.nullValue;
	
	public class Feature_Files_Steps extends StepsBase
	{
		public function Feature_Files_Steps()
		{
			super();
		}
		
		private var _backgroundRun:String = "Not run";
		//Note: Object is destroyed after each scenario so this will be reset
		
		//Background:
		
		[Given ( /^I run background$/ )]
		public function background():void
		{
			assertThat( true, isTrue() );
			_backgroundRun = "is run";
		}
		
		//Scenario: First Scenario of two
		
		[Given ( /^scenario one a$/ )]
		public function one_A():void
		{
			assertThat( true, isTrue() );
			assertThat( _backgroundRun, equalTo( "is run" ) );
		}
		
		[Then (/^scenario one b$/)]
		public function one_B():void
		{
			assertThat( true, isTrue() );
		}
		
		//Scenario: Second Scenario of two
		
		[Given ( /^scenario two a$/ )]
		public function two_A():void
		{
			assertThat( true, isTrue() );
			assertThat( _backgroundRun, equalTo( "is run" ) );
		}
		
		[Then (/^scenario two b$/)]
		public function two_B():void
		{
			assertThat( true, isTrue() );
		}
		
		//Scenario Outline: A Scenario Outline which uses two sets of examples
		
		private var _stack:Vector.<Number> = new Vector.<Number>();
		private var _addResult:Number;
		
		[Given (/^I have entered (\d+)$/)]
		public function outline_input( n:Number ):void
		{
			assertThat( _backgroundRun, equalTo( "is run" ) );
			assertThat( n, instanceOf( Number ) );
			_stack.push( n );
		}
		
		[When (/^I press (\w+)$/)]
		public function outline_press( s:String ):void
		{
			assertThat( s, instanceOf( String ) );
			assertThat( s, anyOf( equalTo( "add" ) ) );
			_addResult = _stack[0] + _stack[1];
		}
		
		[Then (/^the current value should be (.*)$/)]
		public function outline_result( n:Number ):void
		{
			assertThat( n, instanceOf( Number ) );
			assertThat( n, equalTo( _addResult ) );
		}
		
		//Scenario: Multiline table with single column
		
		private var _singleColumnTable:Table;
		
		[Given (/^the following single column table with (\d+) items$/ )]
		public function single_column_table( numItems:Number, data:Array ):void
		{
			assertThat( _backgroundRun, equalTo( "is run" ) );
			//Note: This is a multidimentional array and always comes last in the args list
			assertThat( data, instanceOf( Array ) );
			assertThat( data, not( emptyArray() ) );
			assertThat( data, arrayWithSize( numItems ) );
			assertThat( data, everyItem( isA( Array) ) );//Only contains arrays
			
			_singleColumnTable = new Table( data );
		}

		[Then (/^the items in the table will be "([^"]*)" and "([^"]*)"$/)]
		public function items_in_table_are( item1:String, item2:String ):void
		{
			assertThat( _singleColumnTable.toArray(), array( equalTo( [item1] ), equalTo( [item2] ) ) );
			
			var s1:String = _singleColumnTable.getItem(0,0);
			assertThat( s1, equalTo( item1 ) );
			
			var s2:String = _singleColumnTable.getItem(0,1);
			assertThat( s2, equalTo( item2 ) );
		}
		
		//Scenario: Multiline table with two columns where the top row are the headers
		
		private var _twoColumnTable:Table;
		
		[Given (/^the following table with headers$/) ]
		public function multi_column_table_with_headers( data:Array ):void
		{
			assertThat( _backgroundRun, equalTo( "is run" ) );
			_twoColumnTable = new Table( data );
		}

		[Then (/^the headings will be "([^"]*)" and "([^"]*)"$/)]
		public function the_headings_are( item1:String, item2:String ):void
		{
			assertThat( _twoColumnTable.getHeadersFromFirstRow()[0], equalTo( item1 ) );
			assertThat( _twoColumnTable.getHeadersFromFirstRow()[1], equalTo( item2 ) );
		}
		
		[Then (/^the (\w+) item in "([^"]*)" will be "([^"]*)"$/)]
		public function item_in_column( itemNum:String, columnName:String, item:String ):void
		{	
			if( itemNum == "first" )
			{
				assertThat( _twoColumnTable.getRowItemByHeader( columnName, 0 ), equalTo( item ) );
			}
			else if( itemNum == "second" )
			{
				assertThat( _twoColumnTable.getRowItemByHeader( columnName, 1) , equalTo( item ) );
			}
			else
			{
				fail("Unknown item number " + itemNum );
			}
		}
		
		//Scenario: Multiline table where the first column contains the headers
		
		[Then (/^the headings will be "([^"]*)" and "([^"]*)" and "([^"]*)"$/)]
		public function the_headings_will_be( a:String, b:String, c:String ):void
		{
			assertThat( a, equalTo( _twoColumnTable.getHeadersFromFirstColumn()[0] ) );
			assertThat( b, equalTo( _twoColumnTable.getHeadersFromFirstColumn()[1] ) );
			assertThat( c, equalTo( _twoColumnTable.getHeadersFromFirstColumn()[2] ) );
		}
		[Then (/^the item for "([^"]*)" will be "([^"]*)"$/)]
		public function the_item_will_be( a:String, b:String ):void
		{
			assertThat( _twoColumnTable.getRowItemByHeader( a, 0, false ), equalTo( b ) );
		}
		
		//Scenario: Basic doc string
		
		private var _docString:String;
		
		[Given (/^the following doc string:$/)]
		public function get_doc_string( docString:String ):void
		{	
			assertThat( _docString, nullValue() );
			
			_docString = docString;
			
			assertThat( _docString, equalTo( docString )  );
		}

		[Then (/^the doc string contained the "([^"]*)" "(.*)"$/)]
		public function the_doc_string_contained( type:String, docString:String ):void
		{
			//Note: When I pass in a string with newline or tab characters instead
			//of a doc string the newline characters will be escaped
			docString = docString.replace( /\\n/g, "\n" );
			docString = docString.replace( /\\t/g, "\t" );
			
			if( type == "String" )
			{
				assertThat( docString, equalTo( _docString ) );
			}
			else
			{
				fail("Unknown type : " + type);
			}
		}
		
		//Scenario: Xml doc string
		private var _xml:XML;
		private var _json_array:Array;
		
		
		[Then (/^the doc string is (?:valid|an) "([^"]*)"$/)]
		public function the_doc_string_is( type:String ):void
		{
			if( type == "xml" )
			{
				_xml = new XML( _docString );//Throws a Type Error if it is not a valid xml string
			}
			else if( type == "JSON" )
			{
				_json_array = JSON.decode( _docString );//Throws a JSONParseError if there is a problem
			}
			else if( type == "array" )
			{
				if( !_json_array is Array )
					throw new Error("Not an Array");
			}
			else
			{
				fail("Unknown type : " + type);
			}
		}
		
		[Then (/^the "([^"]*)" node "(content|attribute)"\s?(?:"([^"]*)")? is "([^"]*)"$/)]
		public function the_node_values_are( nodeName:String, type:String, attributeName:String, result:String ):void
		{	
			if( type == "content" )
			{
				assertThat("Contains node \"" + nodeName +"\"", _xml.hasOwnProperty( nodeName ) );
				assertThat( _xml[nodeName], equalTo( result ) );
			}
			else if( type == "attribute" )
			{
				assertThat(_xml[ nodeName ].@[ attributeName ], equalTo( result ) );
			}
		}
		
		[Then (/^the (.*) item in the array is (?:a|an) "([^"]*)"\s?(?:"([^"]*)")?$/)]
		public function the_item_in_the_array_is( increment:String, type:String, value:String ):void
		{
			var val:*;
			
			if( increment == "first" )
			{
				val = _json_array[0];
			}
			else if( increment == "second" )
			{
				val = _json_array[1];
			}
			else
			{
				fail( "Invalid increment : " + increment );
			}
			
			if( type == "String" )
			{
				assertThat( val, instanceOf( String ) );
				assertThat( ( val as String ), equalTo( value ) );
			}
			else if( type == "Object" )
			{
				assertThat( val, instanceOf( Object ) );
				assertThat( val, not( instanceOf( Array ) ) );//Could do this a lot ;)
			}
			else
			{
				fail("Unknown type : " + type);
			}
				
		}
		
		[Then (/^the attribute of the object called "([^"]*)" is a "([^"]*)" "([^"]*)"$/)]
		public function the_object_attribute_is( attributeName:String, objectType:String, expectedValue:String ):void
		{
			var value:* = ( _json_array[1] as Object )[ attributeName ];
			
			if( objectType == "Number" )
			{
				assertThat( value, instanceOf( Number ) );
				var castToNumber:Number = Number( expectedValue );
				assertThat( value, allOf( equalTo( expectedValue ), equalTo( castToNumber ) ) );
			}
			else if( objectType == "String" )
			{
				assertThat( value, instanceOf( String ) );
				var castToString:String = expectedValue.toString();
				assertThat( value, allOf( equalTo( expectedValue ), equalTo( castToString ) ) );
			}
			else
			{
				fail( "Unknown Object Type : " + objectType );
			}
		}
		
		override public function destroy():void
		{
			_addResult = 0;
			_backgroundRun = null;
			_docString = null;
			_json_array = null;
			_singleColumnTable = null;
			_stack = null;
			_twoColumnTable = null;
			_xml = null;
		}
	}
}