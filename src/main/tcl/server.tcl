## SPEC: http://www.relishapp.com/cucumber/cucumber/docs/wire-protocol ##

if {![namespace exists json]} {
    package require json
    package require json::write
}

namespace eval ::cucumber::tcl::wire:: {
    namespace export startServer

    proc log {args} {
        puts $args
    }

    variable last_session
}

proc ::cucumber::tcl::wire::startServer {port} {
    global stop_cucumber_server 0
    set s [socket -server accept $port]
    vwait stop_cucumber_server
    log "Tcl cucumber wire server stopped"
}

proc ::cucumber::tcl::wire::accept {sock addr port} {
    variable last_session

    log "Accepting $sock from $addr port $port"
    set last_session(addr,$sock) [list $addr $port]

    # TODO: consider using a timeout
    fconfigure $sock -buffering line

    fileevent $sock readable [list ::cucumber::tcl::wire::processRequest $sock]
}

###########################################################
proc ::cucumber::tcl::wire::step_matches {sock argValues args} {
    set d [lindex $argValues 1]
    set name_to_match [dict get $d name_to_match]
    set match_found [::cucumber::step_definition_exists $name_to_match]

    # puts "match? $match_found : $argValues"

    if {$match_found == 1} {
        set location [::cucumber::get_step_location $name_to_match]
        ::json::write indented 0
        set json_response [json::write array \
                [json::write string success] \
                [json::write array [json::write object \
                    id [json::write string $name_to_match] \
                    args [json::write array] \
                    "source" [json::write string "$location"] \
                ]]
            ]
        # puts "RESPONSE: $json_response"
        puts $sock "$json_response"
    } elseif { $match_found == "pending" } {
        puts $sock {  ["success", []]  }
    } else {
        puts $sock {  ["success", []]  }
    }
}

proc ::cucumber::tcl::wire::snippet_text {sock argValues args} {
    set d [lindex $argValues 1]
    set keyword [dict get $d step_keyword]
    set step_name [dict get $d step_name]
    set proposal_string "$keyword \{\^$step_name\$\} \{ args \} \{\n  pending \n\}"
    set proposal [json::write string $proposal_string]
    puts $sock [concat { ["success", } $proposal {] }]
}

proc ::cucumber::tcl::wire::invoke {sock argValues args} {
    set d [lindex $argValues 1]
    set id [dict get $d id]
    set args_ [dict get $d args]

    # puts "EXECUTE ::cucumber::execute_step_definition \"$id\" $args_"
    set result 0
    catch {set result [::cucumber::execute_step_definition "$id" $args_]} exception_text

    if {$result == 1} {
        puts $sock {  ["success"]  }
    } elseif { $result == "pending" } {
        puts $sock {  ["pending", "PENDING"]  } ;#todo message
    } else {
        set json_response [json::write array \
                [json::write string fail] \
                [json::write object \
                    message [json::write string "Tcl execution failed with: "] \
                    exception [json::write string $exception_text] \
                ]
            ]
        puts $sock $json_response ;
    }
}

proc ::cucumber::tcl::wire::begin_scenario {sock argValues args} {
    log "beginning scenario: $argValues"
    puts $sock { ["success"] }
}

proc ::cucumber::tcl::wire::end_scenario {sock argValues args} {
    puts $sock { ["success"] }
}

###########################################################

proc ::cucumber::tcl::wire::getCommand {jsonValue} {
    return [lindex $jsonValue 0]
}

proc ::cucumber::tcl::wire::getArgs {jsonValue} {
    if { [catch {return [lindex $jsonValue 0]} ] } {
        return $jsonValue
    }
}

proc ::cucumber::tcl::wire::processRequest {sock} {
    variable last_session

    if {[eof $sock] || [catch {gets $sock line}]} {
        close $sock
        log "Closed $last_session(addr,$sock)"
        unset last_session(addr,$sock)
        global stop_cucumber_server
        set stop_cucumber_server 1
    } elseif { [string length $line] > 0 } {
        log "received: $line"

        set parsed_request [::json::json2dict $line]

        set command [::cucumber::tcl::wire::getCommand $parsed_request]

        set args [::cucumber::tcl::wire::getArgs $parsed_request]

        log "parsed command: $command, args: $args"
        set proc_exists [info procs $command]
        if {$proc_exists!=""} {
            eval {$command $sock $args}
        } else {
            log "command not found: $command"
        }
        # catch {gets $sock line} ;# response
        # puts $line
    }
}
