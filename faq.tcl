# Original Script (Diccionario.TCL) by BaRDaHL
#
# by ICU <icu@eggdrop-support.org> (#eggdrop.support @ irc.QuakeNet.org)
#
# Tradotta da Carlino carlin0@email.it  
#
#
# creates a file in your eggdrop-dir to store facts
# if you want to modify the faq-database status you need to have the +M flag
# to set this flag you just need to copy ".chattr <handle> +M" to the partyline
#
# The most current Version is available here: http://no-scrub.de/other/faq.tcl.zip
#
# Depending on your faq(cmdchar) setting prefix something other then a questionmark
# Depending on your faq(splitchar) settings use something other then a paragraph sign
#
# Public commands:
# ?faq-help - usage
# ? keyword - used to look up something from the db
# ?faq nick keyword - used to explain something(keyword) to someone(nick)
#
# Master commands:
# ?+parola keyword§definition - used to add something to the db
# ?-parola keyword - used to delete something from the db
# ?cambia  definition - used to modify a keyword in the db
# ?apri - opens the database if closed
# ?chiudi- closes the database if opened

########
# SETS #
########

# File will be created in your eggdrop dir unless you specify a path
# Ex. set faq(database) "/path/to/faqdatabase"
set faq(database) "faqdatabase"

# This char will be prefixed to all commands
set faq(cmdchar) "?"

# This char is used to split the keyword from the definition on irc commands and in the database.
# Note: § will not longer work on TCL 8.4+ for some strange reason.
set faq(splitchar) "|"

# This char is used to split multiple lines in your reply/definition.
# Note: § will not longer work on TCL 8.4+ for some strange reason.
set faq(newline) ";;"

# Global flag needed to use the FAQ Master commands
set faq(glob_flag) "o"

# Channel flag needed to use FAQ Master commands (empty means noone)
set faq(chan_flag) "o"

# Channels the FAQ is active on
set faq(channels) "#provazze #bannati" 

#################
# END OF CONFIG #
#################



##############
# STOP HERE! #
##############

# Initial Status of the Database (0 = open 1 = closed)
set faq(status) 0
# Current Version of the Database
set faq(version) "v2.10-Italiano"

#########
# BINDS #
#########

bind pub - "[string trim $faq(cmdchar)]" faq:explain_fact
bind pub - "[string trim $faq(cmdchar)]faq" faq:tell_fact
bind pub - "[string trim $faq(cmdchar)]+parola" faq:add_fact
bind pub - "[string trim $faq(cmdchar)]-parola" faq:delete_fact
bind pub - "[string trim $faq(cmdchar)]cambia" faq:modify_fact
bind pub - "[string trim $faq(cmdchar)]chiudi-faq" faq:close-faqdb
bind pub - "[string trim $faq(cmdchar)]apri-faq" faq:open-faqdb
bind pub - "[string trim $faq(cmdchar)]faq-help" faq:faq_howto

#########
# PROCS #
#########

proc faq:close-faqdb {nick idx handle channel args} {
 global faq
 if { [lsearch -exact [split [string tolower $faq(channels)]] [string tolower $channel]] < 0 } { 
  return 0
 }
 if {![matchattr $handle [string trim $faq(glob_flag)]|[string trim $faq(chan_flag)] $channel]} {
  putnotc $nick "Non puoi cambiare lo stato del faq-database."
  return 0
 }
 if {$faq(status)==0} {
  set faq(status) 1
  putnotc $nick "Il faq-database é stato \002chiuso correttamente\002."
  putnotc $nick "Ora nessuno può usare il comando '[string trim $faq(cmdchar)] parola_chiave'."
  putnotc $nick "Per aprire nuovamente il faq-database usa il comando '[string trim $faq(cmdchar)]apri-faq'."
  return 0
 }
 if {$faq(status)==1} {
  putnotc $nick "Il faq-database é \002già chiuso\002."
  return 0
 }
}

proc faq:open-faqdb {nick idx handle channel args} {
 global faq
 if { [lsearch -exact [split [string tolower $faq(channels)]] [string tolower $channel]] < 0 } {
  return 0
 }
 if {![matchattr $handle [string trim $faq(glob_flag)]|[string trim $faq(chan_flag)] $channel]} {
  putnotc $nick "Non puoi cambiare lo stato del faq-database."
  return 0
 }
 if {$faq(status)==1} {
  set faq(status) 0
  putnotc $nick "Il faq-database é stato \002correttamente aperto\002."
  putnotc $nick "Ora chiunque puo usare il comando '[string trim $faq(cmdchar)] \002parola_chiave\002'."
  putnotc $nick "Per chiudere nuovamente il faq-database usa il comando '[string trim $faq(cmdchar)]chiudi-faq'."
  return 0
 }
 if {$faq(status)==0} {
  putnotc $nick "Il faq-database é \002già aperto\002."
  return 0
 }
}


proc faq:explain_fact {nick idx handle channel args} {
 global faq
 if { [lsearch -exact [split [string tolower $faq(channels)]] [string tolower $channel]] < 0 } {
  return 0
 }
 if {$faq(status) == 1} { 
  putnotc $nick "Il faq-database é \002chiuso\002."
  return 0 
 }
 if {![file exist $faq(database)]} { 
  set database [open $faq(database) w]
  puts -nonewline $database ""
  close $database
 }
 set fact [ string trim [ string tolower [ join $args ] ] ]
 if {$fact == ""} {
#  putmsg $nick "Sintassi: [string trim $faq(cmdchar)] \002parola_chiave\002"
  return 0
 }
 set database [open $faq(database) r]
 set dbline ""
 while {![eof $database]} {
  gets $database dbline
  set dbfact [ string tolower [ lindex [split $dbline [string trim $faq(splitchar)]] 0 ]] 
  set dbdefinition [string range $dbline [expr [string length $fact]+1] end]
  if {$dbfact==$fact} {
    if {[string match -nocase "*$faq(newline)*" $dbdefinition]} {
      set out1 [lindex [split $dbdefinition $faq(newline)] 0]
      set out2 [string range $dbdefinition [expr [string length $out1]+2] end]
      putmsg $channel "\002$fact\002: $out1"
      putmsg $channel "\002$fact\002: $out2"
   } else { 
     putmsg $channel "\002$fact\002: $dbdefinition"
   }
   close $database
   return 0
  }
 }
 close $database
 putnotc $nick "Non so nulla di \002$fact\002."
 if {[matchattr $handle [string trim $faq(glob_flag)]|[string trim $faq(chan_flag)] $channel]} {
  putnotc $nick "Si puo aggiungere \002$fact\002 scrivendo [string trim $faq(cmdchar)]+parola \002$fact\002[string trim $faq(splitchar)]e qui la definizione."
 } else {
#  putnotc $nick "se cerchi delle TCL-Script prova qui http://www.egghelp.org/cgi-bin/tcl_archive.tcl?strings=$fact"
 }
 return 0
}

proc faq:tell_fact {nick idx handle channel args} {
 global faq
 if { [lsearch -exact [split [string tolower $faq(channels)]] [string tolower $channel]] < 0 } {
  return 0
 }
 if {$faq(status)==1} { 
  putnotc $nick "Il faq-database é \002chiuso\002."
  return 0 
 }
 if {![file exist $faq(database)]} { 
  set database [open $faq(database) w]
  puts -nonewline $database ""
  close $database
 }
 set tellnick [ lindex [split [join $args]] 0 ] 
 set fact [ string trim [ string tolower [ join [ lrange [split [join $args]] 1 end ] ] ] ]
 if {$tellnick == ""} { 
  putnotc $nick "Sintassi: [string trim $faq(cmdchar)]faq \002nick\002 parola_chiave"
  return 0 
 }
 if {$fact == ""} { 
  putnotc $nick "Sintassi: [string trim $faq(cmdchar)]faq nick \002parola_chiave\002"
  return 0
 }
 set database [open $faq(database) r]
 set dbline ""
 while {![eof $database]} {
  gets $database dbline
  set dbfact [ string tolower [ lindex [split $dbline [string trim $faq(splitchar)]] 0 ] ]
  set dbdefinition [string range $dbline [expr [string length $fact]+1] end]
  if {$dbfact==$fact} {
    if {[string match -nocase "*$faq(newline)*" $dbdefinition]} {
      set out1 [lindex [split $dbdefinition "$faq(newline)"] 0]
      set out2 [string range $dbdefinition [expr [string length $out1]+2] end]
      putmsg $channel "\002$tellnick\002: ($dbfact) $out1"
      putmsg $channel "\002$tellnick\002: ($dbfact) $out2"
    } else {
      putmsg $channel "\002$tellnick\002: ($dbfact) $dbdefinition"
    }
    putlog "FAQ: Mando la parola chiave \"\002$fact\002\" a $tellnick da parte di $nick ($idx)"
    close $database
    return 0
  }
 }
 close $database
 putnotc $nick "Non ho la parola_chiave \002$fact\002 nel mio database."
 if {[matchattr $handle [string trim $faq(glob_flag)]|[string trim $faq(chan_flag)] $channel]} {
  putnotc $nick "Si puo aggiungere \002$fact\002 scrivendo [string trim $faq(cmdchar)]+parola \002$fact\002[string trim $faq(splitchar)]e qui la definizione."
 } else {
#  putnotc $nick "Se tu cerchi delle TCL-Script prova su http://www.egghelp.org/cgi-bin/tcl_archive.tcl?strings=$fact"
 }
 return 0
}

proc faq:add_fact {nick idx handle channel args} {
 global faq
 if { [lsearch -exact [split [string tolower $faq(channels)]] [string tolower $channel]] < 0 } {
  return 0
 }
 if {$faq(status)==1} {
  putnotc $nick "Il faq-database é \002chiuso\002."
  return 0
 }
 if {![matchattr $handle [string trim $faq(glob_flag)]|[string trim $faq(chan_flag)] $channel]} {
	putnotc $nick "Non puoi aggiungere parole_chiave nel mio dababase."
  return 0
 }
 if {![file exist $faq(database)]} {
  set database [open $faq(database) w]
  puts -nonewline $database ""
  close $database
 }
 set fact [ string tolower [ lindex [split [join $args] [string trim $faq(splitchar)]] 0 ] ]
 set definition [string range [join $args] [expr [string length $fact]+1] end]  
 set database [open $faq(database) r]
 if {($fact=="")} {
  putnotc $nick "Mancano parametri."
  putnotc $nick "scrivi: [string trim $faq(cmdchar)]+parola \002parola_chiave\002[string trim $faq(splitchar)]definizione"
  return 0
 } elseif {($definition=="")} {
  putnotc $nick "Mancano parametri."
  putnotc $nick "scrivi: [string trim $faq(cmdchar)]+parola parola_chiave[string trim $faq(splitchar)]\002definizione\002"
  return 0
 }
 while {![eof $database]} {
  gets $database dbline
  set add_fact [ string tolower [ lindex [split $dbline [string trim $faq(splitchar)]] 0 ] ]
  if {$add_fact==$fact} {
   putnotc $nick "Questa parola_chiave é gia nel mio database:"
   putnotc $nick "é: \002$fact\002 - $definition"
   putnotc $nick "se vuoi cambiarla scrivi '[string trim $faq(cmdchar)]cambia $fact[string trim $faq(splitchar)]\002definizione\002'"
   close $database
   return 0
  }
 }
 close $database
 set database [open $faq(database) a]
 puts $database "$fact[string trim $faq(splitchar)]$definition"
 close $database
 putnotc $nick "La parola_chiave \002$fact\002 é stata aggiunta correttamente al mio database."
 putnotc $nick "Ora é: \002$fact\002 - $definition"
}

proc faq:delete_fact {nick idx handle channel args} {
 global faq
 if { [lsearch -exact [split [string tolower $faq(channels)]] [string tolower $channel]] < 0 } {
  return 0
 }
 if {$faq(status)==1} {
  putnotc $nick "Il faq-database é \002chiuso\002."
  return 0
 }
 if {![matchattr $handle [string trim $faq(glob_flag)]|[string trim $faq(chan_flag)] $channel]} {
  putnotc $nick "Non puoi cancellare le parole_chiave dal mio database."
  return 0
 }
 if {![file exist $faq(database)]} { 
  set database [open $faq(database) w]
  puts -nonewline $database ""
  close $database
 }
 set fact [string tolower [join $args]]
 if {($fact=="")} {
  putnotc $nick "Mancano parametri."
  putnotc $nick "scrivi: [string trim $faq(cmdchar)]-parola \002parola_chiave\002"
  return 0
 }
 set database [open $faq(database) r]
 set dbline ""
 set found 0
 while {![eof $database]} {
  gets $database dbline
  set dbfact [ string tolower [ lindex [split $dbline [string trim $faq(splitchar)]] 0 ] ]
  set dbdefinition [string range $dbline [expr [string length $fact]+1] end]
  if {$dbfact!=$fact} {
   lappend datalist $dbline
  } else {
   putnotc $nick "La parola_chiave \002$fact\002 é stata cancellata corrrettamente dal mio database."
   putnotc $nick "Era: \002$dbfact\002 - $dbdefinition"
   set found 1
  }
 }
 close $database
 set databaseout [open $faq(database) w]
 foreach line $datalist {
  if {$line!=""} {puts $databaseout $line}
 }
 close $databaseout
 if {$found != 1} {putnotc $nick "\002$fact\002 non trovata nel mio database."}
}

proc faq:modify_fact {nick idx handle channel args} {
 global faq
 if { [lsearch -exact [split [string tolower $faq(channels)]] [string tolower $channel]] < 0 } {
  return 0
 }
 if {$faq(status)==1} {
  putnotc $nick "Il faq-database é \002chiuso\002."
  return 0
 }
 if {![matchattr $handle [string trim $faq(glob_flag)]|[string trim $faq(chan_flag)] $channel]} {
  putnotc $nick "Non puoi modificare le parole_chiave nel mio database."
  return 0
 }
 if {![file exist $faq(database)]} { 
  set database [open $faq(database) w]
  puts -nonewline $database ""
  close $database
 }
 set fact [ string tolower [ lindex [split [join $args] [string trim $faq(splitchar)]] 0 ] ]
 set definition [string range [join $args] [expr [string length $fact]+1] end]
 set database [open $faq(database) r]
 if {($fact=="")} {
  putnotc $nick "Mancano parametri."
  putnotc $nick "Scrivi: [string trim $faq(cmdchar)]cambia \002parola_chiave\002[string trim $faq(splitchar)]definizione"
  return 0
 }
 if {($definition=="")} {
  putnotc $nick "Mancano parametri."
  putnotc $nick "Scrivi: [string trim $faq(cmdchar)]cambia parola_chiave[string trim $faq(splitchar)]\002definizione\002"
  return 0
 }
 set database [open $faq(database) r]
 set dbline ""
 set found 0
 while {![eof $database]} {
  gets $database dbline
  set dbfact [ string tolower [ lindex [split $dbline [string trim $faq(splitchar)]] 0 ] ]
  set dbdefinition [string range $dbline [expr [string length $fact]+1] end]
  if {$dbfact!=$fact} {
   lappend datalist $dbline
  } else {
   if {$dbdefinition!=$definition} {
    lappend datalist "$fact[string trim $faq(splitchar)]$definition"
    putnotc $nick "La parola_chiave \002$fact\002 é stata modificata correttamente nel mio database."
    putnotc $nick "Ora é: \002$fact\002 - $definition"
    putnotc $nick "Era: $dbfact - $dbdefinition"
    set found 1
   } else {
    lappend datalist $dbline
    putnotc $nick "E` già così \002$fact\002 non va modificata."
    putnotc $nick "E`: \002$fact\002 - $definition"
    set found 1
   }
  }
 }
 close $database
 set databaseout [open $faq(database) w]
 foreach line $datalist {
  if {$line!=""} {puts $databaseout $line}
 }
 close $databaseout
 if {$found != 1} {
  putnotc $nick "\002$fact\002 non trovata nel mio database"
  putnotc $nick "Se vuoi aggiungerla al database scrivi: [string trim $faq(cmdchar)]+parola $fact[string trim $faq(splitchar)]\002descrizione\002"
 }
}

proc faq:faq_howto {nick idx handle channel args} {
 global faq
 if { [lsearch -exact [split [string tolower $faq(channels)]] [string tolower $channel]] < 0 } {
  return 0
 }
 putnotc $nick "Elenco dei comandi per il FAQ Database $faq(version)"
 if {[matchattr $handle [string trim $faq(glob_flag)]|[string trim $faq(chan_flag)] $channel]} {
  if {$faq(status)==0} {
   putnotc $nick " - [string trim $faq(cmdchar)]chiudi-faq"
   putnotc $nick " - [string trim $faq(cmdchar)]+parola : [string trim $faq(cmdchar)]+parola \002parola_chiave\002[string trim $faq(splitchar)]la tua descrizione qui..."
   putnotc $nick " - [string trim $faq(cmdchar)]-parola : [string trim $faq(cmdchar)]-parola \002parola_chiave\002"
   putnotc $nick " - [string trim $faq(cmdchar)]cambia  : [string trim $faq(cmdchar)]cambia \002parola_chiave\002[string trim $faq(splitchar)]la nuova descrizione qui..."
  }
  if {$faq(status)==1} {
   putnotc $nick " - [string trim $faq(cmdchar)]apri-faq"
  }
 }
 if {$faq(status)==0} {
  putnotc $nick " - [string trim $faq(cmdchar)] \002parola_chiave\002 : cerca la parola nel database"
  putnotc $nick " - Per consentire al Bot di inviare la descrizione a qualcuno scrivi [string trim $faq(cmdchar)]faq nick \002parola_chiave\002"
 }
 if {$faq(status)==1} {
  putnotc $nick "Il faq-database é \002chiuso\002."
 }
}

#######
# LOG #
#######

putlog " FAQ-Database $faq(version) caricato "

#################
# END OF SCRIPT #
#################
