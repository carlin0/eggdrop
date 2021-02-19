# description: Kicks/Bans people who say bad words. Words/pharses are stored in a file. Op protect is allowed. You can add/del/list words/pharses via priv msg. You don't need to rehash/restart your bot. You can define ban duration time etc. Script is very simple to use.

# Author: tomekk 
# e-mail:  tomekk/@/oswiecim/./eu/./org 
# home page: http://tomekk.oswiecim.eu.org/ 
# 
# Version 0.10
# 
# This file is Copyrighted under the GNU Public License. 
# http://www.gnu.org/copyleft/gpl.html 

# ****** please delete old 'banned hosts file', there is a small change in 0.10 (neeed for ban on-join-restoration) ******

# if you need utf-8 support, please read this -> http://eggwiki.org/Utf-8

# fixed: some code fixes, read below - script is now much better, i think... :o)
# changed: from now, if you want to use this script on your channel you have to use .chanset before (info below)
# added: channel triggers, custom triggers names without script mods
# added: user nick tracking, nick change doesn't work now (ban avoiding)
# added: separate users files for each channel
# fixed: from now, if someone removes ban for the user which should be banned, bot will ban this user when he join the channel again

	# some examples:
	
	# you want to punish users for word 'test', no matter on which place in text line
	# /msg <botnick> bword add *test*, this will match: test, text test, test text, text test text, texttesttext

	# you want to punish users for single word 'test'
	# /msg <botnick> bword addr test, this will match: test, text test, test text, text test text

	# you want to punish users for 'test' and some text after it
	# /msg <botnick> bword add test *, this will match: test text

	# you want to punish users for pharse which starts with 'test' and ends with 'cool'
	# /msg <botnick> bword add test*cool, this will match: test text cool, testcool

	# you want to punish users for 'test', 'tess', 'tesx', 'tesa'
	# /msg <botnick> bword add test?, this will match: test, tess, tesx, tesa, but no tes - ? means any char, not null

	# you want to punish users for pharse witch starts with 'test', ends with 'cool' and with '*' between
	# /msg <botnick> bword add test*\**cool, this will match: test text* cool, test*cool, test *text cool, test text*text cool,  etc.

	# you want to punish users for 'hello?'
	# /msg <botnick> bword add hello\?, this will match: hello?
	
	# you want punish users for 'test<single_number>test'
	# /msg <botnick> bword add test[0-9]test, this will match: test0test, test1test, test2test etc.

	# of course you can make more complicated sequences, like:
	# /msg <botnick> bword add hello?*here*, this will match: hello? some1 here?, hello? tom are u here?????, hello! hello! are u here????

	# etc etc, i think this is simple ;)
	# remember, if you want to use chars: * ? [ ] \ like non special chars, you need to escape them with \, like: \* \? \[ \] \\

	# USE '/msg <botnick> bword' for more information

# if you want to use this script on your chan, type in eggdrop console (via telnet or DCC chat)                 
# .chanset #channel_name +bword
# and later .save           

# host allowed to use 'bword' commands
set bdw_hosts {janedoe@*.adsl.isp.com *tag@some.domain.com jimmy@my.host.com}

# control script via (triggers binds below)
# 1 - priv msgs triggers
# 2 - chan triggers
set control_via 1

# sets ban type 
# 1)  *!*@*.domain.com 
# 2)  *!*@some.domain.com 
# 3)  *nick*!*@some.domain.com 
# 4)  *!*ident*@some.domain.com 
set btype 2

# 1 - protect users with op, 0 - don't
set protectops 0

# 1 - enable ban, 0 - disable ban (just kick after bad word)
set want_ban 1

# wait 'waitb' times before ban, works only when want_ban is set to 1
# if you want to ban user after one bad word, set 'waitb' to 0 
set waitb 3 

# 'waitb' info type, works only when want_ban is set to 1
# 1 - kick after bad word and ban after 'waitb' times 
# 2 - write message after bad word to the nick, 'nick: message' and ban after 'waitb' times 
# 3 - do nothing, just ban after 'waitb' times
set waitb_type 2

# kick message.
set kmsg "bad word! - kick"

# ban message.
set bmsg "banned!"

# if you set 'waitb' to 2, then here is a option to set this message 
set waitb_message "controlla il tuo linguaggio !" 

# ban duration time (minutes, +/- 30 seconds for ban checker loop) 
# 0 - infinite 
set ban_duration 0

# "offence" duration time, how long bot should remember last bad word time (minutes) 
# 0 - infinite 
set offence_duration 0 

# reload words/pharses DB every x minutes (this means that the new word will work after X minutes)
# bot loads whole word DB into memory
set reload_words_db_every 7

# bind the triggers
# chan triggers
set action_bind(chan_add) "!bwordadd"
set action_bind(chan_addr) "!bwordaddr"
set action_bind(chan_del) "!bworddel"
set action_bind(chan_delr) "!bworddelr"
set action_bind(chan_list) "!bwordlist"

# priv triggers
set action_bind(priv_add) "add"
set action_bind(priv_addr) "addr"
set action_bind(priv_del) "del"
set action_bind(priv_delr) "delr"
set action_bind(priv_list) "list"

# dirs and files, better leave it as it is ;)
# base directory 
set dirname "badwords.db" 

# users directory [lusers / $channame / $user]
# separate data for each channel
set usersdir "$dirname/lusers" 

# banned hosts file 
set banned_hosts "$dirname/bndhosts" 

# dbase with bad words 
set bw_dbase "$dirname/words_bank.db" 

##################################################################
bind pubm - "*" word_fct
bind nick - "*" nick_tracking
bind join - "*" nick_join

if {$control_via == 1} {
	bind msgm - "*" bpmsg_fct
}

if {$control_via == 2} {
	bind pub - $action_bind(chan_add) chan_trigger_add
	bind pub - $action_bind(chan_addr) chan_trigger_addr
	bind pub - $action_bind(chan_del) chan_trigger_del
	bind pub - $action_bind(chan_delr) chan_trigger_delr
	bind pub - $action_bind(chan_list) chan_trigger_list
}

setudef flag bword

if {[file exists $dirname] == 0} {
	file mkdir $dirname
	set crtdb [open $bw_dbase a+]
        puts $crtdb "fuck\nshit\n* fuck *\n* shit *\nfuck *\nshit *\n* shit\n* fuck"
        close $crtdb
}

if {[file exists $usersdir] == 0} {
	file mkdir $usersdir
}

proc create_db { dbname definfo } {
	if {[file exists $dbname] == 0} {
		set crtdb [open $dbname a+]
		puts $crtdb "$definfo"
		close $crtdb
	}
}

proc readdb { rdb } {
	set fs_open [open $rdb r]
	gets $fs_open dbout
	close $fs_open

	return $dbout
}

proc get_user_host { chan nick } {
	global usersdir

	set user_data [lindex [split [readdb $usersdir/$chan/$nick] "&"] 0]

	return $user_data
}

proc get_all_lines { db } {
	set bf [open $db r]
	set all_lines [read $bf]
	close $bf

	set lines_split [split $all_lines "\n"]
        return $lines_split
}

proc add_new_bword { bword } {
	global bw_dbase

	set bfile_handle [open $bw_dbase a]
	puts $bfile_handle "$bword"
	close $bfile_handle
}

proc add_new_bnd_host { new_host  } {
	global banned_hosts

	set bnd_hosts [open $banned_hosts a]
	puts $bnd_hosts $new_host
	close $bnd_hosts
}

proc bnd_host_mask_update { chan uhost ban_mask} {
	global banned_hosts

	set before_update [get_all_lines $banned_hosts]

	set after_update [open $banned_hosts w]
	foreach old_host $before_update {
		if {$old_host != ""} {
			set old_host_data [split $old_host "&"]
			set old_host_chan [lindex $old_host_data 0]
			set old_host_host [lindex $old_host_data 1]
			set old_host_time [lindex $old_host_data 2]
			set old_host_mask [lindex $old_host_data 3]

			set skip 0

			if {$uhost == $old_host_host} {
				if {$chan == $old_host_chan} {
					puts $after_update "$old_host_chan&$old_host_host&$old_host_time&$ban_mask"
					set skip 1
				}
			}

			if {$skip == 0} {
				puts $after_update "$old_host_chan&$old_host_host&$old_host_time&$old_host_mask"
			}
		}
	}
	close $after_update
}

proc delete_bword { dbword {dlall 0}} {
	global bw_dbase

	set old_bwdb [get_all_lines $bw_dbase]
	
	set file_tow [open $bw_dbase w]
	
	if {$dlall == 0} {
		foreach chk_bw $old_bwdb {
			if {$chk_bw != $dbword} {
				if {$chk_bw != ""} {
					puts $file_tow $chk_bw
				}
			}
		}
	}
	close $file_tow
}

proc check_bw_exist { chword } {
	global bw_dbase

	set old_chbwdb [get_all_lines $bw_dbase]

        set bw_exist 0

	foreach check_bword $old_chbwdb {
		if {[string match $chword $check_bword]} {
			 set bw_exist 1
		 }
	}
	return $bw_exist
}

proc ban_checker_timer { } {
	ban_checker

	if {[string match *ban_checker_timer* [utimers]] != 1} {
		utimer 20 ban_checker_timer
	}
}

proc words_reload_timer { } {
	global nasty_words reload_words_db_every bw_dbase

	set nasty_words [get_all_lines $bw_dbase]

	putlog "tkbadword.tcl - reloading words DB"

	if {[string match *words_reload_timer* [timers]] != 1} {
		timer $reload_words_db_every words_reload_timer
	}
}

set nasty_words [get_all_lines $bw_dbase]

proc word_fct { nick uhost hand chan arg } {
  	global botnick protectops usersdir waitb waitb_type waitb_message want_ban kmsg bmsg offence_duration ban_duration bdw_channels nasty_words action_bind

	set arg [string trim $arg]

	if {![channel get $chan bword]} {                                                                 
		return                                                                                          
	}

	# exceptions
	set chan_binds {chan_add chan_addr chan_del chan_delr}
	foreach chan_bind $chan_binds {
		if {[string match $action_bind($chan_bind)* $arg]} {
			return
		}
	}

	if {$protectops == 1} {
		if {[isop $nick $chan] == 1} {
			return
		}
	}	

	# channel dir
	if {![file exists $usersdir/$chan ]} {
		file mkdir $usersdir/$chan
	}

	set kill 0

	set ban_status 0

	foreach i [string tolower $nasty_words] {
		if {$i != ""} {
			if {[string match $i [string tolower $arg]]} {
				set kill 1
			}
		}
	}
		
	if {$kill == 1} {
		if {$want_ban == 1} {
			set time_in_seconds [clock seconds]
			set user_ban_mask [banmask $uhost $nick]

			if {$waitb == 0} {
				putquick "MODE $chan +b $user_ban_mask"

				add_new_bnd_host "$chan&$uhost&$time_in_seconds&$user_ban_mask"

				putkick $chan $nick $bmsg

				set ban_status 1
			} {
				if {[file exists $usersdir/$chan/$nick] == 0} {
					create_db "$usersdir/$chan/$nick" "$uhost&1&$time_in_seconds"
				} { 
					set each_user_data [split [readdb "$usersdir/$chan/$nick"] "&"]
					set ident [lindex $each_user_data 0]
					set times [lindex $each_user_data 1]
					set first_time [lindex $each_user_data 2]

					if {([expr $time_in_seconds - $first_time] >= [expr $offence_duration * 60]) && ($offence_duration > 0)} {
						file delete $usersdir/$chan/$nick
						create_db "$usersdir/$chan/$nick" "$uhost&1&$time_in_seconds"
					} {
						file delete $usersdir/$chan/$nick
						set overall [expr $times + 1]

						create_db "$usersdir/$chan/$nick" "$ident&$overall&$first_time"
						set ident [lindex [split [readdb "$usersdir/$chan/$nick"] "&"] 0]

						if {$uhost == $ident} {				
							if {$overall >= $waitb} {
								putquick "MODE $chan +b $user_ban_mask"

								add_new_bnd_host "$chan&$uhost&$time_in_seconds&$user_ban_mask"

								file delete $usersdir/$chan/$nick

								putkick $chan $nick $bmsg

								set ban_status 1
							}
						} { 
							file delete $usersdir/$chan/$nick
							create_db "$usersdir/$chan/$nick" "$uhost&1"
						}
					}	
				}

				if {($ban_status == 0) && ($waitb_type < 3)} {
					if {$waitb_type == 1} {
						putkick $chan $nick $bmsg
					} {
						putquick "PRIVMSG $chan :$nick: $waitb_message"
					}
				}
			}
		} {
			putkick $chan $nick $kmsg
		}
	}
}

proc chan_trigger_add { nick uhost hand chan arg } {
	bpmsg_fct $nick $uhost $hand "bword add $arg"
}

proc chan_trigger_addr { nick uhost hand chan arg } {
	bpmsg_fct $nick $uhost $hand "bword addr $arg"
}

proc chan_trigger_del { nick uhost hand chan arg } {
	bpmsg_fct $nick $uhost $hand "bword del $arg"
}

proc chan_trigger_delr { nick uhost hand chan arg } {
	bpmsg_fct $nick $uhost $hand "bword delr $arg"
}

proc chan_trigger_list { nick uhost hand chan arg } {
	bpmsg_fct $nick $uhost $hand "bword list $arg"
}

proc bpmsg_fct { nick uhost hand arg } {
	global bdw_hosts action_bind control_via bw_dbase

	set check_host 0

	foreach def_host $bdw_hosts {
		if {$def_host != ""} {
			if {[string match $def_host $uhost]} {
				set check_host 1
				break
			}
		}
	}

	if {$check_host == 0} {
		return
	}

	set need_help 0

	set all_bargs [split [string tolower $arg]]
	set bargs_opt1 [lindex $all_bargs 0]
	set bargs_opt2 [lindex $all_bargs 1]
	set bargs_opt_newords [join [lrange $all_bargs 2 end]]

	set bw_list [list]
	
	# yeah, can be switch, who cares! ;-)
	if {$bargs_opt1 == "bword"} {
		if {$bargs_opt2 != ""} {
			if {$bargs_opt2 == $action_bind(priv_add)} {
				if {$bargs_opt_newords != ""} {
					if {[check_bw_exist $bargs_opt_newords]} {
						putquick "PRIVMSG $nick :word/pharse: '$bargs_opt_newords' allready exists"
					} {
						putquick "PRIVMSG $nick :word/pharse: '$bargs_opt_newords' has been added"
						add_new_bword $bargs_opt_newords
					}
				} {
					set need_help 1
				}
			} elseif {$bargs_opt2 == $action_bind(priv_addr)} {
				if {$bargs_opt_newords != ""} {
					if {[check_bw_exist $bargs_opt_newords]} {
						putquick "PRIVMSG $nick :word/pharse: '$bargs_opt_newords' allready exists"
					} {
						putquick "PRIVMSG $nick :word/pharse: '$bargs_opt_newords' with regexps has been added"
						add_new_bword "$bargs_opt_newords\n$bargs_opt_newords *\n* $bargs_opt_newords\n* $bargs_opt_newords *"
					}
				} {
					set need_help 2
				}
			} elseif {$bargs_opt2 == $action_bind(priv_list)} {
				set list_bwords [get_all_lines $bw_dbase]

				if {$list_bwords != ""} {
					foreach bw_word $list_bwords {
						lappend bw_list "$bw_word"
					}
					putquick "PRIVMSG $nick :[join $bw_list ", "]"
				} else {
					putquick "PRIVMSG $nick :db is empty"
				}
			} elseif {$bargs_opt2 == $action_bind(priv_delr)} {
				if {$bargs_opt_newords != ""} {
					if {[check_bw_exist $bargs_opt_newords]} {
						delete_bword $bargs_opt_newords
						delete_bword "$bargs_opt_newords *"
						delete_bword "* $bargs_opt_newords"
						delete_bword "* $bargs_opt_newords *"
						putquick "PRIVMSG $nick :word/pharse: '$bargs_opt_newords' with regexps has been deleted"
					} {
						putquick "PRIVMSG $nick :word/pharse: '$bargs_opt_newords' not found"
					}
				} {
					set need_help 3
				}
			} elseif {$bargs_opt2 == $action_bind(priv_del)} {
				if {$bargs_opt_newords != ""} {
					if {$bargs_opt_newords == "delall"} {
						delete_bword 0 1
						putquick "PRIVMSG $nick :all words/pharses have been deleted"
					} {
						if {[check_bw_exist $bargs_opt_newords]} {
							delete_bword $bargs_opt_newords
							putquick "PRIVMSG $nick :word/pharse: '$bargs_opt_newords' has been deleted"
						} {
							putquick "PRIVMSG $nick :word/pharse: '$bargs_opt_newords' not found"
						}
					}
				} {
					set need_help 4
				}
			}
				
		} {
			set need_help 5
		}
	}

	if {$need_help > 0} {
		if {$control_via == 1} {
			switch $need_help {
				1 {
					putquick "PRIVMSG $nick :use: /msg <botnick> bword $action_bind(priv_add) <word/pharse>"
				}

				2 {
					putquick "PRIVMSG $nick :use: /msg <botnick> bword $action_bind(priv_addr) <word/pharse>"
				}

				3 {
					putquick "PRIVMSG $nick :use: /msg <botnick> bword $action_bind(priv_delr) <word/pharse>"
				}

				4 {
					 putquick "PRIVMSG $nick :use: /msg <botnick> bword $action_bind(priv_del) <word/pharse>"
					 putquick "PRIVMSG $nick :if you want to delete all words/pharses use: /msg <botnick> $action_bind(priv_del) delall"
				}

				5 {
					putquick "PRIVMSG $nick :use: /msg <botnick> bword <$action_bind(priv_add)|$action_bind(priv_addr)|$action_bind(priv_del)|$action_bind(priv_delr)|$action_bind(priv_list)>"
				}
			}
		} else {
			switch $need_help {
				1 {
					putquick "PRIVMSG $nick :use: $action_bind(chan_add) <word/pharse>"
				}
														                                2 {
					putquick "PRIVMSG $nick :use: $action_bind(chan_addr) <word/pharse>"
				}

				3 {
		                        putquick "PRIVMSG $nick :use: $action_bind(chan_delr) <word/pharse>"
				}

				4 {
					putquick "PRIVMSG $nick :use: $action_bind(chan_del) <word/pharse>"
					putquick "PRIVMSG $nick :if you want to delete all words use: $action_bind(chan_del) delall"
				}
			}
		}
	}
}

proc ban_checker { } {
	global banned_hosts ban_duration

	if {([file exists $banned_hosts]) && ($ban_duration > 0)} {
		set banned_hts [get_all_lines $banned_hosts]

		set time_in_seconds [clock seconds]

		set rewrite_hosts_hand [open $banned_hosts w]
		foreach banned_h $banned_hts {
			if {$banned_h != ""} {
				set split_banned_h [split $banned_h "&"]
				set host_ban_chan [lindex $split_banned_h 0]
				set host_ban_host [lindex $split_banned_h 1]
				set host_ban_time [lindex $split_banned_h 2]
				set host_ban_mask [lindex $split_banned_h 3]
	
				if {[expr $time_in_seconds - $host_ban_time] >= [expr $ban_duration * 60]} {
					putquick "MODE $host_ban_chan -b $host_ban_mask"
				} {
					puts $rewrite_hosts_hand "$host_ban_chan&$host_ban_host&$host_ban_time&$host_ban_mask"
				}
			}
		}
		close $rewrite_hosts_hand
	}
}

proc nick_tracking { nick uhost hand chan newnick } {
	global usersdir

	if {![channel get $chan bword]} {
		return
	}

	if {[file exists $usersdir/$chan/$nick]} {
		file rename -force $usersdir/$chan/$nick $usersdir/$chan/$newnick
	}
}

proc nick_join { nick uhost hand chan  } {
	global usersdir banned_hosts bmsg

	if {![channel get $chan bword]} {
		return
	}

	# compare nick and host in file	
	if {[file exists $usersdir/$chan/$nick]} {
		if {$uhost != [get_user_host $chan $nick]} {
			file delete $usersdir/$chan/$nick
		}
	}

	# add ban if someone removed it 
	set banned_users [get_all_lines $banned_hosts]

	foreach banned_user $banned_users {
		if {$banned_user != ""} {
			set banned_user_data [split $banned_user "&"]
			set bn_user_chan [lindex $banned_user_data 0]
			set bn_user_host [lindex $banned_user_data 1]
			set bn_user_time [lindex $banned_user_data 2]
			set bn_user_mask [lindex $banned_user_data 3]

			if {$uhost == $bn_user_host} {
				if {$chan == $bn_user_chan} {
					set actual_ban_mask [banmask $uhost $nick]

					putquick "MODE $chan +b $actual_ban_mask"
					putkick $chan $nick $bmsg

					# update ban mask (someone could change it in script between joins)
					bnd_host_mask_update $chan $uhost $actual_ban_mask
					break
				}
			}
		}
	}
}

proc banmask { host nick } {
	global btype

	switch $btype {
		1 {
			set mask "*!*@[lindex [split [maskhost $host] "@"] 1]"
		}

		2 {
			set mask "*!*@[lindex [split $host @] 1]"
		}

		3 {
			set mask "*$nick*!*@[lindex [split $host "@"] 1]"
		}

		4 {
			set mask "*!*[lindex [split $host "@"] 0]*@[lindex [split $host "@"] 1]"
		}
		return $mask
	}
}

if {[string match *ban_checker_timer* [utimers]] != 1} {
	utimer 30 ban_checker_timer
}

if {[string match *words_reload_timer* [timers]] != 1} {
	timer $reload_words_db_every words_reload_timer
}

putlog "tkbadword.tcl ver 0.10 by tomekk loaded"
