### Set Bad Words that you want the Bot to Kick on
set badnicks { 
"*kazzo*"
"*kazz0*"
"*cazzo*"
"*cazz0*"
"*stronz*"
"*str0nz*"
"*coglion*"
"*c0glion*"
"*cogli0n*"
"*C0gli0n*"
"*bastard*"
"*puttan*"
"*mignott*"
"*mign0tt*"
"*ricchion*"
"*ricchi0n*"
"*rikkion*"
"*rikki0n*"
"*buttan*"
"*troia*"
"*tr0ia*"
"*froci*"
"*fr0ci*"
"*merd*"
}

### Set Your Ban Reason
set badnickreason "Cambia nick e torna ... /nick NuovoNick "

### Set Ban Time
set bnduration 24h

### Begin Script:

## Binding all joins to our Process
bind join - * filter_bad_nicks
bind nick - * filter_bad_nicks_change

## Starting Process
proc filter_bad_nicks {nick uhost hand channel} {
 global badnicks badnickreason banmask botnick bnduration
  set handle [nick2hand $nick]
   set banmask "*$nick*!*@*" 
	foreach badnick [string tolower $badnicks] {     
	if {[string match *$badnick* [string tolower $nick]]}  {
       if {[matchattr $handle +f]} {
           putlog "-Anti Bad Nick Script- $nick ($handle) with +f joined $channel"
       } elseif {[matchattr $handle +o]} {
           putlog "-Anti Bad Nick Script- $nick ($handle) with +o flags joined $channel"
       } else {
           putlog "-Anti Bad Nick Script- KICKED $nick on $channel"
           putquick "KICK $channel $nick :$badnickreason"
           newchanban $channel $banmask $botnick $badnickreason $bnduration
       }
    }
  }
}

## Starting Process
proc filter_bad_nicks_change {nick uhost hand channel newnick} {
 global badnicks badnickreason banmask botnick
  set handle [nick2hand $newnick]
   set banmask "*$newnick*!*@*" 
   set duration 10m
	foreach badnick [string tolower $badnicks] {     
	if {[string match *$badnick* [string tolower $newnick]]}  {
       if {[matchattr $handle +f]} {
           putlog "-Anti Bad Nick Script- $nick ($handle) with +f changed nickname to $newnick on $channel"
       } elseif {[matchattr $handle +o]} {
           putlog "-Anti Bad Nick Script- $nick ($handle) with +o flags changed nickname to $newnick on $channel"
       } else {
           putlog "-Anti Bad Nick Script- KICKED $newnick on $channel"
           putquick "KICK $channel $newnick :$badnickreason"
           newchanban $channel $banmask $botnick $badnickreason 2m
       }
    }
  }
}


bind join - * filter_bad_nicks
bind nick - * filter_bad_nicks_change
putlog " - Badnick Script Loaded - "