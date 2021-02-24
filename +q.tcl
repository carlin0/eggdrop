bind flud - * quiet
proc quiet {nick uhost handle type chan} { 
putserv "MODE $chan +q \$~a"
flushmode $chan
}
