/***
*
*  aposta.ch
*
***/


/***
*
*  Variaveis para a Entrada de Dados das apostas
*
***/
#XTRANSLATE pAPOSTA_CAD_JOGO                            => aAposta\[ 1\]
#XTRANSLATE pAPOSTA_CAD_CONCURSO                        => aAposta\[ 2\]
#XTRANSLATE pAPOSTA_CAD_SEQUENCIA                       => aAposta\[ 3\]
#XTRANSLATE pAPOSTA_CAD_SORTEIO                         => aAposta\[ 4\]
#XTRANSLATE pAPOSTA_CAD_ORIGEM                          => aAposta\[ 5\]
#XTRANSLATE pAPOSTA_CAD_HISTORICO                       => aAposta\[ 6\]

#XTRANSLATE xInitAposta                                 =>  (   aAposta := Array(6) )

#XTRANSLATE xStoreAposta                                =>  (   pAPOSTA_CAD_JOGO      := Space(3), ;
                                                                pAPOSTA_CAD_CONCURSO  := Space(5), ;
                                                                pAPOSTA_CAD_SEQUENCIA := 1,        ;
                                                                pAPOSTA_CAD_SORTEIO   := CToD(''), ;
                                                                pAPOSTA_CAD_ORIGEM    := Space(3), ;
                                                                pAPOSTA_CAD_HISTORICO := Space(40) ;
                                                            )



/***                                                           
*                                                              
*  Contante para definir a origem da aposta
*                                                              
***/                                                           
#DEFINE pAPOSTA_ORIGEM_USUARIO                          'USR'
#DEFINE pAPOSTA_ORIGEM_SISTEMA                          'SIS'



/***
*
*  Variaveis para a Entrada de Dados dos grupos das apostas
*
***/
#XTRANSLATE pAPOSTA_GRP_JOGO                            => aApostaGrupos\[ 1\]
#XTRANSLATE pAPOSTA_GRP_CONCURSO                        => aApostaGrupos\[ 2\]
#XTRANSLATE pAPOSTA_GRP_SEQUENCIA                       => aApostaGrupos\[ 3\]
#XTRANSLATE pAPOSTA_GRP_APOSTADOR                       => aApostaGrupos\[ 4\]
#XTRANSLATE pAPOSTA_GRP_VALOR                           => aApostaGrupos\[ 5\]

#XTRANSLATE xInitApostaGrupos                           =>  (   aApostaGrupos := Array(5) )

#XTRANSLATE xStoreApostaGrupos                          =>  (   pAPOSTA_GRP_JOGO      := Space(3), ;
                                                                pAPOSTA_GRP_CONCURSO  := Space(5), ;
                                                                pAPOSTA_GRP_SEQUENCIA := 1,        ;
                                                                pAPOSTA_GRP_APOSTADOR := Space(5), ;
                                                                pAPOSTA_GRP_VALOR     := 0         ;
                                                            )


/***
*
*  Variaveis para a Entrada de Dados do cartao de jogos da LOTECA
*
***/
#DEFINE pLTC_POS_DADOS                                  7

#XTRANSLATE pLTC_APOSTA_ITEM_JOGO                       => aCartao\[ 1\]
#XTRANSLATE pLTC_APOSTA_ITEM_CONCURSO                   => aCartao\[ 2\]
#XTRANSLATE pLTC_APOSTA_ITEM_SEQUENCIA                  => aCartao\[ 3\]
#XTRANSLATE pLTC_APOSTA_ITEM_ITEM                       => aCartao\[ 4\]
#XTRANSLATE pLTC_APOSTA_ITEM_SORTEIO                    => aCartao\[ 5\]
#XTRANSLATE pLTC_APOSTA_ITEM_VALOR                      => aCartao\[ 6\]

#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_01             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[ 1\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_02             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[ 2\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_03             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[ 3\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_04             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[ 4\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_05             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[ 5\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_06             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[ 6\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_07             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[ 7\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_08             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[ 8\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_09             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[ 9\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_10             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[10\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_11             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[11\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_12             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[12\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_13             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[13\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_1_14             => aCartao\[ pLTC_POS_DADOS ]\[ 1\]\[14\]

#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_01             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[ 1\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_02             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[ 2\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_03             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[ 3\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_04             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[ 4\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_05             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[ 5\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_06             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[ 6\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_07             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[ 7\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_08             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[ 8\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_09             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[ 9\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_10             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[10\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_11             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[11\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_12             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[12\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_13             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[13\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_COL_2_14             => aCartao\[ pLTC_POS_DADOS ]\[ 2\]\[14\]

#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_01          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[ 1\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_02          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[ 2\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_03          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[ 3\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_04          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[ 4\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_05          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[ 5\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_06          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[ 6\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_07          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[ 7\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_08          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[ 8\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_09          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[ 9\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_10          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[10\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_11          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[11\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_12          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[12\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_13          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[13\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_1_14          => aCartao\[ pLTC_POS_DADOS ]\[ 3\]\[14\]

#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_01          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[ 1\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_02          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[ 2\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_03          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[ 3\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_04          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[ 4\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_05          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[ 5\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_06          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[ 6\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_07          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[ 7\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_08          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[ 8\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_09          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[ 9\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_10          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[10\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_11          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[11\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_12          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[12\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_13          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[13\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_2_14          => aCartao\[ pLTC_POS_DADOS ]\[ 4\]\[14\]

#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_01          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[ 1\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_02          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[ 2\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_03          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[ 3\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_04          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[ 4\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_05          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[ 5\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_06          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[ 6\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_07          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[ 7\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_08          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[ 8\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_09          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[ 9\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_10          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[10\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_11          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[11\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_12          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[12\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_13          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[13\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_RESULT_3_14          => aCartao\[ pLTC_POS_DADOS ]\[ 5\]\[14\]

#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_01             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[ 1\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_02             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[ 2\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_03             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[ 3\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_04             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[ 4\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_05             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[ 5\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_06             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[ 6\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_07             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[ 7\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_08             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[ 8\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_09             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[ 9\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_10             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[10\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_11             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[11\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_12             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[12\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_13             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[13\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_DUPLO_14             => aCartao\[ pLTC_POS_DADOS ]\[ 6\]\[14\]

#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_01            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[ 1\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_02            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[ 2\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_03            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[ 3\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_04            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[ 4\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_05            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[ 5\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_06            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[ 6\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_07            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[ 7\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_08            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[ 8\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_09            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[ 9\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_10            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[10\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_11            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[11\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_12            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[12\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_13            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[13\]
#XTRANSLATE pLTC_APOSTA_ITEM_CLUBE_TRIPLO_14            => aCartao\[ pLTC_POS_DADOS ]\[ 7\]\[14\]


#XTRANSLATE xInitApostaLoteca                           =>  (   aCartao :=  {   ,,,,,,  {   Array(14), Array(14),  ;
                                                                                            Array(14), Array(14),  ;
                                                                                            Array(14), Array(14),  ;
                                                                                            Array(14)              ;
                                                                                        } ;
                                                                            } ;
                                                            )

#XTRANSLATE xStoreApostaLoteca                          =>  (   pLTC_APOSTA_ITEM_JOGO      := Space(3),            ;
                                                                pLTC_APOSTA_ITEM_CONCURSO  := Space(5),            ;
                                                                pLTC_APOSTA_ITEM_SEQUENCIA := Space(3),            ;
                                                                pLTC_APOSTA_ITEM_ITEM      := 1,                   ;
                                                                pLTC_APOSTA_ITEM_SORTEIO   := CToD(''),            ;
                                                                pLTC_APOSTA_ITEM_VALOR     := 0,                   ;
                                                                AFill( aCartao\[ pLTC_POS_DADOS ]\[1], Space(5) ), ;
                                                                AFill( aCartao\[ pLTC_POS_DADOS ]\[2], Space(5) ), ;
                                                                AFill( aCartao\[ pLTC_POS_DADOS ]\[3], pFALSE ),   ;
                                                                AFill( aCartao\[ pLTC_POS_DADOS ]\[4], pFALSE ),   ;
                                                                AFill( aCartao\[ pLTC_POS_DADOS ]\[5], pFALSE ),   ;
                                                                AFill( aCartao\[ pLTC_POS_DADOS ]\[6], pFALSE ),   ;
                                                                AFill( aCartao\[ pLTC_POS_DADOS ]\[7], pFALSE )    ;
                                                            )

