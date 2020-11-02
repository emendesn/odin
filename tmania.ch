/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  tmania.ch
*
***/


/***
*
*  Numero minimo e maximo de dezenas por jogo
*
***/
#DEFINE pTIM_DEF_MIN_DEZENAS                            10
#DEFINE pTIM_DEF_MAX_DEZENAS                            10


/***
*
*  Contante definindo o numero maximo de combinacoes
*
***/
#DEFINE pTIM_DEF_MAX_COMB                               1646492110120


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#DEFINE pTIM_POS_CONCURSO                               1
#DEFINE pTIM_POS_SORTEIO                                2
#DEFINE pTIM_POS_CORACAO                                3
#DEFINE pTIM_POS_DADOS                                  4

#DEFINE pTIM_POS_DEZENAS                                1
#DEFINE pTIM_POS_ACER_03                                2
#DEFINE pTIM_POS_ACER_04                                3
#DEFINE pTIM_POS_ACER_05                                4
#DEFINE pTIM_POS_ACER_06                                5
#DEFINE pTIM_POS_ACER_07                                6
#DEFINE pTIM_POS_ACER_CORACAO                           7



#XTRANSLATE pTIM_CONCURSO                               => aTimeMania\[ pTIM_POS_CONCURSO ]
#XTRANSLATE pTIM_SORTEIO                                => aTimeMania\[ pTIM_POS_SORTEIO  ]
#XTRANSLATE pTIM_CORACAO                                => aTimeMania\[ pTIM_POS_CORACAO  ]

#XTRANSLATE pTIM_DEZENA_01                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_DEZENAS ]\[ 1\]
#XTRANSLATE pTIM_DEZENA_02                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_DEZENAS ]\[ 2\]
#XTRANSLATE pTIM_DEZENA_03                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_DEZENAS ]\[ 3\]
#XTRANSLATE pTIM_DEZENA_04                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_DEZENAS ]\[ 4\]
#XTRANSLATE pTIM_DEZENA_05                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_DEZENAS ]\[ 5\]
#XTRANSLATE pTIM_DEZENA_06                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_DEZENAS ]\[ 6\]
#XTRANSLATE pTIM_DEZENA_07                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_DEZENAS ]\[ 7\]

#XTRANSLATE pTIM_ACERTO_03                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_03 ]\[ 1\]
#XTRANSLATE pTIM_PREMIO_03                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_03 ]\[ 2\]

#XTRANSLATE pTIM_ACERTO_04                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_04 ]\[ 1\]
#XTRANSLATE pTIM_PREMIO_04                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_04 ]\[ 2\]

#XTRANSLATE pTIM_ACERTO_05                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_05 ]\[ 1\]
#XTRANSLATE pTIM_PREMIO_05                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_05 ]\[ 2\]

#XTRANSLATE pTIM_ACERTO_06                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_06 ]\[ 1\]
#XTRANSLATE pTIM_PREMIO_06                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_06 ]\[ 2\]

#XTRANSLATE pTIM_ACERTO_07                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_07 ]\[ 1\]
#XTRANSLATE pTIM_PREMIO_07                              => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_07 ]\[ 2\]

#XTRANSLATE pTIM_ACERTO_CORACAO                         => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_CORACAO ]\[ 1\]
#XTRANSLATE pTIM_PREMIO_CORACAO                         => aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_CORACAO ]\[ 2\]


#XTRANSLATE xInitTimeMania                              =>  ( aTimeMania := {   ,,, {   Array(7), Array(2), Array(2), Array(2),  ;
                                                                                        Array(2), Array(2), Array(2), Array(2)   ;
                                                                                    }                                            ;
                                                                            }                                                    ;
                                                            )

// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreTimeMania                             =>  (   pTIM_CONCURSO     := Space(5),                                         ;
                                                                pTIM_SORTEIO      := CToD(''),                                         ;
                                                                pTIM_CORACAO      := Space(1),                                         ;
                                                                AFill( aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_DEZENAS ], Space(2) ), ;
                                                                AFill( aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_03 ], 0        ), ;
                                                                AFill( aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_04 ], 0        ), ;
                                                                AFill( aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_05 ], 0        ), ;
                                                                AFill( aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_06 ], 0        ), ;
                                                                AFill( aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_07 ], 0        ), ;
                                                                AFill( aTimeMania\[ pTIM_POS_DADOS ]\[ pTIM_POS_ACER_CORACAO ], 0 )    ;
                                                            )

/***
*
*  Verifica a duplicidade de dezenas digitadas.
*
***/
#xTRANSLATE xDuplicSequencia(<aSequencia>)              =>  (   ( xCount := 0, xTemp := {},                                                          ;
                                                                    AEval(  <aSequencia>,                                                            ;
                                                                        { |xDez| iif( hb_AScan( xTemp, xDez ) == 0, AAdd( xTemp, xDez ), xCount++ )});
                                                                ),                                                                                   ;
                                                                iif( xCount == 0, .T., .F. )                                                         ;
                                                            )

/***
*
*  Estas funções tem por finalidade verificar as dezenas digitadas estao entre as dezenas do Jogo
*
***/
#xTRANSLATE xVerificaSequencia(<aSequencia>, <aStru>)   =>  (   ( xCount := 0,                                                                       ;
                                                                    AEval( <aSequencia>,                                                             ;
                                                                        { |xDez| xCount += iif( hb_AScan( <aStru>, xDez ) == 0, 1, 0 ) } )           ;
                                                                ),                                                                                   ;
                                                                iif( xCount == 0, .T., .F. )                                                         ;
                                                            )

