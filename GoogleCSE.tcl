if 0 {
	How could you get an API Key and cx Code?:
	Sign-in to your Google Account and goto
	https://console.developers.google.com/ to create a new project
	Give a name and add a description about it and goto;
	menu / APIs / APIs & auth you will see list of APIs there.
	select Custom Search API to enable it.
	then goto ; menu / credentials to create your API key.
	Select type as server, and enter your bot's / shell's IP into
	IPs section. then go in : https://www.google.com/cse/all

	You can add your links in there .(e.g www.google.com)
	to customize your search engine.
	When you are done, click to create at the bottom of that page,
	and you will see your cx code .(Search Engine ID) keep it and
	copy-paste with your API key in this script's settings.
	and, You are ready to go!

	This script requires Tcl 8.6 , tcllib ( 1.16 or above )
	tcl-tls newer than v1.6.4 , 1.7 preferably. and eggdrop v1.8
	( I always liked new, shiny things! )

	When you load this script, connect to your bot,
	telnet/dcc/ctcp chat, login in partyline and type;
	.chanset #channel +Gugil to enable in your #channel
}


namespace eval Gugil {

	proc Gug_init {} {
		variable GCSEres 5                      ;# how many results would like to see for each query?
		variable ApiKey {YOUR API KEY}          ;#  Google API key
		variable Gcx {YOUR CX CODE}             ;# Search Engine ID / cx Code
		variable EggPM 1                        ;# Do you also want to allow work this script in bot's PM ? 1 = yes , 0 = No
		variable Gcmds ".gugıl .gug"            ;# Whats gonna be the commands for this script. (you can add multiple with a space)
		variable Allowedflags "-"               ;# Who have permit to use this command? (eggdrop user flags)
		variable DaLimit "3:10"                                     ;# number:time (seconds) flood protection
		variable ignmsg "Just another Trump lover!"                 ;# ignore message
		variable igntime 1                      ;# ignore time in minutes ( 0 = permanent ignore )
		variable exflags "mnf|ao"               ;# exempt user flags ( global flags | channel flags )
		variable CSElink {https://www.googleapis.com/customsearch/v1}
		variable GtimeOut 16
		variable Gencode [encoding system]
		variable GuAgent "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
		variable GugLogo "12G4o8o12g3l4e"
		foreach Gugcmds [split $Gcmds { }] {
			bind pub $Allowedflags $Gugcmds [namespace current]::CSE_pubs
			if {$EggPM >= 1 && [string length $EggPM]} {
				bind msg $Allowedflags $Gugcmds [namespace current]::CSE_pubs
			}
		}
		putlog "[file tail [info script]] ok..."
	}
}

if {[package vcompare [package provide Tcl] 8.6] < 0} {
	putloglev o * "You got this : [info patchlevel]. But,\
		[file tail [info script]] wants one of Tcl 8.6 versions!"
}
package present Tcl 8.6
package require http 2.8
package require htmlparse 1.2
package require json 1.3
package require eggdrop 1.8

if {[catch {package require tls 1.6.4}]} {
	error "[file tail [info script]] requires tcl-tls => OpenSSL Tcl extension, for Google's secured https link!\
		will be better to get higher than 1.6.4 version these has been released later than heartbleed and poodle exploits!"
} elseif {[package vcompare [package present tls] 1.7] > 0} {
	::http::register https 443 [list ::tls::socket -autoservername 1]
} else {
	::http::register https 443 [list ::tls::socket -request 0 -require 1 -ssl2 0 -ssl3 0 -tls1 1 -tls1.1 1 -tls1.2 1]
}

setudef flag Gugil

namespace eval Gugil {

	proc CSE_pubs args {
		set kishi [lindex $args 0]
		expr {[string first # [lindex $args end-1]] ? [set target $kishi] : [set target [lindex $args end-1]]}
		if {[expr {[string first # $target] > -1}] && ![channel get $target Gugil]} { return 0 }
		if {![isbotnick $kishi] && ![matchattr [nick2hand $kishi] $Gugil::exflags $target]} {
			scan [lindex $args 1] {%[^@]@%[^ ]} id host
			if {![info exists ::trollol($kishi)] && ![info exists ::trollol($host)]} {
				array set ::trollol [list $host 1 $kishi [clock seconds]]
			} else {
				incr ::trollol($host)
			}
			if {([expr {[clock seconds] - $::trollol($kishi)}] <= [lindex [split $Gugil::DaLimit :] 1]) && ($::trollol($host) >= [lindex [split $Gugil::DaLimit :] 0])} {
				putserv "notice $kishi :${kishi}, I'm adding you into my ignores list for $Gugil::igntime minutes!"
				unset -nocomplain ::trollol($host) ::trollol($kishi)
				newignore [join [maskhost *![string trimleft [lindex $args 1] ~]]] $::botnick $Gugil::ignmsg $Gugil::igntime
				return 1
			}
			utimer [lindex [split $Gugil::DaLimit :] 1] [list unset -nocomplain ::trollol($host) ::trollol($kishi)]
		}
		set CSEQuery [stripcodes * [lindex $args end]]
		if {[llength $CSEQuery] < 1} {
			putserv "privmsg $target :Usage: $::lastbind <Search Term>"
			return 0
		}
		set GugilData [Gugil::GugilGet ${Gugil::CSElink}?[http::formatQuery\
			q $CSEQuery cx $Gugil::Gcx key $Gugil::ApiKey num $Gugil::GCSEres fields items(title,link,snippet),queries(request(totalResults,searchTerms))]]
		set GugTotal [lindex [lindex [Gugil::GDicts $GugilData queries request] 0] 1]
		set SearchTerm [lindex [lindex [Gugil::GDicts $GugilData queries request] 0] 3]
		if {$GugTotal == {0}} {
			putserv "privmsg $target :No any result found for $SearchTerm !"
			return
		} elseif {![dict exists $GugilData items]} {
			putserv "privmsg $target :I got an error while $CSEQuery query!"
			return
		} else {
			putserv "privmsg $target :$Gugil::GugLogo \002[Gugil::comma $GugTotal]\002 \00306results found for:\003 \" $SearchTerm \""
			for { set G 0 } { $G < $Gugil::GCSEres } { incr G } {
				set QRes [lindex [Gugil::GDicts $GugilData items] $G]
				set GResTitle [Gugil::GDicts $QRes title]
				set GReslinks [Gugil::GDicts $QRes link]
				set GResnip [Gugil::GDicts $QRes snippet]
				puthelp "privmsg $target :$GResTitle - [string map [list \n " "] $GResnip] : \026[Gugil::CSE_urlDecoder $GReslinks]\026"
			}
		}
	}

	proc GDicts {DictVar args} {
		if {[dict exists $DictVar {*}$args]} {
			return [dict get $DictVar {*}$args]
		} else {
			return -code error "Error! : Couldn't found: {*}$args keys!"
		}
	}

	proc CSE_urlDecoder sum {
		set Duh [subst -nocommands -novariables [regsub -all {%([a-fA-F0-9]{2})} $sum {\u\1}]]
		expr {$Gugil::Gencode eq "utf-8" ? [set GugDa [encoding convertfrom utf-8 $Duh]] : [set GugDa $Duh]}
		set GugDa
	}

	# http://wiki.tcl.tk/5000
	proc comma num {regsub -all -- {\d(?=(\d{3})+($|\.))} $num {\0,}}

	proc GugilGet url {
		::http::config -useragent $Gugil::GuAgent -urlencoding "utf-8"
		try { set token [http::geturl $url -binary 1 -timeout [expr {round(1000*${Gugil::GtimeOut})}]]
		} on error { err } {
			return -code error "Error: $err"
		} finally {
			if {[string equal -nocase ok [http::status $token]] && [http::ncode $token] == 200} {
				set page [http::data $token]
			} else {
				putcmdlog "[http::code $token] || [string map [list \n " "] [http::status $token]]"
			}
			catch { ::http::cleanup $token }
		}
		if {[info exists page] && [string length $page]} {
			expr {$Gugil::Gencode eq "utf-8" ? [set GugData [encoding convertfrom utf-8 $page]] : [set GugData $page]}
			return [json::json2dict [htmlparse::mapEscapes $GugData]]
		}
	}
	::Gugil::Gug_init
}

