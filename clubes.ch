/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*  clubes.ch
*
***/


/***
*
*  Variaveis para a Entrada de Dados
*
***/
#XTRANSLATE pCLUBES_CAD_CODIGO                          => aClubes\[ 1\]
#XTRANSLATE pCLUBES_CAD_ABREVIADO                       => aClubes\[ 2\]
#XTRANSLATE pCLUBES_CAD_NOME                            => aClubes\[ 3\]
#XTRANSLATE pCLUBES_CAD_UF                              => aClubes\[ 4\]

#XTRANSLATE xInitClubes                                 => ( aClubes := Array(4) )

#XTRANSLATE xStoreClubes                                =>  (   pCLUBES_CAD_CODIGO    := Space(5),  ;
                                                                pCLUBES_CAD_ABREVIADO := Space(30), ;
                                                                pCLUBES_CAD_NOME      := Space(50), ;
                                                                pCLUBES_CAD_UF        := Space(2)   ;
                                                            )


/***
*
*  Localidades
*
***/
#XTRANSLATE pCLUBES_CAD_LOCALIDADE                      =>  {   {'Acre',              'AC' }, {'Alagoas',             'AL' }, ;
                                                                {'Amazonas',          'AM' }, {'Amapa',               'AP' }, ;
                                                                {'Bahia',             'BA' }, {'Ceara',               'CE' }, ;
                                                                {'Distrito Federal',  'DF' }, {'Espirito Santo',      'ES' }, ;
                                                                {'Goias',             'GO' }, {'Maranhao',            'MA' }, ;
                                                                {'Minas Gerais',      'MG' }, {'Mato Grosso do Sul',  'MS' }, ;
                                                                {'Mato Grosso',       'MT' }, {'Para',                'PA' }, ;
                                                                {'Paraiba',           'PB' }, {'Pernanbuco',          'PE' }, ;
                                                                {'Piaui',             'PI' }, {'Parana',              'PR' }, ;
                                                                {'Rio de janeiro',    'RJ' }, {'Rio Grande do Norte', 'RN' }, ;
                                                                {'Rondonia',          'RO' }, {'Roraima',             'RR' }, ;
                                                                {'Rio Grande do Sul', 'RS' }, {'Santa Catarina',      'SC' }, ;
                                                                {'Sergipe',           'SE' }, {'Sao Paulo',           'SP' }, ;
                                                                {'Tocantins',         'TO' }, {'Selecao',             'SL' }, ;
                                                                {'Clube',             'CL' }                                  ;
                                                            }

