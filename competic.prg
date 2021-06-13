/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  compatic.prg
*
***/

#include 'set.ch'
#include 'box.ch'
#include 'inkey.ch'
#include 'common.ch'
#include 'setcurs.ch'
#include 'getexit.ch'
#include 'competic.ch'
#include 'dbfunc.ch'
#include 'main.ch'

static aCompeticoes
static aGrpClubes
static aPartida

memvar GetList

/***
*
*	Competicoes()
*
*	Realiza a manutencao do cadastro de competicoes.
*
*/
PROCEDURE Competicoes

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
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 31
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 10
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 31
		oWindow:cHeader := PadC( 'Competicoes', Len( 'Competicoes' ) + 2, ' ')
		oWindow:Open()

		// Desenha a Linha de Botoes
		hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
					oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

		// Estabelece o Filtro para exibicao dos registros
		bFiltro := { || .not. COMPETICOES->( Eof() ) }

		dbSelectArea('COMPETICOES')
		COMPETICOES->( dbEval( {|| nMaxItens++ }, bFiltro ) )
		COMPETICOES->( dbSetOrder(2), dbGoTop() )

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
			oColumn 			:= TBColumnNew( PadC( 'Codigo', 10 ), COMPETICOES->( FieldBlock( 'COM_CODIGO' ) ) )
			oColumn:picture 	:= '@!'
			oColumn:width   	:= 10
			oBrowse:addColumn( oColumn )

			oColumn 			:= TBColumnNew( PadC( 'Competicoes', 40 ), COMPETICOES->( FieldBlock( 'COM_COMPET' ) ) )
			oColumn:picture 	:= '@!'
			oColumn:width   	:= 45
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

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' &Grupos ' )
			oTmpButton:sBlock    := { || GrpClubes( COMPETICOES->COM_CODIGO ) }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+43, ' &Partidas ' )
			oTmpButton:sBlock    := { || Partidas( COMPETICOES->COM_CODIGO ) }
			oTmpButton:Style     := ''
			oTmpButton:ColorSpec := SysPushButton()
			AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+54, ' &Sair ' )
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
*	Realiza a inclusao de Competicoes.
*
*   Competicoes -> Incluir
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
		xInitCompeticoes

		// Inicializa as Variaveis de no vetor aCompeticoes
		xStoreCompeticoes

		// Cria o Objeto Windows
		oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  3
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 17
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  3
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 17
		oWindow:cHeader := PadC( 'Incluir', Len( 'Incluir' ) + 2, ' ')
		oWindow:Open()

		while lContinua

			@ oWindow:nTop+ 1, oWindow:nLeft+13 GET     pCOMPETICAO_CAD_COMPET                          ;
												PICT    '@K!S20'                                        ;
												CAPTION 'Competicao'                                    ;
												COLOR   SysFieldGet()

			hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
						oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
						
			@ oWindow:nTop+ 3, oWindow:nLeft+13 GET     pCOMPETICAO_CAD_VITORIA                         ;
												PICT    '@E 99'                                         ;
												CAPTION 'Vitorias'                                      ;
												COLOR   SysFieldGet()

			@ oWindow:nTop+ 3, oWindow:nLeft+28 GET     pCOMPETICAO_CAD_EMPATE                          ;
												PICT    '@E 99'                                         ;
												CAPTION 'Empates'                                       ;
												COLOR   SysFieldGet()

			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                      ;
													CAPTION ' Con&firma '                               ;
													COLOR   SysPushButton()                             ;
													STYLE   ''                                          ;
													WHEN    .not. Empty( pCOMPETICAO_CAD_COMPET ) .and. ;
															.not. Empty( pCOMPETICAO_CAD_VITORIA ) .and.;
															.not. Empty( pCOMPETICAO_CAD_EMPATE )       ;
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
					COMPETICOES->( dbEval( { || pCOMPETICAO_CAD_CODIGO++ }, { || .not. Eof() } ) )
					COMPETICOES->( dbSetOrder(1) )
					while COMPETICOES->( dbSeek( StrZero( pCOMPETICAO_CAD_CODIGO, 5 ) ) )
						pCOMPETICAO_CAD_CODIGO++
					enddo
				always

					begin sequence

						If COMPETICOES->( NetAppend() )
							COMPETICOES->COM_CODIGO := StrZero( pCOMPETICAO_CAD_CODIGO, 5 )
							COMPETICOES->COM_COMPET := pCOMPETICAO_CAD_COMPET
							COMPETICOES->COM_VITORI := pCOMPETICAO_CAD_VITORIA
							COMPETICOES->COM_EMPATE := pCOMPETICAO_CAD_EMPATE
							COMPETICOES->( dbUnlock() )
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
*	Realiza a Alteracao dos dados das Competicoes.
*
*   Competicoes -> Modificar
*
*/
STATIC PROCEDURE Modificar

local lContinua   := pTRUE
local lPushButton
local oWindow


	//************************************************************************
	// A rotina so deve ser executada somente se ja houverem dados cadastrados
	//************************************************************************
	If .not. Empty(	COMPETICOES->COM_CODIGO )

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Inicializa o vetor aCompticoes
			xInitCompeticoes

			// Inicializa as Variaveis de no vetor aCompeticoes
			xStoreCompeticoes

			//
			// Atualiza a variaveis com o registro selecionado
			//
			pCOMPETICAO_CAD_CODIGO  := COMPETICOES->COM_CODIGO
			pCOMPETICAO_CAD_COMPET  := COMPETICOES->COM_COMPET
			pCOMPETICAO_CAD_VITORIA := COMPETICOES->COM_VITORI
			pCOMPETICAO_CAD_EMPATE  := COMPETICOES->COM_EMPATE

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  3
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 21
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  3
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 21
			oWindow:cHeader := PadC( 'Modificar', Len( 'Modificar' ) + 2, ' ')
			oWindow:Open()

			while lContinua

				@ oWindow:nTop+ 1, oWindow:nLeft+11 GET     pCOMPETICAO_CAD_CODIGO                         ;
													PICT    '@!'                                           ;
													CAPTION 'Codigo'                                       ;
													WHEN    pFALSE                                         ;
													COLOR   SysFieldGet()

				@ oWindow:nTop+ 1, oWindow:nLeft+25 GET     pCOMPETICAO_CAD_COMPET                         ;
													VALID   .not. Empty( pCOMPETICAO_CAD_COMPET )          ;
													PICT    '@K!S15'                                       ;
													CAPTION 'Nome'                                         ;
													COLOR   SysFieldGet()


				hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
							oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nTop+ 3, oWindow:nLeft+11 GET     pCOMPETICAO_CAD_VITORIA                        ;
													VALID   .not. Empty( pCOMPETICAO_CAD_VITORIA )         ;
													PICT    '@E 99'                                        ;
													CAPTION 'Vitorias'                                     ;
													COLOR   SysFieldGet()

				@ oWindow:nTop+ 3, oWindow:nLeft+25 GET     pCOMPETICAO_CAD_EMPATE                         ;
													VALID   .not. Empty( pCOMPETICAO_CAD_EMPATE )          ;
													PICT    '@E 99'                                        ;
													CAPTION 'Empates'                                      ;
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

						If COMPETICOES->( NetRLock() )
							COMPETICOES->COM_COMPET := pCOMPETICAO_CAD_COMPET
							COMPETICOES->COM_VITORI := pCOMPETICAO_CAD_VITORIA
							COMPETICOES->COM_EMPATE := pCOMPETICAO_CAD_EMPATE
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
*	Realiza a Exclusao das Competicoes.
*
*   Competicoes -> Excluir
*
*/
STATIC PROCEDURE Excluir

	//************************************************************************
	// A rotina so deve ser executada somente se ja houverem dados cadastrados
	//************************************************************************
	If .not. Empty( COMPETICOES->COM_CODIGO )

		If Alert( 'Sera excluido todos os registros relacionados a esta competicao ?', {' Sim ', ' Nao ' } ) == 1

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Realiza a exclusao das partidas amarradas a competicao
				If PARTIDAS->( dbSetOrder(1), dbSeek( COMPETICOES->COM_CODIGO ) )
					while .not. PARTIDAS->( Eof() ) .and. PARTIDAS->PAR_CODIGO == COMPETICOES->COM_CODIGO
						If PARTIDAS->( NetRLock() )
							PARTIDAS->( dbDelete() )
							PARTIDAS->( dbUnlock() )
						EndIf
						PARTIDAS->( dbSkip() )
					enddo
				EndIf

				// Realiza a exclusao dos clubes amarrados a competicao
				If GRP_COMPETICOES->( dbSetOrder(1), dbSeek( COMPETICOES->COM_CODIGO ) )
					while .not. GRP_COMPETICOES->( Eof() ) .and. GRP_COMPETICOES->GRP_CODIGO == COMPETICOES->COM_CODIGO
						If GRP_COMPETICOES->( NetRLock() )
							GRP_COMPETICOES->( dbDelete() )
							GRP_COMPETICOES->( dbUnlock() )
						EndIf
						GRP_COMPETICOES->( dbSkip() )
					enddo
				EndIf

				// Realiza a exclusao da competicao
				If COMPETICOES->( NetRLock() )
					COMPETICOES->( dbDelete() )
					COMPETICOES->( dbUnlock() )
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
*	GrpClubes( cCodigo )
*
*	Realiza a Manutencao do Cadastro do Grupo de Clubes por Competicao.
*
*	Parametros:
*               <cCodigo>  - Codigo da compticao para o cadastro do clube
*
*   Competicoes -> Grupos
*
*/
STATIC PROCEDURE GrpClubes( cCodigo )

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


	If .not. Empty( cCodigo )

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  8
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 18
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  8
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 18
			oWindow:cHeader := PadC( 'Grupos', Len( 'Grupos' ) + 2, ' ')
			oWindow:Open()

			// Desenha a Linha de Botoes
			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			// Estabelece o Filtro para exibicao dos registros
			bFiltro := { || GRP_COMPETICOES->GRP_CODIGO == cCodigo .and. .not. GRP_COMPETICOES->( Eof() ) }

			dbSelectArea('GRP_COMPETICOES')
			GRP_COMPETICOES->( dbEval( {|| nMaxItens++ }, bFiltro ) )
			GRP_COMPETICOES->( dbSetOrder(1), dbSeek( cCodigo ) )

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
				oColumn         := TBColumnNew( 'CLUBES', {|| 	iif( CLUBES->( dbSetOrder(1), dbSeek( GRP_COMPETICOES->GRP_CLUBE ) ), ;
																AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), '' ) } )
				oColumn:picture 	:= '@!'
				oColumn:width   	:= 30
				oBrowse:addColumn( oColumn )

				// Realiza a Montagem da Barra de Rolagem
				oScrollBar           	:= ScrollBar( oWindow:nTop+ 3, oWindow:nBottom- 3, oWindow:nRight )
				oScrollBar:colorSpec 	:= SysScrollBar()
				oScrollBar:display()


				// Desenha os botoes da tela
				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
				oTmpButton:sBlock    := { || GrpIncluir( cCodigo ) }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:caption, At('&', oTmpButton:caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' E&xcluir ' )
				oTmpButton:sBlock    := { || GrpExcluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:caption, At('&', oTmpButton:caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+22, ' &Sair ' )
				oTmpButton:sBlock    := { || lSair := pTRUE }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:caption, At('&', oTmpButton:caption )+ 1, 1 ) ) } )

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

	EndIf

return


/***
*
*	GrpIncluir( cCodigo )
*
*	Realiza a Inclusao do Clube no Grupo da Competicao.
*
*	Parametros:
*               <cCodigo> - Codigo da competicao para o cadastro do clube
*
*   Competicoes -> Grupos -> GrpIncluir
*
*/
STATIC PROCEDURE GrpIncluir( cCodigo )

local aClubes
local lContinua  := pTRUE
local lPushButton
local oWindow


	//************************************************************************
	//*Carrega o Cadastro de Clubes                                          *
	//************************************************************************
	If Len( aClubes := LoadClubes() ) > 0

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Inicializa as Variaveis de Grupos
			xInitGrupos

			// Define o conteudo das variaveis de grupos
			xStoreGrupos

			// Cria o Objeto Windows
			oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  2
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 18
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  2
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 18
			oWindow:cHeader := PadC( 'Incluir', Len( 'Incluir' ) + 2, ' ')
			oWindow:Open()

			while lContinua

				@ oWindow:nTop+ 1, oWindow:nLeft+ 2, ;
					oWindow:nTop+ 1, oWindow:nLeft+34 	GET     pGRUPOS_COMPETICAO_CLUBE                ;
														LISTBOX aClubes                                 ;
														DROPDOWN                                        ;
														SCROLLBAR                                       ;
														COLOR   SysFieldListBox()

				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nBottom- 1, oWindow:nRight-22	GET     lPushButton PUSHBUTTON                  ;
														CAPTION ' Con&firma '                           ;
														COLOR   SysPushButton()                         ;
														STYLE   ''                                      ;
														WHEN    .not. Empty( pGRUPOS_COMPETICAO_CLUBE ) ;
														STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

				@ oWindow:nBottom- 1, oWindow:nRight-11	GET     lPushButton PUSHBUTTON                  ;
														CAPTION ' Cance&lar '                           ;
														COLOR   SysPushButton()                         ;
														STYLE   ''                                      ;
														STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_ESCAPE }

				Set( _SET_CURSOR, SC_NORMAL )

				READ

				Set( _SET_CURSOR, SC_NONE )

				If lContinua .and. LastKey() != K_ESC

					If .not. GRP_COMPETICOES->( dbSetOrder(1), dbSeek( cCodigo + pGRUPOS_COMPETICAO_CLUBE ) )

						begin sequence

							If GRP_COMPETICOES->( NetAppend() )
								GRP_COMPETICOES->GRP_CODIGO := cCodigo
								GRP_COMPETICOES->GRP_CLUBE  := pGRUPOS_COMPETICAO_CLUBE
								GRP_COMPETICOES->( dbUnlock() )
							EndIf
						always
							lContinua := pFALSE
						end sequence

					Else
						ErrorTable( 'A02' )  // Clube ja cadastrados no grupo
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
		ErrorTable( 'A01' )  // Nao existem clubes cadastrados
	EndIf

return


***
*
*	GrpExcluir()
*
*	Realiza a Exclusao do Clube no Grupo da Competicao.
*
*   Competicoes -> Grupos -> GrpExcluir
*
*/
STATIC PROCEDURE GrpExcluir

	If .not. Empty( GRP_COMPETICOES->GRP_CODIGO ) .and. COMPETICOES->COM_CODIGO == GRP_COMPETICOES->GRP_CODIGO

		If Alert( 'Confirma Exclusao do Registro ?', {' Sim ', ' Nao '} ) == 1

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Elimina o Registro
				If GRP_COMPETICOES->( NetRLock() )
					GRP_COMPETICOES->( dbDelete() )
					GRP_COMPETICOES->( dbUnlock() )
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
*	Partidas( cCodigo )
*
*	Realiza a Manutencao das partidas da Competicao.
*
*	Parametros:
*               <cCodigo>  - Codigo da compticao para o cadastro da partida
*
*   Competicoes -> Partidas
*
*/
STATIC PROCEDURE Partidas( cCodigo )

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


	If .not. Empty( cCodigo )

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  8
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 34
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  8
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 34
			oWindow:cHeader := PadC( 'Partidas', Len( 'Partidas' ) + 2, ' ')
			oWindow:Open()

			// Desenha a Linha de Botoes
			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			// Estabelece o Filtro para exibicao dos registros
			bFiltro := { || PARTIDAS->PAR_CODIGO == cCodigo .and. .not. PARTIDAS->( Eof() ) }

			dbSelectArea('PARTIDAS')
			PARTIDAS->( dbEval( {|| nMaxItens++ }, bFiltro ) )
			PARTIDAS->( dbSetOrder(1), dbSeek( cCodigo ) )

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
				oColumn := TBColumnNew( '',                 PARTIDAS->( FieldBlock( 'PAR_STATUS' ) ) )
				oColumn:picture    := '@!'
				oColumn:width      := 3
				oBrowse:addColumn( oColumn )

				oColumn := TBColumnNew( PadC( 'Data', 10 ), PARTIDAS->( FieldBlock( 'PAR_DATA' ) ) )
				oColumn:picture    := '@D 99/99/99'
				oColumn:width      := 10
				oBrowse:addColumn( oColumn )

				oColumn := TBColumnNew( '',                 PARTIDAS->( FieldBlock( 'PAR_RODADA' ) ) )
				oColumn:picture    := '@!'
				oColumn:width      := 2
				oBrowse:addColumn( oColumn )

				oColumn := TBColumnNew( '',                 {|| iif( CLUBES->( dbSetOrder(1), dbSeek( PARTIDAS->PAR_COL1 ) ), ;
																AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), '' ) } )
				oColumn:picture    := '@!'
				oColumn:width      := 20
				oBrowse:addColumn( oColumn )

				oColumn := TBColumnNew( '',                 {|| iif( CLUBES->( dbSetOrder(1), dbSeek( PARTIDAS->PAR_COL2 ) ), ;
																AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), '' ) } )
				oColumn:picture    := '@!'
				oColumn:width      := 20
				oBrowse:addColumn( oColumn )

				// Realiza a Montagem da Barra de Rolagem
				oScrollBar           	:= ScrollBar( oWindow:nTop+ 3, oWindow:nBottom- 3, oWindow:nRight )
				oScrollBar:colorSpec 	:= SysScrollBar()
				oScrollBar:display()


				// Desenha os botoes da tela
				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
				oTmpButton:sBlock    := { || ParIncluir( cCodigo ) }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:caption, At('&', oTmpButton:caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
				oTmpButton:sBlock    := { || ParModificar() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:caption, At('&', oTmpButton:caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' E&xcluir ' )
				oTmpButton:sBlock    := { || ParExcluir() }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:caption, At('&', oTmpButton:caption )+ 1, 1 ) ) } )

				oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' &Sair ' )
				oTmpButton:sBlock    := { || lSair := pTRUE }
				oTmpButton:Style     := ''
				oTmpButton:ColorSpec := SysPushButton()
				AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:caption, At('&', oTmpButton:caption )+ 1, 1 ) ) } )

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

	EndIf

return


/***
*
*	ParIncluir( cCodigo )
*
*	Realiza a Inclusao das Partidas da competicao selecionada.
*
*	Parametros:
*               <cCodigo>  - Codigo da compticao para o cadastro da partida
*
*   Competicoes -> Partidas -> ParIncluir
*
*/
STATIC PROCEDURE ParIncluir( cCodigo )

local aClubes    := {}
local lContinua  := pTRUE
local lPushButton
local oWindow


	DEFAULT cCodigo TO ''

	If GRP_COMPETICOES->( dbSetOrder(1), dbSeek( cCodigo ) )

		//************************************************************************
		//*Carrega o Cadastro de Clubes                                          *
		//************************************************************************
		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			dbSelectArea('GRP_COMPETICOES')
			while .not. GRP_COMPETICOES->( Eof() ) .and. GRP_COMPETICOES->GRP_CODIGO == cCodigo
				If CLUBES->( dbSetOrder(1), dbSeek( GRP_COMPETICOES->GRP_CLUBE ) )
					AAdd( aClubes, { AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), CLUBES->CLU_CODIGO } )
				EndIf
				GRP_COMPETICOES->( dbSkip() )
			enddo

		always		
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence


		If Len( aClubes ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Ordena o vetor de Clubes
				aClubes := ASort( aClubes,,, { |x, y| x[1] < y[1] } )

				// Inicializa as Variaveis de Dados
				xInitCompeticoesPartidas

				// Inicializa as Variaveis de no vetor aCompeticoes
				xStoreCompeticoesPartidas

				// Define o valor inicial como agendado para para os registros incluidos
				pCOMPETICAO_PARTIDA_STATUS := pCOMPETICAO_PARTIDA_AGENDADO

				// Cria o Objeto Windows
				oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  3
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 26
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  3
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 26
				oWindow:cHeader := PadC( 'Incluir', Len( 'Incluir' ) + 2, ' ')
				oWindow:Open()

				while lContinua

					@ oWindow:nTop+ 1, oWindow:nLeft+ 9, ;
						oWindow:nTop+ 1, oWindow:nLeft+19 	GET     pCOMPETICAO_PARTIDA_STATUS                           ;
															LISTBOX pCOMPETICAO_PARTIDA_OPCOES                           ;
															DROPDOWN                                                     ;
															CAPTION 'Status'                                             ;
															SCROLLBAR                                                    ;
															COLOR   SysFieldListBox()

					@ oWindow:nTop+ 1, oWindow:nLeft+30 GET     pCOMPETICAO_PARTIDA_DATA                                 ;
														PICT    '@KD 99/99/99'                                           ;
														CAPTION 'Data'                                                   ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 1, oWindow:nLeft+49 GET     pCOMPETICAO_PARTIDA_RODADA                               ;
														PICT    '@K 99'                                                  ;
														SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),2))          ;
														CAPTION 'Rodada'                                                 ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+ 2, ;
						oWindow:nTop+ 3, oWindow:nLeft+22 	GET   	pCOMPETICAO_PARTIDA_COLUNA1 	                     ;
															LISTBOX aClubes                                              ;
															DROPDOWN                                                     ;
															SCROLLBAR                                                    ;
															COLOR   SysFieldListBox()

					@ oWindow:nTop+ 3, oWindow:nLeft+24 GET   pCOMPETICAO_PARTIDA_PONTOS1                                ;
														PICT  '@K 99'                                                    ;
														WHEN  pCOMPETICAO_PARTIDA_STATUS <> pCOMPETICAO_PARTIDA_AGENDADO ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+27, ;
						oWindow:nTop+ 3, oWindow:nLeft+47 	GET     pCOMPETICAO_PARTIDA_COLUNA2                          ;
															LISTBOX aClubes                                              ;
															DROPDOWN                                                     ;
															SCROLLBAR                                                    ;
															COLOR   SysFieldListBox()

					@ oWindow:nTop+ 3, oWindow:nLeft+49	GET   pCOMPETICAO_PARTIDA_PONTOS2                                ;
														PICT  '@K 99'                                                    ;
														WHEN  pCOMPETICAO_PARTIDA_STATUS <> pCOMPETICAO_PARTIDA_AGENDADO ;
														COLOR SysFieldGet()

					hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
								oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                               ;
															CAPTION ' Con&firma '                                        ;
															COLOR   SysPushButton()                                      ;
															STYLE   ''                                                   ;
															WHEN    Val( pCOMPETICAO_PARTIDA_RODADA ) > 0 .and.          ;
																	.not. Empty( pCOMPETICAO_PARTIDA_DATA ) .and.        ;
																	.not. Empty( pCOMPETICAO_PARTIDA_COLUNA1 ) .and.     ;
																	.not. Empty( pCOMPETICAO_PARTIDA_COLUNA2 )           ;
															STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

					@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                           ;
															CAPTION ' Cance&lar '                                    ;
															COLOR   SysPushButton()                                  ;
															STYLE   ''                                               ;
															STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

					Set( _SET_CURSOR, SC_NORMAL )

					READ

					Set( _SET_CURSOR, SC_NONE )

					If lContinua .and. LastKey() != K_ESC

						begin sequence

							If PARTIDAS->( NetAppend() )
								PARTIDAS->PAR_CODIGO := cCodigo
								PARTIDAS->PAR_STATUS := pCOMPETICAO_PARTIDA_STATUS
								PARTIDAS->PAR_DATA   := pCOMPETICAO_PARTIDA_DATA
								PARTIDAS->PAR_RODADA := pCOMPETICAO_PARTIDA_RODADA
								PARTIDAS->PAR_COL1   := pCOMPETICAO_PARTIDA_COLUNA1
								PARTIDAS->PAR_PONT1  := pCOMPETICAO_PARTIDA_PONTOS1
								PARTIDAS->PAR_COL2   := pCOMPETICAO_PARTIDA_COLUNA2
								PARTIDAS->PAR_PONT2  := pCOMPETICAO_PARTIDA_PONTOS2
								PARTIDAS->( dbUnlock() )
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

	Else
		ErrorTable( 'A03' )  // Nao existe clube cadastrados para esta competicao
	EndIf

return


/***
*
*	ParModificar()
*
*	Permite Modificar os dados da Partida da competicao selecionada.
*
*   Competicoes -> Partidas -> ParModificar
*/
STATIC PROCEDURE ParModificar()

local aClubes    := {}
local lContinua  := pTRUE
local lPushButton
local oWindow


	If .not. Empty( PARTIDAS->PAR_CODIGO )

		//************************************************************************
		//*Carrega o Cadastro de Clubes                                          *
		//************************************************************************
		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			dbSelectArea('GRP_COMPETICOES')
			GRP_COMPETICOES->( dbSetOrder(1), dbSeek( PARTIDAS->PAR_CODIGO ) )
			while .not. GRP_COMPETICOES->( Eof() ) .and. PARTIDAS->PAR_CODIGO == GRP_COMPETICOES->GRP_CODIGO
				If CLUBES->( dbSetOrder(1), dbSeek( GRP_COMPETICOES->GRP_CLUBE ) )
					AAdd( aClubes, { AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ), CLUBES->CLU_CODIGO } )
				EndIf
				GRP_COMPETICOES->( dbSkip() )
			enddo

		always
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

		If Len( aClubes ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Ordena o vetor de Clubes
				aClubes := ASort( aClubes,,, { |x, y| x[1] < y[1] } )

				// Inicializa as Variaveis de Dados
				xInitCompeticoesPartidas

				// Carrega os dados a serem modificados
				pCOMPETICAO_PARTIDA_STATUS  := PARTIDAS->PAR_STATUS
				pCOMPETICAO_PARTIDA_DATA    := PARTIDAS->PAR_DATA
				pCOMPETICAO_PARTIDA_RODADA  := PARTIDAS->PAR_RODADA
				pCOMPETICAO_PARTIDA_COLUNA1 := PARTIDAS->PAR_COL1
				pCOMPETICAO_PARTIDA_PONTOS1 := PARTIDAS->PAR_PONT1
				pCOMPETICAO_PARTIDA_COLUNA2 := PARTIDAS->PAR_COL2
				pCOMPETICAO_PARTIDA_PONTOS2 := PARTIDAS->PAR_PONT2

				// Cria o Objeto Windows
				oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  3
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 26
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  3
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 26
				oWindow:cHeader := PadC( 'Modificar', Len( 'Modificar' ) + 2, ' ')
				oWindow:Open()

				while lContinua

					@ oWindow:nTop+ 1, oWindow:nLeft+ 9, ;
						oWindow:nTop+ 1, oWindow:nLeft+19 	GET     pCOMPETICAO_PARTIDA_STATUS                       ;
															LISTBOX pCOMPETICAO_PARTIDA_OPCOES                       ;
															DROPDOWN                                                 ;
															CAPTION 'Status'                                         ;
															SCROLLBAR                                                ;
															COLOR   SysFieldListBox()

					@ oWindow:nTop+ 1, oWindow:nLeft+30 GET     pCOMPETICAO_PARTIDA_DATA                             ;
														VALID   .not. Empty( pCOMPETICAO_PARTIDA_RODADA )            ;
														PICT    '@KD 99/99/99'                                       ;
														CAPTION 'Data'                                               ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 1, oWindow:nLeft+49 GET     pCOMPETICAO_PARTIDA_RODADA                           ;
														VALID   .not. Empty( pCOMPETICAO_PARTIDA_RODADA )            ;
														SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),2))      ;
														PICT    '@K 99'                                              ;
														CAPTION 'Rodada'                                             ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+ 2, ;
						oWindow:nTop+ 3, oWindow:nLeft+22  	GET     pCOMPETICAO_PARTIDA_COLUNA1                      ;
															LISTBOX aClubes                                          ;
															DROPDOWN                                                 ;
															SCROLLBAR                                                ;
															COLOR   SysFieldListBox()

					@ oWindow:nTop+ 3, oWindow:nLeft+24 GET   pCOMPETICAO_PARTIDA_PONTOS1                            ;
														PICT  '@K 99'                                                ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+27, ;
						oWindow:nTop+ 3, oWindow:nLeft+47  	GET     pCOMPETICAO_PARTIDA_COLUNA2                      ;
															LISTBOX aClubes                                          ;
															DROPDOWN                                                 ;
															SCROLLBAR                                                ;
															COLOR   SysFieldListBox()

					@ oWindow:nTop+ 3, oWindow:nLeft+49 GET   pCOMPETICAO_PARTIDA_PONTOS2                            ;
														PICT  '@K 99'                                                ;
														COLOR SysFieldGet()

					hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
								oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                           ;
															CAPTION ' Con&firma '                                    ;
															COLOR   SysPushButton()                                  ;
															STYLE   ''                                               ;
															WHEN    .not. Empty( pCOMPETICAO_PARTIDA_COLUNA1 ) .and. ;
																	.not. Empty( pCOMPETICAO_PARTIDA_COLUNA2 )       ;
															STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

					@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                           ;
															CAPTION ' Cance&lar '                                    ;
															COLOR   SysPushButton()                                  ;
															STYLE   ''                                               ;
															STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

					Set( _SET_CURSOR, SC_NORMAL )

					READ

					Set( _SET_CURSOR, SC_NONE )

					If lContinua .and. LastKey() != K_ESC

						begin sequence

							If PARTIDAS->( NetRLock() )
								PARTIDAS->PAR_STATUS := pCOMPETICAO_PARTIDA_STATUS
								PARTIDAS->PAR_DATA   := pCOMPETICAO_PARTIDA_DATA
								PARTIDAS->PAR_RODADA := pCOMPETICAO_PARTIDA_RODADA
								PARTIDAS->PAR_COL1   := pCOMPETICAO_PARTIDA_COLUNA1
								PARTIDAS->PAR_PONT1  := pCOMPETICAO_PARTIDA_PONTOS1
								PARTIDAS->PAR_COL2   := pCOMPETICAO_PARTIDA_COLUNA2
								PARTIDAS->PAR_PONT2  := pCOMPETICAO_PARTIDA_PONTOS2
								PARTIDAS->( dbUnlock() )
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
			ErrorTable( 'A03' )  // Nao existe clube cadastrados para esta competicao
		EndIf

	EndIf

return


/***
*
*	ParExcluir()
*
*	Realiza a Exclusao da Partidas da competicao selecionada.
*
*   Competicoes -> Partidas -> ParExcluir
*/
STATIC PROCEDURE ParExcluir()

	If .not. Empty( PARTIDAS->PAR_CODIGO )
		
		If Alert( 'Confirma Exclusao do Registro ?', {' Sim ', ' Nao ' } ) == 1

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Marca o Registro para Delecao
				If PARTIDAS->( NetRLock() )
					PARTIDAS->( dbDelete() )
					PARTIDAS->( dbUnlock() )
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
*   Competicoes -> Acoes
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
