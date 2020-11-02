/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

#include "set.ch"
#include "box.ch"
#include "inkey.ch"
#include "common.ch"
#include "button.ch"
#include "setcurs.ch"
#include "dbinfo.ch"
#include "main.ch"

static aOdinSystem

/***
*
*	Main( cParam1, cParam2, cParam3 ) -- Nil
*
*	Realiza a montagem do Menu Principal.
*
*/
PROCEDURE Main( cParam1, cParam2, cParam3 )

local aParams

    DEFAULT cParam1 TO "", ;
            cParam2 TO "", ;
            cParam3 TO ""

    // Interpreta os parametros passados na linha de comando
    aParams := ParseCommLine( Upper( cParam1 + "~" + cParam2 + "~" + cParam3 + "~" ) )

    //######################################################################
    // Define o diretorio de dados
    //######################################################################
    begin sequence

        If .not. Empty( aParams.Path )

            // Realiza o tratamento para o caminho definido no parametro
            aParams.Path := hb_PathNormalize( hb_DirSepAdd( aParams.Path ) )

            // Verifica a existencia do diretorio informando no parametro
            If .not. hb_vfDirExists( aParams.Path )
                aParams.Path := hb_PathNormalize( hb_DirSepAdd( hb_DirBase() ) )
            EndIf

        ElseIf .not. Empty( GetEnv( "ODIN" ) )

            // Obtem as informacoes da variavel de ambiente
            aParams.Path := hb_PathNormalize( hb_DirSepAdd( AllTrim( GetEnv( "ODIN" ) ) ) )

            // Checa a existencia do diretorio e se foi informado o drive no parametro
            If .not. hb_vfDirExists( aParams.Path )
                aParams.Path := hb_PathNormalize( hb_DirSepAdd( hb_DirBase() ) )
            EndIf

        Else
            //######################################################################
            // Caso nao tenha passado o caminho no parametro e nao tenha definido
            // a variavel de ambiente
            //######################################################################

            // Define o subdiretorio data para armazenamento
            aParams.Path := hb_PathNormalize( hb_DirSepAdd( hb_DirBase() ) ) + "data" + hb_ps()

            // Verifca a existencia do diretorio
            If .not. hb_vfDirExists( aParams.Path )
                aParams.Path := hb_PathNormalize( hb_DirSepAdd( hb_DirBase() ) )
            EndIf

        EndIf

    always
        // Define o diretorio padrao para armazenamento
        SI_PATH := aParams.Path
    end sequence


    //######################################################################
    // Define o diretorio de temporario
    //######################################################################
    begin sequence

        If .not. Empty( aParams.Temp )

            // Realiza o tratamento para o caminho definido no parametro
            aParams.Temp := hb_PathNormalize( hb_DirSepAdd( aParams.Temp ) )

            // Verifica a existencia do diretorio informando no parametro
            If .not. hb_vfDirExists( aParams.Temp )
                aParams.Temp := hb_PathNormalize( hb_DirSepAdd( hb_DirBase() ) )
            EndIf

        ElseIf .not. Empty( GetEnv( "TMP" ) )

            // Obtem as informacoes da variavel de ambiente
            aParams.Path := hb_PathNormalize( hb_DirSepAdd( AllTrim( GetEnv( "TMP" ) ) ) )

            // Checa a existencia do diretorio e se foi informado o drive no parametro
            If .not. hb_vfDirExists( aParams.Temp )
                aParams.Temp := hb_PathNormalize( hb_DirSepAdd( hb_DirBase() ) )
            EndIf

        Else

            //######################################################################
            // Caso nao tenha passado o caminho no parametro e nao tenha definido
            // a variavel de ambiente
            //######################################################################

            // Define o Caminho dos Dados do Sistema
            aParams.Temp := hb_PathNormalize( hb_DirSepAdd( hb_DirBase() ) ) + "tmp" + hb_ps()

            // Verifica a existencia do caminho definido
            If .not. hb_vfDirExists( aParams.Temp )
                aParams.Temp := hb_PathNormalize( hb_DirSepAdd( hb_DirBase() ) )
            EndIf

        EndIf

    always
        // Define o diretorio padrao temporario
        SI_TMP := aParams.Temp
    end sequence

    If .not. Empty( SI_PATH ) .and. .not. Empty( SI_TMP )
        
		// Realiza a Criacao da tabela de erros do sistema
		SetupEnvironment()

		// Verifica a criacao das tabelas do sistema
        Setup()
        
		// Efetua a abertura de arquivos do sistema
        OpenFiles()
        
		// Define as Cores do Sistema
		If ( IsColor() .or. "/C" $ Upper( aParams.color ) ) .and. .not. "/M" $ UPPER( aParams.color )
			SI_MESSAGE        := "B/W,R/W"                                      && Message no Rodape
			SI_BACKGROUND     := "B/W,R/W"                                      && Fundo de tela
			SI_PUSHBUTTON     := "W+/R,I/R,I/R,GR+/R"                           && Cores dos Botoes
			SI_MENU           := "N/BG,W+/N,GR+/BG,GR+/N,N+/BG,N/BG"            && Menu
			SI_FORM           := "W+/B"                                         && Formularios
			SI_LABEL          := "W+/B,B/W"                                     && Label de campos
			SI_SCROLLBAR      := "W+/B,GR+/B"                                   && Cores da Barra de Rolagem Vertical
			SI_FIELDGET       := "B/W,R/W,W+/B,GR+/BG"                          && Campos de Entrada de dados
			SI_FIELDLISTBOX   := "GR+/W,B/W,W/GR+,R/W,n+/w,w+/b,w/b,b/w"        && Campos de ListBox
			SI_FIELDGRADIOBOX := "W+/B,W+/B,GR+/B"                              && Cores Radio Group
			SI_FIELDBRADIOBOX := "W+/B,GR+/B,W+/B,GR+/B,W+/B,GR+/B,GR+/B"       && Campos Rario Button
			SI_FIELDCHECKBOX  := "B/W,GR+/B,W+/B,GR+/BG"                        && Campos de Entrada de dados
			SI_BROWSE         := "W+/B,B/W,R+/B,GR+/B,BG+/B,R+/B,W+/GB,B/W"     && Cores do Browse
			
		Else
			SI_MESSAGE        := "B/W,R/W"
			SI_BACKGROUND     := "B/W,R/W"
			SI_PUSHBUTTON     := "W/N,N/W,N/W,W+/N"
			SI_MENU           := "b/w,gr+/rb,r/w,g/rb,n+/w,w+/b"
			SI_FORM           := "W/N"
			SI_LABEL          := "W/N,N/W"
			SI_SCROLLBAR      := "B/W,R/W,W+/B,GR+/BG"
			SI_FIELDGET       := "B/W,R/W,B/BG,GR+/BG"
			SI_FIELDLISTBOX   := "b/w,gr+/rb,r/w,g/rb,n+/w,w+/b,w/b,b/w"
			SI_FIELDGRADIOBOX := "N/W"
			SI_FIELDBRADIOBOX := "W+/B,W+/B,GR+/B"
			SI_FIELDCHECKBOX  := "B/W,R/W,W+/B,GR+/BG"
			SI_BROWSE         := "B/BG,B/W"
			
		EndIf

		BEGIN SEQUENCE
		
			// Salva a tela Principal
			PUSHScreen()
			
			// Cria o Menu
			SI_MAINMENU := MenuCreate()
			
			SI_BANNER   := { |cName| ;
                                DispBegin(),;
                                hb_DispBox( SI_ROWTOP, SI_COLTOP, SI_ROWTOP+ 4, SI_COLBOTTOM, B_SINGLE + " ", SystemLabelColor() ),                 ;
                                hb_DispOutAt( SI_ROWTOP+ 1, SI_COLTOP+ 1,    hb_StrToUTF8( "Edilson Mendes Nascimento" ), SystemLabelColor() ),     ;
                                hb_DispOutAt( SI_ROWTOP+ 1, SI_COLBOTTOM-30, PadL( Transform( Date(), "@E 99/99/9999"), 30 ), SystemLabelColor() ), ;
                                hb_DispOutAt( SI_ROWTOP+ 2, SI_COLTOP+ 1,    hb_StrToUTF8( "Odin(tm)" ), SystemLabelColor() ),                      ;
                                hb_DispOutAt( SI_ROWTOP+ 2, SI_COLBOTTOM-30, PadL( hb_StrToUTF8( "Version 1.0" ), 30 ), SystemLabelColor() ),       ;
                                hb_DispOutAt( SI_ROWTOP+ 3, SI_COLTOP+ 1,    PadC( hb_StrToUTF8( cName ), SI_COLBOTTOM -2 ), SystemLabelColor() ),  ;
                                DispEnd() }
			
			DispBegin()
			hb_DispBox( SI_ROWTOP, SI_COLTOP, SI_ROWBOTTOM, SI_COLBOTTOM, REPLICATE( CHR(178), 9 ), SI_BACKGROUND )
			DispEnd()
			
			Eval( SI_BANNER, "Menu Principal" )
			
			while MenuModal( SI_MAINMENU, 1, SI_ROWBOTTOM, SI_COLTOP, SI_COLBOTTOM, SI_MESSAGE ) <> 999
            enddo
			
		always
			// Restaura a tela Principal
			POPScreen()
		end sequence
		
	Else
		
		? "Diretorio de dados:   " + aParams.Path
		? "Diretorio temporario: " + aParams.Temp
		INkey(0)

    EndIf

return


/***
*
*	MenuCreate() --> oValue
*
*	Realiza a montagem do Menu Principal.
*
*/
STATIC FUNCTION MenuCreate()

local oTopBar
local oSistema
local oConcurso
local oApostas
local oRelato
local oEstatistica
local oItem
    
    
    oTopBar := TopBar( SI_ROWTOP+ 5, SI_COLTOP, SI_COLBOTTOM )
    oTopBar:ColorSpec := SI_MENU
        
            // Create a new popup menu named FILE and add it to the TopBar object
            oSistema := PopUp()
            oSistema:ColorSpec := SI_MENU
            oTopBar:AddItem( MenuItem ( "&Sistema", oSistema ) )

                // Cria o Menu do Concurso
                oConcurso := PopUp()
                oConcurso:ColorSpec:= SI_MENU
                oSistema:AddItem( MenuItem( "&Concurso", oConcurso ) )
            
                    oItem := MenuItem( "&Dupla Sena    Ctr-D", {|| SystemSelect( pDUPLA_SENA ) }, K_CTRL_D, "Manutencao dos Jogos da Dupla Sena" )
                    oItem:Enabled := pTRUE
                    oConcurso:AddItem( oItem )
                    
                    oItem := MenuItem( "Loto &Facil    Ctr-F", {|| SystemSelect( pLOTO_FACIL ) }, K_CTRL_F, "Manutencao dos Jogos da Loto Facil" )
                    oItem:Enabled := pTRUE
                    oConcurso:AddItem( oItem )

                    oItem := MenuItem( "Loto &Mania    Ctr-M", {|| SystemSelect( pLOTO_MANIA ) }, K_CTRL_M, "Manutencao dos Jogos da Loto Mania" )
                    oItem:Enabled := pTRUE
                    oConcurso:AddItem( oItem)

                    oItem := MenuItem( "Mega Se&na     Ctr-N", {|| SystemSelect( pMEGA_SENA )  }, K_CTRL_N, "Manutencao dos Jogos da Mega Sena" )
                    oItem:Enabled := pTRUE
                    oConcurso:AddItem( oItem)

                    oItem := MenuItem( "&Quina         Ctr-Q", {|| SystemSelect( pQUINA )      }, K_CTRL_Q, "Manutencao dos Jogos da Quina" )
                    oItem:Enabled := pTRUE
                    oConcurso:AddItem( oItem)

                    oItem := MenuItem( "T&ime Mania    Ctr-I", {|| SystemSelect( pTIME_MANIA ) }, K_CTRL_I, "Manutencao dos Jogos da Time Mania" )
                    oItem:Enabled := pTRUE
                    oConcurso:AddItem( oItem)
                    
                    oItem := MenuItem( "Dia de So&rte  Ctr-R", {|| SystemSelect( pDIA_SORTE )  }, K_CTRL_R, "Manutencao dos Jogos Dia de Sorte" )
                    oItem:Enabled := pTRUE
                    oConcurso:AddItem( oItem)

                    oConcurso:AddItem( MenuItem( MENU_SEPARATOR ) )          

                    oItem := MenuItem( "Lote&ca        Ctr-C", {|| SystemSelect( pLOTECA )     }, K_CTRL_C, "Manutencao dos Jogos da Loteca" )
                    oItem:Enabled := pTRUE
                    oConcurso:AddItem( oItem)

                    oItem := MenuItem( "Loto&gol       Ctr-G", {|| SystemSelect( pLOTOGOL )    }, K_CTRL_G, "Manutencao dos Jogos da LotoGol" )
                    oItem:Enabled := pTRUE
                    oConcurso:AddItem( oItem)


                // Separador do Menu
                oSistema:AddItem( MenuItem( MENU_SEPARATOR ) )

                oItem := MenuItem( "Man&utencao    Ctr-U" ,{|| Manutencao() },  K_CTRL_U, "Realiza a manutencao do cadastro de concursos", 200)
                oSistema:AddItem( oItem )

                // Separador do Menu
                oSistema:AddItem( MenuItem( MENU_SEPARATOR ) )

                oItem := MenuItem( "A&postadores   Ctr-P" ,{|| Nil },  K_CTRL_P, "Realiza a manutencao de Apostadores")
                oSistema:AddItem( oItem )

                oItem := MenuItem( "Clu&bes        Ctr-B" ,{|| Nil },  K_CTRL_B, "Realiza a manutencao de Cllubes")
                oSistema:AddItem( oItem )

                oSistema:AddItem( MenuItem( MENU_SEPARATOR ) )
            
                oItem := MenuItem( "&Apostas       Ctr-A" ,{|| Nil },  K_CTRL_A, "Realiza a manutencao do cadastro de Apostas")
                oSistema:AddItem( oItem )
            
                oItem := MenuItem( "&Heuristica    Ctr-H" ,{|| Nil },  K_CTRL_H, "Realiza o estudo sobre as probabilidades de acerto")
                oSistema:AddItem( oItem )

                oItem := MenuItem( "&Importar      Ctr-I" ,{|| importar() },  K_CTRL_H, "Realiza o estudo sobre as probabilidades de acerto")
                oSistema:AddItem( oItem )
    
                // Separador do Menu
                oSistema:AddItem( MenuItem( MENU_SEPARATOR ) )

                oItem := MenuItem( "&Reindex       Ctr-R" ,{|| ( DBCloseAll(), SystemIndex(), Setup() ) },  K_CTRL_R, "Recria os indices do sistema")
                oItem:Enabled := IIF( .NOT. Empty( SI_CONCURSO ), pTRUE, pFALSE )
                oSistema:AddItem( oItem )

                // Separador do Menu
                oSistema:AddItem( MenuItem( MENU_SEPARATOR ) )

                oItem := MenuItem( "&Sair"                ,{|| pTRUE }, K_ALT_F4, "Finaliza a Aplicacao", 999)
                oSistema:AddItem( oItem)
        
        
        // Cria o Menu de Relatorios
        oRelato := PopUp()
        oRelato:ColorSpec := SI_MENU
        oTopBar:AddItem( MenuItem ( "&Relatorios", oRelato ) )
        
            oItem := MenuItem( "Extrat&o        Ctr-O" ,{|| Nil }, K_CTRL_O, "Realiza a Emissao do Extrato")
        oItem:Enabled := pTRUE
            oRelato:AddItem( oItem )
            
            //########################################################################
            //#Itens do Menu Criado somente para os Jogos da LotoFacil
            //########################################################################
            If SI_CONCURSO == "LF"
                // Separador do Menu
                oRelato:AddItem( MenuItem( MENU_SEPARATOR ) )
    
                // Cria o Menu de Estatisticas
                oEstatistica := PopUp()
                oEstatistica:ColorSpec:= SI_MENU
                oItem := MenuItem( "&Estatisticas", oEstatistica )
                
                oRelato:AddItem( oItem )          	
            
                        oItem :=MenuItem( "A&nalise       Ctr-N", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := IIF( SI_CONCURSO == "LF", pTRUE, pFALSE )          
                        oEstatistica:AddItem( oItem)
            
                        oItem :=MenuItem( "A&nalise de Frequencia Loteca", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := IIF( SI_CONCURSO == "LF", pTRUE, pFALSE )          
                        oEstatistica:AddItem( oItem)

                        oItem :=MenuItem( "A&nalise de Frequencia Loteria Esportiva", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := IIF( SI_CONCURSO == "LF", pTRUE, pFALSE )          
                        oEstatistica:AddItem( oItem)

                        oItem :=MenuItem( "Resultados Loteca", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := IIF( SI_CONCURSO == "LF", pTRUE, pFALSE )          
                        oEstatistica:AddItem( oItem)

                        oItem :=MenuItem( "Resultados Loteria Esportiva", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := IIF( SI_CONCURSO == "LF", pTRUE, pFALSE )          
                        oEstatistica:AddItem( oItem)

// Edilson
                        oItem :=MenuItem( "Mapa de Resultados", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := IIF( SI_CONCURSO == "LF", pTRUE, pFALSE )          
                        oEstatistica:AddItem( oItem)
                        
                oItem := MenuItem( "F&requencia     Ctr-R" ,{|| Nil }, K_CTRL_R, "Realiza a Impressao de um mapa com a analise de todos os concurso")
                oItem:Enabled := IIF( .NOT. Empty( SI_CONCURSO ), pTRUE, pFALSE )
                oRelato:AddItem( oItem )
                        
            EndIf
            
            //########################################################################
            //#Itens do Menu Criado somente para os Jogos da Loteca
            //########################################################################
            If SI_CONCURSO == "LC" .OR. SI_CONCURSO == "LG"
                // Separador do Menu
                oRelato:AddItem( MenuItem( MENU_SEPARATOR ) )

                oItem := MenuItem( "Clube&s         Ctr-S" ,{|| Nil },    K_CTRL_S, "Realiza a emissao das movimentacoes dos clubes.")
                oItem:Enabled := IIF( SI_CONCURSO == "LC" .OR. SI_CONCURSO == "LG", pTRUE, pFALSE )
                oRelato:AddItem( oItem )

                oItem := MenuItem( "Compet&icoes    Ctr-I" ,{|| Nil },   K_CTRL_I, "Realiza a emissao das movimentacoes das competicoes.")
                oItem:Enabled := IIF( SI_CONCURSO == "LC" .OR. SI_CONCURSO == "LG", pTRUE, pFALSE )
                oRelato:AddItem( oItem )
                
                oItem := MenuItem( "Disp&utas       Ctr-U" ,{|| Nil },  K_CTRL_U, "Realiza a emissao de um estudo entre dois times.")
                oItem:Enabled := IIF( SI_CONCURSO == "LC" .OR. SI_CONCURSO == "LG", pTRUE, pFALSE )
                oRelato:AddItem( oItem )
                
    
                // Cria o Menu de Estatisticas
                oEstatistica := PopUp()
                oEstatistica:ColorSpec:= SI_MENU
                oItem := MenuItem( "&Estatisticas", oEstatistica )
                
                oRelato:AddItem( oItem )          	
            
                        oItem :=MenuItem( "A&nalise       Ctr-N", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := iif( SI_CONCURSO == "LC" .or. SI_CONCURSO == "LG", pTRUE, pFALSE )
                        oEstatistica:AddItem( oItem)
            
                        oItem :=MenuItem( "A&nalise de Frequencia Loteca", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := iif( SI_CONCURSO == "LC" .or. SI_CONCURSO == "LG", pTRUE, pFALSE )
                        oEstatistica:AddItem( oItem)

                        oItem :=MenuItem( "A&nalise de Frequencia Loteria Esportiva", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := iif( SI_CONCURSO == "LC" .or. SI_CONCURSO == "LG", pTRUE, pFALSE )
                        oEstatistica:AddItem( oItem)

                        oItem :=MenuItem( "Resultados Loteca", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := iif( SI_CONCURSO == "LC" .or. SI_CONCURSO == "LG", pTRUE, pFALSE )
                        oEstatistica:AddItem( oItem)

                        oItem :=MenuItem( "Resultados Loteria Esportiva", {|| Nil }, K_CTRL_N, "Realiza a analise dos jogos para a Loteca" )
                        oItem:Enabled := iif( SI_CONCURSO == "LC" .or. SI_CONCURSO == "LG", pTRUE, pFALSE )
                        oEstatistica:AddItem( oItem)
                        
            EndIf
            
        
        // Separador do Menu
        oRelato:AddItem( MenuItem( MENU_SEPARATOR ) )
            
            oItem := MenuItem( "Resulta&dos     Ctr-D" ,{|| Nil },        K_CTRL_D, "Realiza a Impressao dos Resultados dos Jogos")
        oItem:Enabled := IIF( .NOT. Empty( SI_CONCURSO ), pTRUE, pFALSE )
            oRelato:AddItem( oItem )
            
return( oTopBar )
    

/***
*
*	SystemMaxRow() --> nValue
*
*	Realiza o retorno do numero de linha maxima na tela.
*
*/
FUNCTION SystemMaxRow()
    return( SI_ROWBOTTOM  )


/***
*
*	SystemMaxCol() --> nValue
*
*	Realiza o retorno do numero de coluna maxima na tela.
*
*/
FUNCTION SystemMaxCol()
    return( SI_COLBOTTOM  )


/***
*
*	SystemPath() --> cValue
*
*	Funcao responsavel em realizar o retorno do PATH definido pelo usuario
*
*/
FUNCTION SystemPath()
    return( SI_PATH )


/***
*
*	SystemTmp() --> cValue
*
*	Funcao responsavel em realizar o retorno do caminho temporario
*
*/
FUNCTION SystemTmp()
    return( SI_TMP )


/***
*
*	SystemLabelColor() --> String
*
*	Realizado o retorno da cor utilizada na exibicao dos Labels.
*
*/
FUNCTION SystemLabelColor()
    return( SI_LABEL )


/***
*
*	SystemFormColor() --> String
*
*	Funcao responsavel em realizar o retorno da cor utilizada no Form.
*
*/
FUNCTION SystemFormColor()
    return( SI_FORM )


/***
*
*	SiScrollBar() --> String
*
*	Funcao responsavel em realizar o retorno da cor na Barra de Rolagem Vertical.
*
*/


FUNCTION SysScrollBar()
    return( SI_SCROLLBAR )


/***
*
*	SiBrowseColor() --> String
*
*	Retorna a cor utilizada nos campos de RadioBox.
*
*/
FUNCTION SysBrowseColor()
    return( SI_BROWSE )


/***
*
*	SiFieldGet() --> String
*
*	Retorna a cor utilizada nos campos para entrada de dados.
*
*/
FUNCTION SysFieldGet()
    return( SI_FIELDGET )


/***
*
*	SysFieldListBox() --> String
*
*	Retorna a cor utilizada nos campos de ListBox.
*
*/
FUNCTION SysFieldListBox()
    return( SI_FIELDLISTBOX )    


/***
*
*	SiPushButton() --> String
*
*	Funcao responsavel em realizar o retorno da cor utilizada no PushButtom.
*
*/
FUNCTION SysPushButton()
    return( SI_PUSHBUTTON )


/***
*
*	SiFieldGRadioBox() --> String
*
*	Retorna a cor utilizada para o Group Radio.
*
*/
FUNCTION SysFieldGRadioBox()
    return( SI_FIELDGRADIOBOX )

/***
*
*	SiFieldBRadioBox() --> String
*
*	Retorna a cor utilizada para o Buttons Radio.
*
*/
FUNCTION SysFieldBRadioBox()
    return( SI_FIELDBRADIOBOX )


/***
*
*	SystemSelect()
*
*	Seleciona o jogo para o Sistema.
*
*/
STATIC PROCEDURE SystemSelect( cConcurso )

local nPointer

    If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == cConcurso } ) ) > 0
        SI_CONCURSO     := pSTRU_SYSTEM[ nPointer ][ pSTRU_JOGO ]
        SI_NOMECONCURSO := pSTRU_SYSTEM[ nPointer ][ pSTRU_NOME ]
    EndIf

    Eval( SI_BANNER, SI_NOMECONCURSO )

return


/***
*
*	Manutencao()
*
*	Realiza a chamada da funcao para manutencao da base de acordo com o concurso selecionado.
*
*/
STATIC PROCEDURE Manutencao()

local nPointer

    If .not. Empty( SystemConcurso() )
        If ( nPointer := AScan( pSTRU_SYSTEM, { |xJog| xJog[ pSTRU_JOGO ] == SystemConcurso() } ) ) > 0
            Eval( pSTRU_SYSTEM[ nPointer ][ pSTRU_JOGOS_BROWSE ] )
        EndIf
    EndIf

return


/***
*
*	SystemConcurso() --> String
*
*	Funcao responsavel em realizar o retorno do Concurso Selecionado
*
*/
FUNCTION SystemConcurso()
    return( SI_CONCURSO )


/***
*
*	SystemNameConcurso() --> String
*
*	Funcao responsavel em realizar o retorno do nome do Concurso selecionado
*
*/
FUNCTION SystemNameConcurso()
    return( SI_NOMECONCURSO )


/***
*
*  ParseCommLine( cStr ) --> { cCor, cDataDir, cTmpDir }
*
*	Processa os parametros passados na linha de comando.
*
*/
STATIC FUNCTION ParseCommLine( cStr )

local aRetValue := { "", "", "" }
local nPos      := 1
local cToken


    while ( nPos != 0 )

        If (( nPos := At( "~", cStr ) ) != 0 )

            cToken := SubStr( cStr, 1, nPos - 1 )
            cStr   := SubStr( cStr, ++nPos )

            do case
                case ( At( "/T", cToken ) > 0 )
                    aRetValue[3] := SUBStr( cToken, 3 )

                case ( At( "/P", cToken ) > 0 )
                    aRetValue[2] := SUBStr( cToken, 3 )

                case ( At( "/C", cToken ) > 0 .OR. At( "/M", cToken ) > 0)
                    aRetValue[1] := cToken

            end case

        EndIf

    enddo

return ( aRetValue )


/***
*
*	SetupEnvironment() --> NIL
*
*	Cria a tabela de Erros do sistema.
*
*/
STATIC PROCEDURE SetupEnvironment()

    ErrorTable( "001", "Concurso ja Existente." )
    ErrorTable( "002", "Nao existem clubes cadastrados." )

    // Dupla Sena
    ErrorTable( "101", "A primeira sequencia encontra em duplicidade." )
    ErrorTable( "102", "A segunda sequencia encontra em duplicidade." )
    ErrorTable( "103", "Dezena digitada na primeira sequencia fora da faixa." )
    ErrorTable( "104", "Dezena digitada na segunda sequencia fora da faixa." )
    ErrorTable( "105", "Problemas na criacao do arquivo temporario." )
    ErrorTable( "106", "Nao existem informacoes a serem exibidas." )
    ErrorTable( "107", "Nao existem informacoes a serem impressas." )

    // Loto Facil
    ErrorTable( "201", "A sequencia encontra em duplicidade." )
    ErrorTable( "203", "Dezena digitada encontra-se fora da faixa." )
    ErrorTable( "205", "Problemas na criacao do arquivo temporario." )
    ErrorTable( "206", "Nao existem informacoes a serem exibidas." )
    ErrorTable( "207", "Nao existem informacoes a serem impressas." )

    // Loto Mania
    ErrorTable( "301", "A sequencia encontra em duplicidade." )
    ErrorTable( "303", "Dezena digitada encontra-se fora da faixa." )
    ErrorTable( "305", "Problemas na criacao do arquivo temporario." )
    ErrorTable( "306", "Nao existem informacoes a serem exibidas." )
    ErrorTable( "307", "Nao existem informacoes a serem impressas." )

    // Mega Sena
    ErrorTable( "401", "A sequencia encontra em duplicidade." )
    ErrorTable( "403", "Dezena digitada encontra-se fora da faixa." )
    ErrorTable( "405", "Problemas na criacao do arquivo temporario." )
    ErrorTable( "406", "Nao existem informacoes a serem exibidas." )
    ErrorTable( "407", "Nao existem informacoes a serem impressas." )

    // Quina
    ErrorTable( "501", "A sequencia encontra em duplicidade." )
    ErrorTable( "503", "Dezena digitada encontra-se fora da faixa." )
    ErrorTable( "505", "Problemas na criacao do arquivo temporario." )
    ErrorTable( "506", "Nao existem informacoes a serem exibidas." )
    ErrorTable( "507", "Nao existem informacoes a serem impressas." )

    // Time Mania
    ErrorTable( "601", "A sequencia encontra em duplicidade." )
    ErrorTable( "602", "Nao existem clubes cadastrados." )
    ErrorTable( "603", "Dezena digitada encontra-se fora da faixa." )
    ErrorTable( "605", "Problemas na criacao do arquivo temporario." )
    ErrorTable( "606", "Nao existem informacoes a serem exibidas." )
    ErrorTable( "607", "Nao existem informacoes a serem impressas." )

    // Dia de Sorte

    // Loteca

    // Lotogol

    // ErrorTable( "002", "Numero Repetido na sequencia de digitacao." )
    ErrorTable( "003", "A quantidade de triplos e suprior a quantidade disponivel." )
    ErrorTable( "004", "Problemas na criacao do arquivo temporario." )
    ErrorTable( "005", "Existem Clubes cadastrados para esta competicoes." )
    ErrorTable( "006", "Dezena digitada fora da sequencia." )
    ErrorTable( "007", "Nao foi possivel criar o arquivo temporario." )
    ErrorTable( "008", "Existem Partidas Cadastrada para esta competicao." )
    ErrorTable( "009", "Verifique as dezenas do concurso." )
    ErrorTable( "010", "Pressione qualquer tecla..." )
    ErrorTable( "011", "Clube ja existe." )
    ErrorTable( "012", "Selecione o resultado da partida." )
    ErrorTable( "013", "Aposta ja cadastrada." )
    ErrorTable( "014", "Codigo ja Existe." )
    ErrorTable( "015", "Concurso nao encontrado." )  
    ErrorTable( "016", "Necessario informar o Time do coracao." )
    ErrorTable( "017", "Nao existem clubes cadastrados para esta competicao." )
    ErrorTable( "018", "Impressora nao encontrada." )
    ErrorTable( "019", "Nao existem competicoes cadastradas." )
    ErrorTable( "020", "Nao existem clubes cadastrados." )
    ErrorTable( "021", "Nao existem partidas em andamento." )
    ErrorTable( "022", "Nao foram encontrados dados para serem exibidos." )
    ErrorTable( "023", "Os valores informados devem estar entre 20 e 100 dezenas." )
    ErrorTable( "024", "Nao existem informacoes a serem exibidas." )
    ErrorTable( "025", "Registro insuficientes para emissao do relatorio." )
    //  ErrorTable( "026", "Nao foi possivel realizar a alteracao do registro." )
    ErrorTable( "027", "Necessario informar no minimo um duplo ou triplo." )

    ErrorMessage( , SI_COLBOTTOM, 0 )

return


/***
*
*	ErrorTable( <cCodigo>, <cMessage> ) --> lValue
*
*	Cria a tabela de Erros do sistema.
*
*	Parametros:
*               <cCodigo>  - Codigo do erro a ser cadastrado
*               <cMessage> - Mensagem do erro a ser cadastrada
*
*/
FUNCTION ErrorTable( cCodigo, cMessage )

local lRetValue := pFALSE
local nPointer

static aErrorTable

    If HB_ISNIL( aErrorTable )
        aErrorTable := {}
    EndIf

    If ( lRetValue := ISCHARACTER( cCodigo ) )
        If Len( aErrorTable ) != 0
            nPointer := AScan( aErrorTable, {|x| x[1] == cCodigo } )
        EndIf

        If ISCHARACTER( cMessage )
            If .not. Empty( nPointer )
                aErrorTable[ nPointer ] := { cCodigo, cMessage }
            Else
                AAdd( aErrorTable, { cCodigo, cMessage } )
            EndIf

        ElseIF .not. Empty( nPointer )
            ErrorMessage( aErrorTable[ nPointer ][1] + ": " + aErrorTable[ nPointer ][2] )
        Else
            lRetValue := pFALSE
        EndIf

    EndIf

return( lRetValue )


/***
*
*	ErrorMessage( <cMessage>, <nRow>, <nCol>, <cDispColor>, lDefaulColor )
*
*	Exibe a tabela de Erros do sistema.
*
*	Parametros:
*               <cMessage>     - Mensagem a ser exibida
*               <nRow>         - Linha para exibicao da mensagem
*               <nCol>         - Coluna para exiibicao da mensagem
*               <cDispColor>   - Cor para exibicao da mensagem
*               <lDefaulColor> - Indica se deve ser usada a cor definida na area como padrao
*
*/
PROCEDURE ErrorMessage( cMessage, nRow, nCol, cDispColor, lDefaulColor )

local cScreen
local nOldCursor := SET( _SET_CURSOR, SC_NONE )
local cOldDevice := SET( _SET_DEVICE, "SCREEN")

static nRowErr
static nColErr 
static nColor

    DEFAULT lDefaulColor TO pFALSE

    If .not. HB_ISNIL( cDispColor ) .and. ISCHARACTER( cDispColor )
        nColor := cDispColor
    Else
        DEFAULT nColor     TO ColorSet( nRowErr, nColErr ), ;
                cDispColor TO ColorSet( nRowErr, nColErr )
    EndIf

    do case
        case HB_ISNIL( nRowErr ) .and. HB_ISNIL( nColErr )
            DEFAULT nRowErr TO SystemMaxRow(), ;
                    nRow    TO SystemMaxRow(), ;
                    nColErr TO 0,              ;
                    nCol    TO 0

        case HB_ISNIL( nRowErr ) .and. .not. HB_ISNIL( nColErr )
            DEFAULT nRowErr TO SystemMaxRow(), ;
                    nRow    TO SystemMaxRow()

        case .not. HB_ISNIL( nRowErr ) .and. HB_ISNIL(nColErr)
            DEFAULT nColErr TO 0, ;
                    nCol    TO 0

        case .not. HB_ISNIL( nRowErr ) .and. .not. HB_ISNIL( nColErr )
            If ISNUMBER( nRow )
                nRowErr := nRow
            EndIf
            If ISNUMBER( nCol )
                nColErr := nCol
            EndIf
        endcase

    If .not. HB_ISNIL( cMessage )
        cScreen := SaveScreen(  nRowErr,       ;
                                nColErr,       ;
                                nRowErr,       ;
                                SystemMaxCol() )
        Scroll( nRowErr,       ;
                nColErr,       ;
                nRowErr,       ;
                SystemMaxCol() )
        hb_DispOutAt(   nRowErr,                             ;
                        nColErr,                             ;
                        cMessage,                            ;
                        iif(lDefaulColor, cDispColor, nColor ) )
        Inkey(0)
        RestScreen( nRowErr,        ;
                    nColErr,        ;
                    nRowErr,        ;
                    SystemMaxCol(), ;
                    cScreen         )
    EndIf

    Set( _SET_CURSOR, nOldCursor )
    Set( _SET_DEVICE, cOldDevice )

return


/***
*
*	DispMessage( <cMessage>, <nRow>, <nCol>, <cDispColor>, lDefaulColor )
*
*	Funcao que permite exibir mensagens no rodape da tela no processo de abertura de tabelas
*
*	Parametros:
*               <cMessage>     - Mensagem a ser exibida
*               <nRow>         - Linha para exibicao da mensagem
*               <nCol>         - Coluna para exiibicao da mensagem
*               <cDispColor>   - Cor para exibicao da mensagem
*               <lDefaulColor> - Indica se deve ser usada a cor definida na area como padrao
*
*/
PROCEDURE DispMessage( cMessage, nRow, nCol, cDispColor, lDefaulColor)

local nOldCursor := SET( _SET_CURSOR, SC_NONE )
local cOldDevice := SET( _SET_DEVICE, "SCREEN" )

static nOldRow
static nOldCol
static cOldScreen
static cOldColor

    DEFAULT nOldRow      TO SystemMaxRow(), ;
            nOldCol      TO 0,              ;
            lDefaulColor TO pFALSE

    If ISNUMBER( nRow )
        nOldRow := nRow
    EndIf

    If ISNUMBER( nCol )
        nOldCol := nCol
    EndIf

    If .not. ISNIL( cMessage ) .and. ISCHARACTER( cDispColor )
        cOldColor := cDispColor
    Else
        DEFAULT cOldColor  TO ColorSet( nRow, nCol ), ;
                cDispColor TO ColorSet( nRow, nCol )
    EndIf

    If PCount() != 0
        If .not. ISNIL( cMessage )

            If .not. Empty( cMessage )
                cOldScreen := SaveScreen(   nOldRow,       ;
                                            nOldCol,       ;
                                            nOldRow,       ;
                                            SystemMaxCol() )
                Scroll( nOldRow,       ;
                        nOldCol,       ;
                        nOldRow,       ;
                        SystemMaxCol() )
                hb_DispOutAt(   nOldRow,                                   ;
                                nOldCol,                                   ;
                                hb_StrToUTF8( cMessage ),                  ;
                                iif( lDefaulColor, cDispColor, cOldColor ) )

            Else
                hb_DispOutAt(   nOldRow,                                   ;
                                nOldCol,                                   ;
                                Space( SystemMaxCol() + 1),                ;
                                iif( lDefaulColor, cDispColor, cOldColor ) )                
                cOldScreen := SaveScreen(   nOldRow,       ;
                                            nOldCol,       ;
                                            nOldRow,       ;
                                            SystemMaxCol() )
            EndIf
        Else
            nOldRow := nRow
            nOldCol := nCol
        EndIf
    Else
        RestScreen( nOldRow,        ;
                    nOldCol,        ;
                    nOldRow,        ;
                    SystemMaxCol(), ;
                    cOldScreen      )
    EndIf

    Set( _SET_CURSOR, nOldCursor )
    Set( _SET_DEVICE, cOldDevice )

return
    


/***
*
*	ColorSet( <nRow>, <nCol> ) --> nValue
*
*	Retorna a cor da regiao definida.
*
*	Parametros:
*               <nRow> - Linha da area analisada
*               <nCol> - Coluna da area analisada
*
*/
FUNCTION ColorSet( nRow, nCol )

    DEFAULT nRow    TO Row(), ;
            nCol    TO Col()

return AttribuTec( Asc( SubStr( SaveScreen( nRow, nCol, nRow, nCol), 2, 1 ) ) )



/***
*
*	AttribuTec( <nAtr> ) --> cValue
*
*	Cria a tabela de Erros do sistema.
*
*	Parametros:art
*               <nAtr> - Valor Ascii com a cor da area
*
*/
FUNCTION AttribuTec( nAtr )

local cRetValue := ""
local nColor1
local nColor2
local lAscii

    If ISNUMBER( nAtr ) .and. ( nAtr := Abs( nAtr ) ) < 256
        lAscii := nAtr > 127
        If( lAscii )
            nAtr := nAtr - 127
        EndIf

        nColor1 := Val( Transform( nAtr % 16, "99" ) )
        nColor2 := Val( Transform( nAtr / 16, "99" ) )

        If(nColor1 > 7)
            cRetValue := AllTrim( Transform( nColor1 - 8, "99"))
            cRetValue += iif( lAscii, "*+/", "+/" )
            cRetValue += AllTrim( Transform( nColor2 - 1, "99" ) )
            cRetValue += ", "
            cRetValue += AllTrim( Transform( nColor2 - 1, "99" ) )
            cRetValue += "/"
            cRetValue += AllTrim( Transform( nColor1 - 8, "99" ) )
        Else
            cRetValue := AllTrim( Transform( nColor1, "99" ) )
            cRetValue += iif( lAscii, "*/", "/" )
            cRetValue += AllTrim( Transform( nColor2, "99" ) )
            cRetValue += ", "
            cRetValue += AllTrim( Transform( nColor2, "99" ) )
            cRetValue += "/"
            cRetValue += AllTrim( Transform( nColor1, "99" ) )
        EndIf
    EndIf
return cRetValue



/***
*
*	InitSystem()
*
*	Funcao Executada no momento da inicializacao do sistema.
*
*/
INIT PROCEDURE InitSystem()

#if defined( __PLATFORM__WINDOWS  )
    // REQUEST HB_GT_STD
    // REQUEST HB_GT_STD_DEFAULT
    REQUEST HB_GT_WVT_DEFAULT
    REQUEST HB_GT_WVT
#else
    REQUEST HB_GT_STD
#endIf	


    // Definir o tipo de banco de dados: DBFCDX Nativo
    REQUEST DBFCDX
    REQUEST DBFFPT
    ANNOUNCE FPTCDX
    rddSetDefault( "DBFCDX" )
    rddRegister( "DBFCDX", 1 ) // RDT_FULL SET AUTOPEN OFF
    // DBSetDriver( "DBFCDX" )	


    // Definir o Idioma Portugues
    REQUEST HB_LANG_PT
    REQUEST HB_CODEPAGE_PT850
    

    // Inicializa as Variaveis do Sistema
    pInicializa

    // Salva o Estado do Sistema
    SI_OLDCOLOR      := Set( _SET_COLOR )
    SI_CURSOR        := Set( _SET_CURSOR, SC_NONE )
    SI_SCOREBOARD    := Set( _SET_SCOREBOARD, pFALSE )
    SI_EXCLUSIVE     := Set( _SET_EXCLUSIVE, pFALSE )	
    SI_DELETED       := Set( _SET_DELETED, pTRUE )
    SI_CANCEL        := Set( _SET_CANCEL, pFALSE )
    SI_EPOCH         := Set( _SET_EPOCH, 1990 )
    SI_DATEFORMAT    := Set( _SET_DATEFORMAT, "dd/mm/yy" )
    SI_TIMEFORMAT    := Set( _SET_TIMEFORMAT, "hh:mm" )
    SI_AUTOPEN       := Set( _SET_AUTOPEN, pFALSE )
    SI_LANGUAGE      := Set( _SET_LANGUAGE, "PT" )
    SI_CODEPAGE      := Set( _SET_CODEPAGE, "PT850" )
    SI_OSCODEPAGE    := Set( _SET_OSCODEPAGE, hb_CdpOS() )
    SI_DBCODEPAGE    := Set( _SET_DBCODEPAGE, hb_CdpSelect() )
    
    SI_DBFLOCKSCHEME := Set( _SET_DBFLOCKSCHEME, DB_DBFLOCK_COMIX )
    SI_EVENTMASK     := Set( _SET_EVENTMASK, hb_bitOr( hb_bitAnd( INKEY_ALL, hb_bitNot( INKEY_MOVE ) ), HB_INKEY_GTEVENT, HB_INKEY_EXT ) )
    SI_OPTIMIZE      := Set( _SET_OPTIMIZE, pTRUE )
    SI_FILECASE      := Set( _SET_FILECASE, 1 )
    SI_DIRCASE       := Set( _SET_DIRCASE, 1 )

    // Numero Maximo de Linhas x Colunas
    SI_OLDROW       := ROW()
    SI_OLDCOL       := COL()

    // Ajusta a aplica com CodePage do SO
  //  hb_CdpSelect( hb_CdpOS() )
    hb_SetKeyCp( hb_CdpOS(), hb_CdpOS() )
  //  hb_SetDispCp( hb_CdpTerm(), "UTF8", .T. )
  //  hb_SetDispCp( hb_CdpTerm(), "UTF8", .T. )

    // Define o Numero de Linhas e Colunas para o sistema
    // SETMODE( 40, 110 )
    SETMODE( 50, 132 )
    //Set( _SET_VIDEOMODE, 264 )

    // Guarda as dimensoes da tela
    SI_ROWTOP       := 0
    SI_COLTOP       := 0
    SI_ROWBOTTOM    := MaxRow()
    SI_COLBOTTOM    := MaxCol()
    
return


/***
*
*	ExistSystem()
*
*	Funcao Executada no momento da Finalizacao do systema.
*
*/
EXIT PROCEDURE ExitSystem()

    dbCloseAll()

    // Restaura o Sistema
    Set( _SET_COLOR, SI_OLDCOLOR )
    Set( _SET_CURSOR, SI_CURSOR )
    Set( _SET_SCOREBOARD, SI_SCOREBOARD )
    Set( _SET_EXCLUSIVE, SI_EXCLUSIVE )
    Set( _SET_DELETED, SI_DELETED )
    Set( _SET_CANCEL, SI_CANCEL )
    Set( _SET_EPOCH, SI_EPOCH )
    Set( _SET_DATEFORMAT, SI_DATEFORMAT )
    Set( _SET_TIMEFORMAT, SI_TIMEFORMAT )
    Set( _SET_EVENTMASK, SI_EVENTMASK )
    Set( _SET_AUTOPEN, SI_AUTOPEN )
    Set( _SET_LANGUAGE, SI_LANGUAGE )
    Set( _SET_CODEPAGE, SI_CODEPAGE )
    Set( _SET_OSCODEPAGE, SI_OSCODEPAGE )
    Set( _SET_DBCODEPAGE, SI_DBCODEPAGE )
    
    Set( _SET_DBFLOCKSCHEME, SI_DBFLOCKSCHEME )
    Set( _SET_OPTIMIZE, SI_OPTIMIZE )
    Set( _SET_FILECASE, SI_FILECASE )
    Set( _SET_DIRCASE, SI_DIRCASE )

    SetPos( SI_OLDROW, SI_OLDCOL )

return


/***
*
* PushScreen( <nTop>, <nLeft>, <nBottom>, <nRight>, <lPopScreen> ) --> cValue
*
*	Salva a regiao da tela definida nos parametros.
*
*	Parametros:
*               <nTop>       - Linha Inicial
*               <nLeft>      - Coluna Inicial
*               <nBottom>    - Linha Final
*               <nRight>     - Coluna Final
*               <lPopScreen> - Variavel logical para a funcao PopScreen
*
*/
FUNCTION PushScreen( nTop, nLeft, nBottom, nRight, lPopScreen )

local cRetValue
local cScreen

static aPushScreen

    DEFAULT nTop       TO 0,        ;
            nLeft      TO 0,        ;
            nBottom    TO MaxRow(), ;
            nRight     TO MaxCol(), ;
            lPopScreen TO pFALSE

    If lPopScreen
        cRetValue   := ATail( aPushScreen )
        aPushScreen := ASize( aPushScreen, Len( aPushScreen ) -1)
    Else
        DEFAULT aPushScreen TO {}
        cRetValue := pTRUE
        cScreen   := Transform( nTop, "99")
        cScreen   += Transform( nLeft, "99")
        cScreen   += Transform( nBottom, "99")
        cScreen   += Transform( nRight, "99")
        cScreen   += SaveScreen( nTop, nLeft, nBottom, nRight )
        AAdd( aPushScreen, cScreen )
    EndIf

return( cRetValue )


/***
*
* PopScreen() --> cValue
*
*	Restaura a area na tela salva na pilha pela funcao PushScreen().
*
*/
FUNCTION PopScreen

local cScreen   := PushScreen( ,,,, pTRUE)
local nTop
local nLeft
local nBottom
local nRight
local lRetValue := pFALSE

    If ISCHARACTER( cScreen )
        lRetValue := pTRUE
        nTop      := Val( SubStr( cScreen, 1, 2) )
        nLeft     := Val( SubStr( cScreen, 3, 2) )
        nBottom   := Val( SubStr( cScreen, 5, 2) )
        nRight    := Val( SubStr( cScreen, 7, 2) )
        RestScreen( nTop, nLeft, nBottom, nRight, SubStr( cScreen, 9 ) )
    EndIf

return( lRetValue )


/***
*
*  GetNextFile( cCaminho ) --> cResult
*
*  cCaminho  : Parametro onde e informado o caminho em que o arquivo sera gerado.
*
*/
FUNCTION GetNextFile( cCaminho, cExtencao )

static aPilha

local cNewFile
local nPointer

    DEFAULT aPilha    TO {}, ;
            cExtencao TO 'ODN'

    while pTRUE
        cNewFile := StrZero( hb_RandInt( 99999999 ), 8 ) + '.' + cExtencao
        If ( nPointer := hb_AScan( aPilha, cCaminho + cNewFile ) ) == 0
            If .not. File( cCaminho + cNewFile ) .or. Len( aPilha ) >= 4096
                AAdd( aPilha, cCaminho + cNewFile )
                exit
            Else
                ADel( aPilha, 1 )
                ASize( aPilha, Len( aPilha ) - 1 )
            EndIf
        EndIf
    enddo

return( cCaminho + cNewFile )
    


procedure importar()

	local cJogo
	local cComp
	local cComp2
	local nSequencia
	local cOrigem
    local cOperacao
    local cCaminho     := '/home/edilson/odin_tes/sav_db/'


	////// 
	////// Importacao dos dados do cadastro de concurso
	////// 
	DbUseArea( .T. , , cCaminho + "arqcon01.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "arqcon01", "CO_JOGO+CO_CONCURS", {|| TMP->CO_JOGO+TMP->CO_CONCURS } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )
		do case
			case TMP->CO_JOGO == "DS" // Dupla Sena
				cJogo := "DSA"
			case TMP->CO_JOGO == "LF" // Loto Facil
				cJogo := "LTF"
			case TMP->CO_JOGO == "LM" // Loto Mania
				cJogo := "LTM"
			case TMP->CO_JOGO == "MS" // Mega Sena
				cJogo := "MSA"
			case TMP->CO_JOGO == "QN" // Quina
				cJogo := "QNA"
			case TMP->CO_JOGO == "TM" // Time Mania
				cJogo := "TIM"
			case TMP->CO_JOGO == "LC" // Loteca
				cJogo := "LTC"
			case TMP->CO_JOGO == "LG" // Lotogol
				cJogo := "LTG"

		endcase

		CONCURSO->( dbAppend() )
		CONCURSO->CON_JOGO   := cJogo
		CONCURSO->CON_CONCUR := PADL( ALLTRIM( TMP->CO_CONCURS ), 5, "0" )
		CONCURSO->CON_SORTEI := TMP->CO_SORTEIO
		CONCURSO->(DBUnlock())

		TMP->(DBSkip())
	ENDDO
	TMP->(DBCloseArea())


	////// 
	////// Importacao dos jogos dos concursos cadastrados
	////// 
	DbUseArea( .T. , , cCaminho + "arqjog01.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "arqjog01", "JG_JOGO+JG_CONCURS+JG_FAIXA", {|| TMP->JG_JOGO+TMP->JG_CONCURS+TMP->JG_FAIXA } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )
		do case
			case TMP->JG_JOGO == "DS"
				cJogo := "DSA"
			case TMP->JG_JOGO == "LF"
				cJogo := "LTF"
			case TMP->JG_JOGO == "LM"
				cJogo := "LTM"
			case TMP->JG_JOGO == "MS"
				cJogo := "MSA"
			case TMP->JG_JOGO == "QN"
				cJogo := "QNA"
			case TMP->JG_JOGO == "TM"
				cJogo := "TIM"
			case TMP->JG_JOGO == "LC"
				cJogo := "LTC"
			case TMP->JG_JOGO == "LG"
				cJogo := "LTG"

		endcase

		JOGOS->( dbAppend() )
		JOGOS->JOG_JOGO   := cJogo
		JOGOS->JOG_CONCUR := PADL( ALLTRIM( TMP->JG_CONCURS ), 5, "0" )
		JOGOS->JOG_FAIXA  := TMP->JG_FAIXA
		JOGOS->JOG_DEZENA := StrDezenas(TMP->JG_DEZENAS)
		JOGOS->JOG_TIM_CO := IIF( EMPTY( TMP->JG_TIM_COR ), "", PADL( ALLTRIM( TMP->JG_TIM_COR ), 5, "0" ) )
		JOGOS->JOG_COL_01 := IIF( EMPTY( TMP->JG_COLUNA1 ), "", PADL( ALLTRIM( TMP->JG_COLUNA1 ), 5, "0" ) )
		JOGOS->JOG_PON_01 := TMP->JG_PONTOS1
		JOGOS->JOG_COL_02 := IIF( EMPTY( TMP->JG_COLUNA2 ), "", PADL( ALLTRIM( TMP->JG_COLUNA2 ), 5, "0" ) )
		JOGOS->JOG_PON_02 := TMP->JG_PONTOS2
		JOGOS->(DBUnlock())

		TMP->(DBSkip())
	ENDDO
	TMP->(DBCloseArea())


	////// 
	////// Importacao dos rateios dos concursos cadastrados
	////// 
	DbUseArea(.T.,  , cCaminho + "arqrat01.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "arqrat01", "RA_JOGO+RA_CONCURS+JG_FAIXA+RA_PREMIA", {|| TMP->RA_JOGO+TMP->RA_CONCURS+TMP->RA_FAIXA+TMP->RA_PREMIA } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )
		do case
			case TMP->RA_JOGO == "DS"
				cJogo := "DSA"
			case TMP->RA_JOGO == "LF"
				cJogo := "LTF"
			case TMP->RA_JOGO == "LM"
				cJogo := "LTM"
			case TMP->RA_JOGO == "MS"
				cJogo := "MSA"
			case TMP->RA_JOGO == "QN"
				cJogo := "QNA"
			case TMP->RA_JOGO == "TM"
				cJogo := "TIM"
			case TMP->RA_JOGO == "LC"
				cJogo := "LTC"
			case TMP->RA_JOGO == "LG"
				cJogo := "LTG"
		endcase

		RATEIO->( dbAppend() )
		RATEIO->RAT_JOGO   := cJogo
		RATEIO->RAT_CONCUR := PADL( ALLTRIM( TMP->RA_CONCURS ), 5, "0" )
		RATEIO->RAT_FAIXA  := IIF( EMPTY( TMP->RA_FAIXA ), "01", TMP->RA_FAIXA )
		RATEIO->RAT_PREMIA := TMP->RA_PREMIA
		RATEIO->RAT_ACERTA := TMP->RA_ACERTA
		RATEIO->RAT_RATEIO := TMP->RA_RATEIO
		RATEIO->(DBUnlock())

		TMP->(DBSkip())
	ENDDO
	TMP->(DBCloseArea())

	////// 
	////// Importacao do cadastro de Apostadores
	////// 
	DbUseArea( .T., , cCaminho + "apocad01.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "apocad01", "APO_CODIGO", {|| TMP->APO_CODIGO } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )

		APOSTADORES->( dbAppend() )
		APOSTADORES->APO_APOCOD  := PADL( ALLTRIM( TMP->APO_CODIGO ), 6, "0" )
		APOSTADORES->APO_NOME    := ALLTRIM(TMP->APO_NOME) 
		APOSTADORES->APO_SALDO   := TMP->APO_SALDO
		APOSTADORES->APO_PREMIO  := TMP->APO_PREMIO
		APOSTADORES->APO_GASTOS  := TMP->APO_GASTOS

		APOSTADORES->(DBUnlock())

		TMP->(DBSkip())
	ENDDO
	TMP->(DBCloseArea())


	////// 
	////// Importacao do cadastro de clubes
	////// 
	DbUseArea( .T., , cCaminho + "clucad01.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "clucad01", "CLU_CODIGO", {|| TMP->CLU_CODIGO } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )

		CLUBES->( dbAppend() )
		CLUBES->CLU_CODIGO := PADL( ALLTRIM( TMP->CLU_CODIGO ), 5, "0" )
		CLUBES->CLU_ABREVI := ALLTRIM( TMP->CLU_ABREVI )
		CLUBES->CLU_NOME   := ALLTRIM( TMP->CLU_NOME )
		CLUBES->CLU_UF     := TMP->CLU_UF
		CLUBES->(DBUnlock())

		TMP->(DBSkip())
	ENDDO
	TMP->(DBCloseArea())


	////// 
	////// Importacao do cadastro de apostas
	////// 
	DbUseArea(.T., , cCaminho + "apoapo01.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "apoapo01", "AP1_JOGO+AP1_CONCUR", {|| TMP->AP1_JOGO+TMP->AP1_CONCUR } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )

		do case
			case TMP->AP1_JOGO == "DS"
				cJogo := "DSA"
			case TMP->AP1_JOGO == "LF"
				cJogo := "LTF"
			case TMP->AP1_JOGO == "LM"
				cJogo := "LTM"
			case TMP->AP1_JOGO == "MS"
				cJogo := "MSA"
			case TMP->AP1_JOGO == "QN"
				cJogo := "QNA"
			case TMP->AP1_JOGO == "TM"
				cJogo := "TIM"
			case TMP->AP1_JOGO == "LC"
				cJogo := "LTC"
			case TMP->AP1_JOGO == "LG"
				cJogo := "LTG"
		endcase

		APOSTAS->( dbAppend() )
		APOSTAS->CAD_JOGO   := cJogo
		APOSTAS->CAD_CONAPO := PADL( ALLTRIM( TMP->AP1_CONCUR ), 5, "0" )
		APOSTAS->CAD_SEQAPO := "001"
		APOSTAS->CAD_SORTEI := TMP->AP1_SORTEI
		APOSTAS->CAD_HISTOR := "APOSTA NORMAL"
		APOSTAS->(DBUnlock())

		TMP->(DBSkip())
	ENDDO
	TMP->(DBCloseArea())


	////// 
	////// Importacao do cadastro de Itens da apostas
	////// 
	DbUseArea(.T., , cCaminho + "apoapo02.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "apoapo02", "AP2_JOGO+AP2_CONCUR+AP2_DIGITO", {|| TMP->AP2_JOGO+TMP->AP2_CONCUR+TMP->AP2_DIGITO } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )

		do case
			case TMP->AP2_JOGO == "DS"
				cJogo := "DSA"
			case TMP->AP2_JOGO == "LF"
				cJogo := "LTF"
			case TMP->AP2_JOGO == "LM"
				cJogo := "LTM"
			case TMP->AP2_JOGO == "MS"
				cJogo := "MSA"
			case TMP->AP2_JOGO == "QN"
				cJogo := "QNA"
			case TMP->AP2_JOGO == "TM"
				cJogo := "TIM"
			case TMP->AP2_JOGO == "LC"
				cJogo := "LTC"
			case TMP->AP2_JOGO == "LG"
				cJogo := "LTG"
		endcase

		cComp      := TMP->AP2_JOGO+TMP->AP2_CONCUR
		nSequencia := 1
		WHILE TMP->AP2_JOGO+TMP->AP2_CONCUR == cComp

			APOSTAS_ITENS->( dbAppend() )
			APOSTAS_ITENS->ITN_JOGO   := cJogo
			APOSTAS_ITENS->ITN_CONAPO := PADL( ALLTRIM( TMP->AP2_CONCUR ), 5, "0" )
			APOSTAS_ITENS->ITN_SEQAPO := "001"			
			APOSTAS_ITENS->ITN_SEQITN := StrZero( nSequencia++, 3 )
			APOSTAS_ITENS->ITN_DEZENA := StrDezenas(TMP->AP2_DEZENA)
			APOSTAS_ITENS->ITN_VALOR  := IIF( TMP->AP2_VALOR < 0, TMP->AP2_VALOR * (-1), TMP->AP2_VALOR )
			APOSTAS_ITENS->ITN_TIM_CO := IIF( EMPTY( TMP->AP2_TIM_CO ), "", PADL(ALLTRIM( TMP->AP2_TIM_CO ), 5, "0" ) )
			APOSTAS_ITENS->(DBUnlock())

			TMP->(DBSkip())

		ENDDO
	ENDDO
	TMP->(DBCloseArea())


	////// 
	////// Importacao do cadastro de Resultado dos Clubes
	////// 
	DbUseArea(.T., , cCaminho + "apoapo03.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "apoapo03", "AP3_JOGO+AP3_CONCUR+AP3_DIGITO", {|| TMP->AP3_JOGO+TMP->AP3_CONCUR+TMP->AP3_DIGITO } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )

		do case
			case TMP->AP3_JOGO == "DS"
				cJogo := "DSA"
			case TMP->AP3_JOGO == "LF"
				cJogo := "LTF"
			case TMP->AP3_JOGO == "LM"
				cJogo := "LTM"
			case TMP->AP3_JOGO == "MS"
				cJogo := "MSA"
			case TMP->AP3_JOGO == "QN"
				cJogo := "QNA"
			case TMP->AP3_JOGO == "TM"
				cJogo := "TIM"
			case TMP->AP3_JOGO == "LC"
				cJogo := "LTC"
			case TMP->AP3_JOGO == "LG"
				cJogo := "LTG"
		endcase

		cComp      := TMP->AP3_JOGO+TMP->AP3_CONCUR
		nSequencia := 1
		WHILE TMP->AP3_JOGO+TMP->AP3_CONCUR == cComp

			cComp2 := TMP->AP3_JOGO+TMP->AP3_CONCUR+TMP->AP3_DIGITO
			while TMP->AP3_JOGO+TMP->AP3_CONCUR+TMP->AP3_DIGITO == cComp2

				APOSTAS_CLUBES->( dbAppend() )
				APOSTAS_CLUBES->CLB_JOGO   := cJogo
				APOSTAS_CLUBES->CLB_CONAPO := PADL( ALLTRIM( TMP->AP3_CONCUR ), 5, "0" )
				APOSTAS_CLUBES->CLB_SEQAPO := "001"
				APOSTAS_CLUBES->CLB_SEQITN := StrZero( nSequencia, 3 )				
				APOSTAS_CLUBES->CLB_FAIXA  := TMP->AP3_FAIXA
				APOSTAS_CLUBES->CLB_COL1   := PADL( ALLTRIM( TMP->AP3_COL1 ), 5, "0" )
				APOSTAS_CLUBES->CLB_COL2   := PADL( ALLTRIM( TMP->AP3_COL2 ), 5, "0" )
				APOSTAS_CLUBES->CLB_RESULT := TMP->AP3_MRK
				APOSTAS_CLUBES->CLB_PON1   := TMP->AP3_PON1
				APOSTAS_CLUBES->CLB_PON2   := TMP->AP3_PON2
				APOSTAS_CLUBES->CLB_DEZENA := StrDezenas(TMP->AP3_DEZENA)
				APOSTAS_CLUBES->(DBUnlock())

				TMP->(DBSkip())

			enddo

			nSequencia++

		ENDDO
	ENDDO
	TMP->(DBCloseArea())


	////// 
	////// Importacao do Grupo de apostadores
	////// 
	DbUseArea(.T., , cCaminho + "apogrp01.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "apogrp01", "GRP_JOGO+GRP_CONCUR", {|| TMP->GRP_JOGO+TMP->GRP_CONCUR } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )

		do case
			case TMP->GRP_JOGO == "DS"
				cJogo := "DSA"
			case TMP->GRP_JOGO == "LF"
				cJogo := "LTF"
			case TMP->GRP_JOGO == "LM"
				cJogo := "LTM"
			case TMP->GRP_JOGO == "MS"
				cJogo := "MSA"
			case TMP->GRP_JOGO == "QN"
				cJogo := "QNA"
			case TMP->GRP_JOGO == "TM"
				cJogo := "TIM"
			case TMP->GRP_JOGO == "LC"
				cJogo := "LTC"
			case TMP->GRP_JOGO == "LG"
				cJogo := "LTG"
		endcase

		APOSTAS_GRUPOS->( dbAppend() )
		APOSTAS_GRUPOS->GRP_JOGO   := cJogo
		APOSTAS_GRUPOS->GRP_CONAPO := PADL( ALLTRIM( TMP->GRP_CONCUR ), 5, "0" )
		APOSTAS_GRUPOS->GRP_SEQAPO := "001"
		APOSTAS_GRUPOS->GRP_APOCOD := PADL( ALLTRIM( TMP->GRP_APOSTA ), 6, "0" )
		APOSTAS_GRUPOS->GRP_VALOR  := IIF( TMP->GRP_VALOR < 0, TMP->GRP_VALOR * (-1), TMP->GRP_VALOR )
		APOSTAS_GRUPOS->(DBUnlock())

		TMP->(DBSkip())

	ENDDO
	TMP->(DBCloseArea())


	////// 
	////// Importacao do movimento financeiro
	////// 
	DbUseArea(.T., , cCaminho + "apomov01.dbf", "TMP", .T.) 
	dbCreateIndex( cCaminho + "apomov01", "MOV_DATA+MOV_APOSTA+MOV_ORIGEM", {|| DTOS( TMP->MOV_DATA )+TMP->MOV_APOSTA+TMP->MOV_ORIGEM } ) 

	TMP->(DBGoTop())
	WHILE .NOT. TMP->( EOF() )

		cComp      := DTOS( TMP->MOV_DATA )+TMP->MOV_APOSTA
		nSequencia := 1
		WHILE DTOS( TMP->MOV_DATA )+TMP->MOV_APOSTA == cComp

			do case
				case TMP->MOV_JOGO == "DS"
					cJogo := "DSA"
				case TMP->MOV_JOGO == "LF"
					cJogo := "LTF"
				case TMP->MOV_JOGO == "LM"
					cJogo := "LTM"
				case TMP->MOV_JOGO == "MS"
					cJogo := "MSA"
				case TMP->MOV_JOGO == "QN"
					cJogo := "QNA"
				case TMP->MOV_JOGO == "TM"
					cJogo := "TIM"
				case TMP->MOV_JOGO == "LC"
					cJogo := "LTC"
				case TMP->MOV_JOGO == "LG"
					cJogo := "LTG"
				otherwise
					cJogo := ""
			endcase

			// Origem do Registro
			do case
				case TMP->MOV_ORIGEM == "M"
					cOrigem := "AUT"
				case TMP->MOV_ORIGEM == "C"
					cOrigem := "MAN"
			endcase

			// Operacao
			do case
				case TMP->MOV_OPERAC == "D"
					cOperacao := "DEB"
				case TMP->MOV_OPERAC == "C"
					cOperacao := "CRE"
			endcase

			MOVIMENTOS->( dbAppend() )
			MOVIMENTOS->MOV_JOGO   := cJogo
			MOVIMENTOS->MOV_DTAMOV := TMP->MOV_DATA
			MOVIMENTOS->MOV_CONAPO := IIF( EMPTY( cJogo ), "", PADL( ALLTRIM( TMP->MOV_CONCUR ), 5, "0" ) )
			MOVIMENTOS->MOV_SEQ    := STRZero( nSequencia++, 3 )
			MOVIMENTOS->MOV_AUTMAN := cOrigem
			MOVIMENTOS->MOV_APOCOD := PADL( ALLTRIM( TMP->MOV_APOSTA ), 6, "0" )
			MOVIMENTOS->MOV_HISTOR := TMP->MOV_HISTOR
			MOVIMENTOS->MOV_CREDEB := cOperacao
			MOVIMENTOS->MOV_VALOR  := IIF( TMP->MOV_VALOR < 0, TMP->MOV_VALOR * (-1), TMP->MOV_VALOR )
			MOVIMENTOS->(DBUnlock())

			TMP->(DBSkip())

		ENDDO

	ENDDO
	TMP->(DBCloseArea())

return
