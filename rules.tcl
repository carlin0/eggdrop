##########################################################################
#
# BlackRules Tcl 1.0
#
#Command script to add channel rules.
#
#!rule <add> <rule>
#!rule <list>
#!rule <del> <number> (take`it from the list)
#And the command for normal users to list the rules is.
#!rules ( will show the rules )
#
#                                             BLaCkShaDoW ProductionS
##########################################################################

#Here you can set what flags can use the command to add/remove/list rules.

set rules(who) "nm|mNMAS"

#Here you can set the char of the commands

set rules(char) "!"

#Here you can set at what intervals the bot can show the rules. (in seconds)
#to avoid flooding the eggdrop.

set rules(time) "60"

##########################################################################
setudef flag rules
bind pub $rules(who) $rules(char)rule showrules
bind pub -|- $rules(char)rules publicrules


proc showrules {nick host hand chan arg} {
global rules
set dir "logs/rules($chan).txt"
set who [lindex [split $arg] 0]
set reguli [join [lrange [split $arg] 1 end]]
set number [lindex [split $arg] 1]

if {$who == ""} { puthelp "NOTICE $nick :Use $rules(char)rule | <on> | <off> | <add> <rule> | <list> | <del> <number>"
return 0
}
if {([regexp -nocase -- {(#[0-9]+|on|off|add|list|del)} $who tmp a]) && (![regexp -nocase -- {\S#} $who])} {
    switch $a {
on {
channel set $chan +rules
puthelp "NOTICE $nick :Activated rules on $chan."

}

off {
channel set $chan -rules
puthelp "NOTICE $nick :Deactivated rules on $chan"
}

add {
if {$reguli == ""} {puthelp NOTICE $nick :Use $rules(char)regula <add> <rule>"
return 0
}

if {[file exists $dir] == 0} {
set file [open $dir w]
close $file
}
set file [open $dir a]
puts $file $reguli
close $file
puthelp "NOTICE $nick :Added rule for $chan:"
puthelp "NOTICE $nick :$reguli"
}
list {
if {[file exists $dir] == 0} {
set file [open $dir w]
close $file
}
set dir "logs/rules($chan).txt"
set file [open $dir "r"]
set w [read -nonewline $file]
close $file
set data [split $w "\n"]
set i 0
if {$data == ""} { puthelp "NOTICE $nick :There are no rules for $chan"
return 0
}
foreach rule $data {
set i [expr $i +1]
puthelp "NOTICE $nick :Rules for $chan are:"
puthelp "NOTICE $nick :$i. $rule"
}
}

del {
if {$number == ""} { puthelp "NOTICE $nick :Use $rules(char)regula <del> <number>"
return 0
}
set dir "logs/rules($chan).txt"
if {[file exists $dir] == 0} {
set file [open $dir w]
close $file
}
set file [open $dir "r"]
set data [read -nonewline $file]
close $file
set lines [split $data "\n"]
set i [expr $number - 1]
set delete [lreplace $lines $i $i]
set files [open $dir "w"]
puts $files [join $delete "\n"]
close $files
set file [open $dir "r"]
set data [read -nonewline $file]
close $file
if {$data == ""} {
set files [open $dir "w"]
close $files
}
puthelp "NOTICE $nick :Erased from $chan the rule number $number"
puthelp "NOTICE $nick :Please verify with $rules(char)rule <list>"
}
}
}
}

proc publicrules {nick host hand chan arg} {
global rules count
set dir "logs/rules($chan).txt"
if {![validchan $chan]} { return 0 }
if {[channel get $chan rules]} {

if {![info exists count(rules:on)]} { 
set count(rules:on) 0 
}

if {$count(rules:on) >= 1} {
puthelp "NOTICE $nick :Please wait for $rules(time) seconds before i can show the rules."
return 0
}

incr count(rules:on)
utimer $rules(time) [list unset count(rules:on)]
if {[file exists $dir] == 0} {
set file [open $dir w]
close $file
}
set file [open $dir "r"]
set w [read -nonewline $file]
close $file
set data [split $w "\n"]
set i 0
if {$data == ""} { puthelp "NOTICE $nick :There are no rules for $chan"
return 0
}
foreach rule $data {
set i [expr $i +1]
puthelp "NOTICE $nick :12The rules for 4$chan 12are:"
puthelp "NOTICE $nick :12 $i . $rule"
}
}
}

putlog "BlackRules TCL 1.0 by BLaCkShaDoW Loaded"


