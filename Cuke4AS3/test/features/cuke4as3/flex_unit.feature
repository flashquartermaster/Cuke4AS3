@unit_testing @flex_unit
Feature: Unit Testing Features for FlexUnit
	In order to make make unit test style assertions
	and leverage Asynchronous support
	I want to be able to support FlexUnit

    Background:
        Given an object that dispatches asynchronous events

	Scenario: FlexUnit Async, Async Handler
	    When I listen for an event using an "Async Handler"
	    Then I receive the specified event when it is dispatched

    Scenario: FlexUnit Async, Async Handler Timeout
        When I listen for an event using an "Async Handler" that will timeout
	    Then the timeout method is called

	Scenario: FlexUnit Async, Handle Event
	    When I listen for an event using "Handle Event"
	    Then I receive the specified event when it is dispatched

	Scenario: FlexUnit Async, Handle Event Timeout
	    When I listen for an event using "Handle Event" that will timeout
	    Then the timeout method is called

	Scenario: FlexUnit Async, Delay Call
	    When I delay a call for 1 second
	    Then the delayed call handler is called after 1 second

	Scenario: FlexUnit Async, Fail On Event
	    When I listen for an event using "Fail on event"
	    Then I receive the specified event when it is dispatched

	Scenario: FlexUnit Async, Fail On Event Timeout
	    When I listen for an event using "Fail on event" that will timeout
	    Then the timeout method is called

	Scenario: FlexUnit Async, Proceed On Event
	    When I listen for an event using "Proceed on event"
	    Then there is no timeout

	Scenario: FlexUnit Async, Proceed On Event Timeout
	    When I listen for an event using "Proceed on event" that will timeout
	    Then the timeout method is called

	Scenario: FlexUnit Async, Register Failure Event
	    When I listen for an event using "Register failure event"
	    Then I do not receive the specified event

    Scenario: Flex SDK Async Responder
        When I listen for an event using "Async Responder"
	    Then I receive the specified event when it is dispatched

	Scenario: Flex SDK Async Responder Timeout
	    When I listen for an event using "Async Responder" that will timeout
	    Then the timeout method is called

    Scenario: Flex SDK Async Native Responder
        When I listen for an event using "Async Native Responder"
	    Then I receive the specified event when it is dispatched

	Scenario: Flex SDK Async Native Responder Timeout
	    When I listen for an event using "Async Native Responder" that will timeout
	    Then the timeout method is called

	Scenario: Sequence runner
	    When I use a sequence runner
	    Then the sequence completes successfully

	Scenario: Other - Assume, dataprovider, theories, parameterised
	    When assume, dataprovider, theories and parameterised