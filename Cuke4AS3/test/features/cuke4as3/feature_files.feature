@features
Feature: Features Check File
	As an implementer of the wire protocol
	I want to ensure that I support all the features expected of a feature file
	
	Background:
		Given I run background
		
	Scenario: First Scenario of two
		Given scenario one a
		Then scenario one b
		
	Scenario: Second Scenario of two but with a comment in it
		Given scenario two a
		#A comment
		Then scenario two b
	
	Scenario: Wild card scenario
		* scenario one a
		* scenario two a
		* scenario one b
		* scenario two b
		
	Scenario Outline: A Scenario Outline which uses two sets of examples
	    Given I have entered <input_1>
	    And I have entered <input_2>
	    When I press add
	    Then the current value should be <output>
    
	Examples: First set of inputs
	    | input_1 | input_2 | output |
	    | 1       | 1       | 2      |
	    | 2       | 2       | 4      |
	
	@second_set    
	Examples: Second set of inputs
	    | input_1 | input_2 | output |
	    | 3       | 3       | 6      |
	    | 4	      | 4       | 8      |
		
	Scenario: Multiline table with single column
		Given the following single column table with 2 items
		
		| Item 1	|
		| Item 2	|
		
		Then the items in the table will be "Item 1" and "Item 2"
		
	Scenario: Multiline table with two columns where the top row are the headers
		Given the following table with headers
		
		| Column A 	| Column B 	|
		| Item A 1	| Item B 1	|
		| Item A 2	| Item B 2	|
		
		Then the headings will be "Column A" and "Column B"
		And the first item in "Column A" will be "Item A 1"
		And the second item in "Column A" will be "Item A 2"
		And the first item in "Column B" will be "Item B 1"
		And the second item in "Column B" will be "Item B 2"
	
	Scenario: Multiline table where the first column contains the headers
		Given the following table with headers
		
		| Header A 	| Item A 1 	|
		| Header B	| Item B 1	|
		| Header C	| Item C 1	|
		
		Then the headings will be "Header A" and "Header B" and "Header C"
		And the item for "Header A" will be "Item A 1"
		And the item for "Header B" will be "Item B 1"
		And the item for "Header C" will be "Item C 1"
	
	Scenario: Basic doc string
		Given the following doc string:
		"""
		I am the doc string content
		"""
		Then the doc string contained the "String" "I am the doc string content"
	
	Scenario: Multiline doc string
		Given the following doc string:
		"""
		I am the
		doc string
		content
		"""
		Then the doc string contained the "String" "I am the\ndoc string\ncontent"
		
	Scenario: Xml doc string
		Given the following doc string:
		"""
		<root><item name="dave">some text</item></root>
		"""
		Then the doc string contained the "String" "<root><item name="dave">some text</item></root>"
		And the doc string is valid "xml"
		And the "item" node "content" is "some text"
		And the "item" node "attribute" "name" is "dave"
	
	Scenario: Multiline Xml doc string
		Given the following doc string:
		"""
		<root>
			<item name="dave">some text</item>
		</root>
		"""
		Then the doc string contained the "String" "<root>\n\t<item name="dave">some text</item>\n</root>"
		And the doc string is valid "xml"
		And the "item" node "content" is "some text"
		And the "item" node "attribute" "name" is "dave"
		
	Scenario: JSON doc string
		Given the following doc string:
		"""
		["dave",{"number":1,"string":"String 1"}]
		"""
		Then the doc string contained the "String" "["dave",{"number":1,"string":"String 1"}]"
		And the doc string is valid "JSON"
		And the doc string is an "array"
		And the first item in the array is a "String" "dave"
		And the second item in the array is an "Object"
		And the attribute of the object called "number" is a "Number" "1"
		And the attribute of the object called "string" is a "String" "String 1" 
		