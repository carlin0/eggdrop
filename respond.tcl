########################################### 
# respond.tcl v2.0
# 
# Originally by MC_8 <mc8@home.com> 
# 
# Mayor overhaul to version 2 by Cruz <styck@xs4all.nl>
#
#
# History.
# v2.0
# Cruz added extra functionality:
#  -o- you can now use /not, /msg and /me in replies (notices/queries/actions).
#  -o- you can use multiple replies ({"reply1" "reply2"}) which will be randomly picked
#  -o- it also triggers on /me lines and join messages
#  -o- limited to 1 reply per line, instead of continuing with other rules
#  -o- you can reply with multiple lines of text by using \n as delimiter {"what\nnow!"}
#  -o- you can use %1 - %6 in the reply, matching the 1st - 6st * in the matching text
#       (ie: (give me *!) {/me gives %nick %1} : "Cruz: give me money!" -> "Bot gives Cruz money")
#
# v1.1
# MaD` Found many errors, fixed by MC_8
#
# v1 inital release by MC_8
#
###########################################

##
# This has been upgraded due to the users bug reports, thank you.
#
# Someone says a matching text in the channel, and the bot will respond to it.
##

##
# Global settings:
##

# what channel(s) do you want this to be active on?
set mc_re(chan) {"#italy" "#torino"}

# how many messages may we send...
set messagelimit 4

# in how many seconds?
set timelimit 60

# what color do you want the text to have?
set mc_color "\002"


##
#Template :
#              read        write
# set {mc_resp(    )}    {"     "}
#
# Valid variables are %nick %uhost %hand %chan ^^^ ###
#
# Examples:
# set {mc_resp(kick me)}	{"/kick %nick Ok, you asked for it"}
# set {mc_resp(help)}		{"/not how can i help you?"}
# set {mc_resp(*fuck*)}		{"swearing is impolite."}
# set {mc_resp(pm me)}		{"/msg %nick sure, i'll personal message you"}
# set {mc_resp(ban me)}		{"/ban %nick 5 A 5 minute ban because you asked for it"}
# set {mc_resp(notice me)}	{"/not %nick sure, i'll send you a notice"}
# set {mc_resp(*slaps you)}	{"/me slaps %nick back, twice as hard"}
##

##
# In case you want to override the default color, you can specify them in the replies as well:
# Coloring tutorial :
# \002 		=> Bold
# \003xx 	=> Change foreground color
# \003xx,yy	=> Change fore & background color
# \017		=> Reset
# \026		=> Flip bg/fg
# \037		=> Underline
#
##

#info
#set {mc_resp(!whoareyou)}	{"/not %nick I'm a bot that has the Responder script enabled. Visit #\[FtUC\] on quakenet and say Hi to Cruz, the creator of that script ^^."}

#"commands"

set {mc_resp(!suicidio)}	{"/kick %nick l'hai voluto tu!!"}

set {mc_resp(!consigli)}	{"Vai a cagare %nick ..." \
                               "/me scorreggia in direzione di %nick" \
                               "%nick ma i tuoi genitori quella sera non potevano andare al cinema ??" \
                               "%nick prendilo in quel posto!!" \
                               "%nick CHUPPAAA!!!" \
                               "%nick fatti un bel clistere!!" \
                               "%nick di merda ..... che il vento ti disperda!!" \
                               "%nick ma perchè non ti ammazzi ?¿?" \
                               "%nick ... per te ci vuole un bel viaggio a Lourdes" \
                               "%nick se la merda fosse oro tu saresti un gran tesoro..." \
                               "%nick hai + corna tu che un cesto di lumache ..." \
                               "%nick salutami tua sorella" \
                               "%nick prendi 2 carote ; una dalla al tuo mulo e l'altra é per te!!" \
                               "buttati in un fiume con una pietra attaccata a un piede %nick" \
                               "%nick vieni a pescare con me mi manca il verme !!" \
                               "/me rutta fragorosamente in faccia a %nick spettinandolo!!" \
                               "%nick ... puppamelo!"  \
                               "%nick ho un paio di pinne in cemento da farti provare..." \
                               "%nick fatti i caXXi tuoi....."}

set {mc_resp(botolo)}		{"/msg %nick ci conosciamo?" \
                               "/msg %nick che caZZo vuoi ???" \
                               "/msg %nick non nominare Botolo invano ..." \
                               "/msg %nick PRRRRRRRRRRRRRRRRRRRRR !!!" \
                               "/msg %nick hai mica una sorella da presentarmi.."}

set {mc_resp(*ciao a t*)}	{"Ciao %nick :)" \
                                 "/me saluta %nick :Þ" \
                                 " %nick  MaCCiao" \
                                 "weee  %nick " \
                                 "Salve %nick :-D"}

set {mc_resp(pizza*)}	{" %nick a me una prosciutto & funghi ..." \
                                 " %nick a me margherita" \
                                 "una diavola %nick "}

set {mc_resp(*fancul*)}	{" %nick vacci tu !!" \
                                 "dopo di te %nick" \
                                 "si ma quale %nick ? il tuo ?"}

set {mc_resp(*fankul*)}	{" %nick vacci tu !!" \
                                 "dopo di te %nick" \
                                 "si ma quale %nick ? il tuo ?"}

set {mc_resp(*salve*)}	{"Ciao %nick :-)" \
                                 "/me saluta %nick :-O" \
                                 "weee  %nick " \
                                 "Salve %nick "}

set {mc_resp(*nasera*)}	{"Buonasera %nick ..." \
                                 " %nick Buonasera....."}

set {mc_resp(*na sera*)}	{"Buonasera %nick ..." \
                                 " %nick Buonasera....."}

set {mc_resp(*onanotte*)}	{"Va curcate %nick ..." \
                                 " %nick era ora... e che cacchio..."}

set {mc_resp(posso fare una domand*)}	{"provaci %nick !" \
                               " %nick tentar non nuoce"}


set {mc_resp(*è qualcuno)}	{"dormono tutti ...." \
                                 "si si ci sono io !!" \
                                 " %nick non c'è nessuno !!" \
                                 " %nick non mi vedi  !?"}

#joins
#set {mc_resp(*cruz*onjoin123)}		{"Look, it's Cruz, my master!"}


#                                                       #
### You may stop editing now, source code starts here ###
#                                                       #

set mc_re(version) v2.0
set mc_re(chan) [string tolower $mc_re(chan)]
bind pubm - * mc:resp
bind ctcp - "ACTION" mc:action
bind join - * mc:join

proc mc:join {nick uhost hand chan args} {
#  puthelp "PRIVMSG $chan : $nick / $uhost / $hand / $chan / $args"
# little hack, add the keyword 'onjoin123' as the text so we can use that to trigger on join messages
  set args "$nick onjoin123"
  mc:resp $nick $uhost $hand $chan $args
    return 0
}

proc mc:action { nick uhost hand chan keyword text } {
#  puthelp "PRIVMSG $chan : $nick / $uhost / $hand / $chan / $keyword / $text"
  mc:resp $nick $uhost $hand $chan $text
}


proc mc:resp {nick uhost hand chan args} {
 global botnick mc_resp mc_re messagelimit messagecount timelimit hack mc_color
 set args [string tolower [lindex $args 0]]

 # make sure we're not spamming because we're being spammed:
 if {![info exists messagecount]} {
   set messagecount 0
 }
 if {$messagecount >= $messagelimit} { return 0 }

 # check if we're on a channel which we are installed on:
 if {[lsearch -exact $mc_re(chan) [string tolower $chan]] == "-1"} {return 0}

 # loop through all above responses with the received line:
 # "search" is the received line.
 foreach search [string tolower [array names mc_resp]] {

  # if we have a match:  
  # (if "search" (*hello*bob*) matches "args" (why, hello bob!))
  if {[string match $search $args]} {

   # put the entire message (bot reply) in the text variable since we'll be using it:
   set text [mc:resp:rep $mc_resp($search) $nick $uhost $hand $chan]

   # pick a random reply if there are multiple defined:
   set alltext [lindex $text [rand [llength $text]]]

   # if the reply contains a \n, split it in multiple commands:
   set alltext [split $alltext "\n"]
   foreach text $alltext {

    # strip any spaces at end or front
    set text [string trim $text]

		# search : *hello*bob*
		# args   : hello bob, good to see you
		# text   : Thanks, it's good to see you too


    # lets see if we can assign text to variables:
    regsub -all "\\*" $search "(.\*)" regtext

    set TXT1 "."
    set TXT2 "."
    set TXT3 "."
    set TXT4 "."
    set TXT5 "."
    set TXT6 "."

    regexp $regtext $args match_var TXT1 TXT2 TXT3 TXT4 TXT5 TXT6

    regsub "%1" $text $TXT1 text
    regsub "%2" $text $TXT2 text
    regsub "%3" $text $TXT3 text
    regsub "%4" $text $TXT4 text
    regsub "%5" $text $TXT5 text
    regsub "%6" $text $TXT6 text

#puthelp "PRIVMSG $chan :$TXT1 $TXT2 $TXT3 $TXT4 $TXT5 $TXT6"
#puthelp "PRIVMSG $chan : (regexp   $regtext   $args)"

    # first parse the /me
    if {[string match /me* $text]} {
       regsub "/me " $text "" echotext    
       puthelp "PRIVMSG $chan :ACTION $echotext"
       continue
       } 

    # second, parse /not
    if {[string match /not* $text]} {
       if {[regexp {^\/not ([^ ]*) (.*)$} $text match_var recipient message]} {
          puthelp "NOTICE $recipient :${mc_color}$message"
          } else { 
          puthelp "PRIVMSG $chan :${mc_color}Sorry, i fucked up. ($text)"
          }
          continue
       }

    # third, parse /msg
    if {[string match /msg* $text]} {
       if {[regexp {^\/msg ([^ ]*) (.*)$} $text match_var recipient message]} {
          puthelp "PRIVMSG $recipient :${mc_color}$message"
          } else { 
          puthelp "PRIVMSG $chan :${mc_color}Sorry, i fucked up. ($text)"
          }
          continue
       }

    # fourth, parse /kick
    if {[string match /kick* $text]} {
       if {[regexp {^\/kick ([^ ]*) (.*)$} $text match_var target message]} {

	  if {[isop $target $chan]!=1} {
              puthelp "KICK $chan $target :$message"
	    } else {
              puthelp "PRIVMSG $chan :ACTION dice a $target : Mannaggia a te!!"
	    }

          } else { 
	      puthelp "PRIVMSG $chan :${mc_color}Sorry, i fucked up. ($text)"
          }
          continue
       }

    # fifth, parse /ban
    if {[string match /ban* $text]} {
       if {[regexp {^\/ban ([^ ]*) ([0-9]+) (.*)$} $text match_var target bantime message]} {

	  if {[isop $target $chan]!=1} {
              newchanban $chan [maskhost $uhost] $botnick $message $bantime
              puthelp "KICK $chan $target :$message"
	    } else {
              puthelp "PRIVMSG $chan :ACTION gently asks $target to permanently leave"
	    }

          } else { 
	      puthelp "PRIVMSG $chan :${mc_color}Sorry, i fucked up. ($text)"
          }
          continue
       }


    # default :
    puthelp "PRIVMSG $chan :${mc_color}$text"
    continue
   }

  # update messagecount to prevent flooding
  set messagecount [expr $messagecount+1]
  utimer $timelimit {set messagecount [expr $messagecount-1]}
  return 0

  }
 }
}

proc mc:resp:rep {data nick uhost hand chan} {
 global botnick
 regsub -all -- %nick $data $nick data ; regsub -all -- %uhost $data $uhost data
 regsub -all -- %botnick $data $botnick data
 regsub -all -- %hand $data $hand data ; regsub -all -- %chan $data $chan data
 regsub -all -- %b $data  data ; regsub -all -- %r $data  data
 regsub -all -- %u $data  data ; regsub -all -- %c $data  data
 return $data
}

putlog "Responder $mc_re(version) LOADED!"
