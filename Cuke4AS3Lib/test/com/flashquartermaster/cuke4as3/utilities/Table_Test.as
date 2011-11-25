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
package com.flashquartermaster.cuke4as3.utilities{
	import com.flashquartermaster.cuke4as3.utilities.Table;
	
	import org.flexunit.asserts.fail;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.not;
	import org.hamcrest.number.greaterThanOrEqualTo;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.instanceOf;
	import org.hamcrest.object.notNullValue;
	import org.hamcrest.object.nullValue;

	public class Table_Test
	{		
		private var _sut:Table;
		
		private var _oneByOneTable:Array;
		private var _twoByTwoTableRow0ColumnHeaders:Array;
		private var _threeByThreeTableRow0columnHeaders:Array;
		
		private var _twoByTwoTableColumn0ColumnHeaders:Array;
		private var _threeByThreeTableColumn0ColumnHeaders:Array;
		
		[Before]
		public function setUp():void
		{
			_oneByOneTable = [ ["Column A"] ];
			
			_twoByTwoTableRow0ColumnHeaders = [ ["Column A","Column B"],["Item A 1","Item B 1"] ];
			_threeByThreeTableRow0columnHeaders = [ ["Column A","Column B","Column C"],["Item A 1","Item B 1","Item C 1"],["Item A 2","Item B 2","Item C 2"] ];
			
			_twoByTwoTableColumn0ColumnHeaders = [ ["Column A","Item A 1"],["Column B","Item B 1"] ];
			_threeByThreeTableColumn0ColumnHeaders = [ ["Column A","Item A 1","Item A 2"],["Column B","Item B 1","Item B 2"],["Column C","Item C 1","Item C 2"] ];
		}
		
		[After]
		public function tearDown():void
		{
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
			_sut = new Table();
			
			assertThat( _sut, notNullValue() );
			assertThat( _sut, instanceOf( Table ) );
			assertThat( _sut.toArray(), nullValue() );
		}
		
		[Test]
		public function should_construct_with_argument():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
		}
		
		[Test]
		public function should_construct_and_process_array():void
		{
			_sut = new Table();
//			_sut.processArray(); argument error will not compile
			_sut.processArray( _oneByOneTable );
			
			assertOneByOneTable();
		}
		
		//Rows
		
		[Test]
		public function should_get_Row():void
		{
			_sut = new Table( _twoByTwoTableRow0ColumnHeaders );
			
			assertTwoByTwoTableRow0ColumnHeaders();
			
			var row0:Array = _sut.getRow( 0 );
			
			assertArraysEqual_WithValues( _twoByTwoTableRow0ColumnHeaders[0], row0 );
			
			var row1:Array = _sut.getRow( 1 );
			
			assertArraysEqual_WithValues( _twoByTwoTableRow0ColumnHeaders[1], row1 );
		}
		
		[Test]
		public function should_return_null_for_non_existent_row():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;
			
			assertThat( _sut.toArray(), not( arrayWithSize( greaterThanOrEqualTo(indexOutOfBounds) ) ) );
			
			var rowThatDoesNotExist:Array = _sut.getRow( indexOutOfBounds );
			
			assertThat( rowThatDoesNotExist, not( emptyArray() ) );
			assertThat( rowThatDoesNotExist, nullValue() );
		}
		
		//Row headers
		
		[Test]
		public function should_get_column_headers_from_first_row():void
		{
			_sut = new Table( _twoByTwoTableRow0ColumnHeaders );
			
			assertTwoByTwoTableRow0ColumnHeaders();
			
			var cols:Array = _sut.getHeadersFromFirstRow();//This is the same as getting row 0
			
			assertArraysEqual_WithValues( _twoByTwoTableRow0ColumnHeaders[0], cols );
		}
		
		[Test]
		public function should_return_null_for_non_existent_column_header():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;
			
			assertThat( _sut.toArray(), not( arrayWithSize( greaterThanOrEqualTo(indexOutOfBounds) ) ) );
			
			var headerThatDoesNotExist:Array = _sut.getHeadersFromFirstRow()[ indexOutOfBounds ];
			
			assertThat("Non existent header from row 0", headerThatDoesNotExist, nullValue() );
			
			var headerThatDoesNotExist2:Array = _sut.getHeadersFromFirstColumn()[ indexOutOfBounds ];
			
			assertThat("Non existent header from column 0", headerThatDoesNotExist2, nullValue() );
		}
		
		//Rows by index
		
		[Test]
		public function should_get_row_item_by_column_index():void
		{
			_sut = new Table( _threeByThreeTableRow0columnHeaders );
			
			assertThreeByThreeTableRow0ColumnHeaders();
			
			//Note: the array requires that you grab the row then apply the column index
			//This is the reverse of how it appears in the method
			
			//[ ["Column A","Column B","Column C"],["Item A 1","Item B 1","Item C 1"],["Item A 2","Item B 2","Item C 2"] ]
			
			//First item in first row or the first header
			var item:String = _sut.getItem( 0, 0 );
			var validItem:String = "Column A";
			assertThat( item, equalTo( validItem ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[0][0] ) );
			
			//second item in first column or first item after header
			item = _sut.getItem( 0, 1 );
			validItem = "Item A 1";
			assertThat( item, equalTo( validItem ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[1][0] ) );
			
			//third item in first column
			item = _sut.getItem( 0, 2 );
			validItem = "Item A 2";
			assertThat( item, equalTo( validItem ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[2][0] ) );
			
			//First item in second column or second header
			item = _sut.getItem( 1, 0 );
			validItem = "Column B";
			assertThat( item, equalTo( validItem ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[0][1] ) );
			
			//Second item in second column or first item after header
			item = _sut.getItem( 1, 1 );
			validItem = "Item B 1";
			assertThat( item, equalTo( validItem ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[1][1] ) );
			
			//Third item in second column
			item = _sut.getItem( 1, 2 );
			validItem = "Item B 2";
			assertThat( item, equalTo( validItem ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[2][1] ) );
			
			//first item in third column or third header
			item = _sut.getItem( 2, 0 );
			validItem = "Column C";
			assertThat( item, equalTo( validItem ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[0][2] ) );
			
			//second item in third column or first item after header
			item = _sut.getItem( 2, 1 );
			validItem = "Item C 1";
			assertThat( item, equalTo( validItem ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[1][2] ) );
			
			//third item in third column
			item = _sut.getItem( 2, 2 );
			validItem = "Item C 2";
			assertThat( item, equalTo( validItem ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[2][2] ) );
		}
		
		[Test]
		public function should_return_null_for_get_row_by_non_existent_column_index():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;//table is 1 x 1
			
			//Non existent column, existent row
			var item:String = _sut.getItem( indexOutOfBounds, 0);
			
			assertThat( item, nullValue() );
		}
		
		[Test]
		public function should_return_null_for_get_non_existent_row_by_valid_column_index():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;//table is 1 x 1
			
			//Non existent row
			var item:String = _sut.getItem( 0, indexOutOfBounds );
			
			assertThat( item, nullValue() );
		}
		
		[Test]
		public function should_return_null_for_get_non_existent_row_by_non_existent_column():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;//table is 1 x 1
			
			//Non existent column and row
			var item:String = _sut.getItem( indexOutOfBounds, indexOutOfBounds );
			
			assertThat( item, nullValue() );
		}
		
		//Rows by column names
		
		[Test]
		public function should_get_row_item_by_column_name_where_row_0_are_headers():void
		{
			_sut = new Table( _threeByThreeTableRow0columnHeaders );
			
			assertThreeByThreeTableRow0ColumnHeaders();
			
			//["Column A","Column B","Column C"]
			var firstColumnName:String = "Column A";
			var secondColumnName:String = "Column B";
			var thirdColumnName:String = "Column C";
			
			assertColumnNameEqualsRow0ColumnHeaders( firstColumnName, _threeByThreeTableRow0columnHeaders, 0 );
			
			assertColumnNameEqualsRow0ColumnHeaders( secondColumnName, _threeByThreeTableRow0columnHeaders, 1 );
			
			assertColumnNameEqualsRow0ColumnHeaders( thirdColumnName, _threeByThreeTableRow0columnHeaders, 2 );
			
			//Note: Because the column headers are in row 0
			//item 0 under a column name is item 1 in the original array
			//Hence _threeByThreeTable[1][0] = row 1 first item or 
			//named column row 0
			var firstItemColumnA:String = "Item A 1";
			var item:String = _sut.getRowItemByHeader( firstColumnName, 0 );
			assertThat( item, equalTo( firstItemColumnA ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[1][0] ) );
			
			//Consequently the second item in the named column
			//will be array row 2 first item (0): _threeByThreeTable[2][0] 
			var secondItemColumnA:String = "Item A 2";
			item = _sut.getRowItemByHeader( firstColumnName, 1 );
			assertThat( item, equalTo( secondItemColumnA ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[2][0] ) );
			
			var firstItemColumnB:String = "Item B 1";
			item = _sut.getRowItemByHeader( secondColumnName, 0 );
			assertThat( item, equalTo( firstItemColumnB ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[1][1] ) );
			
			var secondItemColumnB:String = "Item B 2";
			item = _sut.getRowItemByHeader( secondColumnName, 1 );
			assertThat( item, equalTo( secondItemColumnB ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[2][1] ) );
			
			var firstItemColumnC:String = "Item C 1";
			item = _sut.getRowItemByHeader( thirdColumnName, 0 );
			assertThat( item, equalTo( firstItemColumnC ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[1][2] ) );
			
			var secondItemColumnC:String = "Item C 2";
			item = _sut.getRowItemByHeader( thirdColumnName, 1 );
			assertThat( item, equalTo( secondItemColumnC ) );
			assertThat( item, equalTo( _threeByThreeTableRow0columnHeaders[2][2] ) );
		}
		
		[Test]
		public function should_return_null_for_get_row_by_non_existent_column_name_where_row_0_are_headers():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var nonExistentColumnName:String = "Garbage";
			
			assertThat( _sut.getHeadersFromFirstRow(), not( hasItem( nonExistentColumnName ) ) );
			//Non existent column, existent row
			var item:String = _sut.getRowItemByHeader( nonExistentColumnName, 0);
			
			assertThat( item, nullValue() );
		}
		
		[Test]
		public function should_return_null_for_non_existent_row_by_valid_column_name_where_row_0_are_headers():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;//table is 1 x 1
			var validColumnName:String = _sut.getHeadersFromFirstRow()[0];
			//Non existent row
			var item:String = _sut.getRowItemByHeader(validColumnName , indexOutOfBounds );
			
			assertThat( item, nullValue() );
		}
		
		[Test]
		public function should_return_null_for_get_non_existent_row_by_non_existent_column_name_where_row_0_are_headers():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;//table is 1 x 1
			var nonExistentColumnName:String = "Garbage";
			assertThat( _sut.getHeadersFromFirstRow(), not( hasItem( nonExistentColumnName ) ) );
			
			//Non existent column and row
			var item:String = _sut.getRowItemByHeader( nonExistentColumnName, indexOutOfBounds );
			
			assertThat( item, nullValue() );
		}
		
		
		[Test]
		public function should_get_row_item_by_column_name_where_column_0_are_headers():void
		{
			_sut = new Table( _threeByThreeTableColumn0ColumnHeaders );
			
			assertThreeByThreeTableColumn0ColumnHeaders();
			
			//[ ["Column A","Item A 1","Item A 2"],["Column B","Item B 1","Item B 2"],["Column C","Item C 1","Item C 2"] ];
			var firstColumnName:String = "Column A";
			var secondColumnName:String = "Column B";
			var thirdColumnName:String = "Column C";
			
			assertColumnNameEqualsColumn0ColumnHeaders( firstColumnName, _threeByThreeTableColumn0ColumnHeaders, 0 );
			
			assertColumnNameEqualsColumn0ColumnHeaders( secondColumnName, _threeByThreeTableColumn0ColumnHeaders, 1 );
			
			assertColumnNameEqualsColumn0ColumnHeaders( thirdColumnName, _threeByThreeTableColumn0ColumnHeaders, 2 );
			
			//Note: Because the column headers are in column 0
			//item 0 under a column name is item 1 in the original array
			//Hence _threeByThreeTable[1][0] = row 1 first item or 
			//the named column
			var firstItemColumnA:String = "Item A 1";
			var item:String = _sut.getRowItemByHeader( firstColumnName, 0, false );
			assertThat( item, equalTo( firstItemColumnA ) );
			assertThat( item, equalTo( _threeByThreeTableColumn0ColumnHeaders[0][1] ) );
			
			//Consequently the second item in the named column
			//will be array row 0 second item (2): _threeByThreeTableColumn0ColumnHeaders[0][2] 
			var secondItemColumnA:String = "Item A 2";
			item = _sut.getRowItemByHeader( firstColumnName, 1, false);
			assertThat( item, equalTo( secondItemColumnA ) );
			assertThat( item, equalTo( _threeByThreeTableColumn0ColumnHeaders[0][2] ) );
			
			var firstItemColumnB:String = "Item B 1";
			item = _sut.getRowItemByHeader( secondColumnName, 0, false );
			assertThat( item, equalTo( firstItemColumnB ) );
			assertThat( item, equalTo( _threeByThreeTableColumn0ColumnHeaders[1][1] ) );
			
			var secondItemColumnB:String = "Item B 2";
			item = _sut.getRowItemByHeader( secondColumnName, 1, false );
			assertThat( item, equalTo( secondItemColumnB ) );
			assertThat( item, equalTo( _threeByThreeTableColumn0ColumnHeaders[1][2] ) );
			
			var firstItemColumnC:String = "Item C 1";
			item = _sut.getRowItemByHeader( thirdColumnName, 0, false );
			assertThat( item, equalTo( firstItemColumnC ) );
			assertThat( item, equalTo( _threeByThreeTableColumn0ColumnHeaders[2][1] ) );
			
			var secondItemColumnC:String = "Item C 2";
			item = _sut.getRowItemByHeader( thirdColumnName, 1, false );
			assertThat( item, equalTo( secondItemColumnC ) );
			assertThat( item, equalTo( _threeByThreeTableColumn0ColumnHeaders[2][2] ) );
		}
		
		[Test]
		public function should_return_null_for_get_row_by_non_existent_column_name_where_column_0_are_headers():void
		{
			
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var nonExistentColumnName:String = "Garbage";
			
			assertThat( _sut.getHeadersFromFirstColumn(), not( hasItem( nonExistentColumnName ) ) );
			//Non existent column, existent row
			var item:String = _sut.getRowItemByHeader( nonExistentColumnName, 0);
			
			assertThat( item, nullValue() );
		}
		
		[Test]
		public function should_return_null_for_get_non_existent_row_by_valid_column_name_where_column_0_are_headers():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;//table is 1 x 1
			var validColumnName:String = _sut.getHeadersFromFirstColumn()[0];
			//Non existent row
			var item:String = _sut.getRowItemByHeader(validColumnName , indexOutOfBounds );
			
			assertThat( item, nullValue() );
		}
		
		[Test]
		public function should_return_null_for_get_non_existent_row_by_non_existent_column_name_where_column_0_are_headers():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;//table is 1 x 1
			var nonExistentColumnName:String = "Garbage";
			assertThat( _sut.getHeadersFromFirstColumn(), not( hasItem( nonExistentColumnName ) ) );
			
			//Non existent column and row
			var item:String = _sut.getRowItemByHeader( nonExistentColumnName, indexOutOfBounds );
			
			assertThat( item, nullValue() );
		}
		
		//Columns
		
		[Test]
		public function should_get_column():void
		{
			_sut = new Table( _twoByTwoTableColumn0ColumnHeaders );
			
			assertTwoByTwoTableColumn0ColumnHeaders();
			
			var column0:Array = _sut.getColumn( 0 );
			
			//"Column A","Column B"
			var expectedColumn0:Array = [_twoByTwoTableColumn0ColumnHeaders[0][0],_twoByTwoTableColumn0ColumnHeaders[1][0]];
				
			assertArraysEqual_WithValues( expectedColumn0, column0 );
			
			var column1:Array = _sut.getColumn( 1 );
			
			//"Item A 1","Item B 1"
			var expectedColumn1:Array = [_twoByTwoTableColumn0ColumnHeaders[0][1],_twoByTwoTableColumn0ColumnHeaders[1][1]];
			
			assertArraysEqual_WithValues( expectedColumn1, column1 );
		}
		
		[Test]
		public function should_return_null_for_non_existent_column():void
		{
			_sut = new Table( _oneByOneTable );
			
			assertOneByOneTable();
			
			var indexOutOfBounds:int = 2;
			
			assertThat( _sut.toArray(), not( arrayWithSize( greaterThanOrEqualTo(indexOutOfBounds) ) ) );
			
			var columnThatDoesNotExist:Array = _sut.getColumn( indexOutOfBounds );
			
			assertThat( columnThatDoesNotExist, not( emptyArray() ) );
			assertThat( columnThatDoesNotExist, nullValue() );
		}
		
		//Column headers
		
		[Test]
		public function should_get_column_headers_from_first_column():void
		{
			_sut = new Table( _twoByTwoTableColumn0ColumnHeaders );
			
			assertTwoByTwoTableColumn0ColumnHeaders();
			
			var col:Array = _sut.getHeadersFromFirstColumn();//This is the same as getting column 0
			
			//"Column A","Column B"
			var expectedColumn0:Array = [_twoByTwoTableColumn0ColumnHeaders[0][0],_twoByTwoTableColumn0ColumnHeaders[1][0]];
			
			assertArraysEqual_WithValues( expectedColumn0, col );
		}
		
		//Support
		
		private function assertOneByOneTable():void
		{
			assertThat( _sut.toArray(), notNullValue() );
			assertThat( _sut.toArray(), not( emptyArray() ) );
			assertThat( _sut.toArray(), arrayWithSize( 1 ) );
			assertArraysEqual_WithValues( _oneByOneTable, _sut.toArray() );
		}
		
		private function assertTwoByTwoTableRow0ColumnHeaders():void
		{
			assertTwoByTwoTable();
			assertArraysEqual_WithValues( _twoByTwoTableRow0ColumnHeaders, _sut.toArray() );
		}
		
		
		private function assertThreeByThreeTableRow0ColumnHeaders():void
		{
			assertThreeByThreeTable();
			assertArraysEqual_WithValues( _threeByThreeTableRow0columnHeaders, _sut.toArray() );
		}
		
		private function assertTwoByTwoTableColumn0ColumnHeaders():void
		{
			assertTwoByTwoTable();
			assertArraysEqual_WithValues( _twoByTwoTableColumn0ColumnHeaders, _sut.toArray() );
		}
		
		
		private function assertThreeByThreeTableColumn0ColumnHeaders():void
		{
			assertThreeByThreeTable();
			assertArraysEqual_WithValues( _threeByThreeTableColumn0ColumnHeaders, _sut.toArray() );
		}
		
		private function assertTwoByTwoTable():void
		{
			assertThat( _sut.toArray(), notNullValue() );
			assertThat( _sut.toArray(), not( emptyArray() ) );
			assertThat( _sut.toArray(), arrayWithSize( 2 ) );
		}
		
		private function assertThreeByThreeTable():void
		{
			assertThat( _sut.toArray(), notNullValue() );
			assertThat( _sut.toArray(), not( emptyArray() ) );
			assertThat( _sut.toArray(), arrayWithSize( 3 ) );
		}
		
		private function assertArraysEqual_WithValues( testValues:Array, sutValues:Array ):void
		{
			assertThat( sutValues, equalTo( testValues ) );
		}
		
		private function assertColumnNameEqualsRow0ColumnHeaders( columnName:String, array:Array, indexInRowZero:int ):void
		{
			assertThat( columnName, equalTo( array[0][ indexInRowZero ] ) );
			assertThat( columnName, equalTo( _sut.getHeadersFromFirstRow()[ indexInRowZero ] ) );
		}
		
		private function assertColumnNameEqualsColumn0ColumnHeaders( columnName:String, array:Array, indexInColumnZero:int):void
		{
			assertThat( columnName, equalTo( array[indexInColumnZero][ 0 ] ) );
			assertThat( columnName, equalTo( _sut.getHeadersFromFirstColumn()[ indexInColumnZero ] ) );
		}
	}
}