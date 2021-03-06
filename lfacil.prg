/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  lfacil.prg
*
***/

#require 'xhb'

#include 'set.ch'
#include 'box.ch'
#include 'inkey.ch'
#include 'error.ch'
#include 'common.ch'
#include 'setcurs.ch'
#include 'getexit.ch'
#include 'hbmemory.ch'
//#include 'apostas.ch'
#include 'lfacil.ch'
#include 'dbfunc.ch'
#include 'main.ch'

//#include 'hbxml.ch'

static aLotoFacil

memvar GetList

/***
*
*	LTFMntBrowse()
*
*	Exibe a relacao de concursos ja realizados.
*
*/
PROCEDURE LTFMntBrowse()

local oBrowse, oColumn
local oTmpButton, oScrollBar
local nKey
local nTmp
local nLastKeyType  := hb_MilliSeconds()
local nRefresh      := 1000              /* um segundo como defaul */
local nCount        := 0
local nMenuItem     := 1
local nMaxItens     := 0
local lSair         := pFALSE
local oWindow
local bFiltro

local oBrwDezenas
local aSelDezenas   := {}
local aDezenas
local nRow          := 1
local nPointer
local nPosDezenas   := 1
local nLinDezenas
local nColDezenas
local nGrade


	If SystemConcurso() == pLOTO_FACIL

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_FACIL } ) ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				nGrade   := Round( Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] ) / 10, 0 )
				aDezenas := Array( nGrade, 10 )

				for nLinDezenas := 1 to nGrade
					for nColDezenas := 1 to 10
						If nPosDezenas <= Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )
							aDezenas[ nLinDezenas ][ nColDezenas ] := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nPosDezenas ]
						Else
							aDezenas[ nLinDezenas ][ nColDezenas ] := Space(2)
						EndIf
						nPosDezenas++
					next
				next

				// Cria o Objeto Windows
				oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 15
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 25
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 15
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 25
				oWindow:cHeader := PadC( SystemNameConcurso(), Len( SystemNameConcurso() ) + 2, ' ')
				oWindow:Open()

				// Desenha a Linha de Botoes
				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				// Estabelece o Filtro para exibicao dos registros
				bFiltro := { || CONCURSO->CON_JOGO == pLOTO_FACIL .and. .not. CONCURSO->( Eof() ) }

				dbSelectArea('CONCURSO')
				CONCURSO->( dbEval( {|| nMaxItens++ }, bFiltro ) )
				CONCURSO->( dbSetOrder(2), dbSeek( pLOTO_FACIL ) )

				begin sequence

					// Exibe o Browse com as Apostas
					oBrowse               	:= 	TBrowseDB( oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
															( oWindow:nBottom- 2 ) - ( nGrade + 2 ), oWindow:nRight- 1 )
					oBrowse:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFiltro ) ) <> 0, ( nCount += xRecno, xRecno ), xRecno ) }
					oBrowse:goTopBlock    	:= 	{ || nCount := 1, GoTopDB( bFiltro ) }
					oBrowse:goBottomBlock 	:= 	{ || nCount := nMaxItens, GoBottomDB( bFiltro ) }
					oBrowse:colorSpec     	:= SysBrowseColor()
					oBrowse:headSep       	:= Chr(205)
					oBrowse:colSep        	:= Chr(179)
					oBrowse:Cargo         	:= {}

					// Adiciona as Colunas
					oColumn 			:= TBColumnNew( PadC( 'Concurso', 10 ), CONCURSO->( FieldBlock( 'CON_CONCUR' ) ) )
					oColumn:picture 	:= '@!'
					oColumn:width   	:= 10
					oBrowse:addColumn( oColumn )

					oColumn 			:= TBColumnNew( PadC( 'Sorteio', 10 ), CONCURSO->( FieldBlock( 'CON_SORTEI' ) ) )
					oColumn:picture 	:= '@D 99/99/99'
					oColumn:width   	:= 10
					oBrowse:addColumn( oColumn )

					hb_DispBox( ( oWindow:nBottom- 2 ) - ( nGrade + 1 ), oWindow:nLeft+ 1, ;
                                ( oWindow:nBottom- 2 ) - ( nGrade + 1 ), oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )                                

					// Exibe a Primeira Coluna de Dezenas
					oBrwDezenas               	:= 	TBrowseNew(	( oWindow:nBottom- 2 ) - nGrade, oWindow:nLeft+ 1, ;
                                                                ( oWindow:nBottom- 2 ) - 1, oWindow:nRight- 1 )
					oBrwDezenas:skipBlock     	:=	{ |x,k| ;
                                                        k := iif( Abs(x) >= iif( x >= 0,                         ;
                                                                            Len( aDezenas ) - nRow, nRow - 1),   ;
                                                                iif(x >= 0, Len( aDezenas ) - nRow,1 - nRow), x );
                                                                , nRow += k, k                                   ;
                                                    }
					oBrwDezenas:goTopBlock    	:= 	{ || nRow := 1 }
					oBrwDezenas:goBottomBlock 	:= 	{ || nRow := Len( aDezenas ) }
					oBrwDezenas:colorSpec     	:= SysBrowseColor()
					oBrwDezenas:autoLite      	:= pFALSE

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 1] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 2] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 3] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 4] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 5] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 6] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 7] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 8] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 9] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][10] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDezenas, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oBrwDezenas:addColumn( oColumn )


					// Realiza a Montagem da Barra de Rolagem
					oScrollBar           	:= ScrollBar( oWindow:nTop+ 3, ( oWindow:nBottom- 2 ) - ( nGrade + 2 ), oWindow:nRight )
					oScrollBar:colorSpec 	:= SysScrollBar()
					oScrollBar:display()


					// Desenha os botoes da tela
					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
					oTmpButton:sBlock    := { || LTFIncluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
					oTmpButton:sBlock    := { || LTFModificar() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' &Excluir ' )
					oTmpButton:sBlock    := { || LTFExcluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Ac&oes ' )
					oTmpButton:sBlock    := { || LTFAcoes() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+42, ' &Sair ' )
					oTmpButton:sBlock    := { || lSair := pTRUE }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					AEval( oBrowse:Cargo, { |xItem| xItem[1]:Display() } )
					oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

					while .not. lSair

                        // Destaca o registro selecionado no Browse 
                        oBrowse:colorRect( { oBrowse:rowPos, 1, oBrowse:rowPos, oBrowse:colCount}, { 1, 2})
						oBrowse:forceStable()
						oBrowse:colorRect( { oBrowse:rowPos, oBrowse:freeze + 1, oBrowse:rowPos, oBrowse:colCount}, { 8, 2})
						oBrowse:hilite()

                        // Atualiza a barra de rolagem
						oScrollBar:current := nCount * ( 100 / nMaxItens )
                        oScrollBar:update()

                        // Atualiza a grade com as dezenas dos jogos
                        If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
                            If Len( aSelDezenas := ParseDezenas( JOGOS->JOG_DEZENA ) ) > 0
                                oBrwDezenas:refreshAll()
                                oBrwDezenas:forceStable()
                            EndIf
                        EndIf    

                        // Aguarda a acao do usuario
                        nKey := Inkey( (nRefresh / 1000), INKEY_ALL )

						If oBrowse:stable .and. nKey > 0

							nLastKeyType := hb_MilliSeconds()
							nRefresh     := 1000					

							do case
								case ( nPointer := AScan( pBRW_INKEYS, { |xKey| xKey[ pBRW_KEY ] == nKey } ) ) > 0
                                    Eval( pBRW_INKEYS[ nPointer ][ pBRW_ACTION ], oBrowse )

								case ( nPointer := AScan( oBrowse:Cargo, { |xKey| xKey[ pBRW_ACTION ] == Upper( chr( nKey ) ) } ) ) > 0
									If oBrowse:Cargo[ nMenuItem ][1]:HasFocus
										oBrowse:Cargo[ nMenuItem ][1]:KillFocus()
									EndIf
									nMenuItem := nPointer
									oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

								case nKey == K_LEFT .or. nKey == K_LBUTTONDOWN
									If oBrowse:Cargo[ nMenuItem ][1]:HasFocus
										oBrowse:Cargo[ nMenuItem ][1]:KillFocus()
									EndIf
									If --nMenuItem < 1
										nMenuItem := 1
									EndIf
									oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

								case nKey == K_RIGHT .or. nKey == K_RBUTTONUP
									If oBrowse:Cargo[ nMenuItem ][1]:HasFocus
										oBrowse:Cargo[ nMenuItem ][1]:KillFocus()
									EndIf
									If ++nMenuItem > Len( oBrowse:Cargo )
										nMenuItem := Len( oBrowse:Cargo )
									EndIf
									oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

								case nKey == K_MWFORWARD
									If MRow() >= oBrowse:nTop .and. MRow() <= oBrowse:nBottom .and. ;
										Mcol() >= oBrowse:nTop .and. Mcol() <= oBrowse:nRight
										oBrowse:up()
									EndIf

								case nKey == K_MWBACKWARD
									If MRow() >= oBrowse:nTop .and. MRow() <= oBrowse:nBottom .and. ;
										Mcol() >= oBrowse:nTop .and. Mcol() <= oBrowse:nRight
										oBrowse:down()
									EndIf	

								case nKey == K_ENTER
									oBrowse:Cargo[ nMenuItem ][1]:Select()
									oBrowse:refreshAll()

                            endcase

						Else
							If ( nTmp := Int( ( ( hb_MilliSeconds() - nLastKeyType ) / 1000 ) / 60 ) ) > 720
								nRefresh := 60000 /* um minuto a cada 12 horas */
							ElseIf nTmp > 60
								nRefresh := 30000
							ElseIf nTmp > 15
								nRefresh := 10000
							ElseIf nTmp > 1
								nRefresh := 3000
							ElseIf nTmp > 0
								nRefresh := 2000
							EndIf
						EndIf

					enddo

				end sequence

			always
				// Fecha o Objeto Windows
				oWindow:Close()

				// Restaura a tabela da Pilha
				DstkPop()
			end sequence

		EndIf

	EndIf

return


/***
*
*	LTFIncluir()
*
*	Realiza a inclusao dos dados para o concurso da LOTO FACIL.
*
*   LTFMntBrowse -> LTFIncluir
*
*/
STATIC PROCEDURE LTFIncluir

local nPointer
local lContinua     := pTRUE
local lPushButton
local oWindow
local nCodigo       := 1
local cAutoSequence
local oIniFile

memvar xCount, xTemp


	If SystemConcurso() == pLOTO_FACIL

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_FACIL } ) ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Inicializa as Variaveis de Dados
				xInitLotoFacil

				// Inicializa as Variaveis de no vetor aLotoFacil
				xStoreLotoFacil

				//
				// Realiza a abertura do arquivo INI
				//
				oIniFile := TIniFile():New( 'odin.ini' )

				//
				// Parametro para definir a sequencia automatica
				//
				If ( cAutoSequence := oIniFile:ReadString( 'LOTOFACIL', 'AUTO_SEQUENCE', '0' ) ) == '1'
					// Define o codigo sequencial
					dbEval( { || nCodigo++ }, { || CONCURSO->CON_JOGO == pLOTO_FACIL .and. .not. CONCURSO->( Eof() ) } )
					pLTF_CONCURSO := StrZero( nCodigo, 5 )
				EndIf


				// Cria o Objeto Windows
				oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  8
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 21
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  9
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 21
				oWindow:Open()

				while lContinua

					@ oWindow:nTop+ 1, oWindow:nLeft+14 GET     pLTF_CONCURSO                                  ;
														PICT    '@K 99999'                                     ;
														SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),5));
														CAPTION 'Concurso'                                     ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 1, oWindow:nLeft+30 GET     pLTF_SORTEIO                                   ;
														PICT    '@KD 99/99/99'                                 ;
														CAPTION 'Sorteio'                                      ;
														COLOR   SysFieldGet()

					hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 2, oWindow:nLeft+ 2, ' Dezenas ', SystemLabelColor() )

					@ oWindow:nTop+ 3, oWindow:nLeft+12 GET   pLTF_DEZENA_01                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+16 GET   pLTF_DEZENA_02                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+20 GET   pLTF_DEZENA_03                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+24 GET   pLTF_DEZENA_04                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+28 GET   pLTF_DEZENA_05                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					
					@ oWindow:nTop+ 5, oWindow:nLeft+12 GET   pLTF_DEZENA_06                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+16 GET   pLTF_DEZENA_07                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+20 GET   pLTF_DEZENA_08                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+24 GET   pLTF_DEZENA_09                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+28 GET   pLTF_DEZENA_10                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+12 GET   pLTF_DEZENA_11                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+16 GET   pLTF_DEZENA_12                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+20 GET   pLTF_DEZENA_13                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+24 GET   pLTF_DEZENA_14                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+28 GET   pLTF_DEZENA_15                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()


					hb_DispBox( oWindow:nTop+ 8, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 8, oWindow:nRight -1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 8, oWindow:nLeft+ 2, ' Premio ', SystemLabelColor() )

					@ oWindow:nTop+ 9, oWindow:nLeft+12 SAY   'Ganhadores'                                     ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+ 9, oWindow:nLeft+30 SAY   'Premio'                                         ;
														COLOR SystemLabelColor()

					// Coluna de Acertos			
					@ oWindow:nTop+10, oWindow:nLeft+10 GET     pLTF_ACERTO_15                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '15 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '15', pLTF_SORTEIO )

					@ oWindow:nTop+11, oWindow:nLeft+10 GET     pLTF_ACERTO_14                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '14 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTF_SORTEIO )

					@ oWindow:nTop+12, oWindow:nLeft+10 GET     pLTF_ACERTO_13                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '13 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTF_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+10 GET     pLTF_ACERTO_12                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '12 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '12', pLTF_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+10 GET     pLTF_ACERTO_11                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '11 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '11', pLTF_SORTEIO )

					// Coluna de Premios			
					@ oWindow:nTop+10, oWindow:nLeft+24 GET   pLTF_PREMIO_15                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '15', pLTF_SORTEIO )

					@ oWindow:nTop+11, oWindow:nLeft+24 GET   pLTF_PREMIO_14                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTF_SORTEIO )

					@ oWindow:nTop+12, oWindow:nLeft+24 GET   pLTF_PREMIO_13                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTF_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+24 GET   pLTF_PREMIO_12                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '12', pLTF_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+24 GET   pLTF_PREMIO_11                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '11', pLTF_SORTEIO )

					hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
								oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                     ;
															CAPTION ' Con&firma '                              ;
															COLOR   SysPushButton()                            ;
															STYLE   ''                                         ;
															WHEN    Val( pLTF_CONCURSO ) > 0 .and.             ;
																	.not. Empty( pLTF_SORTEIO ) .and.          ;
																	.not. Empty( pLTF_DEZENA_01 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_02 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_03 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_04 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_05 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_06 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_07 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_08 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_09 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_10 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_11 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_12 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_13 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_14 ) .and.        ;
																	.not. Empty( pLTF_DEZENA_15 )              ;
															STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

					@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                     ;
															CAPTION ' Cance&lar '                              ;
															COLOR   SysPushButton()                            ;
															STYLE   ''                                         ;
															STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

					Set( _SET_CURSOR, SC_NORMAL )

					READ

					Set( _SET_CURSOR, SC_NONE )

					If lContinua .and. LastKey() != K_ESC

						pLTF_CONCURSO := StrZero( Val( pLTF_CONCURSO ), 5 )

						//************************************************************************
						//*Verifica se concurso ja existe                                        *
						//************************************************************************
						If .not. CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + pLTF_CONCURSO ) )

							//************************************************************************
							//*Verifica a duplicidade de dezenas no concurso                         *
							//************************************************************************
							If xDuplicSequencia( aLotoFacil[ pLTF_POS_DADOS ][ pLTF_POS_DEZENAS ] )

								//************************************************************************
								//*Verifica cada item da primeira sequencia para identificar se o valor  *
								//*digitado esta dentro da faixa especifica do concurso                  *
								//************************************************************************
								If xVerificaSequencia( 	aLotoFacil[ pLTF_POS_DADOS ][ pLTF_POS_DEZENAS ], ;
														pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )

									If LTFGravaDados()
										lContinua := pFALSE
									EndIf

								Else
									ErrorTable( '203' )  // Dezena digitada encontra-se fora da faixa.
								EndIf

							Else
								ErrorTable( '201' )  // A sequencia encontra em duplicidade.
							EndIf

						Else
							ErrorTable( '001' )  // Concurso ja Existente.
						EndIf

					EndIf

				enddo

			always
				// Fecha o Objeto Windows
				oWindow:Close()

				// Atualiza o parametro do arquivo de configuracao de autonumeracao
				oIniFile:WriteString( 'LOTOFACIL', 'AUTO_SEQUENCE', cAutoSequence )

				// Atualiza o arquivo de Configuracao
				oIniFile:UpdateFile()

				// Restaura a tabela da Pilha
				DstkPop()
			end sequence

		EndIf

	EndIf

return


/***
*
*	LTFModificar()
*
*	Realiza a manutencao dos dados para o concurso da LOTO FACIL.
*
*   LTFMntBrowse -> LTFModificar
*
*/
STATIC PROCEDURE LTFModificar

local nPos
local nCount
local nPointer
local lContinua   := pTRUE
local lPushButton
local oWindow

memvar xCount, xTemp


	//************************************************************************
	// A rotina so deve ser executada a partir de concurso loto facil
	//************************************************************************
	If CONCURSO->CON_JOGO == pLOTO_FACIL

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_FACIL } ) ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Inicializa o vetor aLotoFacil
				xInitLotoFacil

				// Inicializa as Variaveis de no vetor aLotoFacil
				xStoreLotoFacil

				//
				// Atualiza a variaveis com o registro selecionado
				//
				pLTF_CONCURSO := CONCURSO->CON_CONCUR
				pLTF_SORTEIO  := CONCURSO->CON_SORTEI


				//
				// Atualiza as dezenas do concurso selecionado
				//
				nPos   := 0
				nCount := 1
				If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
					while nPos++ <= Len( AllTrim( JOGOS->JOG_DEZENA ) )
						If IsDigit( SubStr( AllTrim( JOGOS->JOG_DEZENA ), nPos, 1 ) )
							aLotoFacil[ pLTF_POS_DADOS ][ pLTF_POS_DEZENAS ][ nCount++ ] := SubStr( AllTrim( JOGOS->JOG_DEZENA ), nPos++, 2 )
						EndIf
					enddo
				EndIf


				//
				// Atualiza os dados da premiacao da registro selecionado
				//
				If RATEIO->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
					while RATEIO->RAT_JOGO == CONCURSO->CON_JOGO .and.  ;
						RATEIO->RAT_CONCUR == CONCURSO->CON_CONCUR .and. .not. ;
						RATEIO->( Eof() )
						do case
							case RATEIO->RAT_FAIXA == '11'
								pLTF_ACERTO_11 := RATEIO->RAT_ACERTA
								pLTF_PREMIO_11 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '12'
								pLTF_ACERTO_12 := RATEIO->RAT_ACERTA
								pLTF_PREMIO_12 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '13'
								pLTF_ACERTO_13 := RATEIO->RAT_ACERTA
								pLTF_PREMIO_13 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '14'
								pLTF_ACERTO_14 := RATEIO->RAT_ACERTA
								pLTF_PREMIO_14 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '15'
								pLTF_ACERTO_15 := RATEIO->RAT_ACERTA
								pLTF_PREMIO_15 := RATEIO->RAT_RATEIO
						endcase
						RATEIO->( dbSkip() )
					enddo
				EndIf

				// Cria o Objeto Windows
				oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  8
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 21
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  9
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 21
				oWindow:Open()


				while lContinua

					@ oWindow:nTop+ 1, oWindow:nLeft+14 GET     pLTF_CONCURSO                                  ;
														PICT    '@!'                                           ;
														CAPTION 'Concurso'                                     ;
														WHEN    pFALSE                                         ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 1, oWindow:nLeft+30 GET     pLTF_SORTEIO                                   ;
														VALID   .not. Empty( pLTF_SORTEIO )                    ;
														PICT    '@KD 99/99/99'                                 ;
														CAPTION 'Sorteio'                                      ;
														COLOR   SysFieldGet()


					hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 2, oWindow:nLeft+ 2, ' Dezenas ', SystemLabelColor() )

					@ oWindow:nTop+ 3, oWindow:nLeft+12 GET   pLTF_DEZENA_01                                   ;
														VALID .not. Empty( pLTF_DEZENA_01 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+16 GET   pLTF_DEZENA_02                                   ;
														VALID .not. Empty( pLTF_DEZENA_02 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+20 GET   pLTF_DEZENA_03                                   ;
														VALID .not. Empty( pLTF_DEZENA_03 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+24 GET   pLTF_DEZENA_04                                   ;
														VALID .not. Empty( pLTF_DEZENA_04 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+28 GET   pLTF_DEZENA_05                                   ;
														VALID .not. Empty( pLTF_DEZENA_05 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()


					@ oWindow:nTop+ 5, oWindow:nLeft+12 GET   pLTF_DEZENA_06                                   ;
														VALID .not. Empty( pLTF_DEZENA_06 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+16 GET   pLTF_DEZENA_07                                   ;
														VALID .not. Empty( pLTF_DEZENA_07 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+20 GET   pLTF_DEZENA_08                                   ;
														VALID .not. Empty( pLTF_DEZENA_08 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+24 GET   pLTF_DEZENA_09                                   ;
														VALID .not. Empty( pLTF_DEZENA_09 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+28 GET   pLTF_DEZENA_10                                   ;
														VALID .not. Empty( pLTF_DEZENA_10 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()


					@ oWindow:nTop+ 7, oWindow:nLeft+12 GET   pLTF_DEZENA_11                                   ;
														VALID .not. Empty( pLTF_DEZENA_11 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+16 GET   pLTF_DEZENA_12                                   ;
														VALID .not. Empty( pLTF_DEZENA_12 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+20 GET   pLTF_DEZENA_13                                   ;
														VALID .not. Empty( pLTF_DEZENA_13 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+24 GET   pLTF_DEZENA_14                                   ;
														VALID .not. Empty( pLTF_DEZENA_14 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+28 GET   pLTF_DEZENA_15                                   ;
														VALID .not. Empty( pLTF_DEZENA_15 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()


					hb_DispBox( oWindow:nTop+ 8, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 8, oWindow:nRight -1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 8, oWindow:nLeft+ 2, ' Premio ', SystemLabelColor() )

					@ oWindow:nTop+ 9, oWindow:nLeft+12 SAY   'Ganhadores'                                     ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+ 9, oWindow:nLeft+30 SAY   'Premio'                                         ;
														COLOR SystemLabelColor()

					// Coluna de Acertos				
					@ oWindow:nTop+10, oWindow:nLeft+10 GET     pLTF_ACERTO_15                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '15 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '15', pLTF_SORTEIO )

					@ oWindow:nTop+11, oWindow:nLeft+10 GET     pLTF_ACERTO_14                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '14 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTF_SORTEIO )

					@ oWindow:nTop+12, oWindow:nLeft+10 GET     pLTF_ACERTO_13                                 ;                
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '13 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTF_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+10 GET     pLTF_ACERTO_12                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '12 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '12', pLTF_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+10 GET     pLTF_ACERTO_11                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '11 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '11', pLTF_SORTEIO )

					// Coluna de Premios				
					@ oWindow:nTop+10, oWindow:nLeft+24 GET   pLTF_PREMIO_15                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '15', pLTF_SORTEIO )

					@ oWindow:nTop+11, oWindow:nLeft+24 GET   pLTF_PREMIO_14                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTF_SORTEIO )

					@ oWindow:nTop+12, oWindow:nLeft+24 GET   pLTF_PREMIO_13                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTF_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+24 GET   pLTF_PREMIO_12                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '12', pLTF_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+24 GET   pLTF_PREMIO_11                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '11', pLTF_SORTEIO )

					hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
								oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                     ;
															CAPTION ' Con&firma '                              ;
															COLOR   SysPushButton()                            ;
															STYLE   ''                                         ;
															STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

					@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                     ;
															CAPTION ' Cance&lar '                              ;
															COLOR   SysPushButton()                            ;
															STYLE   ''                                         ;
															STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

					Set( _SET_CURSOR, SC_NORMAL )

					READ

					Set( _SET_CURSOR, SC_NONE )

					If lContinua .and. LastKey() != K_ESC

						//************************************************************************
						//*Verifica a duplicidade de dezenas no concurso                         *
						//************************************************************************
						If xDuplicSequencia( aLotoFacil[ pLTF_POS_DADOS ][ pLTF_POS_DEZENAS ] )

							//************************************************************************
							//*Verifica cada item da primeira sequencia para identificar se o valor  *
							//*digitado esta dentro da faixa especifica do concurso                  *
							//************************************************************************
							If xVerificaSequencia( 	aLotoFacil[ pLTF_POS_DADOS ][ pLTF_POS_DEZENAS ], ;
													pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )

								If LTFGravaDados()
									lContinua := pFALSE
								EndIf

							Else
								ErrorTable( '203' )  // Dezena digitada encontra-se fora da faixa.
							EndIf

						Else
							ErrorTable( '201' )  // A sequencia encontra em duplicidade.
						EndIf

					EndIf

				enddo

			always
				// Fecha o Objeto Windows
				oWindow:Close()

				// Restaura a tabela da Pilha
				DstkPop()
			end sequence

		EndIf

	EndIf

return


/***
*
*	LTFExcluir()
*
*	Realiza a exclusao do concurso da LOTO FACIL.
*
*   LTFMntBrowse -> LTFExcluir
*
*/
STATIC PROCEDURE LTFExcluir

	If CONCURSO->CON_JOGO == pLOTO_FACIL

		If Alert( 'Confirma Exclusao do Registro ?', {' Sim ', ' Nao ' } ) == 1

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Marca o Registro de rateio do concurso
				If RATEIO->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
					while RATEIO->RAT_JOGO == CONCURSO->CON_JOGO .and. ;
						RATEIO->RAT_CONCUR == CONCURSO->CON_CONCUR .and. .not. ;
						RATEIO->( Eof() )
						If RATEIO->( NetRLock() )
							RATEIO->( dbDelete() )
							RATEIO->( dbUnlock() )
						EndIf
						RATEIO->( dbSkip() )
					enddo
				EndIf

				// Marca o Registro do jogo do concurso
				If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
					If JOGOS->( NetRLock() )
						JOGOS->( dbDelete() )
						JOGOS->( dbUnlock() )
					EndIf
				EndIf

				// Marca o cabecario do concurso
				If CONCURSO->( NetRLock() )
					CONCURSO->( dbDelete() )
					CONCURSO->( dbUnlock() )
				EndIf

			always
				// Restaura a tabela da Pilha
				DstkPop()
			end sequence

		EndIf

	EndIf

return



/***
*
*	LTFGravaDados()
*
*	Realiza a gravacao dos dados da LOTO FACIL.
*
*/
STATIC FUNCTION LTFGravaDados

local lRetValue := pFALSE


	begin sequence

		while .not. lRetValue			

			If iif( CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + pLTF_CONCURSO ) ), CONCURSO->( NetRLock() ), CONCURSO->( NetAppend() ) )
				CONCURSO->CON_JOGO   := pLOTO_FACIL
				CONCURSO->CON_CONCUR := pLTF_CONCURSO
				CONCURSO->CON_SORTEI := pLTF_SORTEIO
				CONCURSO->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTO_FACIL + pLTF_CONCURSO ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTO_FACIL
				JOGOS->JOG_CONCUR := pLTF_CONCURSO
				JOGOS->JOG_DEZENA := ParseString( aLotoFacil[ pLTF_POS_DADOS ][ pLTF_POS_DEZENAS ] )
				JOGOS->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + pLTF_CONCURSO + '11' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_FACIL
				RATEIO->RAT_CONCUR := pLTF_CONCURSO
				RATEIO->RAT_FAIXA  := '11'
				RATEIO->RAT_ACERTA := pLTF_ACERTO_11
				RATEIO->RAT_RATEIO := pLTF_PREMIO_11
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + pLTF_CONCURSO + '12' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_FACIL
				RATEIO->RAT_CONCUR := pLTF_CONCURSO
				RATEIO->RAT_FAIXA  := '12'
				RATEIO->RAT_ACERTA := pLTF_ACERTO_12
				RATEIO->RAT_RATEIO := pLTF_PREMIO_12
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + pLTF_CONCURSO + '13' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_FACIL
				RATEIO->RAT_CONCUR := pLTF_CONCURSO
				RATEIO->RAT_FAIXA  := '13'
				RATEIO->RAT_ACERTA := pLTF_ACERTO_13
				RATEIO->RAT_RATEIO := pLTF_PREMIO_13
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + pLTF_CONCURSO + '14' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_FACIL
				RATEIO->RAT_CONCUR := pLTF_CONCURSO
				RATEIO->RAT_FAIXA  := '14'
				RATEIO->RAT_ACERTA := pLTF_ACERTO_14
				RATEIO->RAT_RATEIO := pLTF_PREMIO_14
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + pLTF_CONCURSO + '15' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_FACIL
				RATEIO->RAT_CONCUR := pLTF_CONCURSO
				RATEIO->RAT_FAIXA  := '15'
				RATEIO->RAT_ACERTA := pLTF_ACERTO_15
				RATEIO->RAT_RATEIO := pLTF_PREMIO_15
				RATEIO->( dbUnlock() )
			EndIf

			lRetValue := pTRUE

		enddo

	end sequence

return( lRetValue )


/***
*
*	LTFAcoes()
*
*	Exibe o menu de acoes relacionadas.
*
*   LTFMntBrowse -> LTFAcoes
*
*/
STATIC PROCEDURE LTFAcoes

local lPushButton
local oWindow
local lContinua   := pTRUE
local aGroup      := Array(3)
local nTipAcoes   := 1


	begin sequence

		// Cria o Objeto Windows	
		oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  4
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 20
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  4
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 20
		oWindow:Open()

		while lContinua

			aGroup[1]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+ 4, 'E&xportar Resultados' )
			aGroup[1]:ColorSpec := SysFieldBRadioBox()

			aGroup[2]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+ 4, 'Com&binacoes' )
			aGroup[2]:ColorSpec := SysFieldBRadioBox()

			aGroup[3]           := RadioButton( oWindow:nTop+ 4, oWindow:nLeft+ 4, 'Impressao &Relacao Resultados' )
			aGroup[3]:ColorSpec := SysFieldBRadioBox()

			@ oWindow:nTop+ 1, oWindow:nLeft+ 3, ;
				oWindow:nBottom-3, oWindow:nRight-3 GET        nTipAcoes              ;
													RADIOGROUP aGroup                 ;
													CAPTION    ' &Acoes Relacionadas ';
													COLOR      SysFieldGRadioBox()

			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON    ;
													CAPTION ' Con&firma '             ;
													COLOR   SysPushButton()           ;
													STYLE   ''                        ;
													STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

			@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON    ;
													CAPTION ' Cance&lar '             ;
													COLOR   SysPushButton()           ;
													STYLE   ''                        ;
													STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

			Set( _SET_CURSOR, SC_NORMAL )

			READ

			Set( _SET_CURSOR, SC_NONE )

			If lContinua .and. LastKey() != K_ESC

				do case
					case nTipAcoes == 1
						LTFExportar()

					case nTipAcoes == 2
						LTFCombina()

					case nTipAcoes == 3
						LTFRelResult()

				end case

			EndIf

		enddo

	always
		// Fecha o Objeto Windows
		oWindow:Close()
	end sequence

return

/***
*
*	LTFExportar()
*
*	Exporta para arquivo no formato XML.
*
*   LTFMntBrowse -> LTFAcoes -> LTFExportar
*
*/
STATIC PROCEDURE LTFExportar

local lContinua    := pTRUE
local lPushButton
local oWindow

local cArquivo     := PadR( hb_DirBase() + pLOTO_FACIL + DToS( Date() ) + '.xml', 50, '' )
local nCurrent
local nTotConcurso := 0
local bFiltro      := { || CONCURSO->CON_JOGO == pLOTO_FACIL .and. .not. CONCURSO->( Eof() ) }
local oBarProgress

local oXMLDoc
local hNode := { => }


	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		// Totaliza a quantidade de registro cadastrados
		CONCURSO->( dbEval( { || nTotConcurso++ }, bFiltro ) )
		If nTotConcurso >= 1

			// Cria o Objeto Windows
			oWindow        	:= WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  2
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 21
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  2
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 21
			oWindow:Open()

			while lContinua

				@ oWindow:nBottom- 3, oWindow:nLeft+ 10 GET     cArquivo                                       ;
														PICT    '@K!S30'                                       ;
														CAPTION 'Arquivo'                                      ;
														COLOR   SysFieldGet()

				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                         ;
														CAPTION ' Con&firma '                                  ;
														COLOR   SysPushButton()                                ;
														STYLE   ''                                             ;
														WHEN    .not. Empty( cArquivo )                        ;
														STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

				@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                         ;
														CAPTION ' Cance&lar '                                  ;
														COLOR   SysPushButton()                                ;
														STYLE   ''                                             ;
														STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

				Set( _SET_CURSOR, SC_NORMAL )

				READ

				Set( _SET_CURSOR, SC_NONE )

				If lContinua .and. LastKey() != K_ESC

					If .not. File( cArquivo )

						altd()

/*						oXmlDoc := TXmlDocument():New() // Creacion del documento respuesta....
//						oXmlDoc:oRoot:AddBelow( TxmlNode():New( HBXML_TYPE_PI,'xml' , , 'version='1.0' encoding=' ) )
						oXmlDoc:oRoot:AddBelow( TxmlNode():New( ,'xml' , , 'version='1.0' encoding=' ) ) */

						oXmlDoc := mxmlNewXML('1.0')
						hNode[ 1 ] := mxmlNewElement( oXmlDoc, 'TGroup' )
						mxmlElementSetAttr( hNode[ 1 ], 'version', '1.00' )
						mxmlElementSetAttr( hNode[ 1 ], 'xmlns', 'http://www.any.url.com' )
						hNode[ 2 ] := mxmlNewElement( hNode[ 1 ], 'bill' )
						hNode[ 3 ] := mxmlNewElement( hNode[ 2 ], 'TData' )
						hNode[ 4 ] := mxmlNewElement( hNode[ 3 ], 'code' )
						mxmlNewText( hNode[ 4 ], 0, '01' )
						hNode[ 4 ] := mxmlNewElement( hNode[ 3 ], 'data' )
						mxmlNewText( hNode[ 4 ], 0, 'Sample' )
						hNode[ 3 ] := mxmlNewElement( hNode[ 2 ], 'TDate' )
						hNode[ 4 ] := mxmlNewElement( hNode[ 3 ], 'date' )
						mxmlNewText( hNode[ 4 ], 0, STOD( Date( ) ) )
						mxmlSaveFile( oXmlDoc, LOWER( cArquivo ) ) // , @whitespace_cb() )

						lContinua := pFALSE


					EndIf

				EndIf

			enddo

		EndIf

	always

		// Restaura a tabela da Pilha
		DstkPop()

		// Fecha o Objeto Windows
		oWindow:Close()
	end sequence

return


/***
*
*	LTFCombina()
*
*	Exibe as opcoes para gerar combinacoes.
*
*   LTFMntBrowse -> LTFAcoes -> LTFCombina
*
*/
STATIC PROCEDURE LTFCombina

local oWindow
local lPushButton
local lContinua   := pTRUE

local aGroup      := Array(4)
local nOpcao      := 1
local nQuantJog   := 1
local nQuantDez   := pLTF_DEF_MIN_DEZENAS
local nQuantGrp   := 1


	begin sequence

		// Cria o Objeto Windows
		oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  5
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 34
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  6
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 34
		oWindow:cHeader := ' Combinacoes '
		oWindow:Open()

		while lContinua

			aGroup[1]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+ 4, '&Aleatoria' )
			aGroup[1]:ColorSpec := SysFieldBRadioBox()

			aGroup[2]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+ 4, 'M&aior Frequencia' )
			aGroup[2]:ColorSpec := SysFieldBRadioBox()

			aGroup[3]           := RadioButton( oWindow:nTop+ 4, oWindow:nLeft+ 4, 'M&enor Frequencia' )
			aGroup[3]:ColorSpec := SysFieldBRadioBox()

			aGroup[4]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+ 4, 'G&rupos' )
			aGroup[4]:ColorSpec := SysFieldBRadioBox()


			@ oWindow:nTop+ 1, oWindow:nLeft+ 3, ;
				oWindow:nBottom- 5, oWindow:nRight- 3	GET        nOpcao                           ;
														RADIOGROUP aGroup                           ;
														CAPTION    ' &Acoes Relacionadas '          ;
														COLOR      SysFieldGRadioBox()

			hb_DispBox( oWindow:nBottom- 4, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 4, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			@ oWindow:nBottom- 3, oWindow:nLeft+ 15 GET     nQuantJog                               ;
													PICT    '@EN 99999999999999'                    ;
													CAPTION 'Quant.Jogos'                           ;
													COLOR   SysFieldGet()

			@ oWindow:nBottom- 3, oWindow:nLeft+ 45 GET     nQuantDez                               ;
													PICT    '@EN 99'                                ;
													CAPTION 'Quant.Dezenas'                         ;
													COLOR   SysFieldGet()

			@ oWindow:nBottom- 3, oWindow:nLeft+ 62 GET     nQuantGrp                               ;
													PICT    '@EN 999'                               ;
													WHEN    nOpcao == 4                             ;
													CAPTION 'Quant.Grupos'                          ;
													COLOR   SysFieldGet()


			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                  ;
													CAPTION ' Con&firma '                           ;
													COLOR   SysPushButton()                         ;
													STYLE   ''                                      ;
													WHEN    nQuantJog >= 1 .and.                    ;
															nQuantJog <= pLTF_DEF_MAX_COMB .and.    ;
															nQuantDez >= pLTF_DEF_MIN_DEZENAS .and. ;
															nQuantDez <= pLTF_DEF_MAX_DEZENAS .and. ;
															nQuantGrp >= 1                          ;
													STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

			@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                  ;
													CAPTION ' Cance&lar '                           ;
													COLOR   SysPushButton()                         ;
													STYLE   ''                                      ;
													STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

			Set( _SET_CURSOR, SC_NORMAL )

			READ

			Set( _SET_CURSOR, SC_NONE )

			If lContinua .and. LastKey() != K_ESC

				do case
					case nOpcao == 1
						LTFAnaliAleatoria( nQuantJog, nQuantDez )
					
					case nOpcao == 2
						// DSARelResult()

					case nOpcao == 3
						// DSARelResult()

					case nOpcao == 4
						LTFGeraGrupos( nQuantJog, nQuantDez, nQuantGrp )
						
				end case

			EndIf

		enddo

	always
		// Fecha o Objeto Windows
		oWindow:Close()
	end sequence

return


/***
*
*	LTFAnaliAleatoria()
*
*	Realiza a geracao das dezenas para a LOTO FACIL aleatoriamente.
*
*   LTFMntBrowse -> LTFAcoes -> LTFCombina -> LTFAnaliAleatoria
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
* nQuantDezenas : Informa o numero de dezenas a ser geradas por jogos
*
*/
STATIC PROCEDURE LTFAnaliAleatoria( nQuantJogos, nQuantDezenas )

local aFileTmp       := {}
local oError
local lFileTmpCreate := pFALSE

local oBarProgress
local nPointer
local nRandom
local nJogCorrente   := 1
local nDezena
local aSequencia


	DEFAULT nQuantJogos   TO 1, ;
			nQuantDezenas TO pLTF_DEF_MIN_DEZENAS

	If Alert( 'Gerar as combinacoes Aleatorias ?', {' Sim ', ' Nao ' } ) == 1

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			begin sequence with { |oErr| Break( oErr ) }

				AAdd( aFileTmp, { GetNextFile( SystemTmp() ), GetNextFile( SystemTmp() ) } )

				dbCreate( ATail( aFileTmp )[1], { 	{ 'TMP_COD', 'C',  7, 0 },  ;
													{ 'TMP_SEQ', 'C', 44, 0 },  ;
													{ 'TMP_MRK', 'C',  1, 0 } } )

				dbUseArea( pTRUE,, ATail( aFileTmp )[1], 'TMP')
				dbCreateIndex( ATail( aFileTmp )[2], 'TMP_COD', {|| TMP->TMP_COD } )

				lFileTmpCreate := pTRUE

			recover using oError
				If ( oError:genCode == EG_CREATE ) .or. ;
					( oError:genCode == EG_OPEN ) .or. ;
					( oError:genCode == EG_CORRUPTION )
					lFileTmpCreate := pFALSE
				EndIf
			end sequence


			If lFileTmpCreate

				If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_FACIL } ) ) > 0

					begin sequence				

						// Inicializa a Barra de Progresso
						oBarProgress := ProgressBar():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
						oBarProgress:Open()

						while nJogCorrente <= nQuantJogos

							// Atualiza a barra de Progresso
							oBarProgress:Update( ( nJogCorrente / nQuantJogos ) * 100 )

							// Declara a variavel para armazenar as Sequencias geradas
							aSequencia := Array( nQuantDezenas )


							// Define a primeira sequencia
							nDezena := 1
							while nDezena <= nQuantDezenas

								nRandom := hb_RandInt( Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] ) )
								If AScan( aSequencia, { |xSeq| xSeq == pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ] } ) == 0
									aSequencia[ nDezena++ ] := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ]
								EndIf

							enddo

							// Realiza a gravacao no arquivo temporario
							TMP->( NetAppend() )
							TMP->TMP_COD := StrZero( nJogCorrente++, 7 )
							TMP->TMP_SEQ := ParseString( aSequencia )
							TMP->( dbUnlock() )

						enddo

					always
						// Remove a Barra de Progresso
						oBarProgress:Close()
					end sequence


					// Exibe as Apostas Geradas
					If TMP->( LastRec() ) > 0
						LTFShowAposta()
					Else
						ErrorTable( '206' )  // Nao existem informacoes a serem exibidas.
					EndIf

					// Fecha os Arquivos Temporarios
					TMP->( dbCloseArea() )

					// Elimina os arquivos temporarios.
					AEval( aFileTmp, { |xFile| FErase( xFile[1] ), FErase( xFile[2] ) } )

				EndIf

			Else
				ErrorTable( '205' )  // Problemas na criacao do arquivo temporario.
			EndIf

		always
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	EndIf

return


/***
*
*	LTFGeraGrupos()
*
*	Realiza a geracao das dezenas para a LOTO FACIL aleatoriamente.
*
*   LTFMntBrowse -> LTFAcoes -> LTFCombina -> LTFGeraGrupos
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
* nQuantDezenas : Informa o numero de dezenas a ser geradas por jogos
*  nQuantGrupos : Informa o numero de grupos gerados por combinacoes
*
*/
STATIC PROCEDURE LTFGeraGrupos( nQuantJogos, nQuantDezenas, nQuantGrupos )

local nPointer
local lContinua    := pTRUE
local lConfirma
local lCancela
local oWindow

local oBrowse, oColumn
local oTmpButton
local nKey
local nTmp
local nLastKeyType  := hb_MilliSeconds()
local nRefresh      := 1000              /* um segundo como defaul */
local nCount        := 0
local nMenuItem     := 1
local nMaxItens     := 0
local lSair         := pFALSE




local cDisplayFile := ''
local nRow         := 1
	
local aTemp
local oCombine
local a, i
local nPercComb

	DEFAULT nQuantJogos   TO  1, ;
			nQuantDezenas TO 15, ;
			nQuantGrupos  TO  1

	If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_FACIL } ) ) > 0

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Cria o Objeto Windows
			oWindow        	:= WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 12
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 21
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 12
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 21
			oWindow:Open()

			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder )


			// nPercComb := hb_idleAdd( {||  hb_DispOutAt( oWindow:nTop+ 2, oWindow:nLeft+ 1,    ;
			// hb_ValToStr( oCombine:Percent() ) ) } )			

			// Executa a rotina para gerar as combinacoes
			// oCombine           		 := hbCombina():New()
			// oCombine:aSequencia 	 := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ]
			// oCombine:nQuantSequencia := nQuantDezenas
			// oCombine:Execute()

			altd()

			aTemp := {  '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',                  ;
						'11', '12', '13', '14', '15', '16', '17' }

			oCombine           		 := hbCombina():New()
			oCombine:aSequencia 	 := aTemp
			oCombine:nQuantSequencia := nQuantDezenas
			oCombine:Execute()


/*			oCombine           := TLFCombine():New( Nil, aTemp, 3, 2 )
			oCombine:cFileName := GetNextFile( SystemTmp() )
			oCombine:Execute()
*/

			altd()

			begin sequence

				// Exibe a Grade com as Dezenas
				oBrowse            		:= 	TBrowseNew(	oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
														oWindow:nBottom- 3, oWindow:nRight- 1 )
				oBrowse:skipBlock		:= 	{	|x,k| ;
													k := iif( 	Abs(x) >= iif( x >= 0,                                  ;
																		Len( oBrowse:Cargo ) - nRow, nRow - 1),         ;
																iif( x >= 0, Len( oBrowse:Cargo ) - nRow,1 - nRow), x ) ;
																	, nRow += k, k                                      ;
											}
				oBrowse:goTopBlock    	:= { || nRow := 1 }
				oBrowse:goBottomBlock	:= { || nRow := Len( oBrowse:Cargo ) }
				oBrowse:colorSpec     	:= SysBrowseColor()
				oBrowse:autoLite      	:= pFALSE
				oBrowse:Cargo         	:= { { 'TESTE1.TST' }, ;
												{ 'TESTE2.TST' }, ;
												{ 'TESTE3.TST' }  }

				oColumn            := TBColumnNew( '', { || oBrowse:Cargo[ nRow ][1] } )
				oColumn:width      := 10
				oBrowse:addColumn( oColumn )
	
				oTmpButton           := PushButton( oWindow:Bottom- 1, oWindow:Right-11, '    &Ok    ' )
				oTmpButton:sBlock    := { || lSair := pTRUE }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:caption, At('&', oTmpButton:caption )+ 1, 1 ) ) } )

				AEval( oBrowse:Cargo, { |xItem| xItem[1]:Display() } )
				oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

				while .not. lSair

					oBrowse:forceStable()
						
					nKey := Inkey( (nRefresh / 1000), INKEY_ALL )

					If oBrowse:stable .and. nKey > 0

						nLastKeyType := hb_MilliSeconds()
						nRefresh     := 1000					

						do case
							case ( nPointer := AScan( pBRW_INKEYS, { |xKey| xKey[ pBRW_KEY ] == nKey } ) ) > 0
								Eval( pBRW_INKEYS[ nPointer ][ pBRW_ACTION ], oBrowse )

							case ( nPointer := AScan( oBrowse:Cargo, { |xKey| xKey[ pBRW_ACTION ] == Upper( chr( nKey ) ) } ) ) > 0
								If oBrowse:Cargo[ nMenuItem ][1]:HasFocus
									oBrowse:Cargo[ nMenuItem ][1]:KillFocus()
								EndIf
								nMenuItem := nPointer
								oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

							case nKey == K_LEFT .or. nKey == K_LBUTTONDOWN
								If oBrowse:Cargo[ nMenuItem ][1]:HasFocus
									oBrowse:Cargo[ nMenuItem ][1]:KillFocus()
								EndIf
								If --nMenuItem < 1
									nMenuItem := 1
								EndIf
								oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

							case nKey == K_RIGHT .or. nKey == K_RBUTTONUP
								If oBrowse:Cargo[ nMenuItem ][1]:HasFocus
									oBrowse:Cargo[ nMenuItem ][1]:KillFocus()
								EndIf
								If ++nMenuItem > Len( oBrowse:Cargo )
									nMenuItem := Len( oBrowse:Cargo )
								EndIf
								oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

							case nKey == K_MWFORWARD
								If MRow() >= oBrowse:nTop .and. MRow() <= oBrowse:nBottom .and. ;
									Mcol() >= oBrowse:nTop .and. Mcol() <= oBrowse:nRight
									oBrowse:up()
								EndIf

							case nKey == K_MWBACKWARD
								If MRow() >= oBrowse:nTop .and. MRow() <= oBrowse:nBottom .and. ;
									Mcol() >= oBrowse:nTop .and. Mcol() <= oBrowse:nRight
									oBrowse:down()
								EndIf	

							case nKey == K_ENTER
								oBrowse:Cargo[ nMenuItem ][1]:Select()
								oBrowse:refreshAll()

						endcase

					Else
						If ( nTmp := Int( ( ( hb_MilliSeconds() - nLastKeyType ) / 1000 ) / 60 ) ) > 720
							nRefresh := 60000 /* um minuto a cada 12 horas */
						ElseIf nTmp > 60
							nRefresh := 30000
						ElseIf nTmp > 15
							nRefresh := 10000
						ElseIf nTmp > 1
							nRefresh := 3000
						ElseIf nTmp > 0
							nRefresh := 2000
						EndIf
					EndIf

				enddo

			end sequence

		always

			// Elimina o Objeto
//			oCombine:End()

			// Fecha o Objeto Windows
			oWindow:Close()

			// Restaura a tabela da Pilha
			DstkPop()

		end sequence

	EndIf

return

	
/***
*
*	LTFShowAposta()
*
*	Exibe as apostas gerados no arquivo Temporario.
*
*   LTFMntBrowse -> LTFAcoes -> LTFCombina -> LTFAnaliAleatoria -> LTFShowAposta
*
*/
STATIC PROCEDURE LTFShowAposta

local oBrowse, oColumn
local oTmpButton, oScrollBar
local nKey
local nPosRecno   := 0
local nMenuItem   := 1
local nMaxItens   := 0
local lSair       := pFALSE
local oWindow
local bFiltro     := { || .not. TMP->( Eof() ) }

local oSequen1
local oSequen2
local aSelDez1    := {}
local aSelDez2    := {}
local aDezenas
local nRow        := 1
local nPointer
local nPosDezenas
local nLinDezenas
local nColDezenas
local nGrade


	If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pDUPLA_SENA } ) ) > 0

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			nGrade   := Round( Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] ) / 10, 0 )
			aDezenas := Array( nGrade, 10 )

			nPosDezenas := 1
			for nLinDezenas := 1 to nGrade
				for nColDezenas := 1 to 10
					If nPosDezenas <= Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )
						aDezenas[ nLinDezenas ][ nColDezenas ] := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nPosDezenas ]
					Else
						aDezenas[ nLinDezenas ][ nColDezenas ] := '  '
					EndIf
					nPosDezenas++
				next
			next


			// Cria o Objeto Windows
			oWindow        	:= WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 15
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 25
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 15
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 25
			oWindow:cHeader := ' Apostas Geradas '
			oWindow:Open()

			// Desenha a Linha de Botoes
			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )


			dbSelectArea('TMP')
			TMP->( dbEval( {|| nMaxItens++ }, bFiltro ) )
			TMP->( dbGoTop() )

			begin sequence

				// Exibe o Browse com as Apostas
				oBrowse               	:= 	TBrowseDB( oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
														( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 3 ), oWindow:nRight- 1 )
				oBrowse:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFiltro ) ) <> 0, ( nPosRecno += xRecno, xRecno ), xRecno ) }
				oBrowse:goTopBlock    	:= 	{ || nPosRecno := 1, GoTopDB( bFiltro ) }
				oBrowse:goBottomBlock 	:= 	{ || nPosRecno := nMaxItens, GoBottomDB( bFiltro ) }
				oBrowse:colorSpec     	:= SysBrowseColor()
				oBrowse:colSep        	:= Chr(179)
				oBrowse:Cargo         	:= {}

				// Adiciona as Colunas
				oColumn         	:= TBColumnNew( '',  TMP->( FieldBlock( 'TMP_COD' ) ) )
				oColumn:picture 	:= '@!'
				oBrowse:addColumn( oColumn )

				// Realiza a montagem da exibicao da segunda sequencia
				hb_DispBox( ( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 2 ), oWindow:nLeft+ 1, ;
							( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 2 ), oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				oSequen1               	:= 	TBrowseNew( ( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 1 ), oWindow:nLeft+ 1, ;
														( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) - 3 ), oWindow:nRight- 1 )
				oSequen1:skipBlock     	:= 	{ |x,k| ;
												k := iif( Abs(x) >= iif( x >= 0,                          ;
																	Len( aDezenas ) - nRow, nRow - 1),    ;
														iif(x >= 0, Len( aDezenas ) - nRow,1 - nRow), x ) ;
														, nRow += k, k                                    ;
											}
				oSequen1:goTopBlock    	:= 	{ || nRow := 1 }
				oSequen1:goBottomBlock 	:= 	{ || nRow := Len( aDezenas ) }
				oSequen1:colorSpec     	:= SysBrowseColor()
				oSequen1:autoLite      	:= pFALSE

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 1] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 2] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 3] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 4] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 5] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 6] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 7] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 8] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 9] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][10] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez1, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen1:addColumn( oColumn )


				// Realiza a montagem da exibicao da segunda sequencia
				hb_DispBox( ( oWindow:nBottom- 2 ) - ( nGrade + 1 ), oWindow:nLeft+ 1, ;
							( oWindow:nBottom- 2 ) - ( nGrade + 1 ), oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				// Exibe a Segunda Coluna de Dezenas
				oSequen2               	:= 	TBrowseNew( ( oWindow:nBottom- 2 ) - nGrade, oWindow:nLeft+ 1, ;
														( oWindow:nBottom- 2 ) - 1, oWindow:nRight- 1 )
				oSequen2:skipBlock     	:= 	{ |x,k| ;
												k := iif( Abs(x) >= iif( x >= 0,                          ;
																	Len( aDezenas ) - nRow, nRow - 1),    ;
														iif(x >= 0, Len( aDezenas ) - nRow,1 - nRow), x ) ;
														, nRow += k, k                                    ;
											}
				oSequen2:goTopBlock    	:= 	{ || nRow := 1 }
				oSequen2:goBottomBlock 	:= 	{ || nRow := Len( aDezenas ) }
				oSequen2:colorSpec     	:= SysBrowseColor()
				oSequen2:autoLite      	:= pFALSE

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 1] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 2] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 3] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 4] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 5] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 6] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 7] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 8] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 9] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )

				oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][10] } )
				oColumn:colorBlock 	:= { |xDez| iif( hb_AScan( aSelDez2, xDez,,, pTRUE ) > 0, {3,2}, {1,2} ) }
				oColumn:width      	:= 2
				oSequen2:addColumn( oColumn )


				// Realiza a Montagem da Barra de Rolagem
				oScrollBar         		:= ScrollBar( oWindow:nTop+ 1, ( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 3 ), ;
														oWindow:nRight )
				oScrollBar:colorSpec 	:= SysScrollBar()
				oScrollBar:display()


				// Desenha os botoes da tela
				oTmpButton           	:= PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' Gerar &Aposta ' )
				oTmpButton:sBlock    	:= { || Nil }
				oTmpButton:Style     	:= ''
				oTmpButton:ColorSpec 	:= SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           	:= PushButton( oWindow:nBottom- 1, oWindow:nLeft+17, ' &Sair ' )
				oTmpButton:sBlock    	:= { || lSair := pTRUE }
				oTmpButton:Style     	:= ''
				oTmpButton:ColorSpec 	:= SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				AEval( oBrowse:Cargo, { |xItem| xItem[1]:Display() } )
				oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

				while .not. lSair

					// Destaca o registro selecionado no Browse 
					oBrowse:colorRect( { oBrowse:rowPos, 1, oBrowse:rowPos, oBrowse:colCount}, {1,2})
					oBrowse:forceStable()
					oBrowse:colorRect( { oBrowse:rowPos, oBrowse:freeze + 1, oBrowse:rowPos, oBrowse:colCount}, {8,2})
					oBrowse:hilite()

					// Atualiza a barra de rolagem
					oScrollBar:current := nPosRecno * ( 100 / nMaxItens )
					oScrollBar:update()

					// Atualiza a grade com as dezenas da primeira sequencia
					If Len( aSelDez1 := ParseDezenas( TMP->TMP_SEQ1 ) ) > 0
						oSequen1:refreshCurrent()
						oSequen1:forceStable()
					EndIf

					// Atualiza a grade com as dezenas da segunda sequencia
					If Len( aSelDez2 := ParseDezenas( TMP->TMP_SEQ2 ) ) > 0
						oSequen2:refreshCurrent()
						oSequen2:forceStable()
					EndIf

					// Aguarda a acao do usuario
					nKey := Inkey( 1000, INKEY_ALL )

					If oBrowse:stable

						do case
							case ( nPointer := AScan( pBRW_INKEYS, { |xKey| xKey[ pBRW_KEY ] == nKey } ) ) > 0
								Eval( pBRW_INKEYS[ nPointer ][ pBRW_ACTION ], oBrowse )

							case ( nPointer := AScan( oBrowse:Cargo, { |xKey| xKey[ pBRW_KEY ] == Upper( Chr( nKey ) ) } ) ) > 0
								If oBrowse:Cargo[ nMenuItem ][1]:HasFocus
									oBrowse:Cargo[ nMenuItem ][1]:KillFocus()
								EndIf
								nMenuItem := nPointer
								oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

							case nKey == K_LEFT .or. nKey == K_LBUTTONDOWN
								If oBrowse:Cargo[ nMenuItem ][1]:HasFocus
									oBrowse:Cargo[ nMenuItem ][1]:KillFocus()
								EndIf
								If --nMenuItem < 1
									nMenuItem := 1
								EndIf
								oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

							case nKey == K_RIGHT .or. nKey == K_RBUTTONUP
								If oBrowse:Cargo[ nMenuItem ][1]:HasFocus
									oBrowse:Cargo[ nMenuItem ][1]:KillFocus()
								EndIf
								If ++nMenuItem > Len( oBrowse:Cargo )
									nMenuItem := Len( oBrowse:Cargo )
								EndIf
								oBrowse:Cargo[ nMenuItem ][1]:SetFocus()

							case nKey == K_MWFORWARD
								If MRow() >= oBrowse:nTop .and. MRow() <= oBrowse:nBottom .and. ;
									Mcol() >= oBrowse:nTop .and. Mcol() <= oBrowse:nRight
									oBrowse:up()
								EndIf

							case nKey == K_MWBACKWARD
								If MRow() >= oBrowse:nTop .and. MRow() <= oBrowse:nBottom .and. ;
									Mcol() >= oBrowse:nTop .and. Mcol() <= oBrowse:nRight
									oBrowse:down()
								EndIf	

							case nKey == K_ENTER
								oBrowse:Cargo[ nMenuItem ][1]:Select()
								oBrowse:refreshAll()

						endcase

					EndIf

				enddo

			end sequence

		always
			// Fecha o Objeto Windows
			oWindow:Close()

			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	EndIf

return


/***
*
*	LTFRelResult()
*
*	Realiza a impressao dos resultados da LOTO FACIL.
*
*   LTFMntBrowse -> LTFAcoes -> LTFCombina -> LTFRelResult
*
*/
STATIC PROCEDURE LTFRelResult

local lContinua    := pTRUE
local lPushButton
local oWindow

local cInicio
local cFinal
local nCurrent
local nTotConcurso := 0
local bFiltro      := { || CONCURSO->CON_JOGO == pLOTO_FACIL .and. .not. CONCURSO->( Eof() ) }
local oBarProgress
local oPDFReport
local nLinha


	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		// Totaliza a quantidade de registro cadastrados
		CONCURSO->( dbEval( { || nTotConcurso++ }, bFiltro ) )
		If nTotConcurso >= 1

			cInicio	:= StrZero( 1, 5 )
			cFinal  := StrZero( nTotConcurso, 5 )

			// Cria o Objeto Windows
			oWindow        	:= WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  2
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 15
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  2
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 15
			oWindow:cHeader := ' Impressao Resultados '
			oWindow:Open()

			while lContinua

				@ oWindow:nBottom- 3, oWindow:nLeft+ 10 GET     cInicio                                        ;
														PICT    '@K! 99999'                                    ;
														CAPTION 'Inicio'                                       ;
														VALID   .not. Empty( cInicio )                         ;
														SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),5));
														COLOR   SysFieldGet()

				@ oWindow:nBottom- 3, oWindow:nLeft+ 23 GET     cFinal                                         ;
														PICT    '@K! 99999'                                    ;
														CAPTION 'Final'                                        ;
														VALID   .not. Empty( cFinal )                          ;
														SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),5));
														COLOR   SysFieldGet()

				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                         ;
														CAPTION ' Con&firma '                                  ;
														COLOR   SysPushButton()                                ;
														STYLE   ''                                             ;
														STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

				@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                         ;
														CAPTION ' Cance&lar '                                  ;
														COLOR   SysPushButton()                                ;
														STYLE   ''                                             ;
														STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

				Set( _SET_CURSOR, SC_NORMAL )

				READ

				Set( _SET_CURSOR, SC_NONE )

				If lContinua .and. LastKey() != K_ESC

					dbSelectArea('CONCURSO')
					If CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + cInicio ) ) .and. ;
						CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + cFinal ) )

						bFiltro := { || CONCURSO->CON_JOGO == pLOTO_FACIL .and. .not. CONCURSO->( Eof() ) .and. ;
										CONCURSO->CON_CONCUR >= cInicio .and. CONCURSO->CON_CONCUR  <= cFinal }

						// Totaliza a quantidade de registro cadastrados
						nCurrent     := 1
						nTotConcurso := 0
						CONCURSO->( dbEval( { || nTotConcurso++ }, bFiltro ) )

						// Inicializa o Objeto da Barra de Progresso
						oBarProgress:= ProgressBar():New( ,,,, oWindow:cBorder, SystemFormColor() )
						oBarProgress:Open()

						// Cria o relatorio
						oPDFReport           := PDFClass()
						oPDFReport:cFileName := GetNextFile( SystemTmp(), 'pdf' )

						begin sequence

							oPDFReport:Begin()
							oPDFReport:nType       := 2
							oPDFReport:nPageNumber := 1
							oPDFReport:nPdfPage    := 1
							// oPDFReport:cCodePage   := hb_CdpOS()
							oPDFReport:SetInfo( 'EDILSON MENDES', 'ODIN', 'RESULTADOS LOTO FACIL', oPDFReport:cFileName )

							nLinha := oPDFReport:MaxCol()

							//Posiciona o Registro
							If CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_FACIL + cInicio ) )

								while Eval( bFiltro )

									// Atualiza a barra de Progresso
									oBarProgress:Update( ( nCurrent++ / nTotConcurso ) * 100 )

									If nLinha >= ( oPDFReport:MaxCol() - 35 )
										oPDFReport:AddPage()
										oPDFReport:DrawRetangle( 0,  0, 22, 2 )
										oPDFReport:DrawRetangle( 0, 25, 49, 2 )
										oPDFReport:DrawRetangle( 0, 77, 22, 2 )
										oPDFReport:DrawText( 1, 26, PadC( 'RESULTADOS LOTO FACIL', 70 ), , 10, 'Helvetica-Bold' )
										oPDFReport:DrawText( 1, 79, 'Pagina: ' + Str( oPDFReport:nPageNumber ) , , 10, 'Helvetica-Bold' )
										oPDFReport:nPageNumber++
										oPDFReport:nPdfPage++
										oPDFReport:DrawLine( 2, 0, 2, oPDFReport:MaxCol(), 1 )
										oPDFReport:DrawText( 3, 3, 'CONCURSO                 DATA                           DEZENAS', , 10, 'Helvetica-Bold' )
										oPDFReport:DrawLine( 3.5, 0, 3.5, oPDFReport:MaxCol(), 1 )
										nLinha := 4.5
									EndIf

									oPDFReport:DrawText( nLinha,  3, Transform( CONCURSO->CON_CONCUR, '@!' ), , 10, 'Helvetica' )
									oPDFReport:DrawText( nLinha, 22, Transform( CONCURSO->CON_SORTEI, '@D 99/99/99' ), , 10, 'Helvetica' )

									If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )

										while CONCURSO->CON_JOGO == JOGOS->JOG_JOGO .and. ;
											CONCURSO->CON_CONCUR == JOGOS->JOG_CONCUR .and. .not. ;
											JOGOS->( Eof() )

											oPDFReport:DrawText( nLinha++, 41, Transform( StrDezenas( JOGOS->JOG_DEZENA ), '@!' ), , 10, 'Helvetica' )

											JOGOS->( dbSkip() )

										enddo

										nLinha -= .5

									EndIf

									oPDFReport:DrawLine( nLinha, 0, nLinha, oPDFReport:MaxCol(), 1 )
									nLinha++

									CONCURSO->( dbSkip() )

								enddo

							EndIf

						always
							oPDFReport:end()
						end sequence

						// Remove a Barra de Progresso
						oBarProgress:Close()

						// Visualia o arquivo gerado
						oPDFReport:PrintPreview()

						// Remove o arquivo gerado
//						FErase( oPDFReport:cFileName )

						lContinua := pFALSE

					EndIf

				EndIf

			enddo

		Else
			ErrorTable( '207' )  // Nao existem informacoes a serem impressas.
		EndIf

	always
		// Fecha o Objeto Windows
		oWindow:Close()
		// Restaura a tabela da Pilha
		DstkPop()
	end sequence

return


STATIC FUNCTION ArraySplit( arrayIn, nChunksReq )

	local arrayOut
	local nChunkSize
	local nChunkPos
	local item
 
	If nChunksReq > 0
 
	   arrayOut := {}
	   nChunkSize := Max( Round( Len( arrayIn ) / nChunksReq, 0 ), 1 )
	   nChunkPos := 0
 
	   for each item in arrayIn
		  	If nChunkPos == 0
			 	AAdd( arrayOut, {} )
			EndIf
			AAdd( ATail( arrayOut ), item )
			If ++nChunkPos == nChunkSize .and. Len( arrayOut ) < nChunksReq
				 nChunkPos := 0
			EndIf
		next
	Else
	   arrayOut := { arrayIn }
	EndIf
 
return arrayOut
 