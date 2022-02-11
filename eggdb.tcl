# e g g d r o p   d a t a b a s e   v 1 . 2                                     #
#                                                                               #
# by Daniel Skovli (gozzer@gmail.com)                                           #
# ----                                                                          #
# This is a database script for eggdrops on IRC. It will save all information   #
# to a flatfile on your shell. It has been tested on eggdrop version 1.6.15     #
# with TCL version 8.3.5.                                                       #
#                                                                               #
# History/idea:                                                                 #
# It all started when I downloaded notepod.tcl by amadeus a year ago or so.     #
# I needed a database script for my egg, to use it on a help-channel.           #
# I did not have any tcl experience at this point. Soon I found out that the    #
# script did not have all the features I wanted, while it had alot of stuff     #
# that were totally useless to me. It wasnt working 100% either..               #
# But, dont get me wrong - amadeus did a good job, all credits to him for that. #
# So, I had to get my hands dirty with tcl (with good help from furt@undernet)  #
# and soon enough I had worked up a useful understanding of the language.       #
# After much modification - I decided to rewrite the whole thing, as it would   #
# be much cleaner - and more efficient code. And, here we are :o)               #
#                                                                               #
# Usage/limitations:                                                            #
# You can only access the commands of this script via public (a channel).       #
# You set up which chans the script should work on, and do your stuff from      #
# there. It can of course work on multiple channels - but note that sometimes   #
# if there is much traffic, the bot may lag some. I.e. if to users in           #
# different chans request a topic at the same time; the bot will answer a bit   #
# slow - to avoid being flooded from IRC.                                       #
#                                                                               #
# To access the different commands, you need different access levels with       #
# the eggdrop, or channel status. The requirements are as follows;              #
# o Add a topic:                                voice                           #
# o Delete a topic you have set:                voice                           #
# o Delete a topic someone else has set:        OP                              #
# o Replace a topic you have set:               voice                           #
# o Replace a topic someone else has set:       OP                              #
# o Search for a user's entries:                voice                           #
# o Showing who sat a topic:                    voice                           #
# o Search for topics, the regular way:         none                            #
# o Search for topics, body search:             none                            #
# o Search for topics, special:                 none                            #
# o Display a topic:                            none                            #
# o Show database stats:                        none                            #
#                                                                               #
# You can not change these settings in the config.                              #
#                                                                               #
# The usage of the commands, will now be a explained a little more.             #
# The command-char I've used here is !, but you can substitute that with what   #
# you want - in the config. Now, lets see how it all works;                     #
#                                                                               #
# o Add a topic:                        !learn <topic> <body>                   #
#   Alias;   !define                                                            #
#   This will add the topic you specify. There can be NO spaces in the topic,   #
#   as it only catches the first word as the topic. You can also use a          #
#   separator in the body, to make the bot type out the reply over several      #
#   lines. This chr defaults to §, since it is the first chr I found that       #
#   is not used in any programming languages (afaik) - since I added this       #
#   feature to ease the adding of raw code in topics (help chan, remember).     #
#                                                                               #
# o Delete a topic:                     !forget <topic>                         #
#   Aliases; !remove, !delete                                                   #
#   This will delete the topic you specify. No wildcards allowed. Not case-     #
#   sensitive.                                                                  #
#                                                                               #
# o Replace a topic:                    !replace <topic> <new body>             #
#   Alias;   !brainwash                                                         #
#   This will delete the body in the specified topic, and add the new one.      #
#   Same rules as the !learn command.                                           #
#                                                                               #
# o Search for a user's entries:        !search-author <nick/handle>            #
#   No aliases.                                                                 #
#   This command runs the nich/handle through the database, and returns the     #
#   topics it finds, that were set by that nick/handle. No wildcards allowed!   #
#                                                                               #
# o Showing who sat a topic:            !author <topic>                         #
#   Alias;   !whoset, !whosat                                                   #
#   This shows you who sat the topic you specify. No wildcards allowed.         #
#                                                                               #
# o Search for topics, regular:         !search <string>                        #
#   Aliases; !search-topic, !find                                               #
#   This command searches through the list of topics, finding the ones that     #
#   match your query. Wildcards are supported, and spaces are converted to them.#
#                                                                               #
# o Search for topics, body:            !search-body <string>                   #
#   No aliases.                                                                 #
#   Search for topics, looking for a string-match in the body.                  #
#   Wildcards are supported, and spaces are converted to them.                  #
#                                                                               #
# o Search for topics, special:         !seek <string>                          #
#   No aliases.                                                                 #
#   This command searches through the list of topics, finding the ones that     #
#   match your query. The difference from the !search is that here the          #
#   wildcards are optional. Meaning that you chose yourself where you want the  #
#   wildcards - they are not appended to the front and end of the string,       #
#   and spaces are not converted. Uses the first word in your sting.            #
#   Can be useful, if you want to find *something instead of *something* etc.   #
#                                                                               #
# o Displaying a topic:                 ?? <topic>                              #
#   Aliases; !display, !show                                                    #
#   This is the command that prints out the topic you choose. Wildcards not     #
#   supported. You can also display a topic to a user in the chan, by typing    #
#   ?? <topic> <nick>                                                           #
#   It will be displayed as a private msg. There is also a timer, that          #
#   prevents the same topic from being displayed in the same channel within     #
#   the number of minutes that you specify. This is to prevent flooding         #
#   and other kinds of lameness.                                                #
#                                                                               #
# o Showing database stats:             !db                                     #
#   Alias;   !db-info                                                           #
#   This commands shows some information about the database.                    #
#   Number of topics, and file-size of the db (optional)..                      #
#                                                                               #
#                                                                               #
# Well, now that we have covered the usage, let me just tell you a few things   #
# about the script in general. I have used this script with a database          #
# containing 20 000+ lines, and it worked great. The use of flatfiles should    #
# therefore not be a problem for most users. If you on the other hand feel the  #
# need to use MySQL instead, I can recommend furt's Define.tcl.                 #
# I have used the script on 2 medium sized channels only, 'double-triggering'   #
# and other laggy stuff was no problem then. So, I dont think you need to worry #
# about that - but if you are sertain that your bot will access this script     #
# all the time, and from several channels at the same time; you'll just have    #
# to see how it goes. But, please give me feedback (positive&negative),         #
# I'm always happy to recieve that.                                             #
#                                                                               #
# You've read many lines now, and should get started on the config.             #
# 8 fast steps. If you are unsertain of the meaning of a setting; just leave    #
# it as it is.. it works. Good luck, and enjoy!                                 #
#                                                                               #
# happy surfin'                                                                 #
#                                                                               #
#-------------------------------------------------------------------------------#



## C O N F I G :
#

#(1) 
#Should the script work on all channels? 1:yes, 0:no. 
#If you turn this on, the channel prefix ($db(chans)) will be disregarded. 
set db(all) 0

#(2)
#If $db(all) is disabled, which chans should this script work on? Separate channels with a space.
set db(chans) "##linux-it #provazze #carlin0"

#(3)
#Set the path to our db-file. the file is used as a txt-file, no matter what you name it.
#The ./ in the path means the same as one dir up from the folder the script is in.
set db(file) "./definitions.db"

#(4)
#What should be the maximum amount of matches to return from a search?
#Don't set this too high, couse the bot will not do more than maximum two (2) text-dumps to the
#server, meaning that if you have long topics - he'll cut some of them. You'll figure it out.
set db(max) 5

#(5)
#This is where you set how many minutes between each time the bot will:
#a) display the same topic/definition in the same channel.
#b) allow the same person to search for the exact same query in the same channel.
set db(timer) 7

#(6)
#When displaying info for the database (number of topics added),
#should we display details as well (size in bytes, of the db)? 1:yes, 0:no.
set db(details) 1

#(7)
#What character should we use as a linebreak/newline? 
#For instance, !learn my-first-entry this § works § great!, would be displayed
#over three lines. Check it out for yourself :-)
set db(newline) "§"

#(8)
#What command character do you want?
#This is the character you use infront of all the commands, e.g:
#!learn, !search, !author, etc.. all commands except the ?? <topic>.
set cmdchar "!"


#You may want to use different triggers/commands than the one's I've set up as default.
#If this is your case, edit the bind below; but make sure you follow the right pattern,
#and if you are stuck: read 'bind pub' in /eggdropdir/docs/tcl-commands.doc for help!

#--------------------------------------


## B I N D S :
#

#pattern: 'bind pub <flags> <trigger> <procedure>'

#triggers for displaying a topic
bind pub - ??                            db:display
bind pub - ${cmdchar}display             db:display
bind pub - ${cmdchar}show                db:display

#triggers for searching for topics (in various ways)
bind pub - ${cmdchar}find                db:search
bind pub - ${cmdchar}search              db:search
bind pub - ${cmdchar}search-topic        db:search
bind pub - ${cmdchar}search-author       db:nick
bind pub - ${cmdchar}search-body         db:body
bind pub - ${cmdchar}seek                db:special

#triggers for checking the author of a topic
bind pub - ${cmdchar}whoset              db:whoset
bind pub - ${cmdchar}whosat              db:whoset
bind pub - ${cmdchar}author              db:whoset

#triggers for adding a new topic&definition
bind pub - ${cmdchar}learn               db:define
bind pub - ${cmdchar}define              db:define

#triggers for deleteing a topic from the db
bind pub - ${cmdchar}remove              db:forget
bind pub - ${cmdchar}forget              db:forget
bind pub - ${cmdchar}delete              db:forget

#triggers for replacing/updating a topic's definition
bind pub - ${cmdchar}replace             db:replace
bind pub - ${cmdchar}brainwash           db:replace

#triggers for displaying some info about the database
bind pub - ${cmdchar}db                  db:info
bind pub - ${cmdchar}db-info             db:info



#----------------------------------


## S C R I P T :
#


#set our channel-list to lowercase
set db(chans) [string tolower $db(chans)]

#define some common commands, for further reference
proc notice {target msg} {putserv "notice $target :$msg"}
proc priv   {target msg} {putserv "privmsg $target :$msg"}
proc priv2  {target msg} {putlog "privmsg $target :$msg"}
proc log    {msg} {putlog "$msg"}

# Create db file if not exists
if {![file exists $db(file)]} {

  #open the db for writing (create it)
  set database [open $db(file) w]

  #put a line in the file
  puts $database "?? this is the trigger to display topics; good job!"
 
  #close the db
  close $database

  #log our success to the partyline
  log "eggdrop db: database successfully created." 

} ;#end proc


# returns the number of lines in the explain.txt file
proc db:info {nick host hand chan text} {
 
 #load some global variables
 global db

 #check if the channel is enabled, else return
 if {!$db(all) && [lsearch -exact $db(chans) [string tolower $chan]] == -1} {return}

 #open the db for reading
 set database [open $db(file) r]

 #get the number of lines in the file
 set length [llength [split [read $database] \n]]
 incr length -1

 #close the db
 close $database

 #check if we need details about the db
 if {$db(details)} {
   
    #catch the size of the db (bytes)
    set size  [file size $db(file)]
    
    #set an output var
    set details " ($size bytes)"
 } else {
    set details ""
 }

 #do a little grammar adjustment
 if {$length == 1} {set grammar "definition"} {set grammar "definitions"}

 #return the msg
 priv $chan "I have $length $grammar in my database$details."

} ;#end proc


#----------------------------------


# get - Retrieve a line from DB
proc get {query} {

  #load some global variables
  global db

  #loop through our file, and extract the topic we want
  set database [open $db(file) r]
  set query [string tolower $query]
  while {![eof $database]} {
    set line [gets $database]
    set topic [string tolower [lindex $line 0]]
    if {$topic == $query} {
      close $database
      return $line 
    }  
  }

  #close the file if the if-statement didnt do it, and return
  close $database
  return "" 

} ;#end proc



# add - add a line to DB
proc add {query} {   

  #load some global variables
  global db

  #set some variables
  set topic    [lindex $query 0]
  set hand     [lindex $query 1]
  set def      [lrange $query 2 end]
  set database [open $db(file) a]
  set defs     ""

  #add the new definition to the database
  fconfigure $database -encoding binary
  puts $database "$topic $hand $def"
  
  #close the file again
  close $database

  #return
  return 1

} ;#end proc



# del - del a line from DB
proc del {query} {   
  
  #load some global variables
  global db

  #set some variables
  set database [open $db(file) r]
  set defs ""
  
  #loop through the file, to find the topic to remove & remove it
  while {![eof $database]} {
    set line [gets $database]
    set topic [string tolower [lindex $line 0]]
    if {$topic != $query} {lappend defs $line}
  }
  
  #close the file
  close $database

  #open the file again, to set the topics back - without the removed one
  set database [open $db(file) w]
  foreach line $defs {
    if {$line != ""} {puts $database $line}
  }
  
  #close the file
  close $database

  #return
  return 1

} ;#end proc



# topics - Retrieve multiple lines from DB
proc topics {query} {
 
  #load some globale variables
  global db
  
  #set some variables
  set database [open $db(file) r]
  set query    [string tolower $query]
  set topics   ""
  set matches  0
  
  #loop through the file to get our lines
  while {![eof $database]} {
    set line [gets $database]
    set topic [lindex $line 0]

    #lappend to list if we got a match
    if {[string match *$query* [string tolower $topic]]} {
       lappend topics $topic
       incr matches
    }
  }

  #close the file
  close $database

  #send our list back to the proc who called us
  set topics  [lrange $topics 0 [expr $db(max) - 1]]
  return "$matches $topics"

} ;#end proc



# special - Retrieve multiple lines from DB
proc special {query} {

  #load some global variables
  global db

  #set some variables
  set database [open $db(file) r]
  set query    [string tolower $query]
  set topics   ""
  set matches  0

  #loop through the file to find our matches
  while {![eof $database]} {
    set line [gets $database]
    set topic [lindex $line 0]
    
    #lappend to list if we got a match
    if {[string match $query [string tolower $topic]]} {
       lappend topics $topic
       incr matches
    }
  }

  #close the file
  close $database
 
  #send our list back to the proc who called us
  set topics  [lrange $topics 0 [expr $db(max) - 1]]
  return "$matches $topics"

} ;#end proc



# body - Retrive multiple topics from DB, from keyword in body 
proc body {query} {

  #load some global variables
  global db
 
  #set some variables
  set database [open $db(file) r]
  set query    [string tolower $query]
  set topics   ""
  set matches  0

  #loop through the file..
  while {![eof $database]} {
    set line [gets $database]
    set body [string tolower [lrange $line 2 end]]
     
    #lappend if we got a match
    if {[string match *$query* $body]} {
       lappend topics [lindex $line 0]
       incr matches
    }
  }

  #close the file
  close $database
 
  #send our list back to the proc who called us
  set topics  [lrange $topics 0 [expr $db(max) - 1]]
  return "$matches $topics"

} ;#end proc



#nick - retrive multiple topics from db, from author
proc nick {query} {

  #load some global variables
  global db
 
  #set some variables
  set database [open $db(file) r]
  set query    [string tolower $query]
  set topics   ""
  set matches  0
 
  #loop through the file
  while {![eof $database]} {
    set line [gets $database]
    set nick [string tolower [lindex $line 1]]

    #lappend if we got a match
    if {[string match $query $nick]} {
       lappend topics [lindex $line 0]
       incr matches
    }
  }

  #close the file
  close $database
 
  #send our list back to the proc who called us
  set topics  [lrange $topics 0 [expr $db(max) - 1]]
  return "$matches $topics"

} ;#end proc


#------------------------------------------


# db:display - Display a topic to a channel (a little messy proc, but who cares..)
proc db:display {nick host hand chan text} {

  #load some gloal variables
  global db botnick

  #set/redefine some variables
  set nickNorm1 $nick
  set nickNorm2 [lindex $text 1]
  set text      [split $text]
  set nick      [string tolower $nick]
  set nicky     [string tolower [lindex $text 1]]
  set chan      [string tolower $chan]
  set query     [lindex $text 0]
  set query2    [string tolower $query]
  set located   [lsearch -exact [string tolower [chanlist $chan]] $nicky]
  set explain2nick 0

  #check if we were told to explain to a nick
  if {$located > -1} {
     set explain2nick 1
     set nickNorm2 [lindex [chanlist $chan] $located]
  } elseif {$nicky != ""} {
     notice $nick "I dont see $nickNorm2 anywhere, displaying to the channel."  
  }

  #check if the channel is enabled, else return
  if {!$db(all) && [lsearch -exact $db(chans) $chan] == -1} {return}

  #if the args have not been specified, we'll return
  if {$query == ""} {return 0}

  #if the topic does not exist, tell the requestor - and return (set $match here, to save some cpu)
  set match [get $query]
  if {$match == ""} {priv $chan "'$query' is not defined."; return 0}

  #set our line-count variable and reply variable
  set counter [llength [split $match $db(newline)]]
  set query   [lindex $match 0]
  set answer  [lrange $match 2 end]

  #check if the topic was displayed within $db(timer) minutes
  if {$db(timer) == 1} {set grammar minute} {set grammar minutes}
  if {[info exists db($chan:$query2)] && !$explain2nick} {
     notice $nick "I displayed '$query' in $chan less than $db(timer) $grammar ago." 
     return 0
  } elseif {[info exists db($nicky:$query2)] && $explain2nick && $nicky == $nick} {
     notice $nick "I displayed '$query' to you less than $db(timer) $grammar ago."
     return 0
  } elseif {[info exists db($nicky:$query2)] && $explain2nick} {
     notice $nick "I displayed '$query' to '$nickNorm2' less than $db(timer) $grammar ago."
     return 0
  }
  
  #if we were told to msg the topic to a nick;
  if {$explain2nick} {
     
     #if the nick is the botnick, return
     if {$nicky == [string tolower $botnick]} {notice $nick "I'm not going to display it to myself moron!"; return 0}
     
     #set a grammar variable
     if {$counter == 1} {set grammar "line"} {set grammar "lines"}
    
     #tell the requestor that we're displaying the topic to the specified nick (if its not himself)
     if {$nick != $nicky} {notice $nick "Displayed '$query' to '$nickNorm2'."}

     #if the requestor is not the reciever, tell him who told us to display the topic for him.
     if {$nick != $nicky} {priv $nicky "$nickNorm1 wanted me to show you '$query', $counter $grammar:"}
     foreach line [split [join $answer] $db(newline)] {
        if {[info exists x]} {incr x} {set x 1}
        if {[catch {priv $nicky "($x/$counter) $line"} error]} {
           priv $chan "A problem occurred while compiling this definition. Please contact my administrator, \"$::admin\"."
           putlog "\[eggdb\] An error occurred while compiling the definition for \"$query\". Debug info follows:"
           foreach error [split $::errorInfo \n] {
              putlog "\[eggdb\] $error"
           }
           break
        }
     }
     
  #if we were told to msg the topic to the chan, as default;
  } else {
     
     #if the return is only one line;
     if {$counter == 1} {
     if {[catch {priv $chan "'$query', (1/1): [join $answer]"} error]} {
        priv $chan "A problem occurred while compiling this definition. Please contact my administrator, \"$::admin\"."
        putlog "\[eggdb\] An error occurred while compiling the definition for \"$query\". Debug info follows:"
        foreach error [split $::errorInfo \n] {
           putlog "\[eggdb\] $error"
        }

     }

     #if the return is several lines;
     } else {
        priv $chan "Displaying '$query', $counter lines:"
        foreach line [split [join $answer] $db(newline)] {
          if {[info exists x]} {incr x} {set x 1}
          if {[catch {priv $chan "($x/$counter) $line"} error]} {
             priv $chan "A problem occurred while compiling this definition. Please contact my administrator, \"$::admin\"."
             putlog "\[eggdb\] An error occurred while compiling the definition for \"$query\". Debug info follows:"
             foreach error [split $::errorInfo \n] {
                putlog "\[eggdb\] $error"
             }
             break
          }
        }
     }
  }

  #set the timer to keep the same topic to be displayed more than once in n-minutes
  if {$explain2nick} {
     set db($nicky:$query2) [timer $db(timer) [list unset db($nicky:$query2)]]
  } else {
     set db($chan:$query2) [timer $db(timer) [list unset db($chan:$query2)]]
  }

} ;#end proc



# db:search - Scan for a topic, with predefined *wildcards*
proc db:search {nick host hand chan text} {

  #load some global variables
  global db

  #check if the channel is enabled, else return
  if {!$db(all) && [lsearch -exact $db(chans) [string tolower $chan]] == -1} {return}

  #set some vars, and do some checking (consering the search-string from the user)
    set query [join [split $text] {*}]

    #if the args are blank, return
    if {$query == ""} {notice $nick "You did not specify a query."; return 0}
    
    #remove wildcards from left and right (possibly the whole string)
    set query  [string trimleft $query "*"]
    set query  [string trimright $query "*"]
    set query2 [string tolower $query]

    #if the string now is equal to "", the user searched for "*" - and we'll return
    if {$query == ""}  {notice $nick "Don't waste our time by searching for *."; return 0}
    if {$query == "?"} {notice $nick "Don't waste our time by searching for ?."; return 0}

    #check if the dude searched for the exact same string less than $db(timer) minutes ago
    if {[info exists db(search:$nick:$query2)]} {
       notice $nick "You searched for '*$query*' less than $db(timer) minutes ago, now take a break!"
       return 0
    } 

  #set some more variables
  set temp    [topics $query]
  set matches "/[lindex $temp 0]"
  set topics  [lrange $temp 1 end]
  set length  [string length [join $topics]]
  set number  [llength $topics]
  set first   [expr $number / 2]
  set second  [incr first]
  if {$number == 1} {set grammar "match"} {set grammar "matches"}
  
  #set our reply, depending on the result of the search  
  if {$length == 0} {
     notice $nick "No matches found for your query."
  } elseif {$length > 400} {
     notice $nick "Displaying $number$matches $grammar for your query: [join [lrange $topics 0 $first] {, }]"
     notice $nick "[join [lrange $topics $second end] {, }]"
  } else {
     notice $nick "Displaying $number$matches $grammar for your query: [join $topics {, }]"
  }

  #set the timer to keep the same topic to be displayed more than once in $db(timer) minutes
  set db(search:$nick:$query2) 1
  timer $db(timer) [list unset db(search:$nick:$query2)]


} ;#end proc



# db:special - Scan for a topic, with optional *wildcards*
proc db:special {nick host hand chan text} {

  #load some global variables
  global db

  #set/redefine some variables
  set text   [split $text]
  set query  [lindex $text 0]
  set query2 [string tolower $query]
  set chan   [string tolower $chan]

  #check if the channel is enabled, else return
  if {!$db(all) && [lsearch -exact $db(chans) $chan] == -1} {return 0}
 
  #if the args are not specified, return
  if {$query == ""} {notice $nick "You did not specify a query."; return 0}
  if {$query == "*"} {notice $nick "Don't waste our time by searching for *."; return 0}
  
  #check if the dude searched for the exact same string less than $db(timer) minutes ago
  if {[info exists db(specialsearch:$nick:$query2)]} {
     notice $nick "You searched for '$query' less than $db(timer) minutes ago, now take a break!"
     return 0
  } 
  
  #set some more variables
  set temp    [special $query]
  set matches "/[lindex $temp 0]"
  set topics  [lrange $temp 1 end]
  set length  [string length [join $topics]]
  set number  [llength $topics]
  set first   [expr $number / 2]
  set second  [incr first]
  if {$number == 1} {set grammar "match"} {set grammar "matches"}
  
  #set our reply, depending on the result of the search  
  if {$topics == ""} {
     notice $nick "No matches found for your query."
  } elseif {$length > 400} {
     notice $nick "Displaying $number$matches $grammar for your query: [join [lrange $topics 0 $first] {, }]"
     notice $nick "[join [lrange $topics $second end] {, }]"
  } else {
     notice $nick "Displaying $number$matches $grammar for your query: [join $topics {, }]"
  }

  #set the timer to keep the same topic to be displayed more than once in $db(timer) minutes
  set db(specialsearch:$nick:$query2) 1
  timer $db(timer) [list unset db(specialsearch:$nick:$query2)]

} ;#end proc



# db:body - Search a topic's body
proc db:body {nick host hand chan text} {

  #load some global variables
  global db

  #check if the channel is enabled, else return
  if {!$db(all) && [lsearch -exact $db(chans) [string tolower $chan]] == -1} {return 0}

  #set some vars, and do some checking (consering the search-string from the user)
    set query [join [split $text] {*}]

    #if the args now are blank, the user did not give us an idbut
    if {$query == ""} {notice $nick "You did not specify a query."; return 0}

    #remove wildcards from left and right (possibly the whole string)
    set query  [string trimleft $query "*"]
    set query  [string trimright $query "*"]
    set query2 [string tolower $query]

    #if the string now is equal to "", the user searched for "*" - and we'll return
    if {$query == ""} {notice $nick "Don't waste our time by searching for *."; return 0}
    if {$query == "?"} {notice $nick "Don't waste our time by searching for ?."; return 0}
    
    #check if the dude searched for the exact same string less than $db(timer) minutes ago
    if {[info exists db(bodysearch:$nick:$query2)]} {
       notice $nick "You searched for '*$query*' less than $db(timer) minutes ago, now take a break!"
       return 0
    } 

  #set some more variables
  set temp    [body $query]
  set matches "/[lindex $temp 0]"
  set topics  [lrange $temp 1 end]
  set length  [string length [join $topics]]
  set number  [llength $topics]
  set first   [expr $number / 2]
  set second  [incr first]
  if {$number == 1} {set grammar "match"} {set grammar "matches"}
  
  #set our reply, depending on the result of the search  
  if {$topics == ""} {
     notice $nick "No matches found for your query."
  } elseif {$length > 400} {
     notice $nick "Displaying $number$matches $grammar for your query: [join [lrange $topics 0 $first] {, }]"
     notice $nick "[join [lrange $topics $second end] {, }]"
  } else {
     notice $nick "Displaying $number$matches $grammar for your query: [join $topics {, }]"
  }

  #set the timer to keep the same topic to be displayed more than once in $db(timer) minutes
  set db(bodysearch:$nick:$query2) 1
  timer $db(timer) [list unset db(bodysearch:$nick:$query2)]

} ;#end proc



# db:nick - Search for a user's topics
proc db:nick {nick host hand chan text} {

  #load some global variables
  global db

  #set some more variables
  set text   [split $text]
  set query  [lindex $text 0]
  set query2 [string tolower $query]
  set hand   [string tolower $hand]
  set chan   [string tolower $chan]

  #check if the channel is enabled, else return
  if {!$db(all) && [lsearch -exact $db(chans) $chan] == -1} {return}

  #check if we got a nick to search for
  if {$query == ""}  {notice $nick "You did not specify a nick to search for."; return 0}

  #check for the right access
  if {![isvoice $nick $chan] && ![isop $nick $chan] && ![matchattr $hand v|v $chan] && ![matchattr $hand o|o $chan]} { 
     notice $nick "You do not have access to use this command."
     return 0
  }
  
  #check if the query contains wildcards, which we wont allow (dont know any 'fancy' regexp way todo this though :-/)
  for {set i 0} {$i < [string length $query]} {incr i} {
      if {[string index $query $i] == "*"} {
         notice $nick "No wildcard-matching allowed when searching for a user's topics."
         return 0
      }
  }
  
  #check if the dude searched for the exact same string less than $db(timer) minutes ago
  if {[info exists db(nicksearch:$nick:$query2)]} {
     notice $nick "You searched for '$query' less than $db(timer) minutes ago, now take a break!"
     return 0
  } 
  
  #set some more variables
  set temp    [nick $query]
  set matches "/[lindex $temp 0]"
  set topics  [lrange $temp 1 end]
  set length  [string length [join $topics]]
  set number  [llength $topics]
  set first   [expr $number / 2]
  set second  [incr first]
  if {$number == 1} {set grammar "match"} {set grammar "matches"}
  
  #set our reply, depending on the result of the search  
  if {$topics == ""} {
     notice $nick "No matches found for your query."
  } elseif {$length > 400} {
     notice $nick "Displaying $number$matches $grammar for your query: [join [lrange $topics 0 $first] {, }]"
     notice $nick "[join [lrange $topics $second end] {, }]"
  } else {
     notice $nick "Displaying $number$matches $grammar for your query: [join $topics {, }]"
  }

  #set the timer to keep the same topic to be displayed more than once in $db(timer) minutes
  set db(nicksearch:$nick:$query2) 1
  timer $db(timer) [list unset db(nicksearch:$nick:$query2)]
  
} ;#end proc



# db:define - learn a new topic
proc db:define {nick host hand chan text} {

  #load some global variables
  global db

  #set some variables
  set text  [split $text]
  set query [lindex $text 0]
  set def   [lrange $text 1 end]
  set hand  [string tolower $hand]
  set chan  [string tolower $chan]
  if {$hand == "*"} {set hand "${nick}(*)"}

  #check if the channel is enabled, else return
  if {!$db(all) && [lsearch -exact $db(chans) $chan] == -1} {return}

  #check if the args were specified, else return
  if {$query == ""} {notice $nick "You did not specify a topic"; return 0}
  if {$def == ""} {notice $nick "You did not specify a definition"; return 0}

  #check the user for the right access
  if {![isvoice $nick $chan] && ![isop $nick $chan] && ![matchattr $hand o|o $chan] && ![matchattr $hand v|v $chan]} { 
     notice $nick "You do not have access to use this command."
     return 0
  }

  #add the topic/body  
  if {[get $query] == ""} {
     add "$query $hand $def"
     notice $nick "'$query' defined."
  } else {
     notice $nick "'$query' is already defined. You need to remove/replace it."
  }

} ;#end proc



# db:forget - delete a topic from the db
proc db:forget {nick host hand chan text} {

  #load some global variables
  global db

  #set some variables
  set text   [split $text]
  set hand   [string tolower $hand]
  set query  [string tolower [lindex $text 0]]
  set match  [get $query]
  set author [lindex $match 1]
  set chan   [string tolower $chan]
 
  #check if the channel is enabled, else return
  if {!$db(all) && [lsearch -exact $db(chans) $chan] == -1} {return}

  #check if the args were spcified, if not, return
  if {$query == ""} {notice $nick "You did not specify a topic to remove."; return 0}
 
  #check if there is such a topic
  if {$match == ""} {notice $nick "'$query' is not defined in my db."; return 0}

  #check for access
  if {$author == $hand || ($author == "${nick}(*)" && [isvoice $nick $chan]) || [isop $nick $chan] || [matchattr $hand o|o $chan]} {
     del $query
     notice $nick "'$query' removed."
  } elseif {[isvoice $nick $chan] || [matchattr $hand v|v $chan]} {
     notice $nick "Sorry, you are not authorized to remove '$query', set by '$author'. You need to be an op to remove a topic that is set by another user than yourself."
     return 0
  } else {
     notice $nick "You do not have access to use this command."
     return 0
  }
    
  #remove the memory of the topic, if there is one
  foreach element [array names db] {
     if {[string match "*:$query" $element]} {
        killtimer $db($element)
        unset db($element)
     }
  }
    
} ;#end proc



# db:whoset - check who set a topic
proc db:whoset {nick host hand chan text} {

  #load some global variables
  global db
  
  #set some variables
  set text   [split $text]
  set query  [lindex $text 0]
  set match  [get $query]
  set author [lindex $match 1]
  set hand   [string tolower $hand]
  set chan   [string tolower $chan]

  #check if the channel is enabled, else return
  if {!$db(all) && [lsearch -exact $db(chans) $chan] == -1} {return 0} 

  #check if the args were spcified
  if {$query == ""} {notice $nick "You did not specify a topic."; return 0}

  #check for access
  if {![isop $nick $chan] && ![isvoice $nick $chan] && ![matchattr $hand v|v $chan] && ![matchattr $hand o|o $chan]} {
     notice $nick "You do not have access to use this command."
     return 0
  }

  #check if there was a match
  if {$match == ""} {
     notice $nick "'$query' is not defined in my db."
  } else {
     notice $nick "'$query' was set by '$author'."
  }

} ;#end proc



# db:replace - replace a topic (delete+add)
proc db:replace {nick host hand chan text} {

  #load some global variables
  global db

  #set some variables  
  set text    [split $text]
  set def     [lrange $text 1 end]
  set query   [string tolower [lindex $text 0]]
  set match   [get $query]
  set author  [lindex $match 1]
  set old_def [lrange $match 2 end]
  set hand    [string tolower $hand]
  set chan    [string tolower $chan]
  
  #check if the channel is enabled, else return
  if {!$db(all) && [lsearch -exact $db(chans) $chan] == -1} {return 0} 

  #check if the args were specified, else return
  if {$query == ""} {notice $nick "You did not specify a topic to replace."; return 0}
  
  #check for access
  if {($author == $hand || [isop $nick $chan] || [matchattr $hand o|o $chan]) || ($author == "${nick}(*)" && [matchattr $hand v|v $chan])} {

     #return if the user specified an invalid topic 
     if {$match == ""} {notice $nick "'$query' is not defined in my db."; return 0}
    
     #return if the new definition equals the old one
     if {[string equal -nocase $old_def $def]} {notice $nick "Replacement definition for '$query' is identical to the old one."; return 0}
    
     #delete & add, set some returned msg's
     del $query
     add "$query $hand $def"
     notice $nick "'$query' replaced."

  } elseif {[isvoice $nick $chan] || [matchattr $hand v|v $chan]} {

     #return if the user specified an invalid topic
     if {$match == ""} {notice $nick "$query is not defined in my db."; return 0}

     #tell the user that he does not have access      
     notice $nick "Sorry, you are not authorized to replace '$query', set by '$author'. You need to be an op to replace a topic that is set by another user than yourself."

  } else {

     #tell the user that he does not, at all, have access :P
     notice $nick "You do not have access to use this command."
  }

  #remove the memory of the topic, if there is one
  foreach element [array names db] {
     if {[string match "*:$query" $element]} {
        killtimer $db($element)
        unset db($element)
     }
  }

} ;#end proc



# Give me som credits
putlog "eggdrop db v1.2 by gozzer loaded"



# Version history:
#
# » January 1st, 2002
#   Script is released.
#
# » July 28th, 2004
#   Added some functionality. The script does now remove memory of
#   a displayed topic to a nick, when the topic is replaced or deleted.
#   This differs from the old version, where the script only removed memory of
#   the public display of the topic, in the channel.
#   The script will also return an error message if you replacement for a definition is
#   identical to the old one, instead of overwriting the entry in the database file. 
#   This can help to prevent redundant disk wearing.
#
# » January 10th, 2005
#   Got reports that the § and other special characters did not function properly on
#   some systems. This should now be solved, when using binary encode for the filehandle.
#   I also made a few changes to the routine that handles weirdo and unmatched characters
#   in a string. Lets hope this eliminates compile-problems once and for all.