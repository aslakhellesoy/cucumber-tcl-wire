namespace eval ::cucumber:: {
  namespace export get_step_location
  namespace export And
}

proc ::cucumber::And args {
  _add_step {*}$args
}

# d-led: extended the original with the location of the step source
# WARNING: depends on the current implementation detail of framework.tcl
proc ::cucumber::_add_step args {

  variable STEPS

  if {[llength $args] == 2} {
    set re [lindex $args 0]
    set params {}
    set body [lindex $args 1]
  } elseif {[llength $args] == 3} {
    set re [lindex $args 0]
    set params [lindex $args 1]
    set body [lindex $args 2]
  } else {
    error "The parameters for this procedure are regular_expression ?list_of_capture_variables? body"
    return 0
  }

  proc get_location {} {
    set caller_framelevel [expr [info frame] - 1]
    set up [expr $caller_framelevel - 3]
    set fr [expr $caller_framelevel - 2]
    set location "[uplevel $up {info script}]:[dict get [info frame $fr] line]"
    return $location
  }

  set location [get_location]

  lappend STEPS [list $re $params $body $location]
}

proc ::cucumber::get_step_location { step_name } {
  variable STEPS

  foreach step $STEPS {
    set existing_step_name   [lindex $step 0]
    set existing_step_params [lindex $step 1]
    set existing_step_location   [lindex $step 3]

    if {[regexp $existing_step_name $step_name matchresult {*}[join $existing_step_params]]} {
      return $existing_step_location
    }
  }

  return {}
}
