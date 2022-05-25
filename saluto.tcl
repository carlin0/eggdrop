#**********#
# SETTINGS #
#**********#

# the onjoin flood settings.
set flood-join 3:70

# what channels the onjoin greet shall work on.
set onjoinchan "#italy #piemonte #provazze"

# want the greet to come out in notice (0) or privmsg (1)?
set howtell 1

set ver "v4.0"

#************************#
# DO NOT EDIT UNDERNEATH #
#************************#
putlog "saluto.tcl caricata ..."

bind join - * holm-join_greet
proc holm-join_greet {nick uhost hand channel args} {
global onjoinchan greet howtell
        if {(([lsearch -exact [string tolower $onjoinchan] [string tolower $channel]] != -1) || ($onjoinchan == "*"))} {
		if {$howtell} {
			putserv "privmsg $channel : Ciao $nick ..."
#			putserv "privmsg $channel : Ciao $nick , welcome $channel..."
		} else {
			putserv "notice $channel : Hi $nick , welcome to $channel..."
		}
	}
}
