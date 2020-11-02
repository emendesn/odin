/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/


/***
*
*  dbfunc.ch
*
***/

#DEFINE NET_WAIT      0.5
#DEFINE NET_SECONDS   0.5

/***
*
*  Funcao para manipulacao de banco de dados.
*
***/
#XTRANSLATE NetAppend( [<nSec>] ) => NetPersist( { || dbAppend(), .not. NetErr() }, <nSec> )
#XTRANSLATE NetRLock( [<nSec>] )  => NetPersist( { || RLock() }, <nSec> )
#XTRANSLATE NetFLock( [<nSec>] )  => NetPersist( { || FLock() }, <nSec> )
