/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  loteca.prg
*
***/

#include 'set.ch'
#include 'box.ch'
#include 'inkey.ch'
#include 'error.ch'
#include 'common.ch'
#include 'setcurs.ch'
#include 'getexit.ch'
#include 'hbmemory.ch'
//#include 'apostas.ch'
#include 'loteca.ch'
#include 'dbfunc.ch'
#include 'main.ch'

static aLoteca

memvar GetList

/***
*
*	LTCMntBrowse()
*
*	Exibe a relacao de concursos ja realizados.
*
*/
PROCEDURE LTCMntBrowse()

local oBrwConcurso
local oBrwPartidas
local oColumn
local oTmpButton, oScrollBar
local nKey
local nTmp
local nLastKeyType  := hb_MilliSeconds()
local nRefresh      := 1000              /* um segundo como defaul */
local nCount        := 0
local nMenuItem     := 1
local nMaxItens     := 1
local lSair         := pFALSE
local oWindow
local bFiltro

local bFilConcurso  := { || CONCURSO->CON_JOGO == pLOTECA .and. .not. ;
							CONCURSO->( Eof() ) }
local bFilPartidas  := { ||	JOGOS->JOG_JOGO == CONCURSO->CON_JOGO .and. ;
							JOGOS->JOG_CONCUR == CONCURSO->CON_CONCUR .and. .not.  ;
							JOGOS->( Eof() ) }

local oBrwDezenas
local aSelDezenas   := {}
local aDezenas
local nRow          := 1
local nPointer
local nPosDezenas   := 1
local nLinDezenas
local nColDezenas
local nGrade


	If SystemConcurso() == pLOTECA

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTECA } ) ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Cria o Objeto Windows
				oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 15
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 26
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 15
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 26
				oWindow:cHeader := PadC( SystemNameConcurso(), Len( SystemNameConcurso() ) + 2, ' ')
				oWindow:Open()

				// Desenha a Linha de Botoes
				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				// Posiciona o registro no consurso selecionado
				dbSelectArea('CONCURSO')
				CONCURSO->( dbEval( {|| nMaxItens++ }, bFilConcurso ) )
				CONCURSO->( dbSetOrder(2), dbSeek( pLOTECA ) )

				begin sequence

					// Exibe o Browse com as Apostas
					oBrwConcurso               	:= 	TBrowseDB( 	oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
																oWindow:nBottom-20, oWindow:nRight- 1 )
					oBrwConcurso:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFilConcurso ) ) <> 0, ;
																			( nCount += xRecno, xRecno ), xRecno ) }
					oBrwConcurso:goTopBlock    	:= 	{ || nCount := 1, GoTopDB( bFilConcurso ) }
					oBrwConcurso:goBottomBlock 	:= 	{ || nCount := nMaxItens, GoBottomDB( bFilConcurso ) }
					oBrwConcurso:colorSpec     	:= SysBrowseColor()
					oBrwConcurso:headSep       	:= Chr(205)
					oBrwConcurso:colSep        	:= Chr(179)
					oBrwConcurso:Cargo         	:= {}

					// Adiciona as Colunas
					oColumn 			:= TBColumnNew( PadC( 'Concurso', 10 ), CONCURSO->( FieldBlock( 'CON_CONCUR' ) ) )
					oColumn:picture 	:= '@!'
					oColumn:width   	:= 10
					oBrwConcurso:addColumn( oColumn )

					oColumn 			:= TBColumnNew( PadC( 'Sorteio', 10 ), CONCURSO->( FieldBlock( 'CON_SORTEI' ) ) )
					oColumn:picture 	:= '@D 99/99/99'
					oColumn:width   	:= 10
					oBrwConcurso:addColumn( oColumn )

					hb_DispBox( oWindow:nBottom-19, oWindow:nLeft+ 1, ;
								oWindow:nBottom-19, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )                                


					// Cria o Browse com as partidas
					oBrwPartidas               	:= 	TBrowseNew(	oWindow:nBottom-18, oWindow:nLeft+ 1, ;
                                                                oWindow:nBottom- 3, oWindow:nRight- 1 )
					oBrwPartidas:skipBlock     	:=	{ |xSkip| JOGOS->( DBSkipper( xSkip, bFilPartidas ) ) }
					oBrwPartidas:goTopBlock    	:= 	{ || JOGOS->( GoTopDB( bFilPartidas ) ) }
					oBrwPartidas:goBottomBlock 	:= 	{ || JOGOS->( GoBottomDB( bFilPartidas ) ) }
					oBrwPartidas:colorSpec     	:= 	SysBrowseColor()
					oBrwPartidas:headSep        := 	Chr(205)
					oBrwPartidas:colSep         := 	Chr(179)
					oBrwPartidas:autoLite      	:= 	pFALSE

					oColumn         := TBColumnNew( "",                      { || JOGOS->JOG_FAIXA } )
					oColumn:picture := "@!"
					oColumn:width   := 02
					oBrwPartidas:addColumn( oColumn )

					oColumn            := TBColumnNew( PADC( "Coluna 1", 20 ),  {|| PadL( iif( CLUBES->( dbSetOrder(1), dbSeek( JOGOS->JOG_COL_01 ) ),       ;
																							AllTrim( CLUBES->CLU_ABREVI ) + "/" + AllTrim( CLUBES->CLU_UF ), ;
																							"" ), 20 ) } )
					oColumn:picture    := "@!"
					oColumn:width      := 20
					oBrwPartidas:addColumn( oColumn )

					oColumn            := TBColumnNew( "1",                     {|| iif( JOGOS->JOG_PON_01 > JOGOS->JOG_PON_02, "X", " " ) } )
					oColumn:picture    := "@!"
					oColumn:width      := 1
					oBrwPartidas:addColumn( oColumn )

					oColumn            := TBColumnNew( "X",                     {|| iif( JOGOS->JOG_PON_01 == JOGOS->JOG_PON_02, "X", "" ) } )
					oColumn:picture    := "@!"
					oColumn:width      := 1
					oBrwPartidas:addColumn( oColumn )

					oColumn            := TBColumnNew( "2",                     {|| iif( JOGOS->JOG_PON_01 < JOGOS->JOG_PON_02, "X", "" ) } )
					oColumn:picture    := "@!"
					oColumn:width      := 1
					oBrwPartidas:addColumn( oColumn )

					oColumn            := TBColumnNew( PADC( "Coluna 2", 20 ),  {|| PadR( iif( CLUBES->( dbSetOrder(1), dbSeek( JOGOS->JOG_COL_02 ) ),        ;
																							AllTrim( CLUBES->CLU_ABREVI ) + "/" + AllTrim( CLUBES->CLU_UF ), ;
																							"" ), 20 ) } )
					oColumn:picture    := "@!"
					oColumn:width      := 20
					oBrwPartidas:addColumn( oColumn )


					// Realiza a Montagem da Barra de Rolagem
					oScrollBar           	:= ScrollBar( oWindow:nTop+ 3, oWindow:nBottom-20, oWindow:nRight )
					oScrollBar:colorSpec 	:= SysScrollBar()
					oScrollBar:display()


					// Desenha os botoes da tela
					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
					oTmpButton:sBlock    := { || LTCIncluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwConcurso:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
					oTmpButton:sBlock    := { || LTCModificar() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwConcurso:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' &Excluir ' )
					oTmpButton:sBlock    := { || LTCExcluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwConcurso:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Ac&oes ' )
					oTmpButton:sBlock    := { || LTCAcoes() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AADD( oBrwConcurso:Cargo, { oTmpButton, UPPER( SUBSTR( oTmpButton:Caption, AT('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+42, ' &Sair ' )
					oTmpButton:sBlock    := { || lSair := pTRUE }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwConcurso:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					AEval( oBrwConcurso:Cargo, { |xItem| xItem[1]:Display() } )
					oBrwConcurso:Cargo[ nMenuItem ][1]:SetFocus()

					while .not. lSair

                        // Destaca o registro selecionado no Browse 
                        oBrwConcurso:colorRect( { oBrwConcurso:rowPos, 1, oBrwConcurso:rowPos, oBrwConcurso:colCount}, {1,2})
						oBrwConcurso:forceStable()
						oBrwConcurso:colorRect( { oBrwConcurso:rowPos, oBrwConcurso:freeze + 1, oBrwConcurso:rowPos, oBrwConcurso:colCount}, {8,2})
						oBrwConcurso:hilite()

                        // Atualiza a barra de rolagem
						oScrollBar:current := nCount * ( 100 / nMaxItens )
                        oScrollBar:update()

                        // Atualiza a grade com as dezenas dos jogos
                        If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
							oBrwPartidas:refreshAll()
							oBrwPartidas:forceStable()
                        EndIf    

                        // Aguarda a acao do usuario
                        nKey := Inkey( (nRefresh / 1000), INKEY_ALL )

						If oBrwConcurso:stable .and. nKey > 0

							nLastKeyType := hb_MilliSeconds()
							nRefresh     := 1000					

							do case
								case ( nPointer := AScan( pBRW_INKEYS, { |xKey| xKey[ pBRW_KEY ] == nKey } ) ) > 0
                                    Eval( pBRW_INKEYS[ nPointer ][ pBRW_ACTION ], oBrwConcurso )

								case ( nPointer := AScan( oBrwConcurso:Cargo, { |xKey| xKey[ pBRW_ACTION ] == Upper( chr( nKey ) ) } ) ) > 0
									If oBrwConcurso:Cargo[ nMenuItem ][1]:HasFocus
										oBrwConcurso:Cargo[ nMenuItem ][1]:KillFocus()
									EndIf
									nMenuItem := nPointer
									oBrwConcurso:Cargo[ nMenuItem ][1]:SetFocus()

								case nKey == K_LEFT .or. nKey == K_LBUTTONDOWN
									If oBrwConcurso:Cargo[ nMenuItem ][1]:HasFocus
										oBrwConcurso:Cargo[ nMenuItem ][1]:KillFocus()
									EndIf
									If --nMenuItem < 1
										nMenuItem := 1
									EndIf
									oBrwConcurso:Cargo[ nMenuItem ][1]:SetFocus()

								case nKey == K_RIGHT .or. nKey == K_RBUTTONUP
									If oBrwConcurso:Cargo[ nMenuItem ][1]:HasFocus
										oBrwConcurso:Cargo[ nMenuItem ][1]:KillFocus()
									EndIf
									If ++nMenuItem > Len( oBrwConcurso:Cargo )
										nMenuItem := Len( oBrwConcurso:Cargo )
									EndIf
									oBrwConcurso:Cargo[ nMenuItem ][1]:SetFocus()

								case nKey == K_MWFORWARD
									If MRow() >= oBrwConcurso:nTop .and. MRow() <= oBrwConcurso:nBottom .and. ;
										Mcol() >= oBrwConcurso:nTop .and. Mcol() <= oBrwConcurso:nRight
										oBrwConcurso:up()
									EndIf

								case nKey == K_MWBACKWARD
									If MRow() >= oBrwConcurso:nTop .and. MRow() <= oBrwConcurso:nBottom .and. ;
										Mcol() >= oBrwConcurso:nTop .and. Mcol() <= oBrwConcurso:nRight
										oBrwConcurso:down()
									EndIf	

								case nKey == K_ENTER
									oBrwConcurso:Cargo[ nMenuItem ][1]:Select()
									oBrwConcurso:refreshAll()

                            endcase

						else
							nTmp := Int( ( ( hb_MilliSeconds() - nLastKeyType ) / 1000 ) / 60 )
							if nTmp > 720
								nRefresh := 60000 /* um minuto a cada 12 horas */
							elseif nTmp > 60
								nRefresh := 30000
							elseif nTmp > 15
								nRefresh := 10000
							elseif nTmp > 1
								nRefresh := 3000
							elseif nTmp > 0
								nRefresh := 2000
							endif
						endif

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
*	LTCIncluir()
*
*	Realiza a inclusao dos dados para o concurso da LOTECA.
*
*   LTCMntBrowse -> LTCIncluir
*
*/
STATIC PROCEDURE LTCIncluir

local aClubes
local nPointer
local lContinua     := pTRUE
local lPushButton
local oWindow
local nCodigo       := 1
local cAutoSequence
local oIniFile

memvar xCount, xTemp


	If SystemConcurso() == pLOTECA

		If Len( aClubes := LoadClubes() ) > 0	

			If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTECA } ) ) > 0

				begin sequence

					// Salva a Area corrente na Pilha
					DstkPush()

					// Inicializa as Variaveis de Dados
					xInitLoteca

					// Inicializa as Variaveis de no vetor aLoteca
					xStoreLoteca

					//
					// Realiza a abertura do arquivo INI
					//
					oIniFile := TIniFile():New( 'odin.ini' )

					//
					// Parametro para definir a sequencia automatica
					//
					If ( cAutoSequence := oIniFile:ReadString( 'LOTECA', 'AUTO_SEQUENCE', '0' ) ) == '1'
						// Define o codigo sequencial
						dbEval( { || nCodigo++ }, { || CONCURSO->CON_JOGO == pLOTECA .and. CONCURSO->( .not. Eof() ) } )
						pLTC_CONCURSO := StrZero( nCodigo, 5 )
					EndIf

					// Realiza a leitura dos dados do arquivo de configuracao
					pLTC_PARTIDA_01_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_01_CLUBE_1', Space(5) )
					pLTC_PARTIDA_01_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_01_CLUBE_2', Space(5) )
					pLTC_PARTIDA_02_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_02_CLUBE_1', Space(5) )
					pLTC_PARTIDA_02_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_02_CLUBE_2', Space(5) )
					pLTC_PARTIDA_03_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_03_CLUBE_1', Space(5) )
					pLTC_PARTIDA_03_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_03_CLUBE_2', Space(5) )
					pLTC_PARTIDA_04_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_04_CLUBE_1', Space(5) )
					pLTC_PARTIDA_04_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_04_CLUBE_2', Space(5) )
					pLTC_PARTIDA_05_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_05_CLUBE_1', Space(5) )
					pLTC_PARTIDA_05_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_05_CLUBE_2', Space(5) )
					pLTC_PARTIDA_06_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_06_CLUBE_1', Space(5) )
					pLTC_PARTIDA_06_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_06_CLUBE_2', Space(5) )
					pLTC_PARTIDA_07_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_07_CLUBE_1', Space(5) )
					pLTC_PARTIDA_07_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_07_CLUBE_2', Space(5) )
					pLTC_PARTIDA_08_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_08_CLUBE_1', Space(5) )
					pLTC_PARTIDA_08_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_08_CLUBE_2', Space(5) )
					pLTC_PARTIDA_09_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_09_CLUBE_1', Space(5) )
					pLTC_PARTIDA_09_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_09_CLUBE_2', Space(5) )
					pLTC_PARTIDA_10_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_10_CLUBE_1', Space(5) )
					pLTC_PARTIDA_10_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_10_CLUBE_2', Space(5) )
					pLTC_PARTIDA_11_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_11_CLUBE_1', Space(5) )
					pLTC_PARTIDA_11_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_11_CLUBE_2', Space(5) )
					pLTC_PARTIDA_12_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_12_CLUBE_1', Space(5) )
					pLTC_PARTIDA_12_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_12_CLUBE_2', Space(5) )
					pLTC_PARTIDA_13_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_13_CLUBE_1', Space(5) )
					pLTC_PARTIDA_13_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_13_CLUBE_2', Space(5) )
					pLTC_PARTIDA_14_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_14_CLUBE_1', Space(5) )
					pLTC_PARTIDA_14_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_14_CLUBE_2', Space(5) )


					// Cria o Objeto Windows
					oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
					oWindow:nTop    := INT( SystemMaxRow() / 2 ) - 12
					oWindow:nLeft   := INT( SystemMaxCol() / 2 ) - 28
					oWindow:nBottom := INT( SystemMaxRow() / 2 ) + 11
					oWindow:nRight  := INT( SystemMaxCol() / 2 ) + 28
					oWindow:Open()

					while lContinua

						@ oWindow:nTop+ 1, oWindow:nLeft+14 GET     pLTC_CONCURSO                                  ;
															PICT    '@K 99999'                                     ;
															SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),5));
															CAPTION 'Concurso'                                     ;
															COLOR   SysFieldGet()

						@ oWindow:nTop+ 1, oWindow:nLeft+30 GET     pLTC_SORTEIO                                   ;
															PICT    '@KD 99/99/99'                                 ;
															CAPTION 'Sorteio'                                      ;
															COLOR   SysFieldGet()

						hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
									oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

						@ oWindow:nTop+ 3, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 3, oWindow:nLeft+26	GET		pLTC_PARTIDA_01_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 1-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 3, oWindow:nLeft+28 GET		pLTC_PARTIDA_01_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 3, oWindow:nLeft+31, ;
							oWindow:nTop+ 3, oWindow:nLeft+51	GET		pLTC_PARTIDA_01_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 3, oWindow:nLeft+53 GET		pLTC_PARTIDA_01_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 4, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 4, oWindow:nLeft+26	GET		pLTC_PARTIDA_02_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 2-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 4, oWindow:nLeft+28 GET		pLTC_PARTIDA_02_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 4, oWindow:nLeft+31, ;
							oWindow:nTop+ 4, oWindow:nLeft+51	GET		pLTC_PARTIDA_02_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 4, oWindow:nLeft+53 GET		pLTC_PARTIDA_02_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 5, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 5, oWindow:nLeft+26	GET		pLTC_PARTIDA_03_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 3-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 5, oWindow:nLeft+28	GET		pLTC_PARTIDA_03_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 5, oWindow:nLeft+31, ;
							oWindow:nTop+ 5, oWindow:nLeft+51	GET		pLTC_PARTIDA_03_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 5, oWindow:nLeft+53 GET		pLTC_PARTIDA_03_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 6, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 6, oWindow:nLeft+26	GET		pLTC_PARTIDA_04_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 4-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 6, oWindow:nLeft+28	GET		pLTC_PARTIDA_04_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 6, oWindow:nLeft+31, ;
							oWindow:nTop+ 6, oWindow:nLeft+51	GET		pLTC_PARTIDA_04_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 6, oWindow:nLeft+53 GET		pLTC_PARTIDA_04_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 7, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 7, oWindow:nLeft+26	GET		pLTC_PARTIDA_05_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 5-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 7, oWindow:nLeft+28	GET		pLTC_PARTIDA_05_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 7, oWindow:nLeft+31, ;
							oWindow:nTop+ 7, oWindow:nLeft+51	GET		pLTC_PARTIDA_05_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 7, oWindow:nLeft+53	GET		pLTC_PARTIDA_05_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 8, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 8, oWindow:nLeft+26	GET		pLTC_PARTIDA_06_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 6-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 8, oWindow:nLeft+28 GET		pLTC_PARTIDA_06_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 8, oWindow:nLeft+31, ;
							oWindow:nTop+ 8, oWindow:nLeft+51	GET		pLTC_PARTIDA_06_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 8, oWindow:nLeft+53 GET		pLTC_PARTIDA_06_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 9, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 9, oWindow:nLeft+26	GET		pLTC_PARTIDA_07_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 7-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 9, oWindow:nLeft+28	GET		pLTC_PARTIDA_07_RESULTADO_1                    ;
															PICT 	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 9, oWindow:nLeft+31, ;
							oWindow:nTop+ 9, oWindow:nLeft+51	GET		pLTC_PARTIDA_07_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 9, oWindow:nLeft+53 GET		pLTC_PARTIDA_07_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+10, oWindow:nLeft+ 6, ;
							oWindow:nTop+10, oWindow:nLeft+26 	GET		pLTC_PARTIDA_08_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 8-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+10, oWindow:nLeft+28 GET		pLTC_PARTIDA_08_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+10, oWindow:nLeft+31, ;
							oWindow:nTop+10, oWindow:nLeft+51	GET	pLTC_PARTIDA_08_CLUBE_2                        ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+10, oWindow:nLeft+53 GET		pLTC_PARTIDA_08_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+11, oWindow:nLeft+ 6, ;
							oWindow:nTop+11, oWindow:nLeft+26	GET		pLTC_PARTIDA_09_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 9-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+11, oWindow:nLeft+28 GET		pLTC_PARTIDA_09_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+11, oWindow:nLeft+31, ;
							oWindow:nTop+11, oWindow:nLeft+51	GET		pLTC_PARTIDA_09_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+11, oWindow:nLeft+53	GET		pLTC_PARTIDA_09_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+12, oWindow:nLeft+ 6, ;
							oWindow:nTop+12, oWindow:nLeft+26	GET		pLTC_PARTIDA_10_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '10-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+12, oWindow:nLeft+28 GET		pLTC_PARTIDA_10_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+12, oWindow:nLeft+31, ;
							oWindow:nTop+12, oWindow:nLeft+51	GET		pLTC_PARTIDA_10_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+12, oWindow:nLeft+53 GET		pLTC_PARTIDA_10_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+13, oWindow:nLeft+ 6, ;
							oWindow:nTop+13, oWindow:nLeft+26	GET		pLTC_PARTIDA_11_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '11-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+13, oWindow:nLeft+28 GET		pLTC_PARTIDA_11_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+13, oWindow:nLeft+31, ;
							oWindow:nTop+13, oWindow:nLeft+51 	GET		pLTC_PARTIDA_11_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+13, oWindow:nLeft+53 GET		pLTC_PARTIDA_11_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+14, oWindow:nLeft+ 6, ;
							oWindow:nTop+14, oWindow:nLeft+26 	GET		pLTC_PARTIDA_12_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '12-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+14, oWindow:nLeft+28 GET		pLTC_PARTIDA_12_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+14, oWindow:nLeft+31, ;
							oWindow:nTop+14, oWindow:nLeft+51 	GET		pLTC_PARTIDA_12_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+14, oWindow:nLeft+53 GET		pLTC_PARTIDA_12_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+15, oWindow:nLeft+ 6, ;
							oWindow:nTop+15, oWindow:nLeft+26	GET		pLTC_PARTIDA_13_CLUBE_1                    ;
																LISTBOX aClubes                                	   ;
																CAPTION '13-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+15, oWindow:nLeft+28 GET		pLTC_PARTIDA_13_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+15, oWindow:nLeft+31, ;
							oWindow:nTop+15, oWindow:nLeft+51	GET		pLTC_PARTIDA_13_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+15, oWindow:nLeft+53 GET		pLTC_PARTIDA_13_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+16, oWindow:nLeft+ 6, ;
							oWindow:nTop+16, oWindow:nLeft+26	GET		pLTC_PARTIDA_14_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '14-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+16, oWindow:nLeft+28 GET		pLTC_PARTIDA_14_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+16, oWindow:nLeft+31, ;
							oWindow:nTop+16, oWindow:nLeft+51	GET		pLTC_PARTIDA_14_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()

						@ oWindow:nTop+16, oWindow:nLeft+53 GET		pLTC_PARTIDA_14_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()


						hb_DispBox( oWindow:nTop+17, oWindow:nLeft+ 1, ;
									oWindow:nTop+17, oWindow:nRight -1, oWindow:cBorder, SystemFormColor() )
						hb_DispOutAt( oWindow:nTop+ 8, oWindow:nLeft+ 2, ' Premio ', SystemLabelColor() )

						@ oWindow:nTop+18, oWindow:nLeft+12 SAY   'Ganhadores'                                     ;
															COLOR SystemLabelColor()

						@ oWindow:nTop+18, oWindow:nLeft+30 SAY   'Premio'                                         ;
															COLOR SystemLabelColor()


						// Coluna de Acertos			
						@ oWindow:nTop+18, oWindow:nLeft+14 GET     pLTC_RATEIO_ACERTO_14                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '14 Acertos'                                   ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTC_SORTEIO )

						@ oWindow:nTop+19, oWindow:nLeft+14 GET     pLTC_RATEIO_ACERTO_13                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '13 Acertos'                                   ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTC_SORTEIO )

						@ oWindow:nTop+20, oWindow:nLeft+14 GET     pLTC_RATEIO_ACERTO_12                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '12 Acertos'                                   ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '12', pLTC_SORTEIO )


						// Coluna de Premios			
						@ oWindow:nTop+18, oWindow:nLeft+35 GET   pLTC_RATEIO_PREMIO_14                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTC_SORTEIO )

						@ oWindow:nTop+19, oWindow:nLeft+35 GET   pLTC_RATEIO_PREMIO_13                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTC_SORTEIO )

						@ oWindow:nTop+20, oWindow:nLeft+35 GET   pLTC_RATEIO_PREMIO_12                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '12', pLTC_SORTEIO )


						hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
									oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

						@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                     ;
																CAPTION ' Con&firma '                              ;
																COLOR   SysPushButton()                            ;
																STYLE   ''                                         ;
																WHEN    Val( pLTC_CONCURSO ) > 0 .and.             ;
																		.not. Empty( pLTC_SORTEIO ) .and.          ;
																		.not. Empty( pLTC_PARTIDA_01_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_01_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_02_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_02_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_03_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_03_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_04_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_04_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_05_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_05_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_06_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_06_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_07_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_07_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_08_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_08_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_09_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_09_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_10_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_10_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_11_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_11_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_12_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_12_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_13_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_13_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_14_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_14_CLUBE_2 )       ;
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

							pLTC_CONCURSO := StrZero( Val( pLTC_CONCURSO ), 5 )

							//************************************************************************
							//*Verifica se concurso ja existe                                        *
							//************************************************************************
							If .not. CONCURSO->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO ) )

								If LTCGravaDados()
									lContinua := pFALSE
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
					oIniFile:WriteString( 'LOTECA', 'AUTO_SEQUENCE', cAutoSequence )

					// Atualiza as variaveis do arquivo de confiruacao
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_01_CLUBE_1', pLTC_PARTIDA_01_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_01_CLUBE_2', pLTC_PARTIDA_01_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_02_CLUBE_1', pLTC_PARTIDA_02_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_02_CLUBE_2', pLTC_PARTIDA_02_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_03_CLUBE_1', pLTC_PARTIDA_03_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_03_CLUBE_2', pLTC_PARTIDA_03_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_04_CLUBE_1', pLTC_PARTIDA_04_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_04_CLUBE_2', pLTC_PARTIDA_04_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_05_CLUBE_1', pLTC_PARTIDA_05_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_05_CLUBE_2', pLTC_PARTIDA_05_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_06_CLUBE_1', pLTC_PARTIDA_06_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_06_CLUBE_2', pLTC_PARTIDA_06_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_07_CLUBE_1', pLTC_PARTIDA_07_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_07_CLUBE_2', pLTC_PARTIDA_07_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_08_CLUBE_1', pLTC_PARTIDA_08_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_08_CLUBE_2', pLTC_PARTIDA_08_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_09_CLUBE_1', pLTC_PARTIDA_09_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_09_CLUBE_2', pLTC_PARTIDA_09_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_10_CLUBE_1', pLTC_PARTIDA_10_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_10_CLUBE_2', pLTC_PARTIDA_10_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_11_CLUBE_1', pLTC_PARTIDA_11_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_11_CLUBE_2', pLTC_PARTIDA_11_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_12_CLUBE_1', pLTC_PARTIDA_12_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_12_CLUBE_2', pLTC_PARTIDA_12_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_13_CLUBE_1', pLTC_PARTIDA_13_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_13_CLUBE_2', pLTC_PARTIDA_13_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_14_CLUBE_1', pLTC_PARTIDA_14_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_14_CLUBE_2', pLTC_PARTIDA_14_CLUBE_2 )

					// Atualiza o arquivo de Configuracao
					oIniFile:UpdateFile()

					// Restaura a tabela da Pilha
					DstkPop()
				end sequence

			EndIf

		Else
			ErrorTable( '002' )  // "Nao existem clubes cadastrados."
		EndIf

	EndIf

return


/***
*
*	LTCModificar()
*
*	Realiza a manutencao dos dados para o concurso da LOTECA.
*
*   LTCMntBrowse -> LTCModificar
*
*/
STATIC PROCEDURE LTCModificar

local aClubes
local nPointer
local lContinua   := pTRUE
local lPushButton
local oWindow

memvar xCount, xTemp


	//************************************************************************
	// A rotina so deve ser executada a partir de concurso loteca
	//************************************************************************
	If CONCURSO->CON_JOGO == pLOTECA

		If Len( aClubes := LoadClubes() ) > 0			

			If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTECA } ) ) > 0

				begin sequence

					// Salva a Area corrente na Pilha
					DstkPush()

					// Inicializa o vetor aLoteca
					xInitLoteca

					// Inicializa as Variaveis de no vetor aLoteca
					xStoreLoteca

					//
					// Atualiza a variaveis com o registro selecionado
					//
					pLTC_CONCURSO := CONCURSO->CON_CONCUR
					pLTC_SORTEIO  := CONCURSO->CON_SORTEI


					//************************************************************************
					//*Carrega o Concurso Selecionado                                        *
					//************************************************************************
					If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
						WHILE JOGOS->JOG_JOGO == CONCURSO->CON_JOGO .and. ;
							JOGOS->JOG_CONCUR == CONCURSO->CON_CONCUR .and. .not. ;
							JOGOS->( Eof() )
							do case
								case JOGOS->JOG_FAIXA == "01"
									pLTC_PARTIDA_01_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_01_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_01_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_01_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "02"
									pLTC_PARTIDA_02_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_02_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_02_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_02_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "03"
									pLTC_PARTIDA_03_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_03_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_03_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_03_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "04"
									pLTC_PARTIDA_04_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_04_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_04_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_04_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "05"
									pLTC_PARTIDA_05_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_05_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_05_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_05_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "06"
									pLTC_PARTIDA_06_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_06_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_06_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_06_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "07"
									pLTC_PARTIDA_07_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_07_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_07_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_07_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "08"
									pLTC_PARTIDA_08_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_08_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_08_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_08_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "09"
									pLTC_PARTIDA_09_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_09_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_09_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_09_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "10"
									pLTC_PARTIDA_10_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_10_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_10_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_10_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "11"
									pLTC_PARTIDA_11_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_11_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_11_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_11_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "12"
									pLTC_PARTIDA_12_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_12_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_12_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_12_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "13"
									pLTC_PARTIDA_13_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_13_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_13_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_13_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == "14"
									pLTC_PARTIDA_14_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_14_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_14_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_14_RESULTADO_2 := JOGOS->JOG_PON_02
							endcase
							JOGOS->( dbSkip() )
						enddo
					EndIf


					//************************************************************************
					//*Carrega a Premicao do Concurso Selecionado                            *
					//************************************************************************
					If RATEIO->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
						while  RATEIO->RAT_JOGO == CONCURSO->CON_JOGO .and. ;
							RATEIO->RAT_CONCUR == CONCURSO->CON_CONCUR .and. .not. ;
							RATEIO->( Eof() )
							do case
								case RATEIO->RAT_FAIXA == "12"
									pLTC_RATEIO_ACERTO_12 := RATEIO->RAT_ACERTA
									pLTC_RATEIO_PREMIO_12 := RATEIO->RAT_RATEIO
								case RATEIO->RAT_FAIXA == "13"
									pLTC_RATEIO_ACERTO_13 := RATEIO->RAT_ACERTA
									pLTC_RATEIO_PREMIO_13 := RATEIO->RAT_RATEIO
								case RATEIO->RAT_FAIXA == "14"
									pLTC_RATEIO_ACERTO_14 := RATEIO->RAT_ACERTA
									pLTC_RATEIO_PREMIO_14 := RATEIO->RAT_RATEIO
							endcase
							RATEIO->( dbSkip() )
						enddo
					EndIf


					// Cria o Objeto Windows
					oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
					oWindow:nTop    := INT( SystemMaxRow() / 2 ) -  8
					oWindow:nLeft   := INT( SystemMaxCol() / 2 ) - 21
					oWindow:nBottom := INT( SystemMaxRow() / 2 ) +  9
					oWindow:nRight  := INT( SystemMaxCol() / 2 ) + 21
					oWindow:Open()

					WHILE lContinua

						@ oWindow:nTop+ 1, oWindow:nLeft+14 GET     pLTC_CONCURSO                                  ;
															PICT    '@!'                                           ;
															CAPTION 'Concurso'                                     ;
															WHEN    pFALSE                                         ;
															COLOR   SysFieldGet()
						
						@ oWindow:nTop+ 1, oWindow:nLeft+30 GET     pLTC_SORTEIO                                   ;
															VALID   .not. Empty( pLTC_SORTEIO )                    ;
															PICT    '@KD 99/99/99'                                 ;
															CAPTION 'Sorteio'                                      ;
															COLOR   SysFieldGet()


						hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
									oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
						hb_DispOutAt( oWindow:nTop+ 2, oWindow:nLeft+ 2, ' Dezenas ', SystemLabelColor() )


						@ oWindow:nTop+ 3, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 3, oWindow:nLeft+26	GET		pLTC_PARTIDA_01_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 1-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_01_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 3, oWindow:nLeft+28	GET		pLTC_PARTIDA_01_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 3, oWindow:nLeft+31, ;
							oWindow:nTop+ 3, oWindow:nLeft+51	GET		pLTC_PARTIDA_01_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_01_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 3, oWindow:nLeft+53 GET		pLTC_PARTIDA_01_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 4, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 4, oWindow:nLeft+26 	GET		pLTC_PARTIDA_02_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 2-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_02_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 4, oWindow:nLeft+28 GET 	pLTC_PARTIDA_02_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 4, oWindow:nLeft+31, ;
							oWindow:nTop+ 4, oWindow:nLeft+51	GET		pLTC_PARTIDA_02_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_02_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 4, oWindow:nLeft+53 GET		pLTC_PARTIDA_02_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 5, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 5, oWindow:nLeft+26	GET		pLTC_PARTIDA_03_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 3-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_03_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 5, oWindow:nLeft+28 GET		pLTC_PARTIDA_03_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 5, oWindow:nLeft+31, ;
							oWindow:nTop+ 5, oWindow:nLeft+51	GET		pLTC_PARTIDA_03_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_03_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 5, oWindow:nLeft+53 GET		pLTC_PARTIDA_03_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 6, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 6, oWindow:nLeft+26	GET		pLTC_PARTIDA_04_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 4-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_04_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 6, oWindow:nLeft+28 GET		pLTC_PARTIDA_04_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 6, oWindow:nLeft+31, ;
							oWindow:nTop+ 6, oWindow:nLeft+51	GET		pLTC_PARTIDA_04_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_04_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 6, oWindow:nLeft+53	GET		pLTC_PARTIDA_04_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 7, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 7, oWindow:nLeft+26 	GET		pLTC_PARTIDA_05_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 5-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_05_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 7, oWindow:nLeft+28 GET		pLTC_PARTIDA_05_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 7, oWindow:nLeft+31, ;
							oWindow:nTop+ 7, oWindow:nLeft+51	GET		pLTC_PARTIDA_05_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_05_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 7, oWindow:nLeft+53 GET		pLTC_PARTIDA_05_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 8, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 8, oWindow:nLeft+26	GET		pLTC_PARTIDA_06_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 6-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_06_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 8, oWindow:nLeft+28	GET		pLTC_PARTIDA_06_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 8, oWindow:nLeft+31, ;
							oWindow:nTop+ 8, oWindow:nLeft+51	GET		pLTC_PARTIDA_06_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_06_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 8, oWindow:nLeft+53	GET		pLTC_PARTIDA_06_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 9, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 9, oWindow:nLeft+26	GET		pLTC_PARTIDA_07_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 7-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_07_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 9, oWindow:nLeft+28 GET		pLTC_PARTIDA_07_RESULTADO_1                    ;
															PICT 	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+ 9, oWindow:nLeft+31, ;
							oWindow:nTop+ 9, oWindow:nLeft+51 	GET		pLTC_PARTIDA_07_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_07_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 9, oWindow:nLeft+53	GET		pLTC_PARTIDA_07_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+10, oWindow:nLeft+ 6, ;
							oWindow:nTop+10, oWindow:nLeft+26	GET		pLTC_PARTIDA_08_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 8-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_08_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+10, oWindow:nLeft+28 GET		pLTC_PARTIDA_08_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+10, oWindow:nLeft+31, ;
							oWindow:nTop+10, oWindow:nLeft+51	GET		pLTC_PARTIDA_08_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_08_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+10, oWindow:nLeft+53 GET		pLTC_PARTIDA_08_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+11, oWindow:nLeft+ 6, ;
							oWindow:nTop+11, oWindow:nLeft+26 	GET		pLTC_PARTIDA_09_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 9-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_09_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+11, oWindow:nLeft+28	GET		pLTC_PARTIDA_09_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+11, oWindow:nLeft+31, ;
							oWindow:nTop+11, oWindow:nLeft+51	GET		pLTC_PARTIDA_09_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_09_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+11, oWindow:nLeft+53	GET		pLTC_PARTIDA_09_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+12, oWindow:nLeft+ 6, ;
							oWindow:nTop+12, oWindow:nLeft+26 	GET		pLTC_PARTIDA_10_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '10-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_10_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+12, oWindow:nLeft+28 GET		pLTC_PARTIDA_10_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+12, oWindow:nLeft+31, ;
							oWindow:nTop+12, oWindow:nLeft+51	GET		pLTC_PARTIDA_10_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_10_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+12, oWindow:nLeft+53 GET		pLTC_PARTIDA_10_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+13, oWindow:nLeft+ 6, ;
							oWindow:nTop+13, oWindow:nLeft+26 	GET		pLTC_PARTIDA_11_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '11-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_11_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+13, oWindow:nLeft+28 GET		pLTC_PARTIDA_11_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+13, oWindow:nLeft+31, ;
							oWindow:nTop+13, oWindow:nLeft+51 	GET		pLTC_PARTIDA_11_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_11_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+13, oWindow:nLeft+53 GET		pLTC_PARTIDA_11_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+14, oWindow:nLeft+ 6, ;
							oWindow:nTop+14, oWindow:nLeft+26 	GET		pLTC_PARTIDA_12_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '12-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_12_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+14, oWindow:nLeft+28 GET		pLTC_PARTIDA_12_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+14, oWindow:nLeft+31, ;
							oWindow:nTop+14, oWindow:nLeft+51 	GET		pLTC_PARTIDA_12_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_12_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+14, oWindow:nLeft+53	GET		pLTC_PARTIDA_12_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+15, oWindow:nLeft+ 6, ;
							oWindow:nTop+15, oWindow:nLeft+26 	GET		pLTC_PARTIDA_13_CLUBE_1                    ;
																LISTBOX aClubes                                	   ;
																CAPTION '13-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_13_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+15, oWindow:nLeft+28	GET		pLTC_PARTIDA_13_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()

						@ oWindow:nTop+15, oWindow:nLeft+31, ;
							oWindow:nTop+15, oWindow:nLeft+51 	GET		pLTC_PARTIDA_13_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_13_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+15, oWindow:nLeft+53 GET		pLTC_PARTIDA_13_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR	SysFieldGet()

						@ oWindow:nTop+16, oWindow:nLeft+ 6, ;
							oWindow:nTop+16, oWindow:nLeft+26 	GET		pLTC_PARTIDA_14_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '14-'                                      ;
																VALID   .not. Empty( pLTC_PARTIDA_14_CLUBE_1 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+16, oWindow:nLeft+28 GET		pLTC_PARTIDA_14_RESULTADO_1                    ;
															PICT  	'@K 99'                                        ;
															COLOR	SysFieldGet()

						@ oWindow:nTop+16, oWindow:nLeft+31, ;
							oWindow:nTop+16, oWindow:nLeft+51	GET		pLTC_PARTIDA_14_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																VALID   .not. Empty( pLTC_PARTIDA_14_CLUBE_2 )     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()

						@ oWindow:nTop+16, oWindow:nLeft+53 GET		pLTC_PARTIDA_14_RESULTADO_2                    ;
															PICT  	'@K 99'                                        ;
															COLOR 	SysFieldGet()


						hb_DispBox( oWindow:nTop+17, oWindow:nLeft+ 1, ;
									oWindow:nTop+17, oWindow:nRight -1, oWindow:cBorder, SystemFormColor() )
						hb_DispOutAt( oWindow:nTop+ 8, oWindow:nLeft+ 2, ' Premio ', SystemLabelColor() )

						@ oWindow:nTop+18, oWindow:nLeft+12 SAY   'Ganhadores'                                     ;
															COLOR SystemLabelColor()

						@ oWindow:nTop+18, oWindow:nLeft+30 SAY   'Premio'                                         ;
															COLOR SystemLabelColor()


						// Coluna de Acertos			
						@ oWindow:nTop+18, oWindow:nLeft+14 GET     pLTC_RATEIO_ACERTO_14                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '14 Acertos'                                   ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTC_SORTEIO )

						@ oWindow:nTop+19, oWindow:nLeft+14 GET     pLTC_RATEIO_ACERTO_13                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '13 Acertos'                                   ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTC_SORTEIO )

						@ oWindow:nTop+20, oWindow:nLeft+14 GET     pLTC_RATEIO_ACERTO_12                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '12 Acertos'                                   ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '12', pLTC_SORTEIO )


						// Coluna de Premios			
						@ oWindow:nTop+18, oWindow:nLeft+35 GET   pLTC_RATEIO_PREMIO_14                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTC_SORTEIO )

						@ oWindow:nTop+19, oWindow:nLeft+35 GET   pLTC_RATEIO_PREMIO_13                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTC_SORTEIO )

						@ oWindow:nTop+20, oWindow:nLeft+35 GET   pLTC_RATEIO_PREMIO_12                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '12', pLTC_SORTEIO )

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

							If LTCGravaDados()
								lContinua := pFALSE
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

		Else
			ErrorTable( '002' )  // "Nao existem clubes cadastrados."
		EndIf

	EndIf

return


/***
*
*	LTCExcluir()
*
*	Realiza a exclusao do concurso da LOTECA.
*
*   LTCMntBrowse -> LTCExcluir
*
*/
STATIC PROCEDURE LTCExcluir

	If CONCURSO->CON_JOGO == pLOTECA

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
					while JOGOS->JOG_JOGO == CONCURSO->CON_JOGO .and. ;
						JOGOS->JOG_CONCUR == CONCURSO->CON_CONCUR .and. .not. ;
						JOGOS->( Eof() )
						If JOGOS->( NetRLock() )
							JOGOS->( dbDelete() )
							JOGOS->( dbUnlock() )
						EndIf
						JOGOS->( dbSkip() )
					enddo
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
*	LTCGravaDados()
*
*	Realiza a gravacao dos dados da LOTECA.
*
*/
STATIC FUNCTION LTCGravaDados

local lRetValue := pFALSE


	begin sequence

		while .not. lRetValue			

			If iif( CONCURSO->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO ) ), CONCURSO->( NetRLock() ), CONCURSO->( NetAppend() ) )
				CONCURSO->CON_JOGO   := pLOTECA
				CONCURSO->CON_CONCUR := pLTC_CONCURSO
				CONCURSO->CON_SORTEI := pLTC_SORTEIO
				CONCURSO->( dbUnlock() )
			EndIf


			// Gravacao dos dados das Partidas
			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "01" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "01"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_01_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_01_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_01_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_01_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "02" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "02"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_02_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_02_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_02_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_02_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "03" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "03"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_03_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_03_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_03_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_03_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "04" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "04"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_04_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_04_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_04_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_04_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "05" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "05"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_05_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_05_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_05_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_05_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "06" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "06"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_06_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_06_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_06_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_06_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "07" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "07"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_07_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_07_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_07_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_07_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "08" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "08"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_08_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_08_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_08_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_08_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "09" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "09"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_09_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_09_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_09_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_09_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "10" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "10"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_10_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_10_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_10_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_10_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "11" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "11"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_11_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_11_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_11_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_11_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "12" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "12"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_12_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_12_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_12_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_12_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "13" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "13"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_13_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_13_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_13_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_13_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "14" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := "14"
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_14_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_14_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_14_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_14_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf


			// Gravacao dos dados da Premiacao
			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "12" ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO    := pLOTECA
				RATEIO->RAT_CONCUR  := pLTC_CONCURSO
				RATEIO->RAT_FAIXA   := "12"
				RATEIO->RAT_ACERTA  := pLTC_RATEIO_ACERTO_12
				RATEIO->RAT_RATEIO  := pLTC_RATEIO_PREMIO_12
				RATEIO->( DBUnLock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "13" ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO    := pLOTECA
				RATEIO->RAT_CONCUR  := pLTC_CONCURSO
				RATEIO->RAT_FAIXA   := "13"
				RATEIO->RAT_ACERTA  := pLTC_RATEIO_ACERTO_13
				RATEIO->RAT_RATEIO  := pLTC_RATEIO_PREMIO_13
				RATEIO->( DBUnLock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + "14" ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO    := pLOTECA
				RATEIO->RAT_CONCUR  := pLTC_CONCURSO
				RATEIO->RAT_FAIXA   := "14"
				RATEIO->RAT_ACERTA  := pLTC_RATEIO_ACERTO_14
				RATEIO->RAT_RATEIO  := pLTC_RATEIO_PREMIO_14
				RATEIO->( DBUnLock() )
			EndIf

			lRetValue := pTRUE

		enddo

	end sequence

return( lRetValue )


/***
*
*	LTCAcoes()
*
*	Exibe o menu de acoes relacionadas.
*
*   LTCMntBrowse -> LTCAcoes
*
*/
STATIC PROCEDURE LTCAcoes

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
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  3
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 20
		oWindow:Open()

		while lContinua

			aGroup[2]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+ 4, 'Com&binacoes' )
			aGroup[2]:ColorSpec := SysFieldBRadioBox()

			aGroup[3]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+ 4, 'Impressao &Relacao Resultados' )
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
						LTCCombina()

					case nTipAcoes == 2
						LTCRelResult()

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
*	LTCCombina()
*
*	Exibe as opcoes para gerar combinacoes.
*
*   LTCMntBrowse -> LTCAcoes -> LTCCombina
*
*/
STATIC PROCEDURE LTCCombina

local aClubes
local nPointer
local lContinua     := pTRUE
local lPushButton
local oWindow
local oIniFile

local aGroup        := Array(2)
local nOpcao        := 1

local nQuantJog     := 1
local nQuantGrp     := 1



	If SystemConcurso() == pLOTECA

		If Len( aClubes := LoadClubes() ) > 0	

			If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTECA } ) ) > 0

				begin sequence

					// Salva a Area corrente na Pilha
					DstkPush()

					// Inicializa as Variaveis de Dados
					xInitLoteca

					// Inicializa as Variaveis de no vetor aLoteca
					xStoreLoteca

					//
					// Realiza a abertura do arquivo INI
					//
					oIniFile := TIniFile():New( 'odin.ini' )


					// Realiza a leitura dos dados do arquivo de configuracao
					pLTC_PARTIDA_01_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_01_CLUBE_1', Space(5) )
					pLTC_PARTIDA_01_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_01_CLUBE_2', Space(5) )
					pLTC_PARTIDA_02_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_02_CLUBE_1', Space(5) )
					pLTC_PARTIDA_02_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_02_CLUBE_2', Space(5) )
					pLTC_PARTIDA_03_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_03_CLUBE_1', Space(5) )
					pLTC_PARTIDA_03_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_03_CLUBE_2', Space(5) )
					pLTC_PARTIDA_04_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_04_CLUBE_1', Space(5) )
					pLTC_PARTIDA_04_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_04_CLUBE_2', Space(5) )
					pLTC_PARTIDA_05_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_05_CLUBE_1', Space(5) )
					pLTC_PARTIDA_05_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_05_CLUBE_2', Space(5) )
					pLTC_PARTIDA_06_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_06_CLUBE_1', Space(5) )
					pLTC_PARTIDA_06_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_06_CLUBE_2', Space(5) )
					pLTC_PARTIDA_07_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_07_CLUBE_1', Space(5) )
					pLTC_PARTIDA_07_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_07_CLUBE_2', Space(5) )
					pLTC_PARTIDA_08_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_08_CLUBE_1', Space(5) )
					pLTC_PARTIDA_08_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_08_CLUBE_2', Space(5) )
					pLTC_PARTIDA_09_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_09_CLUBE_1', Space(5) )
					pLTC_PARTIDA_09_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_09_CLUBE_2', Space(5) )
					pLTC_PARTIDA_10_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_10_CLUBE_1', Space(5) )
					pLTC_PARTIDA_10_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_10_CLUBE_2', Space(5) )
					pLTC_PARTIDA_11_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_11_CLUBE_1', Space(5) )
					pLTC_PARTIDA_11_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_11_CLUBE_2', Space(5) )
					pLTC_PARTIDA_12_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_12_CLUBE_1', Space(5) )
					pLTC_PARTIDA_12_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_12_CLUBE_2', Space(5) )
					pLTC_PARTIDA_13_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_13_CLUBE_1', Space(5) )
					pLTC_PARTIDA_13_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_13_CLUBE_2', Space(5) )
					pLTC_PARTIDA_14_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_14_CLUBE_1', Space(5) )
					pLTC_PARTIDA_14_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_PARTIDA_14_CLUBE_2', Space(5) )


					// Cria o Objeto Windows
					oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
					oWindow:nTop    := INT( SystemMaxRow() / 2 ) - 11
					oWindow:nLeft   := INT( SystemMaxCol() / 2 ) - 27
					oWindow:nBottom := INT( SystemMaxRow() / 2 ) + 12
					oWindow:nRight  := INT( SystemMaxCol() / 2 ) + 27
					oWindow:Open()


					while lContinua

						aGroup[1]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+ 4, 'Aleatorias' )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()

						aGroup[2]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+14, 'Resultados' )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()

						@ oWindow:nTop+1, oWindow:nLeft+1, ;
							oWindow:nTop+ 3, oWindow:nRight-1 	GET        nOpcao                                  ;
																RADIOGROUP aGroup                                  ;
																COLOR      SysFieldGRadioBox()

						hb_DispBox( oWindow:nTop+ 4, oWindow:nLeft+ 1, ;
									oWindow:nTop+ 4, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

						@ oWindow:nTop+ 5, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 5, oWindow:nLeft+26 	GET		pLTC_PARTIDA_01_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 1-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 5, oWindow:nLeft+31, ;
							oWindow:nTop+ 5, oWindow:nLeft+51	GET		pLTC_PARTIDA_01_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+ 6, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 6, oWindow:nLeft+26 	GET		pLTC_PARTIDA_02_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 2-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 6, oWindow:nLeft+31, ;
							oWindow:nTop+ 6, oWindow:nLeft+51	GET		pLTC_PARTIDA_02_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+ 7, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 7, oWindow:nLeft+26 	GET		pLTC_PARTIDA_03_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 3-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 7, oWindow:nLeft+31, ;
							oWindow:nTop+ 7, oWindow:nLeft+51	GET		pLTC_PARTIDA_03_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+ 8, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 8, oWindow:nLeft+26 	GET		pLTC_PARTIDA_04_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 4-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 8, oWindow:nLeft+31, ;
							oWindow:nTop+ 8, oWindow:nLeft+51	GET		pLTC_PARTIDA_04_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+ 9, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 9, oWindow:nLeft+26 	GET		pLTC_PARTIDA_05_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 5-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+ 9, oWindow:nLeft+31, ;
							oWindow:nTop+ 9, oWindow:nLeft+51	GET		pLTC_PARTIDA_05_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+10, oWindow:nLeft+ 6, ;
							oWindow:nTop+10, oWindow:nLeft+26 	GET		pLTC_PARTIDA_06_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 6-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+10, oWindow:nLeft+31, ;
							oWindow:nTop+10, oWindow:nLeft+51	GET		pLTC_PARTIDA_06_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+11, oWindow:nLeft+ 6, ;
							oWindow:nTop+11, oWindow:nLeft+26 	GET		pLTC_PARTIDA_07_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 7-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+11, oWindow:nLeft+31, ;
							oWindow:nTop+11, oWindow:nLeft+51	GET		pLTC_PARTIDA_07_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+12, oWindow:nLeft+ 6, ;
							oWindow:nTop+12, oWindow:nLeft+26 	GET		pLTC_PARTIDA_08_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 8-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+12, oWindow:nLeft+31, ;
							oWindow:nTop+12, oWindow:nLeft+51	GET		pLTC_PARTIDA_08_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+13, oWindow:nLeft+ 6, ;
							oWindow:nTop+13, oWindow:nLeft+26 	GET		pLTC_PARTIDA_09_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 9-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+13, oWindow:nLeft+31, ;
							oWindow:nTop+13, oWindow:nLeft+51	GET		pLTC_PARTIDA_09_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+14, oWindow:nLeft+ 6, ;
							oWindow:nTop+14, oWindow:nLeft+26 	GET		pLTC_PARTIDA_10_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '10-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+14, oWindow:nLeft+31, ;
							oWindow:nTop+14, oWindow:nLeft+51	GET		pLTC_PARTIDA_10_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+15, oWindow:nLeft+ 6, ;
							oWindow:nTop+15, oWindow:nLeft+26 	GET		pLTC_PARTIDA_11_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '11-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+15, oWindow:nLeft+31, ;
							oWindow:nTop+15, oWindow:nLeft+51	GET		pLTC_PARTIDA_11_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+16, oWindow:nLeft+ 6, ;
							oWindow:nTop+16, oWindow:nLeft+26 	GET		pLTC_PARTIDA_12_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '12-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+16, oWindow:nLeft+31, ;
							oWindow:nTop+16, oWindow:nLeft+51	GET		pLTC_PARTIDA_12_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+17, oWindow:nLeft+ 6, ;
							oWindow:nTop+17, oWindow:nLeft+26 	GET		pLTC_PARTIDA_13_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '13-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+17, oWindow:nLeft+31, ;
							oWindow:nTop+17, oWindow:nLeft+51	GET		pLTC_PARTIDA_13_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						@ oWindow:nTop+18, oWindow:nLeft+ 6, ;
							oWindow:nTop+18, oWindow:nLeft+26 	GET		pLTC_PARTIDA_14_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION '14-'                                      ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						@ oWindow:nTop+18, oWindow:nLeft+31, ;
							oWindow:nTop+18, oWindow:nLeft+51	GET		pLTC_PARTIDA_14_CLUBE_2                    ;
																LISTBOX	aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR 	SysFieldListBox()


						hb_DispBox( oWindow:nBottom- 4, oWindow:nLeft+ 1, ;
									oWindow:nBottom- 4, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

						@ oWindow:nBottom- 3, oWindow:nLeft+ 15 GET     nQuantJog                                  ;
																PICT    '@EN 99999999999999'                       ;
																CAPTION 'Quant.Jogos'                              ;
																COLOR   SysFieldGet()
			
						@ oWindow:nBottom- 3, oWindow:nLeft+ 45 GET     nQuantGrp                                  ;
																PICT    '@EN 999'                                  ;
																CAPTION 'Quant.Grupos'                             ;
																COLOR   SysFieldGet()


						hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
									oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

						@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                     ;
																CAPTION ' Con&firma '                              ;
																COLOR   SysPushButton()                            ;
																STYLE   ''                                         ;
																WHEN    nQuantJog >= 1 .and.                       ;
																		nQuantJog <= pLTC_DEF_MAX_COMB .and.       ;
																		nQuantGrp >= 1 .and.                       ;
																		.not. Empty( pLTC_PARTIDA_01_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_01_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_02_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_02_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_03_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_03_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_04_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_04_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_05_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_05_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_06_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_06_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_07_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_07_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_08_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_08_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_09_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_09_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_10_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_10_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_11_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_11_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_12_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_12_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_13_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_13_CLUBE_2 ) .and. ;
																		.not. Empty( pLTC_PARTIDA_14_CLUBE_1 ) .and. .not. Empty( pLTC_PARTIDA_14_CLUBE_2 )       ;
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

						EndIf

					enddo

				always
					// Fecha o Objeto Windows
					oWindow:Close()
					
					// Atualiza as variaveis do arquivo de confiruacao
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_01_CLUBE_1', pLTC_PARTIDA_01_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_01_CLUBE_2', pLTC_PARTIDA_01_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_02_CLUBE_1', pLTC_PARTIDA_02_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_02_CLUBE_2', pLTC_PARTIDA_02_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_03_CLUBE_1', pLTC_PARTIDA_03_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_03_CLUBE_2', pLTC_PARTIDA_03_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_04_CLUBE_1', pLTC_PARTIDA_04_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_04_CLUBE_2', pLTC_PARTIDA_04_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_05_CLUBE_1', pLTC_PARTIDA_05_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_05_CLUBE_2', pLTC_PARTIDA_05_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_06_CLUBE_1', pLTC_PARTIDA_06_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_06_CLUBE_2', pLTC_PARTIDA_06_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_07_CLUBE_1', pLTC_PARTIDA_07_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_07_CLUBE_2', pLTC_PARTIDA_07_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_08_CLUBE_1', pLTC_PARTIDA_08_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_08_CLUBE_2', pLTC_PARTIDA_08_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_09_CLUBE_1', pLTC_PARTIDA_09_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_09_CLUBE_2', pLTC_PARTIDA_09_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_10_CLUBE_1', pLTC_PARTIDA_10_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_10_CLUBE_2', pLTC_PARTIDA_10_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_11_CLUBE_1', pLTC_PARTIDA_11_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_11_CLUBE_2', pLTC_PARTIDA_11_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_12_CLUBE_1', pLTC_PARTIDA_12_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_12_CLUBE_2', pLTC_PARTIDA_12_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_13_CLUBE_1', pLTC_PARTIDA_13_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_13_CLUBE_2', pLTC_PARTIDA_13_CLUBE_2 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_14_CLUBE_1', pLTC_PARTIDA_14_CLUBE_1 )
					oIniFile:WriteString( 'LOTECA', 'LTC_PARTIDA_14_CLUBE_2', pLTC_PARTIDA_14_CLUBE_2 )
					
					// Atualiza o arquivo de Configuracao
					oIniFile:UpdateFile()
					
					// Restaura a tabela da Pilha
					DstkPop()
				end sequence

			EndIf

		Else
			ErrorTable( '002' )  // "Nao existem clubes cadastrados."
		EndIf

	EndIf				

return


/***
*
*	LTCAnaliAleatoria()
*
*	Realiza a geracao das dezenas para a LOTECA aleatoriamente.
*
*   LTCMntBrowse -> LTCAcoes -> LTCCombina -> LTCAnaliAleatoria
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
* nQuantDezenas : Informa o numero de dezenas a ser geradas por jogos
*
*/
STATIC PROCEDURE LTCAnaliAleatoria( nQuantJogos, nQuantDezenas )

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

				If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTECA } ) ) > 0

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
						LTCShowAposta()
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
*	LTCShowAposta()
*
*	Exibe as apostas gerados no arquivo Temporario.
*
*   LTCMntBrowse -> LTCAcoes -> LTCCombina -> LTCAnaliAleatoria -> LTCShowAposta
*
*/
STATIC PROCEDURE LTCShowAposta

local oBrowse, oColumn
local oTmpButton, oScrollBar
local nKey
local nPosRecno   := 0
local nMenuItem   := 1
local nMaxItens   := 0
local lSair       := pFALSE
local oWindow
local bFiltro     := { || TMP->( .not. Eof() ) }

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
												k := iif( Abs(x) >= IIF( x >= 0,                          ;
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
								if MRow() >= oBrowse:nTop .and. MRow() <= oBrowse:nBottom .and. ;
									Mcol() >= oBrowse:nTop .and. Mcol() <= oBrowse:nRight
									oBrowse:up()
								EndIf

							case nKey == K_MWBACKWARD
								if MRow() >= oBrowse:nTop .and. MRow() <= oBrowse:nBottom .and. ;
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
*	LTCRelResult()
*
*	Realiza a impressao dos resultados da LOTECA.
*
*   LTCMntBrowse -> LTCAcoes -> LTCCombina -> LTCRelResult
*
*/
STATIC PROCEDURE LTCRelResult

local lContinua    := pTRUE
local lPushButton
local oWindow

local cInicio
local cFinal
local nCurrent
local nTotConcurso := 0
local bFiltro      := { || CONCURSO->CON_JOGO == pLOTECA .and. CONCURSO->( .not. Eof() ) }
local oBarProgress
local oPDFReport
local nLinha


	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		// Totaliza a quantidade de registro cadastrados
		CONCURSO->( dbEval( { || nTotConcurso++ }, bFiltro ) )
		if nTotConcurso >= 1

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

			WHILE lContinua

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

				IF lContinua .and. LastKey() != K_ESC

					dbSelectArea('CONCURSO')
					IF CONCURSO->( dbSetOrder(1), dbSeek( pLOTECA + cInicio ) ) .and. ;
						CONCURSO->( dbSetOrder(1), dbSeek( pLOTECA + cFinal ) )

						bFiltro := { || CONCURSO->CON_JOGO == pLOTECA .and. CONCURSO->( .not. Eof() ) .and. ;
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
							oPDFReport:SetInfo( 'EDILSON MENDES', 'ODIN', 'RESULTADOS LOTECA', oPDFReport:cFileName )

							nLinha := oPDFReport:MaxCol()

							//Posiciona o Registro
							If CONCURSO->( dbSetOrder(1), dbSeek( pLOTECA + cInicio ) )

								while Eval( bFiltro )

									// Atualiza a barra de Progresso
									oBarProgress:Update( ( nCurrent++ / nTotConcurso ) * 100 )

									If nLinha >= ( oPDFReport:MaxCol() - 35 )
										oPDFReport:AddPage()
										oPDFReport:DrawRetangle( 0,  0, 22, 2 )
										oPDFReport:DrawRetangle( 0, 25, 49, 2 )
										oPDFReport:DrawRetangle( 0, 77, 22, 2 )
										oPDFReport:DrawText( 1, 26, PadC( 'RESULTADOS LOTECA', 70 ), , 10, 'Helvetica-Bold' )
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

							endif

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

				endif

			enddo

		else
			ErrorTable( '207' )  // Nao existem informacoes a serem impressas.
		endif

	always
		// Fecha o Objeto Windows
		oWindow:Close()
		// Restaura a tabela da Pilha
		DstkPop()
	end sequence

return


STATIC FUNCTION ArraySplit( arrayIn, nChunksReq )

	LOCAL arrayOut
	LOCAL nChunkSize
	LOCAL nChunkPos
	LOCAL item
 
	IF nChunksReq > 0
 
	   arrayOut := {}
	   nChunkSize := Max( Round( Len( arrayIn ) / nChunksReq, 0 ), 1 )
	   nChunkPos := 0
 
	   FOR EACH item IN arrayIn
		  IF nChunkPos == 0
			 AAdd( arrayOut, {} )
		  ENDIF
		  AAdd( ATail( arrayOut ), item )
		  IF ++nChunkPos == nChunkSize .AND. Len( arrayOut ) < nChunksReq
			 nChunkPos := 0
		  ENDIF
	   NEXT
	ELSE
	   arrayOut := { arrayIn }
	ENDIF
 
	RETURN arrayOut
 