/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  loteca.ch
*
***/

/***
*
*  Contante definindo o numero maximo de combinacoes
*
***/
#DEFINE pLTC_DEF_MAX_COMB                               2391485


/***
*
*  Variaveis para a Entrada de Dados
*
***/
// Constante da estutura Principal
#DEFINE pLTC_POS_CONCURSO                               1
#DEFINE pLTC_POS_SORTEIO                                2
#DEFINE pLTC_POS_DADOS                                  3
#DEFINE pLTC_POS_PREMIACAO                              4

// Constante de estrutura das partidas realizadas
#DEFINE pLTC_POS_DADOS_COLUNA_1                         1
#DEFINE pLTC_POS_DADOS_COLUNA_2                         2
#DEFINE pLTC_POS_DADOS_RESULTADO_1                      3
#DEFINE pLTC_POS_DADOS_RESULTADO_2                      4

// Constante de estrutura da premicao das partidas realizadas
#DEFINE pLTC_POS_PREMIACAO_ACERTO                       1
#DEFINE pLTC_POS_PREMIACAO_PREMIO                       2


// Definicao das estrutura
#XTRANSLATE pLTC_CONCURSO                               => aLoteca\[ pLTC_POS_CONCURSO ]
#XTRANSLATE pLTC_SORTEIO                                => aLoteca\[ pLTC_POS_SORTEIO  ]

// Definicao das estrutura para as partidas
#XTRANSLATE pLTC_PARTIDA_01_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[ 1\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_01_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[ 1\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_01_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[ 1\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_01_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[ 1\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_02_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[ 2\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_02_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[ 2\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_02_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[ 2\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_02_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[ 2\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_03_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[ 3\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_03_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[ 3\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_03_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[ 3\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_03_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[ 3\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_04_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[ 4\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_04_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[ 4\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_04_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[ 4\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_04_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[ 4\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_05_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[ 5\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_05_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[ 5\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_05_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[ 5\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_05_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[ 5\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_06_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[ 6\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_06_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[ 6\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_06_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[ 6\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_06_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[ 6\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_07_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[ 7\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_07_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[ 7\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_07_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[ 7\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_07_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[ 7\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_08_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[ 8\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_08_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[ 8\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_08_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[ 8\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_08_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[ 8\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_09_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[ 9\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_09_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[ 9\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_09_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[ 9\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_09_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[ 9\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_10_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[10\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_10_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[10\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_10_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[10\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_10_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[10\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_11_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[11\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_11_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[11\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_11_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[11\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_11_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[11\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_12_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[12\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_12_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[12\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_12_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[12\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_12_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[12\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_13_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[13\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_13_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[13\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_13_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[13\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_13_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[13\]\[ pLTC_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTC_PARTIDA_14_CLUBE_1                     => aLoteca\[ pLTC_POS_DADOS ]\[14\]\[ pLTC_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTC_PARTIDA_14_CLUBE_2                     => aLoteca\[ pLTC_POS_DADOS ]\[14\]\[ pLTC_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTC_PARTIDA_14_RESULTADO_1                 => aLoteca\[ pLTC_POS_DADOS ]\[14\]\[ pLTC_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTC_PARTIDA_14_RESULTADO_2                 => aLoteca\[ pLTC_POS_DADOS ]\[14\]\[ pLTC_POS_DADOS_RESULTADO_2 ]


// Estrutura de Rateio da Premiacao
#XTRANSLATE pLTC_RATEIO_ACERTO_12                       => aLoteca\[ pLTC_POS_PREMIACAO ]\[ 1\]\[ pLTC_POS_PREMIACAO_ACERTO ]
#XTRANSLATE pLTC_RATEIO_PREMIO_12                       => aLoteca\[ pLTC_POS_PREMIACAO ]\[ 1\]\[ pLTC_POS_PREMIACAO_PREMIO ]

#XTRANSLATE pLTC_RATEIO_ACERTO_13                       => aLoteca\[ pLTC_POS_PREMIACAO ]\[ 2\]\[ pLTC_POS_PREMIACAO_ACERTO ]
#XTRANSLATE pLTC_RATEIO_PREMIO_13                       => aLoteca\[ pLTC_POS_PREMIACAO ]\[ 2\]\[ pLTC_POS_PREMIACAO_ACERTO ]

#XTRANSLATE pLTC_RATEIO_ACERTO_14                       => aLoteca\[ pLTC_POS_PREMIACAO ]\[ 3\]\[ pLTC_POS_PREMIACAO_ACERTO ]
#XTRANSLATE pLTC_RATEIO_PREMIO_14                       => aLoteca\[ pLTC_POS_PREMIACAO ]\[ 3\]\[ pLTC_POS_PREMIACAO_ACERTO ]


// Cria o vetor com a estrutura de dados
#XTRANSLATE xInitLoteca                                 =>  (   aLoteca := {    ,,  {                                           ;
                                                                                        Array(4), Array(4), Array(4), Array(4), ;
                                                                                        Array(4), Array(4), Array(4), Array(4), ;
                                                                                        Array(4), Array(4), Array(4), Array(4), ;
                                                                                        Array(4), Array(4),                     ;
                                                                                    },                                          ;
                                                                                    {                                           ;
                                                                                        Array(2), Array(2), Array(2)            ;
                                                                                    }                                           ;
                                                                            }                                                   ;
                                                            )


// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreLoteca                                =>  (   pLTC_CONCURSO   := Space(5),                                    ;
                                                                pLTC_SORTEIO    := CToD(''),                                    ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 1], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 1], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 2], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 2], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 3], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 3], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 4], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 4], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 5], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 5], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 6], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 6], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 7], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 7], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 8], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 8], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 9], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[ 9], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[10], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[10], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[11], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[11], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[12], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[12], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[13], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[13], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[14], Space(5), 1, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_DADOS ]\[14], 0,        3, 2 ),       ;
                                                                AFill( aLoteca\[ pLTC_POS_PREMIACAO ]\[ 1], 0 ),                ;
                                                                AFill( aLoteca\[ pLTC_POS_PREMIACAO ]\[ 2], 0 ),                ;
                                                                AFill( aLoteca\[ pLTC_POS_PREMIACAO ]\[ 3], 0 )                 ;
                                                            )




/***
*
*	Constantes para a Entrada de Dados para a montagem dos jogos utilizado nas seguintes rotinas
*
*   ==> [ Combina() ]
*   ==> [ Aleatoria() ]
*
*/
#DEFINE pLTC_POS_APOSTA_OPCAO                           1
#DEFINE pLTC_POS_APOSTA_QUANTIDADE_JOGOS                2
#DEFINE pLTC_POS_APOSTA_DUPLO                           3
#DEFINE pLTC_POS_APOSTA_TRIPLO                          4
#DEFINE pLTC_POS_APOSTA_DADOS                           5

// Constante de estrutura das partidas realizadas
#DEFINE pLTC_POS_APOSTA_DADOS_COLUNA_1                  1
#DEFINE pLTC_POS_APOSTA_DADOS_COLUNA_2                  2

// Definicao das estrutura
#XTRANSLATE pLTC_APOSTA_OPCAO                           => aLoteca\[ pLTC_POS_APOSTA_OPCAO ]
#XTRANSLATE pLTC_APOSTA_QUANTIDADE_JOGOS                => aLoteca\[ pLTC_POS_APOSTA_QUANTIDADE_JOGOS ]
#XTRANSLATE pLTC_APOSTA_DUPLO                           => aLoteca\[ pLTC_POS_APOSTA_DUPLO ]
#XTRANSLATE pLTC_APOSTA_TRIPLO                          => aLoteca\[ pLTC_POS_APOSTA_TRIPLO ]

#XTRANSLATE pLTC_APOSTA_01_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 1\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_01_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 1\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_02_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 2\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_02_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 2\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_03_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 3\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_03_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 3\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_04_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 4\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_04_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 4\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_05_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 5\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_05_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 5\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_06_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 6\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_06_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 6\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_07_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 7\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_07_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 7\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_08_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 8\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_08_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 8\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_09_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 9\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_09_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 9\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_10_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[10\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_10_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[10\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_11_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[11\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_11_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[11\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_12_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[12\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_12_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[12\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_13_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[13\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_13_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[13\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

#XTRANSLATE pLTC_APOSTA_14_CLUBE_1                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[14\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_1 ]
#XTRANSLATE pLTC_APOSTA_14_CLUBE_2                      => aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[14\]\[ pLTC_POS_APOSTA_DADOS_COLUNA_2 ]

// Cria o vetor com a estrutura de dados
#XTRANSLATE xInitMontaLoteca                            =>  (   aLoteca := {    ,,,,{                                           ;
                                                                                        Array(2), Array(2), Array(2), Array(2), ;
                                                                                        Array(2), Array(2), Array(2), Array(2), ;
                                                                                        Array(2), Array(2), Array(2), Array(2), ;
                                                                                        Array(2), Array(2)                      ;
                                                                                    }                                           ;
                                                                            }                                                   ;
                                                            )

// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreMontaLoteca                           =>  (   pLTC_APOSTA_OPCAO            := 1,                              ;
                                                                pLTC_APOSTA_QUANTIDADE_JOGOS := 1,                              ;
                                                                pLTC_APOSTA_DUPLO            := 1,                              ;
                                                                pLTC_APOSTA_TRIPLO           := 0,                              ;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 1], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 2], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 3], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 4], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 5], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 6], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 7], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 8], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[ 9], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[10], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[11], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[12], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[13], Space(5), 1, 2 ),;
                                                                AFill( aLoteca\[ pLTC_POS_APOSTA_DADOS ]\[14], Space(5), 1, 2 ) ;
                                                            )


/***
*
*  Constante para a montagem do cartao para as apostas aleatorias
*
***/
#XTRANSLATE xLTCMontCartao( <array> )                   => ( <array> := { {}, {} }, ;
                                                                        AEval( aLoteca\[ pLTC_POS_DADOS ], ;
                                                                        { |xItem| AAdd( <array>\[1],{   xItem\[1],              ;  // Clube 1
                                                                                                        xItem\[2]               ; // Clube 2
                                                                                                    } ) } ) )  