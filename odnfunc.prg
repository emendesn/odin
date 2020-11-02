/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  odnfunc.prg
*
***/

#include "hbclass.ch"
#include "hbthread.ch"
#include "fileio.ch"
#include "common.ch"
#include "setcurs.ch"
#include "box.ch"
#include "main.ch"
//#iinclude "odinnet.ch"


/***
*
*	AvalCondRateio()
*
*	Funcao que permite exibir mensagens no rodape da tela.
*
*/
FUNCTION AvalCondRateio( aCondicao, cFaixa, dPeriodo )

local lRetValue := pFALSE
local nCount

	DEFAULT cFaixa    TO "",     ;
			dPeriodo  TO CTOD("")

	If HB_ISARRAY( aCondicao ) .and. .not. Empty( dPeriodo )
		If ( nCount := AScan( aCondicao, { |xItem| xItem[1] == cFaixa } ) ) > 0
			If Eval( aCondicao[ nCount ][2], dPeriodo )
				lRetValue := pTRUE
			EndIf
		EndIf
	EndIf
	
return( lRetValue )


/***
*
*	LoadClubes()
*
*	Funcao responsavel em realizar o Load dos Clubes para as funcoes.
*
*/
FUNCTION LoadClubes

local aRetValue := {}
local bFiltro   := { || CLUBES->( .not. Eof() ) }

	// Salva a Area corrente na Pilha
	DstkPush()

	CLUBES->( dbSetOrder(2), dbEval( {|| AAdd( aRetValue, { AllTrim( CLUBES->CLU_ABREVI ) + "/" + ;
															AllTrim( CLUBES->CLU_UF ),            ;
															CLUBES->CLU_CODIGO } ) }, bFiltro ) )

	// Restaura a tabela da Pilha
	DstkPop()

RETURN( aRetValue )