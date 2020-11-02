/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  lotogol.ch
*
***/


/***
*
*  Variaveis para a Entrada de Dados
*
***/
// Constante da estutura Principal
#DEFINE pLTG_POS_CONCURSO                               1
#DEFINE pLTG_POS_SORTEIO                                2
#DEFINE pLTG_POS_DADOS                                  3
#DEFINE pLTG_POS_PREMIACAO                              4

// Constante de estrutura das partidas realizadas
#DEFINE pLTG_POS_DADOS_COLUNA_1                         1
#DEFINE pLTG_POS_DADOS_COLUNA_2                         2
#DEFINE pLTG_POS_DADOS_RESULTADO_1                      3
#DEFINE pLTG_POS_DADOS_RESULTADO_2                      4

// Constante de estrutura da premicao das partidas realizadas
#DEFINE pLTG_POS_PREMIACAO_ACERTO                       1
#DEFINE pLTG_POS_PREMIACAO_PREMIO                       2


// Definicao das estrutura
#XTRANSLATE pLTG_CONCURSO                               => aLotogol\[ pLTG_POS_CONCURSO ]
#XTRANSLATE pLTG_SORTEIO                                => aLotogol\[ pLTG_POS_SORTEIO  ]

// Definicao das estrutura para as partidas
#XTRANSLATE pLTG_PARTIDA_01_CLUBE_1                     => aLotogol\[ pLTG_POS_DADOS ]\[ 1\]\[ pLTG_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTG_PARTIDA_01_CLUBE_2                     => aLotogol\[ pLTG_POS_DADOS ]\[ 1\]\[ pLTG_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTG_PARTIDA_01_RESULTADO_1                 => aLotogol\[ pLTG_POS_DADOS ]\[ 1\]\[ pLTG_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTG_PARTIDA_01_RESULTADO_2                 => aLotogol\[ pLTG_POS_DADOS ]\[ 1\]\[ pLTG_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTG_PARTIDA_02_CLUBE_1                     => aLotogol\[ pLTG_POS_DADOS ]\[ 2\]\[ pLTG_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTG_PARTIDA_02_CLUBE_2                     => aLotogol\[ pLTG_POS_DADOS ]\[ 2\]\[ pLTG_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTG_PARTIDA_02_RESULTADO_1                 => aLotogol\[ pLTG_POS_DADOS ]\[ 2\]\[ pLTG_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTG_PARTIDA_02_RESULTADO_2                 => aLotogol\[ pLTG_POS_DADOS ]\[ 2\]\[ pLTG_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTG_PARTIDA_03_CLUBE_1                     => aLotogol\[ pLTG_POS_DADOS ]\[ 3\]\[ pLTG_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTG_PARTIDA_03_CLUBE_2                     => aLotogol\[ pLTG_POS_DADOS ]\[ 3\]\[ pLTG_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTG_PARTIDA_03_RESULTADO_1                 => aLotogol\[ pLTG_POS_DADOS ]\[ 3\]\[ pLTG_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTG_PARTIDA_03_RESULTADO_2                 => aLotogol\[ pLTG_POS_DADOS ]\[ 3\]\[ pLTG_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTG_PARTIDA_04_CLUBE_1                     => aLotogol\[ pLTG_POS_DADOS ]\[ 4\]\[ pLTG_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTG_PARTIDA_04_CLUBE_2                     => aLotogol\[ pLTG_POS_DADOS ]\[ 4\]\[ pLTG_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTG_PARTIDA_04_RESULTADO_1                 => aLotogol\[ pLTG_POS_DADOS ]\[ 4\]\[ pLTG_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTG_PARTIDA_04_RESULTADO_2                 => aLotogol\[ pLTG_POS_DADOS ]\[ 4\]\[ pLTG_POS_DADOS_RESULTADO_2 ]

#XTRANSLATE pLTG_PARTIDA_05_CLUBE_1                     => aLotogol\[ pLTG_POS_DADOS ]\[ 5\]\[ pLTG_POS_DADOS_COLUNA_1    ]
#XTRANSLATE pLTG_PARTIDA_05_CLUBE_2                     => aLotogol\[ pLTG_POS_DADOS ]\[ 5\]\[ pLTG_POS_DADOS_COLUNA_2    ]
#XTRANSLATE pLTG_PARTIDA_05_RESULTADO_1                 => aLotogol\[ pLTG_POS_DADOS ]\[ 5\]\[ pLTG_POS_DADOS_RESULTADO_1 ]
#XTRANSLATE pLTG_PARTIDA_05_RESULTADO_2                 => aLotogol\[ pLTG_POS_DADOS ]\[ 5\]\[ pLTG_POS_DADOS_RESULTADO_2 ]


// Estrutura de Rateio da Premiacao
#XTRANSLATE pLTG_RATEIO_ACERTO_03                       => aLotogol\[ pLTG_POS_PREMIACAO ]\[ 1\]\[ pLTG_POS_PREMIACAO_ACERTO ]
#XTRANSLATE pLTG_RATEIO_PREMIO_03                       => aLotogol\[ pLTG_POS_PREMIACAO ]\[ 1\]\[ pLTG_POS_PREMIACAO_PREMIO ]

#XTRANSLATE pLTG_RATEIO_ACERTO_04                       => aLotogol\[ pLTG_POS_PREMIACAO ]\[ 2\]\[ pLTG_POS_PREMIACAO_ACERTO ]
#XTRANSLATE pLTG_RATEIO_PREMIO_04                       => aLotogol\[ pLTG_POS_PREMIACAO ]\[ 2\]\[ pLTG_POS_PREMIACAO_ACERTO ]

#XTRANSLATE pLTG_RATEIO_ACERTO_05                       => aLotogol\[ pLTG_POS_PREMIACAO ]\[ 3\]\[ pLTG_POS_PREMIACAO_ACERTO ]
#XTRANSLATE pLTG_RATEIO_PREMIO_05                       => aLotogol\[ pLTG_POS_PREMIACAO ]\[ 3\]\[ pLTG_POS_PREMIACAO_ACERTO ]


// Cria o vetor com a estrutura de dados
#XTRANSLATE xInitLotogol                                =>  (   aLotogol := {    ,,  {                                           ;
                                                                                        Array(4), Array(4), Array(4), Array(4), ;
                                                                                        Array(4)                                ;
                                                                                    },                                          ;
                                                                                    {                                           ;
                                                                                        Array(2), Array(2), Array(2)            ;
                                                                                    }                                           ;
                                                                            }                                                   ;
                                                            )


// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreLotogol                               =>  (   pLTG_CONCURSO   := Space(5),                                    ;
                                                                pLTG_SORTEIO    := CToD(''),                                    ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 1], Space(5), 1, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 1], 0,        3, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 2], Space(5), 1, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 2], 0,        3, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 3], Space(5), 1, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 3], 0,        3, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 4], Space(5), 1, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 4], 0,        3, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 5], Space(5), 1, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_DADOS ]\[ 5], 0,        3, 2 ),      ;
                                                                AFill( aLotogol\[ pLTG_POS_PREMIACAO ]\[ 1], 0 ),               ;
                                                                AFill( aLotogol\[ pLTG_POS_PREMIACAO ]\[ 2], 0 ),               ;
                                                                AFill( aLotogol\[ pLTG_POS_PREMIACAO ]\[ 3], 0 )                ;
                                                            )


/***
*
*  Funcao para o tratamento de Leitura e Gravacao dos campos AP2_PON1 e AP2_PON2.
*
***/

#XTRANSLATE pxLTGRead( <nValor> )                       => ( <nValor> + 1 )
#XTRANSLATE pxLTGWrite( <nValor> )                      => ( <nValor> - 1 )