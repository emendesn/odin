/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  lmania.prg
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
#include 'lmania.ch'
#include 'dbfunc.ch'
#include 'main.ch'

static aLotoMania

memvar GetList

/***
*
*	LTFMntBrowse()
*
*	Exibe a relacao de concursos ja realizados.
*
*/
PROCEDURE LTMMntBrowse()

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

local oBrwDezenas
local aSelDezenas   := {}
local aDezenas
local nRow          := 1
local nPointer
local nPosDezenas   := 1
local nLinDezenas
local nColDezenas
local nGrade


	If SystemConcurso() == pLOTO_MANIA

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_MANIA } ) ) > 0

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
				oWindow:nLeft   := Int( SystemMaxCol() / 2 ) - 25
				oWindow:nBottom := Int( SystemMaxRow() / 2 ) + 15
				oWindow:nRight  := Int( SystemMaxCol() / 2 ) + 25
				oWindow:cHeader := PadC( SystemNameConcurso(), Len( SystemNameConcurso() ) + 2, ' ')
				oWindow:Open()

				// Desenha a Linha de Botoes
				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				// Estabelece o Filtro para exibicao dos registros
				bFiltro := { || CONCURSO->CON_JOGO == pLOTO_MANIA .and. CONCURSO->( .not. Eof() ) }

				dbSelectArea('CONCURSO')
				CONCURSO->( dbEval( {|| nMaxItens++ }, bFiltro ) )
				CONCURSO->( dbSetOrder(2), dbSeek( pLOTO_MANIA ) )

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
                                                        k := iif( Abs(x) >= iif( x >= 0,                           ;
                                                                            Len( aDezenas ) - nRow, nRow - 1 ),    ;
                                                                iif(x >= 0, Len( aDezenas ) - nRow, 1 - nRow ), x );
                                                                , nRow += k, k                                     ;
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
					oTmpButton:sBlock    := { || LTMIncluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+12, ' &Modificar ' )
					oTmpButton:sBlock    := { || LTMModificar() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+24, ' &Excluir ' )
					oTmpButton:sBlock    := { || LTMExcluir() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AAdd( oBrowse:Cargo, { oTmpButton, Upper( SubStr( oTmpButton:Caption, At('&', oTmpButton:Caption )+ 1, 1 ) ) } )

					oTmpButton           := PushButton( oWindow:nBottom- 1, oWindow:nLeft+34, ' Ac&oes ' )
					oTmpButton:sBlock    := { || LTMAcoes() }
					oTmpButton:Style     := ''
					oTmpButton:ColorSpec := SysPushButton()
					AADD( oBrowse:Cargo, { oTmpButton, UPPER( SUBSTR( oTmpButton:Caption, AT('&', oTmpButton:Caption )+ 1, 1 ) ) } )

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
								// oBrwDezenas:refreshCurrent()
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
*	LTMIncluir()
*
*	Realiza a inclusao dos dados para o concurso da LOTO MANIA.
*
*   LTMMntBrowse -> LTMIncluir
*
*/
STATIC PROCEDURE LTMIncluir

local nPointer
local lContinua     := pTRUE
local lPushButton
local oWindow
local nCodigo       := 1
local cAutoSequence
local oIniFile

memvar xCount, xTemp


	If SystemConcurso() == pLOTO_MANIA

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_MANIA } ) ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Inicializa as Variaveis de Dados
				xInitLotoMania

				// Inicializa as Variaveis de no vetor aLotoMania
				xStoreLotoMania

				//
				// Realiza a abertura do arquivo INI
				//
				oIniFile := TIniFile():New( 'odin.ini' )

				//
				// Parametro para definir a sequencia automatica
				//
				If ( cAutoSequence := oIniFile:ReadString( 'LOTOMANIA', 'AUTO_SEQUENCE', '0' ) ) == '1'
					// Define o codigo sequencial
					dbEval( { || nCodigo++ }, { || CONCURSO->CON_JOGO == pLOTO_MANIA .and. CONCURSO->( .not. Eof() ) } )
					pLTM_CONCURSO := StrZero( nCodigo, 5 )
				EndIf


				// Cria o Objeto Windows
				oWindow        := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := INT( SystemMaxRow() / 2 ) - 10
				oWindow:nLeft   := INT( SystemMaxCol() / 2 ) - 21
				oWindow:nBottom := INT( SystemMaxRow() / 2 ) + 10
				oWindow:nRight  := INT( SystemMaxCol() / 2 ) + 21
				oWindow:Open()

				while lContinua

					@ oWindow:nTop+ 1, oWindow:nLeft+14 GET     pLTM_CONCURSO                                  ;
														PICT    '@K 99999'                                     ;
														SEND    VarPut(StrZero(Val(ATail(GetList):VarGet()),5));
														CAPTION 'Concurso'                                     ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 1, oWindow:nLeft+30 GET     pLTM_SORTEIO                                   ;
														PICT    '@KD 99/99/99'                                 ;
														CAPTION 'Sorteio'                                      ;
														COLOR   SysFieldGet()

					hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 2, oWindow:nLeft+ 2, ' Dezenas ', SystemLabelColor() )

					@ oWindow:nTop+ 3, oWindow:nLeft+12 GET   pLTM_DEZENA_01                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+16 GET   pLTM_DEZENA_02                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+20 GET   pLTM_DEZENA_03                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+24 GET   pLTM_DEZENA_04                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+28 GET   pLTM_DEZENA_05                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+12 GET   pLTM_DEZENA_06                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+16 GET   pLTM_DEZENA_07                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+20 GET   pLTM_DEZENA_08                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+24 GET   pLTM_DEZENA_09                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+28 GET   pLTM_DEZENA_10                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+12 GET   pLTM_DEZENA_11                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+16 GET   pLTM_DEZENA_12                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+20 GET   pLTM_DEZENA_13                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+24 GET   pLTM_DEZENA_14                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+28 GET   pLTM_DEZENA_15                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+12 GET   pLTM_DEZENA_16                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+16 GET   pLTM_DEZENA_17                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+20 GET   pLTM_DEZENA_18                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+24 GET   pLTM_DEZENA_19                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+28 GET   pLTM_DEZENA_20                                   ;
														PICT  '@K 99'                                          ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														COLOR SysFieldGet()

					hb_DispBox( oWindow:nTop+10, oWindow:nLeft+ 1, ;
								oWindow:nTop+10, oWindow:nRight -1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+10, oWindow:nLeft+ 2, ' Premio ', SystemLabelColor() )
					
					@ oWindow:nTop+11, oWindow:nLeft+12 SAY   'Ganhadores'                                     ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+11, oWindow:nLeft+30 SAY   'Premio'                                         ;
														COLOR SystemLabelColor()

					// Coluna de Acertos			
					@ oWindow:nTop+12, oWindow:nLeft+10 GET     pLTM_ACERTO_20                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '20 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '20', pLTM_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+10 GET     pLTM_ACERTO_19                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '19 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '19', pLTM_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+10 GET     pLTM_ACERTO_18                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '18 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '18', pLTM_SORTEIO )

					@ oWindow:nTop+15, oWindow:nLeft+10 GET     pLTM_ACERTO_17                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '17 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '17', pLTM_SORTEIO )

					@ oWindow:nTop+16, oWindow:nLeft+10 GET     pLTM_ACERTO_16                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '16 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '16', pLTM_SORTEIO )

					@ oWindow:nTop+17, oWindow:nLeft+10 GET     pLTM_ACERTO_15                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '15 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '15', pLTM_SORTEIO )

					@ oWindow:nTop+18, oWindow:nLeft+10 GET     pLTM_ACERTO_00                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '00 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '00', pLTM_SORTEIO )

					// Coluna de Premios			
					@ oWindow:nTop+12, oWindow:nLeft+24 GET   pLTM_PREMIO_20                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '20', pLTM_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+24 GET   pLTM_PREMIO_19                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '19', pLTM_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+24 GET   pLTM_PREMIO_18                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '18', pLTM_SORTEIO )

					@ oWindow:nTop+15, oWindow:nLeft+24 GET   pLTM_PREMIO_17                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '17', pLTM_SORTEIO )

					@ oWindow:nTop+16, oWindow:nLeft+24 GET   pLTM_PREMIO_16                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '16', pLTM_SORTEIO )

					@ oWindow:nTop+17, oWindow:nLeft+24 GET   pLTM_PREMIO_15                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '15', pLTM_SORTEIO )

					@ oWindow:nTop+18, oWindow:nLeft+24 GET   pLTM_PREMIO_00                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '00', pLTM_SORTEIO )

					hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
								oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

					@ oWindow:nBottom- 1, oWindow:nRight-22 GET     lPushButton PUSHBUTTON                     ;
															CAPTION ' Con&firma '                              ;
															COLOR   SysPushButton()                            ;
															STYLE   ''                                         ;
															WHEN    Val( pLTM_CONCURSO ) > 0 .and.             ;
																	.not. Empty( pLTM_SORTEIO ) .and.          ;
																	.not. Empty( pLTM_DEZENA_01 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_02 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_03 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_04 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_05 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_06 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_07 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_08 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_09 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_10 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_11 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_12 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_13 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_14 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_15 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_16 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_17 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_18 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_19 ) .and.        ;
																	.not. Empty( pLTM_DEZENA_20 )              ;
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

						pLTM_CONCURSO := StrZero( Val( pLTM_CONCURSO ), 5 )

						//************************************************************************
						//*Verifica se concurso ja existe                                        *
						//************************************************************************
						If .not. CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO ) )

							//************************************************************************
							//*Verifica a duplicidade de dezenas no concurso                         *
							//************************************************************************
							If xDuplicSequencia( aLotoMania[ pLTM_POS_DADOS ][ pLTM_POS_DEZENAS ] )

								//************************************************************************
								//*Verifica cada item da primeira sequencia para identificar se o valor  *
								//*digitado esta dentro da faixa especifica do concurso                  *
								//************************************************************************
								If xVerificaSequencia( 	aLotoMania[ pLTM_POS_DADOS ][ pLTM_POS_DEZENAS ], ;
														pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )

									If LTMGravaDados()
										lContinua := pFALSE
									EndIf

								Else
									ErrorTable( '303' )  // Dezena digitada encontra-se fora da faixa.
								EndIf

							Else
								ErrorTable( '301' )  // A sequencia encontra em duplicidade.
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
				oIniFile:WriteString( 'LOTOMANIA', 'AUTO_SEQUENCE', cAutoSequence )

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
*	LTMModificar()
*
*	Realiza a manutencao dos dados para o concurso da LOTO MANIA.
*
*   LTMMntBrowse -> LTMModificar
*
*/
STATIC PROCEDURE LTMModificar

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
	If CONCURSO->CON_JOGO == pLOTO_MANIA

		If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_MANIA } ) ) > 0

			begin sequence

				// Salva a Area corrente na Pilha
				DstkPush()

				// Inicializa o vetor aLotoMania
				xInitLotoMania

				// Inicializa as Variaveis de no vetor aLotoMania
				xStoreLotoMania

				//
				// Atualiza a variaveis com o registro selecionado
				//
				pLTM_CONCURSO := CONCURSO->CON_CONCUR
				pLTM_SORTEIO  := CONCURSO->CON_SORTEI


				//
				// Atualiza as dezenas do concurso selecionado
				//
				nPos   := 0
				nCount := 1
				If JOGOS->( dbSetOrder(1), dbSeek( CONCURSO->CON_JOGO + CONCURSO->CON_CONCUR ) )
					while nPos++ <= Len( AllTrim( JOGOS->JOG_DEZENA ) )
						If IsDigit( SubStr( AllTrim( JOGOS->JOG_DEZENA ), nPos, 1 ) )
							aLotoMania[ pLTM_POS_DADOS ][ pLTM_POS_DEZENAS ][ nCount++ ] := SubStr( AllTrim( JOGOS->JOG_DEZENA ), nPos++, 2 )
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
							case RATEIO->RAT_FAIXA == '00'
								pLTM_ACERTO_00 := RATEIO->RAT_ACERTA
								pLTM_PREMIO_00 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '15'
								pLTM_ACERTO_15 := RATEIO->RAT_ACERTA
								pLTM_PREMIO_15 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '16'
								pLTM_ACERTO_16 := RATEIO->RAT_ACERTA
								pLTM_PREMIO_16 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '17'
								pLTM_ACERTO_17 := RATEIO->RAT_ACERTA
								pLTM_PREMIO_17 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '18'
								pLTM_ACERTO_18 := RATEIO->RAT_ACERTA
								pLTM_PREMIO_18 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '19'
								pLTM_ACERTO_19 := RATEIO->RAT_ACERTA
								pLTM_PREMIO_19 := RATEIO->RAT_RATEIO
							case RATEIO->RAT_FAIXA == '20'
								pLTM_ACERTO_20 := RATEIO->RAT_ACERTA
								pLTM_PREMIO_20 := RATEIO->RAT_RATEIO			
						endcase
						RATEIO->( dbSkip() )
					enddo
				EndIf

				// Cria o Objeto Windows
				oWindow         := WindowsNew():New( ,,,, B_SINGLE + ' ', SystemFormColor() )
				oWindow:nTop    := INT( SystemMaxRow() / 2 ) - 10
				oWindow:nLeft   := INT( SystemMaxCol() / 2 ) - 21
				oWindow:nBottom := INT( SystemMaxRow() / 2 ) + 10
				oWindow:nRight  := INT( SystemMaxCol() / 2 ) + 21
				oWindow:Open()


				while lContinua

					@ oWindow:nTop+ 1, oWindow:nLeft+14 GET     pLTM_CONCURSO                                  ;
														PICT    '@!'                                           ;
														CAPTION 'Concurso'                                     ;
														WHEN    pFALSE                                         ;
														COLOR   SysFieldGet()

					@ oWindow:nTop+ 1, oWindow:nLeft+30 GET     pLTM_SORTEIO                                   ;
														VALID   .not. Empty( pLTM_SORTEIO )                    ;
														PICT    '@KD 99/99/99'                                 ;
														CAPTION 'Sorteio'                                      ;
														COLOR   SysFieldGet()


					hb_DispBox( oWindow:nTop+ 2, oWindow:nLeft+ 1, ;
								oWindow:nTop+ 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+ 2, oWindow:nLeft+ 2, ' Dezenas ', SystemLabelColor() )

					@ oWindow:nTop+ 3, oWindow:nLeft+12 GET   pLTM_DEZENA_01                                   ;
														VALID .not. Empty( pLTM_DEZENA_01 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+16 GET   pLTM_DEZENA_02                                   ;
														VALID .not. Empty( pLTM_DEZENA_02 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+20 GET   pLTM_DEZENA_03                                   ;
														VALID .not. Empty( pLTM_DEZENA_03 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+24 GET   pLTM_DEZENA_04                                   ;
														VALID .not. Empty( pLTM_DEZENA_04 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 3, oWindow:nLeft+28 GET   pLTM_DEZENA_05                                   ;
														VALID .not. Empty( pLTM_DEZENA_05 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+12 GET   pLTM_DEZENA_06                                   ;
														VALID .not. Empty( pLTM_DEZENA_06 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+16 GET   pLTM_DEZENA_07                                   ;
														VALID .not. Empty( pLTM_DEZENA_07 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+20 GET   pLTM_DEZENA_08                                   ;
														VALID .not. Empty( pLTM_DEZENA_08 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+24 GET   pLTM_DEZENA_09                                   ;
														VALID .not. Empty( pLTM_DEZENA_09 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 5, oWindow:nLeft+28 GET   pLTM_DEZENA_10                                   ;
														VALID .not. Empty( pLTM_DEZENA_10 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+12 GET   pLTM_DEZENA_11                                   ;
														VALID .not. Empty( pLTM_DEZENA_11 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+16 GET   pLTM_DEZENA_12                                   ;
														VALID .not. Empty( pLTM_DEZENA_12 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+20 GET   pLTM_DEZENA_13                                   ;
														VALID .not. Empty( pLTM_DEZENA_13 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+24 GET   pLTM_DEZENA_14                                   ;
														VALID .not. Empty( pLTM_DEZENA_14 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 7, oWindow:nLeft+28 GET   pLTM_DEZENA_15                                   ;
														VALID .not. Empty( pLTM_DEZENA_15 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+12 GET   pLTM_DEZENA_16                                   ;
														VALID .not. Empty( pLTM_DEZENA_16 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+16 GET   pLTM_DEZENA_17                                   ;
														VALID .not. Empty( pLTM_DEZENA_17 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+20 GET   pLTM_DEZENA_18                                   ;
														VALID .not. Empty( pLTM_DEZENA_18 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+24 GET   pLTM_DEZENA_19                                   ;
														VALID .not. Empty( pLTM_DEZENA_19 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					@ oWindow:nTop+ 9, oWindow:nLeft+28 GET   pLTM_DEZENA_20                                   ;
														VALID .not. Empty( pLTM_DEZENA_20 )                    ;
														SEND  VarPut(StrZero(Val(ATail(GetList):VarGet()),2))  ;
														PICT  '@K 99'                                          ;
														COLOR SysFieldGet()

					hb_DispBox( oWindow:nTop+10, oWindow:nLeft+ 1, ;
								oWindow:nTop+10, oWindow:nRight -1, oWindow:cBorder, SystemFormColor() )
					hb_DispOutAt( oWindow:nTop+10, oWindow:nLeft+ 2, ' Premio ', SystemLabelColor() )

					@ oWindow:nTop+11, oWindow:nLeft+12 SAY   'Ganhadores'                                     ;
														COLOR SystemLabelColor()

					@ oWindow:nTop+11, oWindow:nLeft+30 SAY   'Premio'                                         ;
														COLOR SystemLabelColor()

					// Coluna de Acertos				
					@ oWindow:nTop+12, oWindow:nLeft+10 GET     pLTM_ACERTO_20                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '20 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '20', pLTM_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+10 GET     pLTM_ACERTO_19                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '19 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '19', pLTM_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+10 GET     pLTM_ACERTO_18                                 ;                
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '18 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '18', pLTM_SORTEIO )

					@ oWindow:nTop+15, oWindow:nLeft+10 GET     pLTM_ACERTO_17                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '17 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '17', pLTM_SORTEIO )

					@ oWindow:nTop+16, oWindow:nLeft+10 GET     pLTM_ACERTO_16                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '16 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '16', pLTM_SORTEIO )

					@ oWindow:nTop+17, oWindow:nLeft+10 GET     pLTM_ACERTO_15                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '15 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '15', pLTM_SORTEIO )

					@ oWindow:nTop+18, oWindow:nLeft+10 GET     pLTM_ACERTO_00                                 ;
														PICT    '@EN 9,999,999,999'                            ;
														CAPTION '00 Acer.'                                     ;
														COLOR   SysFieldGet()                                  ;
														WHEN    AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '00', pLTM_SORTEIO )

					// Coluna de Premios				
					@ oWindow:nTop+12, oWindow:nLeft+24 GET   pLTM_PREMIO_20                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '20', pLTM_SORTEIO )

					@ oWindow:nTop+13, oWindow:nLeft+24 GET   pLTM_PREMIO_19                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '19', pLTM_SORTEIO )

					@ oWindow:nTop+14, oWindow:nLeft+24 GET   pLTM_PREMIO_18                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '18', pLTM_SORTEIO )

					@ oWindow:nTop+15, oWindow:nLeft+24 GET   pLTM_PREMIO_17                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '17', pLTM_SORTEIO )

					@ oWindow:nTop+16, oWindow:nLeft+24 GET   pLTM_PREMIO_16                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '16', pLTM_SORTEIO )

					@ oWindow:nTop+17, oWindow:nLeft+24 GET   pLTM_PREMIO_15                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '15', pLTM_SORTEIO )

					@ oWindow:nTop+18, oWindow:nLeft+24 GET   pLTM_PREMIO_00                                   ;
														PICT  '@EN 99,999,999,999.99'                          ;
														COLOR SysFieldGet()                                    ;
														WHEN  AvalCondRateio( pSTRU_SYSTEM[ nPointer ][ pSTRU_REGRA_PREMIACAO ], '00', pLTM_SORTEIO )


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
						If xDuplicSequencia( aLotoMania[ pLTM_POS_DADOS ][ pLTM_POS_DEZENAS ] )

							//************************************************************************
							//*Verifica cada item da primeira sequencia para identificar se o valor  *
							//*digitado esta dentro da faixa especifica do concurso                  *
							//************************************************************************
							If xVerificaSequencia( 	aLotoMania[ pLTM_POS_DADOS ][ pLTM_POS_DEZENAS ], ;
													pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ] )

								If LTMGravaDados()
									lContinua := pFALSE
								EndIf

							Else
								ErrorTable( '303' )  // Dezena digitada encontra-se fora da faixa.
							EndIf

						Else
							ErrorTable( '301' )  // A sequencia encontra em duplicidade.
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
*	LTMExcluir()
*
*	Realiza a exclusao do concurso da LOTO MANIA.
*
*   LTMMntBrowse -> LTMExcluir
*
*/
STATIC PROCEDURE LTMExcluir

	If CONCURSO->CON_JOGO == pLOTO_MANIA

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
*	LTMGravaDados()
*
*	Realiza a gravacao dos dados da LOTO MANIA.
*
*/
STATIC FUNCTION LTMGravaDados

local lRetValue := pFALSE


	begin sequence

		while .not. lRetValue			

			If iif( CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO ) ), CONCURSO->( NetRLock() ), CONCURSO->( NetAppend() ) )
				CONCURSO->CON_JOGO   := pLOTO_MANIA
				CONCURSO->CON_CONCUR := pLTM_CONCURSO
				CONCURSO->CON_SORTEI := pLTM_SORTEIO
				CONCURSO->( dbUnlock() )
			EndIf

			If iif( JOGOS->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO ) ), JOGOS->( NetRLock() ), JOGOS->( NetAppend() ) )
				JOGOS->JOG_JOGO   := pLOTO_MANIA
				JOGOS->JOG_CONCUR := pLTM_CONCURSO
				JOGOS->JOG_DEZENA := ParseString( aLotoMania[ pLTM_POS_DADOS ][ pLTM_POS_DEZENAS ] )
				JOGOS->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO + '00' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_MANIA
				RATEIO->RAT_CONCUR := pLTM_CONCURSO
				RATEIO->RAT_FAIXA  := '00'
				RATEIO->RAT_ACERTA := pLTM_ACERTO_00
				RATEIO->RAT_RATEIO := pLTM_PREMIO_00
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO + '15' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_MANIA
				RATEIO->RAT_CONCUR := pLTM_CONCURSO
				RATEIO->RAT_FAIXA  := '15'
				RATEIO->RAT_ACERTA := pLTM_ACERTO_15
				RATEIO->RAT_RATEIO := pLTM_PREMIO_15
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO + '16' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_MANIA
				RATEIO->RAT_CONCUR := pLTM_CONCURSO
				RATEIO->RAT_FAIXA  := '16'
				RATEIO->RAT_ACERTA := pLTM_ACERTO_16
				RATEIO->RAT_RATEIO := pLTM_PREMIO_16
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO + '17' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_MANIA
				RATEIO->RAT_CONCUR := pLTM_CONCURSO
				RATEIO->RAT_FAIXA  := '17'
				RATEIO->RAT_ACERTA := pLTM_ACERTO_17
				RATEIO->RAT_RATEIO := pLTM_PREMIO_17
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO + '18' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_MANIA
				RATEIO->RAT_CONCUR := pLTM_CONCURSO
				RATEIO->RAT_FAIXA  := '18'
				RATEIO->RAT_ACERTA := pLTM_ACERTO_18
				RATEIO->RAT_RATEIO := pLTM_PREMIO_18
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO + '19' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_MANIA
				RATEIO->RAT_CONCUR := pLTM_CONCURSO
				RATEIO->RAT_FAIXA  := '19'
				RATEIO->RAT_ACERTA := pLTM_ACERTO_19
				RATEIO->RAT_RATEIO := pLTM_PREMIO_19
				RATEIO->( dbUnlock() )
			EndIf

			If iif( RATEIO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + pLTM_CONCURSO + '20' ) ), RATEIO->( NetRLock() ), RATEIO->( NetAppend() ) )
				RATEIO->RAT_JOGO   := pLOTO_MANIA
				RATEIO->RAT_CONCUR := pLTM_CONCURSO
				RATEIO->RAT_FAIXA  := '20'
				RATEIO->RAT_ACERTA := pLTM_ACERTO_20
				RATEIO->RAT_RATEIO := pLTM_PREMIO_20
				RATEIO->( dbUnlock() )
			EndIf

			lRetValue := pTRUE

		enddo

	end sequence

return( lRetValue )


/***
*
*	LTMAcoes()
*
*	Exibe o menu de acoes relacionadas.
*
*   LTMMntBrowse -> LTMAcoes
*
*/
STATIC PROCEDURE LTMAcoes

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
						LTMCombina()

					case nTipAcoes == 2
						LTMRelResult()

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
*	LTMCombina()
*
*	Exibe as opcoes para gerar combinacoes.
*
*   LTMMntBrowse -> LTMAcoes -> LTMCombina
*
*/
STATIC PROCEDURE LTMCombina

local oWindow
local lPushButton
local lContinua   := pTRUE

local aGroup      := Array(4)
local nOpcao      := 1
local nQuantJog   := 1
local nQuantDez   := pLTM_DEF_MIN_DEZENAS
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
															nQuantJog <= pLTM_DEF_MAX_COMB .and.    ;
															nQuantDez >= pLTM_DEF_MIN_DEZENAS .and. ;
															nQuantDez <= pLTM_DEF_MAX_DEZENAS .and. ;
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
						LTMAnaliAleatoria( nQuantJog, nQuantDez )
					
					case nOpcao == 2
						// LTMRelResult()

					case nOpcao == 3
						// LTMRelResult()

					case nOpcao == 4
						LTMGeraGrupos( nQuantJog, nQuantDez, nQuantGrp )

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
*	LTMAnaliAleatoria()
*
*	Realiza a geracao das dezenas para a LOTO MANIA aleatoriamente.
*
*   LTMMntBrowse -> LTMAcoes -> LTMCombina -> LTMAnaliAleatoria
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
* nQuantDezenas : Informa o numero de dezenas a ser geradas por jogos
*
*/
STATIC PROCEDURE LTMAnaliAleatoria( nQuantJogos, nQuantDezenas )

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
			nQuantDezenas TO pLTM_DEF_MIN_DEZENAS

	If Alert( 'Gerar as combinacoes Aleatorias ?', {' Sim ', ' Nao ' } ) == 1

		begin sequence

			// Salva a Area corrente na Pilha
			DstkPush()

			begin sequence with { |oErr| Break( oErr ) }

				AAdd( aFileTmp, { GetNextFile( SystemTmp() ), GetNextFile( SystemTmp() ) } )

				dbCreate( ATail( aFileTmp )[1], { 	{ 'TMP_COD', 'C',  7, 0 },  ;
													{ 'TMP_SEQ', 'C', 53, 0 },  ;
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

				If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_MANIA } ) ) > 0

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
						LTMShowAposta()
					Else
						ErrorTable( '306' )  // Nao existem informacoes a serem exibidas.
					EndIf

					// Fecha os Arquivos Temporarios
					TMP->( dbCloseArea() )

					// Elimina os arquivos temporarios.
					AEval( aFileTmp, { |xFile| FErase( xFile[1] ), FErase( xFile[2] ) } )

				EndIf

			Else
				ErrorTable( '305' )  // Problemas na criacao do arquivo temporario.
			EndIf

		always
			// Restaura a tabela da Pilha
			DstkPop()
		end sequence

	EndIf

return


/***
*
*	LTMGeraGrupos()
*
*	Realiza a geracao das dezenas para a LOTO MANIA aleatoriamente.
*
*   LTMMntBrowse -> LTMAcoes -> LTMCombina -> LTMGeraGrupos
*
*   nQuantJogos : Informa a quantidade de jogos a ser geradas
* nQuantDezenas : Informa o numero de dezenas a ser geradas por jogos
*  nQuantGrupos : Informa o numero de grupos gerados por combinacoes
*
*/
STATIC PROCEDURE LTMGeraGrupos( nQuantJogos, nQuantDezenas, nQuantGrupos )

local nPointer
local lContinua    := pTRUE
local lConfirma
local lCancela
local oWindow

local oBrwFiles, oColumn
local cDisplayFile := ""
local nRow         := 1
	
local aTemp
local oCombine
local a, i
local nPercComb

	DEFAULT nQuantJogos   TO  1, ;
			nQuantDezenas TO 15, ;
			nQuantGrupos  TO  1

	If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == pLOTO_MANIA } ) ) > 0

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

			// nPercComb := hb_idleAdd( {||  hb_DispOutAt( oWindow:nTop+ 2, oWindow:nLeft+ 1,    ;
			// hb_ValToStr( oCombine:Percent() ) ) } )			

			// Executa a rotina para gerar as combinacoes
			oCombine           		 := hbCombina():New()
			oCombine:aSequencia 	 := pSTRU_SYSTEM[ nPointer ][ pSTRU_DEZENAS ]
			oCombine:nQuantSequencia := nQuantDezenas
			oCombine:Execute()

			/* altd()
			oCombine           := TLFCombine():New( Nil, aTemp, 3, 2 )
			oCombine:cFileName := GetNextFile( SystemTmp() )
			oCombine:Execute() */

			oBrwFiles               := 	TBrowseNew( oWindow:nTop+ 3, oWindow:nLeft+ 1, ;
													oWindow:nBottom- 3, oWindow:nRight- 1 )
			oBrwFiles:skipBlock     := 	{ |x,k| ;
											k := iif( Abs(x) >= iif( x >= 0,                                 ;
																Len( oBrwFiles:Cargo ) - nRow, nRow - 1),    ;
													iif(x >= 0, Len( oBrwFiles:Cargo ) - nRow,1 - nRow), x ) ;
													, nRow += k, k                                           ;
										}
			oBrwFiles:goTopBlock    := 	{ || nRow := 1 }
			oBrwFiles:goBottomBlock := 	{ || nRow := Len( oBrwFiles:Cargo ) }
			oBrwFiles:colorSpec     := SysBrowseColor()
			oBrwFiles:autoLite      := pFALSE
			oBrwFiles:Cargo         := { { 'TESTE1.TST' }, ;
										 { 'TESTE2.TST' }, ;
										 { 'TESTE3.TST' }  }

			oColumn            := TBColumnNew( "", { || oBrwFiles:Cargo[ nRow ][1] } )
			oColumn:width      := 10
			oBrwFiles:addColumn( oColumn )

			oBrwFiles:forceStable()

			WHILE lContinua

				@ oWindow:nTop+ 3, oWindow:nLeft+ 1, ;
					oWindow:nBottom- 3, oWindow:nRight- 1 	GET     cDisplayFile                           ;
															TBROWSE oBrwFiles                              ;
															WHEN    pFALSE

				hb_DispBox( oWindow:nBottom- 2, oWindow:nLeft+ 1, ;
							oWindow:nBottom- 2, oWindow:nRight- 1, oWindow:cBorder, SystemFormColor() )

				@ oWindow:nBottom- 1, oWindow:nRight-22	GET     lConfirma PUSHBUTTON                       ;
														CAPTION ' Con&firma '                              ;
														COLOR   SysPushButton()                            ;
														STYLE   ''                                         ;
														STATE   { || lContinua := pTRUE, GetActive():ExitState := GE_WRITE }

				@ oWindow:nBottom- 1, oWindow:nRight-11	GET     lCancela  PUSHBUTTON                       ;
														CAPTION ' Cance&lar '                              ;
														COLOR   SysPushButton()                            ;
														STYLE   ''                                         ;
														STATE   { || lContinua := pFALSE, GetActive():ExitState := GE_ESCAPE }

				Set( _SET_CURSOR, SC_NORMAL )

				READ

				Set( _SET_CURSOR, SC_NONE )

				hb_idleDel( nPercComb )

				lContinua := pFALSE

			enddo

		always

			// Elimina o Objeto
			oCombine:End()

			// Fecha o Objeto Windows
			oWindow:Close()

			// Restaura a tabela da Pilha
			DstkPop()

		end sequence

	EndIf

return


/***
*
*	LTMShowAposta()
*
*	Exibe as apostas gerados no arquivo Temporario.
*
*   LTMMntBrowse -> LTMAcoes -> LTMCombina -> LTMAnaliAleatoria -> LTMShowAposta
*
*/
STATIC PROCEDURE LTMShowAposta

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
*	LTMRelResult()
*
*	Realiza a impressao dos resultados da LOTO MANIA.
*
*   LTMMntBrowse -> LTMAcoes -> LTMCombina -> LTMRelResult
*
*/
STATIC PROCEDURE LTMRelResult

local lContinua    := pTRUE
local lPushButton
local oWindow

local cInicio
local cFinal
local nCurrent
local nTotConcurso := 0
local bFiltro      := { || CONCURSO->CON_JOGO == pLOTO_MANIA .and. CONCURSO->( .not. Eof() ) }
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

				IF lContinua .and. LastKey() != K_ESC

					dbSelectArea('CONCURSO')
					IF CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + cInicio ) ) .and. ;
						CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + cFinal ) )

						bFiltro := { || CONCURSO->CON_JOGO == pLOTO_MANIA .and. CONCURSO->( .not. Eof() ) .and. ;
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
							oPDFReport:SetInfo( 'EDILSON MENDES', 'ODIN', 'RESULTADOS LOTO MANIA', oPDFReport:cFileName )

							nLinha := oPDFReport:MaxCol()

							//Posiciona o Registro
							If CONCURSO->( dbSetOrder(1), dbSeek( pLOTO_MANIA + cInicio ) )

								while Eval( bFiltro )

									// Atualiza a barra de Progresso
									oBarProgress:Update( ( nCurrent++ / nTotConcurso ) * 100 )

									If nLinha >= ( oPDFReport:MaxCol() - 35 )
										oPDFReport:AddPage()
										oPDFReport:DrawRetangle( 0,  0, 22, 2 )
										oPDFReport:DrawRetangle( 0, 25, 49, 2 )
										oPDFReport:DrawRetangle( 0, 77, 22, 2 )
										oPDFReport:DrawText( 1, 26, PadC( 'RESULTADOS LOTO MANIA', 70 ), , 10, 'Helvetica-Bold' )
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
			ErrorTable( '307' )  // Nao existem informacoes a serem impressas.
		endif

	always
		// Fecha o Objeto Windows
		oWindow:Close()
		// Restaura a tabela da Pilha
		DstkPop()
	end sequence

return
