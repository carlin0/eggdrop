# floodcontrol.tcl 1.0.1 - 22 july 2007
#     author : mindcry (mindcry DALnet)
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
#  USAGE :
#  in dcc:
#    .chanset #channel +chars
#    .chanset #channel +ccodes
#    .chanset #channel +caps
#    .chanset #channel +repeat
#    to enable each protection on each channel.
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
# global configuration
#
# CHARS & CONTROL CODES FLOOD
# chars flood event trigger, 0:0 to disable
set charsf 3:55

# maximum chars allowed, 0 to disable
#set maxchar 200
set maxchar 331

# control codes flood trigger, 0:0 to disable
set ccf 3:35

# maximum control codes allowed, 0 to disable
#set maxconcodes 25
set maxconcodes 0

# bantime in minutes for chars flood and control codes flood:
set cbantime 3

# REPEAT FLOOD
# repeat flood settings, 0:0 to disable
# normal repeat (kick only)
set srepeat 3:15
# offensive repeat (kick ban)
set lrepeat 7:45

# bantime in minutes for offensive repeat flood:
set repeatban 15

# CAPSLOCK VIOLATION
# how many violation before bot punishing user ?
# enter event:secs, 0 to disable
set capsv 3:75

# maximal percentage of caps allowed, 0 to disable
set capslock 47

# do you want to place ban upon capslock violation?
# 0 = disable
# 1 = enable
set capsban 0

# ban time in minutes for capslock violation:
set capsbantime 3

# end of global configuration.
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
bind RAW  - PRIVMSG msgcheck
bind RAW  - NOTICE  msgcheck
bind CTCP - ACTION  actcheck
setudef flag chars
setudef flag ccodes
setudef flag caps
setudef flag repeat

set charsf [split $charsf :]
set ccf [split $ccf :]
set srepeat [split $srepeat :]
set lrepeat [split $lrepeat :]
set capsv [split $capsv :]

proc msgcheck {from keyword arg} {
  global botnick
  set arg [split $arg]; set chan [string tolower [lindex $arg 0]]
  if {[validchan $chan] && [botisop $chan]} {
    set nick [string tolower [lindex [split $from !] 0]]; set hand [nick2hand $nick $chan]
    if {$nick == "" || [string match *.* $nick] || [isbotnick $nick]} {return 0}
    set uhost [string tolower [string range $from [expr [string first "!" $from]+1] e]]; set text [join [lrange [split $arg] 1 end]]
    msg:exec $nick $uhost $hand $chan $text
  }
}
proc actcheck {nick uhost hand dest key arg} {
  global botnick
  if {[validchan $dest] && ![isbotnick $nick]} {
    msg:exec $nick $uhost $hand $dest $arg
  }
}

proc msg:exec {nick uhost hand chan arg} {
  global botnick chan_flooded 
  global maxchar maxconcodes cbantime charsf ccf chars_count cc_count
  global srepeat lrepeat repeatban srepeat_count lrepeat_count
  global capslock capsban capsbantime capsv caps_count

  if {![matchattr $hand fb $chan] && ![isop $nick $chan] && ![string match -nocase $nick "chanserv"] && [botisop $chan]} {
    if {[lsearch -exact [channel info $chan] "+chars"] != -1 && [lsearch -exact $maxchar 0] == -1 && [lsearch -exact $charsf 0] == -1 && [expr [string length $arg] - 1] >= $maxchar} {
      if {![info exists chars_count($uhost:$chan)]} {set chars_count($uhost:$chan) 0}
      incr chars_count($uhost:$chan) 1
      utimer [lindex $charsf 1] [list unset -nocomplain chars_count($uhost:$chan)]
      if {$chars_count($uhost:$chan) >= [lindex $charsf 0]} {
        if {![info exists chan_flooded($chan)]} {
          lock:chan $chan
          newchanban $chan *!$uhost \002violation\002 "Chars Flooders." $cbantime
          putquick "KICK $chan $nick :Quanto parli!"
        }
      }
    } elseif {[lsearch -exact [channel info $chan] "+ccodes"] != -1 && [lsearch -exact $maxconcodes 0] == -1 && [regexp -all {\001|\002|\003|\037|\026|\017} $arg] >= $maxconcodes && [expr [string length $arg] - 1] < $maxchar} {
      if {![info exists cc_count($uhost:$chan)]} {set cc_count($uhost:$chan) 0}
      incr cc_count($uhost:$chan) 1
      utimer [lindex $ccf 1] [list unset -nocomplain cc_count($uhost:$chan)]
      if {$cc_count($uhost:$chan) >= [lindex $ccf 0]} {
        if {![info exists chan_flooded($chan)]} {
          lock:chan $chan
          newchanban $chan *!$uhost \002violation\002 "Control Codes Flooders." $cbantime
          putquick "KICK $chan $nick :Control Codes Flood!"
        }
      }
    } elseif {[expr [string length $arg] - 1] < $maxchar && [lsearch -exact $maxchar 0] == -1} {
      if {[lsearch -exact [channel info $chan] "+caps"] != -1 && [lsearch -exact $capslock 0] == -1 && [lsearch -exact $capsv 0] == -1 && [expr [string length $arg] - 1] > 10} {
        if {[expr 100 * [regexp -all {[A-Z]} $arg] / [expr [string length $arg] - 1]] > $capslock} {
          if {![info exists caps_count($uhost:$chan)]} {set caps_count($uhost:$chan) 0}
          incr caps_count($uhost:$chan) 1
          utimer [lindex $capsv 1] [list unset -nocomplain caps_count($uhost:$chan)]
          if {$caps_count($uhost:$chan) == [expr [lindex $capsv 0] - 1]} {
            putquick "NOTICE $nick :Scrivere maiuscolo equivale a urlare , massimo caps consentito: $capslock\%, rilevato: [expr 100 * [regexp -all {[A-Z]} $arg] / [expr [string length $arg] - 1]]\%"
          } elseif {$caps_count($uhost:$chan) == [lindex $capsv 0]} {
            if {$capsban} {
              newchanban $chan *!$uhost \002violation\002 "Capslock ban." $capsbantime
              putquick "KICK $chan $nick :Non urlare! massimo caps consentito: $capslock\%, rilevato: [expr 100 * [regexp -all {[A-Z]} $arg] / [expr [string length $arg] - 1]]\%"
            } else {
              putquick "KICK $chan $nick :Non urlare! massimo caps consentito: $capslock\%, rilevato: [expr 100 * [regexp -all {[A-Z]} $arg] / [expr [string length $arg] - 1]]\%"
            }
          }
        }
      }
      if {[lsearch -exact [channel info $chan] "+repeat"] != -1} {
        if {![info exists srepeat_count($uhost:$chan:$arg)]  && [lsearch -exact $srepeat 0] == -1} {set srepeat_count($uhost:$chan:$arg) 0}
        if {![info exists lrepeat_count($uhost:$chan:$arg)] && [lsearch -exact $lrepeat 0] == -1} {set lrepeat_count($uhost:$chan:$arg) 0}
        incr srepeat_count($uhost:$chan:$arg) 1; utimer [lindex $srepeat 1] [list unset -nocomplain srepeat_count($uhost:$chan:$arg)]
        incr lrepeat_count($uhost:$chan:$arg) 1; utimer [lindex $lrepeat 1] [list unset -nocomplain lrepeat_count($uhost:$chan:$arg)]
        if {$lrepeat_count($uhost:$chan:$arg) >= [lindex $lrepeat 0]} {
          if {![info exists chan_flooded($chan)]} {
            lock:chan $chan
            newchanban $chan *!$uhost \002violation\002 "Offensive repeater!" $repeatban
            putquick "KICK $chan $nick :Non ripetere!"
            putlog "punishing offensive repeat flooders: $nick ($uhost) on $chan."
          }
        } elseif {$srepeat_count($uhost:$chan:$arg) == [lindex $srepeat 0]} {
          putquick "KICK $chan $nick :Non ripetere!"
        }
      }
    }
  }
}
proc lock:chan {chan} {
  global botnick chan_flooded

  if {![info exists chan_flooded($chan)]} {
    set chan_flooded($chan) 1
    putquick "MODE $chan +m"
    utimer 20 "putquick \"MODE $chan -m\""
    utimer 20 [list unset -nocomplain chan_flooded($chan)]
  }
}

putlog "Controllo flood repeat caps - Caricato..."
