####
#
# The script will ban all IPs which are in countries added to the blacklist.
# You can add both full name and/or countries shortcut.
#
# For enable the script: !country <on>/<off> or .chanset #channel +bcountry
# Add locations/countries: !country add <locatie> (Ex: US sau United States)
# List all blacklisted countries: !country list
# Remove countries from the blacklist: !country del <number> (from the blacklist)
# For informations: !country help
#
#+++ ATTENTION ++++ You must have 'package GeoIP' for the script to work.
#
# cd /usr/share/GeoIP
# wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
# gunzip GeoIP.dat.gz
# mv -v GeoIP.dat /usr/share/GeoIP/GeoIP.dat
#
###################################################################################

#Here set the predefined message ban
set blackcountry(breason) "A causa di problemi con cloni,flood e spam, tutti gli utenti %location% , sono bannati da questo canale."

#Here set the predefined time ban (minutes)
set blackcountry(btime) "180"

###################################################################################

bind pub mn|- !country blackcountry:cmd
bind join - * blackcountry:join
setudef flag bcountry
set blackcountry(file) "scripts/country_list.txt"


if {![file exists $blackcountry(file)]} {
	set file [open $blackcountry(file) w]
	close $file
}

proc blackcountry:cmd {nick host hand chan arg} {
	global blackcountry
	
	set arg0 [lindex [split $arg] 0]
	set arg1 [lindex [split $arg] 1]
if {$arg0 == ""} {
	putserv "NOTICE $nick : Usa: !country help per maggiori informazioni."
	return
}
switch $arg0 {

	on {
	channel set $chan +bcountry
	putserv "NOTICE $nick : BlackCountry attivo su $chan."
	}
	off {
	channel set $chan -bcountry
	putserv "NOTICE $nick : BlackCountry disattivato su $chan."
	}
	add {
if {$arg1 == ""} {
	putserv "NOTICE $nick : Usa: !country help per maggiori informazioni."
	return
}
	set file [open $blackcountry(file) a]
	puts $file "$chan $arg1"
	close $file
	putserv "NOTICE $nick : Ho aggiunto $arg1 alla blacklist."
	}

	list {
	set file [open $blackcountry(file) "r"]
	set read [read -nonewline $file]
	close $file
	set data [split $read "\n"]
	set i 0
if {$data == ""} { 
	putserv "NOTICE $nick : Non ci sono paesi aggiunti alla blacklist."
	return
}
	putserv "NOTICE $nick : La lista dei paesi aggiunti alla blacklist."
foreach line $data {
	set read_chan [lindex [split $line] 0]
if {[string match -nocase $read_chan $chan]} {
	set i [expr $i +1]
	set read_blackchan [lindex [split $line] 1]
	putserv "NOTICE $nick :$i.) $read_blackchan"
			}
		}
	}

	
	del {
	array set countrydel [list]
if {![regexp {^[0-9]} $arg1]} {
	putserv "NOTICE $nick : Usa: !country help per maggiori informazioni."
	return
}


set file [open $blackcountry(file) "r"]
	set data [read -nonewline $file]
	close $file
	set lines [split $data "\n"]
	set counter -1
	set line_counter -1
	set current_place -1
foreach line $lines {
	set line_counter [expr $line_counter + 1]
	set read_chan [lindex [split $line] 0]
if {[string match -nocase $read_chan $chan]} {
	set counter [expr $counter + 1]
	set countrydel($counter) $line_counter
	}
}

foreach place [array names countrydel] {
	if {$place == [expr $arg1 - 1]} {
	set current_place $countrydel($place)
	}
}

if {$current_place == "-1"} {
	putserv "NOTICE $nick : Il numero $arg1 non esiste."	
	return	
}

	set delete [lreplace $lines $current_place $current_place]
	set files [open $blackcountry(file) "w"]
	puts $files [join $delete "\n"]
	close $files
	set file [open $blackcountry(file) "r"]
	set data [read -nonewline $file]
	close $file
if {$data == ""} {
	set files [open $blackcountry(file) "w"]
	close $files
}
	putserv "NOTICE $nick : Il numero $arg1 è stato rimosso dalla blacklist."

	}

	help {
	putserv "NOTICE $nick : Per abilitare/disabilitare lo script usa: !country <on>/<off>"
	putserv "NOTICE $nick : Per aggiungere un paese usa: !country add <paese> (Es: US or United States)"
	putserv "NOTICE $nick : Per l'elenco dei paesi bannati usa: !country list"
	putserv "NOTICE $nick : Per levare un paese dalla lista usa: !country del <numero> (dalla blacklist)"
		}
	}
}


proc blackcountry:join {nick host hand chan } {
	global blackcountry

	set handle [nick2hand $nick]
	set hostname [lindex [split $host @] 1]

if {![validchan $chan]} { return }
if {![channel get $chan bcountry]} { return }
if {[isbotnick $nick]} { return }
if {![botisop $chan]} { return }
if {[string match -nocase "*undernet.org" $host]} { return}
if {[matchattr $handle "nm|oHPASMVO" $chan]} { return }


	set execution [exec geoiplookup $hostname]
	set execution [split $execution "\n"]
	set split_execution [split [lindex $execution 0] ","]
	set short_location [concat [string map {"GeoIP Country Edition:" "" "  " ""} [lindex $split_execution 0]]]
	set location [concat [lindex $split_execution 1]]

	set file [open $blackcountry(file) "r"]
	set read [read -nonewline $file]
	close $file
	set data [split $read "\n"]

foreach line $data {
	set read_chan [lindex $line 0]
	set read_location [lindex $line 1]

if {[string match -nocase $read_chan $chan]} {
if {[string equal -nocase $read_location $short_location] || [string match -nocase $read_location $location]} {

	set replace(%location%) $read_location
	set reason [string map [array get replace] $blackcountry(breason)]
	set banmask "*!*@[lindex [split $host @] 1]"
	newchanban $chan $banmask "BlackCountry" $reason $blackcountry(btime)
			}
		}
	}
}


putlog "Ban-Paese caricata."

