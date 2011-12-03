@core
Feature: Running the Completed Application

    Considerations:
    Runs within an air application as a library
    Runs from commandline with adl: uses onInvoke to run
    Runs as installed app as air: uses onInvoke to run

    Background:
        Given Cuke4AS3 is set up correctly

    Scenario: Can run the Calculator example successfully
        When I run it against the Calculator example
        Then I receive events from the "compiler"
        And I receive events from the "swf loader"
        And I receive events from the "wire server"
        And I receive events from "cucumber"
        And the cucumber process exits without error

        And the output from cucumber contains
            |2 scenarios (2 passed) |
            |8 steps (8 passed)     |

    Scenario: Can listen for core errors
        When I run it without correctly configuring it
        Then an error is raised

    #Scenario: Can be stopped cleanly when executing