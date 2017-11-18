############### Conf ############
# Small repeat flood, kick on repeats:seconds
set rp_kflood 3:60
# Small repeat flood kick reason
set rp_kreason "Non ripetere"

# Large repeat flood, kick-ban on repeats:seconds
set rp_bflood 5:180
# Large repeat flood kick-ban reason
set rp_breason "Non ripetere !"

# Spam repeat flood, kick on repeats:seconds
set rp_sflood 3:240
# Spam repeat flood kick reason
set rp_sreason "Non ripetere"
# Set the string length for spam-type text (lines of text shorter than this
# will not be counted by the 'spam' type repeat detector)
set rp_slength 40

# Repeat offences, ban on two repeat floods from a particular host within
# how many seconds
set rp_mtime 240
# Repeat offences ban reason
set rp_mreason "Non ripetere !"

# Length of time in minutes to ban large repeat flooders and repeat
# offenders
set rp_btime 60


# Don't edit anything below unless you know what you're doing

proc rp_pubmsg {nick uhost hand chan text} {
  global botnick rp_bcount rp_bflood rp_breason rp_btime rp_kcount rp_kflood rp_kreason rp_scount rp_sflood rp_slength rp_sreason
  set uhost [string tolower $uhost]
  set chan [string tolower $chan]
  set text [string tolower $text]
  if {$nick == $botnick} {return 0}
  if {[matchattr $hand f|f $chan]} {return 0}
  if {![info exists rp_bcount($uhost:$chan:$text)]} {
    set rp_bcount($uhost:$chan:$text) 0
  }
  incr rp_bcount($uhost:$chan:$text)
  if {![info exists rp_kcount($uhost:$chan:$text)]} {
    set rp_kcount($uhost:$chan:$text) 0
  }
  incr rp_kcount($uhost:$chan:$text)
  if {[string length $text] > $rp_slength} {
    if {![info exists rp_scount($uhost:$chan:$text)]} {
      set rp_scount($uhost:$chan:$text) 0
    }
    incr rp_scount($uhost:$chan:$text)
  }
  if {$rp_bcount($uhost:$chan:$text) == [lindex $rp_bflood 0]} {
    if {[botisop $chan] && [onchan $nick $chan]} {
      putserv "KICK $chan $nick :$rp_breason"
    }
    set bmask *!*[string tolower [string range $uhost [string first "@" $uhost] end]]
    newchanban $chan $bmask repeat $rp_breason $rp_btime
    return 0
  }
  if {$rp_kcount($uhost:$chan:$text) == [lindex $rp_kflood 0]} {
    rp_mhost $nick $uhost $chan
    if {[botisop $chan] && [onchan $nick $chan]} {
      putserv "KICK $chan $nick :$rp_kreason"
    }
    return 0
  }
  if {[info exists rp_scount($uhost:$chan:$text)]} {
    if {$rp_scount($uhost:$chan:$text) == [lindex $rp_sflood 0]} {
      rp_mhost $nick $uhost $chan
      if {[botisop $chan] && [onchan $nick $chan]} {
        putserv "KICK $chan $nick :$rp_sreason"
      }
      return 0
    }
  }
}

proc rp_pubact {nick uhost hand dest key arg} {
  rp_pubmsg $nick $uhost $hand $dest $arg
}

proc rp_pubnotc {from keyword arg} {
  set nick [lindex [split $from !] 0]
  set chan [string tolower [lindex [split $arg] 0]]
  if {![validchan $chan] || ![onchan $nick $chan]} {return 0}
  set uhost [getchanhost $nick $chan]
  set hand [nick2hand $nick $chan]
  set text [join [lrange [split $arg] 1 end]]
  rp_pubmsg $nick $uhost $hand $chan $text
}

proc rp_mhost {nick uhost chan} {
  global rp_btime rp_mhosts rp_mreason rp_mtime
  set mhost [lindex [split $uhost "@"] 1]
  if {![info exists rp_mhosts($chan)]} {
    set rp_mhosts($chan) ""
  }
  set mlist $rp_mhosts($chan)
  if {[lsearch -exact $mlist $mhost] != -1} {
    set bmask *!*[string tolower [string range $uhost [string first "@" $uhost] end]]
    newchanban $chan $bmask repeat $rp_mreason $rp_btime
  } else {
    lappend rp_mhosts($chan) $mhost
    utimer $rp_mtime "rp_mhostreset $chan"
  }
}

proc rp_mhostreset {chan} {
  global rp_mhosts
  set rp_mhosts($chan) [lrange rp_mhosts($chan) 1 end]
}

proc rp_kreset {} {
  global rp_kcount rp_kflood
  if {[info exists rp_kcount]} {
    unset rp_kcount
  }
  utimer [lindex $rp_kflood 1] rp_kreset
}

proc rp_breset {} {
  global rp_bcount rp_bflood
  if {[info exists rp_bcount]} {
    unset rp_bcount
  }
  utimer [lindex $rp_bflood 1] rp_breset
}

proc rp_sreset {} {
  global rp_scount rp_sflood
  if {[info exists rp_scount]} {
    unset rp_scount
  }
  utimer [lindex $rp_sflood 1] rp_sreset
}

if {![string match *rp_kreset* [utimers]]} {
  global rp_kflood
  utimer [lindex $rp_kflood 1] rp_kreset
}

if {![string match *rp_breset* [utimers]]} {
  global rp_bflood
  utimer [lindex $rp_bflood 1] rp_breset
}

if {![string match *rp_sreset* [utimers]]} {
  global rp_sflood
  utimer [lindex $rp_sflood 1] rp_sreset
}

set rp_kflood [split $rp_kflood :]
set rp_bflood [split $rp_bflood :]
set rp_sflood [split $rp_sflood :]

bind pubm - * rp_pubmsg
bind ctcp - ACTION rp_pubact
bind raw - NOTICE rp_pubnotc

putlog "Loaded repeat.tcl"
