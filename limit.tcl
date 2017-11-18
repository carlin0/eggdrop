# Type $autolimt in a channel for more info..


bind pub  n|m "\$autolimit" autolimit:pub
bind join -|- * autolimit:join

setudef str "autolimit"

proc autolimit:start {} {
  foreach channel [channels] {
    if {[channel get $channel "autolimit"] == ""} {
      channel set $channel "autolimit" "0"
    }
  }
  utimer 90 autolimit
}

proc autolimit:join {nickname hostname handle channel} {
  if {![isbotnick $nickname]} {
    return 0
  }
  if {[channel get $channel "autolimit"] == ""} {
    channel set $channel "autolimit" "0"
  }
}

proc autolimit:pub {nickname hostname handle channel arguments} {
 global lastbind
  set argumentc [llength [split $arguments { }]]
  set option [lindex $arguments 0]
  set users [llength [chanlist $channel]]
  if {$argumentc < 1} {
    set currentlimit [channel get $channel "autolimit"]
    if {$currentlimit > 0} {
      putserv "NOTICE $nickname :Current auto-limit is: [channel get $channel "autolimit"]"
    } else {
      putserv "NOTICE $nickname :Argument should start with a '#' and a digit. (eg. #10 or on|off)"
    }
    return
  }
  if {([regexp -nocase -- {(#[0-9]+|off|on)} $option tmp result]) && (![regexp -nocase -- {\S#} $option])} {
    switch $result {
      on {
        channel set $channel "autolimit" "10"
        putserv "MODE $channel +l [expr $users + 10]"
        puthelp "NOTICE $nickname :Auto-limit is changed to: +10"
      }
      off {
        channel set $channel "autolimit" "0"
        putserv "MODE $channel -l *"
        puthelp "NOTICE $nickname :Done. Auto-limit disabled successfully."
      }
      default {
        if {([regexp {#[0-9]} $result]) && ([string index $result 0] == "#")} {
          regexp {#([0-9]+)} $result tmp result
          if {($result < 2)} {
            set result 2
          } elseif {($result > 500)} {
            set result 500
          }
          channel set $channel "autolimit" "$result"
          putserv "MODE $channel +l [expr $users + $result]"
          puthelp "NOTICE $nickname :Auto-limit is changed to: $result"
        }
      }
    }
  } else {
    puthelp "NOTICE $nickname :Argument should start with a '#' and a digit. (eg. #10 or on|off)"
  }
}

proc autolimit {} {
  if {![string match *autolimit* [utimers]]} {
    utimer 90 autolimit
  }
  foreach channel [channels] {
    set autolimit [channel get $channel "autolimit"]
    if {(![botisop $channel]) || ($autolimit == "0")} {
      continue
    }
    set users [llength [chanlist $channel]]
    set newlimit [expr $users + $autolimit]
    set chanmodes [getchanmode $channel]
    if {[string match *l* [lindex $chanmodes 0]]} {
      regexp {\S[\s]([0-9].*)} $chanmodes tmp currentlimit
    } else {
      set currentlimit 0
    }
    if {$newlimit == $currentlimit} {continue}
    if {$newlimit > $currentlimit} {
      set difference [expr $newlimit - $currentlimit]
    } elseif {$newlimit < $currentlimit} {
      set difference [expr $currentlimit - $newlimit]
    }
    if {($difference <= [expr round($autolimit * 0.5)]) && ($autolimit > 5)} {
      continue
    } elseif {($difference < [expr round($autolimit * 0.38)]) && ($autolimit <= 5)} {
      continue
    }
    putserv "mode $channel +l $newlimit"
  }
}

autolimit:start

putlog "- Script loaded: auto-limit -"
