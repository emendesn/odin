/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*	Classes para Manipulacao da Barra de Progresso.
*
*/
#include "hbclass.ch"
#include "common.ch"
#include "box.ch"

/***
*
*	ProgressBar
*
*	Objeto para manipulacao da barra de progresso
*
*	Objetos:
*            :cScreen - Variavel para armazena a area do objeto criado
*            :nTop    - Variavel para armazena a linha inicial para o posicionamento da janela
*            :nLeft   - Variavel para armazena a coluna inicial para o posicionamento da janela
*            :cHeader - Variavel para armazenar a mensagem apresentada no topo da janela
*            :cFooter - Variavel para armazenar a mensagem apresentada no final da janela
*            :cBorder - variavel para armazenar o formato da borda da janela
*            :cColor  - variavel para armazenar a cor do objeto criado
*
*	Metodos:
*            :New()    - Cria o objeto
*            :Open()   - Exibe na tela o objeto criado
*            :Update() - Atualiza na tela o objeto criado
*            :Close()  - Fecha o objeto criado
*
*/
CLASS ProgressBar
	HIDDEN:
		DATA cScreen AS CHARACTER
	
	EXPORTED:
		DATA nTop    AS NUMERIC
		DATA nLeft   AS NUMERIC
		DATA cHeader AS CHARACTER
		DATA cFooter AS CHARACTER
		DATA cBorder AS CHARACTER
		DATA cColor  AS CHARACTER

	METHOD New( nTop, nLeft, cHeader, cFooter, cBorder, cColor )
	METHOD Open()
	METHOD Update( nDone ) SETGET
	METHOD Close()
	
END CLASS


/***
*
*	:New( <nTop>, <nLeft>, <cHeader>, <cFooter>, <cBorder>, <cColor> ) -> Objeto
*
*	Metodo utilizado para a criacao do objeto na tela
*
*	Parametros:
*            <nTop>    - Define a linha inicial para o posicionamento da janela
*            <nLeft>   - Define a coluna inicial para o posicionamento da janela
*            <cHeader> - Define a mensagem apresentada no topo da janela
*            <cFooter> - Define a mensagem apresentada no final da janela
*            <cBorder> - Define o formato da borda da janela
*            <nColor>  - Define a cor da janela
*
*/
METHOD New( nTop, nLeft, cHeader, cFooter, cBorder, cColor ) CLASS ProgressBar
	
	::nTop    := iif( .not. HB_ISNIL( nTop ) .and.  nTop < MaxRow()- 5,    nTop,  INT( ( MaxRow()- 4)/2 ) )
	::nLeft   := iif( .not. HB_ISNIL( nLeft ) .and. nLeft < MaxCol()-55,   nLeft, INT( ( MaxCol()-54)/2 ) )
	::cHeader := iif( .not. HB_ISNIL( cHeader ), cHeader, "> Percentual Completo <" )
	::cFooter := iif( .not. HB_ISNIL( cFooter ), cFooter, "> Aguarde... <" )
	::cBorder := iif( .not. HB_ISNIL( cBorder ), cBorder,  B_SINGLE )
	::cColor  := iif( .not. HB_ISNIL( cColor ),  cColor,  Set( _SET_COLOR ) )
		
return QSelf()


/***
*
*	:Open()
*
*	Metodo utilizado para a exibir objeto na tela
*
*/
METHOD PROCEDURE Open() CLASS ProgressBar
		
local nRow := Row()
local nCol := Col()

	// Salva a regiao corrente
	::cScreen := SaveScreen( ::nTop, ::nLeft, ::nTop+ 5, ::nLeft+56)
	
	// Cria a Janela
	hb_DispBox( ::nTop, ::nLeft, ::nTop+ 4, ::nLeft+54, ::cBorder, ::cColor )
	
	// Cria o efeito de sombra na Janela
	DbgShadow( ::nTop, ::nLeft, ::nTop+ 4, ::nLeft+54 )
	
	// Exibe o titulo da Janela
	@ ::nTop,    ::nLeft+ 1 SAY PadC( ::cHeader, 53, Chr(196) ) COLOR ::cColor
	@ ::nTop+ 4, ::nLeft+ 1 SAY PadC( ::cFooter, 53, Chr(196) ) COLOR ::cColor
		
	SetPos( nRow, nCol)
		
return


/***
*
*	:Update( nDone )
*
*	Metodo utilizado para atualizacao do objeto
*
*	Parametros:
*            <nDone> - Valor a ser atualizado  
*
*/
METHOD PROCEDURE Update( nDone ) CLASS ProgressBar
		
local nRow := Row()
local nCol := Col()


	// Verifica o valor dentro da Range
	If nDone < 0
		nDone := 0
    ElseIf nDone > 100
		nDone := 100
	EndIf
	
	// Exibe o Percentual
	@ ::nTop+ 1, ::nLeft+25 SAY Str( nDone, 3) + "%" COLOR ::cColor
	
	// show progress bar
	@ ::nTop+ 2, ::nLeft+ 2 SAY PadR( Replicate( Chr(219), ( (nDone*.51)+.5) ), 51, ".") COLOR ::cColor
	
	SetPos( nRow, nCol)
	
return


/***
*
*	:Close()
*
*	Metodo utilizado para a fechar o objeto na tela e restaurar a area
*
*/
METHOD PROCEDURE Close() CLASS ProgressBar

	// Restaura a regiao da Janela
	If .not. HB_ISNIL( ::cScreen )
		RestScreen( ::nTop, ::nLeft, ::nTop+ 5, ::nLeft+56, ::cScreen )
    EndIf
		
return
