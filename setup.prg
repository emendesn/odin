/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

#include 'setcurs.ch'
#include 'common.ch'
#include 'main.ch'
#include 'error.ch'


#ifdef __HARBOUR__
	#define pARRAY     'A'
	#define pBLOCK     'B'
	#define pCHARACTER 'C'
	#define pDATE      'D'
	#define pLOGICAL   'L'
	#define pMEMO      'M'
	#define pNUMERIC   'N'
	#define pOBJECT    'O'

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

#xtranslate odnAlert( <Message> )                               => hb_gtAlert( <Message>, { 'Ok' }, 'W+/R', 'W+/B' )

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
        AAdd( aSystem, { 'arqcon01', 'CONCURSO',        { 'arqcon1a', 'arqcon1b'             }, 'Arquivo de Concursos' } )
        AAdd( aSystem, { 'arqjog02', 'JOGOS',           { 'arqjog2a'                         }, 'Arquivo de Jogos' } )
        AAdd( aSystem, { 'arqrat03', 'RATEIO',          { 'arqrat3a'                         }, 'Arquivo de Rateio' } )
        AAdd( aSystem, { 'cadclu01', 'CLUBES',          { 'cadclu1a', 'cadclu1b', 'cadclu1c' }, 'Cadastro de Clubes' } )
        AAdd( aSystem, { 'cadapo02', 'APOSTADORES',     { 'cadapo2a'                         }, 'Cadastro de Apostadores' } )        
        AAdd( aSystem, { 'apoapt01', 'APOSTAS',         { 'apoapt1a', 'apoapt1b'             }, 'Cabecario do Cadastro de Apostas' } )
        AAdd( aSystem, { 'apoitn02', 'APOSTAS_ITENS',   { 'apoitn2a', 'apoitn2b'             }, 'Itens das Apostas' } )
        AAdd( aSystem, { 'apoclb03', 'APOSTAS_CLUBES',  { 'apoclb3a'                         }, 'Itens com as Apostas da Loteca e da Lotogol' } )		
        AAdd( aSystem, { 'apogrp04', 'APOSTAS_GRUPOS',  { 'apogrp4a', 'apogrp4b'             }, 'Grupo de Apostadores' } )
        AAdd( aSystem, { 'finmov01', 'MOVIMENTOS',      { 'finmov1a', 'finmov1b'             }, 'Arquivos de movimentacoes financeira' } )
        AAdd( aSystem, { 'copcad01', 'COMPETICOES',     { 'copcad1a', 'copcad1b'             }, 'Cadastro de Competicoes' } )
        AAdd( aSystem, { 'copgrp02', 'GRP_COMPETICOES', { 'copgrp2a'                         }, 'Grupo de Clubes disputados na competicao' } )
        AAdd( aSystem, { 'coppar03', 'PARTIDAS',        { 'coppar3a', 'coppar3b'             }, 'Cadastro de Partidas' } )

    EndIf

    CheckConcurso( nOperacao )
    CheckJogos( nOperacao )
    CheckRateio( nOperacao )
    CheckCadClubes( nOperacao )
    CheckCadApostadores( nOperacao )    
    CheckApostas( nOperacao )
    CheckItemApostas( nOperacao )
    CheckClubApostas( nOperacao )	
    CheckGrpApostas( nOperacao )
    CheckMovimentacoes( nOperacao )
    CheckCompeticoes( nOperacao )
    CheckGrpCompeticoes( nOperacao )
    CheckPartidas( nOperacao )

	
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
    CheckCadClubes( pREINDEX )
    CheckCadApostadores( pREINDEX )
    CheckApostas( pREINDEX )
    CheckItemApostas( pREINDEX )
    CheckClubApostas( pREINDEX )		
    CheckGrpApostas( pREINDEX )
    CheckMovimentacoes( pREINDEX )
    CheckCompeticoes( pREINDEX )
    CheckGrpCompeticoes( pREINDEX )    
    CheckPartidas( pREINDEX )

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

    DEFAULT cMessage TO ''

    dbCloseAll()

    for nCounter := 1 to Len( aSystem )

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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_READ .or. oErr:genCode == EG_CORRUPTION .or. oErr:genCode == EG_CORRUPTION
                    odnAlert( oErr:description + ':' + oErr:filename )
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

    DispMessage('')

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
local cFile      := 'arqcon01'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'arqcon1a' + ordBagExt()  ) .and. ;
                    .not. File( SystemPath() + 'arqcon1b' + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
local cFile      := 'arqjog02'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'arqjog2a' + ordBagExt()  )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
local cFile      := 'arqrat03'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'arqrat3a' + ordBagExt()  )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
local cFile      := 'cadclu01'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'cadclu1a' + ordBagExt()  ) .and. ;
                    .not. File( SystemPath() + 'cadclu1b' + ordBagExt()  ) .and. ;
                    .not. File( SystemPath() + 'cadclu1c' + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, clu_codigo,  pCHARACTER,  05, 0 )
        ADDFIELD( aStru, clu_abrevi,  pCHARACTER,  30, 0 )
        ADDFIELD( aStru, clu_nome,    pCHARACTER,  60, 0 )
        ADDFIELD( aStru, clu_uf,      pCHARACTER,  02, 0 )

        ADDINDEX( aIndexes, cadclu1a, FIELD->clu_codigo )
        ADDINDEX( aIndexes, cadclu1b, FIELD->clu_abrevi )
        ADDINDEX( aIndexes, cadclu1c, FIELD->clu_nome )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
*               apo_codigo - Codigo do apostador cadastrado
*               apo_nome   - Nome do Apostador Cadastrado
*               apo_saldo  - Saldo do Apostador Cadastrado
*               apo_premio - Valor da premiacao do apostador obtida na apuracao do concurso
*               apo_gastos - Valor do gasto efetuado na aposta
*
*/
STATIC PROCEDURE CheckCadApostadores( nOption )

local oErr
local aStru      := {}
local cFile      := 'cadapo02'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'cadapo2a' + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, apo_codigo, pCHARACTER, 05, 0 )
        ADDFIELD( aStru, apo_nome,   pCHARACTER, 30, 0 )
        ADDFIELD( aStru, apo_email,  pCHARACTER, 30, 0 )
        ADDFIELD( aStru, apo_saldo,  pNUMERIC,   10, 2 )
        ADDFIELD( aStru, apo_premio, pNUMERIC,   10, 2 )
        ADDFIELD( aStru, apo_gastos, pNUMERIC,   10, 2 )

        ADDINDEX( aIndexes, cadapo2a, FIELD->apo_codigo )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
*               apt_jogo   - Codigo do jogo da aposta realizada
*               apt_concur - Codigo do concurso da aposta realizada
*               apt_sequen - Codigo sequencial no quando realizada mais de uma aposta para o mesmo concurso
*               apt_sortei - Data da realizacao da aposta
*               apt_orig   - Define a origem da aposta, sendo USR (Ususario) e SIS (Sistema)
*               apt_histor - Contem o historio da aposta, sendo gerado automaticamente quando realizada via sistema
*
*/
STATIC PROCEDURE CheckApostas( nOption )

local oErr
local aStru      := {}
local cFile      := 'apoapt01'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'apoapt1a' + ordBagExt()  ) .and. ;
                    .not. File( SystemPath() + 'apoapt1b' + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, apt_jogo,    pCHARACTER,  03, 0 )
        ADDFIELD( aStru, apt_concur,  pCHARACTER,  05, 0 )
        ADDFIELD( aStru, apt_sequen,  pCHARACTER,  03, 0 )
        ADDFIELD( aStru, apt_sortei,  pDATE,       08, 0 )
        ADDFIELD( aStru, apt_orig,    pCHARACTER,  03, 0 )
        ADDFIELD( aStru, apt_histor,  pCHARACTER,  40, 0 )

        ADDINDEX( aIndexes, apoapt1a, FIELD->apt_jogo + FIELD->apt_concur + FIELD->apt_sequen + DToS( FIELD->apt_sortei ) )
        ADDINDEX( aIndexes, apoapt1b, DToS( FIELD->apt_sortei ) + FIELD->apt_jogo + FIELD->apt_concur  + FIELD->apt_sequen )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( 'Funcao: CheckApostas - ' + oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        Elseif oErr:genCode == EG_NOVAR
                            odnAlert( 'Funcao: CheckApostas - ' + oErr:description + ' : ' + oErr:operation )
                            Break(oErr)
                        Else
                            odnAlert( 'Funcao: CheckApostas - ' + oErr:description )
                            Break(oErr)
                        EndIf
                    Else
                        odnAlert( 'Funcao: CheckApostas - ' + oErr:description )
                        Break(oErr)
                    EndIf
                end sequence
            EndIf

        recover using oErr
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( 'Funcao: CheckApostas - ' + oErr:description + ':' + oErr:filename )
                    Break(oErr)
                Else
                    odnAlert( 'Funcao: CheckApostas - ' + oErr:description )
                    Break(oErr)
                EndIf
            Else
                odnAlert( 'Funcao: CheckApostas - ' + oErr:description )
            EndIf
        end sequence

    EndIf

return


/***
*
*	CheckItemApostas( <nOption> ) --> NIL
*
*	Tabela contendo as apostas relacionadas a LOTO FACIL, LOTO MANIA, MEGA SENA, QUINA e TIME MANIA
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               itn_jogo   - Codigo do tipo jogo que sera realizada a aposta
*               itn_concur - Codigo do concurso que sera realizada a aposta
*               itn_sequen - Codigo sequencial da aposta cadastrada
*               itn_item   - Codigo sequencial onde permite que seja cadastrado mais
*                            apostas por concurso
*               itn_dezena - Dezenas relacionada a aposta cadastrada
*               itn_valor  - Valor da aposta realizada
*               itn_tim_co - Codigo do clube da aposta realizada 
*                            Especifico para TIME MANIA
*               itn_dds_me - Codigo do mes de sorte da aposta realizada 
*                            Especifico para DIA DE SORTE

*
*/
STATIC PROCEDURE CheckItemApostas( nOption )

local oErr
local aStru      := {}
local cFile      := 'apoitn02'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'apoitn2a' + ordBagExt()  ) .and. ;
                    .not. File( SystemPath() + 'apoitn2b' + ordBagExt()  )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, itn_jogo,    pCHARACTER,  03, 0 )
        ADDFIELD( aStru, itn_concur,  pCHARACTER,  05, 0 )
        ADDFIELD( aStru, itn_sequen,  pCHARACTER,  03, 0 )
        ADDFIELD( aStru, itn_item,    pCHARACTER,  03, 0 )
        ADDFIELD( aStru, itn_dezena,  pCHARACTER, 149, 0 )
        ADDFIELD( aStru, itn_valor,   pNUMERIC,    13, 2 )
        ADDFIELD( aStru, itn_tim_co,  pCHARACTER,  05, 0 )
        ADDFIELD( aStru, itn_dds_me,  pCHARACTER,  02, 0 )

        ADDINDEX( aIndexes, apoitn2a, FIELD->itn_jogo + FIELD->itn_concur + FIELD->itn_sequen + FIELD->itn_item )
        ADDINDEX( aIndexes, apoitn2b, FIELD->itn_jogo + FIELD->itn_item + FIELD->itn_concur )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
*               clb_concur - Codigo do concurso que sera realizada a aposta
*               clb_sequen - Codigo sequencial da aposta cadastrada
*               clb_item   - Codigo sequencial onde permite que seja cadastrado mais
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
local cFile      := 'apoclb03'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'apoclb3a' + ordBagExt() )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, clb_jogo,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, clb_concur,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, clb_sequen,  pCHARACTER, 03, 0 )		
        ADDFIELD( aStru, clb_item,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, clb_faixa,   pCHARACTER, 02, 0 )
        ADDFIELD( aStru, clb_col1,    pCHARACTER, 05, 0 )
        ADDFIELD( aStru, clb_col2,    pCHARACTER, 05, 0 )
        ADDFIELD( aStru, clb_result,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, clb_pon1,    pNUMERIC,   01, 0 )
        ADDFIELD( aStru, clb_pon2,    pNUMERIC,   01, 0 )
        ADDFIELD( aStru, clb_dezena,  pCHARACTER, 17, 0 )

        ADDINDEX( aIndexes, apoclb3a, FIELD->clb_jogo + FIELD->clb_concur + FIELD->clb_sequen + FIELD->clb_item + FIELD->clb_faixa )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
*	CheckGrpApostas( <nOption> ) --> NIL
*
*	Tabela contendo o grupo de apostadores
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               grp_jogo   - Codigo do tipo jogo que sera realizada a aposta
*               grp_concur - Codigo do concurso que sera realizada a aposta
*               grp_sequen - Codigo sequencial onde permite que seja cadastrado mais
*                            apostas por concurso
*               grp_apocod - Codigo do Apostador
*               grp_valor  - Valor da aposta
*
*/
STATIC PROCEDURE CheckGrpApostas( nOption )

local oErr
local aStru      := {}
local cFile      := 'apogrp04'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'apogrp4a' + ordBagExt() ) .and. ;
                    .not. File( SystemPath() + 'apogrp4b' + ordBagExt() )


    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, grp_jogo,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, grp_concur,  pCHARACTER, 05, 0 )
        ADDFIELD( aStru, grp_sequen,  pCHARACTER, 03, 0 )
        ADDFIELD( aStru, grp_apocod,  pCHARACTER, 06, 0 )
        ADDFIELD( aStru, grp_valor,   pNUMERIC,   09, 2 )

        ADDINDEX( aIndexes, apogrp4a, FIELD->grp_jogo + FIELD->grp_concur + FIELD->grp_sequen + FIELD->grp_apocod )
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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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

local oErr
local aStru      := {}
local cFile      := 'finmov01'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'finmov1a' + ordBagExt() )  .and. ;
                    .not. File( SystemPath() + 'finmov1b' + ordBagExt() )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, mov_jogo,   pCHARACTER, 03, 0 )
        ADDFIELD( aStru, mov_dtamov, pDATE,      08, 0 )
        ADDFIELD( aStru, mov_conapo, pCHARACTER, 05, 0 )
        ADDFIELD( aStru, mov_seq,    pCHARACTER, 03, 0 )
        ADDFIELD( aStru, mov_autman, pCHARACTER, 03, 0 )
        ADDFIELD( aStru, mov_apocod, pCHARACTER, 06, 0 )
        ADDFIELD( aStru, mov_histor, pCHARACTER, 40, 0 )
        ADDFIELD( aStru, mov_credeb, pCHARACTER, 03, 0 )
        ADDFIELD( aStru, mov_valor,  pNUMERIC,   09, 2 )

        ADDINDEX( aIndexes, finmov1a, FIELD->mov_apocod + DToS( FIELD->mov_dtamov ) + FIELD->mov_seq )
        ADDINDEX( aIndexes, finmov1b, FIELD->mov_jogo + FIELD->mov_conapo + FIELD->mov_seq + FIELD->mov_apocod)
        // ADDINDEX( aIndexes, finmov1a, FIELD->mov_aposta + DToS( FIELD->mov_data ) )   		//// teste

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
*	CheckCompeticoes( <nOption> ) --> NIL
*
*	Tabela contendo as competicoes
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               com_codigo - Codigo sequencial da competicoes
*               com_compet - Nome da competicao
*               com_vitori - Pontuacao em caso de vitoria
*               com_empate - Pontuacao em caso de empate
*
*/
STATIC PROCEDURE CheckCompeticoes( nOption )

local oErr
local aStru      := {}
local cFile      := 'copcad01'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'copcad1a' + ordBagExt() )  .and. ;
                    .not. File( SystemPath() + 'copcad1b' + ordBagExt() )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, com_codigo, pCHARACTER, 05, 0 )
        ADDFIELD( aStru, com_compet, pCHARACTER, 50, 0 )
        ADDFIELD( aStru, com_vitori, pNUMERIC,   02, 0 )
        ADDFIELD( aStru, com_empate, pNUMERIC,   02, 0 )

        ADDINDEX( aIndexes, copcad1a, FIELD->com_codigo )
        ADDINDEX( aIndexes, copcad1b, Descend( FIELD->com_codigo ) )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
*	CheckGrpCompeticoes( <nOption> ) --> NIL
*
*	Tabela contendo os clubes que compoem a competicao
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               grp_codigo - Codigo da competicao
*               grp_clube  - Codigos dos clubes que compoe a partida
*
*/
STATIC PROCEDURE CheckGrpCompeticoes( nOption )

local oErr
local aStru       := {}
local cFile       := 'copgrp02'
local aIndexes    := {}
local lStartup    := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound := .not. File( SystemPath() + 'copgrp2a' + ordBagExt() )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

        ADDFIELD( aStru, grp_codigo, pCHARACTER,  05, 0 )
        ADDFIELD( aStru, grp_clube,  pCHARACTER,  05, 0 )
        
        ADDINDEX( aIndexes, copgrp2a, FIELD->grp_codigo + FIELD->grp_clube )

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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
*	CheckPartidas( <nOption> ) --> NIL
*
*	Tabela contendo as partidas da competicao
*
*	Parametros:
*               <nOption>  - 1 -> Reseta todas as tabelas de dados
*               <nOption>  - 2 -> Reindexa os arquivos
*
*	Estrutura:
*               par_codigo - Codigo sequencial das partidas
*               par_status - Nome da competicao
*               par_data - Pontuacao em caso de vitoria
*               par_rodada - Pontuacao em caso de empate
*               par_col1 - Pontuacao em caso de empate
*               par_pont1 - Pontuacao em caso de empate
*               par_col2 - Pontuacao em caso de empate
*               par_pont2 - Pontuacao em caso de empate
*
*/
STATIC PROCEDURE CheckPartidas( nOption )

local oErr
local aStru      := {}
local cFile      := 'coppar03'
local aIndexes   := {}
local lStartup   := .not. File( SystemPath() + cFile + '.dbf'  )
local lIndexFound:= .not. File( SystemPath() + 'coppar3a' + ordBagExt() )  .and. ;
                    .not. File( SystemPath() + 'coppar3b' + ordBagExt() )

    If lStartup .or. lIndexFound .or. .not. Empty( nOption )

		ADDFIELD( aStru, par_codigo, pCHARACTER,  05, 0 )
		ADDFIELD( aStru, par_status, pCHARACTER,  03, 0 )
		ADDFIELD( aStru, par_data,   pDATE,       08, 0 )
		ADDFIELD( aStru, par_rodada, pCHARACTER,  02, 0 )		
		ADDFIELD( aStru, par_col1,   pCHARACTER,  05, 0 )
		ADDFIELD( aStru, par_pont1,  pNUMERIC,    02, 0 )
		ADDFIELD( aStru, par_col2,   pCHARACTER,  05, 0 )
		ADDFIELD( aStru, par_pont2,  pNUMERIC,    02, 0 )
		
		ADDINDEX( aIndexes, coppar3a, FIELD->par_codigo + FIELD->par_rodada + DToS( FIELD->par_data ) )
		ADDINDEX( aIndexes, coppar3b, FIELD->par_codigo + FIELD->par_status + FIELD->par_rodada + DToS( FIELD->par_data ) )		

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
                    If oErr:className() == 'ERROR'
                        If oErr:genCode == EG_CREATE
                            odnAlert( oErr:description + ':' + oErr:filename )
                            Break(oErr)
                        ElseIf oErr:genCode == EG_NOVAR
                            odnAlert( oErr:description + ' : ' + oErr:operation )
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
            If oErr:className() == 'ERROR'
                If oErr:genCode == EG_CREATE
                    odnAlert( oErr:description + ':' + oErr:filename )
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


