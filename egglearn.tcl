#       EggLearn v 1.0 by Defcon7, from an idea of supergate
#


### Configurazione ###

#Trigger for adding records
set eglrn(add)  !add

#Trigger for deleting records
set eglrn(rem)  !rem

#Trigger for modifying records
set eglrn(modify) !modify

#Trigger for searching records
set eglrn(search) !findb

#Trigger to read the db size in bytes
set eglrn(dbsize) !db-size

#Trigger to read number of db lines
set eglrn(dblines) !db-lines

#Trigger for read records
set eglrn(define) !explain

#Trigger for manual database backup
set eglrn(dbbcktrigger) !backup

#Trigger to request the help
set eglrn(hlp) !help-db

#Who add records must be op ? 1|0 (Default 1)
set eglrn(addop) "0"

#Who modify records must be op ? 1|0 (Default 1)
set eglrn(modop) "0"

#Who remove records must be op ? 1|0 (Default 1)
set eglrn(remop) "0"

#Who search records in the database must be op ? 1|0 (Default 0)
set eglrn(srcop) "0"

#Who request the definition must be op ? 1|0 (Default 0)
set eglrn(defineop) "0"

#Who request the database size must be op ? 1|0 (Default 0)
set eglrn(dbsizeop) "0"

#Who request the database lines must be op ? 1|0 (Default 0)
set eglrn(dblinesop) "0"


#Flags, read the flags.html in this package for info about the flags meanings (its a copy of flags.html of eggdrop pkg ***ALL RIGHTS RESERVED***)
#To mean the flag global just type the flag (ex for global owner "n")
#To mean the flag for the channels type |flag (ex for channel owner "|n")
#To mean the flag for the channels or global type flag|flag (ex for global or local owner "n|n")


#Flag for adding (Default n)
set eglrn(addflag) o|o

#Flag for deleting (Default n)
set eglrn(remflag) o|o

#Flag for modifying (Default n)
set eglrn(modifyflag) o|o

#Flag for searching, this trigger is disabled by default because you can search also putting wildchars in the define trigger, like !explain *lp* (Default Z)
#To enable this change this inexistent flag to an existent
set eglrn(srcflag) -

#Flag for requesting definitions (Default -)
set eglrn(defineflag) -

#Flag for requesting the db size (Default -)
set eglrn(dbsizeflag) -

#Flag for requesting the number of definitions in the db (Default -)
set eglrn(dblinesflag) -

#Flag for database backup (Default n)
set eglrn(dbbckflag) n

#This is the max length of a record that users are able to put in the database, over this the bot will reply an error message (Default 128)
set eglrn(maxlength) 131

#This is the max number of records that search trigger can list, over this the bot will reply an error message. (Default 15)
set eglrn(maxrec) 11



#Dont edit below if you dont know what are you doing


bind pub $eglrn(addflag) $eglrn(add) reqs_analisys_add
bind pub $eglrn(remflag) $eglrn(rem) reqs_analisys_rem
bind pub $eglrn(srcflag) $eglrn(search) reqs_analisys_src
bind pub $eglrn(defineflag) $eglrn(define) reqs_analisys_define
bind pub $eglrn(dbsizeflag) $eglrn(dbsize) reqs_analisys_dbsize
bind pub $eglrn(dblinesflag) $eglrn(dblines) reqs_analisys_dblines
bind pub $eglrn(modifyflag) $eglrn(modify) reqs_analisys_modify
bind pub $eglrn(dbbckflag) $eglrn(dbbcktrigger) dbbck
bind pub - $eglrn(hlp) help


set eglrn(learndir) "[pwd]/EggLearn"
set eglrn(dbfile) "$eglrn(learndir)/define.db"
set eglrn(dbbackup) "$eglrn(learndir)/database.backup"
set eglrn(difference) ""
        if {![file exist EggLearn]} {
                global eglrn
                file mkdir EggLearn
                set chid [open $eglrn(dbfile) w+]
                close $chid
                putlog "hmm sembra la prima volta che usi EggLearn, creo $eglrn(learndir) e $eglrn(dbfile)"
        }



proc dbbck {nick uhost hand chan arg } {
        global eglrn
        file copy -force $eglrn(dbfile) $eglrn(dbbackup)
        putquick "privmsg $chan :Backup del database eseguito"
}



proc reqs_analisys_add { nick uhost hand chan arg } {
        global eglrn
        if {$eglrn(addop) == "1"} {
                if {[isop $nick $chan] == 1} {
                       set arg [string map [list \\ {\\}] $arg]
                       if {[string match {*\**} $arg]} {
		       		putquick "NOTICE $nick :hmm quante cose vuoi aggiungere ? NoNoNo..."
		       		return
		       } else { add_record $nick $uhost $hand $chan $arg }
                }
        } else {
		set arg [string map [list \\ {\\}] $arg]
                       if {[string match {*\**} $arg]} {
		       		putquick "NOTICE $nick :hmm quante cose vuoi aggiungere ? NoNoNo..."
		       		return
		       } else { add_record $nick $uhost $hand $chan $arg }

	}
}



proc reqs_analisys_rem { nick uhost hand chan arg } {
        global eglrn
        if {$eglrn(remop) == "1"} {
                if {[isop $nick $chan] == 1} {
                        set arg [string map [list \\ {\\}] $arg]
                        rem_record $nick $uhost $hand $chan $arg
                }
        } else {
		set arg [string map [list \\ {\\}] $arg]
		rem_record $nick $uhost $hand $chan $arg
	}
}


proc reqs_analisys_modify { nick uhost hand chan arg } {
        global eglrn
        if {$eglrn(modop) == "1"} {
                if {[isop $nick $chan] == 1} {
                        set arg [string map [list \\ {\\}] $arg]
                        modify_record $nick $uhost $hand $chan $arg
                }
        } else {
		set arg [string map [list \\ {\\}] $arg]
		modify_record $nick $uhost $hand $chan $arg
	}
}



proc reqs_analisys_src { nick uhost hand chan arg } {
        global eglrn
        if {$eglrn(srcop) == "1"} {
                if {[isop $nick $chan] == 1} {
                        set arg [string map [list \\ {\\}] $arg]
                        search_record $nick $uhost $hand $chan $arg
                }
        } else {
		set arg [string map [list \\ {\\}] $arg]
		search_record $nick $uhost $hand $chan $arg
	}
}


proc reqs_analisys_define { nick uhost hand chan arg } {
        global eglrn
        if {$eglrn(defineop) == "1"} {
                if {[isop $nick $chan] == 1} {
                        set arg [string map [list \\ {\\}] $arg]
                        define_object $nick $uhost $hand $chan $arg
                }
        } else {
		set arg [string map [list \\ {\\}] $arg]
		define_object $nick $uhost $hand $chan $arg
	}
}

proc reqs_analisys_dbsize { nick uhost hand chan arg } {
        global eglrn
        if {$eglrn(dbsizeop) == "1"} {
                if {[isop $nick $chan] == 1} {
                        dbsize $nick $uhost $hand $chan $arg
                }
        } else {dbsize $nick $uhost $hand $chan $arg}
}


proc reqs_analisys_dblines { nick uhost hand chan arg } {
        global eglrn
        if {$eglrn(dblinesop) == "1"} {
                if {[isop $nick $chan] == 1} {
                        dblines $nick $uhost $hand $chan $arg
                }
        } else {dblines $nick $uhost $hand $chan $arg}
}





proc add_record { nick uhost hand chan arg } {
        global eglrn 
        if {[string length [lrange $arg 0 end]] > $eglrn(maxlength) } {
                putquick "NOTICE $nick :Attenzione! La lunghezza massima delle descrizioni è impostata a $eglrn(maxlength) caratteri, contatta l'amministratore del bot per aumentarla o scrivi descrizioni piu' corte"
                return
        }
        set query [string tolower [lindex $arg 0]]
        set definition [lrange $arg 1 end]
        if { ($query != "") && ($definition != "")} {
                set chid [open $eglrn(dbfile) r+]
                set remav 0
                set recaad 0
                while {![eof $chid]} {
                        set line [gets $chid]
                        set first [lindex [split $line] 0]
                        set reclength [expr {[string length $query] + [string length $definition] + 1}]
                        if {$line == ""} {
                                break
                        } else {
                                if {$first == $query} {
                                        putquick "NOTICE $nick :Attenzione! questa descrizione e' gia' nel database usa $eglrn(modify) o $eglrn(rem) ($eglrn(hlp) per l'aiuto)"
                                        close $chid
                                        set recaad 1
                                        break
                                } else {
                                        if {[string match "ZXC*" $line]} {
                                                set position [tell $chid]
                                                set strlen [string length $line]
                                                set cposition [expr $position - $strlen -1]
                                                        if {$reclength <= $strlen} {
								set remav 1
                                                        }

                                        }
                                }
                        }

                }

        if {($remav == "1") && ($recaad == "0")} {
                seek $chid $cposition
                set out "$query $definition[string repeat "\ " [expr { $strlen - $reclength }]]"
                puts -nonewline $chid "$out"
                flush $chid
                close $chid
                putquick "Notice $nick :Definizione per $query aggiunta"
        } elseif {($remav == "0") && ($recaad == "0")} {
                close $chid
                set chid [open $eglrn(dbfile) a+]
                puts $chid "$query $definition"
                putquick "Notice $nick :Definizione per $query aggiunta"
                close $chid
        }



   } else { putquick "NOTICE $nick :Sintassi: $eglrn(add) voce definizione ($eglrn(hlp) per l'aiuto)"}



 }


proc define_object { nick uhost hand chan arg } {
        global eglrn
        set query [string tolower [lindex $arg 0]]
        set definition [lrange $arg 1 end]
        set argline [string trimright [ string trimleft [string tolower [lrange $arg 0 end]]]]
                if { $query != "" } {
                set chid [open $eglrn(dbfile) r+]
                set definitions "0"
                        while {![eof $chid]} {
                                set line [gets $chid]
                                set first [lindex [split $line] 0 ]
                                set second [lrange [split $line] 1 end]
                                set u [join $second]
                                set cleaned [string trimleft [string trimright $u]]
                                set remmatch [string match "ZXC*" $first]
                                        if {[string match "*\\**" [join [lrange $arg 0 end]]] || [string match "*\\?*" [join [lrange $arg 0 end]]] && ($remmatch != "1")} {
						search_record $nick $uhost $hand $chan $arg
						close $chid
						break

                                        } elseif {($query == $first) && ($definition == "")} {
                                                putquick "privmsg $chan :$cleaned"
                                                close $chid
                                                break

                                        } elseif {[string equal -nocase $argline $cleaned] && ($remmatch != "1")} {
                                                if {[llength $cleaned] > "1"} {
                                                        putquick "privmsg $chan :$first"
                                                        set definitions "1"
                                                        #close $chid
                                                        #break
                                                }
                                        } elseif {$line == ""} {
                                                if {$definitions == "0"} {
                                                        putquick "NOTICE $nick :Il database non contiene nessuna definizione che corrisponde a $query"
                                                        close $chid
                                                        break
                                                } else {
                                                        close $chid
                                                        break
                                        	}
                                         }
                                        }
                        } else {putquick "NOTICE $nick :Sintassi: $eglrn(define) voce ($eglrn(hlp) per l'aiuto)"}
}


proc rem_record { nick uhost hand chan arg } {
        global eglrn
        set query [string tolower [lindex $arg 0]]
                if {$query != ""} {
                        set chid [open $eglrn(dbfile) r+]
                                while {![eof $chid]} {
                                        set line [gets $chid]
                                        set first [lindex [split $line] 0 ]
                                                if {$first == $query} {
                                                        set position [tell $chid]
                                                        set strlen [string length $line]
                                                        set cposition [expr {$position - $strlen -1}]
                                                        seek $chid $cposition
                                                        puts -nonewline $chid "ZXC"
                                                        flush $chid
                                                        close $chid
                                                        putquick "NOTICE $nick :Okay definizione cancellata"
                                                        break
                                                } elseif { $line == ""} {
                                                        putquick "NOTICE $nick :Il database non contiene nessuna definizione che corrisponde a $query"
                                                        close $chid
                                                        break
                                                 }
                                                }
                } else {putquick "NOTICE $nick :Sintassi: $eglrn(rem) voce ($eglrn(hlp) per l'aiuto)"}
}


proc modify_record { nick uhost hand chan arg } {
        global eglrn
        set query [string tolower [lindex $arg 0]]
        set definition [lrange $arg 1 end]
                if { ($query != "") && ($definition != "") } {
                        set chid [open $eglrn(dbfile)]
                        	while {![eof $chid]} {
                                        set line [gets $chid]
                                        set first [lindex [split $line] 0 ]
                                        set second [lrange [split $line] 1 end]
                                                if {$first != ""} {
                                                        if {$first == $query} {
                                                                rem_record $nick $uhost $hand $chan $arg
                                                                utimer 1 [add_record $nick $uhost $hand $chan $arg]
                                                                close $chid
                                                                break
                                                        }

                                                } else {
                                                	putquick "NOTICE $nick :Il database non contiene nessuna definizione che corrisponde a $query"
                                                	close $chid
                                                        break
                                                }
                                }
                } else { putquick "NOTICE $nick :Sintassi: $eglrn(modify) voce definizione ($eglrn(hlp) per l'aiuto)"}

}


proc search_record { nick uhost hand chan arg } {
global eglrn
set query [lrange $arg 0 end]
if {$query != ""} {
	set chid [open $eglrn(dbfile) r]
	set i 0
	while {![eof $chid]} {
		set line [gets $chid]
		set line [string map [list \\ {\\}] $line]
		set starg [lindex $line 0]
		set ndarg [lrange $line 1 end]
		set remmatch [string match "ZXC*" $starg]
		set difnull [string match "" $line]
		if {[string match -nocase $query $starg] && ($remmatch != "1") && ($difnull != "1") || [string match -nocase $query $ndarg] && ($remmatch != "1") && ($difnull != "1") } {
				incr i
				lappend buffer $starg
				}
	}
	close $chid
if {$i > "0"} {
	if {$i <= $eglrn(maxrec)} {
		set buffer [join [string trim $buffer] ", "]
		set buffer [string map [list "\{" "" "\}" ""] $buffer]
		if {[llength $buffer] == 1 } {
                putquick "privmsg $chan :Trovate $i definizioni: $buffer"
		} else {putquick "privmsg $chan :Trovate $i definizioni: $buffer"}
	} else { putquick "privmsg $chan :$i definizioni trovate, massimo $eglrn(maxrec) definizioni, devi essere piu' specifico."}
} else {
	putquick "privmsg $chan :Il database non contiene nessuna definizione che corrisponde a $query"
	return
}
} else { putquick "NOTICE $nick :Sintassi: $eglrn(search) stringa ($eglrn(hlp) per l'aiuto)"}
}


proc dblines { nick uhost hand chan arg } {
        global eglrn
        set chid [open $eglrn(dbfile) r]
        set i 0
                while {![eof $chid]} {
                        incr i
                        set line [gets $chid]
                                if {$line == ""} {
                                        incr i -1
                                        putquick "privmsg $chan :Il database contiene $i voci"
                                        close $chid
                                        break
                                }
                }
}


proc dbsize { nick uhost hand chan arg } {
        global eglrn
        set size [file size $eglrn(dbfile)]
        putquick "privmsg $chan :Il database e' di $size bytes"
}

proc help {nick uhost hand chan arg} {
	global eglrn
        if {([matchattr $hand $eglrn(addflag) $chan]) || ([matchattr $hand $eglrn(addflag)]) || (($eglrn(addflag) == "-") && (($eglrn(addop) == [isop $nick $chan]) || $eglrn(addop) == "0")) } {putquick "privmsg $nick :Per aggiungere una voce digita $eglrn(add) voce definizione, es: $eglrn(add) Defcon7 EggLearn coder" ; set records 1 }
	if {([matchattr $hand $eglrn(remflag) $chan] || [matchattr $hand $eglrn(remflag)]) || (($eglrn(remflag) == "-") && (($eglrn(remop) == [isop $nick $chan]) || $eglrn(remop) == "0")) } {putquick "privmsg $nick :Per cancellare una voce digita $eglrn(rem) voce, es: $eglrn(rem) Defcon7" ; set records 1 }
	if {([matchattr $hand $eglrn(modifyflag) $chan] || [matchattr $hand $eglrn(modifyflag)]) || (($eglrn(modifyflag) == "-") && (($eglrn(modop) == [isop $nick $chan]) || $eglrn(modop) == "0")) } {putquick "privmsg $nick :Per modificare una voce digita $eglrn(modify) voce nuova definizione, es: $eglrn(modify) Defcon7 EggLearn creator" ; set records 1 }
	if {([matchattr $hand $eglrn(defineflag) $chan] || [matchattr $hand $eglrn(defineflag)]) || (($eglrn(defineflag) == "-") && (($eglrn(defineop) == [isop $nick $chan]) || $eglrn(defineop) == "0")) } {putquick "privmsg $nick :Per mostrare la definizione di una voce digita $eglrn(define) voce, es: $eglrn(define) Defcon7, puoi fare anche al contrario, es: $eglrn(define) egglearn creator , e il bot rispondera'  Defcon7" ; putquick "privmsg $nick :Se vuoi cercare usando caratteri jolly digita: $eglrn(define) *fcon*  e il bot rispondera' con una lista di voci che corrispondono a *fcon*" ; set records 1 }
	if {([matchattr $hand $eglrn(srcflag) $chan] || [matchattr $hand $eglrn(srcflag)]) || (($eglrn(srcflag) == "-") && (($eglrn(srcop) == [isop $nick $chan]) || $eglrn(srcop) == "0")) } {putquick "privmsg $nick :Per cercare una voce specifica digita $eglrn(search) record es: $eglrn(search) *fcon*" ; set records 1 }
	if {([matchattr $hand $eglrn(dbsizeflag) $chan] || [matchattr $hand $eglrn(dbsizeflag)]) || (($eglrn(dbsizeflag) == "-") && (($eglrn(dbsizeop) == [isop $nick $chan]) || $eglrn(dbsizeop) == "0")) } {putquick "privmsg $nick :Per vedere quanti bytes occupa il database digita $eglrn(dbsize)" ; set records 1 }
	if {([matchattr $hand $eglrn(dblinesflag) $chan] || [matchattr $hand $eglrn(dblinesflag)]) || (($eglrn(dblinesflag) == "-") && (($eglrn(dblinesop) == [isop $nick $chan]) || $eglrn(dblinesop) == "0")) } {putquick "privmsg $nick :Per vedere quante linee ci sono nel database digita $eglrn(dblines)" ; set records 1 }
	if {([matchattr $hand $eglrn(dbbckflag) $chan] || [matchattr $hand $eglrn(dbbckflag)]) || ($eglrn(dbbckflag) == "-")} {putquick "privmsg $nick :Per fare backup manualmente del database digita $eglrn(dbbcktrigger)" ; set records 1 }	
	if {$records == "1"} {putquick "privmsg $nick :Fine dei comandi di EggLearn utilizzabili"}
}



putlog "Loaded EggLearn v1.0 by Defcon7"

