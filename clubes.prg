/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  clubes.prg
*
***/

#include 'set.ch'
#include 'box.ch'
#include 'inkey.ch'
#include 'common.ch'
#include 'setcurs.ch'
#include 'getexit.ch'
#include 'clubes.ch'
#include 'dbfunc.ch'
#include 'main.ch'

//#include 'hbxml.ch'

static aClubes

memvar GetList

/***
*
*	Clubes()
*
*	Realiza a manutencao do cadastro de clubes.
*
*/
PROCEDURE Clubes

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
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 32
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 10
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 32
		oWindow:cHeader := PadC( 'Clubes', Len( 'Clubes' ) + 2, ' ')
		oWindow:Open()

		// Desenha a Linha de Botoes
		hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
					oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

		// Estabelece o Filtro para exibicao dos registros
		bFiltro := { || .not. CLUBES->( Eof() ) }

		dbSelectArea('CLUBES')
		CLUBES->( dbEval( {|| nMaxItens++ }, bFiltro ) )
		CLUBES->( dbSetOrder(1), dbGoTop() )

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
			oColumn 			:= TBColumnNew( PadC( 'Concurso', 10 ), CLUBES->( FieldBlock( 'CLU_CODIGO' ) ) )
			oColumn:picture 	:= '@!'
			oColumn:width   	:= 10
			oBrowse:addColumn( oColumn )

			oColumn 			:= TBColumnNew( PadC( 'Clubes', 10 ), { || AllTrim( CLUBES->CLU_ABREVI ) + '/' + AllTrim( CLUBES->CLU_UF ) } )
			oColumn:picture 	:= '@!'
			oColumn:width   	:= 30
			oBrowse:addColumn( oColumn )

			oColumn 			:= TBColumnNew( PadC( 'Nome', 30 ), CLUBES->( FieldBlock( 'CLU_NOME' ) ) )
			oColumn:picture 	:= '@!'
			oColumn:width   	:= 30
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

			oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Ac&oes ' )
			oTmpButton:sBlock    := { || Acoes() }
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
*	Realiza a inclusao de Clubes.
*
*   Clubes -> Incluir
*
*/
STATIC PROCEDURE Incluir

local lContinua     := pTRUE
local lPushButton
local oWindow
local nCodigo       := 0


	begin sequence

		// Salva a Area corrente na Pilha
		DstkPush()

		// Inicializa as Variaveis de Dados
		xInitClubes

		// Inicializa as Variaveis de no vetor aClubes
		xStoreClubes

		// Cria o Objeto Windows
		oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  3
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 28
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  3
		oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 28
		oWindow:cHeader := PadC( 'Incluir', Len( 'Incluir' ) + 2, ' ')
		oWindow:Open()

		while lContinua

			@ oWindow:nTop+ 1, oWindow:nLeft+ 9 GET     pCLUBES_CAD_ABREVIADO                          ;
												PICT    '@K!S20'                                       ;
												CAPTION 'Abrev.'                                       ;
												COLOR   SysFieldGet()

			@ oWindow:nTop+ 1, oWindow:nLeft+34, ;
				oWindow:nTop + 1, oWindow:nLeft+54 	GET      pCLUBES_CAD_UF                            ;
													LISTBOX pCLUBES_CAD_LOCALIDADE                     ;
													DROPDOWN                                           ;
													CAPTION 'UF'                                       ;
													COLOR   SysFieldListBox()

			@ oWindow:nTop+ 3, oWindow:nLeft+ 9 GET         pCLUBES_CAD_NOME                           ;
												PICT    '@K!S46'                                       ;
												CAPTION 'Nome.'                                        ;
												COLOR   SysFieldGet()

			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                     ;
													CAPTION ' Con&firma '                              ;
													COLOR   SysPushButton()                            ;
													STYLE   ''                                         ;
													WHEN    .not. Empty( pCLUBES_CAD_ABREVIADO ) .and. ;
															.not. Empty( pCLUBES_CAD_UF ) .and.        ;
															.not. Empty( pCLUBES_CAD_NOME )            ;
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
					// Pesquisa na base de dados um codigo valido para cadastrar o clube
					CLUBES->( dbEval( { || nCodigo++ }, { || .not. Eof() } ) )
					CLUBES->( dbSetOrder(1) )
					while CLUBES->( dbSeek( StrZero( nCodigo, 5 ) ) )
						nCodigo++
					enddo
				always
					
					begin sequence

						If CLUBES->( NetAppend() )
							CLUBES->CLU_CODIGO := StrZero( nCodigo, 5 )
							CLUBES->CLU_ABREVI := pCLUBES_CAD_ABREVIADO
							CLUBES->CLU_NOME   := pCLUBES_CAD_NOME
							CLUBES->CLU_UF     := pCLUBES_CAD_UF
							CLUBES->( dbUnlock() )
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
*	Realiza a manutencao no cadastro de clubes.
*
*   Clubes -> Modificar
*
*/
STATIC PROCEDURE Modificar

local lContinua   := pTRUE
local lPushButton
local oWindow


	//************************************************************************
	// A rotina so deve ser executada somente se ja houverem dados cadastrados
	//************************************************************************
	If .not. Empty(	CLUBES->CLU_CODIGO )

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			// Inicializa o vetor aClubes
			xInitClubes

			// Inicializa as Variaveis de no vetor aClubes
			xStoreClubes

			//
			// Atualiza a variaveis com o registro selecionado
			//
			pCLUBES_CAD_CODIGO    := CLUBES->CLU_CODIGO
			pCLUBES_CAD_ABREVIADO := CLUBES->CLU_ABREVI
			pCLUBES_CAD_NOME      := CLUBES->CLU_NOME
			pCLUBES_CAD_UF        := CLUBES->CLU_UF


			// Cria o Objeto Windows
			oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
			oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  3
			oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 28
			oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  3
			oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 28
			oWindow:cHeader := PadC( 'Modificar', Len( 'Modificar' ) + 2, ' ')
			oWindow:Open()


			while lContinua

				@ oWindow:nTop+ 1, oWindow:nLeft+ 9 GET     pCLUBES_CAD_ABREVIADO                          ;
													VALID   .not. Empty( pCLUBES_CAD_ABREVIADO )           ;
													PICT    '@K!S20'                                       ;
													CAPTION 'Nome'                                         ;
													COLOR   SysFieldGet()

				@ oWindow:nTop+ 1, oWindow:nLeft+34, ;
					oWindow:nTop + 1, oWindow:nLeft+54  GET     pCLUBES_CAD_UF                             ;
														LISTBOX pCLUBES_CAD_LOCALIDADE                     ;
														VALID   .not. Empty( pCLUBES_CAD_UF )              ;														
														DROPDOWN                                           ;
														CAPTION 'UF'                                       ;
														COLOR   SysFieldListBox()

				@ oWindow:nTop+ 3, oWindow:nLeft+ 9 GET     pCLUBES_CAD_NOME                               ;
													VALID   .not. Empty( pCLUBES_CAD_NOME )                ;
													PICT    '@K!S46'                                       ;
													CAPTION 'Nome'                                         ;
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

						If CLUBES->( NetRLock() )
							CLUBES->CLU_ABREVI := pCLUBES_CAD_ABREVIADO
							CLUBES->CLU_NOME   := pCLUBES_CAD_NOME
							CLUBES->CLU_UF     := pCLUBES_CAD_UF
							CLUBES->( dbUnlock() )
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
*	Realiza a exclusao no cadastro de clubes.
*
*   Clubes -> Excluir
*
*/
STATIC PROCEDURE Excluir

	//************************************************************************
	// A rotina so deve ser executada somente se ja houverem dados cadastrados
	//************************************************************************
	If .not. Empty( CLUBES->CLU_CODIGO )

		If Alert( 'Confirma Exclusao do Registro ?', {' Sim ', ' Nao ' } ) == 1

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Marca o Registro para eliminacao
				If CLUBES->( NetRLock() )
					CLUBES->( dbDelete() )
					CLUBES->( dbUnlock() )
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
*   Clubes -> Acoes
*
*/
STATIC PROCEDURE Acoes

local lPushButton
local oWindow
local lContinua   := pTRUE
local aGroup      := Array(1)
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

			aGroup[1]           := RadioButton( oWindow:nTop+ 2, oWindow:nLeft+ 4, 'Impressao &Relacao Resultados' )
			aGroup[1]:ColorSpec := SysFieldBRadioBox()

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
//						LTFRelResult()

				end case

			EndIf

		enddo

	always
		// Fecha o Objeto Windows
		oWindow:Close()
	end sequence

return
