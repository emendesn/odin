/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  quina.ch
*
***/


/***
*
*  Numero minimo e maximo de dezenas por jogo
*
***/
#DEFINE pQNA_DEF_MIN_DEZENAS                             5
#DEFINE pQNA_DEF_MAX_DEZENAS                            15


/***
*
*  Contante definindo o numero maximo de combinacoes
*
***/
#DEFINE pQNA_DEF_MAX_COMB                               24040016


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#DEFINE pQNA_POS_CONCURSO                               1
#DEFINE pQNA_POS_SORTEIO                                2
#DEFINE pQNA_POS_DADOS                                  3

#DEFINE pQNA_POS_DEZENAS                                1
#DEFINE pQNA_POS_ACER_02                                2
#DEFINE pQNA_POS_ACER_03                                3
#DEFINE pQNA_POS_ACER_04                                4
#DEFINE pQNA_POS_ACER_05                                5



#XTRANSLATE pQNA_CONCURSO                               => aQuina\[ pQNA_POS_CONCURSO ]
#XTRANSLATE pQNA_SORTEIO                                => aQuina\[ pQNA_POS_SORTEIO  ]

#XTRANSLATE pQNA_DEZENA_01                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_DEZENAS ]\[ 1\]
#XTRANSLATE pQNA_DEZENA_02                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_DEZENAS ]\[ 2\]
#XTRANSLATE pQNA_DEZENA_03                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_DEZENAS ]\[ 3\]
#XTRANSLATE pQNA_DEZENA_04                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_DEZENAS ]\[ 4\]
#XTRANSLATE pQNA_DEZENA_05                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_DEZENAS ]\[ 5\]

#XTRANSLATE pQNA_ACERTO_02                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_02 ]\[ 1\]
#XTRANSLATE pQNA_PREMIO_02                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_02 ]\[ 2\]

#XTRANSLATE pQNA_ACERTO_03                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_03 ]\[ 1\]
#XTRANSLATE pQNA_PREMIO_03                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_03 ]\[ 2\]

#XTRANSLATE pQNA_ACERTO_04                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_04 ]\[ 1\]
#XTRANSLATE pQNA_PREMIO_04                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_04 ]\[ 2\]

#XTRANSLATE pQNA_ACERTO_05                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_05 ]\[ 1\]
#XTRANSLATE pQNA_PREMIO_05                              => aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_05 ]\[ 2\]


#XTRANSLATE xInitQuina                                  =>  ( aQuina := {   ,,   {   Array(5), Array(2), Array(2), Array(2), Array(2) ;
                                                                                    }                                                 ;
                                                                            }                                                         ;
                                                            )

// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreQuina                                 =>  (   pQNA_CONCURSO     := Space(5),                                         ;
                                                                pQNA_SORTEIO      := CToD(''),                                         ;
                                                                AFill( aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_DEZENAS ], Space(2) ),     ;
                                                                AFill( aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_02 ], 0        ),     ;
                                                                AFill( aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_03 ], 0        ),     ;
                                                                AFill( aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_04 ], 0        ),     ;
                                                                AFill( aQuina\[ pQNA_POS_DADOS ]\[ pQNA_POS_ACER_05 ], 0 )             ;
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

