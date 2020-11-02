/***
*
*  main.ch
*
***/

/***
*
*  Constante Logiscas
*
***/
#define pTRUE                   .T.
#define pFALSE                  .F.


/***
*
*  Variaveis para a utilizacao dos parametros
*
***/
#XTRANSLATE .color            => \[ 1\]
#XTRANSLATE .path             => \[ 2\]
#XTRANSLATE .temp             => \[ 3\]


/***
*
*  Variaveis do sistema
*
***/
#xtranslate SI_ROWTOP         => aOdinSystem\[ 1\]   /* Linha Inicial */
#xtranslate SI_COLTOP         => aOdinSystem\[ 2\]   /* Coluna Inicial */
#xtranslate SI_ROWBOTTOM      => aOdinSystem\[ 3\]
#xtranslate SI_COLBOTTOM      => aOdinSystem\[ 4\]
#xtranslate SI_PATH           => aOdinSystem\[ 5\]
#xtranslate SI_TMP            => aOdinSystem\[ 6\]
#xtranslate SI_OLDCOLOR       => aOdinSystem\[ 7\]
#xtranslate SI_CURSOR         => aOdinSystem\[ 8\]
#xtranslate SI_SCOREBOARD     => aOdinSystem\[ 9\]
#xtranslate SI_EXCLUSIVE      => aOdinSystem\[10\]
#xtranslate SI_DELETED        => aOdinSystem\[11\]
#xtranslate SI_CANCEL         => aOdinSystem\[12\]
#xtranslate SI_EPOCH          => aOdinSystem\[13\]
#xtranslate SI_DATEFORMAT     => aOdinSystem\[14\]
#xtranslate SI_TIMEFORMAT     => aOdinSystem\[15\]
#xtranslate SI_EVENTMASK      => aOdinSystem\[16\]
#xtranslate SI_AUTOPEN        => aOdinSystem\[17\]
#xtranslate SI_LANGUAGE       => aOdinSystem\[18\]
#xtranslate SI_CODEPAGE       => aOdinSystem\[19\]
#xtranslate SI_OSCODEPAGE     => aOdinSystem\[20\]
#xtranslate SI_DBCODEPAGE     => aOdinSystem\[21\]
#xtranslate SI_DBFLOCKSCHEME  => aOdinSystem\[22\]
#xtranslate SI_EVENTMASK      => aOdinSystem\[23\]
#xtranslate SI_OPTIMIZE       => aOdinSystem\[24\]
#xtranslate SI_FILECASE       => aOdinSystem\[25\]
#xtranslate SI_DIRCASE        => aOdinSystem\[26\]

#xtranslate SI_OLDROW         => aOdinSystem\[27\]
#xtranslate SI_OLDCOL         => aOdinSystem\[28\]
#xtranslate SI_MAINMENU       => aOdinSystem\[29\]

#xtranslate SI_CONCURSO       => aOdinSystem\[30\]   /* Codigo do Concurso */
#xtranslate SI_NOMECONCURSO   => aOdinSystem\[31\]   /* Nome do Concurso   */
#xtranslate SI_BANNER         => aOdinSystem\[32\]

#xtranslate SI_MESSAGE        => aOdinSystem\[33\]
#xtranslate SI_BACKGROUND     => aOdinSystem\[34\]
#xtranslate SI_PUSHBUTTON     => aOdinSystem\[35\]
#xtranslate SI_MENU           => aOdinSystem\[36\]
#xtranslate SI_FORM           => aOdinSystem\[37\]
#xtranslate SI_LABEL          => aOdinSystem\[38\]
#xtranslate SI_SCROLLBAR      => aOdinSystem\[39\]
#xtranslate SI_FIELDGET       => aOdinSystem\[40\]
#xtranslate SI_FIELDLISTBOX   => aOdinSystem\[41\]
#xtranslate SI_FIELDGRADIOBOX => aOdinSystem\[42\]
#xtranslate SI_FIELDBRADIOBOX => aOdinSystem\[43\]
#xtranslate SI_FIELDCHECKBOX  => aOdinSystem\[44\]
#xtranslate SI_BROWSE         => aOdinSystem\[45\]

#xtranslate pInicializa       => ( aOdinSystem := ARRAY( 45 ) )


/***
*
*  Estrutura dos Jogos
*
***/
#DEFINE pDUPLA_SENA           'DSA'
#DEFINE pLOTO_FACIL           'LTF'
#DEFINE pLOTO_MANIA           'LTM' 
#DEFINE pMEGA_SENA            'MSA'
#DEFINE pQUINA                'QNA'
#DEFINE pTIME_MANIA           'TIM'
#DEFINE pDIA_SORTE            'DDS'
#DEFINE pLOTECA               'LTC'
#DEFINE pLOTOGOL              'LTG'


/***
*
*  Estrutura dos dicionarios dos Concursos
*
***/
#DEFINE pSTRU_JOGO                1
#DEFINE pSTRU_NOME                2
#DEFINE pSTRU_DEZENAS             3
#DEFINE pSTRU_REGRA_PREMIACAO     4
#DEFINE pSTRU_REGRA_QUANT_DEZENAS 5
#DEFINE pSTRU_JOGOS_BROWSE        6
#DEFINE pSTRU_APOSTAS_BROWSE      7
#DEFINE pSTRU_APOSTAS_INCLUIR     8
#DEFINE pSTRU_APOSTAS_MODIFICAR   9
#DEFINE pSTRU_APOSTAS_EXCLUIR    10

#DEFINE pSTRU_SYSTEM              { ;
                                    { 'DSA', 'DUPLASENA',   {   '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',                  ;
                                                                '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',                  ;
                                                                '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',                  ;
                                                                '31', '32', '33', '34', '35', '36', '37', '38', '39', '40',                  ;
                                                                '41', '42', '43', '44', '45', '46', '47', '48', '49', '50'                   ;
                                                            },                                                                               ;
                                                            {   { '06', { |xDta| xDta >= CToD('11/06/03') } },                               ;
                                                                { '05', { |xDta| xDta >= CToD('11/06/03') } },                               ;
                                                                { '04', { |xDta| xDta >= CToD('11/06/03') } },                               ;
                                                                { '03', { |xDta| xDta >= CToD('06/28/16') } }                                ;
                                                            },                                                                               ;
                                                                { |xDez| xDez >= 16 .or. xDez == 0 },                                        ;
                                                                { || DSAMntBrowse()   },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              }                                                      ;
                                    },                                                                                                       ;
                                    { 'LTF', 'LOTOFACIL',   {   '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',                  ;
                                                                '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',                  ;
                                                                '21', '22', '23', '24', '25'                                                 ;
                                                            },                                                                               ;
                                                            {   { '15', { |xDta| xDta >= CToD('09/29/03') } },                               ;
                                                                { '14', { |xDta| xDta >= CToD('09/29/03') } },                               ;
                                                                { '13', { |xDta| xDta >= CToD('09/29/03') } },                               ;
                                                                { '12', { |xDta| xDta >= CToD('09/29/03') } },                               ;
                                                                { '11', { |xDta| xDta >= CToD('09/29/03') } }                                ;
                                                            },                                                                               ;
                                                                { |xDez| xDez >= 11   },                                                     ;
                                                                { || LTFMntBrowse()   },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              }                                                      ;
                                    },                                                                                                       ;
                                    { 'LTM', 'LOTOMANIA',   {   '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',                  ;
                                                                '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',                  ;
                                                                '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',                  ;
                                                                '31', '32', '33', '34', '35', '36', '37', '38', '39', '40',                  ;
                                                                '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',                  ;
                                                                '51', '52', '53', '54', '55', '56', '57', '58', '59', '60',                  ;
                                                                '61', '62', '63', '64', '65', '66', '67', '68', '69', '70',                  ;
                                                                '71', '72', '73', '74', '75', '76', '77', '78', '79', '80',                  ;
                                                                '81', '82', '83', '84', '85', '86', '87', '88', '89', '90',                  ;
                                                                '91', '92', '93', '94', '95', '96', '97', '98', '99', '00'                   ;
                                                            },                                                                               ;
                                                            {   { '20', { |xDta| xDta >= CToD('10/02/99') } },                               ;
                                                                { '19', { |xDta| xDta >= CToD('10/02/99') } },                               ;
                                                                { '18', { |xDta| xDta >= CToD('10/02/99') } },                               ;
                                                                { '17', { |xDta| xDta >= CToD('10/02/99') } },                               ;
                                                                { '16', { |xDta| xDta >= CToD('10/02/99') } },                               ;
                                                                { '15', { |xDta| xDta >= CToD('04/29/16') } },                               ;
                                                                { '00', { |xDta| xDta >= CToD('10/02/99') } }                                ;
                                                            },                                                                               ;
                                                                { |xDez| xDez >= 16 .or. xDez == 0 },                                        ;
                                                                { || LTMMntBrowse()   },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              }                                                      ;
                                    },                                                                                                       ;
                                    { 'MSA', 'MEGASENA',    {   '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',                  ;
                                                                '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',                  ;
                                                                '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',                  ;
                                                                '31', '32', '33', '34', '35', '36', '37', '38', '39', '40',                  ;
                                                                '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',                  ;
                                                                '51', '52', '53', '54', '55', '56', '57', '58', '59', '60'                   ;
                                                            },                                                                               ;
                                                            {   { '06', { |xDta| xDta >= CToD('03/11/96') } },                               ;
                                                                { '05', { |xDta| xDta >= CToD('03/11/96') } },                               ;
                                                                { '04', { |xDta| xDta >= CToD('03/11/96') } }                                ;
                                                            },                                                                               ;
                                                                { |xDez| xDez >= 4    },                                                     ;
                                                                { || MSAMntBrowse()   },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              }                                                      ;
                                    },                                                                                                       ;
                                    { 'QNA', 'QUINA',       {   '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',                  ;
                                                                '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',                  ;
                                                                '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',                  ;
                                                                '31', '32', '33', '34', '35', '36', '37', '38', '39', '40',                  ;
                                                                '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',                  ;
                                                                '51', '52', '53', '54', '55', '56', '57', '58', '59', '60',                  ;
                                                                '61', '62', '63', '64', '65', '66', '67', '68', '69', '70',                  ;
                                                                '71', '72', '73', '74', '75', '76', '77', '78', '79', '80'                   ;
                                                            },                                                                               ;
                                                            {   { '05', { |xDta| xDta >= CToD('03/13/94') } },                               ;
                                                                { '04', { |xDta| xDta >= CToD('03/13/94') } },                               ;
                                                                { '03', { |xDta| xDta >= CToD('03/13/94') } },                               ;
                                                                { '02', { |xDta| xDta >= CToD('05/16/16') } }                                ;
                                                            },                                                                               ;
                                                                { |xDez| xDez >=  3   },                                                     ;
                                                                { || QNAMntBrowse()   },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              }                                                      ;
                                    },                                                                                                       ;
                                    { 'TIM', 'TIMEMANIA',   {   '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',                  ;
                                                                '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',                  ;
                                                                '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',                  ;
                                                                '31', '32', '33', '34', '35', '36', '37', '38', '39', '40',                  ;
                                                                '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',                  ;
                                                                '51', '52', '53', '54', '55', '56', '57', '58', '59', '60',                  ;
                                                                '61', '62', '63', '64', '65', '66', '67', '68', '69', '70',                  ;
                                                                '71', '72', '73', '74', '75', '76', '77', '78', '79', '80'                   ;
                                                            },                                                                               ;
                                                            {   { '07', { |xDta| xDta >= CToD('03/01/08') } },                               ;
                                                                { '06', { |xDta| xDta >= CToD('03/01/08') } },                               ;
                                                                { '05', { |xDta| xDta >= CToD('03/01/08') } },                               ;
                                                                { '04', { |xDta| xDta >= CToD('03/01/08') } },                               ;
                                                                { '03', { |xDta| xDta >= CToD('03/01/08') } }                                ;
                                                            },                                                                               ;
                                                                { |xDez| xDez >=  3 .or. xDez == 7 },                                        ;
                                                                { || TIMMntBrowse()   },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              }                                                      ;
                                    },                                                                                                       ;
                                    { 'DDS', 'DIADESORTE',  {   '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',                  ;
                                                                '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',                  ;
                                                                '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',                  ;
                                                                '31'                                                                         ;
                                                            },                                                                               ;
                                                            {   { '07', { |xDta| xDta >= CToD('19/05/18') } },                               ;
                                                                { '06', { |xDta| xDta >= CToD('19/05/18') } },                               ;
                                                                { '05', { |xDta| xDta >= CToD('19/05/18') } },                               ;
                                                                { '04', { |xDta| xDta >= CToD('19/05/18') } }                                ;
                                                            },                                                                               ;
                                                                { |xDez| Len(xDez) > 0 .and. (Len(xDez) >= 7 .or. Len(xDez) <= 15) },        ;
                                                                { || DDSMntBrowse() },                                                       ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil },                                                                  ;
                                                                { || Nil }                                                                   ;
                                    },                                                                                                       ;
                                    { 'LTC', ' LOTECA ',    { '00100', '01000', '10000'                                                      ; // , '01110', '11010', '10110', '11101' ;
                                                            },                                                                               ;
                                                            {   { '14', { |xDta| xDta >= CToD('02/18/02') } },                               ;
                                                                { '13', { |xDta| xDta >= CToD('02/18/02') } },                               ;
                                                                { '12', { |xDta| xDta >= CToD('02/18/02') .and. xDta <= CToD('11/03/03') } } ;
                                                            },                                                                               ;
                                                                { |xDez| xDez >= 13   },                                                     ;
                                                                { || LTCMntBrowse()   },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              }                                                      ;
                                    },                                                                                                       ;
                                    { 'LTG', 'LOTOGOL',     { ''                                                                             ;
                                                            },                                                                               ;
                                                            {   { '05', { |xDta| xDta >= CToD('02/18/02') } },                               ;
                                                                { '04', { |xDta| xDta >= CToD('02/18/02') } },                               ;
                                                                { '03', { |xDta| xDta >= CToD('02/18/02') } }                                ;
                                                            },                                                                               ;
                                                                { |xDez| xDez >= 3    },                                                     ;
                                                                { || LTGMntBrowse()   },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              },                                                     ;
                                                                { || Nil              }                                                      ;
                                    } ;
                                }


                                /***
*
*  Teclas de Movimentacao do Browse
*
***/
#DEFINE pBRW_KEY               1
#DEFINE pBRW_ACTION            2
#DEFINE pBRW_INKEYS            {    { K_DOWN      , {|obj| obj:down() }    },;
                                    { K_UP        , {|obj| obj:up() }      },;
                                    { K_PGDN      , {|obj| obj:pageDown()} },;
                                    { K_PGUP      , {|obj| obj:pageUp()}   },;
                                    { K_CTRL_PGUP , {|obj| obj:goTop()}    },;
                                    { K_CTRL_PGDN , {|obj| obj:goBottom()} },;
                                    { K_HOME      , {|obj| obj:home()}     },;
                                    { K_END       , {|obj| obj:end()}      },;
                                    { K_CTRL_LEFT , {|obj| obj:panLeft()}  },;
                                    { K_CTRL_RIGHT, {|obj| obj:panRight()} },;
                                    { K_CTRL_HOME , {|obj| obj:panHome()}  },;
                                    { K_CTRL_END  , {|obj| obj:panEnd()}   } }