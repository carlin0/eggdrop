
set asmsg {
   "!start"
   "!hint"
   "Oh là laaaa je suis fatigué"
   "je re , Smoke Time !!!"
   "!hint"
   "c'est fatiguant , d'être un robot Ouuuff!!!"
   "!stop"
   "!w rabat"
}

proc autospeak {min hour day month dow} {
   putserv "PRIVMSG #yourchan :[lindex $::asmsg [rand [llength $::asmsg]]]"
}

bind cron - "*/5 * * * *" autospeak

