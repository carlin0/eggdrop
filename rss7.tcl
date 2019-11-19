##############################################################################################
##  ##     rssreader.tcl for eggdrop by Ford_Lawnmower irc.geekshed.net #Script-Help    ##  ##
##############################################################################################
## .rss in the party line for commands and syntax. Example Feed Add Below:                  ##
##.rss add #Hawkee hawkee Hawkee http://www.hawkee.com/comment.rss.php?tool_type=snippet_id ##
##############################################################################################
##      ____                __                 ###########################################  ##
##     / __/___ _ ___ _ ___/ /____ ___   ___   ###########################################  ##
##    / _/ / _ `// _ `// _  // __// _ \ / _ \  ###########################################  ##
##   /___/ \_, / \_, / \_,_//_/   \___// .__/  ###########################################  ##
##        /___/ /___/                 /_/      ###########################################  ##
##                                             ###########################################  ##
##############################################################################################
##  ##                             Start Setup.                                         ##  ##
##############################################################################################
namespace eval rssreader {
## Edit textf to change the color/state of the text shown                               ##  ##
  variable textf ""
## Edit linkf to change the color/state of the links                                    ##  ##
  variable linkf ""
## Change usetiny to shorten links with tinyurl. 1 = on , 0 = off                       ##  ##  
  variable usetiny 1
## Change useisgd to shorten links with is.gd. 1 = on , 0 = off                         ##  ##  
  variable useisgd 0
## Edit maxresults to the amount of results you want per query. This will not cause     ##  ##
## You to lose results. It will only spread them out over several querys.               ##  ##
  variable maxresults 2
## Edit checkdelay to change the frequency feed pages are checked. Delay is in minutes. ##  ##
  variable checkdelay 3
## Edit startupdelay to add delay to startup/restart. Delay is in minutes.              ##  ##
  variable startupdelay 2
##############################################################################################
##  ##                           End Setup.                                              ## ##
##############################################################################################   
  package require http
  bind dcc - rss rssreader::settings
  bind evnt -|- init-server rssreader::loadhash
  bind evnt -|- prerehash rssreader::loadhash
  proc settings {hand idx text} {
    set choice [lindex $text 0]; set channel [lindex $text 1]
    set name [lindex $text 2]; set logo [lindex $text 3]
   set link [lindex $text 4]
   if {[string equal -nocase "add" $choice] && $link != ""} {
     set deleteinfo [string map {\[ ? \] ?} [hget "rssreader" $name]]
     if {[set indx [lsearch -glob [timers] "*$deleteinfo*"]] != -1 && $deleteinfo != "0"} {
       killtimer [lindex [lindex [timers] $indx] 2]
     }
     hadd "rssreader" "$name" "rssreader::main {$channel $logo $link}"
     savehash
     putdcc $idx "Added feed $name to $channel as $logo $link"
     rssreader::main "$channel $logo $link"
   } elseif {[string equal -nocase "addxml" $choice] && $link != ""} {
     set deleteinfo [string map {\[ ? \] ?} [hget "rssreader" $name]]
     if {[set indx [lsearch -glob [timers] "*$deleteinfo*"]] != -1 && $deleteinfo != "0"} {
       killtimer [lindex [lindex [timers] $indx] 2]
     }
     hadd "rssreader" "$name" "rssreader::type2 {$channel $logo $link}"
     savehash
     putdcc $idx "Added feed $name to $channel as $logo $link"
     rssreader::type2 "$channel $logo $link"
   } elseif {[string equal -nocase "addssl" $choice] && $link != ""} {
     set deleteinfo [string map {\[ ? \] ?} [hget "rssreader" $name]]
     if {[set indx [lsearch -glob [timers] "*$deleteinfo*"]] != -1 && $deleteinfo != "0"} {
       killtimer [lindex [lindex [timers] $indx] 2]
     }
     hadd "rssreader" "$name" "rssreader::type3 {$channel $logo $link}"
     savehash
     putdcc $idx "Added feed $name to $channel as $logo $link"
     rssreader::type3 "$channel $logo $link"     
   } elseif {[string equal -nocase "list" $choice]} {
     putdcc $idx "\[RSS list\]"
     set count [hfind "rssreader" "*" 0]; set counter 1
     while {$count >= $counter} {
       putdcc $idx "[hfind "rssreader" "*" $counter]"
      incr counter
     }
   } elseif {[string equal -nocase "info" $choice] && $channel != ""} {
     putdcc $idx "[hget "rssreader" $channel]"
   } elseif {[string equal -nocase "delete" $choice] && $channel != ""} {
     set deleteinfo [string map {\[ ? \] ?} [hget "rssreader" $channel]]
     hdel "rssreader" $channel
     savehash
     if {[set indx [lsearch -glob [timers] "*$deleteinfo*"]] != -1 && $deleteinfo != "0"} {
       killtimer [lindex [lindex [timers] $indx] 2]
      putdcc $idx "Removed $channel from RSS"
     } else {
       putdcc $idx "$channel not found"
     }
   } elseif {[string equal -nocase "timers" $choice]} {
     putdcc $idx [timers]
   } elseif {[string equal -nocase "rehash" $choice]} {
     putdcc $idx "rehashing rss...."
     hfree rsstempold
     hfree rsstempnew
     putdcc $idx "done"
   } else {
     putdcc $idx "\[RSS Syntax\]"
     putdcc $idx "Add Feed: .rss add <#chan1,#chan2,#chanetc> <name> <logo> <link>"
     putdcc $idx "Add Xml Feed: .rss addxml <#chan1,#chan2,#chanetc> <name> <logo> <link>"
     putdcc $idx "Add SSL Feed: .rss addssl <#chan1,#chan2,#chanetc> <name> <logo> <link>"
     putdcc $idx "Delete Feed: .rss delete <name>"
     putdcc $idx "Info Feed: .rss info <name>"
     putdcc $idx "List Feeds: .rss list"
     putdcc $idx "Help Feeds: .rss"
    }   
  }
  proc main {text} {
    set chan [lindex $text 0]; set logo [lindex $text 1]; set linker [lindex $text 2]
    set title ""; set link ""; set description ""; set maxcount 1; set json ""
    if {[set indx [lsearch -glob [timers] "*rssreader::main {$chan [string map {\[ ? \] ?} $logo] ${linker}}*"]] != -1} { 
      killtimer [lindex [lindex [timers] $indx] 2] 
    }
    timer $rssreader::checkdelay "rssreader::main {$chan $logo $linker}"
    set rssreaderurl "/ajax/services/feed/load?v=1.0&q=${linker}"
    set rssreadersite "ajax.googleapis.com"; set rssout ""
    if {[catch {set rssreadersock [socket -async $rssreadersite 80]} sockerr]} {
      return 0
    } else {
      puts $rssreadersock "GET $rssreaderurl HTTP/1.0"
      puts $rssreadersock "Host: $rssreadersite"
      puts $rssreadersock "User-Agent: Opera 9.6"
     puts $rssreadersock "Connection: close"
      puts $rssreadersock ""
      flush $rssreadersock
      while {![eof $rssreadersock]} {
        set rssreadervar " [string map {<![CDATA[ "" ]]> "" \$ \002\$\002 \[ \( \] \)} [gets $rssreadersock]] "
      if {[regexp {\"responseStatus\":\s?400} $rssreadervar]} {
        if {[set indx [lsearch -glob [timers] "*rssreader::main {$chan $logo ${linker}}*"]] != -1} { 
            killtimer [lindex [lindex [timers] $indx] 2] 
          }
        type2 "$chan $logo $linker"
        close $rssreadersock
        return
      } else {
        regexp {\:\[(\{.*)$} $rssreadervar match rssout
        set rssout [regexp -all -inline {\{(.*?)\}} $rssout]
        if {$rssout != ""} {
          set count 0
          foreach {match matched} $rssout {
           incr count
            set matched [regexp -all -inline {(".*?":".*?"\,)} $match]
              foreach {innermatch innermatched} $matched {
             regexp  {\"(.*?)\":\".*?\"\,} $innermatch match varname
                regexp  {\".*?\":\"(.*?)\"\,} $innermatch match value
            set value [string map {\$ \002\$\002 \] \002\]\002 \[ \002\[\002} $value]
             set $varname $value
           }
           if {[hfindexact "rsstempold" "${link}" 1] != $link} {
             if {$title == ""} { set title $description }
            set linked $link
            if {$rssreader::usetiny} { set linked [string trimright [tiny $link]] }
            if {$rssreader::useisgd} { set linked [string trimright [isgd $link]] }
            if {$maxcount <= $rssreader::maxresults} {
               putserv "PRIVMSG $chan :${logo} ${rssreader::textf}[dehex $title] ${rssreader::linkf}${linked}"
               incr maxcount
              hadd "rsstempnew" $link 1
            } 
           }
            }
          hfree rsstempold
          hcopy rsstempnew rsstempold
         rssreader::savetemphash
          }
      }
      }
     close $rssreadersock
    } 
  }
  proc type2 {text} {
    set chan [lindex $text 0]; set logo [lindex $text 1]; set linker [lindex $text 2]
    set title ""; set link ""; set description "" 
    if {[set indx [lsearch -glob [timers] "*rssreader::type2 {$chan [string map {\[ ? \] ?} $logo] ${linker}}*"]] != -1} { 
      killtimer [lindex [lindex [timers] $indx] 2] 
    }
    timer $rssreader::checkdelay "rssreader::type2 {$chan $logo $linker}"
    regexp -- {https?\:\/\/(.*?)(\/.*)$} $linker wholematch rsstype2site rsstype2url
    set itemfound 0 ; set maxcount 1
    if {[catch {set rsstype2sock [socket -async $rsstype2site 80]} sockerr]} {
      return 0
    } else {
      puts $rsstype2sock "GET $rsstype2url HTTP/1.0"
      puts $rsstype2sock "Host: $rsstype2site"
      puts $rsstype2sock "User-Agent: Opera 9.6"
      puts $rsstype2sock "Connection: close"
      puts $rsstype2sock ""
      flush $rsstype2sock
      while {![eof $rsstype2sock]} {
        set rsstype2var " [string map {<![CDATA[ "" ]]> "" \$ \002\$\002 \[ \( \] \)} [gets $rsstype2sock]] "   
        if {[string match {*<item>*} $rsstype2var]} { set itemfound 1 }
        if {[regexp {<title>(.*?)(?:<\/title>|$)} $rsstype2var match title]} { }
        if {[regexp {<link>(.*?)(?:<\/link>|$)} $rsstype2var match link]} { }
        if {[string match {*</item>*} $rsstype2var]} {
          if {[hfindexact "rsstempold" "${link}" 1] != $link} {
            if {$itemfound} {
              if {$maxcount <= $rssreader::maxresults} {
                set linked $link
                if {$rssreader::usetiny} { set linked [string trimright [tiny $link]] }
                if {$rssreader::useisgd} { set linked [string trimright [isgd $link]] }
                putserv "PRIVMSG $chan :${logo} ${rssreader::textf}[dehex $title] ${rssreader::linkf}${linked}"
                incr maxcount
                hadd "rsstempnew" $link 1
              } 
            }
          }
        }
     }
     set itemfound 0
     hfree rsstempold
     hcopy rsstempnew rsstempold
     rssreader::savetemphash
     close $rsstype2sock
    } 
  }
  proc type3 {text} {
    set chan [lindex $text 0]; set logo [lindex $text 1]; set linker [lindex $text 2]
    set title ""; set link ""; set description "" 
    if {[set indx [lsearch -glob [timers] "*rssreader::type3 {$chan [string map {\[ ? \] ?} $logo] ${linker}}*"]] != -1} { 
      killtimer [lindex [lindex [timers] $indx] 2] 
    }
    timer $rssreader::checkdelay "rssreader::type3 {$chan $logo $linker}"
    regexp -- {https?\:\/\/(.*?)(\/.*)$} $linker wholematch rsstype3site rsstype3url
    set itemfound 0 ; set maxcount 1 ; set count 1 ; set counter 1
    ::http::register https 443 tls::socket
    set type3searchtoken [::http::geturl "https://${rsstype3site}${rsstype3url}"]
    set type3searchdata [string map {<!\[CDATA\[ \"\" \]\]> "" \$ \\\$ \[ \\\[ \] \\\]} [::http::data $type3searchtoken]]
    ::http::cleanup $type3searchtoken
    ::http::unregister https
    set title [regexp -all -inline {<title>(.*?)<\/title>} $type3searchdata]
    set link [regexp -all -inline {<link>(.*?)<\/link>} $type3searchdata]
    while {$counter <= [llength $title]} {
      set thislink [lindex ${link} $counter]
      if {[hfindexact "rsstempold" "${thislink}" 1] != $thislink} {
        if {$maxcount <= $rssreader::maxresults} {
          set linked $thislink
          if {$rssreader::usetiny} { set linked [string trimright [tiny $thislink]] }
          if {$rssreader::useisgd} { set linked [string trimright [isgd $thislink]] }
          putserv "PRIVMSG $chan :${logo} ${rssreader::textf}[dehex [lindex $title $counter]] ${rssreader::linkf}${linked}"
          hadd "rsstempnew" $thislink 1
          incr maxcount 1
        }
        incr count 2
      }
      incr counter 2
    }
    hfree rsstempold
    hcopy rsstempnew rsstempold
    rssreader::savetemphash
  }  
  proc tiny {link} {
    set tinysite tinyurl.com
    set tinyurl /api-create.php?url=[urlencode ${link}]
    if {[catch {set tinysock [socket -async $tinysite 80]} sockerr]} {
      putlog "$tinysite $tinyurl $sockerr error"
      return $link
    } else {
      puts $tinysock "GET $tinyurl HTTP/1.0"
      puts $tinysock "Host: $tinysite"
      puts $tinysock "User-Agent: Opera 9.6"
     puts $tinysock "Connection: close"
      puts $tinysock ""
      flush $tinysock
      while {![eof $tinysock]} {
        set tinyvar " [gets $tinysock] "
        if {[regexp {(http:\/\/.*)} $tinyvar match tinyresult]} {
          close $tinysock
          return [string map {http:// https://} $tinyresult]
        }
      }
      close $tinysock
      return $link
    }
  }
  proc isgd {link} {
    set isgdsite is.gd
    set isgdurl /create.php?format=simple&url=[urlencode ${link}]
    if {[catch {set isgdsock [socket -async $isgdsite 80]} sockerr]} {
      putlog "$isgdsite $isgdurl $sockerr error"
      return $link
    } else {
      puts $isgdsock "GET $isgdurl HTTP/1.0"
      puts $isgdsock "Host: $isgdsite"
      puts $isgdsock "User-Agent: Opera 9.6"
      puts $isgdsock "Connection: close"
      puts $isgdsock ""
      flush $isgdsock
      while {![eof $isgdsock]} {
        set isgdvar " [gets $isgdsock] "
        if {[regexp {(http:\/\/.*)} $isgdvar match isgdresult]} {
          close $isgdsock
          return $isgdresult
        }
      }
      close $isgdsock
      return $link
    }
  }
  proc hex {decimal} { return [format %x $decimal] }
  proc decimal {hex} { return [expr 0x$hex] }
  proc dehex {string} {
    regsub -all {^\{|\}$} $string "" string
    set string [subst [regsub -nocase -all {\\u([a-f0-9]{4})} $string {[format %c [decimal \1]]}]]
    set string [subst [regsub -nocase -all {\%([a-f0-9]{2})} $string {[format %c [decimal \1]]}]]
    set string [subst [regsub -nocase -all {\&#([0-9]{4});} $string {[format %c \1]}]]
    set string [subst [regsub -nocase -all {\&#x([0-9]{2});} $string {[format %c [decimal \1]]}]]
    set string [string map {&quot; \" &middot; · &amp; & <b> \002 </b> \002 &ndash; – &raquo; \
    » &laquo; « &Uuml; Ü &uuml; ü &Aacute; Á &aacute; á &Eacute; É &eacute; é &Iacute; Í &iacute; \
    í &Oacute; Ó &oacute; ó &Ntilde; Ñ &ntilde; ñ &Uacute; Ú &uacute; ú &aelig; æ &nbsp; " " &apos; \' \
   \( \002\(\002 \) \002\)\002 \{ \002\{\002 \} \002\}\002} $string]
    return $string
  }
  proc urlencode {string} {
    regsub -all {^\{|\}$} $string "" string
    return [subst [regsub -nocase -all {([^a-z0-9\+])} $string {%[format %x [scan "\\&" %c]]}]]
  }
  proc hadd {hashname hashitem hashdata } {
    global $hashname
    set ${hashname}($hashitem) $hashdata
  }
  proc hget {hashname hashitem} {
    upvar #0 $hashname hgethashname
   if {[info exists hgethashname($hashitem)]} {
     return $hgethashname($hashitem)
   } else {
     return 0
   }
  }
  proc hfind {hashname search value} {
    upvar #0 $hashname hfindhashname
   if {[array exists hfindhashname]} {
     if {$value == 0} {
       return [llength [array names hfindhashname $search]]
      } else {
        set value [expr $value - 1]
       return [lindex [array names hfindhashname $search] $value]
     }
   }
  }
  proc hfindexact {hashname search value} {
    upvar #0 $hashname hfindhashname
   if {[array exists hfindhashname]} {
     if {$value == 0} {
       return [llength [array names hfindhashname -exact $search]]
      } else {
        set value [expr $value - 1]
       return [lindex [array names hfindhashname -exact $search] $value]
     }
   }
  }
  proc hsave {hashname filename} {
    upvar #0 $hashname hsavehashname
   if {[array exists hsavehashname]} {
     set hsavefile [open $filename w]
     foreach {key value} [array get hsavehashname] {
       puts $hsavefile "${key}=${value}"
     }
     close $hsavefile
   }
  }
  proc hload {hashname filename} {
    upvar #0 $hashname hloadhashname
   hfree $hashname
   set hloadfile [open $filename]
   set linenum 0
   while {[gets $hloadfile line] >= 0} {
     if {[regexp -- {([^\s]+)=(.*)$} $line wholematch item data]} {
       set hloadhashname($item) $data
     }
    }
   close $hloadfile
  }
  proc hfree {hashname} {
    upvar #0 $hashname hfreehashname
   if {[array exists hfreehashname]} {
      foreach key [array names hfreehashname] { 
       unset hfreehashname($key) 
     }
   }
  }
  proc hdel {hashname hashitem} {
    upvar #0 $hashname hdelhashname
   if {[info exists hdelhashname($hashitem)]} {
     unset hdelhashname($hashitem)
   }
  }
  proc hcopy {hashfrom hashto} {
   upvar #0 $hashfrom hashfromlocal $hashto hashtolocal
   array set hashtolocal [array get hashfromlocal]
  } 
  proc savetemphash {} {
    #hsave "rsstempnew" "${::network}rsstemp.hsh"
  }
  proc savehash {} {
    hsave "rssreader" "${::network}rssreader.hsh"
  }
  proc loadhash {type} {
    if {[file exists "${::network}rssreader.hsh"]} { 
     rssreader::hload "rssreader" "${::network}rssreader.hsh" 
   }
   if {[file exists "${::network}rsstemp.hsh"]} { 
     #rssreader::hload "rsstempnew" "${::network}rsstemp.hsh"
     #rssreader::hload "rsstempold" "${::network}rsstemp.hsh"     
   }
    set count $rssreader::startupdelay
    foreach {key value} [array get ::rssreader] {
      if {[set indx [lsearch -glob [timers] "*$value*"]] != -1} {
       killtimer [lindex [lindex [timers] $indx] 2]
      }
      timer $count $value
      incr count
    }
  }  
}
putlog "\002*Loaded* \017\00304\002RSS Reader\017 \002by \
Ford_Lawnmower irc.GeekShed.net #Script-Help .rss for help"
