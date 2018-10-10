## Autochangenick tcL version Beta

# - configuration of autochangenick
set nchange(mins) "95" 
set nchange(nicks) "nick1 nick2 nick3 Andothers" 

### autochange nick - new features!version Beta ###
foreach ntimer [timers] { 
 if {[string match -nocase "*change:nick*" "[lindex $ntimer 1]"]} { 
  killtimer [lindex $ntimer 2]
 } 
} 
timer $nchange(mins) [list change:nick $nchange(nicks) $nchange(mins)] 
set nchange(length) 0 

proc change:nick {nicks mins} { 
  global nick nchange 
  incr nchange(length) 
  if {"$nchange(length)" > "[llength $nicks]"} { set nchange(length) 1 } 
  set nick "[lindex $nicks [expr {$nchange(length)-1}]]" 
  timer $mins [list change:nick $nicks $mins] 
}


putlog "Autochangenick tcl version Beta loaded"
