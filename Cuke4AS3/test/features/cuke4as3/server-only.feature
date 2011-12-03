@core @reflection @net
Feature: Running in Server Only mode
        In order to run cuke4As3 in server only mode because I am working with cucumber some other way (e.g. commnad line)
        and in no-compile mode because I am compiling my step definitions some other way
        I want to be able to run the the system just using the 'net' and 'reflection' packages

    Scenario: Happy Path
        Given a valid swf is loaded
        And the loaded swf is processed successfully
        When I run the wire server on:
            | host          | port      |
            | 127.0.0.1     | 54322     |
        And cucumber connects to it
        Then I can match a step definition
        And I can invoke the code related to it
        And cucumber can disconnect when it is done