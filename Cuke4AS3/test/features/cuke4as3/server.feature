@wire_server @net
Feature: The Wire Server
    In order to implement the wire protocol
    I need to have a server that cucumber can connect to

    Background:
        Given I have initialised the server on:
            | host          | port      |
            | 127.0.0.1     | 54323     |

    Scenario: Server Happy Path
        When I run the server
        Then it reports that it is running successfully

     Scenario: Happy Path with connection
        Given it is running successfully
        When cucumber connects to it
        Then cucumber communicates with the server

    Scenario: Multiple sequential connections
       Given it is running successfully
       When cucumber connects to it
       And cucumber communicates with the server
       And cucumber closes its connection
       And cucumber reconnects to it
       Then cucumber communicates with the server

    Scenario: Accept multiple connections
        #TODO

    #Running against multiple projects can mean that the wire
    #file contents change so the server need to adapt to this

    Scenario Outline: Change host and port information
        Given it is running successfully
        When I specify a different <item> of <value>
        And I run the server
        Then the server listens on <item> <value>

    Examples:
        | item          | value             |
        | host          | 0.0.0.0           |
        | port          | 54324             |
        | host & port   | 0.0.0.0:54325     |

