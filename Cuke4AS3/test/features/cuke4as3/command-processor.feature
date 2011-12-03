@wire_protocol @command_processor
Feature: The Command Processor
        In order to process commands sent from cucumber using the wire protocol
        I want to use a command processor that accepts a command and some data

        Background:
            Given a valid command processor

        Scenario Outline: Process Begin Scenario Command
            When I send a valid <request>
            Then I receive <response>

        Examples:
            | request                                           | response      |
            | ["begin_scenario"]                                | ["success"]   |
            | ["begin_scenario", {"tags":["bar","baz","foo"]}]  | ["success"]   |

        Scenario Outline: Process Match Step Command
            When I send a valid <request>
            Then I receive <response>

        Examples:
            | request                                                   | response                                                                                                                                                                                          |
            | ["step_matches",{"name_to_match":"An undefined step"}]    | ["success",[]]                                                                                                                                                                                    |
            | ["step_matches",{"name_to_match":"I have entered 6 into the calculator"}]       | ["success",[{"id":"0", "args":[{"val":6, "pos": 15}], "source":"features.step_definitions.Calculator_Steps", "regexp":"/^I have entered (\\d+) into the calculator$/g"}]]   |

        Scenario Outline: Process Invoke Command
            When I send a valid <request>
            Then I receive <response>

        Examples:
            | request                                                                   | response                                                                              |
            | ["invoke",{"id":"0","args":[]}]                                           | ["success"]                                                                           |
            | ["invoke",{"id":"0","args":["wired"]}]                                    | ["success"]                                                                           |
            | ["invoke",{"id":"0","args":["we're",[["wired"],["high"],["happy"]]]}]     | ["success"]                                                                           |
            | ["invoke",{"id":"1","args":[]}]                                           | ["fail",{"message":"The wires are down", "exception":"Error"}]   |
            | ["invoke",{"id":"2","args":[]}]                                           | ["pending", "I'll do it later"]                                                       |

        Scenario Outline: Process End Scenario Command
            When I send a valid <request>
            Then I receive <response>

        Examples:
            | request                                           | response      |
            | ["end_scenario"]                                  | ["success"]   |
            | ["end_scenario", {"tags":["bar","baz","foo"]}]    | ["success"]   |

        Scenario Outline: Process Snippet Text Command
            When I send a valid <request>
            Then I receive:
            """
            ["success","[Given (/^we're all wired$/)]\npublic function should_we_re_all_wired():void\n{\n\tthrow new Pending(\"Awaiting implementation\");\n}"]
            """

        Examples:
        | request                                                                                           |
        | ["snippet_text",{"step_keyword":"Given","multiline_arg_class":"","step_name":"we're all wired"}]  |

        Scenario Outline: Invalid Command
            When I send an invalid <request>
            Then I receive an error

        Examples:
            | request                   |
            | ["load_of_old_twaddle"]   |