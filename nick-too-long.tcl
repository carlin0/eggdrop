
set max_nick_len 15

bind join - * nick_join
bind nick - * nick_change

proc nick_join {nick uhost hand chan} {
  global max_nick_len
  if {[string length $nick] > $max_nick_len} { nick_punish $nick $chan }
}

proc nick_change {nick uhost hand chan newnick} {
  global max_nick_len
  if {[string length $newnick] > $max_nick_len} { nick_punish $newnick $chan }
}

proc nick_punish {nick chan} {
  global max_nick_len
  putserv "KICK $chan $nick :Hai un nick troppo lungo! Accorcialo con un massimo di $max_nick_len caratteri."
}

putlog "Loaded: The amazing nick length checker"
