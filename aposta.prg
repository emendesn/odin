/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  aposta.prg
*
***/

#include 'set.ch'
#include 'box.ch'
#include 'inkey.ch'
#include 'common.ch'
#include 'setcurs.ch'
#include 'getexit.ch'
#include 'dbfunc.ch'
#include 'aposta.ch'
#include 'main.ch'

static aAposta
static aApostaGrupos
static aCartao

memvar GetList

/***
*
*	Aposta()
*
*	Realiza a manutencao do cadastro de apostas dos seguintes jogos
*
*   => Dupla Sena
*   => Loto Facil
*   => Loto Mania
*   => Mega Sena
*   => Quina
*   => Time Mania
*   => Dia de Sorte
*   => Loteca
*   => Lotogol
*
*/
PROCEDURE MntAposta

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

local aSelDezenas   := {}
local nRow          := 1
local nPointer
local nPosDezenas   := 1


	If .not. Empty( SystemConcurso() )

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 13
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 32
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 13
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 32
			oWindow:cHeader := PadC( SystemNameConcurso(), Len( SystemNameConcurso() ) + 2, ' ')
			oWindow:Open()

			// Desenha a Linha de Botoes
			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			// Estabelece o Filtro para exibicao dos registros
			bFiltro := { || APOSTAS->APT_JOGO == SystemConcurso() .and. .not. APOSTAS->( Eof() ) }

			dbSelectArea('APOSTAS')
			APOSTAS->( dbEval( {|| nMaxItens++ }, bFiltro ) )
			APOSTAS->( dbSetOrder(1), dbSeek( SystemConcurso() ) )

			begin sequence

				// Exibe o Browse com as Apostas
				oBrowse               	:= 	TBrowseDB( oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
														oWindow:nBottom- 3, oWindow:nRight- 1 )
				oBrowse:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFiltro ) ) <> 0, ( nCount += xRecno, xRecno ), xRecno ) }
				oBrowse:goTopBlock    	:= 	{ || nCount := 1, GoTopDB( bFiltro ) }
				oBrowse:goBottomBlock 	:= 	{ || nCount := nMaxItens, GoBottomDB( bFiltro ) }
				oBrowse:colorSpec     	:= SysBrowseColor()
				oBrowse:headSep       	:= Chr(205)
				oBrowse:colSep        	:= Chr(179)
				oBrowse:Cargo         	:= {}

				// Adiciona as Colunas
				oColumn 			:= TBColumnNew( PadC( 'Concurso', 8 ),  APOSTAS->( FieldBlock( 'APT_CONCUR' ) ) )
				oColumn:picture 	:= '@!'
				oColumn:width   	:= 8
				oColumn:colSep      := Chr(179)
				oBrowse:addColumn( oColumn )

				oColumn 			:= TBColumnNew( '',                     APOSTAS->( FieldBlock( 'APT_SEQUEN' ) ) )
				oColumn:picture 	:= '@!'
				oColumn:width   	:= 3
				oColumn:colSep      := Chr(179)
				oBrowse:addColumn( oColumn )

				oColumn            := TBColumnNew( PadC( 'Sorteio', 8 ),    APOSTAS->( FieldBlock( 'APT_SORTEI' ) ) )
				oColumn:picture    := '@D 99/99/99'
				oColumn:width      := 8
				oColumn:colSep     := Chr(179)
				oBrowse:addColumn( oColumn )

				oColumn            := TBColumnNew( PadC( 'Historico', 20 ), APOSTAS->( FieldBlock( 'APT_HISTOR' ) ) )
				oColumn:picture    := '@!'
				oColumn:width      := 20
				oColumn:colSep     := Chr(179)
				oBrowse:addColumn( oColumn )

				// Realiza a Montagem da Barra de Rolagem
				oScrollBar           	:= ScrollBar( oWindow:nTop+ 3, oWindow:nBottom- 3, oWindow:nRight )
				oScrollBar:colorSpec 	:= SysScrollBar()
				oScrollBar:display()

				// Desenha os botoes da tela
				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
				oTmpButton:sBlock    := { || Incluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
				oTmpButton:sBlock    := { || Modificar() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' &Excluir ' )
				oTmpButton:sBlock    := { || Excluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Gr&upos ' )
				oTmpButton:sBlock    := { || Grupos() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AADD( oBrowse:Cargo, { oTmpButton, UPPER( SubStr( oTmpButton:Caption, AT('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+43, ' A&postas ' )
				oTmpButton:sBlock    := { || Apostas() }
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

	Else
		ErrorTable( 'C01' )  // Nao existe concurso selecionado.
	EndIf

return


/***
*
*	Incluir()
*
*	Realiza a chamada da funcao para a inclusao das apostas conforme o concurso ativo.
*
*   MntAposta -> Incluir
*
*/
STATIC PROCEDURE Incluir

local nPointer

	If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == SystemConcurso() } ) ) > 0
		Eval( pSTRU_SYSTEM[ nPointer ][ pSTRU_APOSTAS_INCLUIR ] )
	EndIf

return


/***
*
*	Modificar()
*
*	Realiza a chamada da funcao para a manutencao das apostas conforme o concurso ativo.
*
*   MntAposta -> Modificar
*
*/
STATIC PROCEDURE Modificar

local nPointer

	If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == SystemConcurso() } ) ) > 0
		Eval( pSTRU_SYSTEM[ nPointer ][ pSTRU_APOSTAS_MODIFICAR ] )
	EndIf

return


/***
*
*	Excluir()
*
*	Realiza a chamada da funcao para a exclusao das apostas conforme o concurso ativo.
*
*   MntAposta -> Excluir
*
*/
STATIC PROCEDURE Excluir

	local nPointer

	If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == SystemConcurso() } ) ) > 0
		Eval( pSTRU_SYSTEM[ nPointer ][ pSTRU_APOSTAS_EXCLUIR ] )
	EndIf

return


/***
*
*	Grupos()
*
*	Realiza o cadastro de grupos de apostadores pertencentes a aposta.
*
*   MntAposta -> Grupos
*
*/
STATIC PROCEDURE Grupos

	local nPointer

	If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == SystemConcurso() } ) ) > 0
		Eval( pSTRU_SYSTEM[ nPointer ][ pSTRU_APOSTAS_GRUPOS ] )
	EndIf

return


/***
*
*	Apostas()
*
*	Realiza o cadastro de grupos de apostadores pertencentes a aposta.
*
*   MntAposta -> Grupos
*
*/
STATIC PROCEDURE Apostas

	local nPointer

	If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == SystemConcurso() } ) ) > 0
		Eval( pSTRU_SYSTEM[ nPointer ][ pSTRU_APOSTAS_APOSTA ] )
	EndIf

return


/***
*
*	ApoIncluir()
*
*	Realiza a inclusao de Apostas exeutada para os seguintes concursos
*
*   => Dupla Sena
*   => Loto Facil
*   => Loto Mania
*   => Mega Sena
*   => Quina
*   => Time Mania
*   => Dia de Sorte
*   => Loteca
*   => Lotogol
*
*   MntAposta -> Incluir -> { => } ApoIncluir
*
*/
PROCEDURE ApoIncluir

local lContinua     := pTRUE
local lPushButton
local oWindow


	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		// Inicializa as Variaveis de Dados
		xInitAposta

		// Inicializa as Variaveis de no vetor aCompeticoes
		xStoreAposta

		// Cria o Objeto Windows
		oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  2
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 19
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  3
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 19
		oWindow:cHeader := PadC( 'Incluir', Len( 'Incluir' ) + 2, ' ')
		oWindow:Open()

		while lContinua

			@ oWindow:nTop+ 1, oWindow:nLeft+12 GET     pAPOSTA_CAD_CONCURSO                            ;
												PICT    '@K 99999'                                      ;
												SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),5)) ;
												CAPTION 'Concurso'                                      ;
												COLOR   SysFieldGet()

			@ oWindow:nTop+ 1, oWindow:nLeft+29 GET     pAPOSTA_CAD_SORTEIO                             ;
												PICT    '@KD 99/99/99'                                  ;
												CAPTION 'Sorteio'                                       ;
												COLOR   SysFieldGet()

			@ oWindow:nTop+ 2, oWindow:nLeft+12 GET     pAPOSTA_CAD_HISTORICO                           ;
												PICT    '@K!S25'                                        ;
												CAPTION 'Historico'                                     ;
												COLOR   SysFieldGet()

			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                      ;
													CAPTION ' Con&firma '                               ;
													COLOR   SysPushButton()                             ;
													STYLE   ''                                          ;
													WHEN    Val( pAPOSTA_CAD_CONCURSO ) > 0 .and.       ;
															.not. Empty( pAPOSTA_CAD_SORTEIO ) .and.    ;
															.not. Empty( pAPOSTA_CAD_HISTORICO )        ;
													STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

			@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                      ;
													CAPTION ' Cance&lar '                               ;
													COLOR   SysPushButton()                             ;
													STYLE   ''                                          ;
													STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

			Set( _SET_CURSOR, SC_NORMAL )

			READ

			Set( _SET_CURSOR, SC_NONE )

			If lContinua .and. LastKey() != K_ESC

				begin sequence

					// Ajusta o codigo do concurso
					pAPOSTA_CAD_CONCURSO := StrZero( Val( pAPOSTA_CAD_CONCURSO ), 5 )

					// Pesquisa na base de dados um codigo valido para cadastrar o clube
					APOSTAS->( 	dbEval	(	{ 	|| 	pAPOSTA_CAD_SEQUENCIA++ },                        ;
											{ 	||	APOSTAS->APT_JOGO == SystemConcurso() .and.       ;
													APOSTAS->APT_CONCUR == pAPOSTA_CAD_CONCURSO .and. ;
													.not. APOSTAS->( Eof() )                          ;
											}                                                         ;
										)                                                             ;
							)

					APOSTAS->( dbSetOrder(1) )
					while APOSTAS->( dbSeek( SystemConcurso() + pAPOSTA_CAD_CONCURSO + StrZero( pAPOSTA_CAD_SEQUENCIA, 3 ) ) )
						pAPOSTA_CAD_SEQUENCIA++
					enddo
				always

					begin sequence

						If APOSTAS->( NetAppend() )
							APOSTAS->APT_JOGO 	:= SystemConcurso()
							APOSTAS->APT_COMCUR := pAPOSTA_CAD_CONCURSO
							APOSTAS->APT_SEQUEN := StrZero( pAPOSTA_CAD_SEQUENCIA, 3 )
							APOSTAS->APT_SORTEI := pAPOSTA_CAD_SORTEIO
							APOSTAS->APT_ORIG   := pAPOSTA_ORIGEM_USUARIO
							APOSTAS->APT_HISTOR := pAPOSTA_CAD_HISTORICO
							APOSTAS->( dbUnlock() )
						EndIf
					always
						lContinua := pFALSE
					end sequence

				end sequence

			EndIf

		enddo

	always
		// Fecha o Objeto Windows
		oWindow:Close()

		// Restaura a tabela da Pilha
		DstkPop()
	end sequence

return


/***
*
*	ApoModificar()
*
*	Realiza a alteracao das Apostas realizadas para os seguintes concursos
*
*   => Dupla Sena
*   => Loto Facil
*   => Loto Mania
*   => Mega Sena
*   => Quina
*   => Time Mania
*   => Dia de Sorte
*   => Loteca
*   => Lotogol
*
*   MntAposta -> Modificar -> { => } ApoModificar
*
*/
PROCEDURE ApoModificar

local lContinua   := pTRUE
local lPushButton
local oWindow


	//************************************************************************
	// A rotina so deve ser executada somente se ja houverem dados cadastrados
	//************************************************************************
	If .not. Empty(	APOSTAS->APT_JOGO ) .and. APOSTAS->APT_JOGO == SystemConcurso()

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Inicializa o vetor aAposta
			xInitAposta

			// Inicializa as Variaveis de no vetor aAposta
			xStoreAposta

			//
			// Atualiza a variaveis com o registro selecionado
			//
			pAPOSTA_CAD_CONCURSO  := APOSTAS->APT_CONCUR
			pAPOSTA_CAD_SORTEIO   := APOSTAS->APT_SORTEI
			pAPOSTA_CAD_ORIGEM    := APOSTAS->APT_ORIG
			pAPOSTA_CAD_HISTORICO := APOSTAS->APT_HISTOR

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  2
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 19
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  3
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 19
			oWindow:cHeader := PadC( 'Modificar', Len( 'Modificar' ) + 2, ' ')
			oWindow:Open()

			while lContinua

				@ oWindow:nTop+ 1, oWindow:nLeft+12 GET     pAPOSTA_CAD_CONCURSO                            ;
													PICT    '@K 99999'                                      ;
													CAPTION 'Concurso'                                      ;
													WHEN    pFALSE                                          ;
													COLOR   SysFieldGet()

				@ oWindow:nTop+ 1, oWindow:nLeft+29 GET     pAPOSTA_CAD_SORTEIO                             ;
													PICT    '@KD 99/99/99'                                  ;
													CAPTION 'Sorteio'                                       ;
													COLOR   SysFieldGet()

				@ oWindow:nTop+ 2, oWindow:nLeft+12 GET     pAPOSTA_CAD_HISTORICO                           ;
													PICT    '@K!S25'                                        ;
													CAPTION 'Historico'                                     ;
													COLOR   SysFieldGet()                                   ; 
													WHEN    pAPOSTA_CAD_ORIGEM == pAPOSTA_ORIGEM_USUARIO

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

					begin sequence

						If APOSTAS->( NetRLock() )
							APOSTAS->APT_SORTEI := pAPOSTA_CAD_SORTEIO
							APOSTAS->APT_HISTOR := pAPOSTA_CAD_HISTORICO
							APOSTAS->( dbUnlock() )
						EndIf
					always
						lContinua := pFALSE
					end sequence

				EndIf

			enddo

		always
			// Fecha o Objeto Windows
			oWindow:Close()

			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	Else
		ErrorTable( 'C02' )  // Nao existe aposta selecionada.
	EndIf

return


/***
*
*	ApoExcluir()
*
*	Realiza a exclusao das Apostas realizadas para os seguintes concursos
*
*   => Dupla Sena
*   => Loto Facil
*   => Loto Mania
*   => Mega Sena
*   => Quina
*   => Time Mania
*   => Dia de Sorte
*   => Loteca
*   => Lotogol
*
*   MntAposta -> Excluir -> { => } APOExcluir
*
*/
PROCEDURE ApoExcluir

	If .not. Empty( APOSTAS->APT_JOGO ) .and. APOSTAS->APT_JOGO == SystemConcurso()

		If Alert( 'Confirma Exclusao do Registro ?', {' Sim ', ' Nao ' } ) == 1

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Elimina os itens das apostas
				If APOSTAS_ITENS->( dbSetOrder(1), dbSeek( APOSTAS->APT_JOGO + APOSTAS->APT_CONCUR ) )
					while APOSTAS_ITENS->ITN_JOGO == APOSTAS->APT_JOGO .and. ;
						APOSTAS_ITENS->ITN_CONCUR == APOSTAS->APT_CONCUR .and. ;
						.not. APOSTAS_ITENS->( Eof() )
						
						// Elimina os clubes amarrado as apostas
						If APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( APOSTAS_ITENS->ITN_JOGO + APOSTAS_ITENS->ITN_CONCUR + APOSTAS_ITENS->ITN_SEQUEN ) )
							while APOSTAS_CLUBES->CLB_JOGO == APOSTAS_ITENS->ITN_JOGO .and. ;
								APOSTAS_CLUBES->CLB_CONCURS == APOSTAS_ITENS->CLB_CONCURS .and. ;
								APOSTAS_CLUBES->CLB_SEQUEN == APOSTAS_ITENS->ITN_SEQUEN .and. ;								
								.not. APOSTAS_CLUBES->( Eof() )
								If APOSTAS_CLUBES->( NetRLock() )
									APOSTAS_CLUBES->( dbDelete() )
									APOSTAS_CLUBES->( dbUnlock() )
								EndIf
								APOSTAS_CLUBES->( dbSkip() )
							enddo
						EndIf
						
						// Elimina o Item da Aposta
						If APOSTAS_ITENS->( NetRLock() )
							APOSTAS_ITENS->( dbDelete() )
							APOSTAS_ITENS->( dbUnlock() )
						EndIf
						APOSTAS_ITENS->( dbSkip() )
						
					enddo
				EndIf

				//Elimina os apostadores do grupo
				If APOSTAS_GRUPOS->( dbSetOrder(1), dbSeek( APOSTAS->APT_JOGO + APOSTAS->APT_CONCUR ) )
					while APOSTAS_GRUPOS->GRP_JOGO == APOSTAS->APT_JOGO .and. ;
						APOSTAS_GRUPOS->GRP_CONCUR == APOSTAS->APT_CONCUR .and. ;
						.not. APOSTAS_GRUPOS->( Eof() )
						If APOSTAS_GRUPOS->( NetRLock() )
							APOSTAS_GRUPOS->( dbDelete() )
							APOSTAS_GRUPOS->( dbUnlock() )
						EndIf
						APOSTAS_GRUPOS->( dbSkip() )
					enddo
				EndIf
				
				// Elimina o cabecario das apostas
				If APOSTAS->( NetRLock() )
					APOSTAS->( dbDelete() )
					APOSTAS->( dbUnlock() )
				EndIf

			always
				// Restaura a tabela da Pilha
				DstkPop()
			end sequence

		EndIf
	Else
		ErrorTable( 'C02' )  // Nao existe aposta selecionada.
	EndIf

return


/***
*
*	ApoGrupos()
*
*	Realiza a manutencao do Grupos de apostadores da aposta cadastrada dos seguintes jogos
*
*   => Dupla Sena
*   => Loto Facil
*   => Loto Mania
*   => Mega Sena
*   => Quina
*   => Time Mania
*   => Dia de Sorte
*   => Loteca
*   => Lotogol
*
*   MntAposta -> Grupos -> { => } ApoGrupos
*
*/
PROCEDURE ApoGrupos

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

local aSelDezenas   := {}
local nRow          := 1
local nPointer
local nPosDezenas   := 1


	If .not. Empty( APOSTAS->APT_JOGO ) .and. APOSTAS->APT_JOGO == SystemConcurso()

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 12
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 25
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 12
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 25
			oWindow:cHeader := PadC( 'Grupos', Len( 'Grupos' ) + 2, ' ')
			oWindow:Open()

			// Desenha a Linha de Botoes
			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			// Estabelece o Filtro para exibicao dos registros
			bFiltro := { || APOSTAS_GRUPOS->GRP_JOGO == APOSTAS->APT_JOGO .and. ;
							APOSTAS_GRUPOS->GRP_CONCUR == APOSTAS->APT_CONCUR .and. ;
							APOSTAS_GRUPOS->GRP_SEQUEN == APOSTAS->APT_SEQUEN .and. ;
							.not. APOSTAS_GRUPOS->( Eof() ) }

			dbSelectArea('APOSTAS_GRUPOS')
			APOSTAS_GRUPOS->( dbEval( {|| nMaxItens++ }, bFiltro ) )
			APOSTAS_GRUPOS->( dbSetOrder(1), dbSeek( APOSTAS->APT_JOGO + APOSTAS->APT_CONCUR + APOSTAS->APT_SEQUEN ) )

			begin sequence

				// Exibe o Browse com as Apostas
				oBrowse               	:= 	TBrowseDB( oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
														oWindow:nBottom- 3, oWindow:nRight- 1 )
				oBrowse:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFiltro ) ) <> 0, ( nCount += xRecno, xRecno ), xRecno ) }
				oBrowse:goTopBlock    	:= 	{ || nCount := 1, GoTopDB( bFiltro ) }
				oBrowse:goBottomBlock 	:= 	{ || nCount := nMaxItens, GoBottomDB( bFiltro ) }
				oBrowse:colorSpec     	:= SysBrowseColor()
				oBrowse:headSep       	:= Chr(205)
				oBrowse:colSep        	:= Chr(179)
				oBrowse:Cargo         	:= {}

				// Adiciona as Colunas
				oColumn               := TBColumnNew( PadC('Apostador', 9 ), APOSTAS_GRUPOS->( FieldBlock( 'GRP_APOCOD' ) ) )
				oColumn:picture       := '@!'
				oColumn:width         := 9
				oColumn:colSep        := Chr(179)
				oBrowse:addColumn( oColumn )

				oColumn               := TBColumnNew( '',                    {|| PadR( iif( APOSTADORES->( dbSetOrder(1), dbSeek( APOSTAS_GRUPOS->GRP_APOCOD ) ), AllTrim( APOSTADORES->APO_NOME ), '' ), 24 ) } )
				oColumn:picture       := '@!'
				oColumn:width         := 24
				oColumn:colSep        := Chr(179)
				oBrowse:addColumn( oColumn )

				oColumn               := TBColumnNew( PadC('Rateio', 12 ),   APOSTAS_GRUPOS->( FieldBlock( 'GRP_VALOR' ) ) )
				oColumn:picture       := '@EN 9,999,999.99'
				oColumn:width         := 12
				oColumn:colSep        := Chr(179)
				oBrowse:addColumn( oColumn )

				// Realiza a Montagem da Barra de Rolagem
				oScrollBar           	:= ScrollBar( oWindow:nTop+ 3, oWindow:nBottom- 3, oWindow:nRight )
				oScrollBar:colorSpec 	:= SysScrollBar()
				oScrollBar:display()

				// Desenha os botoes da tela
				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
				oTmpButton:sBlock    := { || GrpIncluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
				oTmpButton:sBlock    := { || GrpModificar() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' E&xcluir ' )
				oTmpButton:sBlock    := { || GrpExcluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' &Sair ' )
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

	Else
		ErrorTable( 'C02' )  // Nao existe aposta selecionada.
	EndIf

return


/***
*
*	GrpIncluir()
*
*	Realiza a inclusado do apostador no grupo de apostas dos seguintes concursos
*
*   => Dupla Sena
*   => Loto Facil
*   => Loto Mania
*   => Mega Sena
*   => Quina
*   => Time Mania
*   => Dia de Sorte
*   => Loteca
*   => Lotogol
*
*   MntAposta -> Grupos -> { => } ApoGrupos -> GrpIncluir
*
*/
STATIC PROCEDURE GrpIncluir

local lContinua    := pTRUE
local aApostadores := {}
local lPushButton
local oWindow


	If Len( aApostadores := LoadApostadores() ) > 0

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Inicializa as Variaveis de Dados
			xInitApostaGrupos

			// Inicializa as Variaveis de no vetor aCompeticoes
			xStoreApostaGrupos

			//
			// Atualiza a variaveis com o registro selecionado
			//
			pAPOSTA_GRP_JOGO      := APOSTAS->APT_JOGO
			pAPOSTA_GRP_CONCURSO  := APOSTAS->APT_CONCUR
			pAPOSTA_GRP_SEQUENCIA := APOSTAS->APT_SEQUEN

			// Cria o Objeto Windows
			oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  2
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 34
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  2
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 34
			oWindow:cHeader := PadC( 'Incluir', Len( 'Incluir' ) + 2, ' ')
			oWindow:Open()

			while lContinua

				@ oWindow:nTop+ 1, oWindow:nLeft+12, ;
					oWindow:nTop+ 1, oWindow:nLeft+48 	GET     pAPOSTA_GRP_APOSTADOR                    ;
														LISTBOX aApostadores                             ;
														CAPTION ' Apostador'                             ;
														DROPDOWN                                         ;
														SCROLLBAR                                        ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 1, oWindow:nLeft+58 GET     pAPOSTA_GRP_VALOR                            ;
													PICT    '@EN 99,999.99'                              ;
													CAPTION 'Aposta'                                     ;
													COLOR   SysFieldGet()

				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                   ;
														CAPTION ' Con&firma '                            ;
														COLOR   SysPushButton()                          ;
														STYLE   ''                                       ;
														WHEN    .not. Empty( pAPOSTA_GRP_APOSTADOR )     ;
														STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

				@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                   ;
														CAPTION ' Cance&lar '                            ;
														COLOR   SysPushButton()                          ;
														STYLE   ''                                       ;
														STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

				Set( _SET_CURSOR, SC_NORMAL )

				READ

				Set( _SET_CURSOR, SC_NONE )

				If lContinua .and. LastKey() != K_ESC

					If .not. APOSTAS_GRUPOS->( dbSetOrder(1), dbSeek( pAPOSTA_GRP_JOGO + pAPOSTA_GRP_CONCURSO + pAPOSTA_GRP_APOSTADOR ) )

						begin sequence

							If APOSTAS_GRUPOS->( NetAppend() )
								APOSTAS_GRUPOS->GRP_JOGO   := pAPOSTA_GRP_JOGO
								APOSTAS_GRUPOS->GRP_CONCUR := pAPOSTA_GRP_CONCURSO
								APOSTAS_GRUPOS->GRP_SEQUEN := pAPOSTA_GRP_SEQUENCIA
								APOSTAS_GRUPOS->GRP_APOCOD := pAPOSTA_GRP_APOSTADOR
								APOSTAS_GRUPOS->GRP_VALOR  := pAPOSTA_GRP_VALOR
								APOSTAS_GRUPOS->( dbUnlock() )
							EndIf

						always
							lContinua := pFALSE
						end sequence

					Else
						ErrorTable( 'C04' ) // Apostador ja cadastrado no grupo.
					EndIf

				EndIf

			enddo

		always
			// Fecha o Objeto Windows
			oWindow:Close()
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	Else
		ErrorTable( 'C03' ) // 'Nao existem apostadores cadastrados.
	EndIf

return


/***
*
*	GrpModificar()
*
*	Realiza a manutencao no grupo de apostas dos seguintes concursos
*
*   => Dupla Sena
*   => Loto Facil
*   => Loto Mania
*   => Mega Sena
*   => Quina
*   => Time Mania
*   => Dia de Sorte
*   => Loteca
*   => Lotogol
*
*   MntAposta -> Grupos -> { => } ApoGrupos -> GrpModificar
*
*/
STATIC PROCEDURE GrpModificar

local lContinua    := pTRUE
local aApostadores := {}
local lPushButton
local oWindow


	If Len( aApostadores := LoadApostadores() ) > 0

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Inicializa as Variaveis de Dados
			xInitApostaGrupos

			// Inicializa as Variaveis de no vetor aCompeticoes
			xStoreApostaGrupos

			//
			// Atualiza a variaveis com o registro selecionado
			//
			pAPOSTA_GRP_APOSTADOR := APOSTAS_GRUPOS->GRP_APOCOD
			pAPOSTA_GRP_VALOR     := APOSTAS_GRUPOS->GRP_VALOR

			// Cria o Objeto Windows
			oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  2
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 34
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  2
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 34
			oWindow:cHeader := PadC( 'Modificar', Len( 'Modificar' ) + 2, ' ')
			oWindow:Open()

			while lContinua

				@ oWindow:nTop+ 1, oWindow:nLeft+12, ;
					oWindow:nTop+ 1, oWindow:nLeft+48 	GET     pAPOSTA_GRP_APOSTADOR                    ;
														LISTBOX aApostadores                             ;
														CAPTION ' Apostador'                             ;
														DROPDOWN                                         ;
														SCROLLBAR                                        ;
														WHEN    pFALSE                                   ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 1, oWindow:nLeft+58 GET     pAPOSTA_GRP_VALOR                            ;
													PICT    '@EN 99,999.99'                              ;
													CAPTION 'Aposta'                                     ;
													COLOR   SysFieldGet()

				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                   ;
														CAPTION ' Con&firma '                            ;
														COLOR   SysPushButton()                          ;
														STYLE   ''                                       ;
														STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

				@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                   ;
														CAPTION ' Cance&lar '                            ;
														COLOR   SysPushButton()                          ;
														STYLE   ''                                       ;
														STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

				Set( _SET_CURSOR, SC_NORMAL )

				READ

				Set( _SET_CURSOR, SC_NONE )

				If lContinua .and. LastKey() != K_ESC

					begin sequence

						If APOSTAS_GRUPOS->( NetRLock() )
							APOSTAS_GRUPOS->GRP_VALOR := pAPOSTA_GRP_VALOR
							APOSTAS_GRUPOS->( dbUnlock() )
						EndIf

					always
						lContinua := pFALSE
					end sequence

				EndIf

			enddo

		always
			// Fecha o Objeto Windows
			oWindow:Close()
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	Else
		ErrorTable( 'C03' ) // 'Nao existem apostadores cadastrados.
	EndIf

return


/***
*
*	GrpModificar()
*
*	Realiza a exclusao do apostador no grupo de apostas dos seguintes concursos
*
*   => Dupla Sena
*   => Loto Facil
*   => Loto Mania
*   => Mega Sena
*   => Quina
*   => Time Mania
*   => Dia de Sorte
*   => Loteca
*   => Lotogol
*
*   MntAposta -> Grupos -> { => } ApoGrupos -> GrpExcluir
*
*/
STATIC PROCEDURE GrpExcluir

	If Alert( 'Confirma Exclusao do Registro ?', {' Sim ', ' Nao ' } ) == 1

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Marca o Registro para eliminacao
			If GRP_APOSTADORES->( NetRLock() )
				GRP_APOSTADORES->( DBDelete() )
				GRP_APOSTADORES->( DBUnLock() )
			EndIf

		always
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	EndIf

return


/***
*
*	ApoApostas()
*
*	Realiza a manutencao do Grupos de apostadores da aposta cadastrada dos seguintes jogos
*
*   => Dupla Sena
*   => Loto Facil
*   => Loto Mania
*   => Mega Sena
*   => Quina
*   => Time Mania
*   => Dia de Sorte
*   => Loteca
*   => Lotogol
*
*   MntAposta -> Grupos -> { => } ApoApostas
*
*/
PROCEDURE ApoApostas

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

local aSelDezenas   := {}
local nRow          := 1
local nPointer
local nPosDezenas   := 1


	If .not. Empty( APOSTAS->APT_JOGO ) .and. APOSTAS->APT_JOGO == SystemConcurso()

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 12
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 25
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 12
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 25
			oWindow:cHeader := PadC( 'Apostas', Len( 'Apostas' ) + 2, ' ')
			oWindow:Open()

			// Desenha a Linha de Botoes
			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			// Estabelece o Filtro para exibicao dos registros
			bFiltro := { || APOSTAS_GRUPOS->GRP_JOGO == APOSTAS->APT_JOGO .and. ;
							APOSTAS_GRUPOS->GRP_CONCUR == APOSTAS->APT_CONCUR .and. ;
							APOSTAS_GRUPOS->GRP_SEQUEN == APOSTAS->APT_SEQUEN .and. ;
							.not. APOSTAS_GRUPOS->( Eof() ) }

			dbSelectArea('APOSTAS_GRUPOS')
			APOSTAS_GRUPOS->( dbEval( {|| nMaxItens++ }, bFiltro ) )
			APOSTAS_GRUPOS->( dbSetOrder(1), dbSeek( APOSTAS->APT_JOGO + APOSTAS->APT_CONCUR + APOSTAS->APT_SEQUEN ) )

			begin sequence

				// Exibe o Browse com as Apostas
				oBrowse               	:= 	TBrowseDB( oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
														oWindow:nBottom- 3, oWindow:nRight- 1 )
				oBrowse:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFiltro ) ) <> 0, ( nCount += xRecno, xRecno ), xRecno ) }
				oBrowse:goTopBlock    	:= 	{ || nCount := 1, GoTopDB( bFiltro ) }
				oBrowse:goBottomBlock 	:= 	{ || nCount := nMaxItens, GoBottomDB( bFiltro ) }
				oBrowse:colorSpec     	:= SysBrowseColor()
				oBrowse:headSep       	:= Chr(205)
				oBrowse:colSep        	:= Chr(179)
				oBrowse:Cargo         	:= {}

				// Adiciona as Colunas
				oColumn               := TBColumnNew( PadC('Apostador', 9 ), APOSTAS_GRUPOS->( FieldBlock( 'GRP_APOCOD' ) ) )
				oColumn:picture       := '@!'
				oColumn:width         := 9
				oColumn:colSep        := Chr(179)
				oBrowse:addColumn( oColumn )

				oColumn               := TBColumnNew( '',                    {|| PadR( iif( APOSTADORES->( dbSetOrder(1), dbSeek( APOSTAS_GRUPOS->GRP_APOCOD ) ), AllTrim( APOSTADORES->APO_NOME ), '' ), 24 ) } )
				oColumn:picture       := '@!'
				oColumn:width         := 24
				oColumn:colSep        := Chr(179)
				oBrowse:addColumn( oColumn )

				oColumn               := TBColumnNew( PadC('Rateio', 12 ),   APOSTAS_GRUPOS->( FieldBlock( 'GRP_VALOR' ) ) )
				oColumn:picture       := '@EN 9,999,999.99'
				oColumn:width         := 12
				oColumn:colSep        := Chr(179)
				oBrowse:addColumn( oColumn )

				// Realiza a Montagem da Barra de Rolagem
				oScrollBar           	:= ScrollBar( oWindow:nTop+ 3, oWindow:nBottom- 3, oWindow:nRight )
				oScrollBar:colorSpec 	:= SysScrollBar()
				oScrollBar:display()

				// Desenha os botoes da tela
				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
//				oTmpButton:sBlock    := { || GrpIncluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
//				oTmpButton:sBlock    := { || GrpModificar() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' E&xcluir ' )
//				oTmpButton:sBlock    := { || GrpExcluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' &Sair ' )
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

	Else
		ErrorTable( 'C02' )  // Nao existe aposta selecionada.
	EndIf

return


/***
*
*	LtcApostas()
*
*	Exibe a relacao de apostas cadastradas pas os seguintes jogos
*
*   => Loteca
*
*   MntAposta -> Grupos -> { => } LtcApostas
*
*/
PROCEDURE LtcApostas

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

local bFilCartao
local oCartao

local aSelDezenas   := {}
local nRow          := 1
local nPointer
local nPosDezenas   := 1


	If .not. Empty( APOSTAS->APT_JOGO ) .and. APOSTAS->APT_JOGO == SystemConcurso()

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 15
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 28
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 15
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 28
			oWindow:cHeader := PadC( 'Apostas', Len( 'Apostas' ) + 2, ' ')
			oWindow:Open()

			// Desenha a Linha de Botoes
			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			// Estabelece o Filtro para exibicao dos registros
			bFiltro := { || APOSTAS_ITENS->ITN_JOGO == APOSTAS->APT_JOGO .and. ;
							APOSTAS_ITENS->ITN_CONCUR == APOSTAS->APT_CONCUR .and. ;
							APOSTAS_ITENS->ITN_SEQUEN == APOSTAS->APT_SEQUEN .and. ;
							.not. APOSTAS_ITENS->( Eof() ) }

			dbSelectArea('APOSTAS_ITENS')
			APOSTAS_ITENS->( dbEval( {|| nMaxItens++ }, bFiltro ) )
			APOSTAS_ITENS->( dbSetOrder(1), dbSeek( APOSTAS->APT_JOGO + APOSTAS->APT_CONCUR + APOSTAS->APT_SEQUEN ) )

			begin sequence

				// Exibe o Browse com as Apostas
				oBrowse               	:= 	TBrowseDB( oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
														oWindow:nBottom-20, oWindow:nRight- 1 )
				oBrowse:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFiltro ) ) <> 0, ( nCount += xRecno, xRecno ), xRecno ) }
				oBrowse:goTopBlock    	:= 	{ || nCount := 1, GoTopDB( bFiltro ) }
				oBrowse:goBottomBlock 	:= 	{ || nCount := nMaxItens, GoBottomDB( bFiltro ) }
				oBrowse:colorSpec     	:= SysBrowseColor()
				oBrowse:headSep       	:= Chr(205)
				oBrowse:colSep        	:= Chr(179)
				oBrowse:Cargo         	:= {}

				// Adiciona as Colunas
				oColumn               := TBColumnNew( PadC('Concurso', 10 ), APOSTAS_ITENS->( FieldBlock( 'ITN_CONCUR' ) ) )
				oColumn:picture       := '@!'
				oColumn:width         := 10
				oColumn:colSep        := Chr(179)
				oBrowse:addColumn( oColumn )

				oColumn               := TBColumnNew( PadC('Item', 10 ),     APOSTAS_ITENS->( FieldBlock( 'ITN_ITEM' ) ) )
				oColumn:picture       := '@!'
				oColumn:width         := 10
				oColumn:colSep        := Chr(179)
				oBrowse:addColumn( oColumn )

				oColumn               := TBColumnNew( PadC('Valor', 12 ),   APOSTAS_ITENS->( FieldBlock( 'ITN_VALOR' ) ) )
				oColumn:picture       := '@EN 9,999,999.99'
				oColumn:width         := 12
				oColumn:colSep        := Chr(179)
				oBrowse:addColumn( oColumn )

				// Monta a browse com os clubes da competicao
				begin sequence

					// Desenha a Linha de dividindo as aapostas dos Cartoes
					hb_DispBox( oWindow:nBottom-19, oWindow:nLeft+ 1, ;
								oWindow:nBottom-19, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					bFilCartao := { || 	APOSTAS_CLUBES->CLB_JOGO == APOSTAS_ITENS->ITN_JOGO .and. ;
										APOSTAS_CLUBES->CLB_CONCUR == APOSTAS_ITENS->ITN_CONCUR .and. ;
										APOSTAS_CLUBES->CLB_SEQUEN == APOSTAS_ITENS->ITN_SEQUEN .and. ;
										.not. APOSTAS_CLUBES->( Eof() ) }

					oCartao               := TBrowseDB( oWindow:nBottom-18, oWindow:nLeft+ 1,   ;
														oWindow:nBottom- 3, oWindow:nRight- 1 )
					oCartao:skipBlock     := { |xSkip| APOSTAS_CLUBES->( DBSkipper( xSkip, bFilCartao ) ) }
					oCartao:goTopBlock    := { || APOSTAS_CLUBES->( GoTopDB( bFilCartao ) ) }
					oCartao:goBottomBlock := { || APOSTAS_CLUBES->( GoBottomDB( bFilCartao ) ) }
					oCartao:colorSpec     := SysBrowseColor()
					oCartao:headSep       := Chr(205)
					oCartao:colSep        := Chr(179)
					oCartao:autoLite      := pFALSE

					oColumn            := TBColumnNew( '',                      { || APOSTAS_CLUBES->CLB_FAIXA } )
					oColumn:picture    := '@!'
					oColumn:width      := 02
					oCartao:addColumn( oColumn )

					oColumn            := TBColumnNew( PadC( 'Coluna 1', 20 ),  {|| PadL( iif( CLUBES->( dbSetOrder(1), dbSeek( APOSTAS_CLUBES->CLB_COL1 ) ), AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), '' ), 20 ) } )
					oColumn:picture    := '@!'
					oColumn:width      := 20
					oCartao:addColumn( oColumn )

					oColumn            := TBColumnNew( '1',                     {|| iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', 'X', '' ) } )
					oColumn:picture    := '@!'
					oColumn:width      := 1
					oCartao:addColumn( oColumn )

					oColumn            := TBColumnNew( 'X',                     {|| iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', 'X', '' ) } )
					oColumn:picture    := '@!'
					oColumn:width      := 1
					oCartao:addColumn( oColumn )

					oColumn            := TBColumnNew( '2',                     {|| iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', 'X', '' ) } )
					oColumn:picture    := '@!'
					oColumn:width      := 1
					oCartao:addColumn( oColumn )

					oColumn            := TBColumnNew( PadC( 'Coluna 2', 20 ),  {|| PadR( iif( CLUBES->( dbSetOrder(1), dbSeek( APOSTAS_CLUBES->CLB_COL2 ) ), AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), '' ), 20 ) } )
					oColumn:picture    := '@!'
					oColumn:width      := 20
					oCartao:addColumn( oColumn )

					oColumn            := TBColumnNew( 'D',                     {|| iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', 'X', '' ) } )
					oColumn:picture    := '@!'
					oColumn:width      := 1
					oCartao:addColumn( oColumn )

					oColumn            := TBColumnNew( 'T',                     {|| iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', 'X', '' ) } )
					oColumn:picture    := '@!'
					oColumn:width      := 1
					oCartao:addColumn( oColumn )

				end sequence

				// Realiza a Montagem da Barra de Rolagem
				oScrollBar           	:= ScrollBar( oWindow:nTop+ 3, oWindow:nBottom- 3, oWindow:nRight )
				oScrollBar:colorSpec 	:= SysScrollBar()
				oScrollBar:display()

				// Desenha os botoes da tela
				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
				oTmpButton:sBlock    := { || LtcApoIncluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
				oTmpButton:sBlock    := { || LtcApoModificar() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' E&xcluir ' )
				oTmpButton:sBlock    := { || LtcApoExcluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' &Sair ' )
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

					If APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( APOSTAS_ITENS->ITN_JOGO + APOSTAS_ITENS->ITN_CONCUR + APOSTAS_ITENS->ITN_SEQUEN + APOSTAS_ITENS->ITN_ITEM ) )
						DispBegin()
						oCartao:refreshAll()
						oCartao:forceStable()
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

	Else
		ErrorTable( 'C02' )  // Nao existe aposta selecionada.
	EndIf

return


/***
*
*	LtcApoIncluir()
*
*	Rotina para realizar a inclusao do cartao da aposta da Loteca.
*
*   => Loteca
*
*   MntAposta -> Grupos -> { => } LtcApostas -> LtcApoIncluir
*
*/
STATIC PROCEDURE LtcApoIncluir

local lContinua   := pTRUE
local aClubes     := {}
local lPushButton
local oWindow
local oIniFile
local nCount
local nItem
local lFailSelect
local nCountDuplo
local nCountTriplo

local oBrowse, oColumn
local lDisplay    := pTRUE
local nRow        := 1


	//************************************************************************
	//*Carrega o Cadastro de Clubes                                          *
	//************************************************************************
	If Len( aClubes := LoadClubes() ) > 0

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Inicializa as Variaveis de Dados
			xInitApostaLoteca

			// Define o conteudo das variaveis do cartao para o cadastro 
			xStoreApostaLoteca

			pLTC_APOSTA_ITEM_JOGO      := APOSTAS_ITENS->ITN_JOGO
			pLTC_APOSTA_ITEM_CONCURSO  := APOSTAS_ITENS->ITN_CONCUR
			pLTC_APOSTA_ITEM_SEQUENCIA := APOSTAS_ITENS->ITN_SEQUEN

			// Realiza a abertura do arquivo INI
			oIniFile := TIniFile():New( 'odin.ini' )

			// Realiza a leitura dos dados do arquivo de configuracao						
			pLTC_APOSTA_ITEM_CLUBE_COL_1_01 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_01', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_02 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_02', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_03 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_03', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_04 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_04', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_05 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_05', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_06 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_06', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_07 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_07', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_08 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_08', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_09 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_09', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_10 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_10', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_11 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_11', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_12 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_12', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_13 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_13', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_1_14 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_1_14', Space(5) )

			pLTC_APOSTA_ITEM_CLUBE_COL_2_01 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_01', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_02 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_02', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_03 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_03', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_04 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_04', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_05 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_05', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_06 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_06', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_07 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_07', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_08 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_08', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_09 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_09', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_10 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_10', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_11 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_11', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_12 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_12', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_13 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_13', Space(5) )
			pLTC_APOSTA_ITEM_CLUBE_COL_2_14 := oIniFile:ReadString( 'LOTECA', 'LTC_COLUNA_2_14', Space(5) )

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 10
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 35
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 10
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 35
			oWindow:cHeader := PadC( 'Incluir', Len( 'Incluir' ) + 2, ' ')
			oWindow:Open()

			while lContinua

				@ oWindow:nTop+ 1, oWindow:nLeft+19 GET     pLTC_APOSTA_ITEM_CONCURSO                       ;
													PICT    '@!'                                            ;
													CAPTION 'Concurso'                                      ;
													WHEN    pFALSE                                          ;
													COLOR   SysFieldGet()

				@ oWindow:nTop+ 1, oWindow:nLeft+51 GET     pLTC_APOSTA_ITEM_VALOR                          ;
													PICT    '@EN 99,999.99'                                 ;
													CAPTION 'Aposta'                                        ;
													COLOR   SysFieldGet()

				hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
							oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				// Realiza a Montagem das Colunas para marcacao das Apostas
				hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+27, ;
							oWindow:nBottom- 3, oWindow:nLeft+27, oWindow:cBorder, SystemFormColor() )
				hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+31, ;
							oWindow:nBottom- 3, oWindow:nLeft+31, oWindow:cBorder, SystemFormColor() )
				hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+35, ;
							oWindow:nBottom- 3, oWindow:nLeft+35, oWindow:cBorder, SystemFormColor() )
				hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+39, ;
							oWindow:nBottom- 3, oWindow:nLeft+39, oWindow:cBorder, SystemFormColor() )

				// Realiza a Montagem do cabecario das colunas
				@ oWindow:nTop+ 3, oWindow:nLeft+29 SAY     '1'                                             ;
													COLOR   SystemLabelColor()

				@ oWindow:nTop+ 3, oWindow:nLeft+33 SAY     'X'                                             ;
													COLOR   SystemLabelColor()

				@ oWindow:nTop+ 3, oWindow:nLeft+37 SAY     '2'                                             ;
													COLOR   SystemLabelColor()

				// Define a Primeira Linha
				@ oWindow:nTop+ 4, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 4, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_01             ;
														LISTBOX aClubes                                     ;
														CAPTION ' 1 -'                                      ;
														DROPDOWN                                            ;
														SCROLLBAR                                           ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 4, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_01              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 4, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_01              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 4, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_01              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 4, oWindow:nLeft+40, ;
					oWindow:nTop+ 4, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_01             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Segunda Linha
				@ oWindow:nTop+ 5, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 5, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_02             ;
														LISTBOX aClubes                                     ;
														CAPTION ' 2 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 5, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_02              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 5, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_02              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 5, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_02              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 5, oWindow:nLeft+40, ;
					oWindow:nTop+ 5, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_02             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Terceira Linha
				@ oWindow:nTop+ 6, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 6, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_03             ;
														LISTBOX aClubes                                     ;
														CAPTION ' 3 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 6, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_03              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 6, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_03              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 6, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_03              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 6, oWindow:nLeft+40, ;
					oWindow:nTop+ 6, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_03             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Quarta Linha
				@ oWindow:nTop+ 7, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 7, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_04             ;
														LISTBOX aClubes                                     ;
														CAPTION ' 4 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 7, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_04              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 7, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_04              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 7, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_04              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 7, oWindow:nLeft+40, ;
					oWindow:nTop+ 7, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_04             ; 
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Quinta Linha
				@ oWindow:nTop+ 8, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 8, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_05             ;
														LISTBOX aClubes                                     ;
														CAPTION ' 5 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 8, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_05              ;
													CHECKBOX                                                ; 
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 8, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_05              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 8, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_05              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 8, oWindow:nLeft+40, ;
					oWindow:nTop+ 8, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_05             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Sexta Linha
				@ oWindow:nTop+ 9, oWindow:nLeft+ 6, ;
					oWindow:nTop+ 9, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_06             ;
														LISTBOX aClubes                                     ;
														CAPTION ' 6 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 9, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_06              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 9, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_06              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 9, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_06              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+ 9, oWindow:nLeft+40, ;
					oWindow:nTop+ 9, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_06             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Setima Linha
				@ oWindow:nTop+10, oWindow:nLeft+ 6, ;
					oWindow:nTop+10, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_07             ;
														LISTBOX aClubes                                     ;
														CAPTION ' 7 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+10, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_07              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+10, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_07              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+10, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_07              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+10, oWindow:nLeft+40, ;
					oWindow:nTop+10, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_07             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Oitava Linha
				@ oWindow:nTop+11, oWindow:nLeft+ 6, ;
					oWindow:nTop+11, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_08             ;
														LISTBOX aClubes                                     ;
														CAPTION ' 8 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+11, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_08              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+11, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_08              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+11, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_08              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+11, oWindow:nLeft+40, ;
					oWindow:nTop+11, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_08             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Nona Linha
				@ oWindow:nTop+12, oWindow:nLeft+ 6, ;
					oWindow:nTop+12, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_09             ;
														LISTBOX aClubes                                     ;
														CAPTION ' 9 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+12, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_09              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+12, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_09              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+12, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_09              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+12, oWindow:nLeft+40, ;
					oWindow:nTop+12, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_09             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Decima Linha
				@ oWindow:nTop+13, oWindow:nLeft+ 6, ;
					oWindow:nTop+13, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_10             ;
														LISTBOX aClubes                                     ;
														CAPTION '10 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+13, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_10              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+13, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_10              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+13, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_10              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+13, oWindow:nLeft+40, ;
					oWindow:nTop+13, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_10             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Decima Primeira Linha
				@ oWindow:nTop+14, oWindow:nLeft+ 6, ;
					oWindow:nTop+14, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_11             ;
														LISTBOX aClubes                                     ;
														CAPTION '11 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+14, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_11              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+14, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_11              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+14, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_11              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+14, oWindow:nLeft+40, ;
					oWindow:nTop+14, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_11             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Decima Segunda Linha
				@ oWindow:nTop+15, oWindow:nLeft+ 6, ;
					oWindow:nTop+15, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_12             ;
														LISTBOX aClubes                                     ;
														CAPTION '12 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+15, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_12              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+15, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_12              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+15, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_12              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+15, oWindow:nLeft+40, ;
					oWindow:nTop+15, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_12             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Decima Terceira Linha
				@ oWindow:nTop+16, oWindow:nLeft+ 6, ;
					oWindow:nTop+16, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_13             ;
														LISTBOX aClubes                                     ;
														CAPTION '13 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+16, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_13              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+16, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_13              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+16, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_13              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+16, oWindow:nLeft+40, ;
					oWindow:nTop+16, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_13             ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				// Define a Decima Quarta Linha
				@ oWindow:nTop+17, oWindow:nLeft+ 6, ;
					oWindow:nTop+17, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_14             ;
														LISTBOX aClubes                                     ;
														CAPTION '14 -'                                      ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+17, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_14              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+17, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_14              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+17, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_14              ;
													CHECKBOX                                                ;
													STYLE   '[X ]'                                          ;
													COLOR   SysFieldCheckBox()                              ;
													STATE   { || oBrowse:forceStable() }

				@ oWindow:nTop+17, oWindow:nLeft+40, ;
					oWindow:nTop+17, oWindow:nLeft+60 	GET     	pLTC_APOSTA_ITEM_CLUBE_COL_2_14         ;
														LISTBOX aClubes                                     ;
														DROPDOWN                                            ;
														COLOR   SysFieldListBox()

				begin sequence

					hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+61, ;
								oWindow:nBottom- 3, oWindow:nLeft+61, oWindow:cBorder, SystemFormColor() )

					oBrowse               := TBrowseNew( oWindow:nTop+ 3, oWindow:nLeft+62, ;
															oWindow:nBottom- 3, oWindow:nRight- 1 )
					oBrowse:skipBlock	:= 	{	|x,k| ;
													k := iif(Abs(x) >= iif( x >= 0,                                           ;
																	Len( aCartao[ pLTC_POS_DADOS ][6] ) - nRow, nRow - 1),    ;
														iif(x >= 0, Len( aCartao[ pLTC_POS_DADOS ][6] ) - nRow,1 - nRow), x ) ;
															, nRow += k, k                                                    ;
											}
					oBrowse:goTopBlock    := { || nRow := 1 }
					oBrowse:goBottomBlock := { || nRow := Len( aCartao[ pLTC_POS_DADOS ][6] ) }
					oBrowse:colorSpec     := SysBrowseColor()
					oBrowse:colSep        := Chr(179)
					oBrowse:autoLite      := pFALSE

					oColumn            := TBColumnNew( PadC( 'D', 3 ), { || iif(aCartao[ pLTC_POS_DADOS ][3][ nRow ] .and.                    ;
																					aCartao[ pLTC_POS_DADOS ][4][ nRow ] .and. .not.          ;
																					aCartao[ pLTC_POS_DADOS ][5][ nRow ], '[X]',              ;
																					iif( aCartao[ pLTC_POS_DADOS ][3][ nRow ] .and.           ;
																						aCartao[ pLTC_POS_DADOS ][5][ nRow ] .and. .not.      ;
																						aCartao[ pLTC_POS_DADOS ][4][ nRow ], '[X]',          ;
																						iif(aCartao[ pLTC_POS_DADOS ][4][ nRow ] .and.        ;
																							aCartao[ pLTC_POS_DADOS ][5][ nRow ] .and. .not.  ;
																							aCartao[ pLTC_POS_DADOS ][3][ nRow ], '[X]', '[ ]' ) ) ) } )
					oColumn:width      := 3
					oBrowse:addColumn( oColumn )

					oColumn            := TBColumnNew( PadC( 'T', 3 ), { || iif(aCartao[ pLTC_POS_DADOS ][3][ nRow ] .and.                 ;
																					aCartao[ pLTC_POS_DADOS ][4][ nRow ] .and.             ;
																					aCartao[ pLTC_POS_DADOS ][5][ nRow ], '[X]', '[ ]' ) } )
					oColumn:width      := 3
					oBrowse:addColumn( oColumn )

				always
					oBrowse:forceStable()
				end sequence

				@ oWindow:nTop+ 3, oWindow:nLeft+62, ;
					oWindow:nBottom- 3, oWindow:nRight- 1 	GET     lDisplay                                ;
															TBROWSE oBrowse                                 ;
															WHEN    pFALSE

				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                      ;
														CAPTION ' Con&firma '                               ;
														COLOR   SysPushButton()                             ;
														STYLE   ''                                          ;
														WHEN    .not. Empty( pLTC_APOSTA_ITEM_VALOR ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_01 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_01 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_02 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_02 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_03 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_03 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_04 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_04 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_05 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_05 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_06 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_06 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_07 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_07 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_08 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_08 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_09 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_09 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_10 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_10 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_11 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_11 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_12 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_12 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_13 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_13 ) .and. ;
																.not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_1_14 ) .and. .not. Empty( pLTC_APOSTA_ITEM_CLUBE_COL_2_14 )       ;
														STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

				@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                      ;
														CAPTION ' Cance&lar '                               ;
														COLOR   SysPushButton()                             ;
														STYLE   ''                                          ;
														STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

				Set( _SET_CURSOR, SC_NORMAL )

				READ

				Set( _SET_CURSOR, SC_NONE )

				If lContinua .and. LastKey() != K_ESC

					// Realiza a gravacao no arquivo de configuracao
					begin sequence

						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_01', pLTC_APOSTA_ITEM_CLUBE_COL_1_01, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_02', pLTC_APOSTA_ITEM_CLUBE_COL_1_02, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_03', pLTC_APOSTA_ITEM_CLUBE_COL_1_03, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_04', pLTC_APOSTA_ITEM_CLUBE_COL_1_04, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_05', pLTC_APOSTA_ITEM_CLUBE_COL_1_05, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_06', pLTC_APOSTA_ITEM_CLUBE_COL_1_06, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_07', pLTC_APOSTA_ITEM_CLUBE_COL_1_07, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_08', pLTC_APOSTA_ITEM_CLUBE_COL_1_08, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_09', pLTC_APOSTA_ITEM_CLUBE_COL_1_09, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_10', pLTC_APOSTA_ITEM_CLUBE_COL_1_10, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_11', pLTC_APOSTA_ITEM_CLUBE_COL_1_11, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_12', pLTC_APOSTA_ITEM_CLUBE_COL_1_12, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_13', pLTC_APOSTA_ITEM_CLUBE_COL_1_13, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_1_14', pLTC_APOSTA_ITEM_CLUBE_COL_1_14, 'ODIN.INI' )

						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_01', pLTC_APOSTA_ITEM_CLUBE_COL_2_01, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_02', pLTC_APOSTA_ITEM_CLUBE_COL_2_02, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_03', pLTC_APOSTA_ITEM_CLUBE_COL_2_03, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_04', pLTC_APOSTA_ITEM_CLUBE_COL_2_04, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_05', pLTC_APOSTA_ITEM_CLUBE_COL_2_05, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_06', pLTC_APOSTA_ITEM_CLUBE_COL_2_06, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_07', pLTC_APOSTA_ITEM_CLUBE_COL_2_07, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_08', pLTC_APOSTA_ITEM_CLUBE_COL_2_08, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_09', pLTC_APOSTA_ITEM_CLUBE_COL_2_09, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_10', pLTC_APOSTA_ITEM_CLUBE_COL_2_10, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_11', pLTC_APOSTA_ITEM_CLUBE_COL_2_11, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_12', pLTC_APOSTA_ITEM_CLUBE_COL_2_12, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_13', pLTC_APOSTA_ITEM_CLUBE_COL_2_13, 'ODIN.INI' )
						oIniFile:WriteString( 'LOTECA', 'LTC_COLUNA_2_14', pLTC_APOSTA_ITEM_CLUBE_COL_2_14, 'ODIN.INI' )

					always
						oIniFile:UpdateFile()
					end sequence


					// Verifica se se todos os jogos foram selecionados os resultados e
					// atualiza as colunas de Duplo e Triplo
					begin sequence

						lFailSelect := pFALSE
						for nCount := 1 to Len( aCartao[ pLTC_POS_DADOS ][3] )
							If aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
								aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pFALSE
								aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
							ElseIf aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
								aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pFALSE
								aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
							ElseIf aCartao[ pLTC_POS_DADOS ][5][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][4][ nCount ]
								aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pFALSE
								aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
							ElseIf aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
								aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pTRUE
								aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
							ElseIf aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][5][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][4][ nCount ]
								aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pTRUE
								aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
							ElseIf aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][5][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][3][ nCount ]
								aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pTRUE
								aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
							ElseIf aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
								aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pFALSE
								aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pTRUE
							ElseIf .not. aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
								lFailSelect := pTRUE
							EndIf
						next

					always
						// Necessario informar no minimo um duplo ou um triplo
						nCountDuplo := 0
						AEval( aCartao[ pLTC_POS_DADOS ][6], { |xJogo| iif( xJogo, nCountDuplo++, Nil ) } )

						nCountTriplo := 0
						AEval( aCartao[ pLTC_POS_DADOS ][7], { |xJogo| iif( xJogo, nCountTriplo++, Nil ) } )
					end sequence


					// Identifica o proximo item e inicia o processo de gravacao do cartao
					begin sequence

						// Estabelece o Filtro para pesquisa dos registros
						nItem := 1
						pLTC_APOSTA_ITEM_ITEM := StrZero( nItem++, 3 )
						while APOSTAS_ITENS->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM ) )
							pLTC_APOSTA_ITEM_ITEM := StrZero( nItem++, 3 )
						enddo

					always

						If .not. lFailSelect
							If nCountDuplo > 0 .or. nCountTriplo > 0
								If LtcGrvCartao()
									lContinua := pFALSE
								EndIf
							Else
								ErrorTable( '027' )  // Necessario informar no minimo um duplo ou triplo.
							EndIf
						Else
							ErrorTable( '012' )  // Selecione o resultado da partida.
						EndIf

					end sequence

				EndIf

			enddo

		always
			// Fecha o Objeto Windows
			oWindow:Close()
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	Else
		ErrorTable( '020' )  // Nao existem clubes cadastrados.
	EndIf

return


/***
*
*	LtcApoModificar()
*
*	Rotina para realizar as alteracoes no cartao da aposta da Loteca.
*
*   => Loteca
*
*   MntAposta -> Grupos -> { => } LtcApostas -> LtcApoModificar
*
*/
STATIC PROCEDURE LtcApoModificar

local aClubes    := {}
local lContinua  := pTRUE
local lPushButton
local oWindow
local nCount
local lFailSelect
local nCountDuplo
local nCountTriplo

local oBrowse, oColumn
local cDisplay    := ''
local nRow        := 1


	If .not. Empty( APOSTAS_ITENS->ITN_JOGO ) .and. APOSTAS_ITENS->ITN_JOGO == APOSTAS->APT_JOGO
		
		//************************************************************************
		//*Carrega o Cadastro de Clubes                                          *
		//************************************************************************
		If Len( aClubes := LoadClubes() ) > 0

			begin sequence
			
				// Salva a Area corrente na Pilha
				DstkPush()
				
				// Inicializa as Variaveis de Dados
				xInitApostaLoteca

				// Define o conteudo das variaveis do cartao para o cadastro 
				xStoreApostaLoteca

				pLTC_APOSTA_ITEM_JOGO      := APOSTAS_ITENS->ITN_JOGO
				pLTC_APOSTA_ITEM_CONCURSO  := APOSTAS_ITENS->ITN_CONCUR
				pLTC_APOSTA_ITEM_SEQUENCIA := APOSTAS_ITENS->ITN_SEQUEN
				pLTC_APOSTA_ITEM_ITEM      := APOSTAS_ITENS->ITN_ITEM				
				pLTC_APOSTA_ITEM_VALOR     := APOSTAS_ITENS->ITN_VALOR

				
				//************************************************************************
				//*Carrega a Premicao do Concurso                                        *
				//************************************************************************
				If APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( APOSTAS_ITENS->ITN_JOGO + APOSTAS_ITENS->ITN_CONCUR + APOSTAS_ITENS->ITN_SEQUEN + APOSTAS_ITENS->ITN_ITEM ) )
					while APOSTAS_CLUBES->CLB_JOGO == APOSTAS_ITENS->ITN_JOGO .and. ;
							APOSTAS_CLUBES->CLB_CONCUR == APOSTAS_ITENS->ITN_CONCUR .and. ;
							APOSTAS_CLUBES->CLB_SEQUEN == APOSTAS_ITENS->ITN_SEQUEN .and. ;
							APOSTAS_CLUBES->CLB_ITEM == APOSTAS_ITENS->ITN_ITEM .and. ;
							.not. APOSTAS_CLUBES->( Eof() )
						do case
							case APOSTAS_CLUBES->CLB_FAIXA == '01'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_01    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_01    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_01 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_01 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_01 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_01    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_01   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '02'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_02    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_02    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_02 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_02 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_02 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_02    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_02   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '03'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_03    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_03    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_03 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_03 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_03 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_03    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_03   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '04'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_04    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_04    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_04 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_04 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_04 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_04    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_04   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '05'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_05    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_05    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_05 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_05 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_05 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_05    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_05   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '06'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_06    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_06    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_06 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_06 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_06 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_06    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_06   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '07'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_07    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_07    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_07 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_07 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_07 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_07    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_07   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '08'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_08    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_08    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_08 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_08 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_08 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_08    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_08   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '09'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_09    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_09    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_09 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_09 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_09 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_09    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_09   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '10'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_10    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_10    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_10 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_10 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_10 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_10    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_10   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '11'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_11    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_11    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_11 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_11 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_11 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_11    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_11   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '12'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_12    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_12    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_12 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_12 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_12 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_12    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_12   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '13'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_13   := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_13   := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_13 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_13 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_13 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_13    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_13   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
							case APOSTAS_CLUBES->CLB_FAIXA == '14'
								pLTC_APOSTA_ITEM_CLUBE_COL_1_14    := APOSTAS_CLUBES->CLB_COL1
								pLTC_APOSTA_ITEM_CLUBE_COL_2_14    := APOSTAS_CLUBES->CLB_COL2
								pLTC_APOSTA_ITEM_CLUBE_RESULT_1_14 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 1, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_2_14 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 2, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_RESULT_3_14 := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 3, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_DUPLO_14    := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 4, 1 ) == '1', pTRUE, pFALSE )
								pLTC_APOSTA_ITEM_CLUBE_TRIPLO_14   := iif( SubStr( APOSTAS_CLUBES->CLB_RESULT, 5, 1 ) == '1', pTRUE, pFALSE )
						endcase
						APOSTAS_CLUBES->( dbSkip() )
					enddo
				EndIf

				// Cria o Objeto Windows
				oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 10
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 35
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 10
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 35
				oWindow:cHeader := PadC( 'Modificar', Len( 'Modificar' ) + 2, ' ')
				oWindow:Open()

				while lContinua

					@ oWindow:nTop+ 1, oWindow:nLeft+19 GET     pLTC_APOSTA_ITEM_CONCURSO             ;
														PICT    '@!'                                  ;
														CAPTION 'Concurso'                            ;
														WHEN    pFALSE                                ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 1, oWindow:nLeft+51 GET     pLTC_APOSTA_ITEM_VALOR                ;
														VALID   .not. Empty( pLTC_APOSTA_ITEM_VALOR ) ;
														PICT    '@EN 99,999.99'                       ;
														CAPTION 'Aposta'                              ;
														COLOR   SysFieldGet()
					
					hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					
					// Realiza a Montagem das Colunas para Apostas
					hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+27, ;
								oWindow:nBottom- 3, oWindow:nLeft+27, oWindow:cBorder, SystemFormColor() )
					hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+31, ;
								oWindow:nBottom- 3, oWindow:nLeft+31, oWindow:cBorder, SystemFormColor() )
					hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+35, ;
								oWindow:nBottom- 3, oWindow:nLeft+35, oWindow:cBorder, SystemFormColor() )
					hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+39, ;
								oWindow:nBottom- 3, oWindow:nLeft+39, oWindow:cBorder, SystemFormColor() )
					
					// Realiza a Montagem do cabecario das colunas
					@ oWindow:nTop+ 3, oWindow:nLeft+29 SAY     '1'                                   ;
														COLOR   SystemLabelColor()
					
					@ oWindow:nTop+ 3, oWindow:nLeft+33 SAY     'X'                                   ;
														COLOR   SystemLabelColor()
					
					@ oWindow:nTop+ 3, oWindow:nLeft+37 SAY     '2'                                   ;
														COLOR   SystemLabelColor()
					
					@ oWindow:nTop+ 3, oWindow:nLeft+63 SAY     'D'                                   ;
														COLOR   SystemLabelColor()
					
					@ oWindow:nTop+ 3, oWindow:nLeft+67 SAY     'T'                                   ;
														COLOR   SystemLabelColor()
					
					
					// Define a Primeira Linha
					@ oWindow:nTop+ 4, oWindow:nLeft+ 6, ;
						oWindow:nTop+ 4, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_01   ;
															LISTBOX aClubes                           ;
															CAPTION ' 1 -'                            ;
															DROPDOWN                                  ;
															SCROLLBAR                                 ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+ 4, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_01    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 4, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_01    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 4, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_01    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 4, oWindow:nLeft+40, ;
						oWindow:nTop+ 4, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_01   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Segunda Linha
					@ oWindow:nTop+ 5, oWindow:nLeft+ 6, ;
						oWindow:nTop+ 5, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_02   ;
															LISTBOX aClubes                           ;
															CAPTION ' 2 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+ 5, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_02    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 5, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_02    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 5, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_02    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 5, oWindow:nLeft+40, ;
						oWindow:nTop+ 5, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_02   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Terceira Linha
					@ oWindow:nTop+ 6, oWindow:nLeft+ 6, ;
						oWindow:nTop+ 6, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_03   ;
															LISTBOX aClubes                           ;
															CAPTION ' 3 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+ 6, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_03    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }

					@ oWindow:nTop+ 6, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_03    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 6, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_03    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 6, oWindow:nLeft+40, ;
						oWindow:nTop+ 6, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_03   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Quarta Linha
					@ oWindow:nTop+ 7, oWindow:nLeft+ 6, ;
						oWindow:nTop+ 7, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_04   ;
															LISTBOX aClubes                           ;
															CAPTION ' 4 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+ 7, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_04    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 7, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_04    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 7, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_04    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 7, oWindow:nLeft+40, ;
						oWindow:nTop+ 7, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_04   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Quinta Linha
					@ oWindow:nTop+ 8, oWindow:nLeft+ 6, ;
						oWindow:nTop+ 8, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_05   ;
															LISTBOX aClubes                           ;
															CAPTION ' 5 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+ 8, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_05    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 8, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_05    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 8, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_05    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 8, oWindow:nLeft+40, ;
						oWindow:nTop+ 8, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_05   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Sexta Linha
					@ oWindow:nTop+ 9, oWindow:nLeft+ 6, ;
						oWindow:nTop+ 9, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_06   ;
															LISTBOX aClubes                           ;
															CAPTION ' 6 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+ 9, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_06    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 9, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_06    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 9, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_06    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+ 9, oWindow:nLeft+40, ;
						oWindow:nTop+ 9, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_06   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Setima Linha
					@ oWindow:nTop+10, oWindow:nLeft+ 6, ;
						oWindow:nTop+10, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_07   ;
															LISTBOX aClubes                           ;
															CAPTION ' 7 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+10, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_07    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+10, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_07    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+10, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_07    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+10, oWindow:nLeft+40, ;
						oWindow:nTop+10, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_07   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Oitava Linha
					@ oWindow:nTop+11, oWindow:nLeft+ 6, ;
						oWindow:nTop+11, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_08   ;
															LISTBOX aClubes                           ;
															CAPTION ' 8 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+11, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_08    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+11, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_08    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+11, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_08    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+11, oWindow:nLeft+40, ;
						oWindow:nTop+11, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_08   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Nona Linha
					@ oWindow:nTop+12, oWindow:nLeft+ 6, ;
						oWindow:nTop+12, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_09   ;
															LISTBOX aClubes                           ;
															CAPTION ' 9 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+12, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_09    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+12, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_09    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+12, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_09    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+12, oWindow:nLeft+40, ;
						oWindow:nTop+12, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_09   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Decima Linha
					@ oWindow:nTop+13, oWindow:nLeft+ 6, ;
						oWindow:nTop+13, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_10   ;
															LISTBOX aClubes                           ;
															CAPTION '10 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+13, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_10    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+13, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_10    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+13, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_10    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+13, oWindow:nLeft+40, ;
						oWindow:nTop+13, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_10   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Decima Primeira Linha
					@ oWindow:nTop+14, oWindow:nLeft+ 6, ;
						oWindow:nTop+14, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_11   ;
															LISTBOX aClubes                           ;
															CAPTION '11 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+14, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_11    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+14, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_11    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+14, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_11    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+14, oWindow:nLeft+40, ;
						oWindow:nTop+14, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_11   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Decima Segunda Linha
					@ oWindow:nTop+15, oWindow:nLeft+ 6, ;
						oWindow:nTop+15, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_12   ;
															LISTBOX aClubes                           ;
															CAPTION '12 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+15, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_12    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+15, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_12    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+15, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_12    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+15, oWindow:nLeft+40, ;
						oWindow:nTop+15, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_12   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Decima Terceira Linha
					@ oWindow:nTop+16, oWindow:nLeft+ 6, ;
						oWindow:nTop+16, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_13   ;
															LISTBOX aClubes                           ;
															CAPTION '13 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+16, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_13    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+16, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_13    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+16, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_13    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+16, oWindow:nLeft+40, ;
						oWindow:nTop+16, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_13   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					// Define a Decima Quarta Linha
					@ oWindow:nTop+17, oWindow:nLeft+ 6, ;
						oWindow:nTop+17, oWindow:nLeft+26 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_1_14   ;
															LISTBOX aClubes                           ;
															CAPTION '14 -'                            ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()
					
					@ oWindow:nTop+17, oWindow:nLeft+28 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_1_14    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+17, oWindow:nLeft+32 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_2_14    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }
					
					@ oWindow:nTop+17, oWindow:nLeft+36 GET     pLTC_APOSTA_ITEM_CLUBE_RESULT_3_14    ;
														CHECKBOX                                      ;
														STYLE   '[X ]'                                ;
														COLOR   SysFieldCheckBox()                    ;
														STATE   { || oBrowse:forceStable() }

					@ oWindow:nTop+17, oWindow:nLeft+40, ;
						oWindow:nTop+17, oWindow:nLeft+60 	GET     pLTC_APOSTA_ITEM_CLUBE_COL_2_14   ;
															LISTBOX aClubes                           ;
															DROPDOWN                                  ;
															COLOR   SysFieldListBox()

					begin sequence

						hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+61, ;
							oWindow:nBottom- 3, oWindow:nLeft+61, oWindow:cBorder, SystemFormColor() )

						oBrowse               := TBrowseNew(oWindow:nTop+ 3, oWindow:nLeft+62, ;
															oWindow:nBottom- 3, oWindow:nRight- 1 )
						oBrowse:skipBlock     := {|x,k| ;
														k := iif( Abs(x) >= iif( x >= 0,                                       ;
																	Len( aCartao[ pLTC_POS_DADOS ][6] ) - nRow, nRow - 1),    ;
														iif(x >= 0, Len( aCartao[ pLTC_POS_DADOS ][6] ) - nRow,1 - nRow), x ) ;
																, nRow += k, k                                                 ;
													}
						oBrowse:goTopBlock    := { || nRow := 1 }
						oBrowse:goBottomBlock := { || nRow := Len( aCartao[ pLTC_POS_DADOS ][6] ) }
						oBrowse:colorSpec     := SysBrowseColor()
						oBrowse:colSep        := Chr(179)
						oBrowse:autoLite      := pFALSE
						
						oColumn            := TBColumnNew( PadC( 'D', 3 ), { || iif(aCartao[ pLTC_POS_DADOS ][3][ nRow ] .and.               ;
																					aCartao[ pLTC_POS_DADOS ][4][ nRow ] .and. .not.         ;
																					aCartao[ pLTC_POS_DADOS ][5][ nRow ], '[X]',             ;
																					iif(aCartao[ pLTC_POS_DADOS ][3][ nRow ] .and.           ;
																						aCartao[ pLTC_POS_DADOS ][5][ nRow ] .and. .not.     ;
																						aCartao[ pLTC_POS_DADOS ][4][ nRow ], '[X]',         ;
																						iif(aCartao[ pLTC_POS_DADOS ][4][ nRow ] .and.       ;
																							aCartao[ pLTC_POS_DADOS ][5][ nRow ] .and. .not. ;
																							aCartao[ pLTC_POS_DADOS ][3][ nRow ], '[X]', '[ ]' ) ) ) } )
						oColumn:width      := 3
						oBrowse:addColumn( oColumn )
						
						oColumn            := TBColumnNew( PadC( 'T', 3 ), { || iif(aCartao[ pLTC_POS_DADOS ][3][ nRow ] .and. ;
																					aCartao[ pLTC_POS_DADOS ][4][ nRow ] .and. ;
																					aCartao[ pLTC_POS_DADOS ][5][ nRow ], '[X]', '[ ]' ) } )
						oColumn:width      := 3
						oBrowse:addColumn( oColumn )

					always
						oBrowse:forceStable()
					end sequence
					
					@ oWindow:nTop+ 3, oWindow:nLeft+62, ;
						oWindow:nBottom- 3, oWindow:nRight- 1 	GET     cDisplay                     ;
																TBROWSE oBrowse                      ;
																WHEN    pFALSE
					
					
					hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
								oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					
					@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON           ;
															CAPTION ' Con&firma '                    ;
															COLOR   SysPushButton()                  ;
															STYLE   ''                               ;
															STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }
					
					@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON           ;
															CAPTION ' Cance&lar '                    ;
															COLOR   SysPushButton()                  ;
															STYLE   ''                               ;
															STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }
					
					Set( _SET_CURSOR, SC_NORMAL )
					
					READ
					
					Set( _SET_CURSOR, SC_NONE )
					
					If lContinua .and. LastKey() != K_ESC
						
						// Verifica se se todos os jogos foram selecionados os resultados e
						// atualiza as colunas de Duplo e Triplo
						begin sequence

							lFailSelect := pFALSE
							for nCount := 1 to Len( aCartao[ pLTC_POS_DADOS ][3] )
								If aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
									aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pFALSE
									aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
								ElseIf aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
									aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pFALSE
									aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
								ElseIf aCartao[ pLTC_POS_DADOS ][5][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][4][ nCount ]
									aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pFALSE
									aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
								ElseIf aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
									aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pTRUE
									aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
								ELseIf aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][5][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][4][ nCount ]
									aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pTRUE
									aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
								ElseIf aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][5][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][3][ nCount ]
									aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pTRUE
									aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pFALSE
								ElseIf aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
									aCartao[ pLTC_POS_DADOS ][6][ nCount ] := pFALSE
									aCartao[ pLTC_POS_DADOS ][7][ nCount ] := pTRUE
								ElseIf .not. aCartao[ pLTC_POS_DADOS ][3][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][4][ nCount ] .and. .not. aCartao[ pLTC_POS_DADOS ][5][ nCount ]
									lFailSelect := pTRUE
								EndIf
							next

						always
							// Necessario informar no minimo um duplo ou um triplo
							nCountDuplo  := 0
							AEval( aCartao[ pLTC_POS_DADOS ][6], { |xItem| iif( xItem, nCountDuplo++, Nil ) } )
							
							nCountTriplo := 0
							AEval( aCartao[ pLTC_POS_DADOS ][7], { |xItem| iif( xItem, nCountTriplo++, Nil ) } )
						end sequence
						
						// atualiza os dados do cartao
						If .not. lFailSelect
							If nCountDuplo > 0 .or. nCountTriplo > 0
								If LtcGrvCartao()
									lContinua := pFALSE
								EndIf
							Else
								ErrorTable( '027' )  // Necessario informar no minimo um duplo ou triplo.
							EndIf
						Else
							ErrorTable( '012' )  // Selecione o resultado da partida.
						EndIf
						
					EndIf
					
				enddo

			always	
				// Fecha o Objeto Windows
				oWindow:Close()
				// Restaura a tabela da Pilha
				DstkPop()
			end sequence
			
		Else
			ErrorTable( '020' )  // Nao existem clubes cadastrados.
		EndIf
		
	EndIf
		
return


/***
*
*	LtcExcluir()
*
*	Realiza a exclusao dos registros dos seguintes concurso:
*
*   => Loteca
*
*   MntAposta -> Grupos -> { => } LtcApostas -> LtcApoExcluir
*
*/
STATIC PROCEDURE LtcApoExcluir

	If .not. Empty( APOSTAS_ITENS->ITN_JOGO ) .and. APOSTAS_ITENS->ITN_JOGO == APOSTAS->APT_JOGO

		If Alert( 'Confirma Exclusao do Registro ?', {' Sim ', ' Nao ' } ) == 1

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()		

				// Marca os Itens do Concurso para Eliminacao
				If APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( APOSTAS_ITENS->ITN_JOGO + APOSTAS_ITENS->ITN_CONCUR + APOSTAS_ITENS->ITN_SEQUEN + APOSTAS_ITENS->ITN_ITEM ) )
					while APOSTAS_CLUBES->CLB_JOGO == APOSTAS_ITENS->ITN_JOGO .and. ;
							APOSTAS_CLUBES->CLB_CONCUR == APOSTAS_ITENS->ITN_CONCUR .and. ;
							APOSTAS_CLUBES->CLB_SEQUEN == APOSTAS_ITENS->ITN_SEQUEN .and. ;
							APOSTAS_CLUBES->CLB_ITEM == APOSTAS_ITENS->ITN_ITEM .and. ;
							.not. APOSTAS_CLUBES->( Eof() )
						If APOSTAS_CLUBES->( NetRLock() )
							APOSTAS_CLUBES->( dbDelete() )
							APOSTAS_CLUBES->( dbUnlock() )
						EndIf
						APOSTAS_CLUBES->( dbSkip() )
					enddo
				EndIf

				//Marca o Cabecario do Concurso para Eliminacao
				If APOSTAS_ITENS->( NetRLock() )
					APOSTAS_ITENS->( dbDelete() )
					APOSTAS_ITENS->( dbUnlock() )
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
*	LtcGrvCartao()
*
*	Realiza a gravacao dos dados da LOTECA.
*
*/
STATIC FUNCTION LtcGrvCartao

local lRetValue := pFALSE


	while .Not. lRetValue
		
		begin sequence
		
			If iif( APOSTAS_ITENS->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM ) ), APOSTAS_ITENS->( NetRLock() ), APOSTAS_ITENS->( NetAppend() ) )
				APOSTAS_ITENS->ITN_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_ITENS->ITN_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_ITENS->ITN_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_ITENS->ITN_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_ITENS->ITN_VALOR  := pLTC_APOSTA_ITEM_VALOR
				APOSTAS_ITENS->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '01' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '01'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_01
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_01
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_01, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_01, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_01, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_01, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_01, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '02' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '02'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_02
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_02
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_02, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_02, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_02, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_02, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_02, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '03' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '03'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_03
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_03
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_03, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_03, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_03, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_03, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_03, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '04' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '04'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_04
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_04
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_04, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_04, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_04, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_04, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_04, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '05' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '05'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_05
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_05
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_05, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_05, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_05, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_05, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_05, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '06' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '06'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_06
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_06
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_06, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_06, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_06, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_06, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_06, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '07' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '07'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_07
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_07
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_07, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_07, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_07, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_07, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_07, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '08' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '08'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_08
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_08
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_08, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_08, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_08, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_08, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_08, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '09' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '09'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_09
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_09
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_09, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_09, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_09, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_09, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_09, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '10' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '10'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_10
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_10
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_10, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_10, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_10, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_10, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_10, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '11' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '11'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_11
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_11
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_11, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_11, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_11, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_11, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_11, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '12' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '12'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_12
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_12
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_12, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_12, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_12, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_12, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_12, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '13' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '13'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_13
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_13
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_13, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_13, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_13, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_13, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_13, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
			If iif( APOSTAS_CLUBES->( dbSetOrder(1), dbSeek( pLTC_APOSTA_ITEM_JOGO + pLTC_APOSTA_ITEM_CONCURSO + pLTC_APOSTA_ITEM_SEQUENCIA + pLTC_APOSTA_ITEM_ITEM + '14' ) ), APOSTAS_CLUBES->( NetRLock() ), APOSTAS_CLUBES->( NetAppend() ) )
				APOSTAS_CLUBES->CLB_JOGO   := pLTC_APOSTA_ITEM_JOGO
				APOSTAS_CLUBES->CLB_CONCUR := pLTC_APOSTA_ITEM_CONCURSO
				APOSTAS_CLUBES->CLB_SEQUEN := pLTC_APOSTA_ITEM_SEQUENCIA
				APOSTAS_CLUBES->CLB_ITEM   := pLTC_APOSTA_ITEM_ITEM
				APOSTAS_CLUBES->CLB_FAIXA  := '14'
				APOSTAS_CLUBES->CLB_COL1   := pLTC_APOSTA_ITEM_CLUBE_COL_1_14
				APOSTAS_CLUBES->CLB_COL2   := pLTC_APOSTA_ITEM_CLUBE_COL_2_14
				APOSTAS_CLUBES->CLB_RESULT := iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_1_14, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_2_14, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_RESULT_3_14, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_DUPLO_14, '1', '0' ) + ;
												iif( pLTC_APOSTA_ITEM_CLUBE_TRIPLO_14, '1', '0' )
				APOSTAS_CLUBES->( dbUnlock() )
			EndIf
			
		alway
			lRetValue := TRUE
		end sequence
		
	enddo
		
return( lRetValue )


/***
*
*	LoadApostadores()
*
*	Realizar a carga dos Apostadores cadastrados.
*
*   ==> [ GrpIncluir() ]
*   ==> [ GrpModificar() ]
*
*/
STATIC FUNCTION LoadApostadores

local aRetValue := {}

	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		dbSelectArea('APOSTADORES')
		APOSTADORES->( dbSetOrder(1), dbGoTop() )
		while .not. APOSTADORES->( Eof() )
			AAdd( aRetValue, { AllTrim( APOSTADORES->APO_CODIGO ) + '-' + AllTrim( APOSTADORES->APO_NOME ), APOSTADORES->APO_CODIGO } )
			APOSTADORES->( dbSkip() )
		enddo
	always
		// Restaura a tabela da Pilha
		DstkPop()
	end sequence

return( aRetValue )
	