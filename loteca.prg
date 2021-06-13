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

local oBrwLoteca
local oBrwPartidas
local oColumn
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

local bFilConcurso  := { || CONCURSO->CON_JOGO == pLOTECA .and. ;
							.not. CONCURSO->( Eof() ) }
local bFilPartidas  := { ||	JOGOS->JOG_JOGO == CONCURSO->CON_JOGO .and. ;
							JOGOS->JOG_CONCUR == CONCURSO->CON_CONCUR .and. ;
							.not. JOGOS->( Eof() ) }

local aSelDezenas   := {}
local nRow          := 1
local nPointer
local nPosDezenas   := 1


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
					oBrwLoteca               	:= 	TBrowseDB( 	oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
																oWindow:nBottom-20, oWindow:nRight- 1 )
					oBrwLoteca:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFilConcurso ) ) <> 0, ;
																			( nCount += xRecno, xRecno ), xRecno ) }
					oBrwLoteca:goTopBlock    	:= 	{ || nCount := 1, GoTopDB( bFilConcurso ) }
					oBrwLoteca:goBottomBlock 	:= 	{ || nCount := nMaxItens, GoBottomDB( bFilConcurso ) }
					oBrwLoteca:colorSpec     	:= SysBrowseColor()
					oBrwLoteca:headSep       	:= Chr(205)
					oBrwLoteca:colSep        	:= Chr(179)
					oBrwLoteca:Cargo         	:= {}

					// Adiciona as Colunas
					oColumn 			:= TBColumnNew( PadC( 'Concurso', 10 ), CONCURSO->( FieldBlock( 'CON_CONCUR' ) ) )
					oColumn:picture 	:= '@!'
					oColumn:width   	:= 10
					oBrwLoteca:addColumn( oColumn )

					oColumn 			:= TBColumnNew( PadC( 'Sorteio', 10 ), CONCURSO->( FieldBlock( 'CON_SORTEI' ) ) )
					oColumn:picture 	:= '@D 99/99/99'
					oColumn:width   	:= 10
					oBrwLoteca:addColumn( oColumn )

					// Monta a browse com os clubes da competicao
					begin sequence

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

						oColumn         := TBColumnNew( '',                        { || JOGOS->JOG_FAIXA } )
						oColumn:picture := '@!'
						oColumn:width   := 02
						oBrwPartidas:addColumn( oColumn )

						oColumn            := TBColumnNew( PadC( 'Coluna 1', 20 ), {|| PadL( 	iif( CLUBES->( dbSetOrder(1), dbSeek( JOGOS->JOG_COL_01 ) ),     ;
																								AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), ;
																								'' ), 20 ) } )
						oColumn:picture    := '@!'
						oColumn:width      := 20
						oBrwPartidas:addColumn( oColumn )

						oColumn            := TBColumnNew( '1',                    {|| iif( JOGOS->JOG_PON_01 > JOGOS->JOG_PON_02, 'X', ' ' ) } )
						oColumn:picture    := '@!'
						oColumn:width      := 1
						oBrwPartidas:addColumn( oColumn )

						oColumn            := TBColumnNew( 'X',                    {|| iif( JOGOS->JOG_PON_01 == JOGOS->JOG_PON_02, 'X', ' ' ) } )
						oColumn:picture    := '@!'
						oColumn:width      := 1
						oBrwPartidas:addColumn( oColumn )

						oColumn            := TBColumnNew( '2',                    {|| iif( JOGOS->JOG_PON_01 < JOGOS->JOG_PON_02, 'X', ' ' ) } )
						oColumn:picture    := '@!'
						oColumn:width      := 1
						oBrwPartidas:addColumn( oColumn )

						oColumn            := TBColumnNew( PadC( 'Coluna 2', 20 ), {|| PadR( iif(	CLUBES->( dbSetOrder(1), dbSeek( JOGOS->JOG_COL_02 ) ),          ;
																									AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), ;
																									'' ), 20 ) } )
						oColumn:picture    := '@!'
						oColumn:width      := 20
						oBrwPartidas:addColumn( oColumn )

					always
						oBrwLoteca:forceStable()
						oBrwPartidas:forceStable()
					end sequence

					// Realiza a Montagem da Barra de Rolagem
					oScrollBar           	:= ScrollBar( oWindow:nTop+ 3, oWindow:nBottom-20, oWindow:nRight )
					oScrollBar:colorSpec 	:= SysScrollBar()
					oScrollBar:display()

					// Desenha os botoes da tela
					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
					oTmpButton:sBlock    := { || LtcIncluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwLoteca:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
					oTmpButton:sBlock    := { || LtcModificar() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwLoteca:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' &Excluir ' )
					oTmpButton:sBlock    := { || LtcExcluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwLoteca:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Ac&oes ' )
					oTmpButton:sBlock    := { || LtcAcoes() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwLoteca:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+42, ' &Sair ' )
					oTmpButton:sBlock    := { || lSair := pTRUE }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwLoteca:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					AEval( oBrwLoteca:Cargo, { |xItem| xItem[1]:Display() } )
					oBrwLoteca:Cargo[ nMenuItem ][1]:SetFocus()

					while .not. lSair

                        // Destaca o registro selecionado no Browse 
                        oBrwLoteca:colorRect( { oBrwLoteca:rowPos, 1, oBrwLoteca:rowPos, oBrwLoteca:colCount}, {1,2})
						oBrwLoteca:forceStable()
						oBrwLoteca:colorRect( { oBrwLoteca:rowPos, oBrwLoteca:freeze + 1, oBrwLoteca:rowPos, oBrwLoteca:colCount}, {8,2})
						oBrwLoteca:hilite()

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

						If oBrwLoteca:stable .and. nKey > 0

							nLastKeyType := hb_MilliSeconds()
							nRefresh     := 1000					

							do case
								case ( nPointer := AScan( pBRW_INKEYS, { |xKey| xKey[ pBRW_KEY ] == nKey } ) ) > 0
                                    Eval( pBRW_INKEYS[ nPointer ][ pBRW_ACTION ], oBrwLoteca )

								case ( nPointer := AScan( oBrwLoteca:Cargo, { |xKey| xKey[ pBRW_ACTION ] == Upper( chr( nKey ) ) } ) ) > 0
									If oBrwLoteca:Cargo[ nMenuItem ][1]:HasFocus
										oBrwLoteca:Cargo[ nMenuItem ][1]:KillFocus()
									EndIf
									nMenuItem := nPointer
									oBrwLoteca:Cargo[ nMenuItem ][1]:SetFocus()

								case nKey == K_LEFT .or. nKey == K_LBUTTONDOWN
									If oBrwLoteca:Cargo[ nMenuItem ][1]:HasFocus
										oBrwLoteca:Cargo[ nMenuItem ][1]:KillFocus()
									EndIf
									If --nMenuItem < 1
										nMenuItem := 1
									EndIf
									oBrwLoteca:Cargo[ nMenuItem ][1]:SetFocus()

								case nKey == K_RIGHT .or. nKey == K_RBUTTONUP
									If oBrwLoteca:Cargo[ nMenuItem ][1]:HasFocus
										oBrwLoteca:Cargo[ nMenuItem ][1]:KillFocus()
									EndIf
									If ++nMenuItem > Len( oBrwLoteca:Cargo )
										nMenuItem := Len( oBrwLoteca:Cargo )
									EndIf
									oBrwLoteca:Cargo[ nMenuItem ][1]:SetFocus()

								case nKey == K_MWFORWARD
									If MRow() >= oBrwLoteca:nTop .and. MRow() <= oBrwLoteca:nBottom .and. ;
										Mcol() >= oBrwLoteca:nTop .and. Mcol() <= oBrwLoteca:nRight
										oBrwLoteca:up()
									EndIf

								case nKey == K_MWBACKWARD
									If MRow() >= oBrwLoteca:nTop .and. MRow() <= oBrwLoteca:nBottom .and. ;
										Mcol() >= oBrwLoteca:nTop .and. Mcol() <= oBrwLoteca:nRight
										oBrwLoteca:down()
									EndIf	

								case nKey == K_ENTER
									oBrwLoteca:Cargo[ nMenuItem ][1]:Select()
									oBrwLoteca:refreshAll()

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
*	LtcIncluir()
*
*	Realiza a inclusao dos dados para o concurso da LOTECA.
*
*   LtcMntBrowse -> LtcIncluir
*
*/
STATIC PROCEDURE LtcIncluir

local aClubes
local nPointer
local lContinua     := pTRUE
local lPushButton
local oWindow
local nCodigo       := 1
local cAutoSequence
local oIniFile

memvar xCount, xTemp


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
					dbEval( { || nCodigo++ }, { || CONCURSO->CON_JOGO == pLOTECA .and. .not. CONCURSO->( Eof() ) } )
					pLTC_CONCURSO := StrZero( nCodigo, 5 )
				EndIf

				// Realiza a leitura dos dados do arquivo de configuracao
				pLTC_PARTIDA_01_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_01_CLUBE_1', Space(5) )
				pLTC_PARTIDA_01_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_01_CLUBE_2', Space(5) )
				pLTC_PARTIDA_02_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_02_CLUBE_1', Space(5) )
				pLTC_PARTIDA_02_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_02_CLUBE_2', Space(5) )
				pLTC_PARTIDA_03_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_03_CLUBE_1', Space(5) )
				pLTC_PARTIDA_03_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_03_CLUBE_2', Space(5) )
				pLTC_PARTIDA_04_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_04_CLUBE_1', Space(5) )
				pLTC_PARTIDA_04_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_04_CLUBE_2', Space(5) )
				pLTC_PARTIDA_05_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_05_CLUBE_1', Space(5) )
				pLTC_PARTIDA_05_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_05_CLUBE_2', Space(5) )
				pLTC_PARTIDA_06_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_06_CLUBE_1', Space(5) )
				pLTC_PARTIDA_06_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_06_CLUBE_2', Space(5) )
				pLTC_PARTIDA_07_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_07_CLUBE_1', Space(5) )
				pLTC_PARTIDA_07_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_07_CLUBE_2', Space(5) )
				pLTC_PARTIDA_08_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_08_CLUBE_1', Space(5) )
				pLTC_PARTIDA_08_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_08_CLUBE_2', Space(5) )
				pLTC_PARTIDA_09_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_09_CLUBE_1', Space(5) )
				pLTC_PARTIDA_09_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_09_CLUBE_2', Space(5) )
				pLTC_PARTIDA_10_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_10_CLUBE_1', Space(5) )
				pLTC_PARTIDA_10_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_10_CLUBE_2', Space(5) )
				pLTC_PARTIDA_11_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_11_CLUBE_1', Space(5) )
				pLTC_PARTIDA_11_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_11_CLUBE_2', Space(5) )
				pLTC_PARTIDA_12_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_12_CLUBE_1', Space(5) )
				pLTC_PARTIDA_12_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_12_CLUBE_2', Space(5) )
				pLTC_PARTIDA_13_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_13_CLUBE_1', Space(5) )
				pLTC_PARTIDA_13_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_13_CLUBE_2', Space(5) )
				pLTC_PARTIDA_14_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_14_CLUBE_1', Space(5) )
				pLTC_PARTIDA_14_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_14_CLUBE_2', Space(5) )

				// Cria o Objeto Windows
				oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 12
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 28
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 12
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 28
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
					hb_DispOutAt( oWindow:nTop+17, oWindow:nLeft+ 2, ' Premio ', SystemLabelColor() )

					@ oWindow:nTop+18, oWindow:nLeft+12 SAY   'Ganhadores'                                     ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+18, oWindow:nLeft+30 SAY   'Premio'                                         ;
														COLOR SystemLabelColor()

					// Coluna de Acertos			
					@ oWindow:nTop+19, oWindow:nLeft+14 GET     pLTC_RATEIO_ACERTO_14                          ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '14 Acertos'                                   ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTC_SORTEIO )

					@ oWindow:nTop+20, oWindow:nLeft+14 GET     pLTC_RATEIO_ACERTO_13                          ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '13 Acertos'                                   ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTC_SORTEIO )

					@ oWindow:nTop+21, oWindow:nLeft+14 GET     pLTC_RATEIO_ACERTO_12                          ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '12 Acertos'                                   ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '12', pLTC_SORTEIO )

					// Coluna de Premios			
					@ oWindow:nTop+19, oWindow:nLeft+35 GET   pLTC_RATEIO_PREMIO_14                            ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '14', pLTC_SORTEIO )

					@ oWindow:nTop+20, oWindow:nLeft+35 GET   pLTC_RATEIO_PREMIO_13                            ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '13', pLTC_SORTEIO )

					@ oWindow:nTop+21, oWindow:nLeft+35 GET   pLTC_RATEIO_PREMIO_12                            ;
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

							If LtcGravaDados()
								lContinua := pFALSE
							EndIf

						Else
							ErrorTable( '801' )  // Concurso ja cadastrado.
						EndIf

					EndIf

				enddo

			always
				// Atualiza o parametro do arquivo de configuracao de autonumeracao
				oIniFile:WriteString( 'LOTECA', 'AUTO_SEQUENCE', cAutoSequence )

				// Atualiza as variaveis do arquivo de confiruacao
				oIniFile:WriteString( 'LOTECA', 'LTC_01_CLUBE_1', pLTC_PARTIDA_01_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_01_CLUBE_2', pLTC_PARTIDA_01_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_02_CLUBE_1', pLTC_PARTIDA_02_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_02_CLUBE_2', pLTC_PARTIDA_02_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_03_CLUBE_1', pLTC_PARTIDA_03_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_03_CLUBE_2', pLTC_PARTIDA_03_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_04_CLUBE_1', pLTC_PARTIDA_04_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_04_CLUBE_2', pLTC_PARTIDA_04_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_05_CLUBE_1', pLTC_PARTIDA_05_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_05_CLUBE_2', pLTC_PARTIDA_05_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_06_CLUBE_1', pLTC_PARTIDA_06_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_06_CLUBE_2', pLTC_PARTIDA_06_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_07_CLUBE_1', pLTC_PARTIDA_07_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_07_CLUBE_2', pLTC_PARTIDA_07_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_08_CLUBE_1', pLTC_PARTIDA_08_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_08_CLUBE_2', pLTC_PARTIDA_08_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_09_CLUBE_1', pLTC_PARTIDA_09_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_09_CLUBE_2', pLTC_PARTIDA_09_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_10_CLUBE_1', pLTC_PARTIDA_10_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_10_CLUBE_2', pLTC_PARTIDA_10_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_11_CLUBE_1', pLTC_PARTIDA_11_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_11_CLUBE_2', pLTC_PARTIDA_11_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_12_CLUBE_1', pLTC_PARTIDA_12_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_12_CLUBE_2', pLTC_PARTIDA_12_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_13_CLUBE_1', pLTC_PARTIDA_13_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_13_CLUBE_2', pLTC_PARTIDA_13_CLUBE_2 )
				oIniFile:WriteString( 'LOTECA', 'LTC_14_CLUBE_1', pLTC_PARTIDA_14_CLUBE_1 )
				oIniFile:WriteString( 'LOTECA', 'LTC_14_CLUBE_2', pLTC_PARTIDA_14_CLUBE_2 )

				// Atualiza o arquivo de Configuracao
				oIniFile:UpdateFile()

				// Fecha o Objeto Windows
				oWindow:Close()

				// Restaura a tabela da Pilha
				DstkPop()
			end sequence

		EndIf

	Else
		ErrorTable( '802' )  // Nao existem clubes cadastrados.
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
STATIC PROCEDURE LtcModificar

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
						while JOGOS->JOG_JOGO == CONCURSO->CON_JOGO .and. ;
							JOGOS->JOG_CONCUR == CONCURSO->CON_CONCUR .and. ;
							.not. JOGOS->( Eof() )
							do case
								case JOGOS->JOG_FAIXA == '01'
									pLTC_PARTIDA_01_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_01_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_01_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_01_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '02'
									pLTC_PARTIDA_02_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_02_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_02_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_02_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '03'
									pLTC_PARTIDA_03_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_03_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_03_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_03_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '04'
									pLTC_PARTIDA_04_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_04_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_04_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_04_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '05'
									pLTC_PARTIDA_05_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_05_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_05_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_05_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '06'
									pLTC_PARTIDA_06_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_06_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_06_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_06_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '07'
									pLTC_PARTIDA_07_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_07_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_07_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_07_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '08'
									pLTC_PARTIDA_08_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_08_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_08_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_08_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '09'
									pLTC_PARTIDA_09_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_09_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_09_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_09_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '10'
									pLTC_PARTIDA_10_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_10_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_10_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_10_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '11'
									pLTC_PARTIDA_11_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_11_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_11_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_11_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '12'
									pLTC_PARTIDA_12_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_12_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_12_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_12_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '13'
									pLTC_PARTIDA_13_CLUBE_1     := JOGOS->JOG_COL_01
									pLTC_PARTIDA_13_RESULTADO_1 := JOGOS->JOG_PON_01
									pLTC_PARTIDA_13_CLUBE_2     := JOGOS->JOG_COL_02
									pLTC_PARTIDA_13_RESULTADO_2 := JOGOS->JOG_PON_02
								case JOGOS->JOG_FAIXA == '14'
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
								case RATEIO->RAT_FAIXA == '12'
									pLTC_RATEIO_ACERTO_12 := RATEIO->RAT_ACERTA
									pLTC_RATEIO_PREMIO_12 := RATEIO->RAT_RATEIO
								case RATEIO->RAT_FAIXA == '13'
									pLTC_RATEIO_ACERTO_13 := RATEIO->RAT_ACERTA
									pLTC_RATEIO_PREMIO_13 := RATEIO->RAT_RATEIO
								case RATEIO->RAT_FAIXA == '14'
									pLTC_RATEIO_ACERTO_14 := RATEIO->RAT_ACERTA
									pLTC_RATEIO_PREMIO_14 := RATEIO->RAT_RATEIO
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

							If LtcGravaDados()
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
			ErrorTable( '802' )  // Nao existem clubes cadastrados.
		EndIf

	EndIf

return


/***
*
*	LtcExcluir()
*
*	Realiza a exclusao do concurso da LOTECA.
*
*   LtcMntBrowse -> LtcExcluir
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
						RATEIO->RAT_CONCUR == CONCURSO->CON_CONCUR .and. ;
						.not. RATEIO->( Eof() )
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
						JOGOS->JOG_CONCUR == CONCURSO->CON_CONCUR .and. ;
						.not. JOGOS->( Eof() )
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
*	LtcGravaDados()
*
*	Realiza a gravacao dos dados da LOTECA.
*
*   LtcMntBrowse -> LtcIncluir
*                -> LtcModificar -> LtcGravaDados
*
*/
STATIC FUNCTION LtcGravaDados

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
			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '01' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '01'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_01_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_01_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_01_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_01_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '02' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '02'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_02_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_02_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_02_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_02_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '03' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '03'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_03_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_03_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_03_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_03_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '04' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '04'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_04_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_04_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_04_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_04_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '05' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '05'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_05_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_05_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_05_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_05_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '06' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '06'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_06_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_06_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_06_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_06_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '07' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '07'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_07_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_07_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_07_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_07_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '08' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '08'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_08_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_08_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_08_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_08_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '09' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '09'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_09_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_09_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_09_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_09_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '10' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '10'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_10_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_10_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_10_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_10_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '11' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '11'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_11_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_11_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_11_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_11_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '12' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '12'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_12_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_12_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_12_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_12_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '13' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '13'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_13_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_13_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_13_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_13_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '14' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTECA
				JOGOS->JOG_CONCUR := pLTC_CONCURSO
				JOGOS->JOG_FAIXA  := '14'
				JOGOS->JOG_COL_01 := pLTC_PARTIDA_14_CLUBE_1
				JOGOS->JOG_PON_01 := pLTC_PARTIDA_14_RESULTADO_1
				JOGOS->JOG_COL_02 := pLTC_PARTIDA_14_CLUBE_2
				JOGOS->JOG_PON_02 := pLTC_PARTIDA_14_RESULTADO_2
				JOGOS->( dbUnlock() )
			EndIf

			// Gravacao dos dados da Premiacao
			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '12' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO    := pLOTECA
				RATEIO->RAT_CONCUR  := pLTC_CONCURSO
				RATEIO->RAT_FAIXA   := '12'
				RATEIO->RAT_ACERTA  := pLTC_RATEIO_ACERTO_12
				RATEIO->RAT_RATEIO  := pLTC_RATEIO_PREMIO_12
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '13' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO    := pLOTECA
				RATEIO->RAT_CONCUR  := pLTC_CONCURSO
				RATEIO->RAT_FAIXA   := '13'
				RATEIO->RAT_ACERTA  := pLTC_RATEIO_ACERTO_13
				RATEIO->RAT_RATEIO  := pLTC_RATEIO_PREMIO_13
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTECA + pLTC_CONCURSO + '14' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO    := pLOTECA
				RATEIO->RAT_CONCUR  := pLTC_CONCURSO
				RATEIO->RAT_FAIXA   := '14'
				RATEIO->RAT_ACERTA  := pLTC_RATEIO_ACERTO_14
				RATEIO->RAT_RATEIO  := pLTC_RATEIO_PREMIO_14
				RATEIO->( dbUnlock() )
			EndIf

			lRetValue := pTRUE

		enddo

	end sequence

return( lRetValue )


/***
*
*	LtcAcoes()
*
*	Exibe o menu de acoes relacionadas.
*
*   LtcMntBrowse -> LtcAcoes
*
*/
STATIC PROCEDURE LTCAcoes

local lPushButton
local oWindow
local lContinua   := pTRUE
local aGroup      := Array(4)
local nTipAcoes   := 1


	begin sequence

		// Cria o Objeto Windows	
		oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  5
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 20
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  5
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 20
		oWindow:Open()

		while lContinua

			aGroup[1]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+ 4, 'Cadastro Clubes' )
			aGroup[1]:ColorSpec := SysFieldBRadioBox()

			aGroup[2]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+ 4, 'Manutencao Competicoes' )
			aGroup[2]:ColorSpec := SysFieldBRadioBox()

			aGroup[3]           := RadioButton( oWindow:nTop+ 4, oWindow:nLeft+ 4, 'Com&binacoes' )
			aGroup[3]:ColorSpec := SysFieldBRadioBox()

			aGroup[4]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+ 4, 'Impressao &Relacao Resultados' )
			aGroup[4]:ColorSpec := SysFieldBRadioBox()

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
						Clubes()

					case nTipAcoes == 2
						Competicoes()

					case nTipAcoes == 3
						Combina()

					case nTipAcoes == 4
						Competicoes()

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
*	Combina()
*
*	Exibe as opcoes para gerar combinacoes.
*
*   LtcMntBrowse -> LtcAcoes -> Combina
*
*/
STATIC PROCEDURE Combina

local aClubes
local lContinua     := pTRUE
local lPushButton
local oWindow
local oIniFile
local aGroup        := Array(2)


	If Len( aClubes := LoadClubes() ) > 0	

		begin sequence

			// Inicializa as Variaveis de Dados
			xInitMontaLoteca

			// Inicializa as Variaveis de no vetor aLoteca
			xStoreMontaLoteca

			//
			// Realiza a abertura do arquivo INI
			//
			oIniFile := TIniFile():New( 'odin.ini' )

			// Realiza a leitura dos dados do arquivo de configuracao
			pLTC_APOSTA_01_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_01_CLUBE_1', Space(5) )
			pLTC_APOSTA_01_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_01_CLUBE_2', Space(5) )
			pLTC_APOSTA_02_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_02_CLUBE_1', Space(5) )
			pLTC_APOSTA_02_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_02_CLUBE_2', Space(5) )
			pLTC_APOSTA_03_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_03_CLUBE_1', Space(5) )
			pLTC_APOSTA_03_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_03_CLUBE_2', Space(5) )
			pLTC_APOSTA_04_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_04_CLUBE_1', Space(5) )
			pLTC_APOSTA_04_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_04_CLUBE_2', Space(5) )
			pLTC_APOSTA_05_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_05_CLUBE_1', Space(5) )
			pLTC_APOSTA_05_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_05_CLUBE_2', Space(5) )
			pLTC_APOSTA_06_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_06_CLUBE_1', Space(5) )
			pLTC_APOSTA_06_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_06_CLUBE_2', Space(5) )
			pLTC_APOSTA_07_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_07_CLUBE_1', Space(5) )
			pLTC_APOSTA_07_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_07_CLUBE_2', Space(5) )
			pLTC_APOSTA_08_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_08_CLUBE_1', Space(5) )
			pLTC_APOSTA_08_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_08_CLUBE_2', Space(5) )
			pLTC_APOSTA_09_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_09_CLUBE_1', Space(5) )
			pLTC_APOSTA_09_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_09_CLUBE_2', Space(5) )
			pLTC_APOSTA_10_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_10_CLUBE_1', Space(5) )
			pLTC_APOSTA_10_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_10_CLUBE_2', Space(5) )
			pLTC_APOSTA_11_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_11_CLUBE_1', Space(5) )
			pLTC_APOSTA_11_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_11_CLUBE_2', Space(5) )
			pLTC_APOSTA_12_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_12_CLUBE_1', Space(5) )
			pLTC_APOSTA_12_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_12_CLUBE_2', Space(5) )
			pLTC_APOSTA_13_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_13_CLUBE_1', Space(5) )
			pLTC_APOSTA_13_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_13_CLUBE_2', Space(5) )
			pLTC_APOSTA_14_CLUBE_1 := oIniFile:ReadString( 'LOTECA', 'LTC_14_CLUBE_1', Space(5) )
			pLTC_APOSTA_14_CLUBE_2 := oIniFile:ReadString( 'LOTECA', 'LTC_14_CLUBE_2', Space(5) )

			// Cria o Objeto Windows
			oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 11
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 27
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 12
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 27
			oWindow:Open()

			while lContinua

				aGroup[1]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+ 8, 'Aleatorias' )
				aGroup[1]:ColorSpec := SysFieldBRadioBox()

				aGroup[2]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+28, 'Resultados' )
				aGroup[2]:ColorSpec := SysFieldBRadioBox()

				@ oWindow:nTop+1, oWindow:nLeft+1, ;
					oWindow:nTop+ 3, oWindow:nRight-1 	GET        pLTC_APOSTA_OPCAO                       ;
														RADIOGROUP aGroup                                  ;
														COLOR      SysFieldGRadioBox()

				hb_DispBox( oWindow:nTop+ 4, oWindow:nLeft+ 1, ;
							oWindow:nTop+ 4, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nTop+ 5, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 5, oWindow:nLeft+26 	GET		pLTC_APOSTA_01_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION ' 1-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 5, oWindow:nLeft+31, ;
					oWindow:nTop+ 5, oWindow:nLeft+51	GET		pLTC_APOSTA_01_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+ 6, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 6, oWindow:nLeft+26 	GET		pLTC_APOSTA_02_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION ' 2-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 6, oWindow:nLeft+31, ;
					oWindow:nTop+ 6, oWindow:nLeft+51	GET		pLTC_APOSTA_02_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+ 7, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 7, oWindow:nLeft+26 	GET		pLTC_APOSTA_03_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION ' 3-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 7, oWindow:nLeft+31, ;
					oWindow:nTop+ 7, oWindow:nLeft+51	GET		pLTC_APOSTA_03_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+ 8, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 8, oWindow:nLeft+26 	GET		pLTC_APOSTA_04_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION ' 4-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 8, oWindow:nLeft+31, ;
					oWindow:nTop+ 8, oWindow:nLeft+51	GET		pLTC_APOSTA_04_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+ 9, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 9, oWindow:nLeft+26 	GET		pLTC_APOSTA_05_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION ' 5-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 9, oWindow:nLeft+31, ;
					oWindow:nTop+ 9, oWindow:nLeft+51	GET		pLTC_APOSTA_05_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+10, oWindow:nLeft+ 6, ;
					oWindow:nTop+10, oWindow:nLeft+26 	GET		pLTC_APOSTA_06_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION ' 6-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+10, oWindow:nLeft+31, ;
					oWindow:nTop+10, oWindow:nLeft+51	GET		pLTC_APOSTA_06_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+11, oWindow:nLeft+ 6, ;
					oWindow:nTop+11, oWindow:nLeft+26 	GET		pLTC_APOSTA_07_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION ' 7-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+11, oWindow:nLeft+31, ;
					oWindow:nTop+11, oWindow:nLeft+51	GET		pLTC_APOSTA_07_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+12, oWindow:nLeft+ 6, ;
					oWindow:nTop+12, oWindow:nLeft+26 	GET		pLTC_APOSTA_08_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION ' 8-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+12, oWindow:nLeft+31, ;
					oWindow:nTop+12, oWindow:nLeft+51	GET		pLTC_APOSTA_08_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+13, oWindow:nLeft+ 6, ;
					oWindow:nTop+13, oWindow:nLeft+26 	GET		pLTC_APOSTA_09_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION ' 9-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+13, oWindow:nLeft+31, ;
					oWindow:nTop+13, oWindow:nLeft+51	GET		pLTC_APOSTA_09_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+14, oWindow:nLeft+ 6, ;
					oWindow:nTop+14, oWindow:nLeft+26 	GET		pLTC_APOSTA_10_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION '10-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+14, oWindow:nLeft+31, ;
					oWindow:nTop+14, oWindow:nLeft+51	GET		pLTC_APOSTA_10_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+15, oWindow:nLeft+ 6, ;
					oWindow:nTop+15, oWindow:nLeft+26 	GET		pLTC_APOSTA_11_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION '11-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+15, oWindow:nLeft+31, ;
					oWindow:nTop+15, oWindow:nLeft+51	GET		pLTC_APOSTA_11_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+16, oWindow:nLeft+ 6, ;
					oWindow:nTop+16, oWindow:nLeft+26 	GET		pLTC_APOSTA_12_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION '12-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+16, oWindow:nLeft+31, ;
					oWindow:nTop+16, oWindow:nLeft+51	GET		pLTC_APOSTA_12_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+17, oWindow:nLeft+ 6, ;
					oWindow:nTop+17, oWindow:nLeft+26 	GET		pLTC_APOSTA_13_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION '13-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+17, oWindow:nLeft+31, ;
					oWindow:nTop+17, oWindow:nLeft+51	GET		pLTC_APOSTA_13_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				@ oWindow:nTop+18, oWindow:nLeft+ 6, ;
					oWindow:nTop+18, oWindow:nLeft+26 	GET		pLTC_APOSTA_14_CLUBE_1                     ;
														LISTBOX aClubes                                    ;
														CAPTION '14-'                                      ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+18, oWindow:nLeft+31, ;
					oWindow:nTop+18, oWindow:nLeft+51	GET		pLTC_APOSTA_14_CLUBE_2                     ;
														LISTBOX	aClubes                                    ;
														DROPDOWN                                           ;
														SCROLLBAR                                          ;
														COLOR 	SysFieldListBox()

				hb_DispBox( oWindow:nBottom- 4, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 4, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nBottom- 3, oWindow:nLeft+ 15 GET     pLTC_APOSTA_QUANTIDADE_JOGOS               ;
														PICT    '@EN 99999999999'                          ;
														CAPTION 'Quant.Jogos'                              ;
														COLOR   SysFieldGet()

				@ oWindow:nBottom- 3, oWindow:nLeft+ 36 GET     pLTC_APOSTA_DUPLO                          ;
														PICT    '@EN 99'                                   ;
														CAPTION 'Duplos'                                   ;
														COLOR   SysFieldGet()

				@ oWindow:nBottom- 3, oWindow:nLeft+ 49 GET     pLTC_APOSTA_TRIPLO                         ;
														PICT    '@EN 99'                                   ;
														CAPTION 'Triplos'                                  ;
														COLOR   SysFieldGet()

				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                     ;
														CAPTION ' Con&firma '                              ;
														COLOR   SysPushButton()                            ;
														STYLE   ''                                         ;
														WHEN    pLTC_APOSTA_QUANTIDADE_JOGOS >= 1 .and.    ;
																pLTC_APOSTA_DUPLO >= 1 .and.               ;
																pLTC_APOSTA_DUPLO <= 14 .and.              ;
																pLTC_APOSTA_TRIPLO <= 14 .and.             ;
																.not. Empty( pLTC_APOSTA_01_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_01_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_02_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_02_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_03_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_03_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_04_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_04_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_05_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_05_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_06_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_06_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_07_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_07_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_08_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_08_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_09_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_09_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_10_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_10_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_11_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_11_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_12_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_12_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_13_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_13_CLUBE_2 ) .and. ;
																.not. Empty( pLTC_APOSTA_14_CLUBE_1 ) .and. .not. Empty( pLTC_APOSTA_14_CLUBE_2 )       ;
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

					begin sequence

						// A quantidade de triplos deve ser menor que a quantidade de jogos duplos
						If pLTC_APOSTA_TRIPLO < pLTC_APOSTA_DUPLO

							do case
								case pLTC_APOSTA_OPCAO == 1
									Aleatoria( pLTC_APOSTA_QUANTIDADE_JOGOS, pLTC_APOSTA_DUPLO, pLTC_APOSTA_TRIPLO )

								case pLTC_APOSTA_OPCAO == 1
									Aproveitamento( pLTC_APOSTA_QUANTIDADE_JOGOS, pLTC_APOSTA_DUPLO, pLTC_APOSTA_TRIPLO )

							end case

						Else
							ErrorTable( '803' )  // A quantidade de triplos deve ser menor que a quantidade de jogos duplos
						EndIf

					always
						lContinua := pFALSE
					end sequence

				EndIf

			enddo

		always
			// Atualiza as variaveis do arquivo de confiruacao
			oIniFile:WriteString( 'LOTECA', 'LTC_01_CLUBE_1', pLTC_APOSTA_01_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_01_CLUBE_2', pLTC_APOSTA_01_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_02_CLUBE_1', pLTC_APOSTA_02_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_02_CLUBE_2', pLTC_APOSTA_02_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_03_CLUBE_1', pLTC_APOSTA_03_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_03_CLUBE_2', pLTC_APOSTA_03_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_04_CLUBE_1', pLTC_APOSTA_04_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_04_CLUBE_2', pLTC_APOSTA_04_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_05_CLUBE_1', pLTC_APOSTA_05_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_05_CLUBE_2', pLTC_APOSTA_05_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_06_CLUBE_1', pLTC_APOSTA_06_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_06_CLUBE_2', pLTC_APOSTA_06_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_07_CLUBE_1', pLTC_APOSTA_07_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_07_CLUBE_2', pLTC_APOSTA_07_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_08_CLUBE_1', pLTC_APOSTA_08_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_08_CLUBE_2', pLTC_APOSTA_08_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_09_CLUBE_1', pLTC_APOSTA_09_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_09_CLUBE_2', pLTC_APOSTA_09_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_10_CLUBE_1', pLTC_APOSTA_10_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_10_CLUBE_2', pLTC_APOSTA_10_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_11_CLUBE_1', pLTC_APOSTA_11_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_11_CLUBE_2', pLTC_APOSTA_11_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_12_CLUBE_1', pLTC_APOSTA_12_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_12_CLUBE_2', pLTC_APOSTA_12_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_13_CLUBE_1', pLTC_APOSTA_13_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_13_CLUBE_2', pLTC_APOSTA_13_CLUBE_2 )
			oIniFile:WriteString( 'LOTECA', 'LTC_14_CLUBE_1', pLTC_APOSTA_14_CLUBE_1 )
			oIniFile:WriteString( 'LOTECA', 'LTC_14_CLUBE_2', pLTC_APOSTA_14_CLUBE_2 )
			
			// Atualiza o arquivo de Configuracao
			oIniFile:UpdateFile()

			// Fecha o Objeto Windows
			oWindow:Close()
		end sequence

	Else
		ErrorTable( '802' )  // Nao existem clubes cadastrados.
	EndIf

return


/***
*
*	Aleatoria()
*
*	Realiza a geracao das dezenas para a LOTECA aleatoriamente.
*
*   LTCMntBrowse -> LTCAcoes -> Combina -> Aleatoria
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
*   nQuantDuplo : Quantidade de jogos duplos a ser gerado por cartao
*  nQuantTriplo : Quantidade de jogos triplos a ser gerado por cartao
*
*/
STATIC PROCEDURE Aleatoria( nQuantJogos, nQuantDuplo, nQuantTriplo )

local aFileTmp       := {}
local oHBCabec
local oHBItens
local oError
local lFileTmpCabec  := pTRUE
local lFileTmpItens  := pTRUE
local oBarProgress
local nCorrente      := 1
local hCartao
local cCartao
local cResult
local hTemp
local nCurrentDuplo
local cPartida
local nDuplo
local nCurrentTriplo
local nFound
local aTemp

local cDuplic
local aDuplic


	DEFAULT nQuantJogos TO 1
	DEFAULT nQuantDuplo TO 1
	DEFAULT nQuantTriplo TO 0

	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		//
		// Realiza a criacao do arquivos com os cabecario das apostas
		//
		begin sequence with { |oErr| Break( oErr ) }

			AAdd( aFileTmp, { GetNextFile( SystemTmp() ) } )

			// Cria a tabela utilizando a classe TTable
			oHBCabec := HBTable():CreateTable( ATail( aFileTmp )[1] )

			// Adiciona os campos
			oHBCabec:AddField( 'CAB_CODIGO', 'C', 5, 0 )
			oHBCabec:AddField( 'CAB_MRK',    'C', 1, 0 )

			// Executa a criacao da tabela
			oHBCabec:GenTable()

			oHBCabec := HBTable():New( ATail( aFileTmp )[1], 'CABEC_ALIAS',,, pTRUE,, pTRUE )
			oHBCabec:addOrder( 'CABEC', 'CAB_CODIGO',,,, pTRUE, {|| FIELD->CAB_CODIGO } )
			oHBCabec:Open()
			oHBCabec:Reindex()
			oHBCabec:SetOrder( 'CABEC' )

		recover using oError
			If ( oError:genCode == EG_CREATE ) .or. ;
				( oError:genCode == EG_OPEN ) .or. ;
				( oError:genCode == EG_CORRUPTION )
				lFileTmpCabec := pFALSE
			EndIf
		end sequence

		//
		// Realiza a criacao do arquivos com os itens da aposta
		//
		begin sequence with { |oErr| Break( oErr ) }
		
			AAdd( aFileTmp, { GetNextFile( SystemTmp() ) } )
			
			// Cria a tabela usando a Classe TTable
			oHBItens := HBTable():CreateTable( ATail( aFileTmp )[1] )
			
			oHBItens:AddField( 'ITN_CODIGO', 'C', 5, 0 )
			oHBItens:AddField( 'ITN_FAIXA',  'C', 2, 0 )
			oHBItens:AddField( 'ITN_COL1',   'C', 5, 0 )
			oHBItens:AddField( 'ITN_COL2',   'C', 5, 0 )
			oHBItens:AddField( 'ITN_RESULT', 'C', 5, 0 )
			
			// Executa a criacao da tabela
			oHBItens:Gentable()

			// Abre a Tabela e cria o indice usando a classe TTable
			oHBItens := HBTable():New( ATail( aFileTmp )[1], 'ITENS_ALIAS',,, pTRUE,, pTRUE )
			oHBItens:addOrder( 'ITENS', 'ITN_CODIGO+ITN_FAIXA',,,, pTRUE, {|| FIELD->ITN_CODIGO+FIELD->ITN_FAIXA } )
			oHBItens:Open()
			oHBItens:Reindex()
			oHBItens:SetOrder( 'ITENS' )
		
		recover using oError
			If ( oError:genCode == EG_CREATE ) .or. ;
				( oError:genCode == EG_OPEN ) .or. ;
				( oError:genCode == EG_CORRUPTION )
				lFileTmpItens := pFALSE
			EndIf
		end sequence

		// Identifica se as tabelas foram criadas corretamente para inicio do processamento
		If lFileTmpCabec .and. lFileTmpItens

			begin sequence

				// Inicia o Objeto da Barra de Progresso
				oBarProgress := ProgressBar():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oBarProgress:Open()

				while nCorrente <= nQuantJogos

					// Atualiza a barra de Progresso
					oBarProgress:Update( ( nCorrente / nQuantJogos ) * 100 )

					// Monta o cartao da aposta
					hCartao := Hb_Hash()
					for each cCartao in aLoteca[ pLTC_POS_APOSTA_DADOS ]

						// Define o resultado da partida aleatoria
						
						switch hb_RandomInt( 1, 3 )
							case 1
								cResult := '10000'
							case 2
								cResult := '01000'
							case 3
								cResult := '00100'
						end switch

						hTemp := Hb_Hash()
						hTemp['clube_1'] := cCartao:__enumValue()[1]
						hTemp['clube_2'] := cCartao:__enumValue()[2]
						hTemp['resultado'] := cResult

						hb_Hset( hCartao, Hb_NtoS( cCartao:__enumIndex() ), hTemp )

					next

					// Monta os duplos nos cartoes
					nCurrentDuplo := 1
					while nCurrentDuplo <= pLTC_APOSTA_DUPLO
						cPartida := Hb_NtoS( hb_RandomInt( 1, 14 ) )
						If SubStr( hCartao[ cPartida ]['resultado'], 4, 1 ) != '1'
							nDuplo := hb_RandomInt( 1, 3 )
							If SubStr( hCartao[ cPartida ][ 'resultado' ], nDuplo, 1 ) != '1'
								// Define o resultado do jogo e marca a coluna de duplos
								begin sequence
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], nDuplo, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 4, 1, '1' )
								always
									nCurrentDuplo++
								end sequence
							EndIf
						EndIf
					enddo

					// Monta os triplos nos cartoes
					If pLTC_APOSTA_TRIPLO > 0
						nCurrentTriplo := 1
						while nCurrentTriplo <= pLTC_APOSTA_TRIPLO
							cPartida := Hb_NtoS( hb_RandomInt( 1, 14 ) )
							// Verifica se o concurso ja nao esta marcado como Duplo
							If SubStr( hCartao[ cPartida ][ 'resultado' ], 4, 1 ) != '1'
								// Marca todos os resultados como triplo
								begin sequence
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 1, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 2, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 3, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 4, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 5, 1, '1' )
								always
									nCurrentTriplo++
								end sequence
							EndIf
						enddo
					EndIf

					// Evita a duplicidade de jogos
					begin sequence

						aDuplic := {}
						for each cDuplic in hCartao
							If hb_AScan( aDuplic, cDuplic[ 'resultado' ],,, pTRUE ) == 0
								AAdd( aDuplic, cDuplic[ 'resultado' ] )
							EndIf
						next

					always

						nFound := 0
						oHBCabec:GoTop()
						while nFound < 14 .and. .not. oHBCabec:Eof()

							nFound := 0
							If oHBItens:dbSeek( oHBCabec:CAB_CODIGO )
								while oHBItens:ITN_CODIGO == oHBCabec:CAB_CODIGO .and. ;
									.not. oHBItens:Eof()
									If ( hb_HScan( hCartao, { |nKey,cChave| HB_SYMBOL_UNUSED( nKey ), cChave['resultado'] == oHBItens:ITN_RESULT } ) ) > 0
										nFound++
									EndIf
									oHBItens:dbSkip()
								enddo
							EndIf

							oHBCabec:dbSkip()

						enddo

					end sequence

					// Grava os dados na tabela temporaria
					If nFound < 14

						begin sequence

							If oHBCabec:Append()
								oHBCabec:CAB_CODIGO := StrZero( nCorrente, 5 )

								for each cCartao in hCartao
									If oHBItens:Append()
										oHBItens:ITN_CODIGO := oHBCabec:CAB_CODIGO
										oHBItens:ITN_FAIXA  := StrZero( cCartao:__enumIndex(), 2 )
										oHBItens:ITN_COL1   := cCartao[ 'clube_1' ]
										oHBItens:ITN_COL2   := cCartao[ 'clube_2' ]
										oHBItens:ITN_RESULT := cCartao[ 'resultado' ]
									EndIf
								next

							EndIf

						always
							oHBCabec:BUFWrite()
							oHBItens:BUFWrite()
							nCorrente++
						end sequence

					EndIf

				enddo

			always
				// Fecha o Objeto oBar
				oBarProgress:Close()

				// Verifica se existem dados a serem exibidos
				If .not. oHBCabec:Eof()
					LTCShowAposta( oHBCabec, oHBItens )
				Else
					ErrorTable( '024' )  // Nao existem informacoes a serem exibidas.
				EndIf
			end sequence

		Else
			ErrorTable( '205' )  // Problemas na criacao do arquivo temporario.
		EndIf

	always
		// Fecha o Temporario cabecario de Jogos
		oHBCabec:kill()
			
		// Fecha Temporario de Itens dos Jogos
		oHBItens:kill()

		// Elimina os arquivos temporarios
		for each aTemp in hb_DirScan( hb_DirSepAdd( hb_DirBase() ), oHBCabec:corderBag +'.*' )
			hb_dbDrop( aTemp[ 1 ] )
		next

		for each aTemp in hb_DirScan( hb_DirSepAdd( hb_DirBase() ), oHBItens:corderBag +'.*' )
			hb_dbDrop( aTemp[ 1 ] )
		next

		// Restaura a tabela da Pilha
		DstkPop()
	end sequence

return


/***
*
*	Aproveitamento()
*
*	Realiza a geracao das dezenas para a LOTECA realizando a analise dos clubes nos campeonatos disputados.
*
*   LTCMntBrowse -> LTCAcoes -> Combina -> Aproveitamento
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
*   nQuantDuplo : Quantidade de jogos duplos a ser gerado por cartao
*  nQuantTriplo : Quantidade de jogos triplos a ser gerado por cartao
*
*/
STATIC PROCEDURE Aproveitamento( nQuantJogos, nQuantDuplo, nQuantTriplo )

local aFileTmp       := {}
local oHBCabec
local oHBItens
local oError
local lFileTmpCabec  := pTRUE
local lFileTmpItens  := pTRUE
local oBarProgress
local nCorrente      := 1
local hCartao
local cCartao
local cResult
local hTemp
local nCurrentDuplo
local cPartida
local nDuplo
local nCurrentTriplo
local nFound


	DEFAULT nQuantJogos TO 1
	DEFAULT nQuantDuplo TO 1
	DEFAULT nQuantTriplo TO 0

	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		//
		// Realiza a criacao do arquivos com os cabecario das apostas
		//
		begin sequence with { |oErr| Break( oErr ) }

			AAdd( aFileTmp, { GetNextFile( SystemTmp() ) } )

			// Cria a tabela utilizando a classe TTable
			oHBCabec := HBTable():CreateTable( ATail( aFileTmp )[1] )

			// Adiciona os campos
			oHBCabec:AddField( 'CAB_CODIGO', 'C', 5, 0 )
			oHBCabec:AddField( 'CAB_MRK',    'C', 1, 0 )

			// Executa a criacao da tabela
			oHBCabec:GenTable()

			oHBCabec := HBTable():New( ATail( aFileTmp )[1], 'CABEC_ALIAS',,, pTRUE,, pTRUE )
			oHBCabec:addOrder( 'CABEC', 'CAB_CODIGO',,,, pTRUE, {|| FIELD->CAB_CODIGO } )
			oHBCabec:Open()
			oHBCabec:Reindex()
			oHBCabec:SetOrder( 'CABEC' )

		recover using oError
			If ( oError:genCode == EG_CREATE ) .or. ;
				( oError:genCode == EG_OPEN ) .or. ;
				( oError:genCode == EG_CORRUPTION )
				lFileTmpCabec := pFALSE
			EndIf
		end sequence

		//
		// Realiza a criacao do arquivos com os itens da aposta
		//
		begin sequence with { |oErr| Break( oErr ) }
		
			AAdd( aFileTmp, { GetNextFile( SystemTmp() ) } )
			
			// Cria a tabela usando a Classe TTable
			oHBItens := HBTable():CreateTable( ATail( aFileTmp )[1] )
			
			oHBItens:AddField( 'ITN_CODIGO', 'C', 5, 0 )
			oHBItens:AddField( 'ITN_FAIXA',  'C', 2, 0 )
			oHBItens:AddField( 'ITN_COL1',   'C', 5, 0 )
			oHBItens:AddField( 'ITN_COL2',   'C', 5, 0 )
			oHBItens:AddField( 'ITN_RESULT', 'C', 5, 0 )
			
			// Executa a criacao da tabela
			oHBItens:Gentable()

			// Abre a Tabela e cria o indice usando a classe TTable
			oHBItens := HBTable():New( ATail( aFileTmp )[1], 'ITENS_ALIAS',,, pTRUE,, pTRUE )
			oHBItens:addOrder( 'ITENS', 'ITN_CODIGO+ITN_FAIXA',,,, pTRUE, {|| FIELD->ITN_CODIGO+FIELD->ITN_FAIXA } )
			oHBItens:Open()
			oHBItens:Reindex()
			oHBItens:SetOrder( 'ITENS' )
		
		recover using oError
			If ( oError:genCode == EG_CREATE ) .or. ;
				( oError:genCode == EG_OPEN ) .or. ;
				( oError:genCode == EG_CORRUPTION )
				lFileTmpItens := pFALSE
			EndIf
		end sequence

		// Identifica se as tabelas foram criadas corretamente para inicio do processamento
		If lFileTmpCabec .and. lFileTmpItens

			begin sequence

				// Inicia o Objeto da Barra de Progresso
				oBarProgress := ProgressBar():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oBarProgress:Open()

				while nCorrente <= nQuantJogos

					// Atualiza a barra de Progresso
					oBarProgress:Update( ( nCorrente / nQuantJogos ) * 100 )

					// Monta o cartao da aposta
					hCartao := Hb_Hash()
					for each cCartao in aLoteca[ pLTC_POS_APOSTA_DADOS ]

						// Define o resultado da partida aleatoria
						
						switch hb_RandomInt( 1, 3 )
							case 1
								cResult := '10000'
							case 2
								cResult := '01000'
							case 3
								cResult := '00100'
						end switch

						hTemp := Hb_Hash()
						hTemp['clube_1'] := cCartao:__enumValue()[1]
						hTemp['clube_2'] := cCartao:__enumValue()[2]
						hTemp['resultado'] := cResult

						hb_Hset( hCartao, Hb_NtoS( cCartao:__enumIndex() ), hTemp )

					next

					// Monta os duplos nos cartoes
					nCurrentDuplo := 1
					while nCurrentDuplo <= pLTC_APOSTA_DUPLO
						cPartida := Hb_NtoS( hb_RandomInt( 1, 14 ) )
						If SubStr( hCartao[ cPartida ]['resultado'], 4, 1 ) != '1'
							nDuplo := hb_RandomInt( 1, 3 )
							If SubStr( hCartao[ cPartida ][ 'resultado' ], nDuplo, 1 ) != '1'
								// Define o resultado do jogo e marca a coluna de duplos
								begin sequence
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], nDuplo, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 4, 1, '1' )
								always
									nCurrentDuplo++
								end sequence
							EndIf
						EndIf
					enddo

					// Monta os triplos nos cartoes
					If pLTC_APOSTA_TRIPLO > 0
						nCurrentTriplo := 1
						while nCurrentTriplo <= pLTC_APOSTA_TRIPLO
							cPartida := Hb_NtoS( hb_RandomInt( 1, 14 ) )
							// Verifica se o concurso ja nao esta marcado como Duplo
							If SubStr( hCartao[ cPartida ][ 'resultado' ], 4, 1 ) != '1'
								// Marca todos os resultados como triplo
								begin sequence
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 1, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 2, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 3, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 4, 1, '1' )
									hCartao[ cPartida ][ 'resultado' ] := Stuff( hCartao[ cPartida ][ 'resultado' ], 5, 1, '1' )
								always
									nCurrentTriplo++
								end sequence
							EndIf
						enddo
					EndIf

					// Evita a duplicidade de jogos
					nFound := 0
					oHBCabec:GoTop()
					while nFound < 14 .and. .not. oHBCabec:Eof()

						nFound := 0
						If oHBItens:dbSeek( oHBCabec:CAB_CODIGO )
							while oHBItens:ITN_CODIGO == oHBCabec:CAB_CODIGO .and. ;
								.not. oHBItens:Eof()
								Eval({ |nKey,cChave| setpos( 10, 20 ), dispout( valtype( nkey ) ), dispout( cChave ) }, hCartao )
								If ( nteste := hb_HScan( hCartao, { |nKey,cChave| HB_SYMBOL_UNUSED( nKey ), cChave['resultado'] == oHBItens:ITN_RESULT } ) ) > 0
									nFound++
								EndIf
								oHBItens:dbSkip()
							enddo
						EndIf

						oHBCabec:dbSkip()

					enddo

					// Grava os dados na tabela temporaria
					If nFound < 14

						begin sequence

							If oHBCabec:Append()
								oHBCabec:CAB_CODIGO := StrZero( nCorrente, 5 )

								for each cCartao in hCartao
									If oHBItens:Append()
										oHBItens:ITN_CODIGO := oHBCabec:CAB_CODIGO
										oHBItens:ITN_FAIXA  := StrZero( cCartao:__enumIndex(), 2 )
										oHBItens:ITN_COL1   := cCartao[ 'clube_1' ]
										oHBItens:ITN_COL2   := cCartao[ 'clube_2' ]
										oHBItens:ITN_RESULT := cCartao[ 'resultado' ]
									EndIf
								next

							EndIf

						always
							oHBCabec:BUFWrite()
							oHBItens:BUFWrite()
							nCorrente++
						end sequence

					EndIf

				enddo

			always
				// Fecha o Objeto oBar
				oBarProgress:Close()

				// Verifica se existem dados a serem exibidos
				If .not. oHBCabec:Eof()
					LTCShowAposta( oHBCabec, oHBItens )
				Else
					ErrorTable( '024' )  // Nao existem informacoes a serem exibidas.
				EndIf
			end sequence

		Else
			ErrorTable( '205' )  // Problemas na criacao do arquivo temporario.
		EndIf

	always
		// Fecha o Temporario cabecario de Jogos
		oHBCabec:kill()
			
		// Fecha Temporario de Itens dos Jogos
		oHBItens:kill()
		
		// Elimina os arquivos temporarios.
		AEval( aFileTmp, { |xItem| FErase( xItem[1] ), FErase( xItem[2] ) } )

		// Restaura a tabela da Pilha
		DstkPop()
	end sequence

return


/***
*
*	LTCShowAposta()
*
*	Exibe as apostas gerados no arquivo Temporario.
*
*   LTCMntBrowse -> LTCAcoes -> Combina -> Aleatoria
*                                       -> Aproveitamento -> LTCShowAposta
*
*/
STATIC PROCEDURE LTCShowAposta( oHBCabec, oHBItens )

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

local bFilPartida
local oPartida

local aSelDezenas   := {}
local nRow          := 1
local nPointer
local nPosDezenas   := 1
	

	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		// Cria o Objeto Windows
		oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 15
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 28
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 15
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 28
		oWindow:cHeader := PadC( 'Apostas Geradas', Len( 'Apostas Geradas' ) + 2, ' ')
		oWindow:Open()

		// Desenha a Linha de Botoes
		hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
					oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

		// Estabelece o Filtro para exibicao dos registros
		bFiltro := { || .not. oHBCabec:Eof() }

		oHBCabec:SetFocus()
		oHBCabec:dbEval( {|| nMaxItens++ }, bFiltro )
		oHBCabec:goTop()

		begin sequence

			// Exibe o Browse com as Apostas
			oBrowse               	:= 	TBrowseDB( oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
													oWindow:nBottom-20, oWindow:nRight- 1 )
			oBrowse:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := (oHBCabec:Alias)->( DBSkipper( xSkip, bFiltro ) ) ) <> 0, ( nCount += xRecno, xRecno ), xRecno ) }
			oBrowse:goTopBlock    	:= 	{ || nCount := 1, (oHBCabec:Alias)->( GoTopDB( bFiltro ) ) }
			oBrowse:goBottomBlock 	:= 	{ || nCount := nMaxItens, (oHBCabec:Alias)->( GoBottomDB( bFiltro ) ) }
			oBrowse:colorSpec     	:= SysBrowseColor()
			oBrowse:headSep       	:= Chr(205)
			oBrowse:colSep        	:= Chr(179)
			oBrowse:Cargo         	:= {}

			// Adiciona as Colunas
			oColumn 			:= TBColumnNew( '',                   { || oHBCabec:CAB_MRK } )
			oColumn:picture 	:= '@!'
			oColumn:width   	:= 1
			oColumn:colSep      := Chr(179)
			oBrowse:addColumn( oColumn )

			oColumn 			:= TBColumnNew( PadC( 'Codigo', 8 ),  { || oHBCabec:CAB_CODIGO } )
			oColumn:picture 	:= '@!'
			oColumn:width   	:= 8
			oColumn:colSep      := Chr(179)
			oBrowse:addColumn( oColumn )

			// Monta a browse com os clubes da competicao
			begin sequence

				// Desenha a Linha de dividindo as aapostas dos Cartoes
				hb_DispBox( oWindow:nBottom-19, oWindow:nLeft+ 1, ;
							oWindow:nBottom-19, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )	

				// Estabelece o Filtro para exibicao dos registros
				bFilPartida := { || oHBCabec:CAB_CODIGO == oHBItens:ITN_CODIGO .and. .not. oHBItens:Eof() }

				oPartida               := TBrowseDB( oWindow:nBottom-18, oWindow:nLeft+ 1,   ;
														oWindow:nBottom- 3, oWindow:nRight- 1 )
				oPartida:skipBlock     := { |xSkip,xRecno| iif( ( xRecno := (oHBItens:Alias)->( DBSkipper( xSkip, bFilPartida ) ) ) <> 0, ( nCount += xRecno, xRecno ), xRecno ) }
				oPartida:goTopBlock    := { || nCount := 1, (oHBItens:Alias)->( GoTopDB( bFilPartida ) ) }
				oPartida:goBottomBlock := { || nCount := nMaxItens, (oHBItens:Alias)->( GoBottomDB( bFilPartida ) ) }
				oPartida:colorSpec     := SysBrowseColor()
				oPartida:headSep       := Chr(205)
				oPartida:colSep        := Chr(179)
				oPartida:autoLite      := pFALSE

				oColumn            := TBColumnNew( '',                      { || oHBItens:ITN_FAIXA } )
				oColumn:picture    := '@!'
				oColumn:width      := 02
				oPartida:addColumn( oColumn )

				oColumn            := TBColumnNew( PadC( 'Coluna 1', 20 ),  {|| PadL( iif( CLUBES->( dbSetOrder(1), dbSeek( oHBItens:ITN_COL1 ) ),  ;
																				AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), '' ), 20 ) } )
				oColumn:picture    := '@!'
				oColumn:width      := 20
				oPartida:addColumn( oColumn )

				oColumn            := TBColumnNew( '1',                     {|| iif( SubStr( oHBItens:ITN_RESULT, 1, 1 ) == '1', 'X', '' ) } )
				oColumn:picture    := '@!'
				oColumn:width      := 1
				oPartida:addColumn( oColumn )

				oColumn            := TBColumnNew( 'X',                     {|| iif( SubStr( oHBItens:ITN_RESULT, 2, 1 ) == '1', 'X', '' ) } )
				oColumn:picture    := '@!'
				oColumn:width      := 1
				oPartida:addColumn( oColumn )

				oColumn            := TBColumnNew( '2',                     {|| iif( SubStr( oHBItens:ITN_RESULT, 3, 1 ) == '1', 'X', '' ) } )
				oColumn:picture    := '@!'
				oColumn:width      := 1
				oPartida:addColumn( oColumn )

				oColumn            := TBColumnNew( PadC( 'Coluna 2', 20 ),  {|| PadR( iif( CLUBES->( dbSetOrder(1), dbSeek( oHBItens:ITN_COL2 ) ), ;
																				AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), '' ), 20 ) } )
				oColumn:picture    := '@!'
				oColumn:width      := 20
				oPartida:addColumn( oColumn )

				oColumn            := TBColumnNew( 'D',                     {|| iif( SubStr( oHBItens:ITN_RESULT, 4, 1 ) == '1', 'X', '' ) } )
				oColumn:picture    := '@!'
				oColumn:width      := 1
				oPartida:addColumn( oColumn )

				oColumn            := TBColumnNew( 'T',                     {|| iif( SubStr( oHBItens:ITN_RESULT, 5, 1 ) == '1', 'X', '' ) } )
				oColumn:picture    := '@!'
				oColumn:width      := 1
				oPartida:addColumn( oColumn )

			always
				oBrowse:forceStable()
				oPartida:forceStable()
			end sequence

			// Realiza a Montagem da Barra de Rolagem
			oScrollBar           := ScrollBar( oWindow:nTop+ 3, oWindow:nBottom- 3, oWindow:nRight )
			oScrollBar:colorSpec := SysScrollBar()
			oScrollBar:display()

			// Desenha os botoes da tela
			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
//			oTmpButton:sBlock    := { || Incluir() }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
//			oTmpButton:sBlock    := { || Modificar() }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' &Excluir ' )
//			oTmpButton:sBlock    := { || Excluir() }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Gr&upos ' )
//			oTmpButton:sBlock    := { || Grupos() }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AADD( oBrowse:Cargo, { oTmpButton, UPPER( SubStr( oTmpButton:Caption, AT('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+43, ' A&postas ' )
//			oTmpButton:sBlock    := { || Apostas() }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+53, ' Ac&oes ' )
//			oTmpButton:sBlock    := { || Acoes() }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+61, ' &Sair ' )
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
				If oHBItens:dbSeek( oHBCabec:CAB_CODIGO )
					DispBegin()
					oPartida:refreshAll()
					oPartida:forceStable()
					DispEnd()
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
local bFiltro      := { || CONCURSO->CON_JOGO == pLOTECA .and. .not. CONCURSO->( Eof() ) }
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
					If CONCURSO->( dbSetOrder(1), dbSeek( pLOTECA + cInicio ) ) .and. ;
						CONCURSO->( dbSetOrder(1), dbSeek( pLOTECA + cFinal ) )

						bFiltro := { || CONCURSO->CON_JOGO == pLOTECA .and. .not. CONCURSO->( Eof() ) .and. ;
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
 