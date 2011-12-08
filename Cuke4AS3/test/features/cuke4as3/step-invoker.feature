@reflection @step_invoker
Feature: Running ActionScript on the fly
         As a wire server, when cucumber asks me
         I want to be able to request that a step definition be executed
         and find out if it is successful, pending or a failure

        Background:
            Given the step invoker is set up correctly

         Scenario: Step definition is executed successfully
            When I ask it to execute some ActionScript successfully
            Then I receive relevant information about the code execution

         Scenario: Step definition is executed and fails
            When I ask it to execute some ActionScript that fails
            Then I receive relevant information about the code execution

         Scenario: Step definition is executed and is pending
            When I ask it to execute some ActionScript that is pending
            Then I receive relevant information about the code execution