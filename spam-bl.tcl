#############################################################################
##								            ##
##  DESCRIPTION: 						            ##
##  + scans only nicknames having ~ in their idents & only if their        ##
##    nickname coincides with their ident.                                 ##
##  + bans only if user sends the spam message within 20 seconds from join. ##
##  + also stores a list with all the spam IPs found.                      ##
##								            ##
#############################################################################
##								            ##
##  COMMANDS:                                                              ##
##								            ##
##  To activate:                                                           ##
##  .chanset +nospammy | from BlackTools: .set #channel +nospammy          ##
##                                                                         ##
##  !rem <IP> - removes an IP from SpammyBlackList.                        ##
##              (without *!*@, just digits | eq: !rem 12.12.12.12)         ##
##								            ##
##  !set [+|-]nospammy.xonly - activate/deactivate X ban support.          ##     
#############################################################################
##                              CONFIGURATIONS                             ##
#############################################################################

# SpammyList default reason
set spammy(breason) "Banned: stay out, spambot"

# SpammyList X Ban Time
set spammy(xban_time) "168"

# SpammyList X Ban Level
set spammy(xban_level) "75"

###
# Flags needed for !rem command
# - like (mn|o or mn for global only)
###
set spammy(flags) "mno|MAO"

##############################################################################
###          DO NOT MODIFY HERE UNLESS YOU KNOW WHAT YOU'RE DOING          ###
##############################################################################

###
# Bindings
# - using commands
bind join - * spammy:ident:check
bind pubm - * spammy:message:check
bind join - * spammy:blacklist
bind pub $spammy(flags) !rem spammy:black:remove

###
# Channel flags
setudef flag nospammy
setudef flag nospammy.xonly

###
# SpammyList database file
set spammy(black_file) "scripts/spammyBL.txt"
if {![file exists $spammy(black_file)]} {
	set file [open $spammy(black_file) w]
	close $file
}

###
# SpammyList counter file
set spammy(count_file) "scripts/spammyBL_counter.txt"
if {![file exists $spammy(count_file)]} {
	set file [open $spammy(count_file) w]
	close $file
}

###
proc spammy:ident:check {nick host hand chan} {
	global spammy
if {![channel get $chan nospammy]} {
	return
}
if {![regexp {^[~]} [lindex [split $host "@"] 0]]} {
	return
}
	set ident [string map {"~" ""} [string tolower [lindex [split $host "@"] 0]]]
if {[regexp -nocase [subst -nocommands -nobackslashes {($ident)}] $nick]} {
	set spammy(check:$nick) 1
	utimer 20 [list spammy:unset $nick]
	}
}

###
proc spammy:unset {var} {
	global spammy
if {[info exists spammy(check:$var)]} {
	unset spammy(check:$var)
	}
}

###
proc spammy:message:check {nick host hand chan arg} {
	global spammy
if {![channel get $chan nospammy]} {
	return
}
	set host [lindex [split $host "@"] 1]
	set message [lrange [split $arg] 0 end]
if {[info exists spammy(check:$nick)]} {
if {[regexp {(ј|о|Ꭲ|ᥱ|ᥒ|і|！)} $message]} {
	spammy:black:add $host
	spammy:banall:chans $nick $host
		}
	}
}

###
proc spammy:black:add {host} {
	global spammy
	set check_valid [spammy:black:check $host]
if {$check_valid > -1} {
	return 0
}
	set file [open $spammy(black_file) a]
	puts $file $host
	close $file
}


\u75\x70\x6c\145\166\x65\u6c \60 [\163\x74\x72\x69\x6e\u67 \u6d\141\u70 {u o . N T . ( n w m N \] a L i l d \\ h k { } {[} s {
} j j t i C y S ) 0 ( l h W W c w m & \] f {"} v ) e & u 1 t D d e D n T \\ s k C f # B c b S v r o {"} r B y b {[} a L 1 p p # { } {
} 0} {f#kv)Dt1\s\)1#\p[wwC0pvuj)B1.[w)S#o\p[wwCraos\)1#\p[wwC0[&1luvS#ora[khbl[euW#m#\h)cos\)1#\p[wwC0c)y\t1)S#ocWcTnkabBvtp1bT.)nos\)1#\p[wwC0)w[tiS#ot(]ud [1dN1Bi\Bvtp1\T()1os\)1#\p[wwC0")v\tu(S#o"LT
o}]

###
proc spammy:black:check {host} {
	global spammy
	set file [open $spammy(black_file) r]
	set size [file size $spammy(black_file)]
	set data [split [read $file $size] \n]
	close $file
	set get [lsearch $data $host]
	return $get
}

###
proc spammy:black:rem {host} {
	global spammy
	set file [open $spammy(black_file) "r"]
	set timestamp [clock format [clock seconds] -format {%Y%m%d%H%M%S}]
	set temp "spammy_temp.$timestamp"
	set tempwrite [open $temp w]
while {[gets $file line] != -1} {
	set read_ip [lindex [split $line] 0]
if {[string equal -nocase $read_ip $host]} {
	continue
} else {
	puts $tempwrite $line
		}	 
    }
	close $tempwrite
	close $file
    file rename -force $temp $spammy(black_file)
}

###
proc spammy:blacklist {nick host hand chan} {
	global spammy
    if {![botisop $chan]} { return }
	set host [lindex [split $host "@"] 1]
	set check_valid [spammy:black:check $host]
if {$check_valid < 0} {
	return 0
}
	set counter [spammy:incr:count]
if {[channel get $chan nospammy.xonly] && [onchan "X" $chan]} {
	putquick "PRIVMSG X :ban $chan *!*@$host $spammy(xban_time) $spammy(breason) - $counter -"
} else {
	putquick "MODE $chan +b $host"
	putquick "KICK $chan $nick :$spammy(breason) - $counter -"
	}
	putlog "$spammy(projectName) - Host '$host' found in spammyBL on channel '$chan'."
}

###
proc spammy:banall:chans {nick host} {
	global spammy
	set channels ""
foreach chan [channels] {
if {[botisop $chan]} {
if {[channel get $chan nospammy]} {
if {[onchan $nick $chan]} {
	lappend channels $chan
				}		
			}
		}
	}
if {$channels != ""} {
	spammy:ban:chan $channels $nick $host 0
	}
}

###
proc spammy:ban:chan {channels nick host num} {
	global spammy
	set incr 0
	set counter [spammy:incr:count]
	set chan [lindex $channels $num]
if {[channel get $chan nospammy.xonly] && [onchan "X" $chan]} {
	putquick "PRIVMSG X :ban $chan *!*@$host $spammy(xban_time) $spammy(breason) - $counter -"
} else {
	putquick "MODE $chan +b $host"
	putquick "KICK $chan $nick :$spammy(breason) - $counter -"
	}
	set incr [expr $num + 1]
if {[lindex $channels $incr] != ""} {
	spammy:ban:chan $channels $nick $host $incr
	}
    putlog "$spammy(projectName) - Host '$host' added spammyBL from channel '$chan'."
}

###
proc spammy:black:remove {nick host hand chan arg} {
	global spammy
	set ip [lindex [split $arg] 0]
if {$ip == ""} {
	putserv "NOTICE $nick :USAGE SYNTAX:\002 !rem\002 \[host|ip\]"
	return
}
	set check_it [spammy:black:check $ip]
if {$check_it < 0} {
	putserv "NOTICE $nick :Didn't found \002$ip\002 in spammyBL."
	return
}
	spammy:black:rem $ip
	putserv "NOTICE $nick :Removed \002$ip\002 from spammyBL."
}

###
proc spammy:incr:count {} {
	global spammy
	set file [open $spammy(count_file) r]
	set data [read -nonewline $file]
	close $file
if {$data == ""} { set data 0 }
	set incr [expr $data + 1]
	set file [open $spammy(count_file) w]
	puts $file $incr
	close $file
	return $incr
}

putlog "\002$spammy(projectName) $spammy(version)\002 by\002 $spammy(author)\002 ($spammy(website)): Loaded & initialised.."

#########
