@core
Feature: Running the Completed Cuke4AS3 Application

    Considerations:
    Runs within an air application as a library
    Runs from commandline with adl: uses onInvoke to run
    Runs as installed app as air: uses onInvoke to run

    Notice:
    Core steps are primarily about how cucumber exits when
    connected or not to the wire server

    Background:
        Given Cuke4AS3 is set up correctly

    Scenario: Can run the Calculator example successfully
        When I run it against the Calculator example
        Then I receive events from the "compiler"
        And I receive events from the "swf loader"
        And I receive events from the "wire server"
        And I receive events from "cucumber"
        And Cuke4AS3 exits cleanly without error

        And the output from cucumber contains
            |2 scenarios (2 passed) |
            |8 steps (8 passed)     |

    Scenario: Can listen for core errors
        When I run it without correctly configuring it
        Then an error is raised

    Scenario: No Scenarios are found to run so Cucumber never connects to the wire server
        When I run it against the Calculator example so that no scenarios run
        Then I receive events from the "compiler"
        And I receive events from the "swf loader"
        And I receive events from the "wire server"
        And I receive events from "cucumber"
        And Cuke4AS3 exits cleanly without error

        And the output from cucumber contains
            |0 scenarios    |
            |0 steps        |

    Scenario: Cucumber encounters fatal errors and ceases execution
        When I run it against the Bad Calculator example
        Then I receive events from the "compiler"
        And I receive events from the "swf loader"
        And I receive events from the "wire server"
        And I receive an error event from "cucumber"
        And Cuke4AS3 exits cleanly without error

    #Scenario: Can be stopped cleanly when executing