# This script converts all data that should be passed to an eggdrop command
# to utf-8, so only the lowest 8 bit are used. When Tcl_Eval is called again
# it can convert the data back to utf.

package require Tcl 8.5

encoding system utf-8

proc initUtf8 {} {
   rename initUtf8 {}
   set i [interp create]
   set tcmds [interp eval $i {info commands}]
   interp delete $i
   set procs [info procs]
   foreach cmd [info commands] {
      if {   $cmd ni $tcmds && $cmd ni $procs
         && "${cmd}_orig" ni [info commands]
         && ![string match *_orig $cmd]
      } {
         # Eggdrop command.
         rename $cmd ${cmd}_orig
         interp alias {} $cmd {} fixutf8 ${cmd}_orig
      }
   }
}
initUtf8
proc fixutf8 args {
   set cmd {}
   foreach arg $args {
      lappend cmd [encoding convertto utf-8 $arg]
   }
   catch {{*}$cmd} res opt
   dict incr opt -level
   return -opt $opt $res
}	

