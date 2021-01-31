
set max_nick_len 15

bind join - * nick_join
bind nick - * nick_change



proc nick_join {nick uhost hand chan} {
  global botnick max_nick_len
   if {![botisop $chan]} { return 0 }
   if [isbotnick $nick] { return 0 }
        if {[string length $nick] > $max_nick_len} {
        pushmode $chan +b [maskhost $uhost 2]
        putkick $chan $nick "Your nickname is too long! use $max_nick_len characters or less"
 }
}


proc nick_change {nick uhost hand chan newnick} {
    if {![botisop $chan]} { return 0 }
    if [isbotnick $newnick] { return 0 }
        nick_join $newnick $uhost $hand $chan
}
