/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  odnfunc.prg
*
***/

#include 'hbclass.ch'
#include 'hbthread.ch'
#include 'fileio.ch'
#include 'common.ch'
#include 'setcurs.ch'
#include 'box.ch'
#include 'main.ch'
//#iinclude 'odinnet.ch'


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

	DEFAULT cFaixa    TO '',     ;
			dPeriodo  TO CToD('')

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
*	Retorna um array contendo todos os clubes cadastrados.
*
*   ==> [ aposta -> LtcApoIncluir() ]
*   ==> [ aposta -> LtcApoModificar() ]
*   ==> [ competic -> GrpIncluir() ]
*   ==> [ loteca -> LtcIncluir() ]
*   ==> [ loteca -> LtcModificar() ]
*   ==> [ loteca -> LtcCombina() ]
*   ==> [ lotogol -> LtgIncluir() ]
*   ==> [ lotogol -> LtgModificar() ]
*   ==> [ tmania -> TimIncluir() ]
*   ==> [ tmania -> TimModificar() ]
*
*
*/
FUNCTION LoadClubes

local aRetValue := {}
local bFiltro   := { || .not. CLUBES->( Eof() ) }
local nTotRecno := 0

	begin sequence

		DstkPush()

		dbSelectArea('CLUBES')
		CLUBES->( dbEval( { || nTotRecno++ }, bFiltro ) )

		If nTotRecno > 0
			CLUBES->( dbSetOrder(2), dbGoTop() )
			while Eval( bFiltro )
				AAdd( aRetValue, { AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), CLUBES->CLU_CODIGO } )
				CLUBES->( dbSkip() )
			enddo
		Else
			AAdd( aRetValue, { 'None' } )
		EndIf

	always
		DstkPop()
	end sequence

return( aRetValue )	