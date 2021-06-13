/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  dsena.ch
*
***/


/***
*
*  Numero minimo e maximo de dezenas por jogo
*
***/
#DEFINE pDSA_DEF_MIN_DEZENAS                             6
#DEFINE pDSA_DEF_MAX_DEZENAS                            15


/***
*
*  Numero maximo de combinacoes
*
***/
#DEFINE pDSA_DEF_MAX_COMB                               3268760


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#DEFINE pDSA_POS_CONCURSO                                1
#DEFINE pDSA_POS_SORTEIO                                 2
#DEFINE pDSA_POS_DADOS                                   3

#DEFINE pDSA_POS_DADOS_SEQUENCIA_1                       1
#DEFINE pDSA_POS_DADOS_SEQUENCIA_2                       2
#DEFINE pDSA_POS_DADOS_ACER_1_3                          3
#DEFINE pDSA_POS_DADOS_ACER_1_4                          4
#DEFINE pDSA_POS_DADOS_ACER_1_5                          5
#DEFINE pDSA_POS_DADOS_ACER_1_6                          6
#DEFINE pDSA_POS_DADOS_ACER_2_3                          7
#DEFINE pDSA_POS_DADOS_ACER_2_4                          8
#DEFINE pDSA_POS_DADOS_ACER_2_5                          9
#DEFINE pDSA_POS_DADOS_ACER_2_6                         10



#XTRANSLATE pDSA_CONCURSO                               => aDuplaSena\[ pDSA_POS_CONCURSO ]
#XTRANSLATE pDSA_SORTEIO                                => aDuplaSena\[ pDSA_POS_SORTEIO ]

#XTRANSLATE pDSA_DEZENA_1_01                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_1 ]\[ 1\]
#XTRANSLATE pDSA_DEZENA_1_02                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_1 ]\[ 2\]
#XTRANSLATE pDSA_DEZENA_1_03                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_1 ]\[ 3\]
#XTRANSLATE pDSA_DEZENA_1_04                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_1 ]\[ 4\]
#XTRANSLATE pDSA_DEZENA_1_05                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_1 ]\[ 5\]
#XTRANSLATE pDSA_DEZENA_1_06                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_1 ]\[ 6\]

#XTRANSLATE pDSA_DEZENA_2_01                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_2 ]\[ 1\]
#XTRANSLATE pDSA_DEZENA_2_02                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_2 ]\[ 2\]
#XTRANSLATE pDSA_DEZENA_2_03                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_2 ]\[ 3\]
#XTRANSLATE pDSA_DEZENA_2_04                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_2 ]\[ 4\]
#XTRANSLATE pDSA_DEZENA_2_05                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_2 ]\[ 5\]
#XTRANSLATE pDSA_DEZENA_2_06                            => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_2 ]\[ 6\]

#XTRANSLATE pDSA_ACERTO_1_TERNO                         => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_3 ]\[ 1\]
#XTRANSLATE pDSA_PREMIO_1_TERNO                         => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_3 ]\[ 2\]

#XTRANSLATE pDSA_ACERTO_1_QUADRA                        => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_4 ]\[ 1\]
#XTRANSLATE pDSA_PREMIO_1_QUADRA                        => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_4 ]\[ 2\]

#XTRANSLATE pDSA_ACERTO_1_QUINA                         => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_5 ]\[ 1\]
#XTRANSLATE pDSA_PREMIO_1_QUINA                         => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_5 ]\[ 2\]

#XTRANSLATE pDSA_ACERTO_1_SENA                          => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_6 ]\[ 1\]
#XTRANSLATE pDSA_PREMIO_1_SENA                          => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_6 ]\[ 2\]

#XTRANSLATE pDSA_ACERTO_2_TERNO                         => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_3 ]\[ 1\]
#XTRANSLATE pDSA_PREMIO_2_TERNO                         => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_3 ]\[ 2\]

#XTRANSLATE pDSA_ACERTO_2_QUADRA                        => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_4 ]\[ 1\]
#XTRANSLATE pDSA_PREMIO_2_QUADRA                        => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_4 ]\[ 2\]

#XTRANSLATE pDSA_ACERTO_2_QUINA                         => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_5 ]\[ 1\]
#XTRANSLATE pDSA_PREMIO_2_QUINA                         => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_5 ]\[ 2\]

#XTRANSLATE pDSA_ACERTO_2_SENA                          => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_6 ]\[ 1\]
#XTRANSLATE pDSA_PREMIO_2_SENA                          => aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_6 ]\[ 2\]


#XTRANSLATE xInitDuplaSena                              => ( aDuplaSena := { ,, {   Array(6), Array(6),                                              ;
                                                                                    Array(2), Array(2), Array(2), Array(2),                          ;
                                                                                    Array(2), Array(2), Array(2), Array(2)                           ;
                                                                                }                                                                    ;
                                                                            }                                                                        ;
                                                            ) 

// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreDuplaSena                             =>  (   pDSA_CONCURSO         := Space(5),                                                   ;
                                                                pDSA_SORTEIO          := CToD(''),                                                   ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_1 ], Space(2) ),     ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_SEQUENCIA_2 ], Space(2) ),     ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_3 ], 0           ),     ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_4 ], 0           ),     ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_5 ], 0           ),     ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_1_6 ], 0           ),     ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_3 ], 0           ),     ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_4 ], 0           ),     ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_5 ], 0           ),     ;
                                                                AFill( aDuplaSena\[ pDSA_POS_DADOS ]\[ pDSA_POS_DADOS_ACER_2_6 ], 0           )      ;
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
