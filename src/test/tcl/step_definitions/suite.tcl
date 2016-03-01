proc sourceLocalFile {filename} {
    source [file join [file dirname [info script]] $filename]
}

# all this could be automated with some convention

# load the framework
sourceLocalFile {../../../../cucumber-ruby-tcl/lib/cucumber/tcl/framework.tcl}
sourceLocalFile {../../../main/tcl/framework_extensions.tcl}
sourceLocalFile {../../../main/tcl/server.tcl}

# the step location is now more robust against framelevel variation
# if {1} {
# 	if {1} {
# 		sourceLocalFile {steps.tcl}
# 	}
# }
sourceLocalFile {steps.tcl}

::cucumber::tcl::wire::startServer 33333
