/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  strfunc.prg
*
***/

#include "common.ch"

/***
*
*  ParseDezenas( <cString> ) --> aResult
*
*	 Recebe uma string contendo as dezenas que serao separadas.
*
*  			<cString> : String de caracteres contendo as dezenas a serem separadas.
*
*   		aResult   : Vetor contendo as dezenas separadas.
*
*/
FUNCTION ParseDezenas( cString )

local aRetValue  := {}
local cTmpString := ""
local nCount     := 0

	If Len( cString ) > 0
		
		while nCount++ <= Len( AllTrim( cString ) )
			If ISDIGIT( SubStr( AllTrim( cString ), nCount, 1 ) )
				cTmpString += SubStr( AllTrim( cString ), nCount, 1 )
			Else
				AAdd( aRetValue, cTmpString )
				cTmpString := ""
			EndIf
		enddo
		
	EndIf

return( aRetValue )


/***
*
*  ParseString( <aArray> ) --> cResult
*
*	 Recebe um array com as dezenas no qual sera convertido para uma string contendo as dezenas do Array.
*
*   <aArray> : Vetor com as Dezenas a serem processadas.
*
*   cResult  : String contendo as dezenas do vetor agrupadas.
*
*/
FUNCTION ParseString( aArray )

local cRetValue := ""
local nCount    := 0

	If ValType( aArray ) == 'A' .and. Len( aArray ) > 0
		for nCount := 1 to Len( aArray )
			cRetValue += aArray[ nCount ]
			cRetValue += iif( Len( aArray ) > nCount, "-", "" )
		next
	EndIf

return( cRetValue )


/***
*
*  StrDezenas( <cString> ) --> cResult
*
*	 Ordena de maneira crescente a string de caracteres passada como parametro.
*
*  			<cString>  : String de caracteres contendo as dezenas a serem ordenadas.
*
*   		cResult    : Retorna uma string de caracteres contendo os numeros passados como parametros
*           		     ordenados de forma crescente.
*
*/
FUNCTION StrDezenas( cString )

local aString   := {}
local cRetValue := ""
local nPos      := 0

	If Len( cString ) > 0

		If Len( aString := ParseDezenas( cString ) ) > 0

			aString := ASort( aString,,, { |x, y| x < y } )

			while nPos++ < Len( aString )
				cRetValue += aString[ nPos ]
				If nPos < Len( aString )
					cRetValue += "-"
				EndIf
			enddo

		EndIf

	EndIf

return( cRetValue )
	
