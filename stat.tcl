# exec tclsh "$0" ${1+"$@"}
# chanstats.1.3.0.tcl
# arfer <arfer.minute@gmail.com>
# dalnet #Atlantis
#tradotta da Carlino carlin0@email.it

# ***************************************************************************************************************************** #
# ********** SYNTAX *********************************************************************************************************** #

# assuming the default trigger "." - see configuration section below

# arguments inside <here> are required
# arguments inside ?here? are optional

# .classifica <nick> <option> ?#chan?    --> outputs the current placing of <nick> for events specified by <option> in the command source channel, or in ?#chan? if specified
# .stato <nick> ?#chan?            --> outputs the chanstats for <nick> and command source channel, or those for <nick> and ?#chan? if specified
# .top10 <option> ?#chan?          --> outputs the top 10 users for events specified by <option> for command source channel, or those for ?#chan? if specified
# .top20 <option> ?#chan?          --> outputs the top 20 users (11 through 20) for events specified by <option> for command source channel, or those for ?#chan? if specified
# .tstato ?#chan?                  --> outputs total events logged for command source channel, or those for ?#chan? if specified
# .resetta ?#chan?                --> deletes chanstats records for the command source channel, or those for ?#chan? if specified

# valid <option> arguments for .top10, top20 and .place commands are linee, parole, azioni, kick, ban, join, part, split, quit, nick

# ***************************************************************************************************************************** #
# ********** CONFIGURATION **************************************************************************************************** #

# set here the single character command trigger
# ensure that it is set such that it does not interfere with similar commands on this or other bots in the same channel(s)
# allowed values are as follows (the existing settings are recommended)
# , = comma
# . = period
# ! = exclamation mark
# $ = dollar sign
# & = ampersand
# - = hyphen
# ? = question mark
# ~ = tilde
# ; = semi-colon
# : = colon
# ' = apostrophe
# % = percent
# ^ = caret
# * = asterisk
set vChanstatsTrigger "~"

# set here the user status required to use the commands in this script
# based on global and channel bot flags
# note that a setting of 9 means that the user's handle must exist in the ..
# .. configuration file's 'set owner' variable
# allowed values are as follows (the existing settings are recommended)
# 1 = public (no bot access required)
# 2 = partyline (p|)
# 3 = channel or global operator (o|o)
# 4 = global operator (o|)
# 5 = channel or global master (m|m)
# 6 = global master (m|)
# 7 = channel or global owner (n|n)
# 8 = global owner (n|)
# 9 = permanent owner (handle must be listed in .conf 'set owner' variable)
set vChanstatsStatus(rank) 1
set vChanstatsStatus(stats) 1
set vChanstatsStatus(top10) 1
set vChanstatsStatus(top20) 1
set vChanstatsStatus(tstats) 3
set vChanstatsStatus(zapstats) 9

# set here the text colours used in the bot's responses
# settings are only valid where channel mode permits colour
# allowed values are as follows (the existing settings are recommended)
# 00 = white
# 01 = black
# 02 = blue
# 03 = green
# 04 = light red
# 05 = brown
# 06 = purple
# 07 = orange
# 08 = yellow
# 09 = light green
# 10 = cyan
# 11 = light cyan
# 12 = light blue
# 13 = pink
# 14 = grey
# 15 = light grey
set vChanstatsColor(arrow) 03
set vChanstatsColor(compliance) 10
set vChanstatsColor(dimmed) 12
set vChanstatsColor(errors) 04
set vChanstatsColor(events) 07

# set here if you wish to automate the channel flag setting of +chanstats for any channel the bot joins
# do not turn on this facility if you intend that the script work in only selected channels
# for 'auto channel setting' the setting can be any of the accepted boolean values 1, yes, true, on
# for 'manual channel setting' (as normal through the .chanset partyline command) the setting can be any ..
# .. of the accepted boolean values 0, no, false, off
# no other values are permitted
set vChanstatsAuto 0

# set here if you wish to allow the stats database to be cleared via a public command
# the only alternative would be to kill the bot and manually delete the chanstats.txt datafile
# for 'allowed' the setting can be any of the accepted boolean values 1, yes, true, on
# for 'not allowed' the setting can be any of the accepted boolean values 0, no, false, off
# no other values are permitted
set vChanstatsZapAllowed 1

# set here the numbers of events (of any/all types) (in any/all channels) to occur between data save operation
# valid values are integers in the range 10 through 50
# no other values are permitted
set vChanstatsEventsSave 35

# set here the number of minutes to elapse between data save operations
# valid values are integers in the range 5 through 25
# no other values are permitted
set vChanstatsScheduleSave 25

# set here the number of days that must pass for any user not recording an event of any type on a channel ..
# .. before their record for that channel is discarded during the next save operation
# valid values are integers in the range 2 through 10
# no other values are permitted
set vChanstatsIdleDays 7

# set here if you wish to see save and load related operations in the partyline
# the information includes records saved and records discarded
# to 'see partyline information' the setting can be any of the accepted boolean values 1, yes, true, on
# to 'not see partyline information' the setting can be any of the accepted boolean values 0, no, false, off
# no other values are permitted
set vChanstatsPutlog 1

# set here if you wish to accrue events by guest nicks
# to 'accrue events by guest nicks' the setting can be any of the accepted boolean values 1, yes, true, on
# to 'ignore events by guest nicks' the setting can be any of the accepted boolean values 0, no, false, off
# no other values are permitted
set vChanstatsGuest 0

# ***************************************************************************************************************************** #
# ********** CODE ************************************************************************************************************* #

# *********************************** #
# *** DO NOT EDIT BELOW THIS LINE *** #
# *********************************** #

# ---------- FAILSAFES --------------------------------------------------------------------------------------------------- #

if {![regexp {^[-,.!$&?~;:'%^*]{1}$} $vChanstatsTrigger]} {
  die "configuration error in chanstats.tcl - illegal command trigger character"
}

foreach status [array names vChanstatsStatus] {
  if {![string is integer -strict $vChanstatsStatus($status)]} {
    die "configuration error in chanstats.tcl - illegal user status value (not an integer)"
  } else {
    if {($vChanstatsStatus($status) < 1) || ($vChanstatsStatus($status) > 9)} {
      die "configuration error in chanstats.tcl - illegal user status value (out of permitted range)"
    }
  }
}

foreach color [array names vChanstatsColor] {
  if {![string is integer -strict $vChanstatsColor($color)]} {
    die "configuration error in chanstats.tcl - illegal text color value (not an integer)"
  } else {
    if {($vChanstatsColor($color) < 0) || ($vChanstatsColor($color) > 15)} {
      die "configuration error in chanstats.tcl - illegal text colour value (out of permitted range)"
    }
  }
}

if {![string is boolean -strict $vChanstatsAuto]} {
  die "configuration error in chanstats.tcl - illegal auto channel setting variable (not boolean)"
}

if {![string is boolean -strict $vChanstatsZapAllowed]} {
  die "configuration error in chanstats.tcl - illegal reset allowed variable (not boolean)"
}

if {![string is integer -strict $vChanstatsEventsSave]} {
  die "configuration error in chanstats.tcl - illegal events save value (not an integer)"
} else {
  if {($vChanstatsEventsSave < 10) || ($vChanstatsEventsSave > 50)} {
    die "configuration error in chanstats.tcl - illegal events save value (out of permitted range)"
  }
}

if {![string is integer -strict $vChanstatsScheduleSave]} {
  die "configuration error in chanstats.tcl - illegal events save value (not an integer)"
} else {
  if {($vChanstatsScheduleSave < 5) || ($vChanstatsScheduleSave > 25)} {
    die "configuration error in chanstats.tcl - illegal events save value (out of permitted range)"
  }
}

if {![string is integer -strict $vChanstatsIdleDays]} {
  die "configuration error in chanstats.tcl - illegal events save value (not an integer)"
} else {
  if {($vChanstatsIdleDays < 2) || ($vChanstatsIdleDays > 10)} {
    die "configuration error in chanstats.tcl - illegal events save value (out of permitted range)"
  }
}

if {![string is boolean -strict $vChanstatsPutlog]} {
  die "configuration error in chanstats.tcl - illegal putlog variable (not boolean)"
}

if {![string is boolean -strict $vChanstatsGuest]} {
  die "configuration error in chanstats.tcl - illegal guest accrue variable (not boolean)"
}

# ---------- INITIALISE -------------------------------------------------------------------------------------------------- #

set vChanstatsVersion 1.3.0

setudef flag chanstats

proc pChanstatsTrigger {} {
  global vChanstatsTrigger
  return $vChanstatsTrigger
}

array set vChanstatsFlag {
  2 p|
  3 o|o
  4 o|
  5 m|m
  6 m|
  7 n|n
  8 n|
}

array set vChanstatsName {
  2 "partyline"
  3 "channel operator"
  4 "global operator"
  5 "channel master"
  6 "global master"
  7 "channel owner"
  8 "global owner"
}

set vChanstatsCount 0

# ---------- BINDS ------------------------------------------------------------------------------------------------------- #

bind EVNT - connect-server pChanstatsLoad
bind EVNT - disconnect-server pChanstatsSave
bind EVNT - init-server pChanstatsInit
bind JOIN - * pChanstatsJoinAuto

bind CTCP - ACTION pChanstatsCtcpInput
bind KICK - * pChanstatsKickInput
bind MODE - "#*+b" pChanstatsModeInput
bind JOIN - * pChanstatsJoinInput
bind NICK - * pChanstatsNickInput
bind PART - * pChanstatsPartInput
bind PUBM - * pChanstatsPubmInput
bind REJN - * pChanstatsRejnInput
bind SIGN - * pChanstatsSignInput
bind SPLT - * pChanstatsSpltInput

bind PUB - [pChanstatsTrigger]classifica pChanstatsOutputRank
bind PUB - [pChanstatsTrigger]stato pChanstatsOutputStats
bind PUB - [pChanstatsTrigger]top10 pChanstatsOutputTop10
bind PUB - [pChanstatsTrigger]top20 pChanstatsOutputTop20
bind PUB - [pChanstatsTrigger]tstato pChanstatsOutputTstats
bind PUB - [pChanstatsTrigger]resetta pChanstatsZapstats

# ---------- PROCS ------------------------------------------------------------------------------------------------------- #

proc pChanstatsColor {chan type number} {
  global vChanstatsColor
  if {[regexp -- {^\+[a-zA-Z]*c} [getchanmode $chan]]} {
    return ""
  } else {
    switch -- $number {
      1 {
        switch -- $type {
          0 {return "\003$vChanstatsColor(errors)"}
          1 {return "\003$vChanstatsColor(compliance)"}
          2 {return "\003$vChanstatsColor(events)"}
        }
      }
      3 {return "\003$vChanstatsColor(dimmed)"}
      5 {return "\003$vChanstatsColor(arrow)"}
      2 - 4 - 6 {return "\003"}
    }
  }
}

proc pChanstatsCompliance {number command snick tnick schan tchan text1 text2 text3 text4 text5 text6} {
  for {set loop 1} {$loop <= 6} {incr loop} {set col($loop) [pChanstatsColor $schan 1 $loop]}
  set output1 "$col(1)Risposta$col(2) ($col(3)$snick$col(4)) $col(5)-->$col(6)"
  switch -- $number {
    001 {set output2 "$text1 $col(3)$text2$col(4) registrato per $col(3)$tchan$col(4) $col(5)-->$col(6) [regsub -all {\)} [regsub -all {\(} [join [join $text3 ", "]] "($col(3)"] "$col(4))"]"}
    002 {set output2 "dati statistici per $col(3)$tnick$col(4) in $col(3)$tchan$col(4) $col(5)-->$col(6) [regsub -all {\)} [regsub -all {\(} $text1 "($col(3)"] "$col(4))"] $col(5)-->$col(6) \
                      l'ultimo evento é stato registrato $col(3)$text2$col(4) fa"}
    003 {set output2 "I dati statistici per $col(3)$tchan$col(4) sono stati cancellati"}
    004 {set output2 "dati statistici totali per $col(3)$tchan$col(4) $col(5)-->$col(6) [regsub -all {\)} [regsub -all {\(} $text1 "($col(3)"] "$col(4))"]"}
    005 {set output2 "$col(3)$tnick$col(4) si classifica $col(3)$text2$col(4) su $col(3)$text4$col(4) dati per $col(3)$text1$col(4) registrate in $col(3)$tchan$col(4) con un punteggio di\
                      $col(3)$text3$col(4) che rappresenta il $col(3)[format %.2f [expr {(double($text3) / double($text5)) * 100}]]%$col(4) di $col(3)$text5$col(4) totali"}
  }
  putserv "PRIVMSG $schan :$output1 $output2"
  return 0
}

proc pChanstatsCtcpInput {nick uhost hand dest keyword text} {
  pChanstatsDataAccrue [string tolower $nick] [string tolower $dest] 4 1
  return 0
}

proc pChanstatsDataAccrue {nick chan position number} {
  global vChanstatsCount
  global vChanstatsData
  global vChanstatsEventsSave
  global vChanstatsGuest
  if {![isbotnick $nick]} {
    if {(!$vChanstatsGuest) && ([regexp {^minduser.+[0-9]{4}$} [string tolower $nick]])} {return 0}
    if {[channel get $chan chanstats]} {
      incr vChanstatsCount
      if {![info exists vChanstatsData($nick\@$chan)]} {set vChanstatsData($nick\@$chan) "$nick\@$chan [unixtime] 0 0 0 0 0 0 0 0 0 0"}
      set oldvalue [join [lindex [split $vChanstatsData($nick\@$chan)] $position]]
      set newvalue [expr {$oldvalue + $number}]
      set vChanstatsData($nick\@$chan) [join [lreplace [split $vChanstatsData($nick\@$chan)] 1 1 [unixtime]]]
      set vChanstatsData($nick\@$chan) [join [lreplace [split $vChanstatsData($nick\@$chan)] $position $position $newvalue]]
      if {[expr {$vChanstatsCount >= $vChanstatsEventsSave}]} {
        pChanstatsSave events
        set vChanstatsCount 0
      }
    }
  }
  return 0
}

proc pChanstatsError {number command snick tnick schan tchan text1 text2 text3 text4 text5 text6} {
  global vChanstatsStatus
  for {set loop 1} {$loop <= 6} {incr loop} {set col($loop) [pChanstatsColor $schan 0 $loop]}
  set output1 "$col(1)Errore$col(2) ($col(3)$snick$col(4)) $col(5)-->$col(6)"
  switch -- $number {
    001 {set output2 "La sintassi corretta é $col(3)[pChanstatsTrigger]top10 <opzione> #canale$col(4)"}
    002 {set output2 "Le $col(3)<opzioni>$col(4) valide sono $col(3)linee, parole, azioni, kick, ban, join, part, split, quit, nick$col(4)"}
    003 {set output2 "$col(3)$tchan$col(4) non é un nome di canale valido"}
    004 {set output2 "Non ho dati registrati per $col(3)$tchan$col(4)"}
    005 {set output2 "Non c'é ancora nessuna statistica registrata per i miei canali"}
    006 {set output2 "Non vi sono state $col(3)$text1$col(4) registrate per $col(3)$tchan$col(4) per ora"}
    007 {set output2 "La sintassi corretta é $col(3)[pChanstatsTrigger]stato <nick> #canale$col(4)"}
    008 {set output2 "$col(3)$tnick$col(4) non é un nick valido"}
    009 {set output2 "Non vi sono dati statistici registrati per nick $col(3)$tnick$col(4) in $col(3)$tchan$col(4) per ora"}
    010 {set output2 "La sintassi corretta é $col(3)[pChanstatsTrigger]resetta #canale$col(4)"}
    011 {set output2 "Non tengo statistiche al momento per $col(3)$tchan$col(4)"}
    012 {set output2 "Non ci sono dati per $col(3)$tchan$col(4) to da cancellare"}
    013 {set output2 "Il comando $col(3)[pChanstatsTrigger]$command$col(4 é stato disabilitato nella configurazione dello script"}
    014 {set output2 "Non registro statistiche per me"}
    015 {set output2 "Solo l'Owner permanente del bot può usare il comando $col(3)[pChanstatsTrigger]$command$col(4)"}
    016 {set output2 "Devi avere minimo [pChanstatsName $vChanstatsStatus($command)] nell'accesso del bot per usare il comando $col(3)[pChanstatsTrigger]$command$col(4)"}
    017 {set output2 "Ho solo $text1 record(s) per $col(3)$text2$col(4) in $col(3)$tchan$col(4)"}
    018 {set output2 "La sintassi corretta é $col(3)[pChanstatsTrigger]top20 <opzione> #canale$col(4)"}
    019 {set output2 "La sintassi corretta é $col(3)[pChanstatsTrigger]total #canale$col(4)"}
    020 {set output2 "Non vi sono dati statistici registrati per $col(3)$tchan$col(4) al momento"}
    021 {set output2 "La sintassi corretta é $col(3)[pChanstatsTrigger]classifica <nick> <opzione> #canale$col(4)"}
    022 {set output2 "$col(3)$tnick$col(4) non é stato registrato nessun $col(3)$text1$col(4) in $col(3)$tchan$col(4)"}
  }
  putserv "PRIVMSG $schan :$output1 $output2"
  return 0
}

proc pChanstatsEvent {number command snick tnick schan tchan text1 text2 text3 text4 text5 text6} {
  for {set loop 1} {$loop <= 6} {incr loop} {set col($loop) [pChanstatsColor $tchan 2 $loop]}
  set output1 "$col(1)Event$col(2) ($col(3)zapstats$col(4)) $col(5)-->$col(6)"
  switch -- $number {
    001 {set output2 "Le statistiche registrate per $col(3)$tchan$col(4) sono state cancellate da $col(3)$tnick$col(4)"}
  }
  putserv "PRIVMSG $tchan :$output1 $output2"
  return 0
}

proc pChanstatsFlag {nick chan} {
  global owner
  global vChanstatsFlag
  set owners [split [string tolower [regsub -all -- {,} $owner ""]]]
  set handle [string tolower [nick2hand $nick]]
  if {[lsearch -exact $owners $handle] != -1} {return 9}
  for {set loop 8} {$loop >= 2} {incr loop -1} {
    if {[matchattr [nick2hand $nick] $vChanstatsFlag($loop) $chan]} {return $loop}
  }
  return 1
}

proc pChanstatsInit {type} {
  global vChanstatsPutlog
  if {$vChanstatsPutlog} {putlog "\00314<chanstats>\003 initialising time bind (\00314$type\003)"}
  pChanstatsSchedule
  return 0
}

proc pChanstatsJoinAuto {nick uhost hand chan} {
  global vChanstatsAuto
  if {[isbotnick $nick]} {
    if {$vChanstatsAuto} {
     if {![channel get $chan chanstats]} {
        channel set $chan +chanstats
        savechannels
      }
    }
  }
  return 0
}

proc pChanstatsJoinInput {nick uhost hand chan} {
  pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 7 1
  return 0
}

proc pChanstatsKickInput {nick uhost hand chan target reason} {
  pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 5 1
  pChanstatsDataAccrue [string tolower $target] [string tolower $chan] 8 1
  return 0
}

proc pChanstatsLoad {type} {
  global vChanstatsData
  global vChanstatsPutlog
  if {[file exists chanstats.txt]} {
    set count 0
    set id [open chanstats.txt r]
    set data [read -nonewline $id]
    close $id
    if {[array size vChanstatsData] != 0} {unset vChanstatsData}
    foreach record [split $data \n] {
      if {[llength [split $record]] == 12} {
        set vChanstatsData([join [lindex [split $record] 0]]) $record
      } else {
        incr count
      }
    }
    if {$vChanstatsPutlog} {putlog "\00314<chanstats>\003 loading data (\00314$type\003) --> loaded (\00314[array size vChanstatsData]\003), discarded (\00314$count\003)"}
  }
  return 0
}

proc pChanstatsModeInput {nick uhost hand chan mc target} {
  pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 6 1
  return 0
}

proc pChanstatsName {number} {
  global vChanstatsName
  switch -- $number {
    1 {return "public"}
    9 {return "permanent owner"}
    default {return $vChanstatsName($number)}
  }
}

proc pChanstatsNickInput {nick uhost hand chan newnick} {
  pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 11 1
  return 0
}

proc pChanstatsOutputRank {nick uhost hand chan text} {
  global vChanstatsData
  global vChanstatsStatus
  if {[channel get $chan chanstats]} {
    set command rank
    if {[pChanstatsFlag $nick $chan] >= $vChanstatsStatus($command)} {
      switch -- [llength [split [string trim $text]]] {
        2 {set tnick [join [lindex [split [string tolower [string trim $text]]] 0]]; set tchan [string tolower $chan]}
        3 {set tnick [join [lindex [split [string tolower [string trim $text]]] 0]]; set tchan [join [lindex [split [string tolower [string trim $text]]] 2]]}
        default {
          pChanstatsError 021 0 $nick 0 $chan 0 0 0 0 0 0 0
          return 0
        }
      }
      if {[array size vChanstatsData] != 0} {
        if {[regexp -- {^[\x41-\x7D][-\d\x41-\x7D]*$} $tnick]} {
          if {![isbotnick $tnick]} {
            if {[string equal [string index $tchan 0] "#"]} {
              if {[validchan $tchan]} {
                if {[info exists vChanstatsData($tnick\@$tchan)]} {
                  set opt [join [lindex [split [string trim [string tolower $text]]] 1]]
                  switch -- $opt {
                    linee {set name linee; set position 2}
                    parole {set name parole; set position 3}
                    azioni {set name azioni; set position 4}
                    kick {set name kick; set position 5}
                    ban {set name ban; set position 6}
                    join {set name join; set position 7}
                    part {set name part; set position 8}
                    split {set name split; set position 9}
                    quit {set name quit; set position 10}
                    nick {set name "cambi nick"; set position 11}
                    default {
                      pChanstatsError 002 0 $nick 0 $chan 0 0 0 0 0 0 0
                      return 0
                    }
                  }
                  foreach {key record} [array get vChanstatsData] {
                    if {[string equal $tchan [join [lindex [split $key @] 1]]]} {
                      if {![string equal [join [lindex [split $record] $position]] 0]} {
                        lappend data [list [lindex [split $key @] 0] [join [lindex [split $record] $position]]]
                        if {[info exists total]} {
                          set total [incr total [join [lindex [split $record] $position]]]
                        } else {set total [join [lindex [split $record] $position]]}
                      }
                    }
                  }
                  if {[info exists data]} {
                    set sorted [lsort -integer -decreasing -index 1 $data]
                    set events [join [lindex [split $vChanstatsData($tnick\@$tchan)] $position]]
                    set count [llength $sorted]
                    if {![string equal $events 0]} {
                      set rank [expr {[lsearch $sorted $tnick*] + 1}]
                      pChanstatsCompliance 005 0 $nick $tnick $chan $tchan $opt $rank $events $count $total 0
                    } else {pChanstatsError 022 0 $nick $tnick $chan $tchan $opt 0 0 0 0 0}
                  } else {pChanstatsError 006 0 $nick 0 $chan $tchan $name 0 0 0 0 0}
                } else {pChanstatsError 009 0 $nick $tnick $chan $tchan 0 0 0 0 0 0}
              } else {pChanstatsError 004 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
            } else {pChanstatsError 003 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
          } else {pChanstatsError 014 0 $nick 0 $chan 0 0 0 0 0 0 0}
        } else {pChanstatsError 008 0 $nick $tnick $chan 0 0 0 0 0 0 0}
      } else {pChanstatsError 005 0 $nick 0 $chan 0 0 0 0 0 0 0}
    } else {
      switch -- $vChanstatsStatus($command) {
        9 {pChanstatsError 015 $command $nick 0 $chan 0 0 0 0 0 0 0}
        default {pChanstatsError 016 $command $nick 0 $chan 0 0 0 0 0 0 0}
      }
    }
  }
  return 0
}

proc pChanstatsOutputStats {nick uhost hand chan text} {
  global vChanstatsData
  global vChanstatsStatus
  if {[channel get $chan chanstats]} {
    set command stats
    if {[pChanstatsFlag $nick $chan] >= $vChanstatsStatus($command)} {
      switch -- [llength [split [string trim $text]]] {
        1 {set tnick [string tolower [string trim $text]]; set tchan [string tolower $chan]}
        2 {set tnick [join [lindex [split [string tolower [string trim $text]]] 0]]; set tchan [join [lindex [split [string tolower [string trim $text]]] 1]]}
        default {
          pChanstatsError 007 0 $nick 0 $chan 0 0 0 0 0 0 0
          return 0
        }
      }
      if {[array size vChanstatsData] != 0} {
        if {[regexp -- {^[\x41-\x7D][-\d\x41-\x7D]*$} $tnick]} {
          if {![isbotnick $tnick]} {
            if {[string equal [string index $tchan 0] "#"]} {
              if {[validchan $tchan]} {
                if {[info exists vChanstatsData($tnick\@$tchan)]} {
                  set elapsed [duration [expr {[unixtime] - [join [lindex [split $vChanstatsData($tnick\@$tchan)] 1]]}]]
                  set linee [join [lindex [split $vChanstatsData($tnick\@$tchan)] 2]]
                  set parole [join [lindex [split $vChanstatsData($tnick\@$tchan)] 3]]
                  set azioni [join [lindex [split $vChanstatsData($tnick\@$tchan)] 4]]
                  set kick [join [lindex [split $vChanstatsData($tnick\@$tchan)] 5]]
                  set ban [join [lindex [split $vChanstatsData($tnick\@$tchan)] 6]]
                  set join [join [lindex [split $vChanstatsData($tnick\@$tchan)] 7]]
                  set part [join [lindex [split $vChanstatsData($tnick\@$tchan)] 8]]
                  set split [join [lindex [split $vChanstatsData($tnick\@$tchan)] 9]]
                  set quit [join [lindex [split $vChanstatsData($tnick\@$tchan)] 10]]
                  set nick [join [lindex [split $vChanstatsData($tnick\@$tchan)] 11]]
                  set output "linee ($linee), parole ($parole), azioni ($azioni), kick ($kick), ban ($ban), join ($join), part ($part), split ($split), quit ($quit), cambi nick ($nick)"
                  pChanstatsCompliance 002 0 $nick $tnick $chan $tchan $output $elapsed 0 0 0 0
                } else {pChanstatsError 009 0 $nick $tnick $chan $tchan 0 0 0 0 0 0}
              } else {pChanstatsError 004 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
            } else {pChanstatsError 003 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
          } else {pChanstatsError 014 0 $nick 0 $chan 0 0 0 0 0 0 0}
        } else {pChanstatsError 008 0 $nick $tnick $chan 0 0 0 0 0 0 0}
      } else {pChanstatsError 005 0 $nick 0 $chan 0 0 0 0 0 0 0}
    } else {
      switch -- $vChanstatsStatus($command) {
        9 {pChanstatsError 015 $command $nick 0 $chan 0 0 0 0 0 0 0}
        default {pChanstatsError 016 $command $nick 0 $chan 0 0 0 0 0 0 0}
      }
    }
  }
  return 0
}

proc pChanstatsOutputTop10 {nick uhost hand chan text} {
  global vChanstatsData
  global vChanstatsStatus
  if {[channel get $chan chanstats]} {
    set command top10
    if {[pChanstatsFlag $nick $chan] >= $vChanstatsStatus($command)} {
      switch -- [llength [split [string trim $text]]] {
        1 {set tchan [string tolower $chan]}
        2 {set tchan [join [lindex [split [string tolower [string trim $text]]] 1]]}
        default {
          pChanstatsError 001 0 $nick 0 $chan 0 0 0 0 0 0 0
          return 0
        }
      }
      if {[array size vChanstatsData] != 0} {
        if {[string equal [string index $tchan 0] "#"]} {
          if {[validchan $tchan]} {
            switch -- [join [lindex [split [string trim [string tolower $text]]] 0]] {
              linee {set name linee; set position 2}
              parole {set name parole; set position 3}
              azioni {set name azioni; set position 4}
              kick {set name kick; set position 5}
              ban {set name ban; set position 6}
              join {set name join; set position 7}
              part {set name part; set position 8}
              split {set name split; set position 9}
              quit {set name quit; set position 10}
              nick {set name "cambi nick"; set position 11}
              default {
                pChanstatsError 002 0 $nick 0 $chan 0 0 0 0 0 0 0
                return 0
              }
            }
            foreach {key record} [array get vChanstatsData] {
              if {[string equal $tchan [join [lindex [split $key @] 1]]]} {
                if {[expr {[join [lindex [split $record] $position]] != 0}]} {
                  lappend data [list [lindex [split $key @] 0] [join [lindex [split $record] $position]]]
                }
              }
            }
            if {[info exists data]} {
              set sorted [lrange [lsort -integer -decreasing -index 1 $data] 0 9]
              set count 1
              foreach element $sorted {
                lappend output [list $count\. [lindex $element 0] ([lindex $element 1])]
                incr count
              }
              pChanstatsCompliance 001 0 $nick 0 $chan $tchan "top 10" $name $output 0 0 0
            } else {pChanstatsError 006 0 $nick 0 $chan $tchan $name 0 0 0 0 0}
          } else {pChanstatsError 004 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
        } else {pChanstatsError 003 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
      } else {pChanstatsError 005 0 $nick 0 $chan 0 0 0 0 0 0 0}
    } else {
      switch -- $vChanstatsStatus($command) {
        9 {pChanstatsError 015 $command $nick 0 $chan 0 0 0 0 0 0 0}
        default {pChanstatsError 016 $command $nick 0 $chan 0 0 0 0 0 0 0}
      }
    }
  }
  return 0
}

proc pChanstatsOutputTop20 {nick uhost hand chan text} {
  global vChanstatsData
  global vChanstatsStatus
  if {[channel get $chan chanstats]} {
    set command top20
    if {[pChanstatsFlag $nick $chan] >= $vChanstatsStatus($command)} {
      switch -- [llength [split [string trim $text]]] {
        1 {set tchan [string tolower $chan]}
        2 {set tchan [join [lindex [split [string tolower [string trim $text]]] 1]]}
        default {
          pChanstatsError 018 0 $nick 0 $chan 0 0 0 0 0 0 0
          return 0
        }
      }
      if {[array size vChanstatsData] != 0} {
        if {[string equal [string index $tchan 0] "#"]} {
          if {[validchan $tchan]} {
            switch -- [join [lindex [split [string trim [string tolower $text]]] 0]] {
              linee {set name linee; set position 2}
              parole {set name parole; set position 3}
              azioni {set name azioni; set position 4}
              kick {set name kick; set position 5}
              ban {set name ban; set position 6}
              join {set name join; set position 7}
              part {set name part; set position 8}
              split {set name split; set position 9}
              quit {set name quit; set position 10}
              nick {set name "cambi nick"; set position 11}
              default {
                pChanstatsError 002 0 $nick 0 $chan 0 0 0 0 0 0 0
                return 0
              }
            }
            foreach {key record} [array get vChanstatsData] {
              if {[string equal $tchan [join [lindex [split $key @] 1]]]} {
                if {[expr {[join [lindex [split $record] $position]] != 0}]} {
                  lappend data [list [lindex [split $key @] 0] [join [lindex [split $record] $position]]]
                }
              }
            }
            if {[info exists data]} {
              set sorted [lrange [lsort -integer -decreasing -index 1 $data] 10 19]
              if {[llength $sorted] != 0} {
                set count 11
                foreach element $sorted {
                  lappend output [list $count\. [lindex $element 0] ([lindex $element 1])]
                  incr count
                }
                pChanstatsCompliance 001 0 $nick 0 $chan $tchan "top 20" $name $output 0 0 0
              } else {pChanstatsError 017 0 $nick 0 $chan $tchan [llength $data] $name 0 0 0 0}
            } else {pChanstatsError 006 0 $nick 0 $chan $tchan $name 0 0 0 0 0}
          } else {pChanstatsError 004 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
        } else {pChanstatsError 003 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
      } else {pChanstatsError 005 0 $nick 0 $chan 0 0 0 0 0 0 0}
    } else {
      switch -- $vChanstatsStatus($command) {
        9 {pChanstatsError 015 $command $nick 0 $chan 0 0 0 0 0 0 0}
        default {pChanstatsError 016 $command $nick 0 $chan 0 0 0 0 0 0 0}
      }
    }
  }
  return 0
}

proc pChanstatsOutputTstats {nick uhost hand chan text} {
  global vChanstatsData
  global vChanstatsStatus
  if {[channel get $chan chanstats]} {
    set command tstats
    if {[pChanstatsFlag $nick $chan] >= $vChanstatsStatus($command)} {
      switch -- [llength [split [string trim $text]]] {
        0 {set tchan [string tolower $chan]}
        1 {set tchan [string tolower [string trim $text]]}
        default {
          pChanstatsError 019 0 $nick 0 $chan 0 0 0 0 0 0 0
          return 0
        }
      }
      if {[array size vChanstatsData] != 0} {
        if {[string equal [string index $tchan 0] "#"]} {
          if {[validchan $tchan]} {
            set tlinee 0; set tparole 0; set tazioni 0; set tkick 0; set tban 0; set tjoin 0; set tpart 0; set tsplit 0; set tquit 0; set tnick 0
            foreach {name value} [array get vChanstatsData] {
              if {[string equal $tchan [join [lindex [split $name @] 1]]]} {
                incr tlinee [join [lindex [split $value] 2]]
                incr tparole [join [lindex [split $value] 3]]
                incr tazioni [join [lindex [split $value] 4]]
                incr tkick [join [lindex [split $value] 5]]
                incr tban [join [lindex [split $value] 6]]
                incr tjoin [join [lindex [split $value] 7]]
                incr tpart [join [lindex [split $value] 8]]
                incr tsplit [join [lindex [split $value] 9]]
                incr tquit [join [lindex [split $value] 10]]
                incr tnick [join [lindex [split $value] 11]]
              }
            }
            if {[expr {$tlinee + $tparole + $tazioni + $tkick + $tban + $tjoin + $tpart + $tsplit + $tquit + $tnick}] == 0} {
              pChanstatsError 020 0 $nick 0 $chan $tchan 0 0 0 0 0 0
            } else {
              set output "linee ($tlinee), parole ($tparole), azioni ($tazioni), kick ($tkick), ban ($tban), join ($tjoin), part ($tpart), split ($tsplit), quit ($tquit), cambi nick ($tnick)"
              pChanstatsCompliance 004 0 $nick 0 $chan $tchan $output 0 0 0 0 0
            }
          } else {pChanstatsError 004 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
        } else {pChanstatsError 003 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
      } else {pChanstatsError 005 0 $nick 0 $chan 0 0 0 0 0 0 0}
    } else {
      switch -- $vChanstatsStatus($command) {
        9 {pChanstatsError 015 $command $nick 0 $chan 0 0 0 0 0 0 0}
        default {pChanstatsError 016 $command $nick 0 $chan 0 0 0 0 0 0 0}
      }
    }
  }
  return 0
}

proc pChanstatsPartInput {nick uhost hand chan msg} {
  pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 8 1
  return 0
}

proc pChanstatsPubmInput {nick uhost hand chan text} {
  global vChanstatsPutlog
  if {![catch {set arguments [split [string trim [string trimleft [stripcodes bcruag $text] \"]]]}]} {
    if {![catch {set choice [string range [join [lindex $arguments 0]] 1 end]}]} {
      switch -- $choice {
        top10 - top20 - stats - tstats - zapstats {return 0}
        default {
          pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 2 1
          pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 3 [llength $arguments]
        }
      }
    } else {if {$vChanstatsPutlog} {putlog "<\00314chanstats\003> unable to split line of text <\00314$nick\003> <\00314$chan\003> skipped"}}
  } else {if {$vChanstatsPutlog} {putlog "<\00314chanstats\003> unable to split line of text <\00314$nick\003> <\00314$chan\003> skipped"}}
  return 0
}

proc pChanstatsRejnInput {nick uhost hand chan} {
  pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 7 1
  return 0
}

proc pChanstatsSave {type} {
  global vChanstatsData
  global vChanstatsIdleDays
  global vChanstatsPutlog
  if {[array size vChanstatsData] != 0} {
    set count 0
    foreach {key record} [array get vChanstatsData] {
      if {![validchan [join [lindex [split $key @] 1]]]} {
        lappend erase $key
        incr count
        continue
      }
      if {[join [lindex [split $record] 1]] <= [expr {[unixtime] - ($vChanstatsIdleDays * 86400)}]} {
        lappend erase $key
        incr count
        continue
      }
      lappend data $record
    }
    if {[info exists erase]} {
      foreach item $erase {
        unset vChanstatsData($item)
      }
    }
    if {[info exists data]} {
      set id [open chanstats.txt w]
      puts $id "[join $data \n]"
      close $id
    } else {
      set data {}
      if {[file exists chanstats.txt]} {
        file delete chanstats.txt
      }
    }
    if {$vChanstatsPutlog} {putlog "\00314<chanstats>\003 saving data (\00314$type\003) --> saved (\00314[llength $data]\003), discarded (\00314$count\003)"}
  }
  return 0
}

proc pChanstatsSchedule {} {
  global vChanstatsScheduleSave
  foreach schedule [binds time] {
    if {[string equal pChanstatsTimedSave [join [lindex $schedule 4]]]} {
      set minute [join [lindex [lindex $schedule 2] 0]]
      set hour [join [lindex [lindex $schedule 2] 1]]
      unbind TIME - "$minute $hour * * *" pChanstatsTimedSave
    }
  }
  set minute [strftime %M [expr {[unixtime] + ($vChanstatsScheduleSave * 60)}]]
  set hour [strftime %H [expr {[unixtime] + ($vChanstatsScheduleSave * 60)}]]
  bind TIME - "$minute $hour * * *" pChanstatsTimedSave
  return 0
}

proc pChanstatsSignInput {nick uhost hand chan reason} {
  pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 10 1
  return 0
}

proc pChanstatsSpltInput {nick uhost hand chan} {
  pChanstatsDataAccrue [string tolower $nick] [string tolower $chan] 9 1
  return 0
}

proc pChanstatsTimedSave {minute hour day month year} {
  pChanstatsSave schedule
  pChanstatsSchedule
  return 0
}

proc pChanstatsZapstats {nick uhost hand chan text} {
  global vChanstatsData
  global vChanstatsStatus
  global vChanstatsZapAllowed
  if {[channel get $chan chanstats]} {
    set command zapstats
    if {[pChanstatsFlag $nick $chan] >= $vChanstatsStatus($command)} {
      if {$vChanstatsZapAllowed} {
        if {[array size vChanstatsData] != 0} {
          switch -- [llength [split [string trim $text]]] {
            0 {set tchan [string tolower $chan]}
            1 {set tchan [string tolower [string trim $text]]}
            default {
              pChanstatsError 010 0 $nick 0 $chan 0 0 0 0 0 0 0
              return 0
            }
          }
          if {[string equal [string index $tchan 0] "#"]} {
            if {[validchan $tchan]} {
              if {[channel get $tchan chanstats]} {
                if {[array names vChanstatsData "*@$tchan"] != ""} {
                  foreach {key record} [array get vChanstatsData "*$tchan"] {
                    set vChanstatsData($key) [join [lreplace [split $record] 1 1 0]]
                  }
                  pChanstatsSave zapstats
                  pChanstatsCompliance 003 0 $nick 0 $chan $tchan 0 0 0 0 0 0
                  if {![string equal -nocase $chan $tchan]} {
                    pChanstatsEvent 001 0 0 $nick 0 $tchan 0 0 0 0 0 0
                  }
                } else {pChanstatsError 012 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
              } else {pChanstatsError 011 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
            } else {pChanstatsError 004 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
          } else {pChanstatsError 003 0 $nick 0 $chan $tchan 0 0 0 0 0 0}
        } else {pChanstatsError 005 0 $nick 0 $chan 0 0 0 0 0 0 0}
      } else {pChanstatsError 013 $command $nick 0 $chan 0 0 0 0 0 0 0}
    } else {
      switch -- $vChanstatsStatus($command) {
        9 {pChanstatsError 015 $command $nick 0 $chan 0 0 0 0 0 0 0}
        default {pChanstatsError 016 $command $nick 0 $chan 0 0 0 0 0 0 0}
      }
    }
  }
  return 0
}

# ---------- ACKNOWLEDGEMENT --------------------------------------------------------------------------------------------- #

putlog "\00314<chanstats>\003 versione $vChanstatsVersion tradotta da Carlino Caricata"

# eof
