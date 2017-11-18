#Set the channels here on which you want this script to work 
#Seperate channels by Space like "#channel1 #channel2 #channel3"
#If you want this script to work on all the channels where ur bot is parked leave it as ""
 
set bwordchan ""

#Set Badwords here on which you want your bot to kick user
#You can manually add badwords in the way mentioned below ( *WILD CARDS SUPPORTED* )
# set badwords {
# "*badword1*"
# "*badword2*"
# }

set badwords {
  "*porc*dio*" 
  "*pork*dio*" 
  "*dio*porco*" 
  "*dio*porko*"
  "*astard*dio*"
  "*dio*astard*"
  "*orc*madonn*"
  "*ork*madonn*"
  "*madonna*por*"
  "*puttan*madonn*" 
  "*madonn*puttan*" 
  "*madonn*maial*"
}

#Set Kick Reason
set bkickreason "Non Imprecare ..."


# Set the banmask type to use in banning the User who uses badwords.
# Currently BAN Type is set to 1 (*!*@some.domain.com),
# BAN Types are given below;
# 1 - *!*@some.domain.com 
# 2 - *!*@*.domain.com
# 3 - *!*ident@some.domain.com
# 4 - *!*ident@*.domain.com
# 5 - *!*ident*@some.domain.com
# 6 - *nick*!*@*.domain.com
# 7 - *nick*!*@some.domain.com
# 8 - nick!ident@some.domain.com
# 9 - nick!ident@*.host.com
set bantype "1"

#Set the Users Mode you want to Exempt
#The Bot will not kick the user who had the modes you will define below
#You can leave it as it is , if you dont know about it
#Recommended : of
set bworduser "o"

###########################
# CONFIGURATION ENDS HERE #
###########################

#--------------------------------------------------------------------------------------------------------------------#
#  SCRIPT STARTS FROM HERE.YOU CAN MAKE MODIFICATIONS AT UR OWN RISK, I DONT RESTRICT YOU TO NOT TO TOUCH THE CODE!  #
#--------------------------------------------------------------------------------------------------------------------#

bind pubm - * btext:RanaUsman
proc btext:RanaUsman {nick uhost hand chan arg} {
global badwords bwordchan bkickreason banmask bworduser
if {(([lsearch -exact [string tolower $bwordchan] [string tolower $chan]] != -1)  || ($bwordchan == ""))} {
set usman [badword:filter $arg]
set arg [badword:filter $arg]
set banmask "[badword:banmask $uhost $nick]" 
foreach bword $badwords {
if {[string match -nocase $bword $usman]} {
if {[matchattr $hand $bworduser]} { return 0 
} else {
putquick "MODE $chan +bb $banmask"
putserv "KICK $chan $nick :$bkickreason"
    }
   }
  }
 }
}
proc badword:filter {str} {
  regsub -all -- {\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\037|\002|\026|\006|\007} $str "" str
  return $str
}
proc badword:banmask {uhost nick} {
 global bantype
  switch -- $bantype {
   1 { set banmask "*!*@[lindex [split $uhost @] 1]" }
   2 { set banmask "*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
   3 { set banmask "*!*$uhost" }
   4 { set banmask "*!*[lindex [split [maskhost $uhost] "!"] 1]" }
   5 { set banmask "*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" }
   6 { set banmask "*$nick*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
   7 { set banmask "*$nick*!*@[lindex [split $uhost "@"] 1]" }
   8 { set banmask "$nick![lindex [split $uhost "@"] 0]@[lindex [split $uhost @] 1]" }
   9 { set banmask "$nick![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
   default { set banmask "*!*@[lindex [split $uhost @] 1]" }
   return $banmask
  }
}

putlog "Anti bestemmia LOADED"
