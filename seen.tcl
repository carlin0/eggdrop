###
#Bass's Seen script.  v1.4.2c  2/2000 
#*!bass@*.psu.edu on Undernet.  Email: bass@tclslave.net or bass@mars.age.psu.edu
#This script maintains a database of *all* nicks seen online,
#not just those ppl who are in the userlist.  Simple flood 
#protection is built-in.  Wildcard searches are supported.
#
#Tradotto in italiano da `Daxeel   *Daxeel!*Olivaw@*   in  IRCnet
#
#L'imput e' accettato da:
#       pub:  !cerca <query> [#chan]
#       msg:  cerca <query> [#chan]
#   and dcc:  .cerca <query> [#chan]
#
#Le richieste possono essere nei seguenti formati (Ci sino anceh esempi pubblici):
#      'regolare' !cerca lamer; !seen lamest 			| SmartSearch-enabled query
#      'limitata' !cercanick lamer			       	| SmartSearch-bypassed query
# 'con maschera'  !cerca *l?mer*; !seen *.lame.com; !seen *.edu #mychan
#
#Possibilita' Bonus:  !zitto <nick>  
#    Puoi usare le wildcard in <nick>.  
#    La risposta riguardera' il primo trovato

###Parametri:

#bs(limit) e' il limite dei record nel database.  
set bs(limit) 15000

#bs(nicksize) e' la massima lunghezza del nick (9 su IRCnet)
set bs(nicksize) 16

#bs(no_pub) e' la lista del canali done tu  *NON* vuoi che il bot posti risposte
#   pubbliche (richieste pubbliche ignorate).  Immettere in minuscolo, es: #lamer
set bs(no_pub) "#ubuntu-it"

#bs(quiet_chan) e' la lista dei canali per i quali si vuole chela risposta   
#  sia mandata alla persona che ha fatto la richiesta via notice. (il bot risponde 
#  alla richiesta pubblica via notice). Immettere in minuscolo.
set bs(quiet_chan) "#ubuntu-it-chat"

#bs(no_log) e' la lista dei canali dei quali *NON* si vuole che il 
#  bot registri i dati.  Immettere i canali in minuscolo.
set bs(no_log) "#gente"

#bs(log_only) e' la lista dei *SOLI* canali dei quali si vuole che il bot
#  registri i dati E' il contrario di bs(no_log).  Settarlo a  ""  se si vuole che il
#  bot registri il log dei nuovi canali dove entra.  Immettere i canali in minuscolo.
set bs(log_only) ""

#bs(cmdchar) e' il carattere di comando pusato per fare le richieste pubbliche. 
#  Il default e' "!".  Settarlo a "" e' un'opzione valida.
set bs(cmdchar) "`"

#bs(flood) e' usato pe rla protezioen contro i flood, nella forma x:y.  Le richieste 
#  superiori a x in y secondi e' considerato un flood e ignorato.
set bs(flood) 4:30

#bs(ignore) e' usato come interruttore per ignorare i flooder (1=on)
set bs(ignore) 1

#bs(ignore_time) e' usato per definire quanto tempo un flooder rimane 
#  ignorato (minuti).  Non serve a nulla se bs(ignore) e' 0.
set bs(ignore_time) 5

#bs(smartsearch) Abilita/disabilita SmartSearch.  SmartSearch assicura che
#  vengano dati i risultati piu' accurati e aggiornati alle richieste. (1=on)
set bs(smartsearch) 1

#bs(logqueries) e' usato per loggare richieste DCC/MSG/PUB
set bs(logqueries) 1

#bs(path) e' usato per indicare quale path e' usato per salvare e fare i backup.  
#  Settarlo a  "" fa in modo che tutto sia salvato nella directory dell'eseguibile del bot
#  Se si setta assicurarsi che il path temini con uno slash (un "/").  
#  es:  set bs(path) "/usr/home/mydir/blah/"
set bs(path) "/home/carlin0/eggdrop/"

###### Don't edit below here, even if you do know Tcl ######


if {[bind msg -|- help] != "*msg:help"} {bind msg -|- help *msg:help} ; #this is to fix a bind I didn't intend to use in a prev version (which screwed up msg'd help).  Sorry!
proc bs_filt {data} {
  regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
  regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}
proc bs_flood_init {} {
  global bs bs_flood_array ; if {![string match *:* $bs(flood)]} {putlog "$bs(version): variabile bs(flood) non settata correttamente." ; return}
  set bs(flood_num) [lindex [split $bs(flood) :] 0] ; set bs(flood_time) [lindex [split $bs(flood) :] 1] ; set i [expr $bs(flood_num) - 1]
  while {$i >= 0} {set bs_flood_array($i) 0 ; incr i -1 ; }
} ; bs_flood_init
proc bs_flood {nick uhost} {
  global bs bs_flood_array ; if {$bs(flood_num) == 0} {return 0} ; set i [expr $bs(flood_num) - 1]
  while {$i >= 1} {set bs_flood_array($i) $bs_flood_array([expr $i - 1]) ; incr i -1} ; set bs_flood_array(0) [unixtime]
  if {[expr [unixtime] - $bs_flood_array([expr $bs(flood_num) - 1])] <= $bs(flood_time)} {
    putlog "$bs(version): Rilevato flood da parte di $nick." ; if {$bs(ignore)} {newignore [join [maskhost *!*[string trimleft $uhost ~]]] $bs(version) flood $bs(ignore_time)} ; return 1
  } {return 0}
}
if {[lsearch -exact [bind time -|- "*2 * * * *"] bs_timedsave] > -1} {unbind time -|- "*2 * * * *" bs_timedsave} ; #backup frequency can be lower
proc bs_read {} {
  global bs_list userfile bs
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
    set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0]
  }
  if {![file exists $bs(path)bs_data.$name]} {
    if {![file exists $bs(path)bs_data.$name.bak]} {
      putlog "     Database non trovato!" ; putlog "     Se questa e' la prima volta che lanci il tcl, non preoccuparti." ; putlog "     Se invece ci dovrebbe essere un file di dati da precedenti avvii dello script allora... preoccupati." ; return
    } {exec cp $bs(path)bs_data.$name.bak $bs(path)bs_data.$name ; putlog "     Database non trovato! Uso i dati di backup."}
  } ; set fd [open $bs(path)bs_data.$name r]
  set bsu_ver "" ; set break 0
  while {![eof $fd]} {
    set inp [gets $fd] ; if {[eof $fd]} {break} ; if {[string trim $inp " "] == ""} {continue}
    if {[string index $inp 0] == "#"} {set bsu_version [string trimleft $inp #] ; continue}
    if {![info exists bsu_version] || $bsu_version == "" || $bsu_version < $bs(updater)} {
      putlog "Aggiornamento database alla nuova versione dello script..."
#bugfix (b) - loading the wrong updater version
      if {[source scripts/bseen_updater1.4.2.tcl] != "ok"} {set temp 1} {set temp 0}
      if {$temp || [bsu_go] || [bsu_finish]} {
        putlog "Un serio problema e' stato trovato durante l'aggiornamento del database."
        if {$temp} {putlog "     Lo script di aggiornamento non e' stato trovato."}
        putlog "NON e' sicuro lanciare il bot con un database che non e' compatibile con questa versione della tcl."
        putlog "Se non trovi il problema, la sola cosa da fare e' cancellare i file bs_data.$name e bs_data.$name.bak files.  Fatto questo, riavviare il bot."
        putlog "Poiche' questo e' un possibile motivo di crash il bot adesso di fermera'." ; die "Errore nello script 'BSeen_IT_1.4.2'"
      } ; set break 1 ; break
    }
    set nick [lindex $inp 0] ; set bs_list([string tolower $nick]) $inp
  } ; close $fd
  if {$break} {bs_read} {putlog "     Caricamento effettuato, trovati [array size bs_list] record."}
}

###
#Must check to make sure the version didn't change during a .rehash
proc bs_update {} {
  global bs
  putlog "Una nuova versione dello script di ricerca e' stato trovato."
  putlog "    Sto verificando l'integrita' del database tra le versioni..."
  bs_save ; bs_read
}
set bs(updater) 10402 ; set bs(version) "bseen1.4.2c - Tradotto da `Daxeel"
if {[info exists bs_list]} {
#a rehash was done
  if {[info exists bs(oldver)]} {
    if {$bs(oldver) < $bs(updater)} {bs_update} ;# old ver found
  } {bs_update} ;# pre- 1.4.0
}
set bs(oldver) $bs(updater)
putlog "$bs(version):  -- Modulo CERCA caricato! --"
if {![info exists bs_list] || [array size bs_list] == 0} {putlog "     Caricamento del database..." ; bs_read}
###

bind time - "57 * * * *" bs_timedsave
proc bs_timedsave {min b c d e} {bs_save}
proc bs_save {} {
  global bs_list userfile bs ; if {[array size bs_list] == 0} {return}
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
    set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0]
  }
  if {[file exists $bs(path)bs_data.$name]} {catch {exec cp -f $bs(path)bs_data.$name $bs(path)bs_data.$name.bak}}
  set fd [open $bs(path)bs_data.$name w] ; set id [array startsearch bs_list] ; putlog "Sto salvando i dati del database..."
  puts $fd "#$bs(updater)"
  while {[array anymore bs_list $id]} {set item [array nextelement bs_list $id] ; puts $fd "$bs_list($item)"} ; array donesearch bs_list $id ; close $fd
}
#bugfix -- support new PART in egg1.5.x+
if {[string trimleft [lindex $version 1] 0] >= 1050000} {
  bind part -|- * bs_part  
} {
  if {[lsearch -exact [bind part -|- *] bs_part] > -1} {unbind part -|- * bs_part}
  bind part -|- * bs_part_oldver
}
proc bs_part_oldver {a b c d} {bs_part $a $b $c $d ""}
#bugfix - new bs_part proc
proc bs_part {nick uhost hand chan reason} {bs_add $nick "[list $uhost] [unixtime] part $chan [split $reason]"}
bind join -|- * bs_join
proc bs_join {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] join $chan"}
bind sign -|- * bs_sign
proc bs_sign {nick uhost hand chan reason} {bs_add $nick "[list $uhost] [unixtime] quit $chan [split $reason]"}
bind kick -|- * bs_kick
proc bs_kick {nick uhost hand chan knick reason} {bs_add $knick "[getchanhost $knick $chan] [unixtime] kick $chan [list $nick] [list $reason]"}
bind nick -|- * bs_nick
proc bs_nick {nick uhost hand chan newnick} {set time [unixtime] ; bs_add $nick "[list $uhost] [expr $time -1] nick $chan [list $newnick]" ; bs_add $newnick "[list $uhost] $time rnck $chan [list $nick]"}
bind splt -|- * bs_splt
proc bs_splt {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] splt $chan"}
bind rejn -|- * bs_rejn
proc bs_rejn {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] rejn $chan"}
bind chon -|- * bs_chon
proc bs_chon {hand idx} {foreach item [dcclist] {if {[lindex $item 3] != "CHAT"} {continue} ; if {[lindex $item 0] == $idx} {bs_add $hand "[lindex $item 2] [unixtime] chon" ; break}}}
if {[lsearch -exact [bind chof -|- *] bs_chof] > -1} {unbind chof -|- * bs_chof} ; #this bind isn't needed any more
bind chjn -|- * bs_chjn
proc bs_chjn {bot hand channum flag sock from} {bs_add $hand "[string trimleft $from ~] [unixtime] chjn $bot"}
bind chpt -|- * bs_chpt
proc bs_chpt {bot hand args} {set old [split [bs_search ? [string tolower $hand]]] ; if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]] [unixtime] chpt $bot"}}

if {[string trimleft [lindex $version 1] 0] > 1030000} {bind away -|- * bs_away}
proc bs_away {bot idx msg} {
  global botnet-nick
  if {$bot == ${botnet-nick}} {set hand [idx2hand $idx]} {return}
  set old [split [bs_search ? [string tolower $hand]]]
  if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]] [unixtime] away $bot [bs_filt [join $msg]]"}
}
bind dcc n|- cancella bs_unseen
proc bs_unseen {hand idx args} {
  global bs_list
  set tot 0 ; set chan [string tolower [lindex $args 0]] ; set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {incr tot ; lappend remlist $item}
  }
  array donesearch bs_list $id ; if {$tot > 0} {foreach item $remlist {unset bs_list($item)}}
  putlog "$hand ha rimosso $chan piazzetta dal database.  $tot record rimossi."
  putidx $idx "$chan rimosso con successo.  $tot record cancellati dal database."
}
bind bot -|- bs_botsearch bs_botsearch
proc bs_botsearch {from cmd args} {
  global botnick ; set args [join $args]
  set command [lindex $args 0] ; set target [lindex $args 1] ; set nick [lindex $args 2] ; set search [bs_filt [join [lrange $args 3 e]]]
  if {[string match *\\\** $search]} {
    set output [bs_seenmask bot $nick $search]
    if {$output != "No matches were found." && ![string match "I'm not on *" $output]} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick says:  [bs_filt $output]}"}
  } {
    set output [bs_output bot $nick [bs_filt [lindex $search 0]] 0]
    if {$output != 0 && [lrange [split $output] 1 4] != "I don't remember seeing"} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick says:  [bs_filt $output]}"}
  }
}
if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}
bind bot -|- bs_botsearch_reply bs_botsearch_reply
proc bs_botsearch_reply {from cmd args} {
  global bs ; set args [join $args]
  if {[lindex [lindex $args 2] 5] == "not" || [lindex [lindex $args 2] 4] == "not"} {return}
  if {![info exists bs(bot_delay)]} {
    set bs(bot_delay) on ; utimer 10 {if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}} 
    if {![lindex $args 0]} {putdcc [lindex $args 1] "[join [lindex $args 2]]"} {puthelp "[lindex $args 1] :[join [lindex $args 2]]"}
  }
}
bind dcc -|- cerca bs_dccreq1
bind dcc -|- cercanick bs_dccreq2
proc bs_dccreq1 {hand idx args} {bs_dccreq $hand $idx $args 0}
proc bs_dccreq2 {hand idx args} {bs_dccreq $hand $idx $args 1}
proc bs_dccreq {hand idx args no} {
  set args [bs_filt [join $args]] ; global bs
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask dcc $hand $args]
    if {$output == "No matches were found."} {putallbots "bs_botsearch 0 $idx $hand $args"}
    if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 0 $idx $hand $args"}
    putdcc $idx $output ; return $bs(logqueries)
  }
  set search [bs_filt [lindex $args 0]]
  set output [bs_output dcc $hand $search $no]
  if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "I don't remember seeing"} {putallbots "bs_botsearch 0 $idx $hand $args"}
  putdcc $idx "$output" ; return $bs(logqueries)
}
bind msg -|- cerca bs_msgreq1
bind msg -|- cercanick bs_msgreq2
proc bs_msgreq1 {nick uhost hand args} {bs_msgreq $nick $uhost $hand $args 0}
proc bs_msgreq2 {nick uhost hand args} {bs_msgreq $nick $uhost $hand $args 1}
proc bs_msgreq {nick uhost hand args no} { 
  if {[bs_flood $nick $uhost]} {return 0} ; global bs
  set args [bs_filt [join $args]]
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask msg $nick $args] 
    if {$output == "No matches were found."} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
    if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
    puthelp "notice $nick :$output" ; return $bs(logqueries)
  }
  set search [bs_filt [lindex $args 0]]
  set output [bs_output $search $nick $search $no]
  if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "I don't remember seeing"} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
  puthelp "notice $nick :$output" ; return $bs(logqueries)
}
bind pub -|- [string trim $bs(cmdchar)]cerca bs_pubreq1
bind pub -|- [string trim $bs(cmdchar)]cercanick bs_pubreq2
proc bs_pubreq1 {nick uhost hand chan args} {bs_pubreq $nick $uhost $hand $chan $args 0}
proc bs_pubreq2 {nick uhost hand chan args} {bs_pubreq $nick $uhost $hand $chan $args 1}
proc bs_pubreq {nick uhost hand chan args no} {
  if {[bs_flood $nick $uhost]} {return 0}
  global botnick bs ; set i 0 
  if {[lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0} {return 0}
  if {$bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1} {return 0}
  set args [bs_filt [join $args]]
  if {[lsearch -exact $bs(quiet_chan) [string tolower $chan]] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask $chan $hand $args]
    if {$output == "No matches were found."} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
    if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
    puthelp "$target :$output" ; return $bs(logqueries)
  }
  set data [bs_filt [string trimright [lindex $args 0] ?!.,]]
  if {[string tolower $nick] == [string tolower $data] } {puthelp "$target :$nick, se ti cerchi ti puoi trovare in uno specchio!" ; return $bs(logqueries)}
  if {[string tolower $data] == [string tolower $botnick] } {puthelp "$target :$nick... io ci sono!!! smettila di farmi perdere tempo!" ; return $bs(logqueries)}
  if {[onchan $data $chan]} {puthelp "$target :$nick, $data, se cerchi bene, e' qui!" ; return $bs(logqueries)}
  set output [bs_output $chan $nick $data $no] ; if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "I don't remember seeing"} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
  puthelp "$target :$output" ; return $bs(logqueries)
}
proc bs_output {chan nick data no} {
  global botnick bs version bs_list
  set data [string tolower [string trimright [lindex $data 0] ?!.,]]
  if {$data == ""} {return 0}
  if {[string tolower $nick] == $data} {return [concat $nick, se ti cerchi ti puoi trovare in uno specchio!]}
  if {$data == [string tolower $botnick]} {return [concat $nick... io ci sono!!! smettila di farmi perdere tempo!]}
  if {[string length $data] > $bs(nicksize)} {return 0} 
  if {$bs(smartsearch) != 1} {set no 1}
  if {$no == 0} {
    set matches "" ; set hand "" ; set addy ""
    if {[lsearch -exact [array names bs_list] $data] != "-1"} { 
      set addy [lindex $bs_list([string tolower $data]) 1] ; set hand [finduser $addy]
      foreach item [bs_seenmask dcc ? [maskhost $addy]] {if {[lsearch -exact $matches $item] == -1} {set matches "$matches $item"}}
    }
    if {[validuser $data]} {set hand $data}
    if {$hand != "*" && $hand != ""} {
      if {[string trimleft [lindex $version 1] 0]>1030000} {set hosts [getuser $hand hosts]} {set hosts [gethosts $hand]}
      foreach addr $hosts {
        foreach item [string tolower [bs_seenmask dcc ? $addr]] {
          if {[lsearch -exact [string tolower $matches] [string tolower $item]] == -1} {set matches [concat $matches $item]}
        }
      }
    }
    if {$matches != ""} {
      set matches [string trimleft $matches " "]
      set len [llength $matches]
      if {$len == 1} {return [bs_search $chan [lindex $matches 0]]}
      if {$len > 99} {return [concat ho trovato $len risposte alla tua domanda\; falla piu' precisa per vedere qualcosa.]}
      set matches [bs_sort $matches]
      set key [lindex $matches 0]
      if {[string tolower $key] == [string tolower $data]} {return [bs_search $chan $key]}
      if {$len <= 5} {
        set output [concat ho trovato $len risposte alla tua domanda (ordinate): [join $matches].]
        set output [concat $output  [bs_search $chan $key]] ; return $output
      } {
        set output [concat ho trovato $len risposte alla tua domanda.  Ecco le 5 piu' recenti (ordinate): [join [lrange $matches 0 4]].]
        set output [concat $output  [bs_search $chan $key]] ; return $output
      }
    }
  }
  set temp [bs_search $chan $data]
  if {$temp != 0} { return $temp } {
    #$data not found in $bs_list, so search userfile
    if {![validuser [bs_filt $data]] || [string trimleft [lindex $version 1] 0]<1030000} { 
      return "$nick, non ricordo di aver mai visto $data."
    } {
      set seen [getuser $data laston]
      if {[getuser $data laston] == ""} {return "$nick, non mi ricordo di aver mai visto $data."}
      if {($chan != [lindex $seen 1] || $chan == "bot" || $chan == "msg" || $chan == "dcc") && [validchan [lindex $seen 1]] && [lindex [channel info [lindex $seen 1]] 23] == "+secret"} {
        set chan "-secret-"
      } {
        set chan [lindex $seen 1]
      }
      return [concat $nick, $data e' stato/a visto/a in $chan [bs_when [lindex $seen 0]] fa.]
    }
  }
}
proc bs_search {chan n} {
  global bs_list ; if {![info exists bs_list]} {return 0}
  if {[lsearch -exact [array names bs_list] [string tolower $n]] != "-1"} { 
#bugfix:  let's see if the split added below fixes the eggdrop1.4.2 truncation bug
    set data [split $bs_list([string tolower $n])]
#bugfix: added a join on the $n  (c)
    set n [join [lindex $data 0]] ; set addy [lindex $data 1] ; set time [lindex $data 2] ; set marker 0
    if {([string tolower $chan] != [string tolower [lindex $data 4]] || $chan == "dcc" || $chan == "msg" || $chan == "bot") && [validchan [lindex $data 4]] && [lindex [channel info [lindex $data 4]] 23] == "+secret"} {
      set chan "-secret-"
    } {
      set chan [lindex $data 4]
    }
    switch -- [lindex $data 3] {
	part { 
        set reason [lrange $data 5 e]
        if {$reason == ""} {set reason "."} {set reason " dicendo \"$reason\"."}
        set output [concat $n ($addy) l'ho visto/a andarsene da $chan [bs_when $time] fa $reason] 
      }
	quit { set output [concat $n ($addy) l'ho visto/a andarsene da  $chan [bs_when $time] fa dicendo ([join [lrange $data 5 e]]).] }
	kick { set output [concat $n ($addy) se ne e' andato/a perche' kickato/a da $chan da parte di [lindex $data 5] [bs_when $time] fa per il motivo: ([join [lrange $data 6 e]]).] }
	rnck {
	  set output [concat $n ($addy) e' stato/a visto/a cambiare nick da [lindex $data 5] su [lindex $data 4] [bs_when $time] fa.] 
	  if {[validchan [lindex $data 4]]} {
	    if {[onchan $n [lindex $data 4]]} {
	      set output [concat $output  $n e' ancora qui.]
	    } {
	      set output [concat $output  comunque io adesso non vedo $n in $chan.]
	    }
	  }
	}
	nick { 
	  set output [concat $n ($addy) e' stato/a visto/a cambiare nick da [lindex $data 5] su [lindex $data 4] [bs_when $time] fa.] 
	}
	splt { set output [concat $n ($addy) e' stato/a visto/a uscire da $chan dopo uno scollegamento dei server [bs_when $time] fa.] }
	rejn { 
	  set output [concat $n ($addy) e' stato/a visto/a rientrare in $chan dopo uno scollegamento dei server [bs_when $time] fa.] 
	  if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output  $n is still on $chan.]} {set output [concat $output  comunque io adesso non vedo $n in $chan.]}}
	}
	join { 
	  set output [concat $n ($addy) e' stato/a visto/a entrare in $chan [bs_when $time] fa.]
	  if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output  $n e' ancora in $chan.]} {set output [concat $output  comunque io adesso non vedo $n in $chan.]}}
	}
	away {
	  set reason [lrange $data 5 e]
        if {$reason == ""} {
	    set output [concat $n ($addy) l'ho visto/a tornare alla partyline in $chan [bs_when $time] fa.]
	  } {
	    set output [concat $n ($addy) si e' messo in away perche' ($reason) in $chan [bs_when $time] fa.]
	  }
	}
	chon { 
	  set output [concat $n ($addy) l'ho visto/a entrare in partyline [bs_when $time] fa.] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline right now.] ; set marker 1 ; break}}
	  if {$marker == 0} {set output [concat $output  non vedo $n in partyline adesso.]}
	}
	chof { 
	  set output [concat $n ($addy) l'ho visto/a uscire dalla partyline [bs_when $time] fa.] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline in [lindex $item 1] still.] ; break}}
	}
	chjn { 
	  set output [concat $n ($addy) l'ho visto/a entrare in partyline in $chan [bs_when $time] fa.] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n e' in partyline in questo momento.] ; set marker 1 ; break}}
	  if {$marker == 0} {set output [concat $output  non vedo $n in partyline adesso.]}
	}
	chpt { 
	  set output [concat $n ($addy) l'ho visto/a lasciare la partyline da $chan [bs_when $time] fa.] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n e' ancora nella partyline in [lindex $item 1].] ; break}}
	}
	default {set output "error"}
    } ; return $output
  } {return 0}
}
proc bs_when {lasttime} {
  #This is equiv to mIRC's $duration() function
  set years 0 ; set days 0 ; set hours 0 ; set mins 0 ; set time [expr [unixtime] - $lasttime]
  if {$time < 60} {return "solo $time secondi"}
  if {$time >= 31536000} {set years [expr int([expr $time/31536000])] ; set time [expr $time - [expr 31536000*$years]]}
  if {$time >= 86400} {set days [expr int([expr $time/86400])] ; set time [expr $time - [expr 86400*$days]]}
  if {$time >= 3600} {set hours [expr int([expr $time/3600])] ; set time [expr $time - [expr 3600*$hours]]}
  if {$time >= 60} {set mins [expr int([expr $time/60])]}
  if {$years == 0} {set output ""} elseif {$years == 1} {set output "1 anno,"} {set output "$years anni,"}
  if {$days == 1} {lappend output "1 giorno,"} elseif {$days > 1} {lappend output "$days giorni,"}
  if {$hours == 1} {lappend output "1 ora,"} elseif {$hours > 1} {lappend output "$hours ore,"}
  if {$mins == 1} {lappend output "1 minuto"} elseif {$mins > 1} {lappend output "$mins minuti"}
  return [string trimright [join $output] ", "]
}
proc bs_add {nick data} {
  global bs_list bs
  if {[lsearch -exact $bs(no_log) [string tolower [lindex $data 3]]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower [lindex $data 3]]] == -1)} {return}
  set bs_list([string tolower $nick]) "[bs_filt $nick] $data"
}
bind time -  "*1 * * * *" bs_trim
proc bs_lsortcmd {a b} {global bs_list ; set a [lindex $bs_list([string tolower $a]) 2] ; set b [lindex $bs_list([string tolower $b]) 2] ; if {$a > $b} {return 1} elseif {$a < $b} {return -1} {return 0}}
proc bs_trim {min h d m y} {
  global bs bs_list ; if {![info exists bs_list] || ![array exists bs_list]} {return} ; set list [array names bs_list] ; set range [expr [llength $list] - $bs(limit) - 1] ; if {$range < 0} {return}
  set list [lsort -increasing -command bs_lsortcmd $list] ; foreach item [lrange $list 0 $range] {unset bs_list($item)}
}
proc bs_seenmask {ch nick args} {
  global bs_list bs ; set matches "" ; set temp "" ; set i 0 ; set args [join $args] ; set chan [lindex $args 1]
  if {$chan != "" && [string trimleft $chan #] != $chan} {
    if {![validchan $chan]} {return "Non sono in $chan."} {set chan [string tolower $chan]}
  } { set $chan "" }
  if {![info exists bs_list]} {return "Non ho trovato corrispondenze."} ; set data [bs_filt [string tolower [lindex $args 0]]]

#bugfix: unnecessarily complex masks essentially freeze the bot
  set maskfix 1
  while $maskfix {
    set mark 1
    if [regsub -all -- \\?\\? $data ? data] {set mark 0}
    if [regsub -all -- \\*\\* $data * data] {set mark 0}
    if [regsub -all -- \\*\\? $data * data] {set mark 0}
    if [regsub -all -- \\?\\* $data * data] {set mark 0}
    if $mark {break}
  }

  set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id] ; if {$item == ""} {continue} ; set i 0 ; set temp "" ; set match [lindex $bs_list($item) 0] ; set addy [lindex $bs_list($item) 1]
    if {[string match $data $item![string tolower $addy]]} {
      set match [bs_filt $match] ; if {$chan != ""} {
        if {[string match $chan [string tolower [lindex $bs_list($item) 4]]]} {set matches [concat $matches $match]}
      } {set matches [concat $matches $match]}
    }
  }
  array donesearch bs_list $id
  set matches [string trim $matches " "]
  if {$nick == "?"} {return [bs_filt $matches]}
  set len [llength $matches]
  if {$len == 0} {return "non ho risposte alla tua domanda."}
  if {$len == 1} {return [bs_output $ch $nick $matches 1]}
  if {$len > 99} {return "ho trovato $len risposte alla tua domanda; falla piu' precisa per sapere qualcosa."}
  set matches [bs_sort $matches]
  if {$len <= 5} {
    set output [concat ho trovato $len risposte alla tua domanda (ordinate): [join $matches].]
  } {
    set output "ho trovato $len risposte alla tua domanda. Ecco le 5 piu' recenti (ordinate): [join [lrange $matches 0 4]]."
  }
  return [concat $output [bs_output $ch $nick [lindex [split $matches] 0] 1]]
} 
proc bs_sort {data} {global bs_list ; set data [bs_filt [join [lsort -decreasing -command bs_lsortcmd $data]]] ; return $data}
bind dcc -|- stato bs_dccstats
proc bs_dccstats {hand idx args} {putdcc $idx "[bs_stats]"; return 1}
bind pub -|- [string trim $bs(cmdchar)]stato bs_pubstats
proc bs_pubstats {nick uhost hand chan args} {
  global bs ; if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) [string tolower $chan]] >= 0} {set target "notice $nick"} {set target "privmsg $chan"} ; puthelp "$target :[bs_stats]" ; return 1
}
bind msg -|- stato bs_msgstats
proc bs_msgstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[bs_stats]" ; return $bs(logqueries)}
proc bs_stats {} {
  global bs_list bs ; set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalm 0 ; set temp ""
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    set tok [lindex $bs_list($item) 2] ; if {$tok == ""} {putlog "Record danneggiato: $item" ; continuo}
    if {[lindex $bs_list($item) 2] < $bs_record} {set bs_record [lindex $bs_list($item) 2] ; set name $item}
    set addy [string tolower [maskhost [lindex $bs_list($item) 1]]] ; if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
  }
  array donesearch bs_list $id
  return "Attualmente sto tracciando [array size bs_list]/$bs(limit) nomi, che comprendono $totalm nomi unici.  Il piu' vecchio record e' di [lindex $bs_list($name) 0], ed e' di [bs_when $bs_record] fa."
}
bind dcc -|- statocanale bs_dccchanstats
proc bs_dccchanstats {hand idx args} {
  if {$args == "{}"} {set args [console $idx]}  
  if {[lindex $args 0] == "*"} {putdcc $idx "$hand, il comando chanstat richiede un argomento tipo #canale, o un canale valido in console." ; return 1}
  putdcc $idx "[bs_chanstats [lindex $args 0]]"
  return 1
}
bind pub -|- [string trim $bs(cmdchar)]statocanale bs_pubchanstats
proc bs_pubchanstats {nick uhost hand chan args} {
  global bs ; set chan [string tolower $chan]
  if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) $chan] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  if {[lindex $args 0] != ""} {set chan [lindex $args 0]} ; puthelp "$target :[bs_chanstats $chan]" ; return $bs(logqueries)
}
bind msg -|- statocanale bs_msgchanstats
proc bs_msgchanstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[bs_chanstats [lindex $args 0]]" ; return $bs(logqueries)}
proc bs_chanstats {chan} {
  global bs_list ; set chan [string tolower $chan] ; if {![validchan $chan]} {return "I'm not on $chan."}
  set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalc 0 ; set totalm 0 ; set temp ""
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id] ; set time [lindex $bs_list($item) 2] ; if {$time == ""} {continue}
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {
      if {$time < $bs_record} {set bs_record $time} ; incr totalc
      set addy [string tolower [maskhost [lindex $bs_list($item) 1]]]
      if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
    }
  }
  array donesearch bs_list $id ; set total [array size bs_list]
  return "da $chan ho il [expr 100*$totalc/$total]% ($totalc/$total) dei miei record di database. In $chan c'e un totale di $totalm nomi unici visti negli ultimi [bs_when $bs_record]."
}
foreach chan [string tolower [channels]] {if {![info exists bs_botidle($chan)]} {set bs_botidle($chan) [unixtime]}}
bind join -|- * bs_join_botidle
proc bs_join_botidle {nick uhost hand chan} {
  global bs_botidle botnick
  if {$nick == $botnick} {
   set bs_botidle([string tolower $chan]) [unixtime]
  }
}
bind pub -|- [string trim $bs(cmdchar)]zitto lastspoke

#bugfix: fixed lastspoke to handle [blah] nicks better (c)
proc lastspoke {nick uhost hand chan args} {
  global bs botnick bs_botidle
  set chan [string tolower $chan] ; if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) $chan] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) $chan] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  set data [lindex [bs_filt [join $args]] 0]
  set ldata [string tolower $data] 
  if {[string match *\** $data]} {
    set chanlist [string tolower [chanlist $chan]]
    if {[lsearch -glob $chanlist $ldata] > -1} {set data [lindex [chanlist $chan] [lsearch -glob $chanlist $ldata]]}
  }
  if {[onchan $data $chan]} { 
    if {$ldata == [string tolower $botnick]} {puthelp "$target :$nick, vuoi farmi perdere tempo?" ; return 1}
    set time [getchanidle $data $chan] ; set bottime [expr ([unixtime] - $bs_botidle($chan))/60]
    if {$time < $bottime} {
      if {$time > 0} {set diftime [bs_when [expr [unixtime] - $time*60 -15]]} {set diftime "meno di un minuto"}
      puthelp "$target :$data disse una parola in $chan $diftime fa."
    } {
      set diftime [bs_when $bs_botidle($chan)]
      puthelp "$target :$data Non ha parlato da quando entrai in $chan $diftime fa."
    }
  }
  return 1
} 
bind msgm -|- "help cerca" bs_help_msg_seen
bind msgm -|- "help statocanale" bs_help_msg_chanstats
bind msgm -|- "help stato" bs_help_msg_seenstats
proc bs_help_msg_seen {nick uhost hand args} {
  global bs ; if {[bs_flood $nick $uhost]} {return 0}
  puthelp "notice $nick :###  cerca <query> \[chan\]          $bs(version)"
  puthelp "notice $nick :  Le richieste posso essere fatte nei seguenti formati:"
  puthelp "notice $nick :    'regolare':  cerca `Daxeel; cerca Liga2LPD "
  puthelp "notice $nick :    'con maschera':   cerca *Da?eel*; cerca *.dax.com; cerca *.edison.it #piazzetta"; return 0
}
proc bs_help_msg_chanstats {nick uhost hand args} {
  global bs ; if {[bs_flood $nick $uhost]} {return 0}
  puthelp "notice $nick :###  statocanale <chan>          $bs(version)"
  puthelp "notice $nick :   Da' le statistiche di #chan nel database." ; return 0
}
proc bs_help_msg_seenstats {nick uhost hand args} {
  global bs ; if {[bs_flood $nick $uhost]} {return 0}
  puthelp "notice $nick :###  stato          $bs(version)"
  puthelp "notice $nick :   Da' lo stato del database." ; return 0
}
bind dcc -|- versione bs_version
proc bs_version {hand idx args} {global bs ; putidx $idx "###  Bass's Seen script, tradotto da `Daxeel, $bs(version)."}
bind dcc -|- help bs_help_dcc
proc bs_help_dcc {hand idx args} {
  global bs
  switch -- $args {
    cerca {
      putidx $idx "###  cerca <domanda> \[canale\]          $bs(version)" ; putidx $idx "   Le domande possono essere fatte nei seguenti formati:"
      putidx $idx "     'regolare':  cerca `Daxeel; cerca Liga2LPD " ; putidx $idx "     'con maschera':   cerca *Da?eel*; cerca *.dax.com; cerca *.it #piazzetta"
    }
    cercanick {putidx $idx "###  cerca <nick>          $bs(version)"}
    statocanale {putidx $idx "###  statocanale <chan>" ; putidx $idx "   Da' le statistiche di #chan nel database."}
    stato {putidx $idx "###  stato          $bs(version)" ; putidx $idx "   Da' lo stato del database."}
    cancella {if {[matchattr $hand n]} {putidx $idx "###  cancella <canale>          $bs(version)" ; putidx $idx "   Cancella tutti i dati di <canale> dal database."}}
    default {*dcc:help $hand $idx [join $args] ; return 0} 
  } ; return 1
}
