# badnick.tcl
# Tradotta e modificata da Carlin0

### ---------- operation ---------------------------------------------------------------------- ###

# creates and manages a list of banned nicks from badnick.txt in the bots root directory
# nicks joining selected bot channels are checked against badnick.txt and kicked and/or banned if present

# to function in #channelname requires in the partyline .chanset #channelname +badnick
# this applies to both commands AND punishment if a nick is present in badnick.txt

# syntax, assuming default trigger character .

# .bad add <nick> ... adds nick to badnick.txt
# .bad del <nick> ... deletes <nick> from badnick.txt
# .bad show ... shows all nicks in badnick.txt

# avoid endless loops by adding nicks that are protected by the bot

### ---------- configuration ------------------------------------------------------------------ ###

# set here the single character command trigger
set vBadnickTrigger !

# set here the bot user flag(s) of people authorised to use the commands
set vBadnickFlag o

# set here the ban time in minutes
# a setting of 0 means that the ban will not be automatically removed by this script
set vBadnickTime 0

# set punishment mode here
# mode 1 may be unwise since the user may rejoin, get kicked, rejoin, get kicked ... ad nauseum
# 1 == kick only
# 2 == ban only
# 3 == ban then kick
set vBadnickMode 3

# set here the banmask type
# this could be set such that evading badnick.txt by changing nick, will not evade a previously set ban
#  1 == nick!*user@host
#  2 == nick!*@host
#  3 == *!*user@host
#  4 == *!*@host
#  5 == nick!*user@mask
#  6 == nick!*@mask
#  7 == *!*user@mask
#  8 == *!*@mask
#  9 == nick!*user@*
# 10 == nick!*@*
# 11 == *!*user@*
set vBadnickType 4

### ---------- code --------------------------------------------------------------------------- ###

set vBadnickVersion 11.03.28.21.35

setudef flag badnick

proc pBadnickTrigger {} {
    global vBadnickTrigger
    return $vBadnickTrigger
}

bind PUB $vBadnickFlag [pBadnickTrigger]bad pBadnickPub
bind JOIN - * pBadnickJoin
bind NICK - * pBadnickJoin

proc pBadnickAdd {target chan} {
    global vBadnickList
    pBadnickRead
    if {[info exists vBadnickList]} {
        if {[lsearch -exact $vBadnickList [string tolower $target]] != -1} {
            pBadnickError 06 0 $target $chan 0
            return 0
        }
    }
    lappend vBadnickList [string tolower $target]
    pBadnickWrite
    pBadnickDone 01 0 $target $chan 0
    foreach channel [channels] {
        if {[channel get $channel badnick]} {
            if {([onchan $target $channel]) && ([botisop $channel])} {
                pBadnickPunish $target [getchanhost $target $channel] $channel
            }
        }
    }
    return 0
}

proc pBadnickDel {target chan} {
    global vBadnickList
    pBadnickRead
    if {[info exists vBadnickList]} {
        if {[set idx [lsearch -exact $vBadnickList [string tolower $target]]] != -1} {
            set vBadnickList [lreplace $vBadnickList $idx $idx]
            pBadnickWrite
            pBadnickDone 02 0 $target $chan 0
        } else {pBadnickError 08 0 $target $chan 0}
    } else {pBadnickError 07 0 0 $chan 0}
    return 0
}

proc pBadnickDone {number command target chan text} {
    switch -- $number {
        01 {set output "$target è stato aggiunto a badnick.txt"}
        02 {set output "$target è stato cancellato da badnick.txt"}
        03 {set output $text}
        default {}
    }
    putserv "PRIVMSG $chan :$output"
    return 0
}

proc pBadnickError {number command target chan text} {
    switch -- $number {
        01 {set output "$target non è un nick valido"}
        02 {set output "la sintassi corretta è [pBadnickTrigger]bad $command <nick>"}
        03 {set output "la sintassi corretta è [pBadnickTrigger]bad $command (senza altri argomenti)"}
        04 {set output "comando sconosciuto [pBadnickTrigger]bad $command"}
        05 {set output "[pBadnickTrigger]bad deve essere seguito da add, del o show"}
        06 {set output "$target è già contenuto in badnick.txt"}
        07 {set output "badnick.txt non ha ancora alcun nick definito"}
        08 {set output "badnick.txt non contiene il nick $target"}
        default {}
    }
    putserv "PRIVMSG $chan :$output"
    return 0
}

proc pBadnickJoin {nick uhost hand chan} {
    global vBadnickList
    if {[channel get $chan badnick]} {
        pBadnickRead
        if {[info exists vBadnickList]} {
            if {[lsearch -exact $vBadnickList [string tolower $nick]] != -1} {
                if {[botisop $chan]} {
                    pBadnickPunish $nick $uhost $chan
                }
            }
        }
    }
    return 0
}

proc pBadnickMask {nick uhost type} {
    scan $uhost {%[^@]@%s} user host
    set user [string trimleft $user ~]
    switch -- [regexp -- {^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $host] {
        0 {
            switch -- [regexp -all -- {\.} $host] {
                0 - 1 {set mask $host}
                2 {set mask *.[join [lrange [split $host .] 1 end] .]}
                default {set mask *.[join [lrange [split $host .] 2 end] .]}
            }
        }
        1 {set mask [join [lrange [split $host .] 0 end-1] .].*}
        default {}
    }
    switch -- $type {
        1  {set hostmask ${nick}!*${user}@$host}
        2  {set hostmask ${nick}!*@$host}
        3  {set hostmask *!*${user}@$host}
        4  {set hostmask *!*@$host}
        5  {set hostmask ${nick}!*${user}@$mask}
        6  {set hostmask ${nick}!*@$mask}
        7  {set hostmask *!*${user}@$mask}
        8  {set hostmask *!*@$mask}
        9  {set hostmask ${nick}!*${user}@*}
        10 {set hostmask ${nick}!*@*}
        11 {set hostmask *!*${user}@*}
        default {}
    }
    return $hostmask
}

proc pBadnickPub {nick uhost hand chan text} {
    if {[channel get $chan badnick]} {
        set arguments [split [string trim $text]]
        if {[llength $arguments] > 0} {
            set command [lindex $arguments 0]
            switch -- $command {
                add {
                    if {[llength $arguments] == 2} {
                        set target [lindex $arguments 1]
                        if {[regexp -- {^[\x41-\x7D][-\d\x41-\x7D]*$} $target]} {
                            pBadnickAdd $target $chan
                        } else {pBadnickError 01 0 $target $chan 0}
                    } else {pBadnickError 02 $command 0 $chan 0}
                }
                del {
                    if {[llength $arguments] == 2} {
                        set target [lindex $arguments 1]
                        if {[regexp -- {^[\x41-\x7D][-\d\x41-\x7D]*$} $target]} {
                            pBadnickDel $target $chan
                        } else {pBadnickError 01 0 $target $chan 0}
                    } else {pBadnickError 02 del 0 $chan 0}
                }
                show {
                    if {[llength $arguments] == 1} {
                        pBadnickShow $chan
                    } else {pBadnickError 03 show 0 $chan 0}
                }
                default {pBadnickError 04 $command 0 $chan 0}
            }
        } else {pBadnickError 05 0 0 $chan 0}
    }
    return 0
}

proc pBadnickPunish {target uhost chan} {
    global vBadnickMode vBadnickTime vBadnickType
    switch -- $vBadnickMode {
        1 {
            putserv "KICK $chan $target :badnick.txt"
        }
        2 - 3 {
            set hostmask [pBadnickMask $target $uhost $vBadnickType]
            putserv "MODE $chan +b $hostmask"
            if {![string equal $vBadnickTime 0]} {timer $vBadnickTime [list pBadnickRemove $chan $hostmask]}
            if {[string equal $vBadnickMode 3]} {putserv "KICK $chan $target :badnick.txt"}
        }
        default {}
    }
    return 0
}

proc pBadnickRead {} {
    global vBadnickList
    unset -nocomplain -- vBadnickList
    if {[file exists badnick.txt]} {
        set fp [open badnick.txt r]
        set data [split [read -nonewline $fp] \n]
        close $fp
        if {[llength $data] != 0} {set vBadnickList $data}
    }
    return 0
}

proc pBadnickRemove {chan hostmask} {
    putserv "MODE $chan -b $hostmask"
    return 0
}

proc pBadnickShow {chan} {
    global vBadnickList
    pBadnickRead
    if {[info exists vBadnickList]} {
        while {[llength $vBadnickList] != 0} {
            pBadnickDone 03 0 0 $chan [join [lrange $vBadnickList 0 9]]
            set vBadnickList [lrange $vBadnickList 10 end]
        }
    } else {pBadnickError 07 0 0 $chan 0}
    return 0
}

proc pBadnickWrite {} {
    global vBadnickList
    set fp [open badnick.txt w]
    puts -nonewline $fp [join $vBadnickList \n]
    close $fp
    return 0
}

putlog "badnick.tcl versione $vBadnickVersion caricata"

# eof
