 ###############################################
#                                               #
#    P U B L I C   Q U O T E S   S Y S T E M    #
#      v1.32en (04/09/2008) by MenzAgitat       #
#                                               #
#        http://www.boulets-roxx.com            #
#        IRC:  irc.teepi.net    #boulets        #
#              irc.epiknet.org  #boulets        #
#                                               #
#-----------------------------------------------#
# Greetings to Galdinx for the help, and to all #
# other beta testers.                           #
#-----------------------------------------------#
# About the english translation, keep in mind I #
# am a french guy, so be tolerant.              #
# If english people would help me to correct    #
# language errors, I would be much grateful.    #
 ###############################################

#
# Description :
# This script adds following commands :
#     !addquote <quote> :
#        To add a quote.
#     !quote <quote number> [#chan] :
#        To display a quote.
#     !quoteinfo <quote number> [#chan] :
#        To display some informations about a given quote.
#     !delquote <quote number> :
#        To delete a quote.
#     !randquote [#chan] :
#        To display a random quote.
#     !lastquote [#chan] :
#        To display the last quote.
#     !findquote [-all/#chan] <search argument(s)> :
#        To look for a quote.
#        Put some quotation marks around your search arguments to look for an exact match.
#        Use the -all option to do a global search in every channel's databases
#        OR specify a chan.
#     !deletedquoteinfo <quote number> : To display some informations about a
#        deleted quote (admin command)
#     !undelquote <quote number> : To restore a deleted quote (admin command)
#     !forcedelquote <quote number> : To delete a quote, even if you are not
#        its author. (admin command)
#     !cancelquote <latest quote number> : To cancel cancel the latest recorded quote on
#        the current channel. (Removes it entirely, does not leave any remains)
#        (admin command)
#
# No need to say that !forcedelquote and !cancelquote commands must be used ethically,
# for maintenance operations or in order to face users misuse of the commands.
#
# A directory named quotes.db will be created in the eggdrop's directory.
# It contains quotes databases.
#

namespace eval pubqsys {

#######################
#      SETTINGS       #
#######################

	# Channels on which quotes will be active (each chan separated by a space).
	# example : {#chan1 #chan2 #chan3} or {#chan1}
	# beware, if the chan's name contains any } or {, you must replace it by
	# \} or \{. example : if your chan is #my{chan}, replace by #my\{chan\}.
  variable allowed_chans {##linux-it #provazze}


  #### PUBLIC COMMANDS AND AUTHORIZATIONS
   
  # Command used to display a quote
  # eg: "!quote"
  variable quotecmd "!quote"
  # authorizations for !quote
  variable quoteauth "-|-"
   
  # Command used to add a quote 
  # eg: "!addquote"
  variable addquotecmd "!addquote"
  # authorizations for !addquote
  variable addquoteauth "f|f"
   
  # Command used to display some informations about a quote
  # eg: "!quoteinfo"
  variable quoteinfocmd "!quoteinfo"
  # authorizations for !quoteinfo
  variable quoteinfoauth "-|-"
   
  # Command used to delete a quote
  # eg: "!delquote"
  variable delquotecmd "!delquote"
  # authorizations for !delquote
  variable delquoteauth "m|m"
   
  # Command used to display a random quote
  # eg: "!randquote"
  variable randquotecmd "!randquote"
  # authorizations for !randquote
  variable randquoteauth "-|-"
   
  # Command used to display the latest quote
  # eg: "!lastquote"
  variable lastquotecmd "!lastquote"
  # authorizations for !lastquote
  variable lastquoteauth "-|-"
   
  # Command used to search for a quote
  # eg: "!findquote"
  variable findquotecmd "!findquote"
  # authorizations for !findquote
  variable findquoteauth "-|-"


  #### ADMINISTRATOR COMMANDS AND AUTHORIZATIONS
   
  # Command used to display some detailed informations about a deleted quote
  # eg: "!deletedquoteinfo"
  variable deletedquoteinfocmd "!deletedquoteinfo"
  # authorizations for !deletedquoteinfo
  variable deletedquoteinfoauth "m|m"
   
  # Command used to restore a deleted quote
  # eg: "!undelquote"
  variable undelquotecmd "!undelquote"
  # authorizations for !undelquote
  variable undelquoteauth "m|m"
   
  # Command used to delete a quote (moderation)
  # eg: "!forcedelquote"
  variable forcedelquotecmd "!forcedelquote"
  # authorizations for !forcedelquote
  variable forcedelquoteauth "m|m"
   
  # Command used to cancel the latest stored quote
  # eg: "!cancelquote"
  variable cancelquotecmd "!cancelquote"
  # authorizations for !cancelquote
  variable cancelquoteauth "m|m"


  #### SEARCH PARAMETERS

  # Maximum number of recent quotes to display when using !findquote
  variable maxfindquote 2
  # Maximum number of results the !findquote command is allowed to handle.
  # For example, if you set the limit to 100 and a search returns more than 100
  # results, the user will be asked to give more specific search arguments, given
  # the too important number of results. Set to 0 for no limit.
  variable maxfindquotetotal 300


  #### FLOOD CONTROL
  
  # Antiflood (0 = off, 1 = on)
  variable antiflood 1
  # Individual antiflood control
  # "6:30" = maximum 6 commands per 30 seconds; following ones will be ignored.
  variable cmdflood_addquote "3:80"
  variable cmdflood_quote "5:80"
  variable cmdflood_quoteinfo "5:80"
  variable cmdflood_delquote "2:60"
  variable cmdflood_randquote "5:80"
  variable cmdflood_lastquote "2:60"
  variable cmdflood_findquote "3:80"
  # global antiflood control (all commands)
  # please note : for the maximum allowed number of commands, make sure the
  #               value is greater than the greatest value defined for
  #               the individual antiflood control settings.
  variable cmdflood_global "10:120"
  # Minimum time interval between 2 warning messages from the antiflood.
  # Do not set that value too low or you will be flooded by antiflood warnings ;)
  variable antiflood_msg_interval 20


  #### BACKUP PARAMETERS

  # Daily backup time.
  variable backuptime "02:50"



####################################################################
#                                                                  #
#   DO NOT MODIFY ANYTHING BELOW THIS BOX IF YOU DON'T KNOW TCL    #
#                                                                  #
####################################################################

  variable version "1.32.20080904en"
  variable floodsettingsstring [split "global $cmdflood_global addquote $cmdflood_addquote quote $cmdflood_quote quoteinfo $cmdflood_quoteinfo delquote $cmdflood_delquote randquote $cmdflood_randquote lastquote $cmdflood_lastquote findquote $cmdflood_findquote"]
  variable floodsettings ; array set floodsettings $floodsettingsstring
  variable instance ; array set instance {}
  variable antiflood_msg ; array set antiflood_msg {}
  variable backuptime [split $backuptime ":"]
  variable allowed_chans [split $allowed_chans]
  array unset quoteslist
  bind pub $pubqsys::quoteauth $pubqsys::quotecmd pubqsys::quote
  bind pub $pubqsys::addquoteauth $pubqsys::addquotecmd pubqsys::addquote
  bind pub $pubqsys::quoteinfoauth $pubqsys::quoteinfocmd pubqsys::quoteinfo
  bind pub $pubqsys::delquoteauth $pubqsys::delquotecmd pubqsys::delquote
  bind pub $pubqsys::randquoteauth $pubqsys::randquotecmd pubqsys::randquote
  bind pub $pubqsys::lastquoteauth $pubqsys::lastquotecmd pubqsys::lastquote
  bind pub $pubqsys::findquoteauth $pubqsys::findquotecmd pubqsys::findquote
  bind pub $pubqsys::deletedquoteinfoauth $pubqsys::deletedquoteinfocmd pubqsys::deletedquoteinfo
  bind pub $pubqsys::undelquoteauth $pubqsys::undelquotecmd pubqsys::undelquote
  bind pub $pubqsys::forcedelquoteauth $pubqsys::forcedelquotecmd pubqsys::forcedelquote
  bind pub $pubqsys::cancelquoteauth $pubqsys::cancelquotecmd pubqsys::cancelquote
  bind evnt - prerehash pubqsys::uninstall 
  bind time - "[lindex $pubqsys::backuptime 1] [lindex $pubqsys::backuptime 0] * * *" pubqsys::backup_db
  proc uninstall {args} {
		putlog "Désallocation des ressources de \002Public Quotes System...\002"
	  unbind pub $pubqsys::quoteauth $pubqsys::quotecmd pubqsys::quote
  	unbind pub $pubqsys::addquoteauth $pubqsys::addquotecmd pubqsys::addquote
  	unbind pub $pubqsys::quoteinfoauth $pubqsys::quoteinfocmd pubqsys::quoteinfo
  	unbind pub $pubqsys::delquoteauth $pubqsys::delquotecmd pubqsys::delquote
  	unbind pub $pubqsys::randquoteauth $pubqsys::randquotecmd pubqsys::randquote
  	unbind pub $pubqsys::lastquoteauth $pubqsys::lastquotecmd pubqsys::lastquote
  	unbind pub $pubqsys::findquoteauth $pubqsys::findquotecmd pubqsys::findquote
  	unbind pub $pubqsys::deletedquoteinfoauth $pubqsys::deletedquoteinfocmd pubqsys::deletedquoteinfo
  	unbind pub $pubqsys::undelquoteauth $pubqsys::undelquotecmd pubqsys::undelquote
  	unbind pub $pubqsys::forcedelquoteauth $pubqsys::forcedelquotecmd pubqsys::forcedelquote
  	unbind pub $pubqsys::cancelquoteauth $pubqsys::cancelquotecmd pubqsys::cancelquote
    unbind evnt - prerehash pubqsys::uninstall 
    unbind time - "[lindex $pubqsys::backuptime 1] [lindex $pubqsys::backuptime 0] * * *" pubqsys::backup_db
    namespace delete ::pubqsys
  }
}

proc pubqsys::quote {nick host hand chan arg} {
  variable quoteslist
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {($pubqsys::antiflood == 1) && (([pubqsys::antiflood $chan "global"] == "flood") || ([pubqsys::antiflood $chan "quote"] == "flood"))} {
    return
  } elseif {([regexp {^[0-9]+$} $arg] == 0) && ([string first # [join [lindex $arg 1]]] != 0)} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!quote[code bold $chan] [code 14 $chan]<[code endcolor $chan]quote number[code 14 $chan]> \[[code endcolor $chan]#chan[code 14 $chan]\][code endcolor $chan]"
    return
  } elseif {([string first # [join [lindex $arg 1]]] == 0) && ([pubqsys::channel_check [lindex $arg 1]] == 0)} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quotes are not enabled on [join [lindex $arg 1]]."
    return
  } else {
    if {[lindex $arg 1] == ""} {
      set channame [string replace $chan 0 0]
      set quotenumber [string trimleft $arg "0"]
    } else {
      set channame [string replace [join [lindex $arg 1]] 0 0]
      set quotenumber [string trimleft [join [lindex $arg 0]] "0"]
    }
    if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
      if { [pubqsys::read_quotes $chan $channame "quote"] == "missing" } { return }
    }
    set numquotes [llength $quoteslist($channame)]
    if { $quotenumber > $numquotes } {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber does not exist yet. ($numquotes quotes in the database)."
      return
    }   
    set quote [split [lindex $quoteslist($channame) [expr $quotenumber - 1]]]
  }
  if {[set index1 [lindex $quote 0]] == $quotenumber} {
    puthelp "PRIVMSG $chan :\[[code bold $chan][code underline $chan]$quotenumber[code underline $chan][code bold $chan]\] [filtercodes [join [lrange $quote 5 end]] $chan]"
  } elseif {$index1 == "-deleted-"} {
    if {[string match *(admin)* [set whodel [join [split [lindex $quote 1]]]]] == 1} { set whodel "an administrator" }
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber has been deleted on [lindex $quote 2] at [lindex $quote 3] by $whodel on [join [split [lindex $quote 4]]]."
  } else {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Database incoherence."
  }
  return
}

proc pubqsys::addquote {nick host hand chan arg} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {($pubqsys::antiflood == 1) && (([pubqsys::antiflood $chan "global"] == "flood") || ([pubqsys::antiflood $chan "addquote"] == "flood"))} {
    return
  } elseif {$arg == ""} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!addquote[code bold $chan] [code 14 $chan]<[code endcolor $chan]quote[code 14 $chan]>[code endcolor $chan]"
  } elseif {([string length $arg] < 10) || ([llength [split $arg]] < 3)} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : You can't store quotes shorter than 10 characters and 3 words."
  } else {
    set channame [string replace $chan 0 0]
    variable quoteslist
    if { (![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} { pubqsys::read_quotes $chan $channame "addquote" }
    set numquotes [llength $quoteslist($channame)]
    set quote "[expr $numquotes + 1] [strftime %m/%d/%Y [unixtime]] [strftime %H:%M:%S [unixtime]] $chan $nick $arg"
    lappend quoteslist($channame) $quote
    pubqsys::write_quotes $channame
    puthelp "PRIVMSG $chan :Quote #[expr $numquotes + 1] has been added."
  }
  return
}

proc pubqsys::quoteinfo {nick host hand chan arg} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {($pubqsys::antiflood == 1) && (([pubqsys::antiflood $chan "global"] == "flood") || ([pubqsys::antiflood $chan "quoteinfo"] == "flood"))} {
    return
  } elseif {([regexp {^[0-9]+$} $arg] == 0) && ([string first # [join [lindex $arg 1]]] != 0)} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!quoteinfo[code bold $chan] [code 14 $chan]<[code endcolor $chan]quote number[code 14 $chan]> \[[code endcolor $chan]#chan[code 14 $chan]\][code endcolor $chan]"
    return
  } elseif {([string first # [join [lindex $arg 1]]] == 0) && ([pubqsys::channel_check [lindex $arg 1]] == 0)} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quotes are not enabled on [join [lindex $arg 1]]."
    return
  } else {
    if {[lindex $arg 1] == ""} {
      set channame [string replace $chan 0 0]
      set quotenumber [string trimleft $arg "0"]
    } else {
      set channame [string replace [join [lindex $arg 1]] 0 0]
      set quotenumber [string trimleft [join [lindex $arg 0]] "0"]
    }
    variable quoteslist
    if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
      if { [pubqsys::read_quotes $chan $channame "quoteinfo"] == "missing" } { return }
    }
    set numquotes [llength $quoteslist($channame)]
    if { $quotenumber > $numquotes } {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber does not exist yet. ($numquotes quotes in the database)."
      return
    }   
    set quote [split [lindex $quoteslist($channame) [expr $quotenumber - 1]]]
  }
  if {[set index1 [lindex $quote 0]] == $quotenumber} {
    puthelp "PRIVMSG $chan :The quote #$quotenumber has been stored on [join [split [lindex $quote 3]]] on [lindex $quote 1] at [lindex $quote 2] by [join [split [lindex $quote 4]]]."
  } elseif {$index1 == "-deleted-"} {
    if {[string match *(admin)* [set whodel [join [split [lindex $quote 1]]]]] == 1} { set whodel "un administrateur" }
    puthelp "PRIVMSG $chan :The quote #$quotenumber has been deleted on [lindex $quote 2] at [lindex $quote 3] by $whodel on [join [split [lindex $quote 4]]]."
  } else {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Database incoherence."
  }
  return
}

proc pubqsys::delquote {nick host hand chan arg} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {($pubqsys::antiflood == 1) && (([pubqsys::antiflood $chan "global"] == "flood") || ([pubqsys::antiflood $chan "delquote"] == "flood"))} {
    return
  } elseif {[regexp {^[0-9]+$} $arg] == 0} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!delquote[code bold $chan] [code 14 $chan]<[code endcolor $chan]quote number[code 14 $chan]>[code endcolor $chan]  (you must be the quote's author)"
    return
  } else {
    set channame [string replace $chan 0 0]
    set quotenumber [string trimleft $arg "0"]
    variable quoteslist
    if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
      if { [pubqsys::read_quotes $chan $channame "delquote"] == "missing" } { return }
    }
    set numquotes [llength $quoteslist($channame)]
    if { $quotenumber > $numquotes } {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber does not exist yet. ($numquotes quotes in the database)."
      return
    }   
    set quote [lindex $quoteslist($channame) [expr $quotenumber - 1]]
  }
  if {[set index1 [lindex [split $quote] 0]] == $quotenumber} {
    if {[set author [join [lindex [split $quote] 4]]] != $nick} {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : You are not allowed to delete that quote. Its author is [code bold $chan]$author[code bold $chan]."
      return
    }
    set deletedquote "-deleted- $nick [strftime %m/%d/%Y [unixtime]] [strftime %H:%M:%S [unixtime]] $chan -------- $nick!$host have deleted : $quote"
    set quoteslist($channame) [lreplace $quoteslist($channame) [set index2 [expr $quotenumber - 1]] $index2 $deletedquote]
    pubqsys::write_quotes $channame
    puthelp "PRIVMSG $chan :Deleted quote #$quotenumber."
  } elseif {$index1 == "-deleted-"} {
    if {[string match *(admin)* [set whodel [join [split [lindex $quote 1]]]]] == 1} { set whodel "un administrateur" }
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber has already been deleted on [lindex $quote 2] at [lindex $quote 3] by $whodel on [join [split [lindex $quote 4]]]."
  } else {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Database incoherence."
  }
  return
}

proc pubqsys::randquote {nick host hand chan arg} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {($pubqsys::antiflood == 1) && (([pubqsys::antiflood $chan "global"] == "flood") || ([pubqsys::antiflood $chan "randquote"] == "flood"))} {
    return
  } elseif {($arg != "") && (([string first # [join $arg]] != 0) || ([llength $arg] > 1))} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!randquote[code bold $chan] [code 14 $chan]\[[code endcolor $chan]#chan[code 14 $chan]\][code endcolor $chan]"
  } elseif {($arg != "") && ([string first # [join $arg]] == 0) && ([pubqsys::channel_check [join $arg]] == 0)} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quotes are not enabled on [join $arg]."
    return
  } else {
    if {[lindex $arg 0] == ""} {
      set channame [string replace $chan 0 0]
    } else {
      set channame [string replace [join [lindex $arg 0]] 0 0]
    }
    variable quoteslist
    if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
      if { [pubqsys::read_quotes $chan $channame "randquote"] == "missing" } { return }
    }
    set existingquotes [lsearch -all -inline -regexp $pubqsys::quoteslist($channame) {^(?!-deleted-(.*))}]
    set numquotes [llength $existingquotes]
    if {$numquotes == 0} {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : No valid quote has been found."
      return
    }
    set quote [split [lindex $existingquotes [rand $numquotes]]]
    puthelp "PRIVMSG $chan :\[[code bold $chan][code underline $chan][lindex $quote 0][code underline $chan][code bold $chan]\] [filtercodes [join [lrange $quote 5 end]] $chan]"
    return    
  }
}

proc pubqsys::lastquote {nick host hand chan arg} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {($pubqsys::antiflood == 1) && (([pubqsys::antiflood $chan "global"] == "flood") || ([pubqsys::antiflood $chan "lastquote"] == "flood"))} {
    return
  } elseif {($arg != "") && (([string first # [join $arg]] != 0) || ([llength $arg] > 1))} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!lastquote[code bold $chan] [code 14 $chan]\[[code endcolor $chan]#chan[code 14 $chan]\][code endcolor $chan]"
  } elseif {($arg != "") && ([string first # [join $arg]] == 0) && ([pubqsys::channel_check [join $arg]] == 0)} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quotes are not enabled on [join $arg]."
    return
  } else {
    if {[lindex $arg 0] == ""} {
      set channame [string replace $chan 0 0]
    } else {
      set channame [string replace [join [lindex $arg 0]] 0 0]
    }
    variable quoteslist
    if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
      if { [pubqsys::read_quotes $chan $channame "lastquote"] == "missing" } { return }
    }
    set existingquotes [lsearch -all -inline -regexp $pubqsys::quoteslist($channame) {^(?!-deleted-(.*))}]
    set numexistingquotes [llength $existingquotes]
    set numquotes [llength $quoteslist($channame)]
    set lastrawquote [split [lindex $quoteslist($channame) [expr $numquotes - 1]]]
    if {$numquotes == 0} {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : No valid quote has been found."
      return
    }
    if {[lindex $lastrawquote 0] == "-deleted-"} {
      if {[string match *(admin)* [set whodel [join [split [lindex $lastrawquote 1]]]]] == 1} { set whodel "un administrateur" }
      puthelp "PRIVMSG $chan :[code 14 $chan]The last quote (#$numquotes) does not exist, it has been deleted on [lindex $lastrawquote 2] at [lindex $lastrawquote 3] by $whodel on [join [split [lindex $lastrawquote 4]]]. Looking for the last valid quote...[code endcolor $chan]"
    }
    set quote [split [lindex $existingquotes [expr $numexistingquotes - 1]]]
    puthelp "PRIVMSG $chan :\[[code bold $chan][code underline $chan][lindex $quote 0][code underline $chan][code bold $chan]\] [filtercodes [join [lrange $quote 5 end]] $chan]"
    return    
  }
}

proc pubqsys::findquote {nick host hand chan {arg}} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {($pubqsys::antiflood == 1) && (([pubqsys::antiflood $chan "global"] == "flood") || ([pubqsys::antiflood $chan "findquote"] == "flood"))} {
    return
  } elseif {[pubqsys::isargclean $chan $arg] == "dirty"} {
    return
  } elseif {($arg == "") || (([lindex $arg 0] == "-all") && ([lindex $arg 1] == ""))} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!findquote[code bold $chan] [code 14 $chan]\[[code endcolor $chan]-all[code 14 $chan]/[code endcolor $chan]#chan[code 14 $chan]\] <[code endcolor $chan]search arguments[code 14 $chan]>  [code 07 $chan]|[code endcolor $chan] Use quotation marks to search for exact match. [code underline $chan]Examples[code underline $chan] : [code bold $chan]!findquote a test[code bold $chan] (finds quotes containing the letter [code bold $chan]a[code bold $chan] [code underline $chan]and[code underline $chan] the word [code bold $chan]test[code bold $chan]).  [code bold $chan]!findquote \"a test\"[code bold $chan] (finds quotes containing the exact match \"[code bold $chan]a test[code bold $chan]\").[code endcolor $chan]"
    return
  } elseif {([string first # [join $arg]] == 0) && ([lindex $arg 1] != "") && ([pubqsys::channel_check [join [lindex $arg 0]]] == 0)} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quotes are not enabled on [join [lindex $arg 0]]."
    return
  } elseif {([string length [join $arg]] < 3) || ((([string first # [join $arg]] == 0) || ([lindex $arg 0] == "-all")) && ([lindex $arg 1] != "") && ([string length [join [lrange $arg 1 end]]] < 3))} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Your search argument must be at least 3 characters long."
    return
  } else {
    if {([string first # [join $arg]] == 0) && ([lindex $arg 1] != "")} {
      set channame [string replace [join [lindex $arg 0]] 0 0]
      set searcharguments [pubqsys::cleanarg [join [lrange $arg 1 end]]]
    } elseif {[lindex $arg 0] == "-all"} {
      if {[llength $pubqsys::allowed_chans] == 1} {
        puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Note[code underline $chan] : Using -all is superfluous since the quotes are enabled on only one channel."
        set channame [string replace $chan 0 0]
      } else {
        set channame "-all"
      }
      set searcharguments [pubqsys::cleanarg [join [lrange $arg 1 end]]]
    } else {
      set channame [string replace $chan 0 0]
      set searcharguments [pubqsys::cleanarg $arg]
    }
    variable quoteslist
    if {$channame != "-all"} {
      if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
        if { [pubqsys::read_quotes $chan $channame "findquote"] == "missing" } { return }
      }
    } else {
      set quoteslist(-all) ""
      foreach channameall $pubqsys::allowed_chans {
        set channameall [string replace $channameall 0 0]
        if {[file exists "quotes.db/quotes.$channameall"]} {
          variable quotesfile [open "quotes.db/quotes.$channameall" r]
          set quoteslist(-all) "$quoteslist(-all) [split [read -nonewline $quotesfile] \n]"
          close $quotesfile
        }
      }
      if {$quoteslist(-all) == ""} {
        puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Database not found."
        return
      }
    }
    set filter_quotes $quoteslist($channame)
    foreach element $searcharguments {
      set filter_quotes [lsearch -all -inline -regexp $filter_quotes "(?i)^\[0-9\]+ \[^\ \]+ \[^\ \]+ \[^\ \]+ \[^\ \]+ .*($element).*$"]
    }
    set numresults [llength $filter_quotes]
    if {$numresults == 0} {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] Your search returned no results."
      return
    } elseif {$numresults == "1"} {
      if {$channame != "-all"} {
        puthelp "PRIVMSG $chan :[code underline $chan]$numresults results have been found[code underline $chan] :"
      } else {
        puthelp "PRIVMSG $chan :[code underline $chan]$numresults result has been found on [lindex [split [join $filter_quotes]] 3][code underline $chan] :"
      }
    } elseif {($numresults > $pubqsys::maxfindquotetotal) && ($pubqsys::maxfindquotetotal != 0)} {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] Your search returned more than $pubqsys::maxfindquotetotal results ($numresults to be exact). Try to use more specific search arguments in order to lower the number of results."
      return
    } else {
      if {$channame != "-all"} {
        set foundquotenumbers "[code underline $chan]$numresults results have been found[code underline $chan] : "
        foreach element $filter_quotes {
          set foundquotenumbers "$foundquotenumbers[code bold $chan][code bold $chan][lindex [split $element] 0][code 14 $chan]|[code endcolor $chan]"
          if {[string length [join $foundquotenumbers]] >= 440} {
            puthelp "PRIVMSG $chan :$foundquotenumbers"
            set foundquotenumbers ""
          }
        }
        if {$foundquotenumbers != ""} {
          puthelp "PRIVMSG $chan :$foundquotenumbers"
        }
      } else {
        set resultchanlist ""
        set chronolist ""
        foreach element $filter_quotes {
          set element [split $element]
          set resultchanlist "$resultchanlist [lindex $element 3]"
          lappend chronolist "[lindex [set date [split [lindex $element 1] "/"]] 2][lindex $date 0][lindex $date 1][join [split [lindex $element 2] ":"] ""] [lindex $element 0] [join [lrange $element 3 end]]"
          set chronolist [lsort $chronolist]
        }
        set resultchanlist [join [lsort -unique $resultchanlist]]
        puthelp "PRIVMSG $chan :[code underline $chan]$numresults results have been found on the following channels[code underline $chan]: $resultchanlist"
        puthelp "PRIVMSG $chan :[code underline $chan]Recent quotes[code underline $chan]:"
        for { set counter 0 } { ($counter < $pubqsys::maxfindquote) && ($counter < $numresults) } { incr counter } {
          set quote [split [lindex $chronolist [expr $numresults - ($counter + 1)]]]
          puthelp "PRIVMSG $chan :[code 14 $chan][join [lindex $quote 2]][code endcolor $chan] \[[code bold $chan][code underline $chan][lindex $quote 1][code underline $chan][code bold $chan]\] [filtercodes [join [lreplace $quote 0 3]] $chan]"
        }
        return
      }
      puthelp "PRIVMSG $chan :[code underline $chan]Recent quotes[code underline $chan]:"
    }
    for { set counter 0 } { ($counter < $pubqsys::maxfindquote) && ($counter < $numresults) } { incr counter } {
      set quote [split [lindex $filter_quotes [expr $numresults - ($counter + 1)]]]
      puthelp "PRIVMSG $chan :\[[code bold $chan][code underline $chan][lindex $quote 0][code underline $chan][code bold $chan]\] [filtercodes [join [lreplace $quote 0 4]] $chan]"
    }
    return
  }
}

proc pubqsys::deletedquoteinfo {nick host hand chan arg} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {[regexp {^[0-9]+$} $arg] == 0} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!deletedquoteinfo[code bold $chan] [code 14 $chan]<[code endcolor $chan]quote number[code 14 $chan]>[code endcolor $chan]"
    return
  } else {
    set channame [string replace $chan 0 0]
    set quotenumber [string trimleft $arg "0"]
    variable quoteslist
    if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
      if { [pubqsys::read_quotes $chan $channame "deletedquoteinfo"] == "missing" } { return }
    }
    set numquotes [llength $quoteslist($channame)]
    if { $quotenumber > $numquotes } {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber does not exist yet. ($numquotes quotes in the database)."
      return
    }   
    set quote [split [lindex $quoteslist($channame) [expr $quotenumber - 1]]]
  }
  if {[set index1 [lindex $quote 0]] == $quotenumber} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber does exist, there is no information about its deleted state."
  } elseif {$index1 == "-deleted-"} {
    if {[lindex $quote 6] == ""} {
      puthelp "PRIVMSG $chan :Informations about that quote are unavailable."
    } else {
      puthelp "NOTICE $nick :The quote #$quotenumber has been deleted on [lindex $quote 2] at [lindex $quote 3] by [join [split [lindex $quote 1]]] ([join [split [lindex $quote 6]]]) on [join [split [lindex $quote 4]]]. That quote was added by [join [split [lindex $quote 14]]] on [join [split [lindex $quote 13]]] on [lindex $quote 11] at [lindex $quote 12]. Here is the quote:"
      puthelp "NOTICE $nick :\[[code bold $chan][code underline $chan][lindex $quote 10][code underline $chan][code bold $chan]\] [filtercodes [join [lrange $quote 15 end]] $chan]"
    }
  } else {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Database incoherence."
  }
  return
}

proc pubqsys::undelquote {nick host hand chan arg} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {[regexp {^[0-9]+$} $arg] == 0} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!undelquote[code bold $chan] [code 14 $chan]<[code endcolor $chan]quote number[code 14 $chan]>[code endcolor $chan]"
    return
  } else {
    set channame [string replace $chan 0 0]
    set quotenumber [string trimleft $arg "0"]
    variable quoteslist
    if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
      if { [pubqsys::read_quotes $chan $channame "undelquote"] == "missing" } { return }
    }
    set numquotes [llength $quoteslist($channame)]
    if { $quotenumber > $numquotes } {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber does not exist yet. ($numquotes quotes in the database)."
      return
    }   
    set quote [lindex $quoteslist($channame) [expr $quotenumber - 1]]
  }
  if {[set index1 [lindex [split $quote] 0]] == $quotenumber} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber does exist, there is no need to restore it."
  } elseif {$index1 == "-deleted-"} {
    set restoredquote [join [lrange [split $quote] 10 end]]
    set quoteslist($channame) [lreplace $quoteslist($channame) [set index2 [expr $quotenumber - 1]] $index2 $restoredquote]
    pubqsys::write_quotes $channame
    puthelp "PRIVMSG $chan :Quote #$quotenumber has been restored."
  } else {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Database incoherence."
  }
  return
}

proc pubqsys::forcedelquote {nick host hand chan arg} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {[regexp {^[0-9]+$} $arg] == 0} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The syntax is [code bold $chan]!forcedelquote[code bold $chan] [code 14 $chan]<[code endcolor $chan]quote number[code 14 $chan]>[code endcolor $chan]"
    return
  } else {
    set channame [string replace $chan 0 0]
    set quotenumber [string trimleft $arg "0"]
    variable quoteslist
    if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
      if { [pubqsys::read_quotes $chan $channame "forcedelquote"] == "missing" } { return }
    }
    set numquotes [llength $quoteslist($channame)]
    if { $quotenumber > $numquotes } {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber does not exist yet. ($numquotes quotes in the database)."
      return
    }   
    set quote [split [lindex $quoteslist($channame) [expr $quotenumber - 1]]]
  }
  if {[set index1 [lindex $quote 0]] == $quotenumber} {
    set deletedquote "-deleted- $nick[code 04 $chan]\(admin\)[code endcolor $chan] [strftime %m/%d/%Y [unixtime]] [strftime %H:%M:%S [unixtime]] $chan -------- $nick!$host have deleted : $quote"
    set quoteslist($channame) [lreplace $quoteslist($channame) [set index2 [expr $quotenumber - 1]] $index2 $deletedquote]
    pubqsys::write_quotes $channame
    puthelp "PRIVMSG $chan :Deleted quote #$quotenumber."
  } elseif {$index1 == "-deleted-"} {
    if {[string match *(admin)* [set whodel [join [split [lindex $quote 1]]]]] == 1} { set whodel "an administrator" }
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote #$quotenumber has already been deleted on [lindex $quote 2] at [lindex $quote 3] by $whodel on [join [split [lindex $quote 4]]]."
  } else {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Database incoherence."
  }
  return
}

proc pubqsys::cancelquote {nick host hand chan arg} {
  if {[pubqsys::channel_check $chan] == 0} {
    return
  } elseif {[regexp {^[0-9]+$} $arg] == 0} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Erreur[code underline $chan] : The syntax is [code bold $chan]!cancelquote[code bold $chan] [code 14 $chan]<[code endcolor $chan]latest quote number[code 14 $chan]>[code endcolor $chan]"
    return
  } else {
    set channame [string replace $chan 0 0]
    variable quoteslist
    if {(![info exists quoteslist($channame)]) || ($quoteslist($channame) == "")} {
      if { [pubqsys::read_quotes $chan $channame "cancelquote"] == "missing" } { return }
    }
    set numquotes [llength $quoteslist($channame)]
    if { $arg != $numquotes } {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : The quote number you just typed does not correspond to the latest quote number. In order tu reduce the risks of accidental deletion, you must specify the latest quote number."
      return  
    }
    set quote [split [lindex $quoteslist($channame) [expr $numquotes - 1]]]
  }
  if {([lindex $quote 0] == $numquotes) || (([lindex $quote 0] == "-deleted-") && ([lindex $quote 10] == $numquotes))} {
    set quoteslist($channame) [lreplace $quoteslist($channame) [set index2 [expr $numquotes - 1]] $index2]
    pubqsys::write_quotes $channame
    puthelp "PRIVMSG $chan :The latest stored quote has been cancelled."
    puthelp "PRIVMSG $chan :[code 14 $chan]\[[code bold $chan][code underline $chan]$numquotes[code underline $chan][code bold $chan]\] [filtercodes [join [lrange $quote 5 end]] $chan][code endcolor $chan]"
  } else {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Database incoherence."
  }
  return
}

proc pubqsys::read_quotes {chan channame command} {
  variable quoteslist
  if {(![file exists "quotes.db/quotes.$channame"]) && ($command != "addquote") && ($command != "findquoteall")} {
    if {[file exists "quotes.db/quotes.$channame.bak"]} {
      file copy "quotes.db/quotes.$channame.bak" "quotes.db/quotes.$channame"
      puthelp "PRIVMSG $chan :[code 04 $chan]::: [code underline $chan]Critical error[code underline $chan][code endcolor $chan] : The database for #$channame can't be found. A recent backup has been found and automatically restored."
      putlog "[code 04 $chan]\[Public Quotes System] [code underline $chan]Critical error[code underline $chan][code endcolor $chan] : The database for #$channame can't be found. A recent backup has been found and automatically restored."
    } else {
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : No database found for #$channame."
      return "missing"
    }
  }
  if {[file exists "quotes.db/quotes.$channame"] != 0} {
    set quotesfile [open "quotes.db/quotes.$channame" r]
    set quoteslist($channame) [split [read -nonewline $quotesfile] \n]
    close $quotesfile
    if {([llength $quoteslist($channame)] == 0) && ($command != "addquote") && ($command != "findquoteall")} { 
      puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : Empty database."
      return "missing"
    }
  } else {
    set quoteslist($channame) ""
  }
  return
}

proc pubqsys::write_quotes {channame} {
  variable quoteslist
  if {![file exists "quotes.db"]} { file mkdir "quotes.db" }
  set quotesfile [open "quotes.db/quotes.$channame" w]
  puts $quotesfile [join $quoteslist($channame) \n]
  close $quotesfile
  return
}

proc pubqsys::cleanarg {data} {
  regsub -all {\?} $data {\\\?} data
  regsub -all {\*} $data {\\\*} data
  regsub -all {\[} $data {\\\[} data
  regsub -all {\]} $data {\\\]} data
  regsub -all {\$} $data {\\\$} data
  regsub -all {\|} $data {\\\|} data
  return $data
}

proc pubqsys::isargclean {chan data} {
  if {[regexp {[\{\}\\]} $data] != 0} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Erreur[code underline $chan] : Vous ne pouvez pas utiliser les caractères suivants dans les arguments de recherche de la commande !findquote : [code bold $chan]\{ \} \\[code bold $chan]"
    return "dirty"
  } elseif {[expr ([set is_even [regsub -all {\"} $data "" isargcleantmp]] / 2) * 2] != $is_even} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : You use an odd number of quotation marks in your search arguments. The quotation marks allows you to search for an exact match and must be used by pairs. [code underline $chan]Example[code underline $chan] : [code bold $chan]!findquote \"a test\"[code bold $chan]"
    return "dirty"
  } elseif {[regexp {""} $data] != 0} {
    puthelp "PRIVMSG $chan :[code 04 $chan]:::[code endcolor $chan] [code underline $chan]Error[code underline $chan] : You used [code bold $chan]\"\"[code bold $chan] in your search arguments; it means an empty exact match search and the command !findquote [code bold $chan]!findquote[code bold $chan] does not allow it. You must add some text between quotation marks. [code underline $chan]Example[code underline $chan] : [code bold $chan]!findquote \"a test\"[code bold $chan]"
    return "dirty"
  } else {
    return "clean"
  }
}

proc pubqsys::channel_check {chan} {
  if {[lsearch -exact $pubqsys::allowed_chans $chan] != -1} { return 1 } { return 0 }
}

proc pubqsys::antiflood {chan type} {
  variable antiflood_msg
  if {![info exists antiflood_msg($chan$type)]} { set antiflood_msg($chan$type) 0 }
  variable instance
  if {![info exists instance($chan$type)]} { set instance($chan$type) 0 }
  set max_instances [lindex [split $pubqsys::floodsettings($type) ":"] 0]
  set instance_length [lindex [split $pubqsys::floodsettings($type) ":"] 1]
  if { $instance($chan$type) >= $max_instances } {
    if { $antiflood_msg($chan$type) == 0 } {
      set antiflood_msg($chan$type) 1
      if {$type != "global"} {
        putquick "privmsg $chan :[code 04 $chan]:::[code 14 $chan] Flood detected on [code bold $chan]!$type[code bold $chan] : maximum $max_instances requests per $instance_length seconds.[code endcolor $chan]"
      } else {
        putquick "privmsg $chan :[code 04 $chan]:::[code 14 $chan] Flood detected on quotes system : maximum $max_instances commands per $instance_length seconds.[code endcolor $chan]"
      }
      utimer $pubqsys::antiflood_msg_interval "pubqsys::antiflood_msg_reset [split $chan] $type"
    }
    return "flood"
  } else {
    incr instance($chan$type)
    utimer $instance_length "pubqsys::antiflood_close_instance [split $chan] $type"
    return "no flood"
  }
}
proc pubqsys::antiflood_close_instance {chan type} {
  variable instance
  if { $instance([set chan [join $chan]]$type) > 0 } { incr instance($chan$type) -1 }
}
proc pubqsys::antiflood_msg_reset {chan type} {
  variable antiflood_msg
  set antiflood_msg([join $chan]$type) 0
}

proc pubqsys::backup_db {min hour day month year} {
  putlog "\00314\[Public Quotes System\]\003 Backing up databases..."
  foreach channame $pubqsys::allowed_chans {
    set channame [string replace $channame 0 0]
    file copy -force "quotes.db/quotes.$channame" "quotes.db/quotes.$channame.bak"
  }
}

proc pubqsys::code {code chan} {
  if {$code == "bold"} {
    if {![string match *c* [lindex [split [getchanmode $chan]] 0]]} { return "\002" } { return "" }
  } elseif {$code == "underline"} {
    if {![string match *c* [lindex [split [getchanmode $chan]] 0]]} { return "\037" } { return "" }
  } elseif {$code == "endcolor"} {
    if {![string match *c* [lindex [split [getchanmode $chan]] 0]]} { return "\003" } { return "" }
  } else {
    if {![string match *c* [lindex [split [getchanmode $chan]] 0]]} { return "\003$code" } { return "" }
  }
}

proc pubqsys::filtercodes {data chan} {
  if {[string match *c* [lindex [split [getchanmode $chan]] 0]]} {
    regsub -all -- {\003[0-9]{0,2}(,[0-9]{0,2})?|\017|\037|\002|\026|\006|\007} $data "" data 
  }
  return $data
}


putlog "Public Quotes System has been loaded"
