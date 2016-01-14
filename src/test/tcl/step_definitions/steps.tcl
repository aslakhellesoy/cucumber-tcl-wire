namespace eval ::context:: {
    variable table
}

Given {^this feature file.*$} {
    puts "-----------------------------------------"
}

Given {^there is a data table:$} { table } {
    set ::context::table $table
}

Then {^the joined table is (.*)$} { table_joined_expected } {
    set table_joined [string map {"{}" ""} [join [join [join $::context::table ""] ""] ""]]
    if { $table_joined != $table_joined_expected } {
        error "output value of $result not correct: should be $output_value"
    }
}

When {^there is input: (\d+)$} { input } {
    set ::context::input $input
}

Then {^there should be output: (\d+)$} { output_value } {
    puts "input was: $::context::input"

    set result [expr $::context::input + 1]
    if { $output_value != $result } {
        error "output value of $result not correct: should be $output_value"
    }
}

Given {^a docstring:$} { contents } {
    set contents [string trim $contents \{\}]
    puts "config file:$contents"
    set ::context::contents $contents
}

Then {^its content is \"(.*)\"$} { contents } {
    set contents [subst $contents]
    puts "contents: $contents"
    if { $contents != $::context::contents } {
        error "strings didn't match!\n$contents\nvs:\n$::context::contents\n"
    }
}
