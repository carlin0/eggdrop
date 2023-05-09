proc bs_nickbot {nick uhost arg} {
  
putserv "NICK $arg"

}

putlog "Partyline Botnick changer Loaded - .botnick <nick>"

bind dcc - botnick bs_nickbot
