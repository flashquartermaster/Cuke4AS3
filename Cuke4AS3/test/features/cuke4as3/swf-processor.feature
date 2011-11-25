@reflection @swf_processor
Feature: SWF Processor Features
    In order to be able to match step definitions when cucumber asks for them
    I want to be able to analyse the step definitions and store them for future reference

    Background:
        Given I have initialised the swf processor correctly
        And a loaded swf containing step definitions

    Scenario: SWF Processor Happy Path
        When I process the loaded classes
        Then I will have steps for cucumber to match
        And it will exit cleanly and confirm success

    #Is this a millstone or a necessity?
    Scenario: An error occurs because you have not added a steps class to the suite
        Given an actionscript class file is missing from the suite of step definitions
        When I process the loaded classes
        Then it will exit cleanly and confirm that the class is missing