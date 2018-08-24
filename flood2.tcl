## (A): CONFIG

# If you need to include the channel or the nick in a message, they must be typed in this way: \$nick or \$chan  <-- remember it!

# Should the script work on all chans?
# Valid settings are; 1:yes, 0:no
set chanpro(all) 1

# If no, which channels should the script work on?
# Separate channels with a space
set chanpro(chans) "#provazze #yourchan #ourchan"

# Which parts of the script do you wish to activate?
# Valid settings are; 0:off, 1:on.
set chanpro(protect_ops) 1        	   ;#If on, the bot will NOT kick/ban ops (chan status AND bot flags)
set chanpro(underline) 0   	  	   ;#Turn on/off underline-check
set chanpro(bold) 0        	  	   ;#Turn on/off bold-check
set chanpro(caps) 1       	  	   ;#Turn on/off CAPS-check
set chanpro(color) 0      	  	   ;#Turn on/off color-check
set chanpro(notice) 0       	  	   ;#Turn on/off ChanNotice check (does not trigger on OPnotice..(/notice @#chan blabla))
set chanpro(annoy) 0              	   ;#Turn on/off annoy-check
set chanpro(longword) 0		   	   ;#Turn on/off the check for loooong words
set chanpro(pubaway) 0			   ;#Turn on/off public-away-check
set chanpro(mp3) 0			   ;#Turn on/off mp3-thingie-check
set chanpro(warnings) 0		    	   ;#If on, the OPs who violate the rules while protectOPs is on, will get a warning
set chanpro(quit) 0		   	   ;#Turn on/off checking for annoyance in quit/part msgs

# Some various settings
# Use only numerical values
set chanpro(caps_minimum) 15  	   	   ;#Minimum lenght of the string, before it gets checked for CAPS
set chanpro(caps_percent) 53 	   	   ;#Minimum percentage of CAPS before kicking
set chanpro(remember) 1      	  	   ;#Time in hrs to remember the person (from the last offence), clear it after that
set chanpro(annoy_length) 5       	   ;#Length of continuous-chars to count as an annoying act. ????? / ?!?!? / ?!!!? / !!!!! etc..
set chanpro(annoy_percent) 50	  	   ;#Minimum percentage of annoy before prosessing. hi??! my!!! name??? is???!
set chanpro(annoy_minimum) 10	  	   ;#Minimum length of the string, before it gets matched for percentage of annoy
set chanpro(longword_length) 50		   ;#Minimum length (chars) of long-words to trigger on (exceptions are set later on)

# In which order should we handle offences?
# Valid settings are: 
# 1: WARN
# 2: KICK
# 3: BAN
# 4: WARN > KICK
# 5: WARN > BAN
# 6: KICK > BAN 
# 7: WARN > KICK > BAN
set chanpro(todo_underline) 1		   ;#Actions to take when someone writes text with underlined characters
set chanpro(todo_bold) 1		   ;#Actions to take when someone writes text with bold characters
set chanpro(todo_caps) 7		   ;#Actions to take when someone overuses uppercase characters
set chanpro(todo_color)	1		   ;#Actions to take when someone uses colors
set chanpro(todo_notice) 1		   ;#Actions to take when someone sends a channel-notice
set chanpro(todo_annoy)	1		   ;#Actions to take when someone is 'annoying'
set chanpro(todo_longword) 1		   ;#Actions to take when someone uses loooong words
set chanpro(todo_pubaway) 1		   ;#Actions to take when someone uses public-away
set chanpro(todo_mp3) 1			   ;#Actions to take when someone uses mp3-stuff

# How should we handle bans, i.e. how should we parse the hostmasks?
# Valid settings are:
# 1: *!*user@host.domain
# 2: *!*user@*.domain
# 3: *!*@host.domain
# 4: *!user@host.domain
# 5: *!user@*.domain
# 6: Let chanpro.tcl choose how to parse the hostmask, by looking for sertain values in the mask. 
#    Anyway, the result will be one of the following banmasks (regular, IP, Undernet username);
#    *!*user@*.domain, *!*user@127.0.* or *!*@username.users.undernet.org
set chanpro(bmask) 3

# Which triggers should we have for the public-away-check?
# Follow the list-pattern.. ("string1" "string2" "string3" ..)
set chanpro(trig_pubaway) {
"*is away*" "*is back*" "*away*(*)*" "*is*back*"
}

# Which triggers should we have for the mp3-thingy?
# Follow the list-pattern.. ("string1" "string2" "string3" ..)
set chanpro(trig_mp3) {
"*play*mp3*" "*listen*to*-*" "*min*sec*bps*" "*-*AMIP*"
}

# Which patterns should the long-word check not trigger on?
# This can be programming syntaxes, etc.. follow the list pattern.. ("string1" "string2" "string3" ..)
set chanpro(not_trig_longword) {
"*_root*" "*{*}" "*[*]*" "*www.*" "*http://*" "*regexp*" "*regsub*"
"*preg_replace(*)*" "*<*>*<*>*" "*=*&*=*"
}

# Ban length
# Use only numerical values
set chanpro(ban_time_caps) 0      	   ;#Time in minutes to ban for allCAPS
set chanpro(ban_time_bold) 0      	   ;#Time in minutes to ban for bold
set chanpro(ban_time_underline) 0 	   ;#Time in minutes to ban for underline
set chanpro(ban_time_color) 0      	   ;#Time in minutes to ban for use of color
set chanpro(ban_time_notice) 0       	   ;#Time in minutes to ban for ChanNotice
set chanpro(ban_time_annoy) 0        	   ;#Time in minutes to ban for annoy
set chanpro(ban_time_longword) 0	   ;#Time in minutes to ban for longwords
set chanpro(ban_time_pubaway) 0            ;#Time in minutes to ban for public-away
set chanpro(ban_time_mp3) 0		   ;#Time in minutes to ban for using mp3-stuff
set chanpro(ban_time_quit_color) 0	   ;#Time in hrs to ban for colorful quit/part msgs
set chanpro(ban_time_quit_underline) 0     ;#Time in hrs to ban for underlined quit/part msgs
set chanpro(ban_time_quit_bold) 0   	   ;#Time in hrs to ban for bold quit/part msgs

# OP warnings
# These settings will only apply if protect_ops is enabled
set chanpro(op_method)      	"notice \$nick"       ;#choose between "privmsg \$chan" and "notice \$nick"
set chanpro(op_bold)        	"Disattiva il CAPS"
set chanpro(op_underline)   	"Loose that underline lamer.."
set chanpro(op_caps)        	"Wow! You really know how to shout very loudly.. teachme, teachme!"
set chanpro(op_color)       	"Ach! I'm going blind.. look at those colors.."
set chanpro(op_notice)      	"ChannelNotice sure does suck - dont do it again.."
set chanpro(op_annoy)       	"That sure was annoying.. dont do it again!"
set chanpro(op_longword)	"Dude, where did you learn to write??"
set chanpro(op_pubaway)		"We really dont care wheter you're here or not dude"
set chanpro(op_mp3)		"We dont care what you listen to dude!"

# Regular warnings
# Use \$nick and \$chan to include Nickname and #channel
set chanpro(warning_method) 	"privmsg \$chan"      ;#choose between "privmsg \$chan" and "notice \$nick"
set chanpro(warn_caps)          "!caps | \$nick"
set chanpro(warn_bold)      	"No bold characters allowed in \$chan \$nick!"
set chanpro(warn_underline)	"No underlined characters allowed in \$chan \$nick!"
set chanpro(warn_notice)        "\$nick: channelnotice sucks so multiple ass, please stop it right away!"
set chanpro(warn_color)         "\$nick: that sertainly sucked, dont do it again!"
set chanpro(warn_annoy)     	"\$nick: excessive lameness usually leads to a kick you know.. (reckless use of ? and/or !)"
set chanpro(warn_longword)	"\$nick: that was really annoying!"
set chanpro(warn_pubaway)	"Loose the publick-away \$nick! First and only warning.."
set chanpro(warn_mp3)		"Newsflash \$nick; we DONT care what music you're playing!"

# Kick messages
# Use \$nick and \$chan to include Nickname and #channel
set chanpro(kick_caps)      	"Ti avevo avvisato"
set chanpro(kick_bold)      	"If you feel the need to express yourself in bold, go somewhere else"
set chanpro(kick_underline) 	"Wow! that underline does indeed suck very much thank you.."
set chanpro(kick_notice)        "Go fuck yourself! ..and yes, that notice sucked"
set chanpro(kick_color)     	"Yes, we love those colors spank you very much.."
set chanpro(kick_annoy)         "Lamer removed due to vote"
set chanpro(kick_longword)	"watch that sucker going dooooooooown"
set chanpro(kick_pubaway)	"NOW you're away.."
set chanpro(kick_mp3)		"Ahh, the silence.."

# Ban messages
# Use \$nick and \$chan to include Nickname and #channel
set chanpro(ban_caps)           "Visto che proprio insisti ..."
set chanpro(ban_bold)           "I tire of your company. Begone!"
set chanpro(ban_underline)      "\037Underline\037 this asswipe!"
set chanpro(ban_color)          "Ohh! ohh! look at the pretty \00306c\003 \00304o\003 \00313l\003 \00310o\003 \00309r\003 \00307s\003.."
set chanpro(ban_notice)         "Look at that lamer fly!"
set chanpro(ban_annoy)          "?!?!!!!????!!! ANNOYING YOU SAY ?????!?!!!!"
set chanpro(ban_longword)	"Take some time off to visit school!"
set chanpro(ban_pubaway)	"My guess is that you'll be away quite some time now"
set chanpro(ban_mp3)		"Now, go listen to some music!"
set chanpro(ban_quit_color)     "Banned 1 day for parting \$chan with colors"
set chanpro(ban_quit_bold)      "Banned 1 day for parting \$chan with bold characters"
set chanpro(ban_quit_underline) "Banned 1 day for parting \$chan with underlined characters"


#Now, you've just set 87 variables. Good job! Let the script do the rest..

#---------------------------------------------------------------------#


## (B): SCRIPT

#binds:
bind notc - * check_notice
bind pubm - * check_pubm
bind ctcp - ACTION check_ctcp
bind sign - * check_quit
bind part - * check_quit

#redefining some old global vars:
set chanpro(remember) [expr $chanpro(remember) * 60]  					;#returns minutes..
set chanpro(ban_time_quit_color) [expr $chanpro(ban_time_quit_color) * 60]		;#returns minutes..
set chanpro(ban_time_quit_underline) [expr $chanpro(ban_time_quit_underline) * 60]	;#returns minutes..
set chanpro(ban_time_quit_bold) [expr $chanpro(ban_time_quit_bold) * 60]		;#returns minutes..
set chanpro(chans) [string tolower $chanpro(chans)]   					;#makes sure the user did not get all CrEAtiVE on me :P~

#checking if the user specified a legal op_method & a legal warning_method
if {$chanpro(op_method) != "notice \$nick" && $chanpro(op_method) != "privmsg \$chan"} {
   utimer 5 {putlog "Chanpro 2.2: You have specified an illegal Op-Warning method - the script will not function properly!"}
}
if {$chanpro(warning_method) != "notice \$nick" && $chanpro(warning_method) != "privmsg \$chan"} {
   utimer 5 {putlog "Chanpro 2.2: You have specified an illegal Warning method - the script will not function properly!"}
}


#havent checked if I need to define theese though, just being on the safe side..
set count(z:z:z) 0
set triggered(z:z:z) 0

# The proc's:

#ACTIONS
proc actions {nick host chan what} {

  #load some globals
  global count triggered chanpro botnick

  #set the banmask, since we might be needing it later on
  set bmask [parse_hostmask $host]

  #check if the dude has triggered before
  if {![info exists count($what:$host:$chan)]} {
     set count($what:$host:$chan) 0
  }

  #increase the variable that tracks number of offences
  incr count($what:$host:$chan)

  #check if we allready have a timer set, and kill it if so (prevent error msgs and bad timers)
  if {[info exists triggered($what:$host:$chan)]} {killtimer $triggered($what:$host:$chan); unset triggered($what:$host:$chan)}

  #set our timer, bound to a variable..
  set triggered($what:$host:$chan) [timer $chanpro(remember) [subst {unset count($what:$host:$chan); unset triggered($what:$host:$chan)}]]

  #check how many offences this dude has, and take action (this is gonna get long and ugly, be aware..)
  switch -- $chanpro(todo_$what) {

    1 {
        putserv "[subst $chanpro(warning_method)] :[subst $chanpro(warn_$what)]"; set count($what:$host:$chan) 1
      }

    2 {
    	putserv "KICK $chan $nick :[subst $chanpro(kick_$what)]"; set count($what:$host:$chan) 1
      }

    3 {
    	newchanban $chan $bmask $botnick [subst $chanpro(ban_$what)] $chanpro(ban_time_$what); putserv "KICK $chan $nick :[subst $chanpro(ban_$what)]"; set count($what:$host:$chan) 1
      }

    4 {
    	if {$count($what:$host:$chan) == 1} {putserv "[subst $chanpro(warning_method)] :[subst $chanpro(warn_$what)]"}
    	if {$count($what:$host:$chan) == 2} {putserv "KICK $chan $nick :[subst $chanpro(kick_$what)]"; set count($what:$host:$chan) 1}
      }

    5 {
    	if {$count($what:$host:$chan) == 1} {putserv "[subst $chanpro(warning_method)] :[subst $chanpro(warn_$what)]"}
    	if {$count($what:$host:$chan) == 2} {newchanban $chan $bmask $botnick [subst $chanpro(ban_$what)] $chanpro(ban_time_$what); putserv "KICK $chan $nick :[subst $chanpro(ban_$what)]"; set count($what:$host:$chan) 1}
      }

    6 {
    	if {$count($what:$host:$chan) == 1} {putserv "KICK $chan $nick :[subst $chanpro(kick_$what)]"}
    	if {$count($what:$host:$chan) == 2} {newchanban $chan $bmask $botnick [subst $chanpro(ban_$what)] $chanpro(ban_time_$what); putserv "KICK $chan $nick :[subst $chanpro(ban_$what)]"; set count($what:$host:$chan) 1}
      }

    7 {
    	if {$count($what:$host:$chan) == 1} {putserv "[subst $chanpro(warning_method)] :[subst $chanpro(warn_$what)]"}
    	if {$count($what:$host:$chan) == 2} {putserv "KICK $chan $nick :[subst $chanpro(kick_$what)]"}
    	if {$count($what:$host:$chan) == 3} {newchanban $chan $bmask $botnick [subst $chanpro(ban_$what)] $chanpro(ban_time_$what); putserv "KICK $chan $nick :[subst $chanpro(ban_$what)]"; set count($what:$host:$chan) 2}
      }

    default {putlog "Chanpro 2.2: I could not determine your todo_$what settings, please make sure \$chanpro(todo_$what) is between 1 and 7. Because of this, $nick is not being punished for his \"$what\"-abuse.."}
  }

} ;#end proc



#CHECK_CTCP
proc check_ctcp {nick host hand dest keyword text} {

 #load some global variables
 global chanpro botnick

 #set some variables
 set botnicky [string tolower $botnick]
 set chan [string tolower $dest]
 set enabled [lsearch -exact $chanpro(chans) $chan]
 set host [string tolower $host]

 #check if the chan enabled, else return..
 if {!$chanpro(all) && $enabled == -1} {return 0}

 #check if the bot is OPed, else return..
 if {![botisop $chan]} {return 0}

 #check if the bot is actually typing the word himself, if so - return..
 if {[string tolower $nick] == $botnicky} {return 0}

 #check the text for colors, bold, underline and CAPS
 if {[string match *\003* $text]} {check_color $nick $host $hand $chan $text} \
 elseif {[string match *\002* $text]} {check_bold $nick $host $hand $chan $text} \
 elseif {[string match *\037* $text]} {check_underline $nick $host $hand $chan $text} \
 else {check_caps $nick $host $hand $chan $text}

} ;#end proc


#CHECK_PUBM
proc check_pubm {nick host hand chan text} {

 #load some global variables
 global chanpro botnick

 #set some variables
 set botnicky [string tolower $botnick]
 set chan [string tolower $chan]
 set enabled [lsearch -exact $chanpro(chans) $chan]
 set host [string tolower $host]

 #check if the chan enabled, else return..
 if {!$chanpro(all) && $enabled == -1} {return 0}

 #check if the bot is OPed, else return..
 if {![botisop $chan]} {return 0}

 #check if the bot is actually typing the word himself, if so - return..
 if {[string tolower $nick] == $botnicky} {return 0}

 #check the text for colors, bold, underline and CAPS
 if {[string match *\003* $text]} {check_color $nick $host $hand $chan $text} \
 elseif {[string match *\002* $text]} {check_bold $nick $host $hand $chan $text} \
 elseif {[string match *\037* $text]} {check_underline $nick $host $hand $chan $text} \
 else {check_caps $nick $host $hand $chan $text}

} ;#end proc


#CHECK_NOTICE
proc check_notice {nick host hand text dest} {

  #load some global variables
  global chanpro botnick

  #set some variables
  set chan [string tolower $dest]
  set enabled [lsearch -exact $chanpro(chans) $chan]

  #check if the channel if enabled, else return
  if {!$chanpro(all) && $enabled == -1} {return 0}

  #set the botnick variable - tolower
  set botnicky [string tolower $botnick]

  #checks if the notice check is disabled..
  if {!$chanpro(notice)} {return 0}

  #Prevent error msg if the notice is to the bot.. (error msg's sux :P)
  if {$botnicky == $chan} {return 0}

  #checks if the user is an op, if so check if protect_ops is enabled
  if {([matchattr $hand o|o $chan] || [isop $nick $chan]) && $chanpro(protect_ops)} {
    if {$chanpro(warnings)} {putserv "[subst $chanpro(op_method)] :[subst $chanpro(op_notice)]"}
    return 0
  }

  #send the arguments on to the actions-proc
  actions $nick $host $chan "notice"

} ;# end proc



#CHECK_CAPS
proc check_caps {nick host hand chan text} {

 #load some global variables
 global chanpro botnick

 #check if CAPS-check is disabled, if so - return
 if {!$chanpro(caps)} {check_annoy $nick $host $hand $chan $text; return 0}

 #check if the string can match URL's, if so set the URLs tolower (for 'etical' reasons, we dont trigger on UpperCase URLs :)
 if {[string match *http://* [string tolower $text]] || [string match *www.* [string tolower $text]]} {
    set where [lsearch [string tolower $text] http://*]
    if {$where > -1} {regsub -all [lindex $text $where] $text [string tolower [lindex $text $where]] text}
    set where [lsearch [string tolower $text] *www.*]
    if {$where > -1} {regsub -all [lindex $text $where] $text [string tolower [lindex $text $where]] text}
 }

 #check if one of the words match a nickname in the channel, if so convert the nick tolower (due to autocomplete, etc..)
 foreach user [split [chanlist $chan] " "] {
    set found [string match -nocase *$user* $text]
    if {$found} {
      regsub -all -nocase -- $user $text [string tolower $user] text
    }
 }

 #set some vars we need
 set total_string [expr [string length $text] - [regsub -all -- " " $text * *]]
 set caps 0

 #check each char with a loop
  foreach char [split $text ""] {
    if {[string match *$char* "ABCDEFGHIJKLMNOPQRSTUVWXYZ∆ÿ≈"]} {incr caps}
  }

 #checks the amount of CAPS in percent
 if {$caps == 0 || $total_string == 0} {check_annoy $nick $host $hand $chan $text; return 0}
 set percent [expr $caps.0 / $total_string * 100]

 #checks if the percentage CAPS use is above the limit and if the string is long enough to be counted
 if {$percent < $chanpro(caps_percent) || $total_string < $chanpro(caps_minimum)} {check_annoy $nick $host $hand $chan $text; return 0}

 ##now, proceed to the actual actions the bot will take

 #checks if the user is an op, if so check if protect_ops is enabled
 if {([matchattr $hand o|o $chan] || [isop $nick $chan]) && $chanpro(protect_ops)} {
    if {$chanpro(warnings)} {putserv "[subst $chanpro(op_method)] :[subst $chanpro(op_caps)]"}
    return 0
 }

 #send the arguments on to the actions-proc
 actions $nick $host $chan "caps"

} ;#end proc



#CHECK_COLOR
proc check_color {nick host hand chan text} {

 #load some global variables
 global chanpro botnick

 #check if color-check is disabled, if so - return
 if {!$chanpro(color)} {return 0}

 ##now, proceed to the actual actions the bot will take

 #checks if the user is an op, if so check if protect_ops is enabled
 if {([matchattr $hand o|o $chan] || [isop $nick $chan]) && $chanpro(protect_ops)} {
    if {$chanpro(warnings)} {putserv "[subst $chanpro(op_method)] :[subst $chanpro(op_color)]"}
    return 0
 }

 #send the arguments on to the actions-proc
 actions $nick $host $chan "color"

} ;#end proc


#CHECK_BOLD
proc check_bold {nick host hand chan text} {

 #load some global variables
 global chanpro botnick

 #check if bold-check is disabled, if so - return
 if {!$chanpro(bold)} {return 0}

 ##now, proceed to the actual actions the bot will take

 #checks if the user is an op, if so check if protect_ops is enabled
 if {([matchattr $hand o|o $chan] || [isop $nick $chan]) && $chanpro(protect_ops)} {
    if {$chanpro(warnings)} {putserv "[subst $chanpro(op_method)] :[subst $chanpro(op_bold)]"}
    return 0
 }

 actions $nick $host $chan "bold"

} ;#end proc


#CHECK_UNDERLINE
proc check_underline {nick host hand chan text} {

 #load some global variables
 global chanpro botnick

 #check if bold-check is disabled, if so - return
 if {!$chanpro(underline)} {return 0}

 ##now, proceed to the actual actions the bot will take

 #checks if the user is an op, if so check if protect_ops is enabled
 if {([matchattr $hand o|o $chan] || [isop $nick $chan]) && $chanpro(protect_ops)} {
    if {$chanpro(warnings)} {putserv "[subst $chanpro(op_method)] :[subst $chanpro(op_underline)]"}
    return 0
 }

 #send the arguments on to the actions-proc
 actions $nick $host $chan "underline"

} ;#end proc


##CHECK_ANNOY
proc check_annoy {nick host hand chan text} {

 #load some global variables
 global chanpro botnick

 #set the annoy variables
 set annoy 0
 set total_annoy 0
 set triggered 0

 #check if annoy-check is disabled, if so - return
 if {!$chanpro(annoy)} {check_pubaway $nick $host $hand $chan $text; return 0}

 #check each char with a loop
 foreach word [split $text] {
    foreach letter [split $word ""] {
       if {$letter == "?" || $letter == "!"} {incr annoy; incr total_annoy}
    }

    #checks if the length of the annoy is huge enough
    if {$annoy >= $chanpro(annoy_length)} {break} {set annoy 0}
 }

 #set some vars again
 set total_string [expr [string length $text] - [regsub -all -- " " $text * *]]
 if {$total_string == 0 || $total_annoy == 0} {check_pubaway $nick $host $hand $chan $text; return 0}
 set percent [expr $total_annoy.0 / $total_string * 100]

 #check if the annoy was big enough
 if {$annoy >= $chanpro(annoy_length)} {
    set triggered 1
 }

 #check if the percentage was big enough, and string was long enough to count
 if {$total_string >= $chanpro(annoy_minimum) && $percent >= $chanpro(annoy_percent)} {
    set triggered 1
 }

 #check if we got a trigger
 if {!$triggered} {
    check_pubaway $nick $host $hand $chan $text
    return 0
 }


 ##now, proceed to the actual actions the bot will take

 #checks if the user is an op, if so check if protect_ops is enabled
 if {([matchattr $hand o|o $chan] || [isop $nick $chan]) && $chanpro(protect_ops)} {
    if {$chanpro(warnings)} {putserv "[subst $chanpro(op_method)] :[subst $chanpro(op_annoy)]"}
    return 0
 }

 #send the arguments on to the actions-proc
 actions $nick $host $chan "annoy"

} ;#end proc



#CHECK_PUBAWAY
proc check_pubaway {nick host hand chan text} {

 #load some globals
 global chanpro botnick

 #check if pubaway-check is disabled, if so - return
 if {!$chanpro(pubaway)} {check_mp3 $nick $host $hand $chan $text; return 0}

 #set a variable we need later on
 set triggered 0

 #split up $text to get a valid string
 set text [string tolower [split $text]]

 #remove any channel-nicknames from the string, as those
 #somethimes lead to an unfair trigger..
 foreach user [split [chanlist $chan] " "] {
    set found [string match -nocase *$user* $text]
    if {$found} {
      regsub -all -nocase -- $user $text "" text
    }
 }

 #match our keywords with the text, in a loop
 foreach pattern $chanpro(trig_pubaway) {
    if {[string match [string tolower $pattern] $text]} {set triggered 1; break}
 }

 #check if we got a match
 if {!$triggered} {check_mp3 $nick $host $hand $chan $text; return 0}

 #checks if the user is an op, if so check if protect_ops is enabled
 if {([matchattr $hand o|o $chan] || [isop $nick $chan]) && $chanpro(protect_ops)} {
    if {$chanpro(warnings)} {putserv "[subst $chanpro(op_method)] :[subst $chanpro(op_pubaway)]"}
    return 0
 }

 #so, we triggered, lets act on it
 actions $nick $host $chan "pubaway"

} ;#end proc



#CHECK_MP3
proc check_mp3 {nick host hand chan text} {

 #load some globals
 global chanpro botnick

 #check if mp3-check is disabled, if so - return
 if {!$chanpro(mp3)} {check_longword $nick $host $hand $chan $text; return 0}

 #set a variable we need later on
 set triggered 0

 #split up $text to get a valid string
 set text [string tolower [split $text]]

 #match our keywords with the text, in a loop
 foreach pattern $chanpro(trig_mp3) {
    if {[string match [string tolower $pattern] $text]} {set triggered 1; break}
 }

 #check if we got a match
 if {!$triggered} {check_longword $nick $host $hand $chan $text; return 0}

 #checks if the user is an op, if so check if protect_ops is enabled
 if {([matchattr $hand o|o $chan] || [isop $nick $chan]) && $chanpro(protect_ops)} {
    if {$chanpro(warnings)} {putserv "[subst $chanpro(op_method)] :[subst $chanpro(op_mp3)]"}
    return 0
 }

 #so, we triggered, lets act on it
 actions $nick $host $chan "mp3"

} ;#end proc



#CHECK_LONGWORD
proc check_longword {nick host hand chan text} {

 #load some globals
 global chanpro botnick

 #check if mp3-check is disabled, if so - return
 if {!$chanpro(longword)} {return 0}

 #set some variables we need later on
 set triggered 1
 set word ""

 #split up $text to get a valid string
 set text [string tolower [split $text]]

 #check if we encountered longwords
 foreach w0rd [split $text] {
    if {[string length $w0rd] >= $chanpro(longword_length)} {set word $w0rd; break}
 }

 #check if we got a longword
 if {$word == ""} {return 0}

 #match our keywords with the text, in a loop
 foreach pattern $chanpro(not_trig_longword) {
    if {[string match [string tolower $pattern] $word]} {set triggered 0; break}
 }

 #check if we got a match
 if {!$triggered} {return 0}

 #checks if the user is an op, if so check if protect_ops is enabled
 if {([matchattr $hand o|o $chan] || [isop $nick $chan]) && $chanpro(protect_ops)} {
    if {$chanpro(warnings)} {putserv "[subst $chanpro(op_method)] :[subst $chanpro(op_longword)]"}
    return 0
 }

 #so, we triggered, lets act on it
 actions $nick $host $chan "longword"

} ;#end proc



#CHECK_QUIT
proc check_quit {nick host hand chan text} {

  #load some global vars
  global chanpro botnick

  #set some variables
  set botnicky  [string tolower $botnick]
  set chan      [string tolower $chan]
  set enabled   [lsearch -exact $chanpro(chans) $chan]
  set nick      [string tolower $nick]
  set triggered 0

  #check if the chan enabled, else return..
  if {!$chanpro(all) && $enabled == -1} {return 0}

  #check we this feature is turned on
  if {!$chanpro(quit)} {return 0}

  #check if the bot is OPed, else return..
  if {![botisop $chan]} {return 0}

  #check if the bot is actually typing the word himself, if so - return..
  if {$nick == $botnicky} {return 0}

  #check if the guy is an op, and the protect_ops is enabled
  if {([matchattr $hand o|o $chan] || [wasop $nick $chan]) && $chanpro(protect_ops)} {return 0}

  #check the text for colors, bold and underline
  if {[string match *\003* $text]} {set triggered 1; set reason "color"} \
  elseif {[string match *\002* $text]} {set triggered 1; set reason "bold"} \
  elseif {[string match *\037* $text]} {set triggered 1; set reason "underline"}

  #check if we triggered
  if {!$triggered} {return 0}

  #do your thing
  set bmask [parse_hostmask $host] 

  #set the ban
  newchanban $chan $bmask $botnick [subst $chanpro(ban_quit_$reason)] $chanpro(ban_time_quit_$reason)

} ;#end proc


#PARSE_HOSTMASK
proc parse_hostmask {host} {

  #load some global vars
  global chanpro
  
  #cheesy variable
  set parsed ""
  
  #run a switch to evaluate the mask from the users wishes
  switch -- $chanpro(bmask) {

    1 {
        set parsed *!*$host
      }

    2 {
    	set first  [split $host @]
    	set second [split [lindex $first 1] .]
    	set parsed *!*[lindex $first 0]@*.[lindex $second end-1].[lindex $second end]
      }

    3 {
    	set parsed *!*@[lindex [split $host @] 1]
      }

    4 {
    	set parsed *!$host
      }

    5 {
    	set first  [split $host @]
    	set second [split [lindex $first 1] .]
    	set parsed *![lindex $first 0]@*.[lindex $second end-1].[lindex $second end]
      }

    6 {
    	if {[regexp ^(\[0-9.\])+$ [set parsed [lindex [split $host @] 1]]]} {
    	   set parsed *!*[lindex [split $host @] 0]@[join [lrange [split $parsed .] 0 1] .].*
    	} elseif {[string match -nocase *.users.undernet.org* $host]} {
    	   set parsed *!*@[lindex [split $host @] 1]
    	} else {
    	   set first  [split $host @]
    	   set second [split [lindex $first 1] .]
    	   set parsed *!*[lindex $first 0]@*.[lindex $second end-1].[lindex $second end]
    	}
      }

    default {
        putlog "Chanpro 2.2: I could not determine your banmask settings, please make sure \$chanpro(bmask) is between 1 and 6."
        set first  [split $host @]
    	set second [split [lindex $first 1] .]
    	set parsed *!*[lindex $first 0]@*.[lindex $second end-1].[lindex $second end]
      }
  }

  #small, unnecessary, check
  if {$host == "" || $parsed == ""} {
     putlog "Chanpro 2.2: Something is VERY wrong with my script, please check it immediately!"
     return "*!faulty@script.settings.com"
  } 

  #return our parsed hostmask
  return $parsed

} ;#end proc


#Credits
putlog "Channel-protection v2.2 loaded" 