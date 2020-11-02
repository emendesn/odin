/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*	Classes para Manipulacao de arquivos INI.
*
*/
#include "hbclass.ch"
#include "fileio.ch"
#include "common.ch"
#include "main.ch"

/***
*
*	TIniFile
*
*	Objeto para manipulacao de arquivos INI
*
*	Objetos:
*            :cFileName - Variavel para armazena o nome do arquivo processado
*            :aContents - Variavel para armazena o conteudo do arquivo processado
*
*	Metodos:
*            :New()          -
*            :ReadString()   -
*            :WriteString()  -
*            :ReadNumber()   -
*            :WriteNumber()  -
*            :ReadDate()     -
*            :WriteDate()    -
*            :ReadBool()     -
*            :WriteBool()    -
*            :DeleteKey()    -
*            :EraseSection() -
*            :ReadSection()  -
*            :ReadSections() -
*            :UpdateFile()   -
*
*/
CLASS TIniFile

	EXPORTED:
      VAR cFileName AS CHARACTER
      VAR aContents AS ARRAY
	
	METHOD New( cNomeArquivo )
	METHOD ReadString( cSection, cIdent, cDefault )
	METHOD WriteString( cSection, cIdent, cString )
	METHOD ReadNumber( cSection, cIdent, nDefault )
	METHOD WriteNumber( cSection, cident, nNumber )
	METHOD ReadDate( cSection, cIdent, dDefault )
	METHOD WriteDate( cSection, cIdent, dDate )
	METHOD ReadBool( cSection, cIdent, lDefault )
	METHOD WriteBool( cSection, cIdent, lBool )
	METHOD DeleteKey( cSection, cIdent )
	METHOD EraseSection( cSection )
	METHOD ReadSection( cSection )
	METHOD ReadSections()
	METHOD UpdateFile()
	
END CLASS


METHOD New( cNomeArquivo ) CLASS TIniFile

local lDone     := pFALSE
local cLine     := ""
local hFile
local cFile
local cIdent
local nPos
local CurrArray
local xRetValue


   If .not. Empty( cNomeArquivo )

      begin sequence

         ::cFileName := cNomeArquivo
         ::aContents := {}
         CurrArray  := ::aContents

         If hb_FileExists( cNomeArquivo )
            hFile := FOpen( cNomeArquivo, FO_READ + FO_DENYNONE )
         Else
            hFile := FCreate( cNomeArquivo, FC_NORMAL )
         EndIf

         while .not. lDone
            cFile := Space( 256 )
            lDone := ( FRead( hFile, @cFile, 256 ) <= 0 )

            // Para que possamos porcurar Chr( 10 )
            cFile := StrTran( cFile, chr( 13 ) )

            // Anexar a ultima leitura
            cFile := cLine + cFile
            while .not. Empty( cFile )
               If ( nPos := At( Chr( 10 ), cFile ) ) > 0
                  cLine := Left( cFile, nPos - 1 )
                  cFile := SubStr( cFile, nPos + 1 )

                  If .not. Empty( cLine )

                     // Nova Secao
                     If Left( cLine, 1 ) == "["
                        If ( nPos := At( "]", cLine ) ) > 1
                           cLine := SubStr( cLine, 2, nPos - 2 )
                        Else
                           cLine := SubStr( cLine, 2 )
                        EndIf

                        AAdd( ::aContents, { cLine, { /* Esta sera o CurrArray */ } } )
                        CurrArray := ::aContents[ Len( ::aContents ) ][2]

                     // Preserva Comentarios no arquivo
                     ElseIF Left( cLine, 1 ) == ";"
                        AAdd( CurrArray, { NIL, cLine } )

                     Else
                        If ( nPos := At( "=", cLine ) ) > 0
                           cIdent := Left( cLine, nPos - 1 )
                           cLine  := SubStr( cLine, nPos + 1 )

                           AAdd( CurrArray, { cIdent, cLine } )

                        Else
                           AAdd( CurrArray, { cLine, "" } )
                        EndIf
                     EndIf

                     // Prepara para acrescentar mais tarde
                     cLine := ""

                  EndIf

               Else
                  cLine := cFile
                  cFile := ""
               EndIf
            enddo
         enddo

      always
         FClose( hFile )
         xRetValue := QSelf()
      end sequence

   else
      // Gera o erro ?
      hb_gtAlert( "Nenhum arquivo foi passado para TIniFile():New()", { "Ok" }, "W+/R", "W+/B" )
   EndIf

return xRetValue


METHOD ReadString( cSection, cIdent, cDefault ) CLASS TIniFile

local nPointer
local nCount
local cResult := cDefault
local cFind

   If Empty( cSection )
      cFind := Lower( cIdent )

      If ( nPointer := AScan( ::aContents, ;
                        { |xFind| HB_ISSTRING( xFind[1] ) .and. Lower( xFind[1] ) == cFind .and. HB_ISSTRING( xFind[2] ) } ) ) > 0
         cResult := ::aContents[ nPointer ][2]
      EndIf

   Else
      cFind := Lower( cSection )

      If ( nCount := AScan( ::aContents, ;
                        { |xFind| HB_ISSTRING( xFind[1] ) .and. Lower( xFind[1] ) == cFind } ) ) > 0
         cFind := Lower( cIdent )

         If ( nPointer := AScan( ::aContents[ nCount ][2], ;
                           { |xItem| HB_ISSTRING( xItem[1] ) .and. Lower( xItem[1] ) == cFind } ) ) > 0
            cResult := ::aContents[ nCount ][2][ nPointer ][2]
         EndIf
      EndIf
   EndIf

return cResult


METHOD PROCEDURE WriteString( cSection, cIdent, cString ) CLASS TIniFile

local nPointer
local nCount
local cFind

   If Empty( cIdent )
      hb_gtAlert( "Deve especificar um identificador", { "Ok" }, "W+/R", "W+/B" )

   ElseIF Empty( cSection )
      cFind := Lower( cIdent )

      If ( nPointer := AScan( ::aContents, ;
                        { |xFind| HB_ISSTRING( xFind[1] ) .and. Lower( xFind[1] ) == cFind .and. HB_ISSTRING( xFind[2] ) } ) ) > 0
         ::aContents[ nPointer ][2] := cString
      Else
         AAdd( ::aContents, NIL )
         AIns( ::aContents, 1 )
         ::aContents[1] := { cIdent, cString }
      EndIf

   Else
      cFind := Lower( cSection )

      If ( nCount := AScan( ::aContents, ;
                        { |xFind| HB_ISSTRING( xFind[1] ) .and. Lower( xFind[1] ) == cFind .and. HB_ISARRAY( xFind[2] ) } ) ) > 0
         cFind := Lower( cIdent )

         If ( nPointer := AScan( ::aContents[ nCount ][2], ;
                           { |xItem| HB_ISSTRING( xItem[1] ) .and. Lower( xItem[1] ) == cFind } ) ) > 0
            ::aContents[ nCount ][2][ nPointer ][2] := cString
         Else
            AAdd( ::aContents[ nCount ][2], { cIdent, cString } )
         EndIf

      Else
         AAdd( ::aContents, { cSection, { { cIdent, cString } } } )
      EndIf
   EndIf

return


METHOD ReadNumber( cSection, cIdent, nDefault ) CLASS TIniFile
   return Val( ::ReadString( cSection, cIdent, Str( nDefault ) ) )


METHOD PROCEDURE WriteNumber( cSection, cIdent, nNumber ) CLASS TIniFile
   ::WriteString( cSection, cIdent, hb_ntos( nNumber ) )
return


METHOD ReadDate( cSection, cIdent, dDefault ) CLASS TIniFile
   return hb_SToD( ::ReadString( cSection, cIdent, DToS( dDefault ) ) )


METHOD PROCEDURE WriteDate( cSection, cIdent, dDate ) CLASS TIniFile
   ::WriteString( cSection, cIdent, DToS( dDate ) )
return


METHOD ReadBool( cSection, cIdent, lDefault ) CLASS TIniFile
   return ::ReadString( cSection, cIdent, iif( lDefault, ".T.", ".F." ) ) == ".T."


METHOD PROCEDURE WriteBool( cSection, cIdent, lBool ) CLASS TIniFile
   ::WriteString( cSection, cIdent, iif( lBool, ".T.", ".F." ) )
return


METHOD PROCEDURE DeleteKey( cSection, cIdent ) CLASS TIniFile

local nPointer
local nCount

   cSection := Lower( cSection )

   If ( nCount := AScan( ::aContents, ;
                     { |xSec| HB_ISSTRING( xSec[1] ) .and. Lower( xSec[1] ) == cSection } ) ) > 0
      cIdent := Lower( cIdent )

      If ( nPointer := AScan( ::aContents[ nCount ][2], ;
                        { |xItem| HB_ISSTRING( xItem[1] ) .and. Lower( xItem[1] ) == cIdent } ) ) > 0
         hb_ADel( ::aContents[ nCount ][2], nPointer, pTRUE )
      EndIf

   EndIf

return


METHOD PROCEDURE EraseSection( cSection ) CLASS TIniFile

local nPointer

   If Empty( cSection )
      while ( nPointer := AScan( ::aContents, { |xItem| HB_ISSTRING( xItem[1] ) .and. HB_ISSTRING( xItem[2] ) } ) ) > 0
         hb_ADel( ::aContents, nPointer, pTRUE )
      enddo

   Else
      cSection := Lower( cSection )
      If ( nPointer := AScan( ::aContents, ;
                        { |xItem| HB_ISSTRING( xItem[1] ) .and. Lower( xItem[1] ) == cSection .and. HB_ISARRAY( xItem[2] ) } ) ) > 0
         hb_ADel( ::aContents, nPointer, pTRUE )
      EndIf
   EndIf

return


METHOD ReadSection( cSection ) CLASS TIniFile

local nPointer
local nPos
local aSection := {}

   If Empty( cSection )
      for nPos := 1 to Len( ::aContents )
         If HB_ISSTRING( ::aContents[ nPos ][1] ) .and. HB_ISSTRING( ::aContents[ nPos ][2] )
            AAdd( aSection, ::aContents[ nPos ][1] )
         EndIf
      next

   Else
      cSection := Lower( cSection )

      If ( nPointer := AScan( ::aContents, ;
                        { |xSec| HB_ISSTRING( xSec[1] ) .and. xSec[1] == cSection .and. HB_ISARRAY( xSec[2] ) } ) ) > 0
         for nPos := 1 to Len( ::aContents[ nPointer ][2] )
            If ::aContents[ nPointer ][2][ nPos ][1] != NIL
               AAdd( aSection, ::aContents[ nPointer ][2][ nPos ][1] )
            EndIf
         next
      EndIf
   EndIf

return aSection


METHOD ReadSections() CLASS TIniFile

local nPos
local aSections := {}

   for nPos := 1 to Len( ::aContents )
      If HB_ISARRAY( ::aContents[ nPos ][2] )
         AAdd( aSections, ::aContents[ nPos ][1] )
      EndIf
   next

return aSections


METHOD PROCEDURE UpdateFile() CLASS TIniFile

local hFile
local nPos
local nCount

   begin sequence

      hFile := FCreate( ::cFilename, FC_NORMAL )

      for nPos := 1 to Len( ::aContents )
         If HB_ISNIL( ::aContents[ nPos ][1] )
            FWrite( hFile, ::aContents[ nPos ][2] + hb_eol() )

         ElseIF HB_ISARRAY( ::aContents[ nPos ][2] )
            FWrite( hFile, "[" + ::aContents[ nPos ][1] + "]" + hb_eol() )

            for nCount := 1 to Len( ::aContents[ nPos ][2] )
               If HB_ISNIL( ::aContents[ nPos ][ 2 ][ nCount ][1] )
                  FWrite( hFile, ::aContents[ nPos ][2][ nCount ][2] + hb_eol() )
               Else
                  FWrite( hFile, ::aContents[ nPos ][2][ nCount ][1] + "=" + ::aContents[ nPos ][2][ nCount ][2] + hb_eol() )
               EndIf
            next

            FWrite( hFile, hb_eol() )

         ElseIF HB_ISSTRING( ::aContents[ nPos ][2] )
            FWrite( hFile, ::aContents[ nPos ][1] + "=" + ::aContents[ nPos ][2] + hb_eol() )

         EndIf
      next

   always
      FClose( hFile )
   end sequence

return