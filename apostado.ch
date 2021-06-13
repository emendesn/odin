/***
*
*  apostado.ch
*
***/


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#XTRANSLATE pAPOSTADORES_CODIGO                         => aApostadores\[ 1\]
#XTRANSLATE pAPOSTADORES_NOME                           => aApostadores\[ 2\]
#XTRANSLATE pAPOSTADORES_EMAIL                          => aApostadores\[ 3\]

#XTRANSLATE xInitApostadores                            =>  (   aApostadores := Array(3) )

#XTRANSLATE xStoreApostadores                           =>  (   pAPOSTADORES_CODIGO := 1, ;
                                                                pAPOSTADORES_NOME   := Space(30), ;
                                                                pAPOSTADORES_EMAIL  := Space(30)  ;
                                                            )

