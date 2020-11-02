/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  lotogol.prg
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
#include 'lotogol.ch'
#include 'dbfunc.ch'
#include 'main.ch'

static aLotogol

memvar GetList

/***
*
*	LTGMntBrowse()
*
*	Exibe a relacao de concursos ja realizados.
*
*/
PROCEDURE LTGMntBrowse()

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

local bFilConcurso  := { || CONCURSO->CON_JOGO == pLOTOGOL .and. .not. ;
							CONCURSO->( Eof() ) }
local bFilPartidas  := { ||	JOGOS->JOG_JOGO == CONCURSO->CON_JOGO .and. ;
							JOGOS->JOG_CONCUR == CONCURSO->CON_CONCUR .and. .not.  ;
							JOGOS->( Eof() ) }
local aSelDezenas   := {}
local nRow          := 1
local nPointer
local nPosDezenas   := 1


	If SystemConcurso() == pLOTOGOL

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTOGOL } ) ) > 0

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
				CONCURSO->( dbSetOrder(2), dbSeek( pLOTOGOL ) )

				begin sequence

					// Cria o Browse com os consursos cadastrados
					oBrwConcurso           		:= 	TBrowseDB( 	oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
																oWindow:nBottom-11, oWindow:nRight- 1 )
					oBrwConcurso:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFilConcurso ) ) <> 0, ( nCount += xRecno, xRecno ), xRecno ) }
					oBrwConcurso:goTopBlock    	:= 	{ || nCount := 1, GoTopDB( bFilConcurso ) }
					oBrwConcurso:goBottomBlock	:= 	{ || nCount := nMaxItens, GoBottomDB( bFilConcurso ) }
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

					hb_DispBox( oWindow:nBottom-10, oWindow:nLeft+ 1, ;
								oWindow:nBottom-10, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )


					// Cria o Browse com as partidas
					oBrwPartidas               	:= 	TBrowseNew(	oWindow:nBottom- 9, oWindow:nLeft+ 1, ;
																oWindow:nBottom- 3, oWindow:nRight- 1 )
					oBrwPartidas:skipBlock     	:=	{ |xSkip| JOGOS->( DBSkipper( xSkip, bFilPartidas ) ) }
					oBrwPartidas:goTopBlock    	:= 	{ || JOGOS->( GoTopDB( bFilPartidas ) ) }
					oBrwPartidas:goBottomBlock 	:= 	{ || JOGOS->( GoBottomDB( bFilPartidas ) ) }
					oBrwPartidas:colorSpec     	:= 	SysBrowseColor()
					oBrwPartidas:headSep        := 	Chr(205)
					oBrwPartidas:colSep         := 	Chr(179)
					oBrwPartidas:autoLite       := 	pFALSE

					
					oColumn            := TBColumnNew( "",                      { || JOGOS->JOG_FAIXA } )
					oColumn:picture    := "@!"
					oColumn:width      := 02
					oBrwPartidas:addColumn( oColumn )
					
					oColumn            := TBColumnNew( PadC( "Coluna 1", 20 ),  {|| PadL( iif( CLUBES->( dbSetOrder(1), dbSeek( JOGOS->JOG_COL_01 ) ),            ;
																								AllTrim( CLUBES->CLU_ABREVI ) + "/" + ALLTRIM( CLUBES->CLU_UF ), ;
																								"" ), 20 ) }                                                     )
					oColumn:picture    := "@!"
					oColumn:width      := 20
					oBrwPartidas:addColumn( oColumn )
					
					oColumn            := TBColumnNew( "",                      {|| JOGOS->JOG_PON_01 } )
					oColumn:picture    := "@!"
					oColumn:width      := 2
					oBrwPartidas:addColumn( oColumn )
					
					oColumn            := TBColumnNew( "",                      {|| JOGOS->JOG_PON_02 } )
					oColumn:picture    := "@!"
					oColumn:width      := 2
					oBrwPartidas:addColumn( oColumn )
					
					oColumn            := TBColumnNew( PadC( "Coluna 2", 20 ),  {|| PadR( iif( CLUBES->( dbSetOrder(1), dbSeek( JOGOS->JOG_COL_02 ) ),            ;
																								AllTrim( CLUBES->CLU_ABREVI ) + "/" + ALLTRIM( CLUBES->CLU_UF ), ;
																								"" ), 20 ) }                                                     )
					oColumn:picture    := "@!"
					oColumn:width      := 20
					oBrwPartidas:addColumn( oColumn )



					// Realiza a Montagem da Barra de Rolagem
					oScrollBar           := ScrollBar( oWindow:nTop+ 3, oWindow:nBottom-11, oWindow:nRight )
					oScrollBar:colorSpec := SysScrollBar()
					oScrollBar:display()


					// Desenha os botoes da tela
					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
					oTmpButton:sBlock    := { || LTGIncluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwConcurso:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
					oTmpButton:sBlock    := { || LTGModificar() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwConcurso:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' &Excluir ' )
					oTmpButton:sBlock    := { || LTGExcluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrwConcurso:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Ac&oes ' )
					oTmpButton:sBlock    := { || LTGAcoes() }
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
                        oBrwConcurso:colorRect( { oBrwConcurso:rowPos, 1, oBrwConcurso:rowPos, oBrwConcurso:colCount}, { 1, 2})
						oBrwConcurso:forceStable()
						oBrwConcurso:colorRect( { oBrwConcurso:rowPos, oBrwConcurso:freeze + 1, oBrwConcurso:rowPos, oBrwConcurso:colCount}, { 8, 2})
						oBrwConcurso:hilite()

                        // Atualiza a barra de rolagem
						oScrollBar:current := nCount * ( 100 / nMaxItens )
                        oScrollBar:update()

                        // Atualiza a grade com as dezenas dos jogos
                        If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
                            If Len( aSelDezenas := ParseDezenas( JOGOS->JOG_DEZENA ) ) > 0
                                oBrwPartidas:refreshAll()
                                oBrwPartidas:forceStable()
                            EndIf
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
									if MRow() >= oBrwConcurso:nTop .and. MRow() <= oBrwConcurso:nBottom .and. ;
										Mcol() >= oBrwConcurso:nTop .and. Mcol() <= oBrwConcurso:nRight
										oBrwConcurso:up()
									EndIf

								case nKey == K_MWBACKWARD
									if MRow() >= oBrwConcurso:nTop .and. MRow() <= oBrwConcurso:nBottom .and. ;
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
*	LTGIncluir()
*
*	Realiza a inclusao dos dados para o concurso da LOTOGOL.
*
*   LTGMntBrowse -> LTGIncluir
*
*/
STATIC PROCEDURE LTGIncluir

local aClubes
local nPointer
local lContinua     := pTRUE
local lPushButton
local oWindow
local nCodigo       := 1
local cAutoSequence
local oIniFile
local aGroup        := Array(5)

memvar xCount, xTemp


	If SystemConcurso() == pLOTOGOL

		If Len( aClubes := LoadClubes() ) > 0	

			If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTOGOL } ) ) > 0

				begin sequence
				
					// Salva a Area corrente na Pilha
					DstkPush()
					
					// Inicializa as Variaveis de Dados
					xInitLotogol
					
					// Inicializa as Variaveis de no vetor aLotogol
					xStoreLotogol
					
					//
					// Realiza a abertura do arquivo INI
					//
					oIniFile := TIniFile():New( 'odin.ini' )
					
					//
					// Parametro para definir a sequencia automatica
					//
					If ( cAutoSequence := oIniFile:ReadString( 'LOTOGOL', 'AUTO_SEQUENCE', '0' ) ) == '1'
						// Define o codigo sequencial
						dbEval( { || nCodigo++ }, { || CONCURSO->CON_JOGO == pLOTOGOL .and. CONCURSO->( .not. Eof() ) } )
						pLTG_CONCURSO := StrZero( nCodigo, 5 )
					EndIf

					// Realiza a leitura dos dados do arquivo de configuracao
					pLTG_PARTIDA_01_CLUBE_1 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_01_CLUBE_1', Space(5) )
					pLTG_PARTIDA_01_CLUBE_2 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_01_CLUBE_2', Space(5) )
					pLTG_PARTIDA_02_CLUBE_1 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_02_CLUBE_1', Space(5) )
					pLTG_PARTIDA_02_CLUBE_2 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_02_CLUBE_2', Space(5) )
					pLTG_PARTIDA_03_CLUBE_1 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_03_CLUBE_1', Space(5) )
					pLTG_PARTIDA_03_CLUBE_2 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_03_CLUBE_2', Space(5) )
					pLTG_PARTIDA_04_CLUBE_1 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_04_CLUBE_1', Space(5) )
					pLTG_PARTIDA_04_CLUBE_2 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_04_CLUBE_2', Space(5) )
					pLTG_PARTIDA_05_CLUBE_1 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_05_CLUBE_1', Space(5) )
					pLTG_PARTIDA_05_CLUBE_2 := oIniFile:ReadString( 'LOTOGOL', 'LTG_PARTIDA_05_CLUBE_2', Space(5) )
					
					
					// Cria o Objeto Windows
					oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
					oWindow:nTop    := INT( SystemMaxRow() / 2 ) - 14
					oWindow:nLeft   := INT( SystemMaxCol() / 2 ) - 30
					oWindow:nBottom := INT( SystemMaxRow() / 2 ) + 15
					oWindow:nRight  := INT( SystemMaxCol() / 2 ) + 30
					oWindow:Open()
					
					WHILE lContinua
						
						@ oWindow:nTop+ 1, oWindow:nLeft+14 GET     pLTG_CONCURSO                                  ;
															PICT    '@K 99999'                                     ;
															SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),5));
															CAPTION 'Concurso'                                     ;
															COLOR   SysFieldGet()
						
						@ oWindow:nTop+ 1, oWindow:nLeft+40 GET     pLTG_SORTEIO                                   ;
															PICT    '@KD 99/99/99'                                 ;
															CAPTION 'Sorteio'                                      ;
															COLOR   SysFieldGet()
						
						hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
									oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )


						// Primeira Partida
						@ oWindow:nTop+ 3, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 3, oWindow:nLeft+26 	GET		pLTG_PARTIDA_01_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 1 -'                                     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+ 4, oWindow:nLeft+28, ;
							oWindow:nTop+ 4, oWindow:nRight- 1	GET			pLTG_PARTIDA_01_RESULTADO_1            ;
																RADIOGROUP	aGroup                                 ;
																COLOR		SysFieldGRadioBox()

						@ oWindow:nTop+ 5, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 5, oWindow:nLeft+26 	GET		pLTG_PARTIDA_01_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+ 4, oWindow:nLeft+28, ;
							oWindow:nTop+ 4, oWindow:nRight- 1	GET        	pLTG_PARTIDA_01_RESULTADO_2            ;
																RADIOGROUP	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						hb_DispBox( oWindow:nTop+ 6, oWindow:nLeft+ 1, ;
									oWindow:nTop+ 6, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )


						// Segunda Partida
						@ oWindow:nTop+ 7, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 7, oWindow:nLeft+26	 GET		pLTG_PARTIDA_02_CLUBE_1                ;
																LISTBOX aClubes                                    ;
																CAPTION ' 2 -'                                     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+ 8, oWindow:nLeft+28, ;
							oWindow:nTop+ 8, oWindow:nRight- 1	GET			pLTG_PARTIDA_02_RESULTADO_1            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						@ oWindow:nTop+ 9, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 9, oWindow:nLeft+26 	GET		pLTG_PARTIDA_02_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+ 8, oWindow:nLeft+28, ;
							oWindow:nTop+ 8, oWindow:nRight- 1	GET			pLTG_PARTIDA_02_RESULTADO_2            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						hb_DispBox( oWindow:nTop+10, oWindow:nLeft+ 1, ;
									oWindow:nTop+10, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )


						// Terceira Partida
						@ oWindow:nTop+11, oWindow:nLeft+ 6, ;
							oWindow:nTop+11, oWindow:nLeft+26	GET		pLTG_PARTIDA_03_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 3 -'                                     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+12, oWindow:nLeft+28, ;
							oWindow:nTop+12, oWindow:nRight- 1 	GET        	pLTG_PARTIDA_03_RESULTADO_1            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						@ oWindow:nTop+13, oWindow:nLeft+ 6, ;
							oWindow:nTop+13, oWindow:nLeft+26 	GET		pLTG_PARTIDA_03_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+12, oWindow:nLeft+28, ;
							oWindow:nTop+12, oWindow:nRight- 1 	GET			pLTG_PARTIDA_03_RESULTADO_2            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						hb_DispBox( oWindow:nTop+14, oWindow:nLeft+ 1, ;
									oWindow:nTop+14, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )


						// Quarta Partida
						@ oWindow:nTop+15, oWindow:nLeft+ 6, ;
							oWindow:nTop+15, oWindow:nLeft+26 	GET		pLTG_PARTIDA_04_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 4 -'                                     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+16, oWindow:nLeft+28, ;
							oWindow:nTop+16, oWindow:nRight- 1 	GET      	pLTG_PARTIDA_04_RESULTADO_1             ;
																RADIOGROUP  aGroup                                  ;
																COLOR       SysFieldGRadioBox()

						@ oWindow:nTop+17, oWindow:nLeft+ 6, ;
							oWindow:nTop+17, oWindow:nLeft+26 	GET		pLTG_PARTIDA_04_CLUBE_2                     ;
																LISTBOX aClubes                                     ;
																DROPDOWN                                            ;
																SCROLLBAR                                           ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+16, oWindow:nLeft+28, ;
							oWindow:nTop+16, oWindow:nRight- 1 	GET        	pLTG_PARTIDA_04_RESULTADO_2            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()
											
						hb_DispBox( oWindow:nTop+18, oWindow:nLeft+ 1, ;
									oWindow:nTop+18, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )


						// Quinta Partida
						@ oWindow:nTop+19, oWindow:nLeft+ 6, ;
							oWindow:nTop+19, oWindow:nLeft+26 	GET		pLTG_PARTIDA_05_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 5 -'                                     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
															
						@ oWindow:nTop+20, oWindow:nLeft+28, ;
							oWindow:nTop+20, oWindow:nRight- 1 	GET        	pLTG_PARTIDA_05_RESULTADO_1            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						@ oWindow:nTop+21, oWindow:nLeft+ 6, ;
							oWindow:nTop+21, oWindow:nLeft+26 	GET		pLTG_PARTIDA_05_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()

						@ oWindow:nTop+20, oWindow:nLeft+28, ;
							oWindow:nTop+20, oWindow:nRight- 1 	GET        	pLTG_PARTIDA_05_RESULTADO_2            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()


						hb_DispBox( oWindow:nTop+22, oWindow:nLeft+ 1, ;
									oWindow:nTop+22, oWindow:nRight -1, oWindow:cBorder, SystemFormColor() )
						hb_DispOutAt( oWindow:nTop+22, oWindow:nLeft+ 2, ' Rateio ', SystemLabelColor() )
						
						@ oWindow:nTop+23, oWindow:nLeft+12 SAY   'Ganhadores'                                     ;
															COLOR SystemLabelColor()

						@ oWindow:nTop+23, oWindow:nLeft+40 SAY   'Premio'                                         ;
															COLOR SystemLabelColor()


						// Coluna de Acertos			
						@ oWindow:nTop+24, oWindow:nLeft+16 GET     pLTG_RATEIO_ACERTO_05                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '5 Acertos'                                    ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pLTG_SORTEIO )

						@ oWindow:nTop+25, oWindow:nLeft+16 GET     pLTG_RATEIO_ACERTO_04                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '4 Acertos'                                    ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pLTG_SORTEIO )

						@ oWindow:nTop+26, oWindow:nLeft+16 GET     pLTG_RATEIO_ACERTO_03                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '3 Acertos'                                    ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pLTG_SORTEIO )


						// Coluna de Premios			
						@ oWindow:nTop+24, oWindow:nLeft+35 GET   pLTG_RATEIO_PREMIO_05                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pLTG_SORTEIO )
															
						@ oWindow:nTop+25, oWindow:nLeft+35 GET   pLTG_RATEIO_PREMIO_04                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pLTG_SORTEIO )

						@ oWindow:nTop+26, oWindow:nLeft+35 GET   pLTG_RATEIO_PREMIO_03                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pLTG_SORTEIO )

						
						hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
									oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
						
						@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                     ;
																CAPTION ' Con&firma '                              ;
																COLOR   SysPushButton()                            ;
																STYLE   ''                                         ;
																WHEN    Val( pLTG_CONCURSO ) > 0 .and.             ;
																		.not. Empty( pLTG_SORTEIO ) .and.          ;
																		.not. Empty( pLTG_PARTIDA_01_CLUBE_1 ) .and. .not. Empty( pLTG_PARTIDA_01_CLUBE_2 ) .and. ;
																		.not. Empty( pLTG_PARTIDA_02_CLUBE_1 ) .and. .not. Empty( pLTG_PARTIDA_02_CLUBE_2 ) .and. ;
																		.not. Empty( pLTG_PARTIDA_03_CLUBE_1 ) .and. .not. Empty( pLTG_PARTIDA_03_CLUBE_2 ) .and. ;
																		.not. Empty( pLTG_PARTIDA_04_CLUBE_1 ) .and. .not. Empty( pLTG_PARTIDA_04_CLUBE_2 ) .and. ;
																		.not. Empty( pLTG_PARTIDA_05_CLUBE_1 ) .and. .not. Empty( pLTG_PARTIDA_05_CLUBE_2 )       ;
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
							
							pLTG_CONCURSO := StrZero( Val( pLTG_CONCURSO ), 5 )
							
							//************************************************************************
							//*Verifica se concurso ja existe                                        *
							//************************************************************************
							If .not. CONCURSO->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO ) )
								
								If LTGGravaDados()
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
					oIniFile:WriteString( 'LOTOGOL', 'AUTO_SEQUENCE', cAutoSequence )

					// Atualiza as variaveis do arquivo de confiruacao
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_01_CLUBE_1', pLTG_PARTIDA_01_CLUBE_1 )
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_01_CLUBE_2', pLTG_PARTIDA_01_CLUBE_2 )
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_02_CLUBE_1', pLTG_PARTIDA_02_CLUBE_1 )
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_02_CLUBE_2', pLTG_PARTIDA_02_CLUBE_2 )
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_03_CLUBE_1', pLTG_PARTIDA_03_CLUBE_1 )
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_03_CLUBE_2', pLTG_PARTIDA_03_CLUBE_2 )
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_04_CLUBE_1', pLTG_PARTIDA_04_CLUBE_1 )
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_04_CLUBE_2', pLTG_PARTIDA_04_CLUBE_2 )
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_05_CLUBE_1', pLTG_PARTIDA_05_CLUBE_1 )
					oIniFile:WriteString( 'LOTOGOL', 'LTG_PARTIDA_05_CLUBE_2', pLTG_PARTIDA_05_CLUBE_2 )
					
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
*	LTGModificar()
*
*	Realiza a manutencao dos dados para o concurso da LOTOGOL.
*
*   LTGMntBrowse -> LTGModificar
*
*/
STATIC PROCEDURE LTGModificar

local aClubes
local nPointer
local lContinua   := pTRUE
local lPushButton
local oWindow
local aGroup     := Array(5)

memvar xCount, xTemp


	//************************************************************************
	// A rotina so deve ser executada a partir de concurso LOTOGOL
	//************************************************************************
	If CONCURSO->CON_JOGO == pLOTOGOL

		If Len( aClubes := LoadClubes() ) > 0			

			If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTOGOL } ) ) > 0
			
				begin sequence
				
					// Salva a Area corrente na Pilha
					DstkPush()
					
					// Inicializa o vetor aLotogol
					xInitLotogol
					
					// Inicializa as Variaveis de no vetor aLotogol
					xStoreLotogol
					
					//
					// Atualiza a variaveis com o registro selecionado
					//
					pLTG_CONCURSO := CONCURSO->CON_CONCUR
					pLTG_SORTEIO  := CONCURSO->CON_SORTEI
					
					
					//************************************************************************
					//*Carrega o Concurso Selecionado                                        *
					//************************************************************************
					If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
						WHILE JOGOS->JOG_JOGO == CONCURSO->CON_JOGO .and. ;
							JOGOS->JOG_CONCUR == CONCURSO->CON_CONCUR .and. .not. ;
							JOGOS->( Eof() )
							do case
								case JOGOS->JOG_FAIXA == "01"
									pLTG_PARTIDA_01_CLUBE_1     := JOGOS->JOG_COL_01
									pLTG_PARTIDA_01_RESULTADO_1 := pxLTGRead( JOGOS->JOG_PON_01 )
									pLTG_PARTIDA_01_CLUBE_2     := JOGOS->JOG_COL_02
									pLTG_PARTIDA_01_RESULTADO_2 := pxLTGRead( JOGOS->JOG_PON_02 )
								case JOGOS->JOG_FAIXA == "02"
									pLTG_PARTIDA_02_CLUBE_1     := JOGOS->JOG_COL_01
									pLTG_PARTIDA_02_RESULTADO_1 := pxLTGRead( JOGOS->JOG_PON_01 )
									pLTG_PARTIDA_02_CLUBE_2     := JOGOS->JOG_COL_02
									pLTG_PARTIDA_02_RESULTADO_2 := pxLTGRead( JOGOS->JOG_PON_02 )
								case JOGOS->JOG_FAIXA == "03"
									pLTG_PARTIDA_03_CLUBE_1     := JOGOS->JOG_COL_01
									pLTG_PARTIDA_03_RESULTADO_1 := pxLTGRead( JOGOS->JOG_PON_01 )
									pLTG_PARTIDA_03_CLUBE_2     := JOGOS->JOG_COL_02
									pLTG_PARTIDA_03_RESULTADO_2 := pxLTGRead( JOGOS->JOG_PON_02 )
								case JOGOS->JOG_FAIXA == "04"
									pLTG_PARTIDA_04_CLUBE_1     := JOGOS->JOG_COL_01
									pLTG_PARTIDA_04_RESULTADO_1 := pxLTGRead( JOGOS->JOG_PON_01 )
									pLTG_PARTIDA_04_CLUBE_2     := JOGOS->JOG_COL_02
									pLTG_PARTIDA_04_RESULTADO_2 := pxLTGRead( JOGOS->JOG_PON_02 )
								case JOGOS->JOG_FAIXA == "05"
									pLTG_PARTIDA_05_CLUBE_1     := JOGOS->JOG_COL_01
									pLTG_PARTIDA_05_RESULTADO_1 := pxLTGRead( JOGOS->JOG_PON_01 )
									pLTG_PARTIDA_05_CLUBE_2     := JOGOS->JOG_COL_02
									pLTG_PARTIDA_05_RESULTADO_2 := pxLTGRead( JOGOS->JOG_PON_02 )
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
								case RATEIO->RAT_FAIXA == "03"
									pLTG_RATEIO_ACERTO_03 := RATEIO->RAT_ACERTA
									pLTG_RATEIO_PREMIO_03 := RATEIO->RAT_RATEIO
								case RATEIO->RAT_FAIXA == "04"
									pLTG_RATEIO_ACERTO_04 := RATEIO->RAT_ACERTA
									pLTG_RATEIO_PREMIO_04 := RATEIO->RAT_RATEIO
								case RATEIO->RAT_FAIXA == "05"
									pLTG_RATEIO_ACERTO_05 := RATEIO->RAT_ACERTA
									pLTG_RATEIO_PREMIO_05 := RATEIO->RAT_RATEIO
							endcase
							RATEIO->( dbSkip() )
						enddo
					EndIf


					// Cria o Objeto Windows
					oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
					oWindow:nTop    := INT( SystemMaxRow() / 2 ) - 14
					oWindow:nLeft   := INT( SystemMaxCol() / 2 ) - 30
					oWindow:nBottom := INT( SystemMaxRow() / 2 ) + 15
					oWindow:nRight  := INT( SystemMaxCol() / 2 ) + 30
					oWindow:Open()
					
					
					WHILE lContinua
						
						@ oWindow:nTop+ 1, oWindow:nLeft+14 GET     pLTG_CONCURSO                                  ;
															PICT    '@!'                                           ;
															CAPTION 'Concurso'                                     ;
															WHEN    pFALSE                                         ;
															COLOR   SysFieldGet()
						
						@ oWindow:nTop+ 1, oWindow:nLeft+40 GET		pLTG_SORTEIO                                   ;
															VALID	.not. Empty( pLTG_SORTEIO )                    ;
															PICT	'@KD 99/99/99'                                 ;
															CAPTION 'Sorteio'                                      ;
															COLOR   SysFieldGet()


						hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
									oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
						
						
						// Primeira Partida
						@ oWindow:nTop+ 3, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 3, oWindow:nLeft+26 	GET		pLTG_PARTIDA_01_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 1 -'                                     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()
						
						aGroup[1]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+ 3, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+ 4, oWindow:nLeft+28, ;
							oWindow:nTop+ 4, oWindow:nRight- 1	GET			pLTG_PARTIDA_01_RESULTADO_1            ;
																RADIOGROUP	aGroup                                 ;
																COLOR		SysFieldGRadioBox()
						
						@ oWindow:nTop+ 5, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 5, oWindow:nLeft+26	GET		pLTG_PARTIDA_01_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()
						
						aGroup[1]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+ 5, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+ 4, oWindow:nLeft+28, ;
							oWindow:nTop+ 4, oWindow:nRight- 1 	GET        	pLTG_PARTIDA_01_RESULTADO_2             ;
																RADIOGROUP	aGroup                                  ;
																COLOR      	SysFieldGRadioBox()
						
						hb_DispBox( oWindow:nTop+ 6, oWindow:nLeft+ 1, ;
									oWindow:nTop+ 6, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
						
						
						// Segunda Partida
						@ oWindow:nTop+ 7, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 7, oWindow:nLeft+26 	GET		pLTG_PARTIDA_02_CLUBE_1                     ;
																LISTBOX aClubes                                     ;
																CAPTION ' 2 -'                                      ;
																DROPDOWN                                            ;
																SCROLLBAR                                           ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+ 7, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+ 8, oWindow:nLeft+28, ;
							oWindow:nTop+ 8, oWindow:nRight- 1	GET			pLTG_PARTIDA_02_RESULTADO_1            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						@ oWindow:nTop+ 9, oWindow:nLeft+ 6, ;
							oWindow:nTop+ 9, oWindow:nLeft+26 	GET		pLTG_PARTIDA_02_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+ 9, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+ 8, oWindow:nLeft+28, ;
							oWindow:nTop+ 8, oWindow:nRight- 1	GET			pLTG_PARTIDA_02_RESULTADO_2            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						hb_DispBox( oWindow:nTop+10, oWindow:nLeft+ 1, ;
									oWindow:nTop+10, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
						
						
						// Terceira Partida
						@ oWindow:nTop+11, oWindow:nLeft+ 6, ;
							oWindow:nTop+11, oWindow:nLeft+26	GET		pLTG_PARTIDA_03_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 3 -'                                     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+11, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+12, oWindow:nLeft+28, ;
							oWindow:nTop+12, oWindow:nRight- 1 	GET			pLTG_PARTIDA_03_RESULTADO_1            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						@ oWindow:nTop+13, oWindow:nLeft+ 6, ;
							oWindow:nTop+13, oWindow:nLeft+26 	GET		pLTG_PARTIDA_03_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+13, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+12, oWindow:nLeft+28, ;
							oWindow:nTop+12, oWindow:nRight- 1 	GET			pLTG_PARTIDA_03_RESULTADO_2            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						hb_DispBox( oWindow:nTop+14, oWindow:nLeft+ 1, ;
									oWindow:nTop+14, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )


						// Quarta Partida
						@ oWindow:nTop+15, oWindow:nLeft+ 6, ;
							oWindow:nTop+15, oWindow:nLeft+26 	GET		pLTG_PARTIDA_04_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 4 -'                                     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+15, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+16, oWindow:nLeft+28, ;
							oWindow:nTop+16, oWindow:nRight- 1 	GET      	pLTG_PARTIDA_04_RESULTADO_1            ;
																RADIOGROUP 	aGroup                                 ;
																COLOR      	SysFieldGRadioBox()

						@ oWindow:nTop+17, oWindow:nLeft+ 6, ;
							oWindow:nTop+17, oWindow:nLeft+26 	GET		pLTG_PARTIDA_04_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+17, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
						
						@ oWindow:nTop+16, oWindow:nLeft+28, ;
							oWindow:nTop+16, oWindow:nRight- 1 	GET        pLTG_PARTIDA_04_RESULTADO_2             ;
																RADIOGROUP aGroup                                  ;
																COLOR      SysFieldGRadioBox()
											
						hb_DispBox( oWindow:nTop+18, oWindow:nLeft+ 1, ;
									oWindow:nTop+18, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )


						// Quinta Partida
						@ oWindow:nTop+19, oWindow:nLeft+ 6, ;
							oWindow:nTop+19, oWindow:nLeft+26	GET		pLTG_PARTIDA_05_CLUBE_1                    ;
																LISTBOX aClubes                                    ;
																CAPTION ' 5 -'                                     ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+19, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
															
						@ oWindow:nTop+20, oWindow:nLeft+28, ;
							oWindow:nTop+20, oWindow:nRight- 1 	GET        pLTG_PARTIDA_05_RESULTADO_1             ;
																RADIOGROUP aGroup                                  ;
																COLOR      SysFieldGRadioBox()

						@ oWindow:nTop+21, oWindow:nLeft+ 6, ;
							oWindow:nTop+21, oWindow:nLeft+26 	GET		pLTG_PARTIDA_05_CLUBE_2                    ;
																LISTBOX aClubes                                    ;
																DROPDOWN                                           ;
																SCROLLBAR                                          ;
																COLOR   SysFieldListBox()

						aGroup[1]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+30, "&0" )
						aGroup[1]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[2]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+36, "&1" )
						aGroup[2]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[3]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+42, "&2" )
						aGroup[3]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[4]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+48, "&3" )
						aGroup[4]:ColorSpec := SysFieldBRadioBox()
						
						aGroup[5]           := RadioButton( oWindow:nTop+21, oWindow:nLeft+54, "&+" )
						aGroup[5]:ColorSpec := SysFieldBRadioBox()
															
						@ oWindow:nTop+20, oWindow:nLeft+28, ;
							oWindow:nTop+20, oWindow:nRight- 1 	GET        pLTG_PARTIDA_05_RESULTADO_2             ;
																RADIOGROUP aGroup                                  ;
																COLOR      SysFieldGRadioBox()


						hb_DispBox( oWindow:nTop+22, oWindow:nLeft+ 1, ;
									oWindow:nTop+22, oWindow:nRight -1, oWindow:cBorder, SystemFormColor() )
						hb_DispOutAt( oWindow:nTop+22, oWindow:nLeft+ 2, ' Rateio ', SystemLabelColor() )
						
						@ oWindow:nTop+23, oWindow:nLeft+12 SAY   'Ganhadores'                                     ;
															COLOR SystemLabelColor()

						@ oWindow:nTop+23, oWindow:nLeft+40 SAY   'Premio'                                         ;
															COLOR SystemLabelColor()


						// Coluna de Acertos			
						@ oWindow:nTop+24, oWindow:nLeft+16 GET     pLTG_RATEIO_ACERTO_05                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '5 Acertos'                                    ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pLTG_SORTEIO )

						@ oWindow:nTop+25, oWindow:nLeft+16 GET     pLTG_RATEIO_ACERTO_04                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '4 Acertos'                                    ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pLTG_SORTEIO )

						@ oWindow:nTop+26, oWindow:nLeft+16 GET     pLTG_RATEIO_ACERTO_03                          ;
															PICT    '@EN 9,999,999,999'                            ;
															CAPTION '3 Acertos'                                    ;
															COLOR   SysFieldGet()                                  ;
															WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pLTG_SORTEIO )


						// Coluna de Premios			
						@ oWindow:nTop+24, oWindow:nLeft+35 GET   pLTG_RATEIO_PREMIO_05                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pLTG_SORTEIO )
															
						@ oWindow:nTop+25, oWindow:nLeft+35 GET   pLTG_RATEIO_PREMIO_04                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pLTG_SORTEIO )

						@ oWindow:nTop+26, oWindow:nLeft+35 GET   pLTG_RATEIO_PREMIO_03                            ;
															PICT  '@EN 99,999,999,999.99'                          ;
															COLOR SysFieldGet()                                    ;
															WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pLTG_SORTEIO )
												
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
							
							If LTGGravaDados()
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
*	LTGExcluir()
*
*	Realiza a exclusao do concurso da LOTOGOL.
*
*   LTGMntBrowse -> LTGExcluir
*
*/
STATIC PROCEDURE LTGExcluir

	If CONCURSO->CON_JOGO == pLOTOGOL

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
*	LTGGravaDados()
*
*	Realiza a gravacao dos dados da LOTOGOL.
*
*/
STATIC FUNCTION LTGGravaDados

local lRetValue := pFALSE

		
	begin sequence

		while .not. lRetValue			
		
			If iif( CONCURSO->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO ) ), CONCURSO->( NetRLock() ), CONCURSO->( NetAppend() ) )
				CONCURSO->CON_JOGO   := pLOTOGOL
				CONCURSO->CON_CONCUR := pLTG_CONCURSO
				CONCURSO->CON_SORTEI := pLTG_SORTEIO
				CONCURSO->( dbUnlock() )
			EndIf


			// Gravacao dos dados das Partidas
			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO + "01" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTOGOL
				JOGOS->JOG_CONCUR := pLTG_CONCURSO
				JOGOS->JOG_FAIXA  := "01"
				JOGOS->JOG_COL_01 := pLTG_PARTIDA_01_CLUBE_1
				JOGOS->JOG_PON_01 := pxLTGWrite( pLTG_PARTIDA_01_RESULTADO_1 )
				JOGOS->JOG_COL_02 := pLTG_PARTIDA_01_CLUBE_2
				JOGOS->JOG_PON_02 := pxLTGWrite( pLTG_PARTIDA_01_RESULTADO_2 ) 
				JOGOS->( dbUnlock() )
			EndIf
			
			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO + "02" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTOGOL
				JOGOS->JOG_CONCUR := pLTG_CONCURSO
				JOGOS->JOG_FAIXA  := "02"
				JOGOS->JOG_COL_01 := pLTG_PARTIDA_02_CLUBE_1
				JOGOS->JOG_PON_01 := pxLTGWrite( pLTG_PARTIDA_02_RESULTADO_1 )
				JOGOS->JOG_COL_02 := pLTG_PARTIDA_02_CLUBE_2
				JOGOS->JOG_PON_02 := pxLTGWrite( pLTG_PARTIDA_02_RESULTADO_2 )
				JOGOS->( dbUnlock() )
			EndIf
			
			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO + "03" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTOGOL
				JOGOS->JOG_CONCUR := pLTG_CONCURSO
				JOGOS->JOG_FAIXA  := "03"
				JOGOS->JOG_COL_01 := pLTG_PARTIDA_03_CLUBE_1
				JOGOS->JOG_PON_01 := pxLTGWrite( pLTG_PARTIDA_03_RESULTADO_1 )
				JOGOS->JOG_COL_02 := pLTG_PARTIDA_03_CLUBE_2
				JOGOS->JOG_PON_02 := pxLTGWrite( pLTG_PARTIDA_03_RESULTADO_2 )
				JOGOS->( dbUnlock() )
			EndIf
			
			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO + "04" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTOGOL
				JOGOS->JOG_CONCUR := pLTG_CONCURSO
				JOGOS->JOG_FAIXA  := "04"
				JOGOS->JOG_COL_01 := pLTG_PARTIDA_04_CLUBE_1
				JOGOS->JOG_PON_01 := pxLTGWrite( pLTG_PARTIDA_04_RESULTADO_1 )
				JOGOS->JOG_COL_02 := pLTG_PARTIDA_04_CLUBE_2
				JOGOS->JOG_PON_02 := pxLTGWrite( pLTG_PARTIDA_04_RESULTADO_2 )
				JOGOS->( dbUnlock() )
			EndIf
			
			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO + "05" ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTOGOL
				JOGOS->JOG_CONCUR := pLTG_CONCURSO
				JOGOS->JOG_FAIXA  := "05"
				JOGOS->JOG_COL_01 := pLTG_PARTIDA_05_CLUBE_1
				JOGOS->JOG_PON_01 := pxLTGWrite( pLTG_PARTIDA_05_RESULTADO_1 )
				JOGOS->JOG_COL_02 := pLTG_PARTIDA_05_CLUBE_2
				JOGOS->JOG_PON_02 := pxLTGWrite( pLTG_PARTIDA_05_RESULTADO_2 )
				JOGOS->( dbUnlock() )
			EndIf
			

			// Gravacao dos dados da Premiacao
			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO + "03" ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO    := pLOTOGOL
				RATEIO->RAT_CONCUR  := pLTG_CONCURSO
				RATEIO->RAT_FAIXA   := "03"
				RATEIO->RAT_ACERTA  := pLTG_RATEIO_ACERTO_03
				RATEIO->RAT_RATEIO  := pLTG_RATEIO_PREMIO_03
				RATEIO->( DBUnLock() )
			EndIf
			
			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO + "04" ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO    := pLOTOGOL
				RATEIO->RAT_CONCUR  := pLTG_CONCURSO
				RATEIO->RAT_FAIXA   := "04"
				RATEIO->RAT_ACERTA  := pLTG_RATEIO_ACERTO_04
				RATEIO->RAT_RATEIO  := pLTG_RATEIO_PREMIO_04
				RATEIO->( DBUnLock() )
			EndIf
			
			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTOGOL + pLTG_CONCURSO + "05" ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO    := pLOTOGOL
				RATEIO->RAT_CONCUR  := pLTG_CONCURSO
				RATEIO->RAT_FAIXA   := "05"
				RATEIO->RAT_ACERTA  := pLTG_RATEIO_ACERTO_05
				RATEIO->RAT_RATEIO  := pLTG_RATEIO_PREMIO_05
				RATEIO->( DBUnLock() )
			EndIf

			lRetValue := pTRUE
		
		enddo

	end sequence
		
return( lRetValue )


/***
*
*	LTGAcoes()
*
*	Exibe o menu de acoes relacionadas.
*
*   LTGMntBrowse -> LTGAcoes
*
*/
STATIC PROCEDURE LTGAcoes

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
						LTGCombina()

					case nTipAcoes == 2
						LTGRelResult()

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
*	LTGCombina()
*
*	Exibe as opcoes para gerar combinacoes.
*
*   LTGMntBrowse -> LTGAcoes -> LTGCombina
*
*/
STATIC PROCEDURE LTGCombina

local oWindow
local lPushButton
local lContinua   := pTRUE

local aGroup      := Array(3)
local nOpcao      := 1
local nQuantJog   := 1
local nQuantDez   := 1  // pLTF_DEF_MIN_DEZENAS
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
						LTGAnaliAleatoria( nQuantJog, nQuantDez )
					
					case nOpcao == 2
						// DSARelResult()

					case nOpcao == 3
						// DSARelResult()

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
*	LTGAnaliAleatoria()
*
*	Realiza a geracao das dezenas para a LOTOGOL aleatoriamente.
*
*   LTGMntBrowse -> LTGAcoes -> LTGCombina -> LTGAnaliAleatoria
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
* nQuantDezenas : Informa o numero de dezenas a ser geradas por jogos
*
*/
STATIC PROCEDURE LTGAnaliAleatoria( nQuantJogos, nQuantDezenas )

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

				If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTOGOL } ) ) > 0

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
						LTGShowAposta()
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
*	LTGShowAposta()
*
*	Exibe as apostas gerados no arquivo Temporario.
*
*   LTGMntBrowse -> LTGAcoes -> LTGCombina -> LTGAnaliAleatoria -> LTGShowAposta
*
*/
STATIC PROCEDURE LTGShowAposta

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
*	LTGRelResult()
*
*	Realiza a impressao dos resultados da LOTOGOL.
*
*   LTGMntBrowse -> LTGAcoes -> LTGCombina -> LTGRelResult
*
*/
STATIC PROCEDURE LTGRelResult

local lContinua    := pTRUE
local lPushButton
local oWindow

local cInicio
local cFinal
local nCurrent
local nTotConcurso := 0
local bFiltro      := { || CONCURSO->CON_JOGO == pLOTOGOL .and. CONCURSO->( .not. Eof() ) }
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
					IF CONCURSO->( dbSetOrder(1), dbSeek( pLOTOGOL + cInicio ) ) .and. ;
						CONCURSO->( dbSetOrder(1), dbSeek( pLOTOGOL + cFinal ) )

						bFiltro := { || CONCURSO->CON_JOGO == pLOTOGOL .and. CONCURSO->( .not. Eof() ) .and. ;
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
							oPDFReport:SetInfo( 'EDILSON MENDES', 'ODIN', 'RESULTADOS LOTOGOL', oPDFReport:cFileName )

							nLinha := oPDFReport:MaxCol()

							//Posiciona o Registro
							If CONCURSO->( dbSetOrder(1), dbSeek( pLOTOGOL + cInicio ) )

								while Eval( bFiltro )

									// Atualiza a barra de Progresso
									oBarProgress:Update( ( nCurrent++ / nTotConcurso ) * 100 )

									If nLinha >= ( oPDFReport:MaxCol() - 35 )
										oPDFReport:AddPage()
										oPDFReport:DrawRetangle( 0,  0, 22, 2 )
										oPDFReport:DrawRetangle( 0, 25, 49, 2 )
										oPDFReport:DrawRetangle( 0, 77, 22, 2 )
										oPDFReport:DrawText( 1, 26, PadC( 'RESULTADOS LOTOGOL', 70 ), , 10, 'Helvetica-Bold' )
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