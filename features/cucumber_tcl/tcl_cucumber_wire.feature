@tcl_wire
Feature: Cucumber Tcl via the wire protocol
    In order to specify behavior of embedded Tcl software
    As a responsible developer writing stuff in Tcl
    I want to be able to drive steps defined in Tcl via the Cucumber wire protocol

    Background:
        Given this feature file

    @some_tag
    Scenario: Data tables
        Given there is a data table:
            | a | b |
            | c | d |
            |   | e |
        Then the joined table is abcde

    Scenario Outline: Scenario outlines
        When there is input: <input>
        Then there should be output: <output>

        Examples:
            | input | output |
            | 1     | 2      |
            | 3     | 4      |

    Scenario: Docstrings
        Given a docstring:
        """
        config 1
        config 2
        """
        Then its content is "config 1\nconfig 2"
