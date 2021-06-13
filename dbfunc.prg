/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  dbfunc.prg
*
***/

#include 'set.ch'
#include 'common.ch'
#include 'assert.ch'
#include 'dbfunc.ch'
#include 'main.ch'


/***
* DstkPush( lPopPush )
*
* Empurra uma entrada na pilha de banco de dados. Salvamos a area
* atual do select de selecao, o numero de registros, a ordem de indexacao,
* SET SOFTSEEK e SET DELETED
*
* lPopPush : Valor logico indicando a chamada da rotina para que seja restaurada a area
*            salva anteriormente.
*/
PROCEDURE DstkPush( lPopPush )

// Variavel para definicao da Pilha de banco de dados.
#DEFINE pLEN_DBF_STK_ENTRY 11

// Variavel de caracteres usada como pilha de Banco de Dados
static cDbfStk := ''

	DEFAULT lPopPush TO pFALSE

	If lPopPush

		If Len( cDbfStk ) > 0
			Set( _SET_SOFTSEEK, SubStr( cDbfStk, 10, 1) == 'T')
			set( _SET_DELETED,  SubStr( cDbfStk, 11, 1) == 'T')

			Select Asc( SubStr( cDbfStk, 1, 1 ) )
			dbGoto( Val( SubStr( cDbfStk, 2, 7 ) ) )
			dbSetOrder( Asc( SubStr( cDbfStk, 9, 1 ) ) )

			cDbfStk := SubStr( cDbfStk, pLEN_DBF_STK_ENTRY + 1 )
		EndIf

	Else

		cDbfStk := Chr( Select() ) + Str( RecNo(), 7)     ;
                        + Chr( IndexOrd() )                    ;
                        + iif( Set( _SET_SOFTSEEK ), 'T', 'F') ;
                        + iif( Set( _SET_DELETED ), 'T', 'F') + cDbfStk
	EndIf

return


/***
* DstkPop()
*
* Remove ultima entrada da pilha de banco de dados (puxando-a)
* e restaura atributos do banco de dados
*
*/
PROCEDURE DstkPop

	DstkPush( pTRUE )

return


/***
*
*	DBSkipper( nSkip, bCondicao )
*
*	Funcao que realiza a ontagem do Browse.
*
*/
FUNCTION DBSkipper( nSkip, bCondicao )

local nRetValue := 0

	If nSkip == 0
		dbSkip(0)
	ElseIf nSkip > 0 .and. .not. Eof()
		while nRetValue < nSkip
			dbSkip()
			If .not. Eval( bCondicao ) .or. Eof()
				dbSkip(-1)
				Exit
			EndIf
			nRetValue++
		enddo
	ElseIf nSkip < 0
		while nRetValue > nSkip
			dbSkip(-1)
			If Bof()
				Exit
			EndIf
			If .not. Eval( bCondicao )
				dbSkip()
				Exit
			EndIf
			nRetValue--
		enddo
	EndIf

return( nRetValue )


/***
*
*	GOTopDB( bCondicao )
*
*	Posiciona no Primeiro registro para exibicao de acordo com a condicao definida.
*
*/
PROCEDURE GOTopDB( bCondicao )

	while ( Eval( bCondicao ) .and. .not. Bof() )
		dbSkip(-1)
		If .not. Eval( bCondicao )
			dbSkip()
			Exit
		EndIf
	enddo

return


/***
*
*	GOBottomDB( bCondicao )
*
*	Posiciona no ultimo registro para exibicao de acordo com a condicao definida.
*
*/
PROCEDURE GOBottomDB( bCondicao )

	while ( Eval( bCondicao ) .and. .not. eof() )
		dbSkip()
    enddo
	dbSkip(-1)

return


/***
*
*  NetPersist( <bBlock>, [<nSeconds>] ) --> lSuccess
*
*  Rotina para a rede onde o sistema executa um numero de tentativas 
*  a partir do numero de segundos passados como parametro para a execucao do
*  codigo de bloco.
*
*  Parametros:
*     bBlock - Bloco de Codigo com a acao que sera executada.
*
*     nSeconds - Parametro opcional informando o numero de segundos que 
*                ira aguarda ate a proxima tentativa.
*
*  Retorno:
*     Retorna um valor logico informando ao sistema caso a acao tenha sido executada com sucesso.
*
*/
FUNCTION NetPersist( bBlock, nSeconds )

local lForever  := ( nSeconds == 0 )
local lRetValue := pFALSE

    DEFAULT nSeconds TO 2

    while ( lForever .or. ( nSeconds > 0 ) )

        If Eval( bBlock )
            lRetValue := pTRUE
            exit
        EndIf

        Inkey( NET_WAIT )
        nSeconds -= NET_SECONDS

    enddo

return ( lRetValue )