/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  dsorte.ch
*
***/


/***
*
*  Numero minimo e maximo de dezenas por jogo
*
***/
#DEFINE pDDS_DEF_MIN_DEZENAS                             7
#DEFINE pDDS_DEF_MAX_DEZENAS                            15


/***
*
*  Contante definindo o numero maximo de combinacoes
*
***/
#DEFINE pDDS_DEF_MAX_COMB                                2629575


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#DEFINE pDDS_POS_CONCURSO                               1
#DEFINE pDDS_POS_SORTEIO                                2
#DEFINE pDDS_POS_MES_SORTE                              3
#DEFINE pDDS_POS_DADOS                                  4

#DEFINE pDDS_POS_DEZENAS                                1
#DEFINE pDDS_POS_ACER_07                                2
#DEFINE pDDS_POS_ACER_06                                3
#DEFINE pDDS_POS_ACER_05                                4
#DEFINE pDDS_POS_ACER_04                                5



#XTRANSLATE pDDS_CONCURSO                               => aDiaSorte\[ pDDS_POS_CONCURSO  ]
#XTRANSLATE pDDS_SORTEIO                                => aDiaSorte\[ pDDS_POS_SORTEIO   ]
#XTRANSLATE pDDS_MES_SORTE                              => aDiaSorte\[ pDDS_POS_MES_SORTE ]

#XTRANSLATE pDDS_DEZENA_01                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_DEZENAS ]\[ 1\]
#XTRANSLATE pDDS_DEZENA_02                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_DEZENAS ]\[ 2\]
#XTRANSLATE pDDS_DEZENA_03                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_DEZENAS ]\[ 3\]
#XTRANSLATE pDDS_DEZENA_04                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_DEZENAS ]\[ 4\]
#XTRANSLATE pDDS_DEZENA_05                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_DEZENAS ]\[ 5\]
#XTRANSLATE pDDS_DEZENA_06                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_DEZENAS ]\[ 6\]
#XTRANSLATE pDDS_DEZENA_07                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_DEZENAS ]\[ 7\]

#XTRANSLATE pDDS_ACERTO_07                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_07 ]\[ 1\]
#XTRANSLATE pDDS_PREMIO_07                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_07 ]\[ 2\]

#XTRANSLATE pDDS_ACERTO_06                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_06 ]\[ 1\]
#XTRANSLATE pDDS_PREMIO_06                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_06 ]\[ 2\]

#XTRANSLATE pDDS_ACERTO_05                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_05 ]\[ 1\]
#XTRANSLATE pDDS_PREMIO_05                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_05 ]\[ 2\]

#XTRANSLATE pDDS_ACERTO_04                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_04 ]\[ 1\]
#XTRANSLATE pDDS_PREMIO_04                              => aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_04 ]\[ 2\]


#XTRANSLATE xInitDiaSorte                               =>  ( aDiaSorte := {   ,,,  {   Array(7), Array(2), Array(2),                  ;
                                                                                        Array(2),  Array(2)                            ;
                                                                                    }                                                  ;
                                                                            }                                                          ;
                                                            )

// Inicializa as Variaveis no vetor
#XTRANSLATE xStoreDiaSorte                              =>  (   pDDS_CONCURSO     := Space(5),                                         ;
                                                                pDDS_SORTEIO      := CToD(''),                                         ;
                                                                pDDS_MES_SORTE    := Space(1),                                         ;
                                                                AFill( aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_DEZENAS ], Space(2) ),  ;
                                                                AFill( aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_07 ], 0        ),  ;
                                                                AFill( aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_06 ], 0        ),  ;
                                                                AFill( aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_05 ], 0        ),  ;
                                                                AFill( aDiaSorte\[ pDDS_POS_DADOS ]\[ pDDS_POS_ACER_04 ], 0        )   ;
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
*  Contante definindo o numero maximo de combinacoes
*
***/
#DEFINE pDDS_DEF_MES_SORTE                              {   {   'Janeiro',   '01' }, ;
                                                            {   'Fevereiro', '02' }, ;
                                                            {   'Marco',     '03' }, ;
                                                            {   'Abril',     '04' }, ;
                                                            {   'Maio',      '05' }, ;
                                                            {   'Junho',     '06' }, ;
                                                            {   'Julho',     '07' }, ;
                                                            {   'Agosto',    '08' }, ;
                                                            {   'Setembro',  '09' }, ;
                                                            {   'Outubro',   '10' }, ;
                                                            {   'Novembro',  '11' }, ;
                                                            {   'Dezembro',  '12' }  ;
                                                        }

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