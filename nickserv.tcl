# Seteando
# Contraseña del Nick del BoT #
set clave "lamiapass"

# Comando de Identificacion "IDENTIFY"
set comando "identify"

# Servicio de Identificacion
# en este Caso NickServ
set botservicio "NickServ"

#     Setea la modalidad del comando
# 0: /msg botservicio comando clave
# 1: /msg botservicio comando nick clave
set mcomando "0"

bind notc - "*This nickname is registered and protected*" identificacion

proc identificacion { nick host hand chan smt } {
global botnick clave botservicio comando mcomando comando

if {[strlwr $nick] == [strlwr $botservicio]} {
   if {$mcomando == "0"} {
        puthelp "PRIVMSG $botservicio :$comando $clave"
        putlog "IDENTIFY: Identificacion Con $botservicio EXITOSA."
   }
   if {$mcomando == "1"} {
        puthelp "PRIVMSG $botservicio :$comando $botnick $clave"
        putlog "IDENTIFY: Identificacion Con $botservicio EXITOSA."
  }
 }
}



