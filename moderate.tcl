#
#
### .chanset +moderate per attivare 

namespace eval moderate {

   setudef flag moderate

   bind cron - {0 0 * * *} [namespace current]::blocca
   bind cron - {0 7 * * *} [namespace current]::sblocca
   
   proc blocca {min hour day month weekday} {
      push "+m"
   }
   
   proc sblocca {min hour day month weekday} {
      push "-m"
   }
   
   proc push {m} {
      foreach chan [channels] {
         if {![channel get $chan moderate]} continue
         if {![botonchan $chan] || ![botisop $chan]} continue
         pushmode $chan $m
      }
   }
} 

putlog "+m la notte - LOADED!"

