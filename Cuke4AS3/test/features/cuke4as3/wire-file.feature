@wire_file
Feature: Wire File Features
    In order to run the wire server at the correct address
    I want to read the wire file

    Scenario: Wire File Parser Happy Path
        Given I have a wire file containing:
            """
            host: localhost
            port: 54321
            """
        When I parse it
        Then the results are:
            | host      | port      |
            | 127.0.0.1 | 54321     |

    #Cannot support ERB right now because AIR has no access to
    #environment variables.
    #Might be able to do something with a native extension though

    #Scenario: ERB support
    #    Given I have a wire file containing:
    #        """
    #        host: localhost
    #        port: <%= ENV['PORT'] || 12345 %>
    #        """
    #    And the environment setting for PORT is 54321
    #    When I parse it
    #    Then the results are:
    #        | host      | port      |
    #        | 127.0.0.1 | 54321     |