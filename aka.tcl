
##############################################################################################
##  ##     aka.tcl for eggdrop by Ford_Lawnmower irc.geekshed.net #Script-Help          ##  ##
##############################################################################################
## .chanset #chan +aka for each channel you want to run the !aka trigger on.                ##
## .chanset #chan +akashowlog to automatically see aka's in the partyline on join.          ##
## .chanset #chan +akashowchan to automatically see aka's in #chan                          ##
##############################################################################################
##      ____                __                 ###########################################  ##
##     / __/___ _ ___ _ ___/ /____ ___   ___   ###########################################  ##
##    / _/ / _ `// _ `// _  // __// _ \ / _ \  ###########################################  ##
##   /___/ \_, / \_, / \_,_//_/   \___// .__/  ###########################################  ##
##        /___/ /___/                 /_/      ###########################################  ##
##                                             ###########################################  ##
##############################################################################################
##  ##                             Start Setup.                                         ##  ##
##############################################################################################
namespace eval aka {
## Edit cmdchar to change the !trigger used to for this script                          ##  ##
  variable cmdchar "!"
## AKA Logo edit to change                                                              ##  ##
  variable logo "\002\00304\[\00307A\00304K\00307A\00304\]\017"
## Edit nicktextf to change the colors of the nickname.                                 ##  ##
  variable nicktextf "\017\00309"
## Edit nickstextf to change the colors of the nicks in the aka list                    ##  ##
  variable nickstextf "\017\00304"
## addresstype defines the type of search AKA uses to match users. Valid values are     ##  ##
## 0-9 0 *!user@host, 1 *!*user@host, 2 *!*@host, 3 *!*user@*.host, 4 *!*@*.host, 5     ##  ##
## nick!user@host, 6 nick!*user@host, 7 nick!*@host, 8 nick!*user@*.host, 9 nick!*@*.host   ##
  variable addresstype 2
## dupsdelay is the delay in seconds before the aka for a nick already displayed will   ##  ##
## be displayed again. This prevents redisplay on /hop and duplicates in partyline      ##  ##
  variable dupsdelay 5
## maxakas is the maximum number of nicks that will be recorded for a single hostmask   ##  ##
  variable maxakas 25


######################################################################
## Slight script modification by Spike^^ to give the option to have ##
## this script report on-join aka info to a report channel.         ##
## NOTE: This disables +akashowlog for all on-join aka infos.       ##
######################################################################

## Set the report channel here (one channel), or leave blank to disable report channel ##
  variable reportchan ""


##############################################################################################
##  ##                           End Setup.                                              ## ##
##############################################################################################
  setudef flag akashowchan
  setudef flag akashowlog
  setudef flag aka
  bind dcc - aka aka::dccsearch
  bind pub -|- [string trimleft $aka::cmdchar]aka aka::search
  bind join -|- * aka::join
  bind nick -|- * aka::nick
  bind evnt -|- prerehash aka::savehash
  bind evnt -|- prerestart aka::savehash
  bind evnt -|- disconnect-server aka::savehash
  bind evnt -|- save aka::savehash
  bind evnt -|- init-server aka::loadhash
  proc dccsearch {hand idx text {matchno 1}} {
    if {[getchanhost $text] != ""} {
      set ltext [string tolower $text]
      set hostmask "akaindex[address "${text}![getchanhost $text]" $aka::addresstype]"
      if {[llength [hget "AKA" $hostmask]] <= 1} {
        putlog "${aka::logo} ${aka::nicktextf}${text} ${aka::nickstextf} has not been know by any other names."
      } else {
        putlog "${aka::logo} ${aka::nicktextf}${text} $aka::logo ${aka::nickstextf}[string map {" " \,} [hget "AKA" $hostmask]]"
      }
    } else {
      if {[hfind "AKA" "*${text}*" $matchno] != ""} {
        set hostmask "akaindex[address [hfind "AKA" "*${text}*" $matchno] $aka::addresstype]"
      }
      if {[hfind "AKA" "*${text}*" $matchno] == ""} {
        putlog "${aka::logo} ${aka::nickstextf}I have no data for ${aka::nicktextf}${text}."
      } elseif {[llength [hget "AKA" $hostmask]] <= 1} {
        putlog "${aka::logo} ${aka::nicktextf}${text} ${aka::nickstextf} has not been know by any other names."
      } else {
        putlog "${aka::nicktextf}${text} $aka::logo ${aka::nickstextf}[string map {" " \,} [hget "AKA" $hostmask]]"
      }
    }
  }
  proc search {nick host hand chan text {matchno 1}} {
    if {[lsearch -exact [channel info $chan] +aka] != -1} {
      if {[getchanhost $text] != ""} {
        set hostmask "akaindex[address "${text}![getchanhost $text]" $aka::addresstype]"
        if {[llength [hget "AKA" $hostmask]] <= 1} {
          putserv "PRIVMSG $chan :${aka::logo} ${aka::nicktextf}${text} ${aka::nickstextf} has not been know by any other names."
        } else {
          putserv "PRIVMSG $chan :${aka::logo} ${aka::nicktextf}${text} $aka::logo ${aka::nickstextf}[string map {" " \,} [hget "AKA" $hostmask]]"
        }
      } else {
        if {[hfind "AKA" "*${text}*" $matchno] != ""} {
          set hostmask "akaindex[address [hfind "AKA" "*${text}*" $matchno] $aka::addresstype]"
        }
        if {[hfind "AKA" "*${text}*" $matchno] == ""} {
          putserv "PRIVMSG $chan :${aka::logo} ${aka::nickstextf}I have no data for ${aka::nicktextf}${text}."
        } elseif {[llength [hget "AKA" $hostmask]] <= 1} {
          putserv "PRIVMSG $chan :${aka::logo} ${aka::nicktextf}${text} ${aka::nickstextf} has not been know by any other names."
        } else {
          putserv "PRIVMSG $chan :${aka::nicktextf}${text} $aka::logo ${aka::nickstextf}[string map {" " \,} [hget "AKA" $hostmask]]"
        }
      }
    }
  }
  proc loadhash {type} {
    if {[file exists "${::network}aka.hsh"]} { aka::hload "AKA" "${::network}aka.hsh" }
  }
  proc savehash {type} {
    hsave "AKA" "${::network}aka.hsh"
  }
  proc nick {nick host hand chan newnick} {
    set hostmask "akaindex[address "${nick}!${host}" $aka::addresstype]"
    hadd "AKA" "${nick}!${host}" [unixtime]
    hadd "AKA" $hostmask [nodups [hget "AKA" $hostmask] $newnick]
  }
  proc ntimer {name seconds command} {
    set killtimer [hget NTIMER $name]
    if {[set idx [lsearch -glob [utimers] "*$killtimer*"]] != -1 && $killtimer != ""} {
      putlog "killed timer [lindex [lindex [utimers] $idx] 2]"
      killutimer [lindex [lindex [utimers] $idx] 2]
    }
    hadd NTIMER $name [utimer $seconds $command]
    utimer $seconds "aka::hdel {NTIMER} $name"
  }
  proc address {hostmask type} {
    set halfhost ""
    regexp -- {^(.*)\!(.*)@(.*?)(\..*\..*)?$} $hostmask wholematch nick user host halfhost
    switch $type {
      0 { return "*!${user}@${host}${halfhost}" }
      1 { return "*!*${user}@${host}${halfhost}" }
      2 { return "*!*@${host}${halfhost}" }
      3 {
          if {$halfhost != ""} {
            return "*!*${user}@*${halfhost}"
          } else {
            return "*!*${user}@${host}${halfhost}"
          }
        }
      4 {       
          if {$halfhost != ""} {
            return "*!*@*${halfhost}"
          } else {
            return "*!*@${host}${halfhost}"
          }
        }
      5 { return $hostmask }
      6 { return "${nick}!*${user}@${host}${halfhost}" }
      7 { return "${nick}!*@${host}${halfhost}" }
      8 {
          if {$halfhost != ""} {
            return "${nick}!*${user}@*${halfhost}"
          } else {
            return "${nick}!*${user}@${host}${halfhost}"
          }
        }
      9 {
          if {$halfhost != ""} {
            return "${nick}!*@*${halfhost}"
          } else {
            return "${nick}!*@${host}${halfhost}"
          }
        }
      default { return $hostmask }
    }
  }
  proc joinadd {chan} {
    foreach user [chanlist $chan] {
      set host [getchanhost $user $chan]
      set hostmask "akaindex[address "${user}!${host}" $aka::addresstype]"
      hadd "AKA" "${user}!${host}" [unixtime]
      hadd "AKA" $hostmask [nodups [hget "AKA" $hostmask] $user]
    }   
  }
  proc nodups {text add} {
    set return ""
    set addfix [string map {\[ \( \] \) \\ \\\\} $add]
    foreach name $text {
      set namefix [string map {\[ \( \] \) \\ \\\\} $name]
      if {![string match -nocase $namefix $addfix]} {
        set return [concat $return $name]
      }
    }
    if {[llength $return] >= [expr $aka::maxakas -1]} {
      set return [lrange $return 1 end]
    }
    return [concat $return $add]
  }
  proc noop {nick} {
    return 0
  } 
  proc join {nick host hand chan} {
    if {$nick != $::botnick} {
      set hostmask "akaindex[address "${nick}!${host}" $aka::addresstype]"
      set safenick [string map {\[ \{ \] \}} $nick]
      hadd "AKA" "${nick}!${host}" [unixtime]
      hadd "AKA" $hostmask [nodups [hget "AKA" $hostmask] $nick]
      if {$nick != [hget "AKA" $hostmask]} {


        if {$aka::reportchan != ""} {
          if {[lsearch -glob [utimers] "*aka::noop $safenick*"] == -1} {
            putmsg $aka::reportchan "$aka::logo ${aka::nicktextf}${nick} $chan $aka::logo\
                   ${aka::nickstextf}[string map {" " "\,"} [hget "AKA" $hostmask]]"
            utimer $aka::dupsdelay "aka::noop $safenick"
          }


        } elseif {[lsearch -exact [channel info $chan] +akashowlog] != -1} {


          if {[set idx [lsearch -glob [utimers] "*aka::noop $safenick*"]] == -1} {
            putlog "$aka::logo ${aka::nicktextf}${nick} $aka::logo ${aka::nickstextf}[string map {" " "\,"} [hget "AKA" $hostmask]]"
            utimer $aka::dupsdelay "aka::noop $safenick"
          }
        }
        if {[lsearch -exact [channel info $chan] +akashowchan] != -1} {
          if {[set idx [lsearch -glob [utimers] "*aka::noop ${chan}${safenick}*"]] == -1} {
            putserv "PRIVMSG $chan :${aka::logo} ${aka::nicktextf}${nick} $aka::logo ${aka::nickstextf}[string map {" " "\,"} [hget "AKA" $hostmask]]"
            utimer $aka::dupsdelay "aka::noop ${chan}${safenick}"
          }
        }
      }
    } else {
      timer 1 "aka::joinadd $chan"
    }
  }
  proc hadd {hashname hashitem hashdata } {
    global $hashname
    set ${hashname}($hashitem) $hashdata
  }
  proc hget {hashname hashitem} {
    upvar #0 $hashname hgethashname
    if {[info exists hgethashname($hashitem)]} {
      return $hgethashname($hashitem)
    } else {
      return ""
    }
  }
  proc hfind {hashname search matchno {type "w"}} {
    upvar #0 $hashname hfindhashname
    set search "(?i)[string map {* ""} ${search}]"
    if {$type == "w"} {
      if {[array exists hfindhashname]} {
        if {$matchno == 0} {
          return [llength [array names hfindhashname -regexp $search]]
        } else {
          set matchno [expr $matchno - 1]
          return [lindex [array names hfindhashname -regexp $search] $matchno]
        }
      }
    } elseif {$type == "W"} {
      set count 0
      foreach {item value} [array get hfindhashname] {
        if {[string match -nocase $search $value] && ![string match -nocase "*akaindex*" $item]} {
          incr count
          if {$count == $matchno} { return $item }
        }
      }
      if {$matchno == 0} {
        return $count
      } else {
        return ""
      }
    }
  }
  proc hsave {hashname filename} {
    upvar #0 $hashname hsavehashname
    if {[array exists hsavehashname]} {
      set hsavefile [open $filename w]
      foreach {key value} [array get hsavehashname] {
        puts $hsavefile "${key}=${value}"
      }
      close $hsavefile
    }
  }
  proc hload {hashname filename} {
    upvar #0 $hashname hloadhashname
    hfree $hashname
    set hloadfile [open $filename]
    set linenum 0
    while {[gets $hloadfile line] >= 0} {
      if {[regexp -- {([^\s]+)=(.*)$} $line wholematch item data]} {
        set hloadhashname($item) $data
      }
    }
    close $hloadfile
  }
  proc hfree {hashname} {
    upvar #0 $hashname hfreehashname
    if {[array exists hfreehashname]} {
      foreach key [array names hfreehashname] {
        unset hfreehashname($key)
      }
    }
  }
  proc hdel {hashname hashitem} {
    upvar #0 $hashname hdelhashname
    if {[info exists hdelhashname($hashitem)]} {
      unset hdelhashname($hashitem)
    }
  }
  proc hcopy {hashfrom hashto} {
    upvar #0 $hashfrom hashfromlocal $hashto hashtolocal
    array set hashtolocal [array get hashfromlocal]
  } 
}
putlog "\002*Loaded* \002\00304\[\00307A\00304K\00307A\00304\]\017 \002by \
Ford_Lawnmower irc.GeekShed.net #Script-Help .rss for help"
