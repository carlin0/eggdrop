# mirc eggdrop logger 1.4
# by Lanze <simon@freeworld.dk>
#
# what valid, existing dir would you like your eggdrop to save logs in?
# please make sure you have created the dir, if it doesn't already
# exist!
set logdir "~/eggdrop/logs"

# logging binds
bind pubm - * log:chat
bind join - * log:join
bind part - * log:part
bind sign - * log:sign
bind topc - * log:topc
bind kick - * log:kick
bind nick - * log:nick
bind mode - * log:mode
bind ctcp - "ACTION" log:cact

# logging procs
proc log:chat {nick host hand chan text} {
  global logdir
  set logstr "\[[strftime %H:%M]\] <$nick> $text"
  set addlog [open $logdir/[string range [string tolower $chan] 1 end].log a]
  puts $addlog "$logstr"
  close $addlog
}

proc log:join {nick host hand chan} {
  global logdir
  set logstr "\[[strftime %H:%M]\] *** $nick ($host) has joined $chan"
  set addlog [open $logdir/[string range [string tolower $chan] 1 end].log a]
  puts $addlog "$logstr"
  close $addlog
}

proc log:part {nick host hand chan} {
  global logdir
  set logstr "\[[strftime %H:%M]\] *** $nick ($host) has left $chan ()"
  set addlog [open $logdir/[string range [string tolower $chan] 1 end].log a]
  puts $addlog "$logstr"
  close $addlog
}

proc log:sign {nick host hand chan text} {
  global logdir
  set logstr "\[[strftime %H:%M]\] *** $nick has left $chan ($text)"
  set addlog [open $logdir/[string range [string tolower $chan] 1 end].log a]
  puts $addlog "$logstr"
  close $addlog
}

proc log:topc {nick host hand chan text} {
  global logdir
  set logstr "\[[strftime %H:%M]\] *** $nick changes topic to '$text'"
  set addlog [open $logdir/[string range [string tolower $chan] 1 end].log a]
  puts $addlog "$logstr"
  close $addlog
}

proc log:kick {nick host hand chan targ text} {
  global logdir
  set logstr "\[[strftime %H:%M]\] *** $targ was kicked by $nick ($text)"
  set addlog [open $logdir/[string range [string tolower $chan] 1 end].log a]
  puts $addlog "$logstr"
  close $addlog
}

proc log:nick {nick host hand chan newn} {
  global logdir
  set logstr "\[[strftime %H:%M]\] *** $nick is now known as $newn"
  set addlog [open $logdir/[string range [string tolower $chan] 1 end].log a]
  puts $addlog "$logstr"
  close $addlog
}

proc log:mode {nick host hand chan chag vict} {
  global logdir
  set logstr "\[[strftime %H:%M]\] *** $nick sets mode: $chag $vict"
  set addlog [open $logdir/[string range [string tolower $chan] 1 end].log a]
  puts $addlog "$logstr"
  close $addlog
}

proc log:cact {nick host hand dest keyw args} {
  global logdir
  if {[string range $dest 0 0] != "#"} {
    return 0
  }
  set logstr "\[[strftime %H:%M]\] * $nick $args"
  set addlog [open $logdir/[string range [string tolower $dest] 1 end].log a]
  puts $addlog "$logstr"
  close $addlog
}

# the end.
