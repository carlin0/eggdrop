#################################################################################################
#                                                                                               #
# CodeNinja Help System v1.0                                                                    #
#                                                                                               #
# Please see README before using this script                                                    #
#                                                                                               #
# To report bugs and give feedback, email me at codeninja68@gmail.com                           #
#                                                                                               #
# For updates, check out http://bit.ly/codeninjacodes                                           #
#                                                                                               #
# Tradotta in italiano da Carlin0                                                               #
#################################################################################################

namespace eval codeninja {
    namespace eval helpsys {

        # Directory where help files are stored (make sure to end with a /)
        variable dir "cmds/"

        # Available topics and files associated with them
        # More info in README
        variable topics {
	main    main.help
	quote  quote.help
	database database.help
        }

        # Public help command
        variable pcmd "!aiuto"

        # Message help command
        variable mcmd "help"

        # Sending method (0 = PRIVMSG, 1 = NOTICE)
        variable smeth 1
    }
}

# END CONFIG

namespace eval codeninja {
    namespace eval helpsys {
        variable version "v1.0"
    }
}

namespace eval codeninja {
    namespace eval helpsys {
        proc helppub {nick uhost hand chan text} {
            helpmain $nick $text
        }

        proc helpmsg {nick uhost hand text} {
            helpmain $nick $text
        }

        proc helpmain {nick text} {
            set arg [lindex $text 0]
            if {[string trim $arg] == ""} { set arg "main"
            }
            # if no argument, use main
            set filesock ""
            foreach {topic file} ${codeninja::helpsys::topics} {
                if {[string match -nocase $topic $arg]} {
                    set filesock [open "${codeninja::helpsys::dir}$file" r]
                }
            }
            # decide which file to use
            if {$filesock == ""} { puthelp "[pmnot] $nick :Nessun aiuto disponibile"
                return
            }
            # if no file is found, tell the user
            set cmdlist [split [read $filesock] "\n"]
            close $filesock
            # read file into $cmdlist
            foreach line $cmdlist {
                    if {$line != ""} { puthelp "[pmnot] $nick :$line" }
                    # output to user
            }
        }
        proc pmnot {} {
            if {${codeninja::helpsys::smeth}} { return "NOTICE" } else { return "PRIVMSG" }
        }
        proc diagnostics {} {
            regsub {\s{2,}} ${codeninja::helpsys::topics} { } codeninja::helpsys::topics
            if {![file isdirectory ${codeninja::helpsys::dir}]} { error "${codeninja::helpsys::dir} non è una cartella valida" }
            if {![regexp {(.+)\/} ${codeninja::helpsys::dir}]} { error "La variabile \"dir\" non è stata impostata correttamente" }
            foreach {topic file} ${codeninja::helpsys::topics} {
                if {![file exists ${codeninja::helpsys::dir}$file]} { error "${codeninja::helpsys::dir}$file non esiste" }
            }
        }
    }
}

codeninja::helpsys::diagnostics

bind pub - ${codeninja::helpsys::pcmd} codeninja::helpsys::helppub
bind msg - ${codeninja::helpsys::mcmd} codeninja::helpsys::helpmsg

putlog "CodeNinja Help System ${codeninja::helpsys::version} loaded"
