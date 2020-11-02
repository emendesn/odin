/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  msena.ch
*
***/


/***
*
*  Numero minimo e maximo de dezenas por jogo
*
***/
#DEFINE pMSA_DEF_MIN_DEZENAS                             6
#DEFINE pMSA_DEF_MAX_DEZENAS                            15


/***
*
*  Contante definindo o numero maximo de combinacoes
*
***/
#DEFINE pMSA_DEF_MAX_COMB                               50063860


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#DEFINE pMSA_POS_CONCURSO                               1
#DEFINE pMSA_POS_SORTEIO                                2
#DEFINE pMSA_POS_DADOS                                  3

#DEFINE pMSA_POS_DEZENAS                                1
#DEFINE pMSA_POS_ACER_04                                2
#DEFINE pMSA_POS_ACER_05                                3
#DEFINE pMSA_POS_ACER_06                                4



#XTRANSLATE pMSA_CONCURSO                               => aMegaSena\[ pMSA_POS_CONCURSO ]
#XTRANSLATE pMSA_SORTEIO                                => aMegaSena\[ pMSA_POS_SORTEIO  ]

#XTRANSLATE pMSA_DEZENA_01                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_DEZENAS ]\[ 1\]
#XTRANSLATE pMSA_DEZENA_02                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_DEZENAS ]\[ 2\]
#XTRANSLATE pMSA_DEZENA_03                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_DEZENAS ]\[ 3\]
#XTRANSLATE pMSA_DEZENA_04                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_DEZENAS ]\[ 4\]
#XTRANSLATE pMSA_DEZENA_05                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_DEZENAS ]\[ 5\]
#XTRANSLATE pMSA_DEZENA_06                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_DEZENAS ]\[ 6\]

#XTRANSLATE pMSA_ACERTO_04                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_ACER_04 ]\[ 1\]
#XTRANSLATE pMSA_PREMIO_04                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_ACER_04 ]\[ 2\]

#XTRANSLATE pMSA_ACERTO_05                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_ACER_05 ]\[ 1\]
#XTRANSLATE pMSA_PREMIO_05                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_ACER_05 ]\[ 2\]

#XTRANSLATE pMSA_ACERTO_06                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_ACER_06 ]\[ 1\]
#XTRANSLATE pMSA_PREMIO_06                              => aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_ACER_06 ]\[ 2\]


#XTRANSLATE xInitMegaSena                               =>  ( aMegaSena := {   ,,   {   Array(6), Array(2), Array(2), Array(2)         ;
                                                                                    }                                                  ;
                                                                            }                                                          ;
                                                            )

// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreMegaSena                              =>  (   pMSA_CONCURSO     := Space(5),                                         ;
                                                                pMSA_SORTEIO      := CToD(''),                                         ;
                                                                AFill( aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_DEZENAS ], Space(2) ),  ;
                                                                AFill( aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_ACER_04 ], 0        ),  ;
                                                                AFill( aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_ACER_05 ], 0        ),  ;
                                                                AFill( aMegaSena\[ pMSA_POS_DADOS ]\[ pMSA_POS_ACER_06 ], 0 )          ;
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

