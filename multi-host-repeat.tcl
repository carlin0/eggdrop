
# multi-host-repeat.tcl v1.6.5 (16Aug2018) by SpiKe^^, closely based on
# repeat.tcl v1.1 (9Apr1999) by slennox <slenny@ozemail.com.au>
# Special Thanks go out to speechles & caesar


##  Advanced multi-host repeat flood detection and protection script.  ##

##  Monitors all text from all channel users for signs of a botnet repeat flood.  ##
##  See Description & Versions @:  http://forum.egghelp.org/viewtopic.php?t=19898 ##


# Repeat flood, kick-ban on repeats:seconds #
set mhrp(flood) 3:10

# Repeat flood kick-ban reason #
set mhrp(reasn) "repeat flood"

# Max number of bans to stack in one mode command #
set mhrp(maxb) 3

# Max number of kicks to stack in one kick command #
# - set 0 to disable this script doing kicks (ex. set mhrp(maxk) 0) #
# NOTE: many networks allow more than one nick to be kicked per command. #
#       set this at or below the max for your network. #
set mhrp(maxk) 3

# Length of time in minutes to ban Repeat flooders #
# - set 0 to disable this script removing bans (ex. set mhrp(btime) 0) #
set mhrp(btime) 0

# After a valid Repeat flood, script will continue to #
# kick-ban offenders for an additional 'x' seconds #
set mhrp(xpire) 15


# Set the type of ban masks to use #                     <<== NEW SETTING OPTIONS <<==
#  0 = use eggdrop default bans (ex. *!*user@*.host.com) #
#  1 = use host/ip specific bans (ex. *!*@some.host.com) #
# Note: settings 2+ require eggdrop 1.6.20 or newer      #
#  2 = use wide masked host/ip bans (ex. *!*@*.host.com) #
#  3 = use extra-wide host bans (domain:  *!*@*.msn.com) #
#  4 = also use extra-wide ipv4 bans (ex.  *!*@68.186.*) #
#  5 = also extra-wide ipv6 bans  (ex.  *!*@2606:df00:*) #
set mhrp(btype) 1


# Set protected host(s) that should not be wide masked #
# - Example:  set mhrp(phost) "*.undernet.org *.irccloud.com"
#  Note: this setting only applies to ban types 2+ above! #
#  Note: set empty to not protect any hosts (ex. set mhrp(phost) "") #
#  Note: space separated if listing more than one protected host #
set mhrp(phost) ""

# Set channel mode(s) on flood detected. #
# - set empty to disable setting channel modes (ex. set mhrp(mode) "") #
set mhrp(mode) "rm"

# Remove these channel modes after how many seconds? #
set mhrp(mrem) 75

# Set user file flags that should be exempt from repeat flood monitoring. #
# - set empty to not exempt any user file flags (ex. set mhrp(xflag) "") #
set mhrp(xflag) "fo|fo"

# Should +o nicks in the channel (@nick) be exempt from repeat flood monitoring? #
#  0 = No: do not exempt +o nicks #
#  1 = Yes: exempt all opped nicks #
set mhrp(xop) 1

# Should +v nicks in the channel (+nick) be exempt from repeat flood monitoring? #
#  0 = No: do not exempt +v nicks #
#  1 = Yes: exempt all voiced nicks #
set mhrp(xvoice) 1

# Should halfop nicks in the channel be exempt from repeat flood monitoring? #
#  Note: Your network Must support halfop & Eggdrop setup for halfop on your network! #
#  0 = No: do not exempt halfop nicks #
#  1 = Yes: exempt all halfop nicks #
set mhrp(xhalfop) 0


# Script sends to the server using putnow? #                     <<== NEW SETTING <<==
#  Note: Don't use putnow unless your bot is opered and has no limits! #
#  0 = No: send to the server using putquick #
#  1 = Yes: send to the server using putnow #
set mhrp(pnow) 0



# END OF SETTINGS # Don't edit below unless you know what you're doing #

bind pubm - * rp_pubmsg
bind notc - * notc_wrap
bind ctcp - "ACTION" action_wrap

proc action_wrap {n u h d k t} {
  if {[isbotnick $d]} {  return 0  }
  rp_pubmsg $n $u $h $d $t
}
proc notc_wrap {n u h t d} {
  if {[isbotnick $d]} {  return 0  }
  rp_pubmsg $n $u $h $d $t
}

proc rp_pubmsg {nick uhost hand chan text} {
  global mhrp mhrc mhrq
  if {[isbotnick $nick]} { return 0 }
  if {$mhrp(xflag) ne "" && $hand ne "*"} {
    if {[matchattr $hand $mhrp(xflag) $chan]} { return 0 }
  }
  if {$mhrp(xop)==1 && [isop $nick $chan]} { return 0 }
  if {$mhrp(xvoice)==1 && [isvoice $nick $chan]} { return 0 }
  if {$mhrp(xhalfop)==1 && [ishalfop $nick $chan]} { return 0 }

  set uhost [string tolower $nick!$uhost]
  set chan [string tolower $chan]
  set text [string map [list \017 ""] [stripcodes abcgru $text]]
  set text [string tolower $text]
  set utnow [unixtime]
  set target [lindex $mhrp(flood) 0]
  if {[info exists mhrc($chan:$text)]} {
    set uhlist [lassign $mhrc($chan:$text) cnt ut]
    set utend [expr {$ut + [lindex $mhrp(flood) 1]}]
    set expire [expr {$utend + $mhrp(xpire)}]
    if {$cnt < $target} {
      if {$utnow > $utend} { unset mhrc($chan:$text) }
    } elseif {$utnow > $expire} { unset mhrc($chan:$text) }
  }
  if {![info exists mhrc($chan:$text)]} {
    set mhrc($chan:$text) [list 1 $utnow $uhost]
    return 0
  }
  incr cnt
  if {$cnt <= $target} {
    if {[lsearch $uhlist $uhost] == -1} { lappend uhlist $uhost }
    if {$cnt < $target} {
      set mhrc($chan:$text) [linsert $uhlist 0 $cnt $ut]
    } else {
      set mhrc($chan:$text) [list $cnt $ut]
      if {$mhrp(mode) ne "" && [string is digit -strict $mhrp(mrem)]} {

        $mhrp(phow) "MODE $chan +$mhrp(mode)"
        utimer $mhrp(mrem) [list $mhrp(phow) "MODE $chan -$mhrp(mode)"]

      }
      rp_dobans $chan $uhlist
    }
    return 0
  }
  if {![info exists mhrq($chan)]} {
    utimer 1 [list rp_bque $chan]
    set mhrq($chan) [list $uhost]
  } elseif {[lsearch $mhrq($chan) $uhost] == -1} {
    lappend mhrq($chan) $uhost
  }
  if {[llength $mhrq($chan)] >= $mhrp(maxb)} {
    rp_dobans $chan $mhrq($chan)
    set mhrq($chan) ""
  }
  return 0
}

proc rp_dobans {chan uhlist} {
  global mhrp
  if {![botisop $chan]} return
  set banList ""  ;  set nickList ""
  foreach ele $uhlist {
    scan $ele {%[^!]!%[^@]@%s} nick user host

    if {$mhrp(btype)==0} {  set bmask [maskhost $ele]

    } elseif {$mhrp(btype)>1} {  set type 4
      foreach ph $mhrp(phost) {
        if {[string match -nocase $ph $host]} {
          set type 2  ;  break
        }
      }
      set bmask [maskhost $ele $type]

      if {$mhrp(btype)>2 && $type==4} {
        set mhost [string range $bmask 4 end]
        if {[string index $mhost 0] eq "*"} {
          if {[llength [set mhls [split $mhost "."]]]>3} {
            set bmask "*!*@*.[lindex $mhls end-1].[lindex $mhls end]"
          }
        } elseif {[string index $mhost end-1] eq "."} {
          if {$mhrp(btype)>3} {  set mhls [split $mhost "."]
            set bmask "*!*@[lindex $mhls 0].[lindex $mhls 1].*"
          }
        } elseif {$mhrp(btype)>4} {  set mhls [split $mhost ":"]
          set bmask "*!*@[lindex $mhls 0]:[lindex $mhls 1]:*"
        }
      }

    } else {  set bmask "*!*@$host"  }

    if {[lsearch $banList $bmask] == -1} { lappend banList $bmask }
    if {[lsearch $nickList $nick] == -1} { lappend nickList $nick }
  }
  stack_bans $chan $mhrp(maxb) $banList
  if {$mhrp(maxk) > 0} {
    foreach nk $nickList { 
      if {[onchan $nk $chan]} {  lappend nkls $nk  } else { continue }
      if {[llength $nkls] == $mhrp(maxk)} {

        $mhrp(phow) "KICK $chan [join $nkls ,] :$mhrp(reasn)"

        unset nkls
      }
    } 
    if {[info exists nkls]} {

      $mhrp(phow) "KICK $chan [join $nkls ,] :$mhrp(reasn)"

    } 
  }
  if {$mhrp(btime) > 0} {
    set expire [expr {[unixtime] + $mhrp(btime)}]
    lappend mhrp(rmls) [list $expire $chan $banList]
  }
}

proc stack_bans {chan max banlist {opt +} } {
  set len [llength $banlist]
  while {$len > 0} {
    if {$len > $max} {
      set mode [string repeat "b" $max]
      set masks [join [lrange $banlist 0 [expr {$max - 1}]]]
      set banlist [lrange $banlist $max end]
      incr len -$max
    } else {
      set mode [string repeat "b" $len]
      set masks [join $banlist]
      set len 0
    }

    $mhrp(phow) "MODE $chan ${opt}$mode $masks"

  }
}

proc rp_bque {chan} {
  global mhrq
  if {![info exists mhrq($chan)]} { return }
  if {$mhrq($chan) eq ""} { unset mhrq($chan) ; return }
  rp_dobans $chan $mhrq($chan)
  unset mhrq($chan)
}

proc rp_breset {} {
  global mhrc mhrp
  set utnow [unixtime]
  set target [lindex $mhrp(flood) 0]
  foreach {key val} [array get mhrc] {
    lassign $val cnt ut
    set utend [expr {$ut + [lindex $mhrp(flood) 1]}]
    set expire [expr {$utend + $mhrp(xpire)}]
    if {$cnt < $target} {
      if {$utnow > $utend} { unset mhrc($key) }
    } elseif {$utnow > $expire} { unset mhrc($key) }
  }
  if {[info exists mhrp(rmls)]} {
    while {[llength $mhrp(rmls)]} {
      set next [lindex $mhrp(rmls) 0]
      lassign $next expire chan banList
      if {$expire > $utnow} {  break  }
      set mhrp(rmls) [lreplace $mhrp(rmls) 0 0]
      if {![info exists rmAra($chan)]} {  set rmAra($chan) $banList
      } else {  set rmAra($chan) [concat $rmAra($chan) $banList]  }
    }
    foreach {key val} [array get rmAra] {
      set banList ""
      foreach mask $val {
        if {![ischanban $mask $key]} {  continue  }
        lappend banList $mask
      }
      if {$banList eq ""} {  continue  }
      if {![botisop $key]} {
        set mhrp(rmls) [linsert $mhrp(rmls) 0 [list $utnow $key $banList]]
      } else {  stack_bans $key $mhrp(maxb) $banList -  }
    }
    if {![llength $mhrp(rmls)]} {  unset mhrp(rmls)  }
  }
  utimer 30 [list rp_breset]
}

if {![info exists rp_running]} {
  utimer 30 [list rp_breset]
  set rp_running 1
}


if {$numversion<"1062000" && $mhrp(btype)>1} {  set mhrp(btype) 1  }

set mhrp(phow) "putquick"
if {$mhrp(pnow)==1} {  set mhrp(phow) "putnow"  }


set mhrp(flood) [split $mhrp(flood) :]
set mhrp(btime) [expr {$mhrp(btime) * 60}]
set mhrp(phost) [split [string trim $mhrp(phost)]]
if {$mhrp(btime)==0 && [info exists mhrp(rmls)]} {  unset mhrp(rmls)  }

set mhrp(xflag) [string trim $mhrp(xflag)]
if {$mhrp(xflag) eq "-" || $mhrp(xflag) eq "-|-"} {  set mhrp(xflag) ""  }

putlog "Loaded multi-host-repeat.tcl v1.6.5 by SpiKe^^"

