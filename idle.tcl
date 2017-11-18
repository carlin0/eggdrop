### SETS
# Ogni quanto deve essere inviato il "messaggio" anti-idle?
# N.B. Il tempo � espresso in minuti.
set time 25

if {![info exists time]} {set time 10}
if {[info exists time]} {timer $time noidle}

### PROCS
proc noidle {} {
	global botnick time
	putserv "PRIVMSG $botnick :PING (Sbarabaus)"
	timer $time noidle
}

putlog "TCL Script: NoIdle v1.0 "
