################################################################################
# COLORS / BOLD								       #
# To make a text bold do this: \002TEXT-BOLD\002			       #
# To make a text with colors do this: \00304TEXT-RED\003 (04 = red, e.g.)      #
# To make a text with colors and bold do this: \002\00304TEXT-RED-BOLD\003\002 #
# Alternative, hit ctrl+k in IRC and copy paste in to dialog box. (RECOMMENDED)#
################################################################################

##### GENERAL SETTINGS ####
# EDIT the channel names or REMOVE one or two depending on which channel you intend the bot the advertise
#set channel "#JingYou #I-spires #Iwebnation"
set channel "#amici"

# Edit the time cycle which is in minutes format depending on the time intervals you want the bot to flow out the advertisment
set time 33

# EDIT the text or REMOVE or ADD lines including inverted commas at the starting and ending at each line 
set text {
"ricordiamo a tutti i nostri amici il nostro sito:  www.chatta-gratis.it"
}

##### DO NOT EDIT ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING #####

if {[string compare [string index $time 0] "!"] == 0} { set timer [string range $time 1 end] } { set timer [expr $time * 60] }
if {[lsearch -glob [utimers] "* go *"] == -1} { utimer $timer go }

proc go {} {
global channel time text timer
foreach chan $channel {
foreach line $text { putserv "PRIVMSG $chan :$line" }
}
if {[lsearch -glob [utimers] "* go *"] == -1} { utimer $timer go }
}

putlog "ADV loaded"