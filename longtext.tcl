########################
#- Channel Activation -#
########################

# DCC/Partyline :  n|n .chanset   Use .chanset to activate the protections for the particular channel or not.
#       Example : .chanset #mychan1 +longtxt
#                 .chanset #mychan2 -longtxt

######################
#- Characters Limit -#
######################

# Set the maximum charaters which is allow to broadcast in a Line.
set longline(txt_len) 333

###############
#- Lock Mode -#
###############

# Set channel modes which you want to be used for locking,
# Leave blank "" if you dont like to set modes.
# set longline(modes) "m"
set longline(modes) ""

##############
#- BAN Type -#
##############

# Set the banmask type to use in banning the IPs  
# Currently BAN Type is set to 1 (*!*@some.domain.com),
# BAN Types are given below;
# 1 - *!*@some.domain.com 
# 2 - *!*@*.domain.com
# 3 - *!*ident@some.domain.com
# 4 - *!*ident@*.domain.com
# 5 - *!*ident*@some.domain.com
# 6 - *nick*!*@*.domain.com
# 7 - *nick*!*@some.domain.com
# 8 - nick!ident@some.domain.com
# 9 - nick!ident@*.host.com
set lt_btype 1


###############
#- Lock Time -#
###############

# Set the unlock time (in seconds), How much time it takes to do -m after the Long Text detection.
set longline(unlock) 45

#####################
#- Kick/BAN Reason -#
#####################

# Set kick/ban reason here.
set longline(reason) "Quanto parli ..."

#####################
#- Voice Exemption -#
#####################

# Voice Immune [0/1]:Set to 1 if you want to protect users who are voiced,
# -OR- Set to 0 to punish everyone who broadcast longline in the channel.
# (NOTE: This script does not kick any Operator(s).)
set longline(vxmpt) 1

##############
#- BAN Time -#
##############

# Set time period (in minutes), How much time it takes to unban punished user.
# la riga sotto è commentata per rendere il ban permanente
# set longline(ub) 0


########################################################
#- Don't edit below unless you know what you're doing -#
########################################################

setudef flag longtxt
bind pubm - * longline:pubm
bind ctcp - ACTION longline:action

proc longline:pubm {nick uhost hand chan txt} {
  global longline
  if {![channel get $chan longtxt]} { return 0 }
  if {($longline(vxmpt) == 1) && [isvoice $nick $chan]} { return 0 }
  if {![botisop $chan] || [isbotnick $nick] || [isop $nick $chan] || [matchattr $hand b] || [matchattr $hand f|f $chan] || [matchattr $hand mo|mo $chan]} {
    return
  }
  if {[string length $txt] >= $longline(txt_len)} {
    set banmask [lt:banmask $uhost $nick]
    putquick "MODE $chan +$longline(modes)b $banmask" 
    putserv "KICK $chan $nick :$longline(reason)"
    utimer $longline(unlock) [list putserv "MODE $chan -$longline(modes)"]
    timer $longline(ub) [list putserv "MODE $chan -b $banmask"]
  }
}
proc longline:action {nick uhost hand chan keyword arg} {
 if {[isbotnick [lindex [split $chan "@"] 0]] || [lindex [split $chan "@"] 1] != ""} {return 0}
 longline:pubm $nick $uhost $hand $chan $arg
}
proc lt:banmask {uhost nick} {
 global lt_btype
  switch -- $lt_btype {
   1 { set banmask "*!*@[lindex [split $uhost @] 1]" }
   2 { set banmask "*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
   3 { set banmask "*!*$uhost" }
   4 { set banmask "*!*[lindex [split [maskhost $uhost] "!"] 1]" }
   5 { set banmask "*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" }
   6 { set banmask "*$nick*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
   7 { set banmask "*$nick*!*@[lindex [split $uhost "@"] 1]" }
   8 { set banmask "$nick![lindex [split $uhost "@"] 0]@[lindex [split $uhost @] 1]" }
   9 { set banmask "$nick![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
   default { set banmask "*!*@[lindex [split $uhost @] 1]" }
   return $banmask
  }
}

putlog "LOADED: Long Text Protection"
