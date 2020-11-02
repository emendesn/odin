/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  dsena.prg
*
***/

#include 'set.ch'
#include 'box.ch'
#include 'inkey.ch'
#include 'error.ch'
#include 'common.ch'
#include 'setcurs.ch'
#include 'getexit.ch'
//#include 'apostas.ch'
#include 'dsena.ch'
#include 'dbfunc.ch'
#include 'main.ch'

static aDuplaSena

memvar GetList

/***
*
*	DSAMntBrowse()
*
*	Exibe a relacao de concursos ja realizados.
*
*/
PROCEDURE DSAMntBrowse()

local oBrowse, oColumn
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

local oSequen1
local oSequen2
local aSelDez1      := {}
local aSelDez2      := {}
local aDezenas
local nRow          := 1
local nPointer
local nPosDezenas   := 1
local nLinDezenas
local nColDezenas
local nGrade


	If SystemConcurso() == pDUPLA_SENA

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pDUPLA_SENA } ) ) > 0

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
							aDezenas[ nLinDezenas ][ nColDezenas ] := '  '
						EndIf
						nPosDezenas++
					next
				next

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

				// Estabelece o Filtro para exibicao dos registros
				bFiltro := { || CONCURSO->CON_JOGO == pDUPLA_SENA .and. CONCURSO->( .not. Eof() ) }

				dbSelectArea('CONCURSO')
				CONCURSO->( dbEval( {|| nMaxItens++ }, bFiltro ) )
				CONCURSO->( dbSetOrder(2), dbSeek( pDUPLA_SENA ) )

				begin sequence

					// Exibe o Browse com as Apostas
					oBrowse               	:= 	TBrowseDB( oWindow:nTop+ 1, oWindow:nLeft+ 1, ;
															( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 3 ), oWindow:nRight- 1 )
					oBrowse:skipBlock     	:= 	{ |xSkip,xRecno| iif( ( xRecno := DBSkipper( xSkip, bFiltro ) ) <> 0, ( nCount += xRecno, xRecno ), xRecno ) }
					oBrowse:goTopBlock    	:= 	{ || nCount := 1, GoTopDB( bFiltro ) }
					oBrowse:goBottomBlock 	:= 	{ || nCount := nMaxItens, GoBottomDB( bFiltro ) }
					oBrowse:colorSpec     	:= SysBrowseColor()
					oBrowse:headSep       	:= Chr(205)
					oBrowse:colSep        	:= Chr(179)
					oBrowse:Cargo         	:= {}

					// Adiciona as Colunas
					oColumn 		:= TBColumnNew( PadC( 'Concurso', 10 ), CONCURSO->( FieldBlock( 'CON_CONCUR' ) ) )
					oColumn:picture := '@!'
					oColumn:width   := 10
					oBrowse:addColumn( oColumn )

					oColumn 		:= TBColumnNew( PadC( 'Sorteio', 10 ), CONCURSO->( FieldBlock( 'CON_SORTEI' ) ) )
					oColumn:picture := '@D 99/99/99'
					oColumn:width   := 10
					oBrowse:addColumn( oColumn )

					hb_DispBox( ( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 2 ), oWindow:nLeft+ 1, ;
								( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 2 ), oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					// Exibe a Primeira Coluna de Dezenas
					oSequen1               	:= TBrowseNew(	( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 1 ), oWindow:nLeft+ 1, ;
															( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) - 3 ), oWindow:nRight- 1 )
					oSequen1:skipBlock     	:=	{ |x,k| ;
													k := iif(Abs(x) >= iif( x >= 0,								;
																	Len( aDezenas ) - nRow, nRow - 1),			;
															iif(x >= 0, Len( aDezenas ) - nRow,1 - nRow), x )	;
															, nRow += k, k										;
												}
					oSequen1:goTopBlock    	:= 	{ || nRow := 1 }
					oSequen1:goBottomBlock 	:= 	{ || nRow := Len( aDezenas ) }
					oSequen1:colorSpec     	:= SysBrowseColor()
					oSequen1:autoLite      	:= pFALSE

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 1] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 2] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 3] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 4] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 5] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 6] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 7] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 8] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 9] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][10] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez1, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen1:addColumn( oColumn )


					hb_DispBox( ( oWindow:nBottom- 2 ) - ( nGrade + 1 ), oWindow:nLeft+ 1, ;
								( oWindow:nBottom- 2 ) - ( nGrade + 1 ), oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					// Exibe a Segunda Coluna de Dezenas
					oSequen2               	:= 	TBrowseNew( ( oWindow:nBottom- 2 ) - nGrade, oWindow:nLeft+ 1, ;
															( oWindow:nBottom- 2 ) - 1, oWindow:nRight- 1 )
					oSequen2:skipBlock     	:= 	{ |x,k| ;
													k := iif(Abs(x) >= iif( x >= 0,								;
																		Len( aDezenas ) - nRow, nRow - 1),		;
															iif(x >= 0, Len( aDezenas ) - nRow,1 - nRow), x )	;
														, nRow += k, k											;
												}
					oSequen2:goTopBlock    	:= 	{ || nRow := 1 }
					oSequen2:goBottomBlock 	:= 	{ || nRow := Len( aDezenas ) }
					oSequen2:colorSpec     	:= SysBrowseColor()
					oSequen2:autoLite      	:= pFALSE

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 1] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 2] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 3] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 4] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 5] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 6] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 7] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 8] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][ 9] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )

					oColumn            	:= TBColumnNew( '', { || aDezenas[ nRow ][10] } )
					oColumn:colorBlock 	:= { |xItem| iif( hb_AScan( aSelDez2, xItem,,, pTRUE ) > 0, {3,2}, {1,2} ) }
					oColumn:width      	:= 2
					oSequen2:addColumn( oColumn )


					// Realiza a Montagem da Barra de Rolagem
					oScrollBar 		    	:= 	ScrollBar( 	oWindow:nTop+ 3, ( oWindow:nBottom- 2 ) - ( ( nGrade * 2 ) + 3 ), ;
															oWindow:nRight )
					oScrollBar:colorSpec 	:= SysScrollBar()
					oScrollBar:display()


					// Desenha os botoes da tela
					oTmpButton           	:= PushButton( oWindow:nBottom- 1, oWindow:nLeft+ 2, ' &Incluir ' )
					oTmpButton:sBlock    	:= { || DSAIncluir() }
					oTmpButton:Style     	:= ''
					oTmpButton:ColorSpec 	:= SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           	:= PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
					oTmpButton:sBlock    	:= { || DSAModificar() }
					oTmpButton:Style     	:= ''
					oTmpButton:ColorSpec 	:= SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           	:= PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' &Excluir ' )
					oTmpButton:sBlock    	:= { || DSAExcluir() }
					oTmpButton:Style     	:= ''
					oTmpButton:ColorSpec 	:= SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           	:= PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Ac&oes ' )
					oTmpButton:sBlock    	:= { || DSAAcoes() }
					oTmpButton:Style     	:= ''
					oTmpButton:ColorSpec 	:= SysPushButton()
					AADD( oBrowse:Cargo, { oTmpButton, UPPER( SUBSTR( oTmpButton:Caption, AT('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           	:= PushButton( oWindow:nBottom- 1, oWindow:nLeft+42, ' &Sair ' )
					oTmpButton:sBlock    	:= { || lSair := pTRUE }
					oTmpButton:Style     	:= ''
					oTmpButton:ColorSpec 	:= SysPushButton()
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
						oScrollBar:current 	:= nCount * ( 100 / nMaxItens )
						oScrollBar:update()

                        // Atualiza a primeira grade com as dezenas dos jogos
						If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR + '01' ) )
							If Len( aSelDez1 := ParseDezenas( JOGOS->JOG_DEZENA ) ) > 0
								oSequen1:refreshAll()
								oSequen1:forceStable()
							EndIf
						EndIf

                        // Atualiza a segunda grade com as dezenas dos jogos
						If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR + '02' ) )
							If Len( aSelDez2 := ParseDezenas( JOGOS->JOG_DEZENA ) ) > 0
								oSequen2:refreshAll()
								oSequen2:forceStable()
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
*	DSAIncluir()
*
*	Realiza a montagem da tela para inclusao dos dados do concurso.
*
*   DSAMntBrowse -> DSAIncluir
*
*/
STATIC PROCEDURE DSAIncluir

local nPointer
local lContinua  := pTRUE
local lConfirma
local lCancela
local oWindow

local nCodigo    := 1
local cAutoSequence
local oIniFile

memvar xCount, xTemp


	//************************************************************************
	// A rotina so deve ser executada a partir de concurso dupla sena
	//************************************************************************
	If SystemConcurso() == pDUPLA_SENA

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pDUPLA_SENA } ) ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Inicializa as Variaveis de Dados
				xInitDuplaSena

				// Inicializa as Variaveis de no vetor aDuplaSena
				xStoreDuplaSena

				//
				// Realiza a abertura do arquivo INI
				//
				oIniFile := TIniFile():New( 'odin.ini' )

				//
				// Parametro para definir a sequencia automatica
				//
				If ( cAutoSequence := oIniFile:ReadString( 'DUPLASENA', 'AUTO_SEQUENCE', '0' ) ) == '1'
					//
					// Codigo sequencial
					//
					dbEval( { || nCodigo++ }, { || CONCURSO->CON_JOGO == pDUPLA_SENA .and. CONCURSO->( .not. Eof() ) } )
					pDSA_CONCURSO := StrZero( nCodigo, 5 )
				EndIf

				// Cria o Objeto Windows
				oWindow        	:= WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 12
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 21
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 12
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 21
				oWindow:Open()

				WHILE lContinua

					@ oWindow:nTop+ 1, oWindow:nLeft+14	GET     pDSA_CONCURSO                                  ;
														PICT    '@K 99999'                                     ;
														SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),5));
														CAPTION 'Concurso'                                     ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 1, oWindow:nLeft+30 GET     pDSA_SORTEIO                                   ;
														PICT    '@KD 99/99/99'                                 ;
														CAPTION 'Sorteio'                                      ;
														COLOR   SysFieldGet()

					hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 3, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 3, oWindow:nLeft+ 2, ' Primeiro Sorteio ', SystemLabelColor() )

					@ oWindow:nTop+ 4, oWindow:nLeft+12 GET   pDSA_DEZENA_1_01                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+16	GET   pDSA_DEZENA_1_02                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+20	GET   pDSA_DEZENA_1_03                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+24	GET   pDSA_DEZENA_1_04                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+28	GET   pDSA_DEZENA_1_05                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+32	GET   pDSA_DEZENA_1_06                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()


					hb_DispBox( oWindow:nTop+ 6, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 6, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 6, oWindow:nLeft+ 2, ' Segundo Sorteio ', SystemLabelColor() )

					@ oWindow:nTop+ 7, oWindow:nLeft+12	GET   pDSA_DEZENA_2_01                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+16	GET   pDSA_DEZENA_2_02                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+20	GET   pDSA_DEZENA_2_03                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+24	GET   pDSA_DEZENA_2_04                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+28	GET   pDSA_DEZENA_2_05                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+32	GET   pDSA_DEZENA_2_06                                 ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()


					hb_DispBox( oWindow:nTop+ 9, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 9, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 9, oWindow:nLeft+ 2, ' Premio Primeiro Sorteio ', SystemLabelColor() )

					@ oWindow:nTop+10, oWindow:nLeft+12	SAY   'Ganhadores'                                     ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+10, oWindow:nLeft+30	SAY   'Premio'                                         ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+11, oWindow:nLeft+10	GET     pDSA_ACERTO_1_SENA                             ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION 'Sena'                                         ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '06', pDSA_SORTEIO )

					@ oWindow:nTop+12, oWindow:nLeft+10	GET     pDSA_ACERTO_1_QUINA                            ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION 'Quina'                                        ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pDSA_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+10	GET     pDSA_ACERTO_1_QUADRA                           ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION 'Quadra'                                       ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pDSA_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+10	GET     pDSA_ACERTO_1_TERNO                            ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION 'Terno'                                        ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pDSA_SORTEIO )

					@ oWindow:nTop+11, oWindow:nLeft+24	GET   pDSA_PREMIO_1_SENA                               ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '06', pDSA_SORTEIO )

					@ oWindow:nTop+12, oWindow:nLeft+24	GET   pDSA_PREMIO_1_QUINA                              ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pDSA_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+24	GET   pDSA_PREMIO_1_QUADRA                             ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pDSA_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+24	GET   pDSA_PREMIO_1_TERNO                              ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pDSA_SORTEIO )

					hb_DispBox( oWindow:nTop+16, oWindow:nLeft+ 1, ;
								oWindow:nTop+16, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+16, oWindow:nLeft+ 2, ' Premio Segundo Sorteio ', SystemLabelColor() )

					@ oWindow:nTop+17, oWindow:nLeft+12	SAY   'Ganhadores'                                     ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+17, oWindow:nLeft+30	SAY   'Premio'                                         ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+18, oWindow:nLeft+10 GET     pDSA_ACERTO_2_SENA                             ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION 'Sena'                                         ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '06', pDSA_SORTEIO )

					@ oWindow:nTop+19, oWindow:nLeft+10 GET     pDSA_ACERTO_2_QUINA                            ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION 'Quina'                                        ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pDSA_SORTEIO )

					@ oWindow:nTop+20, oWindow:nLeft+10 GET     pDSA_ACERTO_2_QUADRA                           ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION 'Quadra'                                       ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pDSA_SORTEIO )

					@ oWindow:nTop+21, oWindow:nLeft+10 GET     pDSA_ACERTO_2_TERNO                            ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION 'Terno'                                        ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pDSA_SORTEIO )

					@ oWindow:nTop+18, oWindow:nLeft+24 GET   pDSA_PREMIO_2_SENA                               ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '06', pDSA_SORTEIO )

					@ oWindow:nTop+19, oWindow:nLeft+24 GET   pDSA_PREMIO_2_QUINA                              ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pDSA_SORTEIO )

					@ oWindow:nTop+20, oWindow:nLeft+24 GET   pDSA_PREMIO_2_QUADRA                             ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pDSA_SORTEIO )

					@ oWindow:nTop+21, oWindow:nLeft+24 GET   pDSA_PREMIO_2_TERNO                              ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pDSA_SORTEIO )


					hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
								oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					@ oWindow:nBottom- 1, oWindow:nRight-22	GET     lConfirma PUSHBUTTON                       ;
															CAPTION ' Con&firma '                              ;
															COLOR   SysPushButton()                            ;
															STYLE   ''                                         ;
															WHEN    Val( pDSA_CONCURSO ) > 0 .and.             ;
																	.not. Empty( pDSA_SORTEIO ) .and.          ;
																	.not. Empty( pDSA_SORTEIO ) .and.          ;
																	.not. Empty( pDSA_DEZENA_1_01 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_1_02 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_1_03 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_1_04 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_1_05 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_1_06 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_2_01 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_2_02 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_2_03 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_2_04 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_2_05 ) .and.      ;
																	.not. Empty( pDSA_DEZENA_2_06 )            ;
															STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

					@ oWindow:nBottom- 1, oWindow:nRight-11	GET     lCancela  PUSHBUTTON                       ;
															CAPTION ' Cance&lar '                              ;
															COLOR   SysPushButton()                            ;
															STYLE   ''                                         ;
															STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

					Set( _SET_CURSOR, SC_NORMAL )

					READ

					Set( _SET_CURSOR, SC_NONE )

					If lContinua .and. LastKey() != K_ESC

						pDSA_CONCURSO := StrZero( Val( pDSA_CONCURSO ), 5 )

						//************************************************************************
						//*Verifica se concurso ja existe                                        *
						//************************************************************************
						If .not. CONCURSO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO ) )

							//************************************************************************
							//*Verifica a duplicidade de dezenas na primeira sequencia               *
							//************************************************************************
							If xDuplicSequencia( aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_1 ] )

								//************************************************************************
								//*Verifica a duplicidade de dezenas na segunda sequencia                *
								//************************************************************************
								If xDuplicSequencia( aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_2 ] )

									//************************************************************************
									//*Verifica cada item da primeira sequencia para identificar se o valor  *
									//*digitado esta dentro da faixa especifica do concurso                  *
									//************************************************************************
									If xVerificaSequencia(	aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_1 ], ;
															pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )

										//************************************************************************
										//*Verifica cada item da segunda sequencia para identificar se o valor   *
										//*digitado esta dentro da faixa especifica do concurso                  *
										//************************************************************************
										If xVerificaSequencia(	aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_2 ], ;
																pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )

											If DSAGravaDados()
												lContinua := pFALSE
											EndIf

										Else
											ErrorTable( '104' ) // Dezena digitada na segunda sequencia fora da faixa.
										EndIf

									Else
										ErrorTable( '103' )  // Dezena digitada na primeira sequencia fora da faixa.
									EndIf

								Else
									ErrorTable( '102' ) // A segunda sequencia encontra em duplicidade.
								EndIf

							Else
								ErrorTable( '101' ) // A primeira sequencia encontra em duplicidade.
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
				oIniFile:WriteString( 'DUPLASENA', 'AUTO_SEQUENCE', cAutoSequence )

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
*	DSAModificar()
*
*	Realiza a Alteracao do registro selecionado.
*
*   DSAMntBrowse -> DSAModificar
*
*/
STATIC PROCEDURE DSAModificar()

local nPos
local nSeq
local nPointer
local lContinua  := pTRUE
local lConfirma
local lCancela
local oWindow

memvar xCount, xTemp


	//************************************************************************
	// A rotina so deve ser executada a partir de concurso dupla sena
	//************************************************************************
	If CONCURSO->CON_JOGO == pDUPLA_SENA

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pDUPLA_SENA } ) ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Inicializa as Variaveis de Dados
				xInitDuplaSena

				// Inicializa as Variaveis de no vetor aDuplaSena
				xStoreDuplaSena

				//
				// Atualiza a variaveis com o registro selecionado
				//
				pDSA_CONCURSO := CONCURSO->CON_CONCUR
				pDSA_SORTEIO  := CONCURSO->CON_SORTEI

				//
				// Atualiza as dezenas da primeira sequencia do concurso selecionado
				//
				nPos := 0
				nSeq := 1
				If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR + '01' ) )
					while nPos++ <= Len( AllTrim( JOGOS->JOG_DEZENA ) )
						If IsDigit( SubStr( AllTrim( JOGOS->JOG_DEZENA ), nPos, 1 ) )
							aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_1 ][ nSeq++ ] := SubStr( AllTrim( JOGOS->JOG_DEZENA ), nPos++, 2 )
						EndIf
					enddo
				EndIf

				//
				// Atualiza as dezenas da segunda sequencia do concurso selecionado
				//
				nPos := 0
				nSeq := 1
				If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR + '02' ) )
					while nPos++ <= Len( AllTrim( JOGOS->JOG_DEZENA ) )
						If IsDigit( SubStr( AllTrim( JOGOS->JOG_DEZENA ), nPos, 1 ) )
							aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_2 ][ nSeq++ ] := SubStr( AllTrim( JOGOS->JOG_DEZENA ), nPos++, 2 )
						EndIf
					enddo
				EndIf

				//
				// Atualiza os dados da premiacao da primeira sequencia
				//
				If RATEIO->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR + '01' ) )
					while RATEIO->RAT_JOGO == CONCURSO->CON_JOGO .and. ;
						RATEIO->RAT_CONCUR == CONCURSO->CON_CONCUR .and. ;
						RATEIO->RAT_FAIXA == '01' .and. .not. ;
						RATEIO->( Eof() )
						do case
							case RATEIO->RAT_PREMIA == '03'
								pDSA_ACERTO_1_TERNO  := RATEIO->RAT_ACERTA
								pDSA_PREMIO_1_TERNO  := RATEIO->RAT_RATEIO
							case RATEIO->RAT_PREMIA == '04'
								pDSA_ACERTO_1_QUADRA := RATEIO->RAT_ACERTA
								pDSA_PREMIO_1_QUADRA := RATEIO->RAT_RATEIO
							case RATEIO->RAT_PREMIA == '05'
								pDSA_ACERTO_1_QUINA  := RATEIO->RAT_ACERTA
								pDSA_PREMIO_1_QUINA  := RATEIO->RAT_RATEIO
							case RATEIO->RAT_PREMIA == '06'
								pDSA_ACERTO_1_SENA   := RATEIO->RAT_ACERTA
								pDSA_PREMIO_1_SENA   := RATEIO->RAT_RATEIO
						end case
						RATEIO->( dbSkip() )
					enddo
				EndIf


				//
				// Atualiza os dados da premiacao da segunda sequencia
				//
				If RATEIO->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR + '02' ) )
					while RATEIO->RAT_JOGO == CONCURSO->CON_JOGO .and. ;
						RATEIO->RAT_CONCUR == CONCURSO->CON_CONCUR .and. ;
						RATEIO->RAT_FAIXA == '02' .and. .not. ;
						RATEIO->( Eof() )
						do case
							case RATEIO->RAT_PREMIA == '03'
								pDSA_ACERTO_2_TERNO  := RATEIO->RAT_ACERTA
								pDSA_PREMIO_2_TERNO  := RATEIO->RAT_RATEIO
							case RATEIO->RAT_PREMIA == '04'
								pDSA_ACERTO_2_QUADRA := RATEIO->RAT_ACERTA
								pDSA_PREMIO_2_QUADRA := RATEIO->RAT_RATEIO
							case RATEIO->RAT_PREMIA == '05'
								pDSA_ACERTO_2_QUINA  := RATEIO->RAT_ACERTA
								pDSA_PREMIO_2_QUINA  := RATEIO->RAT_RATEIO
							case RATEIO->RAT_PREMIA == '06'
								pDSA_ACERTO_2_SENA   := RATEIO->RAT_ACERTA
								pDSA_PREMIO_2_SENA   := RATEIO->RAT_RATEIO
						end case
						RATEIO->( dbSkip() )
					enddo
				EndIf

				// Cria o Objeto Windows
				oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := Int( SystemMaxRow() / 2 ) - 12
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 21
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 12
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 21
				oWindow:Open()

				while lContinua

					@ oWindow:nTop+ 1, oWindow:nLeft+14	GET     pDSA_CONCURSO                            ;
														WHEN    pFALSE		                             ;
														PICT    '@!'                                     ;
														CAPTION 'Concurso'                               ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 1, oWindow:nLeft+30	GET     pDSA_SORTEIO                             ;
														VALID   .not. Empty( pDSA_SORTEIO )              ;
														PICT    '@KD 99/99/99'                           ;
														CAPTION 'Sorteio'                                ;
														COLOR   SysFieldGet()


					hb_DispBox( oWindow:nTop+ 3, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 3, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 3, oWindow:nLeft+ 2, ' Primeiro Sorteio ', SystemLabelColor() )

					@ oWindow:nTop+ 4, oWindow:nLeft+12	GET   pDSA_DEZENA_1_01                           ;
														VALID .not. Empty( pDSA_DEZENA_1_01 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+16	GET   pDSA_DEZENA_1_02                           ;
														VALID .not. Empty( pDSA_DEZENA_1_02 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+20	GET   pDSA_DEZENA_1_03                           ;
														VALID .not. Empty( pDSA_DEZENA_1_03 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+24	GET   pDSA_DEZENA_1_04                           ;
														VALID .not. Empty( pDSA_DEZENA_1_04 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+28	GET   pDSA_DEZENA_1_05                           ;
														VALID .not. Empty( pDSA_DEZENA_1_05 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 4, oWindow:nLeft+32	GET   pDSA_DEZENA_1_06                           ;
														VALID .not. Empty( pDSA_DEZENA_1_06 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()


					hb_DispBox( oWindow:nTop+ 6, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 6, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 6, oWindow:nLeft+ 2, ' Segundo Sorteio ', SystemLabelColor() )

					@ oWindow:nTop+ 7, oWindow:nLeft+12	GET   pDSA_DEZENA_2_01                           ;
														VALID .not. Empty( pDSA_DEZENA_2_01 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+16	GET   pDSA_DEZENA_2_02                           ;
														VALID .not. Empty( pDSA_DEZENA_2_02 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+20	GET   pDSA_DEZENA_2_03                           ;
														VALID .not. Empty( pDSA_DEZENA_2_03 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+24	GET   pDSA_DEZENA_2_04                           ;
														VALID .not. Empty( pDSA_DEZENA_2_04 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+28	GET   pDSA_DEZENA_2_05                           ;
														VALID .not. Empty( pDSA_DEZENA_2_05 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+32	GET   pDSA_DEZENA_2_06                           ;
														VALID .not. Empty( pDSA_DEZENA_2_06 )            ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                    ;
														COLOR SysFieldGet()


					hb_DispBox( oWindow:nTop+ 9, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 9, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 9, oWindow:nLeft+ 2, ' Premio Primeiro Sorteio ', SystemLabelColor() )

					@ oWindow:nTop+10, oWindow:nLeft+12	SAY   'Ganhadores'                               ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+10, oWindow:nLeft+30	SAY   'Premio'                                   ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+11, oWindow:nLeft+10	GET     pDSA_ACERTO_1_SENA                       ;
														PICT    '@EN 9,999,999,999'                      ;
														CAPTION 'Sena'                                   ;
														COLOR   SysFieldGet()                            ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '06', pDSA_SORTEIO )

					@ oWindow:nTop+12, oWindow:nLeft+10	GET     pDSA_ACERTO_1_QUINA                      ;
														PICT    '@EN 9,999,999,999'                      ;
														CAPTION 'Quina'                                  ;
														COLOR   SysFieldGet()                            ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pDSA_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+10	GET     pDSA_ACERTO_1_QUADRA                     ;
														PICT    '@EN 9,999,999,999'                      ;
														CAPTION 'Quadra'                                 ;
														COLOR   SysFieldGet()                            ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pDSA_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+10	GET     pDSA_ACERTO_1_TERNO                      ;
														PICT    '@EN 9,999,999,999'                      ;
														CAPTION 'Terno'                                  ;
														COLOR   SysFieldGet()                            ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pDSA_SORTEIO )


					@ oWindow:nTop+11, oWindow:nLeft+24	GET   pDSA_PREMIO_1_SENA                         ;
														PICT  '@EN 99,999,999,999.99'                    ;
														COLOR SysFieldGet()                              ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '06', pDSA_SORTEIO )

					@ oWindow:nTop+12, oWindow:nLeft+24	GET   pDSA_PREMIO_1_QUINA                        ;
														PICT  '@EN 99,999,999,999.99'                    ;
														COLOR SysFieldGet()                              ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pDSA_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+24	GET   pDSA_PREMIO_1_QUADRA                       ;
														PICT  '@EN 99,999,999,999.99'                    ;
														COLOR SysFieldGet()                              ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pDSA_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+24	GET   pDSA_PREMIO_1_TERNO                        ;
														PICT  '@EN 99,999,999,999.99'                    ;
														COLOR SysFieldGet()                              ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pDSA_SORTEIO )


					hb_DispBox( oWindow:nTop+16, oWindow:nLeft+ 1, ;
								oWindow:nTop+16, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+16, oWindow:nLeft+ 2, ' Premio Segundo Sorteio ', SystemLabelColor() )

					@ oWindow:nTop+17, oWindow:nLeft+12	SAY   'Ganhadores'                               ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+17, oWindow:nLeft+30	SAY   'Premio'                                   ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+18, oWindow:nLeft+10	GET     pDSA_ACERTO_2_SENA                       ;
														PICT    '@EN 9,999,999,999'                      ;
														CAPTION 'Sena'                                   ;
														COLOR   SysFieldGet()                            ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '06', pDSA_SORTEIO )

					@ oWindow:nTop+19, oWindow:nLeft+10	GET     pDSA_ACERTO_2_QUINA                      ;
														PICT    '@EN 9,999,999,999'                      ;
														CAPTION 'Quina'                                  ;
														COLOR   SysFieldGet()                            ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pDSA_SORTEIO )

					@ oWindow:nTop+20, oWindow:nLeft+10	GET     pDSA_ACERTO_2_QUADRA                     ;
														PICT    '@EN 9,999,999,999'                      ;
														CAPTION 'Quadra'                                 ;
														COLOR   SysFieldGet()                            ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pDSA_SORTEIO )

					@ oWindow:nTop+21, oWindow:nLeft+10	GET     pDSA_ACERTO_2_TERNO                      ;
														PICT    '@EN 9,999,999,999'                      ;
														CAPTION 'Terno'                                  ;
														COLOR   SysFieldGet()                            ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pDSA_SORTEIO )


					@ oWindow:nTop+18, oWindow:nLeft+24	GET   pDSA_PREMIO_2_SENA                         ;
														PICT  '@EN 99,999,999,999.99'                    ;
														COLOR SysFieldGet()                              ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '06', pDSA_SORTEIO )

					@ oWindow:nTop+19, oWindow:nLeft+24	GET   pDSA_PREMIO_2_QUINA                        ;
														PICT  '@EN 99,999,999,999.99'                    ;
														COLOR SysFieldGet()                              ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '05', pDSA_SORTEIO )

					@ oWindow:nTop+20, oWindow:nLeft+24	GET   pDSA_PREMIO_2_QUADRA                       ;
														PICT  '@EN 99,999,999,999.99'                    ;
														COLOR SysFieldGet()                              ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '04', pDSA_SORTEIO )

					@ oWindow:nTop+21, oWindow:nLeft+24	GET   pDSA_PREMIO_2_TERNO                        ;
														PICT  '@EN 99,999,999,999.99'                    ;
														COLOR SysFieldGet()                              ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '03', pDSA_SORTEIO )


					hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
								oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					@ oWindow:nBottom- 1, oWindow:nRight-22	GET     lConfirma PUSHBUTTON                 ;
															CAPTION ' Con&firma '                        ;
															COLOR   SysPushButton()                      ;
															STYLE   ''                                   ;
															STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

					@ oWindow:nBottom- 1, oWindow:nRight-11	GET     lCancela  PUSHBUTTON                 ;
															CAPTION ' Cance&lar '                        ;
															COLOR   SysPushButton()                      ;
															STYLE   ''                                   ;
															STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

					Set( _SET_CURSOR, SC_NORMAL )

					READ

					Set( _SET_CURSOR, SC_NONE )

					If lContinua .and. LastKey() != K_ESC

						//************************************************************************
						//*Verifica a duplicidade de dezenas na primeira sequencia               *
						//************************************************************************
						If xDuplicSequencia( aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_1 ] )

							//************************************************************************
							//*Verifica a duplicidade de dezenas na segunda sequencia                *
							//************************************************************************
							If xDuplicSequencia( aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_2 ] )

								//************************************************************************
								//*Verifica cada item da primeira sequencia para identificar se o valor  *
								//*digitado esta dentro da faixa especifica do concurso                  *
								//************************************************************************
								If xVerificaSequencia(	aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_1 ], ;
														pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )

									//************************************************************************
									//*Verifica cada item da segunda sequencia para identificar se o valor   *
									//*digitado esta dentro da faixa especifica do concurso                  *
									//************************************************************************
									If xVerificaSequencia(	aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_2 ], ;
															pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )

										If DSAGravaDados()
											lContinua := pFALSE
										EndIf

									Else
										ErrorTable( '104' ) // Dezena digitada na segunda sequencia fora da faixa
									EndIf

								Else
									ErrorTable( '103' )  // Dezena digitada na primeira sequencia fora da faixa
								EndIf

							Else
								ErrorTable( '102' )  // A segunda sequencia encontra em duplicidade.
							EndIf

						Else
							ErrorTable( '101' )  // A primeira sequencia encontra em duplicidade.
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
*	DSAExcluir()
*
*	Realiza a exclusao do concurso da DUPLA SENA.
*
*   DSAMntBrowse -> DSAExcluir
*
*/
STATIC PROCEDURE DSAExcluir()

	If CONCURSO->CON_JOGO == pDUPLA_SENA

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
*	DSAGravaDados()
*
*	Realiza a gravacao dos dados da DUPLA SENA.
*
*/
STATIC FUNCTION DSAGravaDados()

local lRetValue := pFALSE


	begin sequence

		while .not. lRetValue

			If iif( CONCURSO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO ) ), CONCURSO->( NetRLock() ), CONCURSO->( NetAppend() ) )
				CONCURSO->CON_JOGO   := pDUPLA_SENA
				CONCURSO->CON_CONCUR := pDSA_CONCURSO
				CONCURSO->CON_SORTEI := pDSA_SORTEIO
				CONCURSO->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '01' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pDUPLA_SENA
				JOGOS->JOG_CONCUR := pDSA_CONCURSO
				JOGOS->JOG_FAIXA  := '01'
				JOGOS->JOG_DEZENA := ParseString( aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_1 ] )
				JOGOS->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '02' ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pDUPLA_SENA
				JOGOS->JOG_CONCUR := pDSA_CONCURSO
				JOGOS->JOG_FAIXA  := '02'
				JOGOS->JOG_DEZENA := ParseString( aDuplaSena[ pDSA_POS_DADOS ][ pDSA_POS_DADOS_SEQUENCIA_2 ] )
				JOGOS->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '01' + '03' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pDUPLA_SENA
				RATEIO->RAT_CONCUR := pDSA_CONCURSO
				RATEIO->RAT_FAIXA  := '01'
				RATEIO->RAT_PREMIA := '03'
				RATEIO->RAT_ACERTA := pDSA_ACERTO_1_TERNO
				RATEIO->RAT_RATEIO := pDSA_PREMIO_1_TERNO
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '01' + '04' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pDUPLA_SENA
				RATEIO->RAT_CONCUR := pDSA_CONCURSO
				RATEIO->RAT_FAIXA  := '01'
				RATEIO->RAT_PREMIA := '04'
				RATEIO->RAT_ACERTA := pDSA_ACERTO_1_QUADRA
				RATEIO->RAT_RATEIO := pDSA_PREMIO_1_QUADRA
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '01' + '05' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pDUPLA_SENA
				RATEIO->RAT_CONCUR := pDSA_CONCURSO
				RATEIO->RAT_FAIXA  := '01'
				RATEIO->RAT_PREMIA := '05'
				RATEIO->RAT_ACERTA := pDSA_ACERTO_1_QUINA
				RATEIO->RAT_RATEIO := pDSA_PREMIO_1_QUINA
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '01' + '06' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pDUPLA_SENA
				RATEIO->RAT_CONCUR := pDSA_CONCURSO
				RATEIO->RAT_FAIXA  := '01'
				RATEIO->RAT_PREMIA := '06'
				RATEIO->RAT_ACERTA := pDSA_ACERTO_1_SENA
				RATEIO->RAT_RATEIO := pDSA_PREMIO_1_SENA
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '02' + '03' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pDUPLA_SENA
				RATEIO->RAT_CONCUR := pDSA_CONCURSO
				RATEIO->RAT_FAIXA  := '02'
				RATEIO->RAT_PREMIA := '03'
				RATEIO->RAT_ACERTA := pDSA_ACERTO_2_TERNO
				RATEIO->RAT_RATEIO := pDSA_PREMIO_2_TERNO
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '02' + '04' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pDUPLA_SENA
				RATEIO->RAT_CONCUR := pDSA_CONCURSO
				RATEIO->RAT_FAIXA  := '02'
				RATEIO->RAT_PREMIA := '04'
				RATEIO->RAT_ACERTA := pDSA_ACERTO_2_QUADRA
				RATEIO->RAT_RATEIO := pDSA_PREMIO_2_QUADRA
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '02' + '05' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pDUPLA_SENA
				RATEIO->RAT_CONCUR := pDSA_CONCURSO
				RATEIO->RAT_FAIXA  := '02'
				RATEIO->RAT_PREMIA := '05'
				RATEIO->RAT_ACERTA := pDSA_ACERTO_2_QUINA
				RATEIO->RAT_RATEIO := pDSA_PREMIO_2_QUINA
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + pDSA_CONCURSO + '02' + '06' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pDUPLA_SENA
				RATEIO->RAT_CONCUR := pDSA_CONCURSO
				RATEIO->RAT_FAIXA  := '02'
				RATEIO->RAT_PREMIA := '06'
				RATEIO->RAT_ACERTA := pDSA_ACERTO_2_SENA
				RATEIO->RAT_RATEIO := pDSA_PREMIO_2_SENA
				RATEIO->( dbUnlock() )
			EndIf

			lRetValue := pTRUE

		enddo

	end sequence
		
return( lRetValue )


/***
*
*	DSAAcoes()
*
*	Exibe o menu de acoes relacionadas.
*
*   DSAMntBrowse -> DSAAcoes
*
*/
STATIC PROCEDURE DSAAcoes

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
						DSACombina()

					case nTipAcoes == 2
						DSARelResult()

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
*	DSACombina()
*
*	Exibe as opcoes para gerar combinacoes.
*
*   DSAMntBrowse -> DSAAcoes -> DSACombina
*
*/
STATIC PROCEDURE DSACombina

local oWindow
local lPushButton
local lContinua   := pTRUE

local aGroup      := Array(3)
local nOpcao      := 1
local nQuantJog   := 1
local nQuantDez   := pDSA_DEF_MIN_DEZENAS


	begin sequence

		// Cria o Objeto Windows
		oWindow        	:= WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
		oWindow:nTop    := Int( SystemMaxRow() / 2 ) -  5
		oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 34
		oWindow:nBottom := Int( SystemMaxRow() / 2 ) +  5
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
				oWindow:nTop+ 5, oWindow:nRight- 3 	GET        nOpcao                              ;
													RADIOGROUP aGroup                              ;
													CAPTION    ' &Acoes Relacionadas '             ;
													COLOR      SysFieldGRadioBox()

			hb_DispBox( oWindow:nBottom- 4, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 4, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
							
			@ oWindow:nBottom- 3, oWindow:nLeft+ 15 GET     nQuantJog                              ;
													PICT    '@EN 99999999999999'                   ;
													WHEN    .not. nOpcao == 2                      ;
													CAPTION 'Quant.Jogos'                          ;
													COLOR   SysFieldGet()

			@ oWindow:nBottom- 3, oWindow:nLeft+ 45 GET     nQuantDez                              ;
													PICT    '@EN 99'                               ;
													WHEN    .not. nOpcao == 3                      ;
													CAPTION 'Quant.Dezenas'                        ;
													COLOR   SysFieldGet()


			hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
						oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

			@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                 ;
													CAPTION ' Con&firma '                          ;
													COLOR   SysPushButton()                        ;
													STYLE   ''                                     ;
													WHEN    nQuantJog >= 1 .and.                   ;
															nQuantJog <= pDSA_DEF_MAX_COMB .and.   ;
															nQuantDez >= pDSA_DEF_MIN_DEZENAS .and.;
															nQuantDez <= pDSA_DEF_MAX_DEZENAS      ;
													STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

			@ oWindow:nBottom- 1, oWindow:nRight-11 GET     lPushButton PUSHBUTTON                 ;
													CAPTION ' Cance&lar '                          ;
													COLOR   SysPushButton()                        ;
													STYLE   ''                                     ;
													STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

			Set( _SET_CURSOR, SC_NORMAL )

			READ

			Set( _SET_CURSOR, SC_NONE )

			If lContinua .and. LastKey() != K_ESC

				do case
					case nOpcao == 1
						DSAAnaliAleatoria( nQuantJog, nQuantDez)
					
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
*	DSAAnaliAleatoria()
*
*	Realiza a geracao das dezenas para a DUPLA SENA aleatoriamente.
*
*   DSAMntBrowse -> DSAAcoes -> DSACombina -> DSAAnaliAleatoria
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
* nQuantDezenas : Informa o numero de dezenas a ser geradas por jogos
*
*
*/
STATIC PROCEDURE DSAAnaliAleatoria( nQuantJogos, nQuantDezenas )

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
			nQuantDezenas TO pDSA_DEF_MIN_DEZENAS

	If Alert( 'Gerar as combinacoes Aleatorias ?', {' Sim ', ' Nao ' } ) == 1

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			begin sequence with { |oErr| Break( oErr ) }

				AAdd( aFileTmp, { GetNextFile( SystemTmp() ), GetNextFile( SystemTmp() ) } )

				dbCreate( ATail( aFileTmp )[1], { 	{ 'TMP_COD',  'C',  7, 0 },  ;
													{ 'TMP_SEQ1', 'C', 44, 0 },  ;
													{ 'TMP_SEQ2', 'C', 44, 0 },  ;
													{ 'TMP_MRK',  'C',  1, 0 } } )

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

				If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pDUPLA_SENA } ) ) > 0

					begin sequence				

						// Inicializa a Barra de Progresso
						oBarProgress := ProgressBar():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
						oBarProgress:Open()

						while nJogCorrente <= nQuantJogos

							// Atualiza a barra de Progresso
							oBarProgress:Update( ( nJogCorrente / nQuantJogos ) * 100 )

							// Declara a variavel para armazenar as Sequencias geradas
							aSequencia := Array( 2, nQuantDezenas )


							// Define a primeira sequencia
							nDezena := 1
							while nDezena <= nQuantDezenas

								nRandom := hb_RandInt( Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] ) )
								If AScan( aSequencia[1], { |xSeq| xSeq == pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ] } ) == 0
									aSequencia[1][ nDezena++ ] := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ]
								EndIf

							enddo

						
							// Define a segunda sequencia
							nDezena := 1
							while nDezena <= nQuantDezenas

								nRandom := hb_RandInt( Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] ) )
								If AScan( aSequencia[2], { |xSeq| xSeq == pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ] } ) == 0
									aSequencia[2][ nDezena++ ] := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ]
								EndIf

							enddo

							// Realiza a gravacao no arquivo temporario
							TMP->( NetAppend() )
							TMP->TMP_COD  := StrZero( nJogCorrente++, 7 )
							TMP->TMP_SEQ1 := ParseString( aSequencia[1] )
							TMP->TMP_SEQ2 := ParseString( aSequencia[2] )
							TMP->( dbUnlock() )

						enddo

					always
						// Remove a Barra de Progresso
						oBarProgress:Close()
					end sequence


					// Exibe as Apostas Geradas
					If TMP->( LastRec() ) > 0
						DSAShowAposta()
					Else
						ErrorTable( '105' )  // Nao existem informacoes a serem exibidas.
					EndIf

					// Fecha os Arquivos Temporarios
					TMP->( dbCloseArea() )

					// Elimina os arquivos temporarios.
					AEval( aFileTmp, { |xFile| FErase( xFile[1] ), FErase( xFile[2] ) } )

				EndIf

			Else
				ErrorTable( '105' )  // Problemas na criacao do arquivo temporario.
			EndIf

		always
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	EndIf

return


/***
*
*	DSAAnaliAleatoria()
*
*	Realiza a geracao das dezenas para a DUPLA SENA analisando a frequencia.
*
*   DSAMntBrowse -> DSAAcoes -> DSACombina -> DSAFrequencia
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
* nQuantDezenas : Informa o numero de dezenas a ser geradas por jogos
*   lOrdem      : Variavel logica informando verdadeiro para analisar os numeros de menor
*                 frequencia e false para os de maior frequencia
*
*/
STATIC PROCEDURE DSAFrequencia( nQuantJogos, nQuantDezenas, lOrdem )

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
			nQuantDezenas TO 6, ;
			lOrdem        TO pFALSE

	If Alert( 'Gerar as combinacoes analisando a Frequencia ?', {' Sim ', ' Nao ' } ) == 1

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			begin sequence with {| oErr | Break( oErr ) }

				AAdd( aFileTmp, { GetNextFile( SystemTmp() ), GetNextFile( SystemTmp() ) } )

				dbCreate( ATail( aFileTmp )[1], { 	{ 'TMP_COD',  'C',  7, 0 },  ;
													{ 'TMP_SEQ1', 'C', 44, 0 },  ;
													{ 'TMP_SEQ2', 'C', 44, 0 } } )

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

				If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pDUPLA_SENA } ) ) > 0

					begin sequence

						// Inicializa a Barra de Progresso
						oBarProgress := ProgressBar():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
						oBarProgress:Open()

						while nJogCorrente <= nQuantJogos


							// Atualiza a barra de Progresso
							oBarProgress:Update( ( nJogCorrente / nQuantJogos ) * 100 )


							// Declara a variavel para armazenar as Sequencias geradas
							aSequencia := Array( 2, nQuantDezenas )


							// Define a primeira sequencia
							nDezena := 1
							while nDezena <= nQuantDezenas

								nRandom := hb_RandInt( Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] ) )
								If AScan( aSequencia[1], { |xSeq| xSeq == pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ] } ) == 0
									aSequencia[1][ nDezena++ ] := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ]
								EndIf

							enddo

						
							// Define a segunda sequencia
							nDezena := 1
							while nDezena <= nQuantDezenas

								nRandom := hb_RandInt( Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] ) )
								If AScan( aSequencia[2], { |xSeq| xSeq == pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ] } ) == 0
									aSequencia[2][ nDezena++ ] := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nRandom ]
								EndIf

							enddo

							// Realiza a gravacao no arquivo temporario
							TMP->( NetAppend() )
							TMP->TMP_COD  := StrZero( nJogCorrente++, 7 )
							TMP->TMP_SEQ1 := ParseString( aSequencia[1] )
							TMP->TMP_SEQ2 := ParseString( aSequencia[2] )
							TMP->( dbUnlock() )

						ENDDO

					always
						// Remove a Barra de Progresso
						oBarProgress:Close()
					end sequence


					// Exibe as Apostas Geradas
					If TMP->( LastRec() ) > 0
						DSAShowAposta()
					Else
						ErrorTable( '105' )  // Nao existem informacoes a serem exibidas.
					EndIf

					// Fecha os Arquivos Temporarios
					TMP->( dbCloseArea() )

					// Elimina os arquivos temporarios.
					AEval( aFileTmp, { |xFile| FErase( xFile[1] ), FErase( xFile[2] ) } )

				EndIf

			Else
				ErrorTable( '105' )  // Problemas na criacao do arquivo temporario.
			EndIf

		always
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	EndIf

return


/***
*
*	DSAShowAposta()
*
*	Exibe as apostas gerados no arquivo Temporario.
*
*   DSAMntBrowse -> DSAAcoes -> DSACombina -> DSAAnaliAleatoria -> DSAShowAposta
*
*/
STATIC PROCEDURE DSAShowAposta

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
			FOR nLinDezenas := 1 TO nGrade
				FOR nColDezenas := 1 TO 10
					IF nPosDezenas <= Len( pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )
						aDezenas[ nLinDezenas ][ nColDezenas ] := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ][ nPosDezenas ]
					ELSE
						aDezenas[ nLinDezenas ][ nColDezenas ] := '  '
					ENDIF
					nPosDezenas++
				NEXT
			NEXT


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
*	DSARelResult()
*
*	Realiza a impressao dos resultados da DUPLA SENA.
*
*   DSAMntBrowse -> DSAAcoes -> DSACombina -> DSARelResult
*
*/
STATIC PROCEDURE DSARelResult

local lContinua    := pTRUE
local lPushButton
local oWindow

local cInicio
local cFinal
local nCurrent
local nTotConcurso := 0
local bFiltro      := { || CONCURSO->CON_JOGO == pDUPLA_SENA .and. CONCURSO->( .not. Eof() ) }
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
					IF CONCURSO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + cInicio ) ) .and. ;
						CONCURSO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + cFinal ) )

						bFiltro := { || CONCURSO->CON_JOGO == pDUPLA_SENA .and. CONCURSO->( .not. Eof() ) .and. ;
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
							//oPDFReport:cCodePage   := hb_CdpOS()
							oPDFReport:SetInfo( 'EDILSON MENDES', 'ODIN', 'RESULTADOS DUPLA SENA', oPDFReport:cFileName )

							nLinha := oPDFReport:MaxCol()

							//Posiciiona o Registro
							If CONCURSO->( dbSetOrder(1), dbSeek( pDUPLA_SENA + cInicio ) )

								while Eval( bFiltro )

									// Atualiza a barra de Progresso
									oBarProgress:Update( ( nCurrent++ / nTotConcurso ) * 100 )

									If nLinha >= ( oPDFReport:MaxCol() - 35 )
										oPDFReport:AddPage()
										oPDFReport:DrawRetangle( 0,  0, 22, 2 )
										oPDFReport:DrawRetangle( 0, 25, 49, 2 )
										oPDFReport:DrawRetangle( 0, 77, 22, 2 )
										oPDFReport:DrawText( 1, 26, PadC( 'RESULTADOS DUPLA SENA', 70 ), , 10, 'Helvetica-Bold' )
										oPDFReport:DrawText( 1, 79, 'Pagina: ' + Str( oPDFReport:nPageNumber ) , , 10, 'Helvetica-Bold' )
										oPDFReport:nPageNumber++
										oPDFReport:nPdfPage++
										oPDFReport:DrawLine( 2, 0, 2, oPDFReport:MaxCol(), 1 )
										oPDFReport:DrawText( 3, 3, 'CONCURSO                 DATA                           FAIXA       DEZENAS', , 10, 'Helvetica-Bold' )
										oPDFReport:DrawLine( 3.5, 0, 3.5, oPDFReport:MaxCol(), 1 )
										nLinha := 4.5
									EndIf

									oPDFReport:DrawText( nLinha,  3, Transform( CONCURSO->CON_CONCUR, '@!' ), , 10, 'Helvetica' )
									oPDFReport:DrawText( nLinha, 22, Transform( CONCURSO->CON_SORTEI, '@D 99/99/99' ), , 10, 'Helvetica' )

									If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )

										while CONCURSO->CON_JOGO == JOGOS->JOG_JOGO .and. ;
											CONCURSO->CON_CONCUR == JOGOS->JOG_CONCUR .and. .not. ;
											JOGOS->( Eof() )

											oPDFReport:DrawText( nLinha,   41, Transform( JOGOS->JOG_FAIXA, '@!' ), , 10, 'Helvetica' )
											oPDFReport:DrawText( nLinha++, 50, Transform( StrDezenas( JOGOS->JOG_DEZENA ), '@!' ), , 10, 'Helvetica' )

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

						lContinua := pFALSE

					EndIf

				endif

			enddo

		else
			ErrorTable( '107' )  // Nao existem informacoes a serem impressas.
		endif

	always
		// Fecha o Objeto Windows
		oWindow:Close()
		// Restaura a tabela da Pilha
		DstkPop()
	end sequence

return



/***
*
*	LMGeraCombina( <cAposta>, <dSorteio>, <nValor>, <aDezenas>, <nQuantDezenas> )
*
*	Funcao para realizar a combinacoes.
*
*   <cAposta>       -> Codido da Aposta gerada
*   <dSorteio>      -> Data do sorteio da Aposta gerada
*   <nValor>        -> Valor da Aposta gerada.
*   <aDezenas>      -> Array contendo as dezenas a serem processadas
*   <nQuantDezenas> -> Quantidade de sequencia a ser gerada
*   <aCombine>      -> Dicionario interno para as dezenas processadas
*   <nElement>      -> Posicao do dicionario processado.
*
*/
STATIC PROCEDURE LMGeraCombina( cAposta, dSorteio, nValor, aDezenas, nQuantDezenas, aCombine, nElement )

LOCAL nPos
LOCAL nCurCodigo
LOCAL nPosCombine
LOCAL aValue      := {}
LOCAL lFound


	DEFAULT aCombine TO {}
	DEFAULT nElement TO 1
	
	IF Len( aCombine ) == 0
		aCombine    := ARRAY( nQuantDezenas, 0 )
		nPosCombine := nElement
	ELSE
		nPosCombine := nElement + 1
	ENDIF
	
	WHILE pTRUE
		
		IF nPosCombine <= nQuantDezenas
			
			FOR nPos := 1 TO Len( aDezenas )
				SCROLL( MAXROW()- 10, 1, MAXROW()- 1, 5, 1 )
				SETPOS( MAXROW()- 1, 1 )
				DEVOUT( STRZERO( nPosCombine, 2 ) + '-' + aDezenas[ nPos ] )
				lFound := pFALSE
				AEVAL( aCombine, { |xItem| IIF( ASCAN( xItem, aDezenas[ nPos ] ) > 0, lFound := pTRUE, Nil ) }, 1, nPosCombine )
				IF .NOT. lFound
					AADD( aCombine[ nPosCombine ], aDezenas[ nPos ] )
					IF nPosCombine <= nQuantDezenas
						LMGeraCombina( cAposta, dSorteio, nValor, aDezenas, nQuantDezenas, aCombine, nPosCombine )
					ENDIF
				ENDIF
			NEXT
			
			// Elimina Itens do vetor
			FOR nPos := Len( aCombine[ nPosCombine ] ) TO 1 STEP -1
				ADEL( aCombine[ nPosCombine ], nPos )
				ASIZE( aCombine[ nPosCombine ], Len( aCombine[ nPosCombine ] ) -1 )
			NEXT
			EXIT
			
		ELSE
			// Forma a sequencia das combinacoes
			AEVAL( aCombine, { |xItem| AADD( aValue, ATAIL( xItem ) ) } )
			
			// Gera o numero da aposta a ser gravada no arquivo temporario
			nCurCodigo := 1
			WHILE TMP->( DBSeek( STRZERO( nCurCodigo, 7 ) ) )
				nCurCodigo++
			ENDDO
			
			BEGIN SEQUENCE
			
				TMP->( NetAppend() )
				TMP->TMP_JOGO    := SystemConcurso()
				TMP->TMP_CODIGO  := STRZERO( nCurCodigo, 7 )
				TMP->TMP_APOSTA  := cAposta
				TMP->TMP_SORTEI  := dSorteio
				TMP->TMP_VALOR   := nValor
				TMP->TMP_DEZENA  := ParseString( aValue )
				TMP->( DBUnLock() )
				
			END SEQUENCE
			
			EXIT
		ENDIF
		
	ENDDO
			
RETURN
