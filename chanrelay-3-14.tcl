# chanrelay.tcl 3.14
#
# A way to link your channels
#
# Author: CrazyCat <crazycat@c-p-f.org>
# http://www.eggdrop.fr
# irc.zeolia.net #eggdrop
#
# Declare issues at https://gitlab.com/tcl-scripts/chanrelay
# No issue means no bug :)
#
## DESCRIPTION ##
#
# This TCL is a complete relay script wich works with botnet.
# All you have to do is to include this tcl in all the eggdrop who
# are concerned by it.
#
# You can use it as a spy or a full duplex communication tool.
#
# It don't mind if the eggdrops are on the same server or not,
# it just mind about the channels and the handle of each eggdrop.

## CHANGELOG ##
#
# 3.14 - The Pi edition :)
# Now possible to change the (user@network) displayed
#   just add the usermask correct value in settings
#   %nick% and %network% are dynamic variables
#   Think to escape chars as [] or {}
#
# 3.13
# Modified join/part/quit procs
# Add a limit to message length
#
# 3.12
# Added colors for actions and non-message
#
#
# 3.11
# Made the "oper" setting functionnal
# Removed MDS support
#
# 3.10
# Added debug log. It can be enable and disable in configuration
# and with /msg rc.debug <on|off>
#
# 3.9
# Added exclusion list to ignore some users
# Added a way to restrict relay to an internal user list
#
# 3.81
# Action mades by server are no more using nick "*"
# Added a protection on oper actions:
#   the action must come from the oper bot
# Correction of the quit transmission: when the bot leaves,
#   it now detect and transmit
# Added botnet status broadcast
# Changed the unload system (thanks to MenzAgitat)
#
# 3.8
# Correction : the config file can now use username for naming,
#   allowing to have relaying eggdrops in the same place with
#   different settings
#
# 3.7
# Addition of @commandes (public) restricted to operators:
#   @topic <network|all> a new topic :
#       Changes topic on specified network (or all)
#   @mode <network|all> +mode [arg][,-mode [arg]] :
#       Changes modes on specified network (or all)
#       All modes must be separated with a comma
#   @kick <network|all> user [reason] :
#       Kicks user on specified network (or all)
#   @ban <network|all> user [reason]:
#       Ban-kick user on specified network (or all)
#   Default reason and banmask are in the conf section
#
# 3.6-3
# Correction of trans mode on/off
#
# 3.6-2
# Correction of the logging of actions (/me)
#   Nick was replaced with ACTION
# Correction of empty chan list (!who)
# 
# 3.6-1
# Correction of the !who command
# It's now possible to have the list from a specific server
#
# 3.6
# Correction of modes catching / transmitting
#
# 3.5 (Beta)
# Integration of Message Delivery Service (MDS)
# by MenzAgitat
#
# 3.4
# Settings modified by msg commands are now saved
# Correction of small bugs
# Best verification of settings sent
# Acknowledgement and error messages added
#
# 3.3-1
# Correction for /msg eggdrop trans <action> [on|off]
#
# 3.3
# Added lines introducing beginning and ending of userlist
#
# 3.2
# Added gray user highlight
#
# 3.1
# Added check for linked bot
# Corrected parse of some messages
# Corrected pub commands
#
# 3.0
# Complete modification of configuration
# Use of namespace
# No more broadcast, the relay is done with putbot

## TODO ##
#
# Enhance configuration
# Allow save of configuration
# Multi-languages

## CONFIGURATION ##
#
# For each eggdrop in the relay, you have to
# indicate his botnet nick, the chan and the network.
#
# Syntax:
# set regg(USERNAME) {
#   "chan"      "#CHANNEL"
#   "network"   "NETWORK"
#}
# with:
# USERNAME : The username sets in eggdrop.conf (case-sensitive)
# optionaly, you can override default values:
# * highlight (0/1/2/3): is speaker highlighted ? (no/bold/undelined/gray)
# * snet (y/n): is speaker'network shown ?
# * transmit (y/n): does eggdrop transmit his channel activity ?
# * receive (y/n): does eggdrop diffuse other channels activity ?
# * oper (y/n): does the eggdrop accept @ commands (topic, kick, ban) ?
# * syn_topic (y/n): if set to Yes, the eggdrop will
#   synchronize the channel topic when changed on
#   another chan of the relay
#
# userlist(beg) is the sentence announcing the start of !who
# userlist(end) is the sentence announcing the end of !who

namespace eval crelay {

	# debug mode : set to 1 to enable
	set debug 0
	
	variable regg
	variable default
	variable userlist

	set regg(Provolo) {
		"chan"      "#provazze"
		"network"   "libera"
		"transmit"  "n"
		"receive"   "y"
	}

	set regg(ABC-XYZ) {
		"chan"      "#piemonte"
		"network"   "Simosnap"
		"transmit"  "y"
		"receive"   "n"
	}

#	set regg(CC_Egg) {
#		"chan"      "#eggdrop"
#		"network"   "Europnet"
#		"transmit"  "y"
#		"receive"   "y"
#	}

	# You can edit values but not remove
	# or you'll break the system
	set default {
		"highlight" 0
		"snet"      "y"
		"transmit"  "y"
		"receive"   "y"
		"log"       "n"
		"oper"      "y"
		"syn_topic" "n"
		"col_act"   "purple"
		"col_jpq"   "cyan"
		"col_mode"  "green"
		"usermask"	"(%nick%@%network%)"
	}

	# Fill this list with the nick of the users
	# who WON'T BE relayed, as services bot
	variable users_excluded {\[Guru\] Pan}

	# Fill this list with the nick of the users
	# wich will be THE ONLY ONES to be relayed
	variable users_only {}

	# transmission configuration
	set trans_pub "y"; # transmit the pub
	set trans_act "y"; # transmit the actions (/me)
	set trans_nick "y"; # transmit the nick changement
	set trans_join "y"; # transmit the join
	set trans_part "y"; # transmit the part
	set trans_quit "y"; # transmit the quit
	set trans_topic "y"; # transmit the topic changements
	set trans_kick "y"; # transmit the kicks
	set trans_mode "y"; #transmit the mode changements
	set trans_who "y"; # transmit the who list

	# reception configuration
	set recv_pub "y"; # recept the pub
	set recv_act "y"; # recept the actions (/me)
	set recv_nick "y"; # recept the nick changement
	set recv_join "y"; # recept the join
	set recv_part "y"; # recept the part
	set recv_quit "y"; # recept the quit
	set recv_topic "y"; # recept the topic changements
	set recv_kick "y"; # recept the kicks
	set recv_mode "y"; # recept the mode changements
	set recv_who "y"; # recept the who list

	set userlist(beg) "Beginning of userlist"
	set userlist(end) "End of userlist"

	# Set the banmask to use in banning the IPs  
	# Default banmask is set to 1
	# 1 - *!*@some.domain.com 
	# 2 - *!*@*.domain.com
	# 3 - *!*ident@some.domain.com
	# 4 - *!*ident@*.domain.com
	# 5 - *!*ident*@some.domain.com
	# 6 - *nick*!*@*.domain.com
	# 7 - *nick*!*@some.domain.com
	# 8 - nick!ident@some.domain.com
	# 9 - nick!ident@*.host.com
	set bantype 1

	# The default (ban)kick reason.
	# %n will be replaced with the kicker name
	set breason "You have been kicked by %n"

	# Path and name of the config file
	# %b will be replaced with the botnick
	variable config "./databases/%b.chanrelay.db"
	
	# Path and name of the logfile (used for debug)
	variable logfile "./databases/chanrelay.log"

	# max length of a message
	variable msglen 350
	
	variable author "CrazyCat"
	variable version "3.13"
}

####################################
#    DO NOT EDIT ANYTHING BELOW    #
####################################
proc ::crelay::init {args} {

	variable me
	array set me $::crelay::default
	array set me $::crelay::regg($::username)
	if { [file exists $::crelay::config] } {
		::crelay::preload
	}

	if { $me(transmit) == "y" } {
		bind msg o|o "trans" ::crelay::set:trans
		if { $::crelay::trans_pub == "y" } { bind pubm - * ::crelay::trans:pub }
		if { $::crelay::trans_act == "y" } { bind ctcp - "ACTION" ::crelay::trans:act }
		if { $::crelay::trans_nick == "y" } { bind nick - * ::crelay::trans:nick }
		if { $::crelay::trans_join == "y" } { bind join - * ::crelay::trans:join }
		if { $::crelay::trans_part == "y" } { bind part - * ::crelay::trans:part }
		if { $::crelay::trans_quit == "y" } {
			bind sign - * ::crelay::trans:quit
			bind evnt - disconnect-server ::crelay::trans:selfquit
		}
		if { $::crelay::trans_topic == "y" } { bind topc - * ::crelay::trans:topic }
		if { $::crelay::trans_kick == "y" } { bind kick - * ::crelay::trans:kick }
		if { $::crelay::trans_mode == "y" } { bind raw - "MODE" ::crelay::trans:mode }
		if { $::crelay::trans_who == "y" } { bind pub - "!who" ::crelay::trans:who }
		if { $me(oper) == "y" } {
			bind pub -|o "@topic" ::crelay::trans:otopic
			bind pub -|o "@mode" ::crelay::trans:omode
			bind pub -|o "@kick" ::crelay::trans:okick
			bind pub -|o "@ban" ::crelay::trans:oban
			bind pub -|o "@voice" ::crelay::trans:ovoice
			bind pub -|o "@hop" ::crelay::trans:ohop
			bind pub -|o "@op" ::crelay::trans:oop
		}
	}

	if { $me(receive) =="y" } {
		bind msg o|o "recv" ::crelay::set:recv
		if { $::crelay::recv_pub == "y" } { bind bot - ">pub" ::crelay::recv:pub }
		if { $::crelay::recv_act == "y" } { bind bot - ">act" ::crelay::recv:act }
		if { $::crelay::recv_nick == "y" } { bind bot - ">nick" ::crelay::recv:nick }
		if { $::crelay::recv_join == "y" } { bind bot - ">join" ::crelay::recv:join }
		if { $::crelay::recv_part == "y" } { bind bot - ">part" ::crelay::recv:part }
		if { $::crelay::recv_quit == "y" } { bind bot - ">quit" ::crelay::recv:quit }
		if { $::crelay::recv_topic == "y" } { bind bot - ">topic" ::crelay::recv:topic }
		if { $::crelay::recv_kick == "y" } { bind bot - ">kick" ::crelay::recv:kick }
		if { $::crelay::recv_mode == "y" } { bind bot - ">mode" ::crelay::recv:mode }
		if { $::crelay::recv_who == "y" } {
			bind bot - ">who" ::crelay::recv:who
			bind bot - ">wholist" ::crelay::recv:wholist
		}
		bind bot - ">otopic" ::crelay::recv:otopic
		bind bot - ">omode" ::crelay::recv:omode
		bind bot - ">okick" ::crelay::recv:okick
		bind bot - ">oban" ::crelay::recv:oban
		bind disc - * ::crelay::recv:disc
		bind link - * ::crelay::recv:link
		bind bot - ">list" ::crelay::recv:list
		bind bot - ">users" ::crelay::recv:users
	}

	::crelay::set:hl $me(highlight);

	if { $me(log) == "y"} {
		logfile sjpk $me(chan) "logs/[string range $me(chan) 1 end].log"
	}
	bind msg -|o "rc.status" ::crelay::help:status
	bind msg - "rc.help" ::crelay::help:cmds
	bind msg -|o "rc.light" ::crelay::set:light
	bind msg -|o "rc.net" ::crelay::set:snet
	bind msg -|o "rc.syntopic" ::crelay::set:syn_topic
	bind msg -|o "rc.debug" ::crelay::set:debug
	bind bot - ">notop" ::crelay::recv:error

	variable eggdrops
	variable chans
	variable networks
	foreach bot [array names ::crelay::regg] {
		array set tmp $::crelay::regg($bot)
		lappend eggdrops $bot
		lappend chans $tmp(chan)
		lappend networks $tmp(network)
	}
	::crelay::save
	bind evnt -|- prerehash ::crelay::deinit

	package forget ChanRelay
	package provide ChanRelay $::crelay::version
}

# Reads settings from a file
proc ::crelay::preload {args} {
	regsub -all %b $::crelay::config $::username fname
	if { [file exists $fname] } {
		set fp [open $fname r]
		set settings [read -nonewline $fp]
		close $fp
		foreach line [split $settings "\n"] {
			set lset [split $line "|"]
			switch [lindex $lset 0] {
				transmit { set ::crelay::me(transmit) [lindex $lset 1] }
				receive { set ::crelay::me(receive) [lindex $lset 1] }
				snet { set ::crelay::me(snet) [lindex $lset 1] }
				highlight { set ::crelay::me(highligt) [lindex $lset 1] }
				syn_topic { set ::crelay::me(syn_topic) [lindex $lset 1] }
				col_act { set ::crelay::me(col_act) [lindex $lset 1] }
				col_mode { set ::crelay::me(col_mode) [lindex $lset 1] }
				col_jpq { set ::crelay::me(col_jpq) [lindex $lset 1] }
				default {
					set ::crelay::[lindex $lset 0] [lindex $lset 1]
				}
			}
		}
	} else {
		::crelay::save
	}
}

# Save all settings in a file
proc ::crelay::save {args} {
	regsub -all %b $::crelay::config $::username fname
	set fp [open $fname w]
	puts $fp "transmit|$::crelay::me(transmit)"
	puts $fp "receive|$::crelay::me(receive)"
	puts $fp "snet|$::crelay::me(snet)"
	puts $fp "highlight|$::crelay::me(highlight)"
	puts $fp "col_act|$::crelay::me(col_act)"
	puts $fp "col_mode|$::crelay::me(col_mode)"
	puts $fp "col_jpq|$::crelay::me(col_jpq)"
	puts $fp "trans_pub|$::crelay::trans_pub"
	puts $fp "trans_act|$::crelay::trans_act"
	puts $fp "trans_nick|$::crelay::trans_nick"
	puts $fp "trans_join|$::crelay::trans_join"
	puts $fp "trans_part|$::crelay::trans_part"
	puts $fp "trans_quit|$::crelay::trans_quit"
	puts $fp "trans_topic|$::crelay::trans_topic"
	puts $fp "trans_kick|$::crelay::trans_kick"
	puts $fp "trans_mode|$::crelay::trans_mode"
	puts $fp "trans_who|$::crelay::trans_who"
	puts $fp "recv_pub|$::crelay::recv_pub"
	puts $fp "recv_act|$::crelay::recv_act"
	puts $fp "recv_nick|$::crelay::recv_nick"
	puts $fp "recv_join|$::crelay::recv_join"
	puts $fp "recv_part|$::crelay::recv_part"
	puts $fp "recv_quit|$::crelay::recv_quit"
	puts $fp "recv_topic|$::crelay::recv_topic"
	puts $fp "recv_kick|$::crelay::recv_kick"
	puts $fp "recv_mode|$::crelay::recv_mode"
	puts $fp "recv_who|$::crelay::recv_who"
	puts $fp "syn_topic|$::crelay::me(syn_topic)"
	close $fp
}

proc ::crelay::deinit {args} {
	putlog "Starting unloading CHANRELAY $::crelay::version"
	::crelay::save
	putlog "Settings are saved in $::crelay::config"
	foreach binding [lsearch -inline -all -regexp [binds *[set ns [::tcl::string::range ::crelay 2 end]]*] " \{?(::)?$ns"] {
		unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
	}
	putlog "CHANRELAY $::crelay::version unloaded"
	package forget ChanRelay
	namespace delete ::crelay
}

namespace eval crelay {
	variable hlnick
	variable snet
	variable syn_topic
	# Setting of hlnick
	proc set:light { nick uhost handle arg } {
		# message binding
		switch [string tolower $arg] {
			"bo" { ::crelay::set:hl 1; }
			"un" { ::crelay::set:hl 2; }
			"gr" { ::crelay::set:hl 3; }
			"off" { ::crelay::set:hl 0; }
			default { puthelp "NOTICE $nick :you must chose \002(bo)\002ld , \037(un)\037derline, \00314(gr)\003ay or (off)" }
		}
		::crelay::save
		return 0;
	}

	proc set:hl { arg } {
		# global hlnick setting function
		switch [string tolower $arg] {
			1 { set ::crelay::hlnick "\002"; }
			2 { set ::crelay::hlnick "\037"; }
			3 { set ::crelay::hlnick "\00314"; }
			default { set ::crelay::hlnick ""; }
		}
	}
	
	variable colors { "white" "\00300" "black" "\00301" "blue" "\00302" "green" "\00303"
		"lightred" "\00304" "brown" "\00305" "purple" "\00306" "orange" "\00307"
		"yellow" "\00308" "lightgreen" "\00309" "cyan" "\00310" "lightcyan" "\00311"
		"lightblue" "\00312" "pink" "\00313" "grey" "\00314" "lightgrey" "\00315" }

	proc colorize {type text} {
		set text [stripcodes abcgru $text]
		if {$type eq "act" && $::crelay::me(col_act) ne ""} {
			set text "[::tcl::string::map $::crelay::colors $::crelay::me(col_act)]$text\003"
		} elseif {$type eq "mode" && $::crelay::me(col_mode) ne ""} {
			set text "[::tcl::string::map $::crelay::colors $::crelay::me(col_mode)]$text\003"
		} elseif { $type eq "jpq" && $::crelay::me(col_jpq) ne ""} {
			set text "[::tcl::string::map $::crelay::colors $::crelay::me(col_jpq)]$text\003"
		}
		return $text
	}
	
	# Setting of show network
	proc set:snet {nick host handle arg } {
		set arg [string tolower $arg]
		if { $arg == "yes" } {
			set ::crelay::snet "y"
			puthelp "NOTICE $nick :Network is now showed"
		} elseif { $arg == "no" } {
			set ::crelay::snet "n"
			puthelp "NOTICE $nick :Network is now hidden"
		} else {
			puthelp "NOTICE $nick :you must chose yes or no"
			return 0
		}
		::crelay::save
	}

	proc set:syn_topic {nick host handle arg} {
		set arg [string tolower $arg]
		if { $arg == "yes" } {
			set ::crelay::syn_topic "y"
			puthelp "NOTICE $nick :Topic synchro is now enabled"
		} elseif { $arg == "no" } {
			set ::crelay::syn_topic "n"
			puthelp "NOTICE $nick :Topic synchro is now disabled"
		} else {
			puthelp "NOTICE $nick :you must choose yes or no"
			return 0
		}
	}
	
	proc set:debug { nick host handle arg} {
		set arg [string tolower $arg]
		if { $arg == "yes" } {
			set ::crelay::debug 1
			puthelp "NOTICE $nick :Debug mode is now enabled"
		} elseif { $arg == "no" } {
			set ::crelay::debug 0
			puthelp "NOTICE $nick :Debug mode is now disabled"
		} else {
			puthelp "NOTICE $nick :Debug mode is actually setted to $::crelay::debug"
			return 0
		}
	}

	# proc setting of transmission by msg
	proc set:trans { nick host handle arg } {
		if { $::crelay::me(transmit) == "y" } {
			if { $arg == "" } {
				putquick "NOTICE $nick :you'd better try /msg $::botnick trans help"
			}
			if { [lindex [split $arg] 0] == "help" } {
				putquick "NOTICE $nick :usage is /msg $::botnick trans <value> on|off"
				putquick "NOTICE $nick :with <value> = pub, act, nick, join, part, quit, topic, kick, mode, who"
				return 0
			} else {
				switch [lindex [split $arg] 0] {
					"pub" { set type pubm }
					"act" { set type ctcp }
					"nick" { set type nick }
					"join" { set type join }
					"part" { set type part }
					"quit" { set type sign }
					"topic" { set type topc }
					"kick" { set type kick }
					"mode" { set type mode }
					"who" { set type who }
					default {
						putquick "NOTICE $nick :Bad mode. Try /msg $::botnick trans help"
						return 0
					}
				}
				set proc_change "::crelay::trans:[lindex [split $arg] 0]"
				set mod_change "::crelay::trans_[lindex [split $arg] 0]"
				if { [lindex [split $arg] 1] eq "on" } {
				   if { $type eq "mode" } {
					  bind raw - "MODE" ::crelay::trans:mode
				   } else {
					bind $type - * $proc_change
			   }
			   if { $type eq "sign"} {
				bind evnt - disconnect-server ::crelay::trans:selfquit
				}
					set ${mod_change} "y"
					putserv "NOTICE $nick :Transmission of [lindex [split $arg] 0] enabled"
				} elseif { [lindex [split $arg] 1] eq "off" } {
				   if { $type eq "mode" } {
					  unbind raw - "MODE" ::crelay::trans:mode
				   } else {
					unbind $type - * $proc_change
				}
				if { $type eq "sign"} {
				unbind evnt - disconnect-server ::crelay::trans:selfquit
				}
					set ${mod_change} "n"
					putserv "NOTICE $nick :Transmission of [lindex [split $arg] 0] disabled"
				} else {
					putquick "NOTICE $nick :[lindex [split $arg] 1] is not a correct value, choose \002on\002 or \002off\002"
				}
			}
		} else {
			putquick "NOTICE $nick :transmission is not activated, you can't change anything"
		}
		::crelay::save
	}

	# proc setting of reception by msg
	proc set:recv { nick host handle arg } {
		if { $::crelay::me(receive) == "y" } {
			if { $arg == "" } {
				putquick "NOTICE $nick :you'd better try /msg $::botnick recv help"
			}
			if { [lindex [split $arg] 0] == "help" } {
				putquick "NOTICE $nick :usage is /msg $::botnick recv <value> on|off"
				putquick "NOTICE $nick :with <value> = pub, act, nick, join, part, quit, topic, kick, mode, who"
				return 0
			} else {
				switch [lindex [split $arg] 0] {
					"pub" -
					"act" -
					"nick" -
					"join" -
					"part" -
					"quit" -
					"topic" -
					"kick" -
					"mode" -
					"who" { set type [lindex [split $arg] 0] }
					default {
						putquick "NOTICE $nick :Bad mode. Try /msg $::botnick recv help"
						return 0
					}
				}
				set change ">$type"
				set proc_change "::crelay::recv:$type"
				set mod_change "::crelay::recv_$type"
				if { [lindex [split $arg] 1] eq "on" } {
					bind bot - $change $proc_change
					set ${mod_change} "y"
					putserv "NOTICE $nick :Reception of $type enabled"
				} elseif { [lindex [split $arg] 1] == "off" } {
					unbind bot - $change $proc_change
					set ${mod_change} "n"
					putserv "NOTICE $nick :Reception of $type disabled"
				} else {
					putquick "NOTICE $nick :[lindex [split $arg] 1] is not a correct value, choose \002on\002 or \002off\002"
				}
			}
		} else {
			putquick "NOTICE $nick :reception is not activated, you can't change anything"
		}
		::crelay::save
	}
	
	# Generates an user@network name
	# based on nick and from bot using usermask setting
	proc make:user { nick frm_bot } {
		if {[string length $::crelay::hlnick] > 0 } {
			set ehlnick [string index $::crelay::hlnick 0]
		} else {
			set ehlnick ""
		}
		set umask $::crelay::me(usermask)
		array set him $::crelay::regg($frm_bot)
		regsub -all %network% $umask $him(network) umask
		if {$nick == "*"} {
			regsub -all {(%nick%|@)} $umask "" umask
			set speaker [concat "$::crelay::hlnick$umask$ehlnick"]
		} else {
			regsub -all %nick% $umask $nick umask
			set speaker $::crelay::hlnick$umask$ehlnick
		}
		return $speaker
	}
	
	# Logs virtual channel activity 
	proc cr:log { lev chan line } {
		if { $::crelay::me(log) == "y" } {
			putloglev $lev "$chan" "$line"
		}
		return 0
	}
	
	# Global transmit procedure
	proc trans:bot { usercmd chan usernick text } {
		if { $::crelay::debug == 1 } { dlog "Transmission $usercmd from $usernick / $chan" }
		if {[llength $::crelay::users_only]>0 && [lsearch -nocase $::crelay::users_only $usernick]==-1} {
			return 0
		}
		if {[llength $::crelay::users_excluded]>0 && [lsearch -nocase $::crelay::users_excluded $usernick]!=-1} {
			return 0
		}
		set transmsg [concat $usercmd $usernick $text]
		set ::crelay::eob 0
		if {[string tolower $chan] == [string tolower $::crelay::me(chan)]} {
			foreach bot [array names ::crelay::regg] {
				if {$bot != $::username && [islinked $bot]} {
					putbot $bot $transmsg
					if { $::crelay::debug == 1 } { dlog "Sent to $bot : $transmsg" }
					if {$usercmd == ">who" } { incr ::crelay::eob }
				}
			}
			
		} else {
			return 0
		}
	}

	# proc transmission of pub (trans_pub = y)
	proc trans:pub {nick uhost hand chan text} {
		if { [string tolower [lindex [split $text] 0]] == "!who" } { return 0; }
		if { [string tolower [lindex [split $text] 0]] == "@topic" } { return 0; }
		if { [string tolower [lindex [split $text] 0]] == "@mode" } { return 0; }
		if { [string tolower [lindex [split $text] 0]] == "@ban" } { return 0; }
		if { [string tolower [lindex [split $text] 0]] == "@kick" } { return 0; }
		foreach splmsg [::crelay::split_line $text [expr {$::crelay::msglen - [::tcl::string::length [::crelay::make:user $nick $::username]]}]] {
			if { $::crelay::debug == 1 } { dlog "Prepare transmission : >pub $chan $nick $splmsg" }
			::crelay::trans:bot ">pub" $chan $nick $splmsg
		}
	}
	
	# proc transmission of action (trans_act = y)
	proc trans:act {nick uhost hand chan key text} {
		set arg [concat $key $text]
		if { $::crelay::debug == 1 } { dlog "Prepare transmission : >act $chan $nick $arg" }
		::crelay::trans:bot ">act" $chan $nick $arg
	}
	
	# proc transmission of nick changement
	proc trans:nick {nick uhost hand chan newnick} {
		if { $::crelay::debug == 1 } { dlog "Prepare transmission : >nick $chan $nick $newnick" }
		::crelay::trans:bot ">nick" $chan $nick $newnick
	}
	
	# proc transmission of join
	proc trans:join {nick uhost hand chan} {
		if { $::crelay::debug == 1 } { dlog "Prepare transmission : >join $chan $chan $nick" }
		::crelay::trans:bot ">join" $chan $chan "$nick!$uhost"
	}
	
	# proc transmission of part
	proc trans:part {nick uhost hand chan text} {
		set arg [concat $chan $text]
		if { $::crelay::debug == 1 } { dlog "Prepare transmission : >part $chan $nick $arg" }
		::crelay::trans:bot ">part" $chan $nick $arg
	}
	
	# proc transmission of quit
	proc trans:quit {nick host hand chan text} {
		if { $::crelay::debug == 1 } { dlog "Prepare transmission : >quit $chan $nick $text" }
		::crelay::trans:bot ">quit" $chan $nick $text
	}
	
	# Proc to get our self quit
	proc trans:selfquit {type} {
		::crelay::trans:bot ">quit" $::crelay::me(chan) $::botnick "I don't know why but I left server"
	}
	
	# proc transmission of topic changement
	proc trans:topic {nick uhost hand chan topic} {
		set arg [concat $chan $topic]
		if { $::crelay::debug == 1 } { dlog "Prepare transmission : >topic $chan $nick $arg" }
		::crelay::trans:bot ">topic" $chan $nick $arg
	}
	
	# proc transmission of kick
	proc trans:kick {nick uhost hand chan victim reason} {
		set arg [concat $victim $chan $reason]
		if { $::crelay::debug == 1 } { dlog "Prepare transmission : >kick $chan $nick $arg" }
		::crelay::trans:bot ">kick" $chan $nick $arg
	}
	
	# proc transmission of mode changement
	proc trans:mode {from keyw text} {
		set nick [lindex [split $from !] 0]
		set chan [lindex [split $text] 0]
		set text [concat $nick $text]
		if { $::crelay::debug == 1 } { dlog "Prepare transmission : >mode $chan $nick $text" }
		::crelay::trans:bot ">mode" $chan $nick $text
	}
	
	# proc transmission of "who command"
	proc trans:who {nick uhost handle chan args} {
		if { [join [lindex [split $args] 0]] != "" } {
			set netindex [lsearch -nocase $::crelay::networks [lindex [split $args] 0]]
			if { $netindex == -1 } {
				putserv "PRIVMSG $nick :$args est un réseau inconnu";
				return 0
			} else {
			   set ::crelay::eol 0
			   set ::crelay::bol 0
					set ::crelay::eob 1
				putbot [lindex $::crelay::eggdrops $netindex] ">who $nick"
			}
		} else {
			set ::crelay::eol 0
			set ::crelay::bol 0
			::crelay::trans:bot ">who" $chan $nick ""
		}
	}
	
	# Error reception
	proc recv:error {frm_bot command arg} {
		# putlog "$command - $arg"
		return 0
	}
	
	# proc reception of pub
	proc recv:pub {frm_bot command arg} {
		if { $::crelay::debug == 1 } { dlog "Received $command from $frm_bot" }
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [::crelay::make:user [lindex $argl 0] $frm_bot]
			if { $::crelay::debug == 1 } { dlog "Sending pub [join [lrange $argl 1 end]] to $::crelay::me(chan)" }
			putquick "PRIVMSG $::crelay::me(chan) :$speaker [join [lrange $argl 1 end]]"
			::crelay::cr:log p "$::crelay::me(chan)" "<[lindex $argl 0]> [join [lrange $argl 1 end]]"
		} else {
			if { $::crelay::debug == 1 } { dlog "$frm_bot is unknown" }
		}
		return 0
	}
	
	# proc reception of action
	proc recv:act {frm_bot command arg} {
		if { $::crelay::debug == 1 } { dlog "Received $command from $frm_bot" }
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [::crelay::make:user [lindex $argl 0] $frm_bot]
			if { $::crelay::debug == 1 } { dlog "Sending act [join [lrange $argl 2 end]] to $::crelay::me(chan)" }
			set text [::crelay::colorize "act" "* $speaker [join [lrange $argl 2 end]]"]
			putquick "PRIVMSG $::crelay::me(chan) :$text"
			::crelay::cr:log p "$::crelay::me(chan)" "Action: [lindex $argl 0] [join [lrange $argl 2 end]]"
		} else {
			if { $::crelay::debug == 1 } { dlog "$frm_bot is unknown" }
		}
		return 0
	}
	
	# proc reception of nick changement
	proc recv:nick {frm_bot command arg} {
		if { $::crelay::debug == 1 } { dlog "Received $command from $frm_bot" }
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [::crelay::make:user [lindex $argl 0] $frm_bot]
			if { $::crelay::debug == 1 } { dlog "Sending nick [join [lrange $argl 1 end]] to $::crelay::me(chan)" }
			set text [::crelay::colorize "jpq" "*** $speaker is now known as [join [lrange $argl 1 end]]"]
			putquick "PRIVMSG $::crelay::me(chan) :$text"
			::crelay::cr:log j "$::crelay::me(chan)" "Nick change: [lindex $argl 0] -> [join [lrange $argl 1 end]]"
		} else {
			if { $::crelay::debug == 1 } { dlog "$frm_bot is unknown" }
		}
		return 0
	}
	
	# proc reception of join
	proc recv:join {frm_bot command arg} {
		if { $::crelay::debug == 1 } { dlog "Received $command from $frm_bot" }
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [lindex $argl 1]
			if { $::crelay::debug == 1 } { dlog "Sending join [join [lrange $argl 1 end]] to $::crelay::me(chan)" }
			set text [::crelay::colorize "jpq" "--> $speaker has joined channel [lindex $argl 0]@[lindex $::crelay::networks $him]"]
			putquick "PRIVMSG $::crelay::me(chan) :$text"
			::crelay::cr:log j "$::crelay::me(chan)" "[lindex $argl 1] joined $::crelay::me(chan)."
		} else {
			if { $::crelay::debug == 1 } { dlog "$frm_bot is unknown" }
		}
		return 0
	}
	
	# proc reception of part
	proc recv:part {frm_bot command arg} {
		if { $::crelay::debug == 1 } { dlog "Received $command from $frm_bot" }
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [::crelay::make:user [lindex $argl 0] $frm_bot]
			if { $::crelay::debug == 1 } { dlog "Sending part [join [lrange $argl 1 end]] to $::crelay::me(chan)" }
			if {[llength $argl]<4} {
				set partmsg ""
			} else {
				set partmsg " ([join [lrange $argl 2 end]])"
			}
			#set text [::crelay::colorize "jpq" "<-- $speaker has left channel [lindex $argl 1] ([join [lrange $argl 2 end]])"]
			set text [::crelay::colorize "jpq" "<-- $speaker has left channel [lindex $argl 1]$partmsg"]
			putquick "PRIVMSG $::crelay::me(chan) :$text"
			::crelay::cr:log j "$::crelay::me(chan)" "[lindex $argl 0] left $::crelay::me(chan) ([join [lrange $argl 2 end]])"
		} else {
			if { $::crelay::debug == 1 } { dlog "$frm_bot is unknown" }
		}
		return 0
	}
	
	# proc reception of quit
	proc recv:quit {frm_bot command arg} {
		if { $::crelay::debug == 1 } { dlog "Received $command from $frm_bot" }
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [::crelay::make:user [lindex $argl 0] $frm_bot]
			if {[llength $argl]<3} {
				set quitmsg ""
			} else {
				set quitmsg " ([join [lrange $argl 1 end]])"
			}
			if { $::crelay::debug == 1 } { dlog "Sending quit [join [lrange $argl 1 end]] to $::crelay::me(chan)" }
			#set text [::crelay::colorize "jpq" "-//- $speaker has quit ([join [lrange $argl 1 end]])"]
			set text [::crelay::colorize "jpq" "-//- $speaker has quit$quitmsg"]
			putquick "PRIVMSG $::crelay::me(chan) :$text"
			::crelay::cr:log j "$::crelay::me(chan)" "[lindex $argl 0] left irc: ([join [lrange $argl 1 end]])"
		} else {
			if { $::crelay::debug == 1 } { dlog "$frm_bot is unknown" }
		}
		return 0
	}
	
	# proc reception of topic changement
	proc recv:topic {frm_bot command arg} {
		if { $::crelay::debug == 1 } { dlog "Received $command from $frm_bot" }
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [::crelay::make:user [lindex $argl 0] $frm_bot]
			if { $::crelay::debug == 1 } { dlog "Sending topic [join [lrange $argl 1 end]] to $::crelay::me(chan)" }
			if { $::crelay::me(syn_topic) == "y" } {
				putserv "TOPIC $::crelay::me(chan) :[join [lrange $argl 2 end]]"
			} else {
				putquick "PRIVMSG $::crelay::me(chan) :*** $speaker changes topic of [lindex $argl 1] to '[join [lrange $argl 2 end]]'"
			}
		} else {
			if { $::crelay::debug == 1 } { dlog "$frm_bot is unknown" }
		}
		return 0
	}
	
	# proc reception of kick
	proc recv:kick {frm_bot command arg} {
		if { $::crelay::debug == 1 } { dlog "Received $command from $frm_bot" }
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [::crelay::make:user [lindex $argl 1] $frm_bot]
			if { $::crelay::debug == 1 } { dlog "Sending kick [join [lrange $argl 1 end]] to $::crelay::me(chan)" }
			set text [::crelay::colorize "jpq" "*** $speaker has been kicked from [lindex $argl 2] by [lindex $argl 0]: [join [lrange $argl 3 end]]"]
			putquick "PRIVMSG $::crelay::me(chan) :$text"
			::crelay::cr:log k "$::crelay::me(chan)" "[lindex $argl 1] kicked from $::crelay::me(chan) by [lindex $argl 0]:[join [lrange $argl 3 end]]"
		} else {
			if { $::crelay::debug == 1 } { dlog "$frm_bot is unknown" }
		}
		return 0
	}
	
	# proc reception of mode changement
	proc recv:mode {frm_bot command arg} {
		if { $::crelay::debug == 1 } { dlog "Received $command from $frm_bot" }
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [::crelay::make:user [lindex $argl 1] $frm_bot]
			if { $::crelay::debug == 1 } { dlog "Sending mode [join [lrange $argl 1 end]] to $::crelay::me(chan)" }
			set text [::crelay::colorize "mode" "*** $speaker set mode [join [lrange $argl 2 end]]"]
			putquick "PRIVMSG $::crelay::me(chan) :$text"
		} else {
			if { $::crelay::debug == 1 } { dlog "$frm_bot is unknown" }
		}
		return 0
	}
	
	# reception of !who command
	proc recv:who {frm_bot command arg} {
		set nick $arg
		set ulist ""
		set cusr 0
		if {![botonchan $::crelay::me(chan)]} {
			putbot $frm_bot ">wholist $::crelay::me(chan) $nick eol"
			return 0
		}
		foreach user [chanlist $::crelay::me(chan)] {
			if { $user == $::botnick } { continue; }
			if { [isop $user $::crelay::me(chan)] == 1 } {
				set st "@"
			} elseif { [ishalfop $user $::crelay::me(chan)] == 1 } {
				set st "%"
			} elseif { [isvoice $user $::crelay::me(chan)] == 1 } {
				set st "%"
			} else {
				set st ""
			}
			incr cusr 1
			append ulist " $st$user"
			if { $cusr == 5 } {
				putbot $frm_bot ">wholist $::crelay::me(chan) $nick $ulist"
				set ulist ""
				set cusr 0
			}
		}
		if { $ulist != "" } {
			putbot $frm_bot ">wholist $::crelay::me(chan) $nick $ulist"
		}
		putbot $frm_bot ">wholist $::crelay::me(chan) $nick eol"
	}
	
	# Proc reception of a who list
	proc recv:wholist {frm_bot command arg} {
		set nick [join [lindex [split $arg] 1]]
		set speaker [::crelay::make:user $frm_bot $frm_bot]
		if {$::crelay::bol == 0} {
			incr ::crelay::bol
			putserv "NOTICE $nick :*** $::crelay::userlist(beg)"
		}
		if { [join [lrange [split $arg] 2 end]] == "eol"} {
			incr ::crelay::eol
			if {$::crelay::eol == $::crelay::eob} {
				putserv "NOTICE $nick :*** $::crelay::userlist(end)"
			}
		} else {
			putserv "NOTICE $nick :$speaker [join [lrange [split $arg] 2 end]]"
		}
	}
	
	######################################
	# Operators commands
	#
	proc trans:otopic {nick uhost handle chan text} {
		if {[::crelay::isOper $::username]==0} {
			putserv "NOTICE $nick :Sorry but I'm not setted as oper in chanrelay"
			return 0
		}
		set netindex [::crelay::checkDest [join [lindex [split $text] 0]]]
		if { $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @topic <network|all> the new topic"
			return 0
		}
		set topic [join [lrange [split $text] 1 end]]
		if { $netindex < 99 } {
			putbot [lindex $::crelay::eggdrops $netindex] ">otopic $nick $topic"
		} else {
			::crelay::trans:bot ">otopic" $chan $nick $topic
			putserv "TOPIC $::crelay::me(chan) :$topic"
		}
		return 0
	}
	
	proc recv:otopic {frm_bot command arg} {
		if { [::crelay::isOper $frm_bot] != 1 } { return 0 }
		set nick [join [lindex [split $arg] 0]]
		if { ![::crelay::hasRights $::crelay::me(chan)] } {
			putbot $frm_bot ">notop $::crelay::me(chan) $nick"
			return 0
		}
		putserv "TOPIC $::crelay::me(chan) :[join [lrange [split $arg] 1 end]]"
		return 0
	}
	
	proc trans:ovoice {nick uhost handle chan text} {
		if {[::crelay::isOper $::username]==0} {
			putserv "NOTICE $nick :Sorry but I'm not setted as oper in chanrelay"
			return 0
		}
		set netindex [::crelay::checkDest [join [lindex [split $text] 0]]]
		if { $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @voice <network|all> <+/->nick"
			return 0
		}
		set mode [append [string index [lindex [split $text] 1] 0] "v"]
		set vict [string range [join [lrange [split $text] 1 end]] 1 end]
		::crelay::trans:omode $nick $uhost $handle $chan "[join [lindex [split $text] 0]] $mode $vict"
	}
	
	proc trans:ohop {nick uhost handle chan text} {
		if {[::crelay::isOper $::username]==0} {
			putserv "NOTICE $nick :Sorry but I'm not setted as oper in chanrelay"
			return 0
		}
		set netindex [::crelay::checkDest [join [lindex [split $text] 0]]]
		if { $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @hop <network|all> <+/->nick"
			return 0
		}
		set mode [append [string index [join [lrange [split $text] 1 end]] 0] "h"]
		set vict [string range [join [lrange [split $text] 1 end]] 1 end]
		::crelay::trans:omode $nick $uhost $handle $chan "@mode [join [lindex [split $text] 0]] $mode $vict"
	}
	
	proc trans:oop {nick uhost handle chan text} {
		if {[::crelay::isOper $::username]==0} {
			putserv "NOTICE $nick :Sorry but I'm not setted as oper in chanrelay"
			return 0
		}
		set netindex [::crelay::checkDest [join [lindex [split $text] 0]]]
		if { $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @op <network|all> <+/->nick"
			return 0
		}
		set mode [append [string index [join [lrange [split $text] 1 end]] 0] "o"]
		set vict [string range [join [lrange [split $text] 1 end]] 1 end]
		::crelay::trans:omode $nick $uhost $handle $chan "@mode [join [lindex [split $text] 0]] $mode $vict"
	}
	
	proc trans:omode {nick uhost handle chan text} {
		if {[::crelay::isOper $::username]==0} {
			putserv "NOTICE $nick :Sorry but I'm not setted as oper in chanrelay"
			return 0
		}
		set netindex [::crelay::checkDest [join [lindex [split $text] 0]]]
		if { $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @mode <network|all> <+/-mode> \[arg\]\[,<+/-mode> \[arg\]...\]"
			return 0
		}
		set mode [join [lrange [split $text] 1 end]]
		if { $netindex < 99 } {
			putbot [lindex $::crelay::eggdrops $netindex] ">omode $nick $mode"
		} else {
			::crelay::trans:bot ">omode" $chan $nick $mode
			foreach m [split $mode ","] { pushmode $::crelay::me(chan) $m; putlog "PM $::crelay::me(chan) $m" }
			flushmode $::crelay::me(chan)
		}
		return 0
	}
	
	proc recv:omode {frm_bot command arg} {
		if { [::crelay::isOper $frm_bot] != 1 } { return 0 }
		set nick [join [lindex [split $arg] 0]]
		if { ![::crelay::hasRights $::crelay::me(chan)] } {
			putbot $frm_bot ">notop $::crelay::me(chan) $nick"
			return 0
		}
		foreach mode [split [join [lrange [split $arg] 1 end]] ","] {
			catch { pushmode $::crelay::me(chan) $mode }
		}
		flushmode $::crelay::me(chan)
		return 0
	}
	
	proc trans:okick {nick uhost handle chan text} {
		if {[::crelay::isOper $::username]==0} {
			putserv "NOTICE $nick :Sorry but I'm not setted as oper in chanrelay"
			return 0
		}
		set netindex [::crelay::checkDest [join [lindex [split $text] 0]]]
		set vict [join [lindex [split $text] 1]]
		set reason [join [lrange [split $text] 2 end]]
		if { $vict eq "" || $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @kick <operpass> <network|all> nick \[reason of kickin\]"
			return 0
		}
		if { $netindex < 99 } {
			putbot [lindex $::crelay::eggdrops $netindex] ">okick $chan $nick $vict $reason"
		} else {
			::crelay::trans:bot ">okick" $chan $nick [concat $vict $reason]
		}
		return 0
	}
	
	proc recv:okick {frm_bot command arg} {
		if { [::crelay::isOper $frm_bot] != 1 } { return 0 }
		set nick [join [lindex [split $arg] 1]]
		if { ![::crelay::hasRights $::crelay::me(chan)] } {
			putbot $frm_bot ">notop $::crelay::me(chan) $nick"
			return 0
		}
		set vict [join [lindex [split $arg] 2]]
		if {![onchan $vict $::crelay::me(chan)]} {
		   putbot $frm_bot ">notop $::crelay::me(chan) $nick"
		}
		set reason [join [lrange [split $arg] 2 end]]
		if { $reason eq "" } { regsub -all %n $::crelay::breason $nick reason }
		putkick $::crelay::me(chan) $vict $reason
	   return 0
	}
	
	proc trans:oban {nick uhost handle chan text} {
		if {[::crelay::isOper $::username]==0} {
			putserv "NOTICE $nick :Sorry but I'm not setted as oper in chanrelay"
			return 0
		}
		set netindex [::crelay::checkDest [join [lindex [split $text] 0]]]
		set vict [join [lindex [split $text] 1]]
		set reason [join [lrange [split $text] 2 end]]
		if { $vict eq "" || $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @ban <operpass> <network|all> nick \[reason of banning\]"
			return 0
		}
		if { $netindex < 99 } {
			putbot [lindex $::crelay::eggdrops $netindex] ">oban $chan $nick $vict $reason"
		} else {
			::crelay::trans:bot ">oban" $chan $nick [concat $vict $reason]
		}
		return 0
	}
	
	proc recv:oban {frm_bot command arg} {
		if { [::crelay::isOper $frm_bot] != 1 } { return 0 }
		set nick [join [lindex [split $arg] 1]]
		if { ![::crelay::hasRights $::crelay::me(chan)] } {
			putbot $frm_bot ">notop $::crelay::me(chan) $nick"
			return 0
		}
		set vict [join [lindex [split $arg] 2]]
		if {![onchan $vict $::crelay::me(chan)]} {
		   putbot $frm_bot ">notop $::crelay::me(chan) $nick"
		}
		set reason [join [lrange [split $arg] 3 end]]
		if { $reason eq "" } { regsub -all %n $::crelay::breason $nick reason }
		set bmask [::crelay::mask [getchanhost $vict $::crelay::me(chan)] $vict]
		pushmode $::crelay::me(chan) +b $bmask
		putkick $::crelay::me(chan) $vict $reason
		flushmode $::crelay::me(chan)
		return 0
	}
	
	# Special : botnet lost
	proc recv:disc {frm_bot} {
		if {$frm_bot == $::username} {
			putquick "PRIVMSG $::crelay::me(chan) :I'd left the relay"
		} elseif {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set speaker [::crelay::make:user "*" $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :*** We lose $speaker ($frm_bot leaves botnet)"
		}
		return 0
	}
	
	# Special : botnet recover
	proc recv:link {frm_bot via} {
		if {$frm_bot == $::username} {
			putquick "PRIVMSG $::crelay::me(chan) :I'm back in the relay"
		} elseif {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set speaker [::crelay::make:user "*" $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :*** $speaker is back ($frm_bot rejoined botnet)"
		}
		return 0
	}
	
	######################################
	# Private messaging
	#
	
	bind msg - "say" ::crelay::prv:say_send
	proc prv:say_send {nick uhost handle text} {
		set dest [join [lindex [split $text] 0]]
		set msg [join [lrange [split $text] 1 end]]
		set vict [join [lindex [split $dest @] 0]]
		set net [join [lindex [split $dest @] 1]]
		if { $vict == "" || $net == "" } {
			putserv "PRIVMSG $nick :Use \002say user@network your message to \037user\037\002";
			return 0
		}
		set him [lsearch -nocase $::crelay::networks $net]
		if { $him == -1 } {
			putserv "PRIVMSG $nick :I don't know any network called $net.";
			putserv "PRIVMSG $nick :Available networks: [join [split $::crelay::networks]]"
			return 0
		}
		if { [string length $msg] == 0 } {
			putserv "PRIVMSG $nick :Did you forget your message to $vict@$net ?";
			return 0
		}
		putbot [lindex $::crelay::eggdrops $him] ">pvmsg $vict $nick@$::crelay::me(network) $msg"
	}
	
	bind bot - ">pvmsg" ::crelay::prv:say_get
	proc prv:say_get {frm_bot command arg} {
		set dest [join [lindex [split $arg] 0]]
		set from [join [lindex [split $arg] 1]]
		set msg [join [lrange [split $arg] 2 end]]
		if { [onchan $dest $::crelay::me(chan)] == 1 } {
			putserv "PRIVMSG $dest :$from: $msg"
		}
	}

	######################################
	# Small tools
	#
	proc checkDest { network } {
		if { $network eq "all" } { return 99 }
		set netindex [lsearch -nocase $::crelay::networks $network]
		if { $network ne "all" && $netindex == -1 } { return -1 }
		return $netindex
	}
	
	# Checks if eggdrop is @ or %
	proc hasRights { chan } {
		if { ![botisop $chan] && ![botishalfop $chan] } {
			return 0
		}
		return 1
	}
	
	# Checks if bot is declared as oper
	proc isOper { bot } {
		if { [lsearch $::crelay::eggdrops $bot] == -1 } { return 0 }
		array set tmp $::crelay::regg($bot)
		if { [lsearch [array names tmp] "oper"] == -1 } { return 0 }
		if { $tmp(oper) ne "y" } { return 0 }
		return 1
	}
	
	# Generate a ban mask based on host and bantype
	proc mask {uhost nick} {
		switch -- $::crelay::bantype {
			1 { set mask "*!*@[lindex [split $uhost @] 1]" }
			2 { set mask "*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
			3 { set mask "*!*$uhost" }
			4 { set mask "*!*[lindex [split [maskhost $uhost] "!"] 1]" }
			5 { set mask "*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" }
			6 { set mask "*$nick*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
			7 { set mask "*$nick*!*@[lindex [split $uhost "@"] 1]" }
			8 { set mask "$nick![lindex [split $uhost "@"] 0]@[lindex [split $uhost @] 1]" }
			9 { set mask "$nick![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
			default { set mask "*!*@[lindex [split $uhost @] 1]" }
		}
		return $mask
	}
	
	# Split line function
	# based on MenzAgitat procedure
	# @see http://www.boulets.oqp.me/tcl/routines/tcl-toolbox-0014.html
	proc split_line {data limit} {
		incr limit -1
		if {$limit < 9} {
			error "limit must be higher than 9"
		}
		if { [::tcl::string::bytelength $data] <= $limit } {
			return [expr {$data eq "" ? [list ""] : [split $data "\n"]}]
		} else {
			# Note : si l'espace le plus proche est situé à plus de 50% de la fin du
			# fragment, on n'hésite pas à couper au milieu d'un mot.
			set middle_pos [expr round($limit / 2.0)]
			set output ""
			while {1} {
				if { ([set cut_index [::tcl::string::first "\n" $data]] != -1) && ($cut_index <= $limit)} then {
					# On ne fait rien de plus, on vient de définir $cut_index.
				} elseif {
					([set cut_index [::tcl::string::last " " $data [expr {$limit + 1}]]] == -1)
					|| ($cut_index < $middle_pos)
				} then {
					set new_cut_index -1
					# On vérifie qu'on ne va pas couper dans la définition d'une couleur.
					for {set i 0} {$i < 6} {incr i} {
						if {
							([::tcl::string::index $data [set test_cut_index [expr {$limit - $i}]]] eq "\003")
							&& ([regexp {^\003([0-9]{1,2}(,[0-9]{1,2})?)} [::tcl::string::range $data $test_cut_index end]])
						} then {
							set new_cut_index [expr {$test_cut_index - 1}]
						}
					}
					set cut_index [expr {($new_cut_index == -1) ? ($limit) : ($new_cut_index)}]
				}
				set new_part [::tcl::string::range $data 0 $cut_index]
				set data [::tcl::string::range $data $cut_index+1 end]
				if { [::tcl::string::trim [::tcl::string::map [list \002 {} \037 {} \026 {} \017 {}] [regsub -all {\003([0-9]{0,2}(,[0-9]{0,2})?)?} $new_part {}]]] ne "" } {
					lappend output [::tcl::string::trimright $new_part]
				} 
				# Si, quand on enlève les espaces et les codes de formatage, il ne reste
				# plus rien, pas la peine de continuer.
				if { [::tcl::string::trim [::tcl::string::map [list \002 {} \037 {} \026 {} \017 {}] [regsub -all {\003([0-9]{0,2}(,[0-9]{0,2})?)?} $data {}]]] eq "" } {
					break
				}
				set taglist [regexp -all -inline {\002|\003(?:[0-9]{0,2}(?:,[0-9]{0,2})?)?|\037|\026|\017} $new_part]
				# Etat des tags "au repos"; les -1 signifient que la couleur est celle par
				# défaut.
				set bold 0 ; set underline 0 ; set italic 0 ; set foreground_color "-1" ; set background_color "-1" 
				foreach tag $taglist {
					if {$tag eq ""} {
						continue
					}
					switch -- $tag {
						"\002" { if { !$bold } { set bold 1 } { set bold 0 } }
						"\037" { if { !$underline } { set underline 1 } { set underline 0 } }
						"\026" { if { !$italic } { set italic 1 } { set italic 0 } }
						"\017" { set bold 0 ; set underline 0 ; set italic 0 ; set foreground_color "-1" ; set background_color "-1" }
						default {
							lassign [split [regsub {\003([0-9]{0,2}(,[0-9]{0,2})?)?} $tag {\1}] ","] foreground_color background_color
							if {$foreground_color eq ""} {
								set foreground_color -1 ; set background_color -1
							} elseif {($foreground_color < 10) && ([::tcl::string::index $foreground_color 0] ne "0")} {
								set foreground_color 0$foreground_color
							}
							if {$background_color eq ""} {
								set background_color -1
							} elseif {
								($background_color < 10)
								&& ([::tcl::string::index $background_color 0] ne "0")
							} then {
								set background_color 0$background_color
							}
						}
					}
				}
				set line_start ""
				if {$bold} { append line_start \002 }
				if {$underline} { append line_start \037 }
				if {$italic} { append line_start \026 }
				if {($foreground_color != -1) && ($background_color == -1)} { append line_start \003$foreground_color }
				if {($foreground_color != -1) && ($background_color != -1)} { append line_start \003$foreground_color,$background_color }
				set data ${line_start}${data}
			}
			return $output
		}
	}
	
	######################################
	# proc for helping
	#
	# proc status
	proc help:status { nick host handle arg } {
		puthelp "PRIVMSG $nick :Chanrelay status for $::crelay::me(chan)@$::crelay::me(network)"
		puthelp "PRIVMSG $nick :\002 Global status\002"
		puthelp "PRIVMSG $nick :\037type\037   -- | trans -|- recept |"
		puthelp "PRIVMSG $nick :global -- | -- $::crelay::me(transmit) -- | -- $::crelay::me(receive) -- |"
		puthelp "PRIVMSG $nick :pub    -- | -- $::crelay::trans_pub -- | -- $::crelay::recv_pub -- |"
		puthelp "PRIVMSG $nick :act    -- | -- $::crelay::trans_act -- | -- $::crelay::recv_act -- |"
		puthelp "PRIVMSG $nick :nick   -- | -- $::crelay::trans_nick -- | -- $::crelay::recv_nick -- |"
		puthelp "PRIVMSG $nick :join   -- | -- $::crelay::trans_join -- | -- $::crelay::recv_join -- |"
		puthelp "PRIVMSG $nick :part   -- | -- $::crelay::trans_part -- | -- $::crelay::recv_part -- |"
		puthelp "PRIVMSG $nick :quit   -- | -- $::crelay::trans_quit -- | -- $::crelay::recv_quit -- |"
		puthelp "PRIVMSG $nick :topic  -- | -- $::crelay::trans_topic -- | -- $::crelay::recv_topic -- |"
		puthelp "PRIVMSG $nick :kick   -- | -- $::crelay::trans_kick -- | -- $::crelay::recv_kick -- |"
		puthelp "PRIVMSG $nick :mode   -- | -- $::crelay::trans_mode -- | -- $::crelay::recv_mode -- |"
		puthelp "PRIVMSG $nick :who    -- | -- $::crelay::trans_who -- | -- $::crelay::recv_who -- |"
		if { $::crelay::syn_topic == "y"} {
			puthelp "PRIVMSG $nick :Topic synchronisation is enable"
		} else {
			puthelp "PRIVMSG $nick :Topic synchronisation is disable"
		}
		puthelp "PRIVMSG $nick :nicks appears as $::crelay::hlnick$nick$::crelay::hlnick"
		puthelp "PRIVMSG $nick :\002 END of STATUS"
	}
		
	# proc help
	proc help:cmds { nick host handle arg } {
		puthelp "NOTICE $nick :/msg $::botnick trans <type> on|off to change the transmissions"
		puthelp "NOTICE $nick :/msg $::botnick recv <type> on|off to change the receptions"
		puthelp "NOTICE $nick :/msg $::botnick rc.status to see my actual status"
		puthelp "NOTICE $nick :/msg $::botnick rc.help for this help"
		puthelp "NOTICE $nick :/msg $::botnick rc.light <bo|un|off> to bold, underline or no higlight"
		puthelp "NOTICE $nick :/msg $::botnick rc.net <yes|no> to show the network"
		puthelp "NOTICE $nick :/msg $::botnick rc.syntopic <yes|no> to enable the topic synchronisation"
		puthelp "NOTICE $nick :/msg $::botnick rc.debug \[<yes|no>\] to enable the debug (no arg: display debug status)"
	}
	
	# Debug log
	proc dlog {text} {
		set out [open $::crelay::logfile a]
		puts $out "\[[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]\] <$::username> $text"
		close $out
	}
}

::crelay::init

putlog "CHANRELAY $::crelay::version by \002$::crelay::author\002 loaded - http://www.eggdrop.fr"
