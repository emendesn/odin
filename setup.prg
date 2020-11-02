/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

#include "setcurs.ch"
#include "common.ch"
#include "main.ch"
#include "error.ch"


#ifdef __HARBOUR__
	#define pARRAY     "A"
	#define pBLOCK     "B"
	#define pCHARACTER "C"
	#define pDATE      "D"
	#define pLOGICAL   "L"
	#define pMEMO      "M"
	#define pNUMERIC   "N"
	#define pOBJECT    "O"

    // Constantes para a manipulacao das tabelas
	#define pREINDEX    1
	#define pSTARTOVER  2
	#define pSTANDARD   0
#endif

/***
*
*  Funcoes para Manipulacao da Estrutura do arquivos
*
***/
#xtranslate ADDFIELD(<array>, <name>, <type>, <length>, <dec> ) => AAdd( <array>, {<(name)>, <(type)>, <length>, <dec>} )
#xtranslate ADDINDEX(<array>, <name>, <key> )                   => AAdd( <array>, {<(name)>, <(key)>, <{key}> } )

#xtranslate odnAlert( <Message> )                               => hb_gtAlert( <Message>, { "Ok" }, "W+/R", "W+/B" )

static aSystem := {}

/***
*
*  Setup( <nOperacao> ) --> NIL
*
*	Rotina de definicao das tabelas.
*
*	Parametros:
*               <nOperacao> - 1 -> Reseta todas as tabelas de dados
*               <nOperacao> - 2 -> Reindexa os arquivos
*
***/
PROCEDURE Setup( nOperacao )

    If Len( aSystem ) == 0
        AAdd( aSystem, { "arqcon01", "CONCURSO",        { "arqcon1a", "arqcon1b"             }, "Arquivo de Concursos" } )
        AAdd( aSystem, { "arqjog02", "JOGOS",           { "arqjog2a"                         }, "Arquivo de Jogos" } )
        AAdd( aSystem, { "arqrat03", "RATEIO",          { "arqrat3a"                         }, "Arquivo de Rateio" } )
        AAdd( aSystem, { "cadapo01", "APOSTADORES",     { "cadapo1a"                         }, "Cadastro de Apostadores" } )
        AAdd( aSystem, { "cadclu02", "CLUBES",          { "cadclu2a", "cadclu2b", "cadclu2c" }, "Cadastro de Clubes" } )
        AAdd( aSystem, { "apocad01", "APOSTAS",         { "apocad1a", "apocad1b"             }, "Cabecario do Cadastro de Apostas" } )
        AAdd( aSystem, { "apoitn02", "APOSTAS_ITENS",   { "apoitn2a", "apoitn2b"             }, "Itens das Apostas" } )
        AAdd( aSystem, { "apoclb03", "APOSTAS_CLUBES",  { "apoclb3a"                         }, "Itens com as Apostas da Loteca e da Lotogol" } )		
        AAdd( aSystem, { "apogrp04", "APOSTAS_GRUPOS",  { "apogrp4a", "apogrp4b"             }, "Grupo de Apostadores" } )
        AAdd( aSystem, { "finmov01", "MOVIMENTOS",      { "finmov1a", "finmov1b"             }, "Arquivos de movimentacoes financeira" } )
        /*		AAdd( aSystem, { "comcad01", "COMPETICOES",     { "comcad1a", "comcad1b"             }, "Cadastro de Competicoes" } )
        AAdd( aSystem, { "parcad01", "PARTIDAS",        { "parcad1a", "parcad1b"             }, "Cadastro de Partidas" } )
        AAdd( aSystem, { "pargrp02", "GRPPARTI",        { "pargrp2a"                         }, "Grupo de Clubes disputados nas Partidas" } ) */

    EndIf

    CheckConcurso( nOperacao )
    CheckJogos( nOperacao )
    CheckRateio( nOperacao )
    CheckCadApostadores( nOperacao )
    CheckCadClubes( nOperacao )
    CheckApostas( nOperacao )
    CheckItenApostas( nOperacao )
    CheckClubApostas( nOperacao )	
    CheckGrpApostadores( nOperacao )
    CheckMovimentacoes( nOperacao )
    /*	CheckCompeticoes( nOperacao )
    CheckPartidas( nOperacao )
    CheckGrpPartidas( nOperacao ) */
	
return


/***
*
*  SystemIndex() --> NIL
*
*  Recria os indices das tabelas do sistema
*
***/
PROCEDURE SystemIndex()

    CheckConcurso( pREINDEX )
    CheckConcurso( pREINDEX )
    CheckJogos( pREINDEX )
    CheckRateio( pREINDEX )
    CheckCadApostadores( pREINDEX )
    CheckCadClubes( pREINDEX )
    CheckApostas( pREINDEX )
    CheckItenApostas( pREINDEX )
    CheckClubApostas( pREINDEX )		
    CheckGrpApostadores( pREINDEX )
    CheckMovimentacoes( pREINDEX )
    /*	CheckCompeticoes( pREINDEX )
    CheckPartidas( pREINDEX )
    CheckGrpPartidas( pREINDEX )*/

return


/***
*
*  OpenFiles() --> NIL
*
*  Realiza a aberturdas das tabelas do sistema
*
***/
PROCEDURE OpenFiles()

local oErr
local nCounter
local cMessage

    DEFAULT cMessage TO ""

    dbCloseAll()

    for nCounter := 1 to len( aSystem )

        begin sequence with __BreakBlock()
            If Len( aSystem[ nCounter ] ) == 1
                aSystem[ nCounter ] := { aSystem[nCounter, 1], aSystem[nCounter, 1] }
            EndIf

            If Len( aSystem[ nCounter ] ) >= 4
                cMessage := aSystem[ nCounter ][4]
            EndIf

            DispMessage( PadR( cMessage, SystemMaxCol() + 1 ) )

            If aSystem[nCounter][2] == NIL
                aSystem[nCounter][2] := aSystem[nCounter][1]
            EndIf

            dbUseArea( pTRUE, , ( SystemPath() + aSystem[ nCounter ][1] ), aSystem[ nCounter ][2], pTRUE )

            If Len( aSystem[ nCounter ] ) >= 3
                AEval( aSystem[ nCounter ][3], { |cFile| dbSetIndex( SystemPath() + cFile )} )
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_READ .or. oErr:genCode == EG_CORRUPTION .or. oErr:genCode == EG_CORRUPTION
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    next

    DispMessage("")

return


/***
*
*	CheckConcurso( <nOption> ) --> NIL
*
*	Rotina para a criacao do arquivo com o cabecario dos concursos.
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               con_jogo   - Codigo do tipo jogo relacionado ao registro
*               con_concur - Codigo do concurso cadastrado
*               con_sortei - Data em que foi realizado o sorteio do concurso
*
*/
STATIC PROCEDURE CheckConcurso( nOption )

local oErr
local aStru      := {}
local cFile      := "arqcon01"
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
local lIndexFound:= .not. File( SystemPath() + "arqcon1a" + ordBagExt()  ) .and. ;
                    .not. FILE( SystemPath() + "arqcon1b" + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .NOT. Empty( nOption )

        ADDFIELD( aStru, con_jogo,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, con_concur,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, con_sortei,  pDATE,      08, 0 )

        ADDINDEX( aIndexes, arqcon1a, FIELD->con_jogo + FIELD->con_concur )
        ADDINDEX( aIndexes, arqcon1b, FIELD->con_jogo + DESCEND( FIELD->con_concur ) )

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( oErr:description )
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckJogos( <nOption> ) --> NIL
*
*	Rotina para a criacao do arquivo com o cabecario dos concursos.
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               jog_jogo   - Codigo do tipo jogo relacionado ao registro
*               jog_concur - Codigo do concurso cadastrado
*               jog_faixa  - Codigo informando a faixa do concurso cadastrado
*                            exclusivo DUPLA SENA e LOTECA
*               jog_dezena - Sequencia das dezenas cadastradas no concurso
*                            exclusivo para DUPLA SENA, LOTOFACIL, LOTOMANIA,
*                            MEGA SENA, QUINA, TIME MANIA e DIA DE SORTE
*               jog_tim_co - Codigo informando o time sorteado no concurso
*                            exclusivo para TIME MANIA
*               jog_dds_co - Codigo informando o codigo do mes de sorte
*                            exclusivo para DIA DE SORTE
*               jog_col_01 - Codigo informando o time sorteado no concurso
*                            exclusivo para LOTECA e LOTOGOL
*               jog_pon_01 - Pontos obtidos no resultado do jogo
*                            exclusivo para LOTECA e LOTOGOL
*               jog_col_02 - Codigo informando o time sorteado no concurso
*                            exclusivo para LOTECA e LOTOGOL
*               jog_pon_02 - Pontos obtidos no resultado do jogo
*                            exclusivo para LOTECA e LOTOGOL
*
*/
STATIC PROCEDURE CheckJogos( nOption )

local oErr
local aStru      := {}
local cFile      := "arqjog02"
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
local lIndexFound:= .not. File( SystemPath() + "arqjog2a" + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, jog_jogo,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, jog_concur,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, jog_faixa,   pCHARACTER, 02, 0 )
        ADDFIELD( aStru, jog_dezena,  pCHARACTER, 59, 0 )
        ADDFIELD( aStru, jog_tim_co,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, jog_dds_co,  pCHARACTER, 02, 0 )        
        ADDFIELD( aStru, jog_col_01,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, jog_pon_01,  pNUMERIC,   02, 0 )
        ADDFIELD( aStru, jog_col_02,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, jog_pon_02,  pNUMERIC,   02, 0 )

        ADDINDEX( aIndexes, arqjog2a, FIELD->jog_jogo + FIELD->jog_concur + FIELD->jog_faixa)

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( oErr:description )
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckRateio( <nOption> ) --> NIL
*
*	Rotina para a criacao do arquivo com o cabecario dos concursos.
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               rat_jogo   - Codigo do tipo jogo relacionado ao registro
*               rat_concur - Codigo do concurso cadastrado
*               rat_faixa  - Codigo informando a faixa do concurso cadastrado
*               rat_premia - Codigo da premiacao cadastrada
*               rat_acerta - Numero de acertadores do concurso cadastrado
*               rat_rateio - Valor do rateio do concurso cadastrado
*
*/
STATIC PROCEDURE CheckRateio( nOption )

local oErr
local aStru      := {}
local cFile      := "arqrat03"
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
local lIndexFound:= .not. file( SystemPath() + "arqrat3a" + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, rat_jogo,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, rat_concur,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, rat_faixa,   pCHARACTER, 02, 0 )
        ADDFIELD( aStru, rat_premia,  pCHARACTER, 02, 0 )
        ADDFIELD( aStru, rat_acerta,  pNUMERIC,   10, 0 )
        ADDFIELD( aStru, rat_rateio,  pNUMERIC,   13, 2 )

        ADDINDEX( aIndexes, arqrat3a, FIELD->rat_jogo + FIELD->rat_concur + FIELD->rat_faixa + FIELD->rat_premia)

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( oErr:description )
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckCadApostadores( <nOption> ) --> NIL
*
*	Rotina para o cadastro de apostadores
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               apo_apocod - Codigo do apostador cadastrado
*               apo_nome   - Nome do Apostador Cadastrado
*               apo_saldo  - Saldo do Apostador Cadastrado
*               apo_premio - Valor da premiacao do apostador obtida na apuracao do concurso
*               apo_gastos - Valor do gasto efetuado na aposta
*
*/
STATIC PROCEDURE CheckCadApostadores( nOption )

local oErr
local aStru      := {}
local cFile      := "cadapo01"
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
local lIndexFound:= .not. File( SystemPath() + "cadapo1a" + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, apo_apocod, pCHARACTER, 06, 0 )
        ADDFIELD( aStru, apo_nome,   pCHARACTER, 30, 0 )
        ADDFIELD( aStru, apo_email,  pCHARACTER, 30, 0 )
        ADDFIELD( aStru, apo_saldo,  pNUMERIC,   10, 2 )
        ADDFIELD( aStru, apo_premio, pNUMERIC,   10, 2 )
        ADDFIELD( aStru, apo_gastos, pNUMERIC,   10, 2 )

        ADDINDEX( aIndexes, cadapo1a, FIELD->apo_apocod )

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( oErr:description )
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckCadClubes( <nOption> ) --> NIL
*
*	Rotina para o cadastro de clubes
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               clu_codigo - Codigo do clube cadastrado
*               clu_abrevi - Abreviacao do clube cadastrado
*               clu_nome   - Nome do clube cadastrado
*               clu_uf     - Estado do clube cadastrado
*
*/
STATIC PROCEDURE CheckCadClubes( nOption )

local oErr
local aStru      := {}
local cFile      := "cadclu02"
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
local lIndexFound:= .not. File( SystemPath() + "cadclu2a" + ordBagExt()  ) .and. ;
                    .not. File( SystemPath() + "cadclu2b" + ordBagExt()  ) .and. ;
                    .not. File( SystemPath() + "cadclu2c" + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, clu_codigo,  pCHARACTER,  05, 0 )
        ADDFIELD( aStru, clu_abrevi,  pCHARACTER,  30, 0 )
        ADDFIELD( aStru, clu_nome,    pCHARACTER,  60, 0 )
        ADDFIELD( aStru, clu_uf,      pCHARACTER,  02, 0 )

        ADDINDEX( aIndexes, cadclu2a, FIELD->clu_codigo )
        ADDINDEX( aIndexes, cadclu2b, FIELD->clu_abrevi )
        ADDINDEX( aIndexes, cadclu2c, FIELD->clu_nome )

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( oErr:description )
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckApostas( <nOption> ) --> NIL
*
*	Cabecario de Apostas
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               cad_jogo   - Codigo do tipo jogo que sera realizada a aposta
*               cad_conapo - Codigo do concurso que sera realizada a aposta
*               cad_seqapo - Codigo sequencial onde permite que seja cadastrado mais
*                            apostas por concurso
*               cad_sortei - Data da realizacao da aposta
*
*/
STATIC PROCEDURE CheckApostas( nOption )

local oErr
local aStru      := {}
local cFile      := "apocad01"
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
local lIndexFound:= .not. File( SystemPath() + "apocad1a" + ordBagExt()  ) .and. ;
                    .not. File( SystemPath() + "apocad1b" + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, cad_jogo,    pCHARACTER,  03, 0 )
        ADDFIELD( aStru, cad_conapo,  pCHARACTER,  05, 0 )
        ADDFIELD( aStru, cad_seqapo,  pCHARACTER,  03, 0 )
        ADDFIELD( aStru, cad_sortei,  pDATE,       08, 0 )
        ADDFIELD( aStru, cad_histor,  pCHARACTER,  30, 0 )

        ADDINDEX( aIndexes, apocad1a, FIELD->cad_jogo + FIELD->cad_conapo + FIELD->cad_seqapo )
        ADDINDEX( aIndexes, apocad1b, DTOS( FIELD->cad_sortei ) + FIELD->cad_jogo + FIELD->cad_conapo )

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( "Funcao: CheckApostas - " + oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( "Funcao: CheckApostas - " + oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( "Funcao: CheckApostas - " + oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( "Funcao: CheckApostas - " + oErr:description )
                        Break(oErr)
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( "Funcao: CheckApostas - " + oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( "Funcao: CheckApostas - " + oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( "Funcao: CheckApostas - " + oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckItenApostas( <nOption> ) --> NIL
*
*	Tabela contendo as apostas relacionadas a LOTO FACIL, LOTO MANIA, MEGA SENA, QUINA e TIME MANIA
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               itn_jogo   - Codigo do tipo jogo que sera realizada a aposta
*               itn_conapo - Codigo do concurso que sera realizada a aposta
*               itn_seqapo - Codigo sequencial da aposta cadastrada
*               itn_seqitn - Codigo sequencial onde permite que seja cadastrado mais
*                            apostas por concurso
*               itn_dezena - Dezenas relacionada a aposta cadastrada
*               itn_valor  - Valor da aposta realizada
*               itn_tim_co - Codigo do clube da aposta realizada 
*                            Especifico para TIME MANIA
*               itn_dds_me - Codigo do mes de sorte da aposta realizada 
*                            Especifico para DIA DE SORTE

*
*/
STATIC PROCEDURE CheckItenApostas( nOption )

local oErr
local aStru      := {}
local cFile      := "apoitn02"
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
local lIndexFound:= .not. File( SystemPath() + "apoitn2a" + ordBagExt()  ) .and. ;
                    .not. File( SystemPath() + "apoitn2b" + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, itn_jogo,    pCHARACTER,  03, 0 )
        ADDFIELD( aStru, itn_conapo,  pCHARACTER,  05, 0 )
        ADDFIELD( aStru, itn_seqapo,  pCHARACTER,  03, 0 )
        ADDFIELD( aStru, itn_seqitn,  pCHARACTER,  03, 0 )
        ADDFIELD( aStru, itn_dezena,  pCHARACTER, 149, 0 )
        ADDFIELD( aStru, itn_valor,   pNUMERIC,    13, 2 )
        ADDFIELD( aStru, itn_tim_co,  pCHARACTER,  05, 0 )
        ADDFIELD( aStru, itn_dds_me,  pCHARACTER,  02, 0 )

        ADDINDEX( aIndexes, apoitn2a, FIELD->itn_jogo + FIELD->itn_conapo + FIELD->itn_seqapo + FIELD->itn_seqitn)
        ADDINDEX( aIndexes, apoitn2b, FIELD->itn_jogo + FIELD->itn_seqitn + FIELD->itn_conapo )

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( oErr:description )
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckClubApostas( <nOption> ) --> NIL
*
*	Tabela contendo as apostas relacionadas a LOTECA, LOTOGOL e DUPLA SENA
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               clb_jogo   - Codigo do tipo jogo que sera realizada a aposta
*               clb_conapo - Codigo do concurso que sera realizada a aposta
*               clb_seqapo - Codigo sequencial da aposta cadastrada
*               clb_seqitn - Codigo sequencial onde permite que seja cadastrado mais
*                            apostas por concurso
*               clb_faixa  - Faixa do jogo cadastrado onde para a LOTECA (1-14),
*                            LOTOGOL (1-5) e DUPLA SENA (1-2)
*               clb_col1   - Codigo do clube para LOTECA e LOTOGOL
*               clb_col2   - Codigo do clube para LOTECA e LOTOGOL
*               clb_result - Resultado da partida para LOTECA
*               clb_pon1   - Pontos da partida LOTOGOL
*               clb_pon2   - Pontos da partida LOTOGOL
*               clb_dezena - Sequencia de dezenas para DUPLA SENA
*
*/
STATIC PROCEDURE CheckClubApostas( nOption )

local oErr
local aStru      := {}
local cFile      := "apoclb03"
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
local lIndexFound:= .not. File( SystemPath() + "apoclb3a" + ordBagExt() )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, clb_jogo,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, clb_conapo,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, clb_seqapo,  pCHARACTER, 03, 0 )		
        ADDFIELD( aStru, clb_seqitn,  pCHARACTER, 03, 0 )
        ADDFIELD( aStru, clb_faixa,   pCHARACTER, 02, 0 )
        ADDFIELD( aStru, clb_col1,    pCHARACTER, 05, 0 )
        ADDFIELD( aStru, clb_col2,    pCHARACTER, 05, 0 )
        ADDFIELD( aStru, clb_result,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, clb_pon1,    pNUMERIC,   01, 0 )
        ADDFIELD( aStru, clb_pon2,    pNUMERIC,   01, 0 )
        ADDFIELD( aStru, clb_dezena,  pCHARACTER, 17, 0 )

        ADDINDEX( aIndexes, apoclb3a, FIELD->clb_jogo + FIELD->clb_conapo + FIELD->clb_seqapo + FIELD->clb_seqitn + FIELD->clb_faixa )

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( oErr:description )
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckGrpApostadores( <nOption> ) --> NIL
*
*	Tabela contendo o grupo de apostadores
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               grp_jogo   - Codigo do tipo jogo que sera realizada a aposta
*               grp_conapo - Codigo do concurso que sera realizada a aposta
*               grp_seqapo - Codigo sequencial onde permite que seja cadastrado mais
*                            apostas por concurso
*               grp_apocod - Codigo do Apostador
*               grp_valor  - Valor da aposta
*
*/
STATIC PROCEDURE CheckGrpApostadores( nOption )

local oErr
local aStru      := {}
local cFile      := "apogrp04"
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
local lIndexFound:= .not. File( SystemPath() + "apogrp4a" + ordBagExt() ) .and. ;
                    .not. File( SystemPath() + "apogrp4b" + ordBagExt() )


    If lStartup .or. lIndexFound .or. .not. EMPTY( nOption )

        ADDFIELD( aStru, grp_jogo,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, grp_conapo,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, grp_seqapo,  pCHARACTER, 03, 0 )
        ADDFIELD( aStru, grp_apocod,  pCHARACTER, 06, 0 )
        ADDFIELD( aStru, grp_valor,   pNUMERIC,   09, 2 )

        ADDINDEX( aIndexes, apogrp4a, FIELD->grp_jogo + FIELD->grp_conapo + FIELD->grp_seqapo + FIELD->grp_apocod )
        ADDINDEX( aIndexes, apogrp4b, FIELD->grp_apocod )

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( oErr:description )
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckMovimentacoes( <nOption> ) --> NIL
*
*	Tabela contendo as movimentacoes financeiras de apostas
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               mov_jogo   - Codigo do tipo jogo que esta sendo realizada a movimentacao
*               mov_dtamov - Data do movimento
*               mov_conapo - codigo do concurso que esta sendo realizada a movimentacao
*               mov_seq    - Codigo sequencial relacionando o movimento a aposta realizada
*               mov_autman - Este campo define se a operacao realizada no registro e AUT=Automatica
*                            onde e gerada automaticamente por alguma movimenta automatica do sistema e
*                            MAN=Manual onde a operacao e gerada manualmente por alguma movimentacao
*               mov_apocod - Codigo do Apostador que esta realizando a movimentacao financeira
*               mov_histor - Historico da movimentacao financeira gerada.
*               mov_credeb - Este campo define se a operacao realizada e de CRE=Credito e DEB=Debito
*               mov_valor  - Neste campo e informado o valor da movimentacao
*
*/
STATIC PROCEDURE CheckMovimentacoes( nOption )

LOCAL oErr
LOCAL aStru      := {}
LOCAL cFile      := "finmov01"
LOCAL aIndexes   := {}
LOCAL lStartup   := .not. File( SystemPath() + cFile + ".dbf"  )
LOCAL lIndexFound:= .not. File( SystemPath() + "finmov1a" + ordBagExt() )  .and. ;
                    .not. File( SystemPath() + "finmov1b" + ordBagExt() )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, mov_jogo,   pCHARACTER, 03, 0 )
        ADDFIELD( aStru, mov_dtamov, pDATE,      08, 0 )
        ADDFIELD( aStru, mov_conapo, pCHARACTER, 05, 0 )
        ADDFIELD( aStru, mov_seq,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, mov_autman, pCHARACTER, 03, 0 )
        ADDFIELD( aStru, mov_apocod, pCHARACTER, 06, 0 )
        ADDFIELD( aStru, mov_histor, pCHARACTER, 30, 0 )
        ADDFIELD( aStru, mov_credeb, pCHARACTER, 03, 0 )
        ADDFIELD( aStru, mov_valor,  pNUMERIC,   09, 2 )

        ADDINDEX( aIndexes, finmov1a, FIELD->mov_apocod + DTOS( FIELD->mov_dtamov ) + FIELD->mov_seq )
        ADDINDEX( aIndexes, finmov1b, FIELD->mov_jogo + FIELD->mov_conapo + FIELD->mov_seq + FIELD->mov_apocod)
        // ADDINDEX( aIndexes, finmov1a, FIELD->mov_aposta + DTOS( FIELD->mov_data ) )   		//// teste

        begin sequence with __BreakBlock()

            If lStartup .or. nOption == pSTARTOVER
                dbCreate( SystemPath() + cFile, aStru )
            EndIf

            If lStartup .or. lIndexFound .or. nOption == pREINDEX
                begin sequence with __BreakBlock()
                    dbUseArea( pTRUE, , SystemPath() + cFile, , pTRUE )
                    AEval( aIndexes, { |aIndex| dbCreateIndex( SystemPath() + aIndex[1], aIndex[2], aIndex[3] )} )
                    dbCloseArea()
                recover using oErr
                    If oErr:className() == "ERROR"
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ":" + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + " : " + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( oErr:description )
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == "ERROR"
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ":" + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( oErr:description )
            EndIf
        end sequence

    EndIf

return
