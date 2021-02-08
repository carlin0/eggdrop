# BotNet Commands v1.11 by: MrHat_

# Command:
#  DCC:
#   .botnet <whattodo> <args>:
#    <whattodo>: What you want the bots to do (duh! man, I'm saying that too much)
#                valid parameters: join, set, chanmode, part, say, act, rehash, save
#
#    <args>:     Arguments for what to do
#                valid parameters: at least a channel name. Some commands
#                (ie: say, act, set), this will be other text; instinct should
#                tell you what it should be; if you can't figure it out, then
#                "rm botnet-1.10.tcl" right now!

#   You need to be global +n to use this

proc botnetmsg_proc {handle idx args} {
 set args [lindex $args 0]
 set whattodo [lindex $args 0]
 set botmsg [lindex $args 1]
 switch -exact $whattodo {
  "join" {
   set channame [lindex $args 1]
   channel add $channame
  }
  "set" {
   set channame [lindex $args 1]
   set settings [lrange $args 2 end]
   foreach chanset [lrange $settings 0 end] {
    channel set $channame $chanset
   }
  }
  "chanmode" {
   set channame [lindex $args 1]
   set chanmode [lrange $args 2 end]
   channel set $channame chanmode $chanmode
  }
  "part" {
   set channame [lindex $args 1]
   channel remove $channame
  }
  "say" {
   set channame [lindex $args 1]
   set themsg [lrange $args 2 end]
   putserv "PRIVMSG $channame :$themsg"
  }
  "act" {
   set channame [lindex $args 1]
   set theact [lrange $args 2 end]
   putserv "PRIVMSG $channame :\001ACTION $theact\001"
  }
  "rehash" {
   rehash
  }
  "save" {
   save
  }
 }
 
 putallbots "botnet $args"

 return 1
}
 
proc botnet_proc {bot cmd args} {
 set args [lindex $args 0]
 set blah [lindex $args 0]
 switch -exact $blah {
  "join" {
   set channame [lindex $args 1]
   channel add $channame
   putlog "BotNet: $bot told me to join $channame"
  }
  "set" {
   set channame [lindex $args 1]
   set settings [lrange $args 2 end]
   foreach chanset [lrange $settings 0 end] {
    channel set $channame $chanset
   }
   putlog "BotNet: $bot told me to set $settings on $channame"
  }
  "chanmode" {
   set channame [lindex $args 1]
   set chanmode [lrange $args 2 end]
   channel set $channame chanmode $chanmode
   putlog "BotNet: $bot told me to keep channel mode $chanmode on $channame"
  }
  "part" {
   set channame [lindex $args 1]
   channel remove $channame
   putlog "BotNet: $bot told me to leave $channame"
  }
  "say" {
   set channame [lindex $args 1]
   set themsg [lrange $args 2 end]
   putserv "PRIVMSG $channame :$themsg"
   putlog "BotNet: $bot told me to say $themsg to $channame"
  }
  "act" {
   set channame [lindex $args 1]
   set theact [lrange $args 2 end]
   putserv "PRIVMSG $channame :\001ACTION $theact\001"
   putlog "BotNet: $bot told me to do action: $theact to $channame"
  }
  "rehash" {
   putlog "BotNet: $bot told me to rehash"
   rehash
  }
  "save" {
   putlog "BotNet: $bot told me to save"
   save
  }
 }
 return 1
}

bind bot - botnet botnet_proc
bind dcc +n botnet botnetmsg_proc
putlog "BotNet Commands v1.1 loaded"

