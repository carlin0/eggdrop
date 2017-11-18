### Start configuring variables from here! ###

#USAGE: [1/2] (1=User defined channels, 2=All channels the bot is on)
set clonescan(chantype) "2"


###SET THIS ONLY IF YOU HAVE SET THE PREVIOUS SETTING TO '1'###
#Set the channels below (each separated by a space) on which this script would work.
#USAGE: set clonescan(channels) "#channel1 #channel2 #mychannel"
set clonescan(channels) "#gente #Torino ##"

#Set the time here in 'minutes' after which you would like the bot to scan the channel for clones.
#Note: Clones are detected in the format of: *!*@host.domain.com
#USAGE: Any integer value between 0 and 60.
set clonescan(time) "25"


#Set the 'maximum number' of clones here which would be detected by the script.
#If the number of users using the same *!*@host.domain.com is detected more than or
#equal to this number then the script will ban that IP address and kick out all the clones.
#USAGE: Any integer value
set clonescan(max) "3"


#Set this if you want the bot to scan users on joining the channel for clones.
#USAGE: [0/1] (0=OFF, 1=ON)
set clonescan(join) "1"


#Set the bantime here in 'minutes' which you want to ban the clones for with
#the hostmask *!*@host.domain.com
#USAGE: Any integer value
set clonescan(bantime) "120"


### SET THIS IF YOU WANT TO EXEMPT SPECIFIC HOST MASKS ###
#If you do not have any mask to exempt: set clonescan(exempt) {}
set clonescan(exempt) {
*!*@carlin0.xyz
}

##################################################
# This script automatically exempts people with: #
# (a) OPS and VOICES                             #
# (b) Virtual hosts (vhosts)                     #
# from the clone detection mechansim.            #
##################################################

##############################################################################
### Don't edit anything else from this point onwards even if you know tcl! ###
##############################################################################

if {$clonescan(chantype) == 1} {
 set clonescan(chans) $clonescan(channels)
} elseif {$clonescan(chantype) == 2} {
 set clonescan(chans) [channels]
}

set clonescan(auth) "\x61\x77\x79\x65\x61\x68"
set clonescan(ver) "v5.90.b"

bind time - "*" clone:scan:in:chan
if {$clonescan(join) == 1} { bind join - "*" clone:scan:on:join }

proc clone:scan:in:chan {m h d mo y} {
 global clonescan
 #check the time interval to perform the scan
 if {([scan $m %d]+([scan $h %d]*60)) % $clonescan(time) == 0} {

 #check all channels in the scan list
 foreach chan [split $clonescan(chans)] {

 #if channel is empty, skip to next channel in scan list
 if {[llength [chanlist $chan]] <= 1} { continue }

 #build list of channel users
 set userlist [list]
 foreach nick [chanlist $chan] {
  if {![isbotnick $nick] && ![matchattr [nick2hand $nick $chan] mn|mn $chan]} {
   lappend userlist [string tolower [lindex [split [getchanhost $nick $chan] @] 1]]
   }
 }

 #build list of channel ops and voices
 set oplist [list]
 foreach nick [chanlist $chan] {
  if {![isbotnick $nick] && ![matchattr [nick2hand $nick $chan] mn|mn $chan] && [isop $nick $chan] || [isvoice $nick $chan]} {
   lappend oplist [string tolower [lindex [split [getchanhost $nick $chan] @] 1]]
   }
 }
 set oplist [lsort -unique $oplist]

 #find no. of clone hosts in channel user list
 foreach host $userlist {
  if {![info exists count($host)]} {
   set count($host) 0
  } else {
   incr count($host)
   }
 }
 #if clones more than or equal to $clonescan(max), add them to the clone list
 set clonehost [list]
 foreach host $userlist {
  if {[expr $count($host) + 1] >= $clonescan(max)} {
   lappend clonehost $host
   }
 }
 unset count
 set clonehost [lsort -unique $clonehost]
 if {[llength $clonehost] == "0"} { continue }

 #filter out any exempt masks found in the clone list
 if {[llength [split $clonescan(exempt) "\n"]] > 0} {
 set exemptlist [list]
 foreach exempthost $clonescan(exempt) {
  lappend exemptlist $exempthost
 }
 if {[llength $exemptlist] > 0} {
  set exemptclones [list]
   foreach host $clonehost {
    if {![string match -nocase "*$host*" $exemptlist]} {
     lappend exemptclones $host
    } else {
     continue
    }
  }
  set clonehost [lsort -unique $exemptclones]
  if {[llength $clonehost] == "0"} { continue }
  }
 }

 #make a new list of clone ips, and exlude the ones found as vhosts
 set clonevhost [list]
 foreach host $clonehost {
  if {[info exists no_vhost_found]} { unset no_vhost_found }
  set tld [lindex [split $host "."] [expr [llength [split $host "."]] - 1]]
  set domain [lindex [split $host "."] [expr [llength [split $host "."]] - 2]]
  set nodomaintld [string map {" " "."} [lrange [split $host "."] 0 [expr [llength [split $host "."]] - 3]]]
  set numbers [regexp -all {[0-9]} $host]
  set alphabets [regexp -nocase -all {[a-z]} $host]
  set totalchar [expr $numbers + $alphabets]
  set numbersper [expr (($totalchar - $alphabets) * 100) / $totalchar]

  #ip address in format (0.0.0.0)
  if {([string length [string map {"." ""} $host]] <= 12) && ([regexp -all {\.} $host] == "3") && [string equal [string length [string map {"." ""} $host]] [regexp -all {[0-9]} $host]] && ([regexp -all -nocase {[a-z]} $host] == "0") && [regexp {^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$} $host] && ([regexp -all -nocase {[a-z]} $host] == "0") || ($numbersper == "100") && [regexp {^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$} $host]} {
   set no_vhost_found 1
  #ip address in domain format
  } elseif {([string length [string map {"." ""} $host]] >= 18) && ($numbersper >= 20) && ([regexp -all {\-} $domain] == "0") && ([regexp -all {[0-9]} $domain] == "0") && ([regexp -all {\-} $nodomaintld] >= 1) && ([regexp -all -nocase {[a-z]} $nodomaintld] >= 8)} {
   set no_vhost_found 1
  }
  if {[info exists no_vhost_found]} {
   lappend clonevhost $host
   unset no_vhost_found
   }
 }
 set clonehost [lsort -unique $clonevhost]
 if {[llength $clonehost] == "0"} { continue }

 #filter out any op or voice ips found in the clone list
 if {[llength $oplist] > 0} {
  set cloneops [list]
  foreach host $clonehost {
   if {![string match -nocase "*$host*" $oplist]} {
    lappend cloneops $host
   } else {
    continue
    }
  }
  set clonehost [lsort -unique $cloneops]
  if {[llength $clonehost] == "0"} { continue }
 }

 #replace clone list by banlist
 set blist [list $clonehost]

 #ban all the clone ips found
 foreach host $blist {
  if {![ischanban $host $chan]} {
   pushmode $chan +b *!*@$host
   utimer $clonescan(bantime) [list clone:scan:unban *!*@$host $chan]
   }
 }
 flushmode $chan

 #create list of clone nicks
 set klist [list]
 foreach host $blist {
  foreach nick [chanlist $chan] {
   if {[string equal -nocase [lindex [split [getchanhost $nick $chan] @] 1] $host] && ![isop $nick $chan] && ![isvoice $nick $chan]} {
     lappend klist $nick
     }
   }
 }

 #kick all the clone nicks found
 if {[llength $klist] > 0} {
  if {[llength $klist] <= "3"} {
   putkick $chan [join $klist ,] "0,1 Excessive Clones 12,0 - 2Excessive clones 12detected 12from 6host 12residing in the 2channel."
  } else {
   set nlist [list]
   foreach x $klist {
    lappend nlist $x
     if {[llength $nlist] == "3"} {
      putkick $chan [join $nlist ,] "0,1 Excessive Clones 12,0 - 2Excessive clones 12detected 12from 6host 12residing in the 2channel."
      set nlist [list]
      }
   }
   if {[llength $nlist] != ""} {
     putkick $chan [join $nlist ,] "0,1 Excessive Clones 12,0 - 2Excessive clones 12detected 12from 6host 12residing in the 2channel."
     set nlist [list]
     }
    }
   }
  }
 }
}


proc clone:scan:on:join {nick uhost hand chan} {
 global clonescan
 #initial checks
 if {[isbotnick $nick]} { return 0 }
 if {($clonescan(chantype) == 1) && ([lsearch -exact [split [string tolower $clonescan(chans)]] [string tolower $chan]] == -1)} { return 0 }

 #check if mask is in exempt list, if found then stop
 if {[llength [split $clonescan(exempt) "\n"]] > 0} {
 set exemptlist [list]
 foreach exempthost $clonescan(exempt) {
  lappend exemptlist $exempthost
 }
 if {[llength $exemptlist] > 0} {
  foreach host $exemptlist {
   if {[string match -nocase "*$host*" $nick!$uhost]} {
    return 0
    }
   }
  }
 }

 #check if host is a vhost, if it is a vhost then stop executing further
 set host [lindex [split $uhost @] 1]
 set tld [lindex [split $host "."] [expr [llength [split $host "."]] - 1]]
 set domain [lindex [split $host "."] [expr [llength [split $host "."]] - 2]]
 set nodomaintld [string map {" " "."} [lrange [split $host "."] 0 [expr [llength [split $host "."]] - 3]]]
 set numbers [regexp -all {[0-9]} $host]
 set alphabets [regexp -nocase -all {[a-z]} $host]
 set totalchar [expr $numbers + $alphabets]
 set numbersper [expr (($totalchar - $alphabets) * 100) / $totalchar]
 #ip address in format (0.0.0.0)
 if {([string length [string map {"." ""} $host]] <= 12) && ([regexp -all {\.} $host] == "3") && [string equal [string length [string map {"." ""} $host]] [regexp -all {[0-9]} $host]] && ([regexp -all -nocase {[a-z]} $host] == "0") && [regexp {^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$} $host] && ([regexp -all -nocase {[a-z]} $host] == "0") || ($numbersper == "100") && [regexp {^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$} $host]} {
  return 0
 }
 #ip address in domain format
 if {([string length [string map {"." ""} $host]] >= 18) && ($numbersper >= 20) && ([regexp -all {\-} $domain] == "0") && ([regexp -all {[0-9]} $domain] == "0") && ([regexp -all {\-} $nodomaintld] >= 1) && ([regexp -all -nocase {[a-z]} $nodomaintld] >= 8)} {
  return 0
 }

 #build list of channel ops and voices
 set oplist [list]
 foreach user [chanlist $chan] {
  if {![isbotnick $user] && ![matchattr [nick2hand $user $chan] mn|mn $chan] && [isop $user $chan] || [isvoice $user $chan]} {
   lappend oplist [string tolower [lindex [split [getchanhost $user $chan] @] 1]]
   }
 }
 set oplist [lsort -unique $oplist]

 #match joined host with oplist, if ip is same as an op, then stop executing
 if {[llength $oplist] > 0} {
  if {[string match -nocase "*$host*" $oplist]} {
   return 0
   }
 }

 #check for clones from the joined ip
 set klist [list]
 foreach user [chanlist $chan] {
  if {![isbotnick $user] && ![matchattr [nick2hand $user $chan] mn|mn $chan] && ![isop $user $chan] && ![isvoice $user $chan] && [string equal -nocase [lindex [split [getchanhost $user $chan] @] 1] $host]} {
   lappend klist $user
   }
 }

 #if clones more than or equal to $clonescan(max), ban the ip
 if {[llength $klist] >= $clonescan(max)} {
  putquick "MODE $chan +b *!*@$host"
  utimer $clonescan(bantime) [list clone:scan:unban *!*@$host $chan]

 #kick all the clone nicks found
 if {[llength $klist] > 0} {
  if {[llength $klist] <= "3"} {
   putkick $chan [join $klist ,] "0,1 Excessive Clones 12,0 - 2Excessive clones 12detected 12from 6host 12residing in the 2channel."
  } else {
   set nlist [list]
   foreach x $klist {
    lappend nlist $x
     if {[llength $nlist] == "3"} {
      putkick $chan [join $nlist ,] "0,1 Excessive Clones 12,0 - 2Excessive clones 12detected 12from 6host 12residing in the 2channel."
      set nlist [list]
      }
   }
   if {[llength $nlist] != ""} {
    putkick $chan [join $nlist ,] "0,1 Excessive Clones 12,0 - 2Excessive clones 12detected 12from 6host 12residing in the 2channel."
    set nlist [list]
    }
   }
  }
 }
}


proc clone:scan:unban {ban chan} {
 if {[botisop $chan]} {
  if {![ischanban $ban $chan]} {
    pushmode $chan -b $ban
    }
  }
}

if {![string equal "\x61\x77\x79\x65\x61\x68" $clonescan(auth)]} { set clonescan(auth) \x61\x77\x79\x65\x61\x68 }
putlog "Clone Scanner loaded."


