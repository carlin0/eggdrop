
########################################################
## Earthquake Announcer  v1.2 by SpiKe^^   08/10/2017 ##
##   => All original script credits to speechles <=   ##
##   http://forum.egghelp.org/viewtopic.php?t=20350   ##
########################################################

# Earthquake .. rumble rumble rumble

# This script will announce earthquakes just like an rss script
# as well as allowing users to type commands and see
# the latest news via notice as well. Fully configurable.
# Enjoy, and may the force be with you.... always....

# speechles was here :P


########################################################
## Updated:                                           ##
##  -New page address & parsing regex (thanks thommey)##
##  -Now supports ssl page address (new page is https)##
########################################################
## Enable script per #channel, in partyline, use:     ##
##  .chanset #channel +earthquake                     ##
##                                                    ##
## Public and PrivateMessage commands:                ##
##  !eq     :Say the 5 most recent earthquake events  ##
##  !eq 4+  :Say the last 5 events M4.0 or larger     ## <- New Command <-
########################################################
## New feed reader code:                              ##
##   no longer misses events posted out-of-order!     ##
########################################################

package require http
package require tls
setudef flag earthquake

namespace eval eqnews {
   # config - make your changes here
   # trigger character
   set ary(pref) "!"

   # command used to reply to user
   # this can be a list of space delimited commands
   set ary(commands) "eq earthquake"

   # amount user can issue before throttle
   set ary(throttle) 2

   # throttle time
   set ary(throttle_time) 30

   # time to announce new news items
   # this can be a list of space delimited time binds.
   # the one you wish to use for bind_time uncommented.
   set ary(bind_time) "00* 15* 30* 45*" ; # every 15 minutes
   # set ary(bind_time) "00* 30*" ; # every 30 minutes
   # set ary(bind_time) "?0* ?5*" ; # every 5 minutes

   # url to news page  (all available feeds)
   #set ary(page) https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_day.atom ; # only significant
   #set ary(page) https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_day.atom ; # 4.5 and greater only
   #set ary(page) https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.atom ; # 2.5 and greater only
   #set ary(page) https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_day.atom ; # 1.0 and greater only
   #set ary(page) https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.atom ; # all
   set ary(page) https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.atom

   # minimum magnitude to show of quakes
   # everything equal to or above this magnitude
   # will be shown and this only affects the automation...
   # this should be larger than what is used in ary(page)
   set ary(magnitude) 4

   # max age (in minutes) of earthquakes to show      <- New Setting <-
   # this only affects the automation...
   # this should be 120 minutes or more  (def: 300)
   set ary(old) 300

   # parsing regex used to gather news
   set ary(regex) {<entry>.*?<title>(.*?)</title><updated>(.*?)</updated>.*?href="https://earthquake.usgs.gov/earthquakes/eventpage/(.*?)".*?<dt>Time</dt><dd>(.*?)</dd>}

   # max amount of news items to announce
   set ary(max_bot) 5

   # max amount of news items for users
   set ary(max_user) 5

   # display format for news messages, variables are: %mag, %title, %ago, %event 
   # these can be used and will be replaced with actual values, newline (\n) will
   # let you span multiple lines if you wish. If something is too long it will
   # be cut off, be aware of this... use colors, bold, but remember to \escape any
   # special tcl characters. 
   set ary(display_format) "\002USGS Earthquake\002: M\002%mag\002, %title (%ago ago) >> https://earthquake.usgs.gov/earthquakes/eventpage/%event"
}

# binds
foreach bind [split $::eqnews::ary(commands)] {
   bind pub -|- "$::eqnews::ary(pref)$bind" ::eqnews::pub_
   bind msg -|- "$::eqnews::ary(pref)$bind" ::eqnews::msg_
}
foreach bind [split $::eqnews::ary(bind_time)] {
   bind time - $bind ::eqnews::magic_
}
bind time - ?0* ::eqnews::throttleclean_

namespace eval eqnews {
   # script version
   set ary(version) "1.2"
   # main - time bind - magic
   proc magic_ {args} {
     news_ $::botnick "-" "-" "all" "-" "privmsg"
   }
   # main - msg bind - notice
   proc msg_ {nick uhost hand arg} {
     news_ $nick $uhost $hand $nick $arg "notice"
   }
   # main - pub bind - privmsg
   proc pub_ {nick uhost hand chan arg} {
     if {[channel get $chan earthquake]} {
       news_ $nick $uhost $hand $chan $arg "privmsg"
     }
   }

   # sub - give news
   proc news_ {nick uhost hand chan arg how} {
      if {![botonchan]} {  return  }
      if {[isbotnick $nick]} {  set magic 1  } else {  set magic 0  }
      if {$magic==0 && [throttle_ $uhost,$chan,news $::eqnews::ary(throttle_time)]} {
        putserv "$how $chan :$nick, you have been Throttled! Your going too fast and making my head spin!"
        return
      }
      set a "Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1"
      set t [::http::config -useragent $a]

      ::http::register https 443 [list ::tls::socket -tls1 1]  ;# added: plat_ #

      catch { set t [::http::geturl $::eqnews::ary(page) -timeout 30000] } error
      # error condition 1, socket error or other general error
      if {![string match -nocase "::http::*" $error]} {
        if {$magic==0} {
          putserv "$how $chan :[string totitle [string map {"\n" " | "} $error]] \( $::eqnews::ary(page) \)"
        }
        return
      }
      # error condition 2, http error
      if {![string equal -nocase [::http::status $t] "ok"]} {
        if {$magic==0} {
          putserv "$how $chan :[string totitle [::http::status $t]] \( $::eqnews::ary(page) \)"
        }
        return
      }

      set html [::http::data $t]
      ::http::cleanup $t

      # new feed reader code # added: SpiKe^^ # no longer misses events posted out-of-order! #
      set last 0 ; set events "" ; set min 0 ; set old 0
      set now [clock seconds]

      if {$magic==1} {  set max $::eqnews::ary(max_bot)
        set min $::eqnews::ary(magnitude)
        set old [expr {$now - ($::eqnews::ary(old) * 60)}]
        if {[info exists ::eqnews::ary(last)]} {
          set last $::eqnews::ary(last)  ;  set events $::eqnews::ary(events)
        }
      } else {  set max $::eqnews::ary(max_user)
        if {[string is double -strict [set arg [string trim $arg " +"]]]} {
          set min $arg
        }
      }

      set c 0  ;  set first 0

      foreach line [lrange [split $html "\n"] 1 end] {

        if {[regexp -- "$::eqnews::ary(regex)" $line x title posted event etime]} {
          #putlog "=> ($title) ($posted) ($event) ($etime)"
          # => (M 4.5 - 74km SSE of Phek, India) (2017-10-03T15:01:03.040Z) (us2000b0gm) (2017-10-03 13:48:34 UTC)
          set posted [string map [list "T" " "] [lindex [split $posted .] 0]]
          set postid [clock scan "$posted UTC"]
          if {$first==0} {  set first $postid  }
          set id [clock scan $etime]
          if {$id<$old} {  break  }
          set mag [lindex [split $title] 1]
          if {$mag<$min || $postid<=$last || [lsearch -exact $events $event]>-1} {
            continue
          }
          set etime [string trimright $etime " UTC"]
          set title [mapit_ [string trim [join [lrange [split $title -] 1 end] -]]]
          set dur [duration [expr {$now - $id}]]
          if {[llength [set x [split $dur]]]>4 && [string match "sec*" [lindex $x end]]} {
            set dur [join [lrange $x 0 end-2]]
          }
          set map [list "%mag" $mag "%title" $title "%ago" $dur "%event" $event]
          set output [string map $map $::eqnews::ary(display_format)]
          if {$magic==0} {
            foreach line [split $output "\n"] {  puthelp "$how $chan :$line"  }
          } else {
            foreach ch [channels] {
              if {[channel get $ch earthquake]} {
                foreach line [split $output "\n"] { puthelp "$how $ch :$line" }
              }
            }
            lappend events $event
          }
          if {[incr c] == $max} {  break  }
        }
      }

      if {$magic==1 && $first>0} {  set ::eqnews::ary(last) $first  }
      if {[llength $events]} {  set ::eqnews::ary(events) [lrange $events end-39 end]  }
   }

   # sub - map it
   proc mapit_ {t} { return [string map [list "'" "'" "&quot;" "\""] $t] }

   # Throttle Proc (slightly altered, super action missles) - Thanks to user
   # see this post: http://forum.egghelp.org/viewtopic.php?t=9009&start=3
   proc throttle_ {id seconds} {
      if {[info exists ::eqnews::throttle($id)]&&[lindex $::eqnews::throttle($id) 0]>[clock seconds]} {
         set ::eqnews::throttle($id) [list [lindex $::eqnews::throttle($id) 0] [set value [expr {[lindex $::eqnews::throttle($id) 1] +1}]]]
         if {$value > $::eqnews::ary(throttle)} { set id 1 } { set id 0 }
      } {
         set ::eqnews::throttle($id) [list [expr {[clock seconds]+$seconds}] 1]
         set id 0
      }
   }
   # sub - clean throttled users
   proc throttleclean_ {args} {
      set now [clock seconds]
      foreach {id time} [array get ::eqnews::throttle] {
         if {[lindex $time 0]<=$now} {unset ::eqnews::throttle($id)}
      }
   }
}

putlog "Earthquake Announcer v$::eqnews::ary(version) loaded."

