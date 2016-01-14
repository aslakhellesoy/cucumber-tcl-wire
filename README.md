# Cucumber-Tcl over the Wire #

This project is intended as an investigation, whether Cucumber-Tcl can be executed via the Cucumber [Wire](http://www.relishapp.com/cucumber/cucumber/docs/wire-protocol) protocol.

The motivation behind the use-case is that in case an embedded (as in, in a larger app) Tcl interpreter is used, it might not be viable to link it to Ruby. Starting the wire server might also be a non-standard task, in case the interpreter is not exposed to the command line.

Here, the standard tcl interpreter `tclsh` is used by default. 

## Running the self-test ##

`gradle` or `gradlew`

## Chosing the interpreter ##

`gradle -Dtcl=wish`

## Keeping the interpreter window open / logging its output ## 

`gradle -Dpause=true`

On Windows, the interpreter window will be left open. On Linux, its output will be redirected into a log file.

## Structure ##

This project builds upon the original [cucumber-ruby-tcl](https://github.com/cucumber/cucumber-ruby-tcl.git), extending the original proc `::cucumber::_add_step` with getting the step source location info, and adding two more procs: `::cucumber::get_step_location` and (just for the sake of completeness) `::cucumber::And`.

[server.tcl](src/main/tcl/server.tcl) is the partial implementation of the wire protocol, allowing to start the server using `::cucumber::tcl::wire::startServer 33333`.

Sourcing of the step definitions is automated only in the [build config](build.gradle), and all necessary sources are loaded in the ["suite"](src/test/tcl/step_definitions/suite.tcl).
