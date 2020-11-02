/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  lfacil.ch
*
***/


/***
*
*  Numero minimo e maximo de dezenas por jogo
*
***/
#DEFINE pLTF_DEF_MIN_DEZENAS                            15
#DEFINE pLTF_DEF_MAX_DEZENAS                            18


/***
*
*  Contante definindo o numero maximo de combinacoes
*
***/
#DEFINE pLTF_DEF_MAX_COMB                               3268760


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#DEFINE pLTF_POS_CONCURSO                               1
#DEFINE pLTF_POS_SORTEIO                                2
#DEFINE pLTF_POS_DADOS                                  3

#DEFINE pLTF_POS_DEZENAS                                1
#DEFINE pLTF_POS_ACER_11                                2
#DEFINE pLTF_POS_ACER_12                                3
#DEFINE pLTF_POS_ACER_13                                4
#DEFINE pLTF_POS_ACER_14                                5
#DEFINE pLTF_POS_ACER_15                                6



#XTRANSLATE pLTF_CONCURSO                               => aLotoFacil\[ pLTF_POS_CONCURSO ]
#XTRANSLATE pLTF_SORTEIO                                => aLotoFacil\[ pLTF_POS_SORTEIO  ]

#XTRANSLATE pLTF_DEZENA_01                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[ 1\]
#XTRANSLATE pLTF_DEZENA_02                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[ 2\]
#XTRANSLATE pLTF_DEZENA_03                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[ 3\]
#XTRANSLATE pLTF_DEZENA_04                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[ 4\]
#XTRANSLATE pLTF_DEZENA_05                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[ 5\]
#XTRANSLATE pLTF_DEZENA_06                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[ 6\]
#XTRANSLATE pLTF_DEZENA_07                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[ 7\]
#XTRANSLATE pLTF_DEZENA_08                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[ 8\]
#XTRANSLATE pLTF_DEZENA_09                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[ 9\]
#XTRANSLATE pLTF_DEZENA_10                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[10\]
#XTRANSLATE pLTF_DEZENA_11                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[11\]
#XTRANSLATE pLTF_DEZENA_12                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[12\]
#XTRANSLATE pLTF_DEZENA_13                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[13\]
#XTRANSLATE pLTF_DEZENA_14                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[14\]
#XTRANSLATE pLTF_DEZENA_15                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ]\[15\]

#XTRANSLATE pLTF_ACERTO_11                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_11 ]\[ 1\]
#XTRANSLATE pLTF_PREMIO_11                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_11 ]\[ 2\]

#XTRANSLATE pLTF_ACERTO_12                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_12 ]\[ 1\]
#XTRANSLATE pLTF_PREMIO_12                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_12 ]\[ 2\]

#XTRANSLATE pLTF_ACERTO_13                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_13 ]\[ 1\]
#XTRANSLATE pLTF_PREMIO_13                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_13 ]\[ 2\]

#XTRANSLATE pLTF_ACERTO_14                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_14 ]\[ 1\]
#XTRANSLATE pLTF_PREMIO_14                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_14 ]\[ 2\]

#XTRANSLATE pLTF_ACERTO_15                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_15 ]\[ 1\]
#XTRANSLATE pLTF_PREMIO_15                              => aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_15 ]\[ 2\]


#XTRANSLATE xInitLotoFacil                              =>  ( aLotoFacil := {   ,,  {   Array(15), Array(2), Array(2),                 ;
                                                                                        Array(2),  Array(2), Array(2)                  ;
                                                                                    }                                                  ;
                                                                            }                                                          ;
                                                            )

// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreLotoFacil                             =>  (   pLTF_CONCURSO     := Space(5),                                         ;
                                                                pLTF_SORTEIO      := CToD(''),                                         ;
                                                                AFill( aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_DEZENAS ], Space(2) ), ;
                                                                AFill( aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_11 ], 0        ), ;
                                                                AFill( aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_12 ], 0        ), ;
                                                                AFill( aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_13 ], 0        ), ;
                                                                AFill( aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_14 ], 0        ), ;
                                                                AFill( aLotoFacil\[ pLTF_POS_DADOS ]\[ pLTF_POS_ACER_15 ], 0 )         ;
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



/***
*
*  Variaveis para a Funcao LFAnaliCalc
*
***/
#XTRANSLATE LF_CL_OCORRENCIA                  => aLFacil\[ 1\]
#XTRANSLATE LF_CL_AA                          => aLFacil\[ 2\]
#XTRANSLATE LF_CL_AB                          => aLFacil\[ 3\]
#XTRANSLATE LF_CL_AC                          => aLFacil\[ 4\]
#XTRANSLATE LF_CL_AD                          => aLFacil\[ 5\]
#XTRANSLATE LF_CL_AE                          => aLFacil\[ 6\]
#XTRANSLATE LF_CL_ARRAY                       => aLFacil\[ 7\]
#XTRANSLATE LF_CL_ARRAY_ABC                   => aLFacil\[ 7\]\[ 1\]
#XTRANSLATE LF_CL_ARRAY_ABD                   => aLFacil\[ 7\]\[ 2\]
#XTRANSLATE LF_CL_ARRAY_ABE                   => aLFacil\[ 7\]\[ 3\]
#XTRANSLATE LF_CL_ARRAY_ACD                   => aLFacil\[ 7\]\[ 4\]
#XTRANSLATE LF_CL_ARRAY_ACE                   => aLFacil\[ 7\]\[ 5\]
#XTRANSLATE LF_CL_ARRAY_ADE                   => aLFacil\[ 7\]\[ 6\]
#XTRANSLATE LF_CL_ARRAY_BCD                   => aLFacil\[ 7\]\[ 7\]
#XTRANSLATE LF_CL_ARRAY_BCE                   => aLFacil\[ 7\]\[ 8\]
#XTRANSLATE LF_CL_ARRAY_BDE                   => aLFacil\[ 7\]\[ 9\]
#XTRANSLATE LF_CL_ARRAY_CDE                   => aLFacil\[ 7\]\[10\]

// Inicializa as variaveis para o Calculo
#XTRANSLATE xLFInitCalculo                    => ( aLFacil := { {}, {}, {}, {}, {}, {}, { {}, {},       ;
	                                                              {}, {}, {}, {}, {}, {}, {}, {} } }      )