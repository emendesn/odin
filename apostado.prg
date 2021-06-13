/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  apostado.prg
*
***/

#include 'set.ch'
#include 'box.ch'
#include 'inkey.ch'
#include 'common.ch'
#include 'setcurs.ch'
#include 'getexit.ch'
#include 'apostado.ch'
#include 'dbfunc.ch'
#include 'main.ch'

static aApostadores

memvar GetList

/***
*
*	Apostadores()
*
*	Realiza a manutencao do cadastro de apostadores.
*
*/
PROCEDURE Apostadores

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


	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		// Cria o Objeto Windows
		oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 10
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 37
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 10
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 37
		oWindow:cHeader := PadC( 'Apostadores', Len( 'Apostadores' ) + 2, ' ')
		oWindow:Open()

		// Desenha a Linha de Botoes
		hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
					oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

		// Estabelece o Filtro para exibicao dos registros
		bFiltro := { || .not. APOSTADORES->( Eof() ) }

		dbSelectArea('APOSTADORES')
		APOSTADORES->( dbEval( {|| nMaxItens++ }, bFiltro ) )
		APOSTADORES->( dbSetOrder(1), dbGoTop() )

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
			oColumn 			:= TBColumnNew( PadC( 'Nome', 30 ), APOSTADORES->( FieldBlock( 'APO_NOME' ) ) )
			oColumn:picture 	:= '@!'
			oColumn:width   	:= 30
			oBrowse:addColumn( oColumn )

			oColumn            := TBColumnNew( PadC( 'Saldo', 12 ),  APOSTADORES->( FieldBlock( 'APO_SALDO' ) ) )
			oColumn:picture    := '@E 9,999,999.99'
			oColumn:width      := 13
			oColumn:colSep     := Chr(179)
			oBrowse:addColumn( oColumn )

			oColumn            := TBColumnNew( PadC( 'Premio', 12 ),  APOSTADORES->( FieldBlock( 'APO_PREMIO' ) ) )
			oColumn:picture    := '@E 9,999,999.99'
			oColumn:width      := 13
			oColumn:colSep     := Chr(179)
			oBrowse:addColumn( oColumn )

			oColumn            := TBColumnNew( PadC( 'Gastos', 12 ),  APOSTADORES->( FieldBlock( 'APO_GASTOS' ) ) )
			oColumn:picture    := '@E 9,999,999.99'
			oColumn:width      := 13
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
//			oTmpButton:sBlock    := { || Excluir() }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Ac&oes ' )
			oTmpButton:sBlock    := { || Acoes() }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+43, ' &Sair ' )
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

return


/***
*
*	Incluir()
*
*	Realiza a inclusao de Apostadores.
*
*   Apostadores -> Incluir
*
*/
STATIC PROCEDURE Incluir

local lContinua     := pTRUE
local lPushButton
local oWindow


	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		// Inicializa as Variaveis de Dados
		xInitApostadores

		// Inicializa as Variaveis de no vetor aCompeticoes
		xStoreApostadores

		// Cria o Objeto Windows
		oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  3
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 20
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  2
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 20
		oWindow:cHeader := PadC( 'Incluir', Len( 'Incluir' ) + 2, ' ')
		oWindow:Open()

		while lContinua

			@ oWindow:nTop+ 1, oWindow:nLeft+ 9 GET     pAPOSTADORES_NOME                               ;
												PICT    '@K!S30'                                        ;
												CAPTION 'Nome'                                          ;
												COLOR   SysFieldGet()

			@ oWindow:nTop+ 2, oWindow:nLeft+ 9 GET     pAPOSTADORES_EMAIL                              ;
												PICT    '@K!S30'                                        ;
												CAPTION 'E-mail'                                        ;
												COLOR   SysFieldGet()

			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                      ;
													CAPTION ' Con&firma '                               ;
													COLOR   SysPushButton()                             ;
													STYLE   ''                                          ;
													WHEN    .not. Empty( pAPOSTADORES_NOME )            ;
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
					// Pesquisa na base de dados um codigo valido para cadastrar o clube
					APOSTADORES->( dbEval( { || pAPOSTADORES_CODIGO++ }, { || .not. Eof() } ) )
					APOSTADORES->( dbSetOrder(1) )
					while APOSTADORES->( dbSeek( StrZero( pAPOSTADORES_CODIGO, 5 ) ) )
						pAPOSTADORES_CODIGO++
					enddo
				always

					begin sequence

						If APOSTADORES->( NetAppend() )
							APOSTADORES->APO_CODIGO := StrZero( pAPOSTADORES_CODIGO, 5 )
							APOSTADORES->APO_NOME 	:= pAPOSTADORES_NOME
							APOSTADORES->APO_EMAIL  := pAPOSTADORES_EMAIL
							APOSTADORES->( dbUnlock() )
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
*	Modificar()
*
*	Realiza a Alteracao dos dados dos Apostadores.
*
*   Apostadores -> Modificar
*
*/
STATIC PROCEDURE Modificar

local lContinua   := pTRUE
local lPushButton
local oWindow


	//************************************************************************
	// A rotina so deve ser executada somente se ja houverem dados cadastrados
	//************************************************************************
	If .not. Empty(	APOSTADORES->APO_CODIGO )

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Inicializa o vetor aApostadores
			xInitApostadores

			// Inicializa as Variaveis de no vetor aApostadores
			xStoreApostadores

			//
			// Atualiza a variaveis com o registro selecionado
			//
			pAPOSTADORES_NOME  := APOSTADORES->APO_NOME
			pAPOSTADORES_EMAIL := APOSTADORES->APO_EMAIL

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  3
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 20
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  2
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 20
			oWindow:cHeader := PadC( 'Modificar', Len( 'Modificar' ) + 2, ' ')
			oWindow:Open()

			while lContinua

				@ oWindow:nTop+ 1, oWindow:nLeft+ 9 GET     pAPOSTADORES_NOME                               ;
													PICT    '@K!S30'                                        ;
													CAPTION 'Nome'                                          ;
													VALID   .not. Empty( pAPOSTADORES_NOME )                ;
													COLOR   SysFieldGet()

				@ oWindow:nTop+ 2, oWindow:nLeft+ 9 GET     pAPOSTADORES_EMAIL                              ;
													PICT    '@K!S30'                                        ;
													CAPTION 'E-mail'                                        ;
													COLOR   SysFieldGet()

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

						If COMPETICOES->( NetAppend() )
							APOSTADORES->APO_NOME  := pAPOSTADORES_NOME
							APOSTADORES->APO_EMAIL := pAPOSTADORES_EMAIL
							COMPETICOES->( dbUnlock() )
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

	EndIf

return


/***
*
*	Excluir()
*
*	Realiza a Exclusao dos dados dos Apostadores.
*
*   Apostadores -> Excluir
*
*/
STATIC PROCEDURE Excluir

	If .not. Empty( APOSTADORES->APO_CODIGO )
		
		If Alert( 'Confirma Exclusao do Apostador ?', {' Sim ', ' Nao ' } ) == 1

			begin sequence
			
				// Salva a Area corrente na Pilha
				DstkPush()
			
				If .not. GRP_APOSTADORES->( dbSetOrder(2), dbSeek( APOSTADORES->CAD_CODIGO ) )
					
					// Exclui os registros do arquivo de Movimento
					If MOVIMENTO->( dbSetOrder(1), dbSeek( APOSTADORES->CAD_CODIGO ) )
						while .not. MOVIMENTO->( Eof() ) .and. APOSTADORES->CAD_CODIGO == MOVIMENTO->MOV_CODIGO
							If MOVIMENTO->( NetRLock() )
								MOVIMENTO->( dbDelete() )
								MOVIMENTO->( dbUnlock() )
							EndIf
							MOVIMENTO->( dbSkip() )
						enddo
					EndIf
					
					// Elimina o registros do Apostador
					If APOSTADORES->( NetRLock() )
						APOSTADORES->( dbDelete() )
						APOSTADORES->( dbUnlock() )
					EndIf

					
				Else
					ErrorTable( 'B01' ) // Apostador com apostas em andamento.
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
*	Acoes()
*
*	Exibe o menu de acoes relacionadas.
*
*   Apostadores -> Excluir
*
*/
STATIC PROCEDURE Acoes

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

			aGroup[1]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+ 4, 'Com&peticoes' )
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
//						LTFExportar()

					case nTipAcoes == 2
//						LTFCombina()

					case nTipAcoes == 3
//						LTFRelResult()

				end case

			EndIf

		enddo

	always
		// Fecha o Objeto Windows
		oWindow:Close()
	end sequence

return
