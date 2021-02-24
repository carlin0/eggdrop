# quietunset.tcl
# +q mode (quiet) unset for Freenode and similar after a certain time.
#
# This is my software.  I hereby give it away to anyone who wants it for any purpose whatsoever.
# -- Thomas "thommey" Sader, 2016
#
# YOU HAVE TO RESTART/RECONNECT THE BOT AFTER LOADING

### Settings ###

# Ban-time in minutes after which to remove +q bans
set qbantime 30

#### No need to touch anything below this. ###

bind raw - MODE qparsemode
# "thommey!thommey@tclhelp.net MODE #thommey -v+v TCL ^|^"
proc qparsemode {from key text} {
	set text [split $text]
	set chan [string tolower [lindex $text 0]]
	if {![validchan $chan]} { return }
	foreach {mode victim} [parsemodestr [lindex $text 1] [lrange $text 2 end]] {
		if {$mode eq "+q"} {
			timer $::qbantime [list puthelp "MODE $chan -q $victim"]
		}
	}
	return 0
}

bind raw - 005 parse005
proc parse005 {from key text} {
	if {[regexp {CHANMODES=(\S+)} $text -> modes]} {
		set ::modeconfig [split $modes ,]
	}
	if {[regexp {PREFIX=\((\S+)\)} $text -> umodes]} {
		set ::umodeconfig $umodes
	}
	return 0
}

# removes first element from the list and returns it
proc pop {varname} {
	upvar 1 $varname list
	if {![info exists list]} { return "" }
	set elem [lindex $list 0]
	set list [lrange $list 1 end]
	return $elem
}

proc modeparam {pre modechar} {
	if {![info exists ::umodeconfig]} {
		putlog "Arbchanmodes: Could not get usermodeconfig from raw 005!"
		set ::umodeconfig qaohv
	}
	if {![info exists ::modeconfig]} {
		putlog "Arbchanmodes: Could not get modeconfig from raw 005!"
		set ::modeconfig [split eIbq,k,flj,ACFLOPQScgimnprstz ,]
	}
	set pls [expr {$pre eq "+"}]
	if {[string match *$modechar* $::umodeconfig] || [string match *$modechar* [lindex $::modeconfig 0]] || [string match *$modechar* [lindex $::modeconfig 1]]} {
		return 1
	}
	if {[string match *$modechar* [lindex $::modeconfig 2]]} {
		return $pls
	}
	if {[string match *$modechar* [lindex $::modeconfig 3]]} {
		return 0
	}
	putlog "Arbchanmodes: Unknown mode char '$modechar'!"
	return 0
}

# parses a modestring "+v-v" and a list of victims {nick1 nick2} and returns a flat list in the form {modechange victim modechange victim ..}
# static modelist with parameters taken from unrealircd (better do it dynamically on raw 005 ;)
proc parsemodestr {modestr victims} {
	set result [list]
	set pre "+"
	foreach char [split $modestr ""] {
		if {$char eq "+" || $char eq "-"} {
			set pre $char
		} else {
			set param [expr {[modeparam $pre $char] ? [pop victims] : ""}]
			lappend result $pre$char $param
		}
	}
	set result
}

