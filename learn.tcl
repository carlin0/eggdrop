# description: store some various information, new information can be added by public command !add and after
# you can view this info by typing ? <command_name>

# use: run script, and use !help on the channel, only op can add, replace, delete, rename, append 
# if you want to allow normal users to add/del/rep etc. you have to change bind from o|o to -|-

# Author: tomekk
# e-mail:  tomekk/@/oswiecim/./eu/./org
# home page: http://tomekk.oswiecim.eu.org/
# tradotto in italiano da Carlin0 <carlin0@email.it>
# 
# Version 0.6
#
# This file is Copyrighted under the GNU Public License.
# http://www.gnu.org/copyleft/gpl.html

# added: some notices
# added: !stored command, shows stored commands
# fixed: removed !help command, now each command has its own help, just type !<command_name> without arguments
# added: now its possible to set on which channels should this script work

# if you want to use this script on your chan, type in eggdrop console (via telnet or DCC chat)
# .chanset #channel_name +learn
# and later .save

# available commands: !add, !del, !rep, !app, !ren, ? <cmd_name>, !stored

# dir with stored files
set dirname "learn.db"

################################################################################################
bind pub f|f !add add_fct
bind pub m|m !del del_fct
bind pub f|f !rep rep_fct
bind pub f|f !app app_fct
bind pub f|f !ren ren_fct
bind pub - ? show_fct
bind pub - !stored stored_cmds
bind pub - !elenco stored_cmds

setudef flag learn

if {[file exists $dirname] == 0} {
	file mkdir $dirname
}

proc create_db { dbname definfo } {
	if {[file exists $dbname] == 0} {
		set crtdb [open $dbname a+]
		puts $crtdb "$definfo"
		close $crtdb
	}
}

proc readdb { rdb } {
	global dbout
	set fs_open [open $rdb r]
	gets $fs_open dbout
	close $fs_open
}

proc add_fct { nick uhost hand chan arg } {
	global dirname

	if {![channel get $chan learn]} {
		return                  
	}    
	
	set txt [split $arg]

	set cmd [string tolower [lindex $txt 0]]

	set msg [join [lrange $txt 1 end]]

	if {$msg != ""} {
		if {[file exists $dirname/$cmd] == 0} {
			create_db "$dirname/$cmd" "$msg"
			putquick "NOTICE $nick :'$cmd' é stato aggiunto"
		} {
			putquick "NOTICE $nick :'$cmd' ha già una definizione"
		}
	} {
		putquick "NOTICE $nick :scrivi: !add <cmd_name> <info>"
	}
}

proc show_fct { nick uhost hand chan arg } {
	global dbout dirname

	if {![channel get $chan learn]} {
		return
	}

	set txt [string tolower [split $arg]]

	set cmd [lindex $txt 0]

	if {$cmd != ""} {
		foreach files $txt {
			if {$files != ""} {
				if {[file exists $dirname/$files] == 1} {
					readdb $dirname/$files
					putquick "PRIVMSG $chan :$files: $dbout"
				} {
					putquick "NOTICE $chan :'$files' non esiste"
				}
			}
		}
	} {
		putquick "NOTICE $nick :scrivi: ? <cmd_name> ... <cmd_name>"
	}
}

proc del_fct { nick uhost hand chan arg } {
	global dirname

	if {![channel get $chan learn]} {
		return
	}

	set all_files [glob -tails -directory $dirname -nocomplain -type f *]
	
	set txt [string tolower [split $arg]]

        set cmd [lindex $txt 0]

	if {$cmd != ""} {
		if {$cmd == "all_cmds"} {
			foreach xfiles $all_files {
				file delete $dirname/$xfiles
				putquick "NOTICE $nick :tutti i comandi sono stati cancellati"
			}
		}

		if {$cmd != "all_cmds"} {
			foreach files $txt {
				if {$files != ""} {
					if {[file exists $dirname/$files] == 1} {
						file delete $dirname/$files
						putquick "NOTICE $nick :'$cmd' é stato cancellato"
					} {
						putquick "NOTICE $nick :'$cmd' non esiste"
					}
				}
			}
		}
	} {
		putquick "NOTICE $nick :scrivi: !del all_cmds o !del <cmd_name> ... <cmd_name>"
	}
}

proc rep_fct { nick uhost hand chan arg } {
	global dirname

	if {![channel get $chan learn]} {
		return
	}

	set txt [split $arg]

        set cmd [string tolower [lindex $txt 0]]

        set msg [join [lrange $txt 1 end]]

	if {$msg != ""} {
		if {[file exists $dirname/$cmd] == 1} {
			file delete $dirname/$cmd
			create_db "$dirname/$cmd" "$msg"
			putquick "NOTICE $nick :'$cmd' é stato cambiato"
		} {
			putquick "NOTICE $nick :'$cmd' non esiste"
		}
	} {
		putquick "NOTICE $nick :scrivi: !rep <cmd_name> <new_info>"
	}
}

proc app_fct { nick uhost hand chan arg } {
	global dirname dbout

	if {![channel get $chan learn]} {
		return
	}
	
	set txt [split $arg]
	
	set start [lindex $txt 0]

	set cmd [string tolower [lindex $txt 1]]

	set app_info [join [lrange $txt 2 end]]

	if {$app_info != "" } {
		if {[file exists $dirname/$cmd] == 1} {		
			if {$start == "fb"} {
				readdb $dirname/$cmd
				file delete $dirname/$cmd
				create_db "$dirname/$cmd" "$app_info $dbout"
				putquick "NOTICE $nick :fatto"
			} 

			if {$start == "fe"} {
       				readdb $dirname/$cmd
				file delete $dirname/$cmd
				create_db "$dirname/$cmd" "$dbout $app_info"
				putquick "NOTICE $nick :fatto"
			}
		} {
			putquick "NOTICE $nick :'$cmd' non esiste"
		}
	} {
		putquick "NOTICE $nick :scrivi: !app <fb|fe> <cmd_name> <info_aggiuntive> | fb - dall'inizio; fe - dalla fine;"
	}
}

proc ren_fct { nick uhost hand chan arg } {
	global dirname

	if {![channel get $chan learn]} {
		return
        }

	set txt [string tolower [split $arg]]

        set old [lindex $txt 0]

        set new [lindex $txt 1]
	
	if {$new != ""} {
		if {[file exists $dirname/$old] == 1} {
			file rename $dirname/$old $dirname/$new
			putquick "NOTICE $nick :'$old' é stato rinominato in '$new'"
		} {
			putquick "NOTICE $nick :'$cmd' non esiste"
		}
	} {
		putquick "NOTICE $nick :scrivi: !ren <old_cmd_name> <new_cmd_name"
	}
}

proc stored_cmds { nick uhost hand chan arg } {
	global dirname

	if {![channel get $chan learn]} {
		return
	}

	set files [glob -tails -directory $dirname -nocomplain -type f *]

	if {$files != ""} {
		set names [join $files ", "]
	} {
		set names "nessuno"
	}

	putquick "NOTICE $nick :elenco comandi: $names"
}

putlog "learn.tcl loaded"
	

