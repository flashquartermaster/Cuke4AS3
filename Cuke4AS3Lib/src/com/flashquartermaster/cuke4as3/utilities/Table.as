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
package com.flashquartermaster.cuke4as3.utilities
{	
	import flash.system.System;
	import flash.utils.Dictionary;

	public class Table
	{
		private var _array:Array;
		private var _row0headers:Dictionary = new Dictionary();
		private var _column0headers:Dictionary = new Dictionary();
		
		public function Table( array:Array = null )
		{
			if( array )
				processArray( array );
		}
		
		public function processArray( array:Array ):void
		{
			_array = array;
//			trace("Table :",_array);
			
			var rowsLength:uint = _array.length;
			var rowItem:*;
			
			var cols:Array = ( _array[0] as Array);
			var columnsLength:uint = cols.length;
			
			for( var i:uint = 0; i < rowsLength; i++ )
			{
				if( i != 0)//Rows 1 onwards
				{
					for( var j:uint = 0; j < columnsLength; j++ )
					{	
						addRowItemToHeader( _row0headers, _array[0][j], _array[i][j] );//All the row items from row 1 onwards are just row items
						
						if( j == 0)
						{
							makeHeader( _column0headers, _array[i][0] );//All items at zero are column headers
						}
						else
						{
							addRowItemToHeader( _column0headers, _array[i][0], _array[i][j] );//All items not at zero are column items
						}
					}
				}
				else
				{
					//process row zero note: not using var i
					
					makeHeader( _column0headers, _array[0][0] );//0,0 is always a column header
					
					for( var k:uint = 0; k < columnsLength; k++ )
					{
						makeHeader( _row0headers, _array[0][k] );//All of row zero are potential column headers

						if( k != 0 )
						{
							addRowItemToHeader( _column0headers, _array[0][0], _array[0][k] );//All the rest of row zero are row items for the column
						}
					}
				}
			}
		}
		
		private function addRowItemToHeader(dict:Dictionary, columnName:String, rowItem:*):void
		{
//			trace("Table: addRowItemToHeader", dict,columnName,rowItem);
			( dict[ columnName ] as Array ).push( rowItem );
		}
		
		private function makeHeader(dict:Dictionary, columnName:String):void
		{
//			trace("Table: makeHeader", dict,columnName);
			dict[ columnName ] = [];
		}
		
		public function  getRow( index:int ):Array
		{
			return _array[index];//Returns null when out of bounds
		}
		
		public function getColumn( index:int ):Array
		{
			var a:Array = [];
			var len:uint = _array.length;
			
			for( var i:uint = 0; i < len; i++ )
			{
				a.push( getRow( i )[index] );
			}
			return a[0] != null ? a : null;//To match getRow return value
		}
		
		public function getHeadersFromFirstRow():Array
		{
			return getRow(0);	
		}
		
		public function getHeadersFromFirstColumn():Array
		{
			return getColumn(0);
		}
		
		public function getItem( column:int, row:int ):String
		{
			var s:String;
			try
			{
				s = _array[ row ][ column ];
				return s;
			}
			catch( error:TypeError )
			{
				//catches use of non existent column
			}
			return s;
		}
		
		public function getRowItemByHeader( column:String, row:int, topRowIsHeaders:Boolean = true ):String
		{
			var s:String;
			try
			{
				if( topRowIsHeaders )
				{
					s = _row0headers[ column ][ row ];
				}
				else
				{
					s = _column0headers[ column ][ row ];
				}
				return s;
			}
			catch( error:TypeError )
			{
				//catches use of non existent column
			}
			
			return s;
		}
		
		public function toArray():Array
		{
			return _array;
		}
		
		public function toString():String
		{
			return _array.toString();
		}
	}
}