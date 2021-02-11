bind pub n "!ban" op_and_ban
bind pub n "!unban" op_and_unban
bind pub n "!mute" op_and_mute
bind pub n "!unmute" op_and_unmute

proc op_and_ban {nick uhost handle chan text} {
	global botnick
	putserv "privmsg ChanServ :op $chan $botnick"
	utimer 1 [list putserv "mode $chan +b-o [maskhost [lindex [split $text] 0]![getchanhost [lindex [split $text] 0] $chan] 2] $botnick " ]
}

proc op_and_unban {nick uhost handle chan text} {
	global botnick
	putserv "privmsg ChanServ :op $chan $botnick"
	utimer 1 [list putserv "mode $chan -bo [lindex [split $text] 0] $botnick " ]
}

proc op_and_mute {nick uhost handle chan text} {
	global botnick
	putserv "privmsg ChanServ :op $chan $botnick"
	utimer 1 [list putserv "mode $chan +q-o [maskhost [lindex [split $text] 0]![getchanhost [lindex [split $text] 0] $chan] 2] $botnick " ]
}

proc op_and_unmute {nick uhost handle chan text} {
	global botnick
	putserv "privmsg ChanServ :op $chan $botnick"
	utimer 1 [list putserv "mode $chan -qo [lindex [split $text] 0] $botnick " ]
}
