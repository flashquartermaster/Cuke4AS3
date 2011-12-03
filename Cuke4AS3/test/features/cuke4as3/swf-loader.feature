@swf_loader
Feature: Using the SWF Loader
    In order to be able to get references to step definitions
    I want to be able to load a compiled swf that contains step definitions from the filesystem as a binary

    Background:
        Given I have initialised the swfloader correctly

    Scenario: SWF Loader Happy Path
        Given I have added a valid path to a swf
        When I run it I can tell it is running
        #There is no Then step to check it is running because it executes so fast it has
        #stopped by the time the method runs
        And on completion it exits cleanly and reports success

    Scenario: An io error occurs
        Given I have added an invalid path to a swf
        When I run it I can tell it is running
        And on completion it exits cleanly and reports the error

#    Scenario: A security error occurs
#        Given I have added a valid path to a swf outside the security sandbox
#        When I run it
#        Then I can tell it is running
#        And on completion it exits cleanly and reports the error