### Random CTCP Version Reply

bind ctcp - version ctcpreply
set ctcps {
 {LostIRC 0.4.6 / Linux 3.16.2}
 {mIRC v7.36 Khaled Mardam-Bey}
 {irssi v0.8.15}
 {Quassel IRC v0.8.0}
 {xchat 2.8.8 / Linux 3.2.0}
 {HexChat 2.9.6 / Linux 3.16.3-031603-generic}
}

proc ctcpreply {nick uhost handle dest keyword text} {
global ctcps ctcp-version
set {ctcp-version} [lindex $ctcps [rand [llength $ctcps]]]
}

putlog "TCL Loaded: Random CTCP Reply"