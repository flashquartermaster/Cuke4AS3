@compiler
Feature: Running the ActionScript Compiler
    In order to compile actionscript step definitions
    I want to be able to run the actionscript compiler

    Background:
        Given I have initialised the compiler correctly

    Scenario: Compiler Happy Path
        When I run the compiler against good code
        Then compiler reports its progress
        And compiler exits cleanly and reports success

    Scenario: Compiler Error
        When I run the compiler against bad code
        Then compiler reports its progress
        Then compiler exits cleanly and reports errors

    Scenario: Additional arguments for compiler
        Given I have added valid additional compiler arguments
        When I run the compiler against good code
        Then compiler reports its progress
        Then compiler exits cleanly and reports success

    #Use bundled Dconsole
    #cuke4AS3.compilerProcess.isUseBundledDConsole = true;
    #Use bundled Flexunit
    #cuke4AS3.compilerProcess.isUseBundledFlexUnit = true;