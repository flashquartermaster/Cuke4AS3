@unit_testing @ui
Feature: Fluint UI Test Environment
	I want to be able to add visual assets
	In order to verify their behavior

	Scenario: Add Sprite to Display List
		Given I have a visible asset
		When I add it to the UI test environment
		Then it can be seen