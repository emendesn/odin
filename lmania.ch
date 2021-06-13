/***
*
*  LMANIA.CH
*
***/


/***
*
*  Numero minimo e maximo de dezenas por jogo
*
***/
#DEFINE pLTM_DEF_MIN_DEZENAS                            50
#DEFINE pLTM_DEF_MAX_DEZENAS                            50


/***
*
*  Contante definindo o numero maximo de combinacoes
*
***/
#DEFINE pLTM_DEF_MAX_COMB                               47129212243960


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#DEFINE pLTM_POS_CONCURSO                               1
#DEFINE pLTM_POS_SORTEIO                                2
#DEFINE pLTM_POS_DADOS                                  3

#DEFINE pLTM_POS_DEZENAS                                1
#DEFINE pLTM_POS_ACER_00                                2
#DEFINE pLTM_POS_ACER_15                                3
#DEFINE pLTM_POS_ACER_16                                4
#DEFINE pLTM_POS_ACER_17                                5
#DEFINE pLTM_POS_ACER_18                                6
#DEFINE pLTM_POS_ACER_19                                7
#DEFINE pLTM_POS_ACER_20                                8


#XTRANSLATE pLTM_CONCURSO                               => aLotoMania\[ pLTM_POS_CONCURSO ]
#XTRANSLATE pLTM_SORTEIO                                => aLotoMania\[ pLTM_POS_SORTEIO  ]

#XTRANSLATE pLTM_DEZENA_01                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[ 1]
#XTRANSLATE pLTM_DEZENA_02                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[ 2]
#XTRANSLATE pLTM_DEZENA_03                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[ 3]
#XTRANSLATE pLTM_DEZENA_04                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[ 4]
#XTRANSLATE pLTM_DEZENA_05                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[ 5]
#XTRANSLATE pLTM_DEZENA_06                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[ 6]
#XTRANSLATE pLTM_DEZENA_07                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[ 7]
#XTRANSLATE pLTM_DEZENA_08                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[ 8]
#XTRANSLATE pLTM_DEZENA_09                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[ 9]
#XTRANSLATE pLTM_DEZENA_10                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[10]
#XTRANSLATE pLTM_DEZENA_11                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[11]
#XTRANSLATE pLTM_DEZENA_12                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[12]
#XTRANSLATE pLTM_DEZENA_13                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[13]
#XTRANSLATE pLTM_DEZENA_14                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[14]
#XTRANSLATE pLTM_DEZENA_15                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[15]
#XTRANSLATE pLTM_DEZENA_16                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[16]
#XTRANSLATE pLTM_DEZENA_17                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[17]
#XTRANSLATE pLTM_DEZENA_18                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[18]
#XTRANSLATE pLTM_DEZENA_19                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[19]
#XTRANSLATE pLTM_DEZENA_20                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ]\[20]

#XTRANSLATE pLTM_ACERTO_00                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_00 ]\[1]
#XTRANSLATE pLTM_PREMIO_00                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_00 ]\[2]

#XTRANSLATE pLTM_ACERTO_15                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_15 ]\[1]
#XTRANSLATE pLTM_PREMIO_15                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_15 ]\[2]

#XTRANSLATE pLTM_ACERTO_16                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_16 ]\[1]
#XTRANSLATE pLTM_PREMIO_16                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_16 ]\[2]

#XTRANSLATE pLTM_ACERTO_17                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_17 ]\[1]
#XTRANSLATE pLTM_PREMIO_17                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_17 ]\[2]

#XTRANSLATE pLTM_ACERTO_18                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_18 ]\[1]
#XTRANSLATE pLTM_PREMIO_18                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_18 ]\[2]

#XTRANSLATE pLTM_ACERTO_19                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_19 ]\[1]
#XTRANSLATE pLTM_PREMIO_19                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_19 ]\[2]

#XTRANSLATE pLTM_ACERTO_20                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_20 ]\[1]
#XTRANSLATE pLTM_PREMIO_20                              => aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_20 ]\[2]


// Inicializa o vetor
#XTRANSLATE xInitLotoMania                              =>  ( aLotoMania := { ,,    {   Array(20), Array(2), Array(2), Array(2),    ;
                                                                                        Array(2),  Array(2), Array(2), Array(2)     ;
                                                                                    }                                               ;
                                                                            }                                                       ;
                                                            )

// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreLotoMania                             => (    pLTM_CONCURSO     := Space(5),                                        ;
                                                                pLTM_SORTEIO      := CToD(''),                                        ;
                                                                AFill( aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_DEZENAS ], Space(2) ),;
                                                                AFill( aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_00 ], 0 ),       ;
                                                                AFill( aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_15 ], 0 ),       ;
                                                                AFill( aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_16 ], 0 ),       ;
                                                                AFill( aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_17 ], 0 ),       ;
                                                                AFill( aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_18 ], 0 ),       ;
                                                                AFill( aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_19 ], 0 ),       ;
                                                                AFill( aLotoMania\[ pLTM_POS_DADOS ]\[ pLTM_POS_ACER_20 ], 0 )        )

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



/***
*
*  Variaveis para a funcao de geracao de dados Aleatorios
*
***/
#XTRANSLATE LM_AL_APOSTA                      => aLMania\[1]
#XTRANSLATE LM_AL_SORTEIO                     => aLMania\[2]
#XTRANSLATE LM_AL_VALOR_APOSTA                => aLMania\[3]
#XTRANSLATE LM_AL_QUANTIDADE                  => aLMania\[4]
#XTRANSLATE LM_AL_DEZENAS                     => aLMania\[5]


// Inicializa o vetor
#XTRANSLATE xLMInitAleatoria                  => ( aLMania := { , , , , } )

// Inicializa as Variaveis no vetor
#XTRANSLATE xLMStoreAleatoria                 => ( LM_AL_APOSTA       := Space(4),  ;
                                                   LM_AL_SORTEIO      := CToD(''),  ;
                                                   LM_AL_VALOR_APOSTA :=  0,        ;
                                                   LM_AL_QUANTIDADE   :=  1,        ;
                                                   LM_AL_DEZENAS      := 50         )

// Variaveis para Processamento Aleatorios
#XTRANSLATE xLMMntAleatorio( <array> )        => ( <array> := { } )




/***
*
*  Variaveis para a funcao de Analise de Dezenas
*
***/
#XTRANSLATE LM_AD_APOSTA                      => aLMania\[1]
#XTRANSLATE LM_AD_SORTEIO                     => aLMania\[2]
#XTRANSLATE LM_AD_VALOR_APOSTA                => aLMania\[3]
#XTRANSLATE LM_AD_OPCAO                       => aLMania\[4]
#XTRANSLATE LM_AD_DEZENAS                     => aLMania\[5]
#XTRANSLATE LM_AD_QUANTIDADE                  => aLMania\[6]

// Inicializa o vetor
#XTRANSLATE xLMInitAnaliseDezenas             => ( aLMania := { , , , , , } )

// Inicializa as Variaveis no vetor
#XTRANSLATE xLMStoreAnaliseDezenas            => ( LM_AD_APOSTA       := Space(4),  ;
                                                   LM_AD_SORTEIO      := CToD(''),  ;
                                                   LM_AD_VALOR_APOSTA :=  0,        ;
                                                   LM_AD_OPCAO        := 'E',       ;
                                                   LM_AD_DEZENAS      := 50,        ;
                                                   LM_AD_QUANTIDADE   := 51         )

// Variaveis para Processamento Analise de Dezenas
#DEFINE LM_AD_MNT_OCORRENCIA                   1
#DEFINE LM_AD_MNT_DEZENAS                      2
#XTRANSLATE xLMMntAnaliseDezenas( <array> )   => ( <array> := { {}, {} } )




/***
*
*  Variaveis para a funcao de Definicao de Dezenas
*
***/
#XTRANSLATE LM_DF_APOSTA                      => aLMania\[1]
#XTRANSLATE LM_DF_SORTEIO                     => aLMania\[2]
#XTRANSLATE LM_DF_VALOR_APOSTA                => aLMania\[3]
#XTRANSLATE LM_DF_DISPLAY                     => aLMania\[4]
#XTRANSLATE LM_DF_DEZENAS                     => aLMania\[5]

// Inicializa o vetor
#XTRANSLATE xLMInitDefinicaoDezenas           => ( aLMania := { , , , , } )

// Inicializa as Variaveis no vetor
#XTRANSLATE xLMStoreDefinicaoDezenas          => ( LM_DF_APOSTA       := Space(4),  ;
                                                   LM_DF_SORTEIO      := CToD(''),  ;
                                                   LM_DF_VALOR_APOSTA :=  0,        ;
                                                   LM_DF_DISPLAY      := '',        ;
                                                   LM_DF_DEZENAS      := 50         )




