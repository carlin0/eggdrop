############################################################
# Domain/IP Whois by Sickness (v0.1)
#
# About:
# Uses WhoisXML from hexillion.com to retrieve whois information
#
# Notes:
# Thanks leprechau for finding the url ;)
#
# Requirements:
# TCL http lib
#############################################################

package require http

#Start config
#Script version
set whois(version) "0.1"
#Trigger you want to use
set whois(trigger) "!whois"
#Avaible in following channels (add as many channels as you wish to this list seperated by a space, leave # for all)
set Channels "#"
#End config

bind pub - $whois(trigger) whoisit_run

proc whoisit_run { nick uhost handle channel search } {
global Channels
	foreach chan $Channels {
		if {($chan == $channel) || ($chan == "#")} {
			if {[lindex $search 0] != ""} {
				if {[testip [lindex $search 0]]} {
					whoisit_whois [lindex $search 0] $channel
				} else {
					dnslookup [lindex $search 0] whoisit_getip $channel
				}
			} else {
				puthelp "PRIVMSG $channel :\[\002Whois\002\] Use: !whois <ip/hostname>"
			}
		}
	}
}

proc whoisit_whois { search chan } {
	# Validate IP
	if {([testip $search]) && ($search != "0.0.0.0")} {
	
		# Create URL
		set token [http::config -useragent "Mozilla"]
		set url "http://hexillion.com/samples/WhoisXML/?query=$search"
		
		# Retrieve info
		set token [http::geturl $url -timeout 15000]
		upvar #0 $token state
		if {$state(status) == "timeout" } {
			puthelp "PRIVMSG $chan :\[\002Whois\002\] The request timed out (try again)."
			return
		}
		set output [split [http::data $token] "\n"]
		http::cleanup $token	
		
		# Parse info
		set range ""
		set namec 0
		foreach line $output {
			if { [regexp {<IPRange>} $line] } {
				set range [whoisit_clearXML $line]
			}	
			if {([regexp {<Name>} $line]) || ([regexp {<Handle>} $line])} {
				if {$namec == 0} {
					incr namec
					set organisation [whoisit_clearXML $line]
				} elseif {$namec == 1}  {
					incr namec
					set netname [whoisit_clearXML $line]
				}
			}
			if { [regexp {<Country>} $line] } {
				set country [whoisit_clearXML $line]
			}
			if {([regexp {<AdminContact>} $line]) || ([regexp {<TechContact>} $line]) || ([regexp {<AbuseContact>} $line])} {
				break
			}
		}
		
		# Put to channel
		if {$range != ""} {
				puthelp "PRIVMSG $chan :\[\002Range\002\] $range"
				puthelp "PRIVMSG $chan :\[\002Netname\002\] $netname"
				puthelp "PRIVMSG $chan :\[\002Organisation\002\] $organisation"
				puthelp "PRIVMSG $chan :\[\002Country\002\] $country"
		} else {
			puthelp "PRIVMSG $chan :\[\002Whois\002\] No results."
		}
	} else {
		puthelp "PRIVMSG $chan :\[\002Whois\002\] Bad input (not a valid hostname or IP address)"
	}
}

proc whoisit_clearXML { input } {
	set input [string map {
		"<IPRange>" ""
		"</IPRange>" ""
		"<Name>" ""
		"</Name>" ""
		"<Handle>" ""
		"</Handle>" ""
		"<Country>" ""
		"</Country>" ""
		"&amp;" "&"
		"&#039;" "'"
		"        " ""
	} $input]
return $input
}

proc whoisit_getip { ipaddress hostname status chan } {
	whoisit_whois $ipaddress $chan
}

putlog "D/IP Whois v$whois(version) Loaded."

