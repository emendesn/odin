/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*	Classes para Manipulacao de Janelas.
*
*/
#include 'hbclass.ch'
#include 'common.ch'
#include 'set.ch'
#include 'box.ch'

/***
*
*	WindowsNew
*
*	Objeto para manipulacao de telas 
*
*	Objetos:
*            :nTop    - Variavel para armazena a linha inicial para o posicionamento da janela
*            :nLeft   - Variavel para armazena a coluna inicial para o posicionamento da janela
*            :nBottom - Variavel para armazena a linha final para o posicionamento da janela
*            :nRight  - Variavel para armazena a coluna final para o posicionamento da janela
*            :cBorder - variavel para armazenar o formato da borda da janela
*            :cColor  - variavel para armazenar a cor do objeto criado
*            :cHeader - Variavel para armazenar a mensagem apresentada no topo da janela
*
*	Metodos:
*            :New()   - Cria o objeto
*            :Open()  - Exibe na tela o objeto criado
*            :Close() - Fecha o objeto criado
*
*/
CLASS WindowsNew
	HIDDEN:
		DATA cScreen AS CHARACTER
	
	EXPORTED:
		DATA nTop    AS NUMERIC
		DATA nLeft   AS NUMERIC
		DATA nBottom AS NUMERIC
		DATA nRight  AS NUMERIC
		DATA cBorder AS CHARACTER
		DATA cColor  AS CHARACTER
		DATA cHeader AS CHARACTER

	METHOD New( nTop, nLeft, nBottom, nRight, cBorder, cColor, cHeader )
	METHOD Open()
	METHOD Close()
	
END CLASS


/***
*
*	:New( <nTop>, <nLeft>, <nBottom>, <nRight>, <cBorder>, <cColor>, <cHeader> ) -> Objeto
*
*	Metodo utilizado para a criacao do objeto na tela
*
*	Parametros:
*            <nTop>    - Define a linha inicial para o posicionamento da janela
*            <nLeft>   - Define a coluna inicial para o posicionamento da janela
*            <nBottom> - Define a linha final para o posicionamento da janela
*            <nRight>  - Define a coluna final para o posicionamento da janela
*            <cBorder> - Define o formato da borda da janela
*            <cColor>  - Define a cor da janela
*            <cHeader> - Define a mensagem apresentada no topo da janela
*
*/
METHOD New( nTop, nLeft, nBottom, nRight, cBorder, cColor, cHeader ) CLASS WindowsNew
	
	::nTop    := iif( .not. HB_ISNIL( nTop ), nTop,  0 )
	::nLeft   := iif( .not. HB_ISNIL( nLeft ), nLeft, 0 )
	::nBottom := iif( .not. HB_ISNIL( nBottom ), nBottom, MaxRow() )
	::nRight  := iif( .not. HB_ISNIL( nRight ), nRight, MaxCol() )
	::cBorder := iif( .not. HB_ISNIL( cBorder ), cBorder, B_SINGLE )	
	::cColor  := iif( .not. HB_ISNIL( cColor ), cColor, Set( _SET_COLOR ) )
	::cHeader := iif( .not. HB_ISNIL( cHeader ), cHeader, '' )
		
return QSelf()


/***
*
*	:Open()
*
*	Metodo utilizado para a exibir objeto na tela
*
*/
METHOD PROCEDURE Open() CLASS WindowsNew
		
local nRow := Row()
local nCol := Col()

	// Salva a regiao corrente
	::cScreen := SaveScreen( ::nTop, ::nLeft, ::nBottom+ 2, ::nRight+ 2)
	
	// Cria a Janela
	hb_DispBox( ::nTop, ::nLeft, ::nBottom, ::nRight, ::cBorder, ::cColor )
	
	// Cria o efeito de sombra na Janela
	DbgShadow( ::nTop, ::nLeft, ::nBottom, ::nRight )
	
	// Exibe o titulo da Janela
	If .not. HB_ISNIL( ::cHeader )
		@ ::nTop, ::nLeft+ 1 SAY ::cHeader COLOR ::cColor
    EndIf
	
	SetPos( nRow, nCol)
		
return


/***
*
*	:Close()
*
*	Metodo utilizado para a fechar o objeto na tela e restaurar a area
*
*/
METHOD PROCEDURE Close() CLASS WindowsNew

	// Restaura a regiao da Janela
	If .not. HB_ISNIL( ::cScreen )
		RestScreen( ::nTop, ::nLeft, ::nBottom+ 2, ::nRight+ 2, ::cScreen )
    EndIf
		
return