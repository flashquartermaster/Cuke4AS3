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
package com.flashquartermaster.cuke4as3.util
{
	public class StringUtilities
	{
		
		public static function stripSingleQuotesAtStartAndEndOfString( s:String ):String
		{
			var stripped:Object = /^'(.*)'$/.exec( s );
			return stripped[1];
		}
		
		public static function testStripSingleQuotesAtStartAndEndOfString( s:String ):Boolean
		{
			return /^'(.*)'$/.test( s );
		}
		
		public static function isNotNullAndNotEmptyString( s:String ):Boolean
		{
			return (s != null && s != "");
		}
		
		//For grabbing args and paths enclosed in quotes
		public static function stripWhiteSpaceExceptWhereEnclosedBySingleQuotes( s:String ):Array
		{
			return s.match( /'(.*?)'|(\S+)/g );
		}
		
		public static function isActionScriptFileExtension( filename:String ):Boolean
		{
			var len:int = filename.length;
			return ( filename.substring( len - 3, len ).indexOf( ".as" ) == 0 );
		}
		
		public static function getClassNameFromDeclaredBy( className:String ):String
		{
			// e.g. "features.step_definitions::Calculator_Steps">
			var colonReplace:RegExp = /::/g;
			className = className.replace( colonReplace, "." );
			return className;
		}
		
		public static function replaceFilePathWithClassPath( filePath:String, className:String ):String
		{
			//Note: Cross platform
			return filePath.replace( /(\/|\\)/g, "." ) + removeFileExtension( className );
		}
		
		public static function removeFileExtension( fileName:String ):String
		{
			return fileName.replace( /(\..+)$/, "" );
		}
		
		public static function formatStepToFunctionName( s:String ):String
		{
			s = s.toLowerCase();
			s = s.replace( /("|')/g, "" );
			s = s.replace( /\s/g, "_" );
			s = s.replace( /\d+/g, "number" );
			s = s.replace( /:$/, "" );
			return s;
		}
		
		public static function createCapturingGroups( s:String ):String
		{
			s = s.replace( /"[^"]*"/g, "\"([^\"]*)\"" );
			s = s.replace( /\d+/g, "(\\d+)" );
			return s;
		}
		
		public static function getCapturingGroupDataTypes( regExp:String ):Array
		{
			var return_array:Array = [];
			
			var pattern:RegExp = /("\(\[\^"\]\*\)"|\(\\d\+\))/g;
			
			var result:Object = pattern.exec( regExp );
			
			while( result != null )
			{
				if( result[0] == "\"([^\"]*)\"" )
				{
					return_array.push( "String" );
				}
				else if( result[0] == "(\\d+)" )
				{
					return_array.push( "Number" );
				}
				
				result = pattern.exec( regExp );
			}
			
			return return_array;
		}
		
	}
}