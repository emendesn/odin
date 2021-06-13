/***
*
*  competic.ch
*
***/


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#XTRANSLATE pCOMPETICAO_CAD_CODIGO                      => aCompeticoes\[ 1\]
#XTRANSLATE pCOMPETICAO_CAD_COMPET                      => aCompeticoes\[ 2\]
#XTRANSLATE pCOMPETICAO_CAD_VITORIA                     => aCompeticoes\[ 3\]
#XTRANSLATE pCOMPETICAO_CAD_EMPATE                      => aCompeticoes\[ 4\]

#XTRANSLATE xInitCompeticoes                            =>  (   aCompeticoes := Array(4) )

#XTRANSLATE xStoreCompeticoes                           =>  (   pCOMPETICAO_CAD_CODIGO  := 1,         ;
                                                                pCOMPETICAO_CAD_COMPET  := Space(50), ;
                                                                pCOMPETICAO_CAD_VITORIA := 0,         ;
                                                                pCOMPETICAO_CAD_EMPATE  := 0          ;
                                                            )



/***                                                           
*                                                              
*  Variaveis Manutencao do Cadastro de Grupos de Partidas                
*                                                              
***/                                                           
#XTRANSLATE pGRUPOS_COMPETICAO_CLUBE                    => aGrpClubes\[ 1\]

#XTRANSLATE xInitGrupos                                 =>  (   aGrpClubes := Array(1) )

#XTRANSLATE xStoreGrupos                                =>  (   pGRUPOS_COMPETICAO_CLUBE := Space(1) )



/***
*
*  Variaveis Manutencao do Cadastro de Partidas
*
***/
#DEFINE pCOMPETICAO_PARTIDA_AGENDADO                    'AGN'
#DEFINE pCOMPETICAO_PARTIDA_REALIZADO                   'REA'
#DEFINE pCOMPETICAO_PARTIDA_OPCOES                      {   {'Agendado',  pCOMPETICAO_PARTIDA_AGENDADO  }, ;
                                                            {'Realizado', pCOMPETICAO_PARTIDA_REALIZADO } }

#XTRANSLATE pCOMPETICAO_PARTIDA_STATUS                  => aPartida\[ 1\]
#XTRANSLATE pCOMPETICAO_PARTIDA_DATA                    => aPartida\[ 2\]
#XTRANSLATE pCOMPETICAO_PARTIDA_RODADA                  => aPartida\[ 3\]
#XTRANSLATE pCOMPETICAO_PARTIDA_COLUNA1                 => aPartida\[ 4\]
#XTRANSLATE pCOMPETICAO_PARTIDA_PONTOS1                 => aPartida\[ 5\]
#XTRANSLATE pCOMPETICAO_PARTIDA_COLUNA2                 => aPartida\[ 6\]
#XTRANSLATE pCOMPETICAO_PARTIDA_PONTOS2                 => aPartida\[ 7\]

#XTRANSLATE xInitCompeticoesPartidas                    =>  (   aPartida := Array(7) )

#XTRANSLATE xStoreCompeticoesPartidas                   =>  (   pCOMPETICAO_PARTIDA_STATUS  := Space(3), ;
                                                                pCOMPETICAO_PARTIDA_DATA    := CToD(''), ;
                                                                pCOMPETICAO_PARTIDA_RODADA  := Space(2), ;
                                                                pCOMPETICAO_PARTIDA_COLUNA1 := Space(5), ;
                                                                pCOMPETICAO_PARTIDA_PONTOS1 := 0,        ;
                                                                pCOMPETICAO_PARTIDA_COLUNA2 := Space(5), ;
                                                                pCOMPETICAO_PARTIDA_PONTOS2 := 0         ;
                                                            )