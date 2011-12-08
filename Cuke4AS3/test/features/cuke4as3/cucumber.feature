@cucumber
Feature: Running Cucumber
    In order to help ActionScript developers adopt cucumber
    and by running it last to make the process as robust as possible
    I want to be able to run cucumber as an integrated part of
    this application

    Background:
        Given I have initialised cucumber correctly

    Scenario: Cucumber Happy Path
        When I run cucumber with a valid directory structure and files
        Then cucumber reports its progress
        And cucumber exits cleanly and reports success

    Scenario: Cucumber Error
        When I run the cucumber against erroneous steps
        Then cucumber reports its progress
        Then cucumber exits cleanly and reports errors

    Scenario: Additional arguments for cucumber
        Given I have added valid additional cucumber arguments
        When I run cucumber with a valid directory structure and files
        Then cucumber reports its progress
        And cucumber exits cleanly and reports success