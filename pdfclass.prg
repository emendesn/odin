/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*	Classes para Criacao de arquivos PDF.
*
*/

#require "hbhpdf"

#include "hbclass.ch"
#include "inkey.ch"

#define PDF_PORTRAIT                        1
#define PDF_LANDSCAPE                       2
#define PDF_TXT                             3

// constante harupdf.ch para Compactacao
#define HPDF_COMP_ALL                       0x0F

// constante harupdf.ch para info do arquivo gerado
#define HPDF_INFO_AUTHOR                    2
#define HPDF_INFO_CREATOR                   3
#define HPDF_INFO_PRODUCER                  4
#define HPDF_INFO_TITLE                     5
#define HPDF_INFO_SUBJECT                   6

// constante harupdf.ch para o tamanho do papel
#define HPDF_PAGE_SIZE_A4                   3

// constante harupdf.ch para a direcao de impressao
#define HPDF_PAGE_PORTRAIT                  0
#define HPDF_PAGE_LANDSCAPE                 1




/***
*
*	PDFClass
*
*	Objeto para criacao de arquivos PDF
*
*	Objetos:
*            :nTop    - Define a linha inicial para o posicionamento da janela
*            :Left   - Define a coluna inicial para o posicionamento da janela
*            :Bottom - Define a linha final para o posicionamento da janela
*            :Right  - Define a coluna final para o posicionamento da janela
*            :Border - Define o formato da borda da janela
*            :Color  - Define a cor da janela
*            :Header - Define a mensagem apresentada no topo da janela
*
*	Metodos:
*            :Open()  - Cria o objeto
*            :Open()  - Exibe na tela o objeto criado
*            :Close() - Fecha o objeto criado
*
*/
CREATE CLASS PDFClass

   EXPORTED:
      VAR    oPdf        AS OBJECT
      VAR    oPage       AS OBJECT
      VAR    cFileName   AS CHARACTER INIT ""
      VAR    nRow        AS NUMERIC   INIT 999
      VAR    nCol        AS NUMERIC   INIT 0
      VAR    nAngle      AS NUMERIC   INIT 0
      VAR    cFontName   AS CHARACTER INIT "Courier"
      VAR    nFontSize   AS NUMERIC   INIT 9
      VAR    nLineHeight AS NUMERIC   INIT 1.3
      VAR    nMargin     AS NUMERIC   INIT 30
      VAR    nType       AS NUMERIC   INIT 1
      VAR    nPdfPage    AS NUMERIC   INIT 0
      VAR    nPageNumber AS NUMERIC   INIT 0
      VAR    cHeader     AS CHARACTER INIT {}
      VAR    cCodePage   AS CHARACTER INIT "CP1252"

   METHOD AddPage()
   METHOD RowToPDFRow( nRow )
   METHOD ColToPDFCol( nCol )
   METHOD MaxRow()
   METHOD MaxCol()
   METHOD DrawText( nRow, nCol, xValue, cPicture, nFontSize, cFontName, nAngle, anRGB ) 
   METHOD DrawLine( nRowi, nColi, nRowf, nColf, nPenSize ) 
   METHOD DrawRetangle( nTop, nLeft, nWidth, nHeight, nPenSize, nFillType, anRGB ) 
   METHOD DrawImage( cJPEGFile, nRow, nCol, nWidth, nHeight ) 
   METHOD Cancel()
   METHOD PrnToPdf( cInputFile )
   METHOD SetType( nType )
   METHOD PageHeader()
   METHOD MaxRowTest( nRows )
   METHOD SetInfo( cAuthor, cCreator, cTitle, cSubject )
   METHOD PrintPreview()
   METHOD Begin()
   METHOD End()

ENDCLASS


/***
*
*	:Begin()
*
*	Metodo utilizado para a criacao do objeto na tela
*
*/
METHOD PROCEDURE Begin() CLASS PDFClass

   If ::nType > 2
      If Empty( ::cFileName )
         ::cFileName := MyTempFile( "LST" )
      EndIf
      SET PRINTER TO ( ::cFileName )
      SET DEVICE TO PRINT
   Else
      IF Empty( ::cFileName )
         ::cFileName := MyTempFile( "PDF" )
      EndIf
      ::oPdf := HPDF_New()
      HPDF_SetCompressionMode( ::oPdf, HPDF_COMP_ALL )

      #ifdef __PLATFORM_WINDOWS
         ::cFontName := HPDF_LoadTTFontFromFile( ::oPDF, "c:\windows\fonts\cour.ttf", .t. )
      #endif

      #ifdef __PLATAFORM__LINUX
         ::cFontName := HPDF_LoadTTFontFromFile( ::oPDF, "/usr/share/fonts/lucon.ttf", .t. )
      #endif

      If .not. HB_ISNIL( ::cCodePage )
         HPDF_SetCurrentEncoder( ::oPDF, ::cCodePage )
      EndIf
   EndIf

return


METHOD PROCEDURE End() CLASS PDFClass

   If ::nType > 2
      SET DEVICE TO SCREEN
      SET PRINTER TO
      RUN ( "cmd /c start notepad.exe " + ::cFileName )
      FErase( ::cFileName )
   Else
      If ::nPdfPage == 0
         ::AddPage()
         ::DrawText( 10, 10, "NENHUM CONTEUDO (NO CONTENT)",, ::nFontSize * 2 )
      EndIf
      If File( ::cFileName )
         FErase( ::cFileName )
      EndIf
         HPDF_SaveToFile( ::oPdf, ::cFileName )
         HPDF_Free( ::oPdf )
   EndIf

return


METHOD PROCEDURE SetInfo( cAuthor, cCreator, cTitle, cSubject ) CLASS PDFClass

   IF ::nType <= 2

      cAuthor  := iif( cAuthor == NIL, "Edilson Mendes", cAuthor )
      cCreator := iif( cCreator == NIL, "Odin", cCreator )
      cTitle   := iif( cTitle == NIL, "", cTitle )
      cSubject := iif( cSubject == NIL, cTitle, cSubject )

      HPDF_SetInfoAttr( ::oPDF, HPDF_INFO_AUTHOR, cAuthor )
      HPDF_SetInfoAttr( ::oPDF, HPDF_INFO_CREATOR, cCreator )
      HPDF_SetInfoAttr( ::oPDF, HPDF_INFO_TITLE, cTitle )
      HPDF_SetInfoAttr( ::oPdf, HPDF_INFO_SUBJECT, cSubject )
      HPDF_SetInfoDateAttr(   Year( Date() ), Month( Date() ), Day( Date() ), ;
                              Val( Substr( Time(), 1, 2 ) ), ;
                              Val( Substr( Time(), 4, 2 ) ), ;
                              Val( Substr( Time(), 7, 2 ) ), "+", 4, 0 )

   EndIf

return


METHOD PROCEDURE SetType( nType ) CLASS PDFClass

   If nType != NIL
      ::nType := nType
   EndIf
   ::nFontSize := iif( ::nType == 1, 9, 6 )

return

   
METHOD PROCEDURE AddPage() CLASS PDFClass

   If ::nType < 3
      ::oPage := HPDF_AddPage( ::oPdf )
      HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, iif( ::nType == 2, HPDF_PAGE_PORTRAIT, HPDF_PAGE_LANDSCAPE ) )
      HPDF_Page_SetFontAndSize( ::oPage, HPDF_GetFont( ::oPdf, ::cFontName, ::cCodePage ), ::nFontSize )
   EndIf
   ::nRow := 0

return


METHOD PROCEDURE Cancel() CLASS PDFClass

   If ::nType < 3
      HPDF_Free( ::oPdf )
   EndIf

return


METHOD PROCEDURE DrawText( nRow, nCol, xValue, cPicture, nFontSize, cFontName, nAngle, anRGB ) CLASS PDFClass

local nRadian
local cTexto

   nFontSize := iif( nFontSize == NIL, ::nFontSize, nFontSize )
   cFontName := iif( cFontName == NIL, ::cFontName, cFontName )
   cPicture  := iif( cPicture == NIL, "", cPicture )
   nAngle    := iif( nAngle == NIL, ::nAngle, nAngle )
   cTexto    := Transform( xValue, cPicture )

   ::nCol := nCol + Len( cTexto ) 

   If ::nType > 2
      @ nRow, nCol SAY cTexto
   Else
      nRow := ::RowToPDFRow( nRow )
      nCol := ::ColToPDFCol( nCol )
      HPDF_Page_SetFontAndSize( ::oPage, HPDF_GetFont( ::oPdf, cFontName, ::cCodePage ), nFontSize )
      If anRGB != NIL
         HPDF_Page_SetRGBFill( ::Page, anRGB[ 1 ], anRGB[ 2 ], anRGB[ 3 ] )
         HPDF_Page_SetRGBStroke( ::Page, anRGB[ 1 ], anRGB[ 2], anRGB[ 3] )
      EndIf
      HPDF_Page_BeginText( ::oPage )
      nRadian := ( nAngle / 180 ) * 3.141592
      HPDF_Page_SetTextMatrix( ::oPage, Cos( nRadian ), Sin( nRadian ), -Sin( nRadian ), Cos( nRadian ), nCol, nRow )
      HPDF_Page_ShowText( ::oPage, cTexto )
      HPDF_Page_EndText( ::oPage )
      If anRGB != NIL
         HPDF_Page_SetRGBFill( ::Page, 0, 0, 0 )
         HPDF_Page_SetRGBStroke( ::Page, 0, 0, 0 )
      EndIf
   EndIf

return


METHOD PROCEDURE DrawLine( nRowi, nColi, nRowf, nColf, nPenSize ) CLASS PDFClass

   If ::nType > 2
      nRowi := Round( nRowi, 0 )
      nColi := Round( nColi, 0 )
      @ nRowi, nColi SAY Replicate( "-", nColf - nColi )
      ::nCol := Col()
   Else
      nPenSize := iif( nPenSize == NIL, 0.2, nPenSize )
      nRowi := ::RowToPDFRow( nRowi )
      nColi := ::ColToPDFCol( nColi )
      nRowf := ::RowToPDFRow( nRowf )
      nColf := ::ColToPDFCol( nColf )
      HPDF_Page_SetLineWidth( ::oPage, nPenSize )
      HPDF_Page_MoveTo( ::oPage, nColi, nRowi )
      HPDF_Page_LineTo( ::oPage, nColf, nRowf )
      HPDF_Page_Stroke( ::oPage )
   EndIf

return


METHOD PROCEDURE DrawImage( cJPEGFile, nRow, nCol, nWidth, nHeight ) CLASS PDFClass

local oImage

   If ::nType <= 2

      nRow    := ::RowToPDFRow( nRow )
      nCol    := ::ColToPDFCol( nCol )
      nWidth  := Int( nWidth * ::nFontSize / 1.666 )
      nHeight := nHeight * ::nFontSize
      IF ValType( cJPEGFile ) == "C"
         oImage := HPDF_LoadJPEGImageFromFile( ::oPdf, cJPEGFile )
      //ELSE
      //   oImage := HPDF_LoadJPEGImageFromMem( cJPEGFile )
      //   oImage := HPDF_LoadRawImageFromMem() // testar
      EndIf
      HPDF_Page_DrawImage( ::oPage, oImage, nCol, nRow, nWidth, nHeight )

   EndIf

return


METHOD PROCEDURE DrawRetangle( nTop, nLeft, nWidth, nHeight, nPenSize, nFillType, anRGB ) CLASS PDFClass

   IF ::nType <= 2

      nFillType := iif( nFillType == NIL, 1, nFillType )
      nPenSize  := iif( nPenSize == NIL, 0.2, nPenSize )
      nTop      := ::RowToPDFRow( nTop )
      nLeft     := ::ColToPDFCol( nLeft )
      nWidth    := ( nWidth ) * ::nFontSize / 1.666
      nHeight   := -( nHeight ) * :: nFontSize 
      HPDF_Page_SetLineWidth( ::oPage, nPenSize )
      If anRGB != NIL
         HPDF_Page_SetRGBFill( ::oPage, anRGB[ 1 ], anRGB[ 2 ], anRGB[ 3 ] )
         HPDF_Page_SetRGBStroke( ::oPage, anRGB[ 1 ], anRGB[ 2 ], anRGB[ 3 ] )
      EndIf
      HPDF_Page_Rectangle( ::oPage, nLeft, nTop, nWidth, nHeight )
      If nFillType == 1
         HPDF_Page_Stroke( ::oPage )     // borders only
      ElseIf nFillType == 2
         HPDF_Page_Fill( ::oPage )       // inside only
      Else
         HPDF_Page_FillStroke( ::oPage ) // all
      EndIf
      IF anRGB != NIL
         HPDF_Page_SetRGBStroke( ::oPage, 0, 0, 0 )
         HPDF_Page_SetRGBFill( ::oPage, 0, 0, 0 )
      EndIf

   EndIf

return


METHOD RowToPDFRow( nRow ) CLASS PDFClass
   return HPDF_Page_GetHeight( ::oPage ) - ::nMargin - ( nRow * ::nFontSize * ::nLineHeight )


METHOD ColToPDFCol( nCol ) CLASS PDFClass
   Return nCol * ::nFontSize / 1.666 + ::nMargin


METHOD MaxRow() CLASS PDFClass

local nPageHeight
local nMaxRow     := 63

   If ::nType <= 2
      nPageHeight := HPDF_Page_GetHeight( ::oPage ) - ( ::nMargin * 2 )
      nMaxRow     := Int( nPageHeight / ( ::nFontSize * ::nLineHeight )  )
   EndIf

RETURN nMaxRow


METHOD MaxCol() CLASS PDFClass

local nPageWidth
local nMaxCol    := 132

   If ::nType <= 2
      nPageWidth := HPDF_Page_GetWidth( ::oPage ) - ( ::nMargin * 2 )
      nMaxCol    := Int( nPageWidth / ::nFontSize * 1.666 )
   EndIf

return nMaxCol


METHOD PROCEDURE PrnToPdf( cInputFile ) CLASS PDFClass

local cTxtReport := MemoRead( cInputFile ) + Chr(12)
local cTxtPage
local cTxtLine
local nRow

   TokenInit( @cTxtReport, Chr(12) )
   while .not. TokenEnd()
      cTxtPage := TokenNEXT( cTxtReport ) + hb_eol()
      If Len( cTxtPage ) > 5
         If Substr( cTxtPage, 1, 1 ) == Chr(13)
            cTxtPage := Substr( cTxtPage, 2 )
         EndIf
         ::AddPage()
         nRow := 0
         while At( hb_eol(), cTxtPage ) != 0
            cTxtLine := Substr( cTxtPage, 1, At( hb_eol(), cTxtPage ) - 1 )
            cTxtPage := Substr( cTxtPage, At( hb_eol(), cTxtPage ) + 2 )
            ::DrawText( nRow++, 0, cTxtLine )
         enddo
      EndIf
   enddo

return


METHOD PROCEDURE PageHeader() CLASS PDFClass

   ::nPdfPage    += 1
   ::nPageNumber += 1
   ::nRow        := 0
   ::nCol        := 0
   ::AddPage()
   If Len( ::cHeader ) != 0
      ::DrawText( 0, 0, "Odin" )
      ::DrawText( 0, ( ::MaxCol() - Len( ::cHeader ) ) / 2, ::cHeader )
      ::DrawText( 0, ::MaxCol() - 12, "Folha " + StrZero( ::nPageNumber, 6 ) )
      ::DrawLine( 0.5, 0, 0.5, ::MaxCol() )
      ::nRow := 2
      ::nCol := 0
   EndIf

return


METHOD PROCEDURE MaxRowTest( nRows ) CLASS PDFClass

   nRows := iif( nRows == NIL, 0, nRows )
   If ::nRow > ::MaxRow() - 2 - nRows
      ::PageHeader()
   EndIf

return

METHOD PROCEDURE PrintPreview() CLASS PDFClass

local cProgram := ''

   #if defined( __PLATFORM__UNIX )
      cProgram := '/usr/bin/xdg-open'
   #else
      cProgram := 'cmd /c start '
   #endif

   cProgram += ' ' + ::cFileName
   hb_OpenProcess( LTrim( cProgram ),,,,.t. )

return


FUNCTION TxtSaida()
   return { "PDF Paisagem", "PDF Retrato", "Matricial" }


FUNCTION MyTempFile( cExtensao )
   return "temp." + cExtensao