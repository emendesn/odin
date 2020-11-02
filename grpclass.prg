/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/


#include 'hbmemory.ch'
#include 'hbthread.ch'
#include 'hbclass.ch'
#include 'common.ch'
#include 'fileio.ch'
#include 'error.ch'
#include 'main.ch'

/***
*
*	hbGrupos
*
*	Classe para a elaboracao da combinacoes de grupos
*
*	Objetos:
*            :mLockCache      - Ponteiro para controle interno
*            :mLockThread     - Ponteiro para controle das threads em execucao
*            :lIsRunning      - Variavel informando o status da execucao
*            :aSequencia      - Relacao dos valores a serem analisados
*            :nQuantSequencia - Quantidade de Grupos de dezenas a serem combinadas
*            :nCorrente       - Valor do registro corrente processado
*            :nPercencutal    - Percentual realizado
*            :nTotal          - Quantidade Total de registros a serem gerados
*            :lStop           - Variavel informando a parada da execucao da rotina
*            :aDicionario     - Dicionario interno para controle das sequencias combinadas
*            :nPointer        - Controle interno para o vetor aDicionario
*            :aCache          - Cache para armazenar as sequencias geradas antes da gravacao
*            :nMaxCache       - Variavel para controlar o valor maximo armazenado na variavel aCache
*            :cAliasTmp       - Nome do Alias do arquivo temporario
*            :cFileTmp        - Nome do arquivo temporario
*            :cIndTmp         - Nome do indice temporario
*            :lErrComb        - Variavel informando caso tenha ocorrido algum erro durante a execucao
*            :cErrComb        - Variavel contendo a descricao do erro ocorrido
*
*	Metodos:
*            :New( aSequencia, nQuantSequencia ) - Realiza a criacao do objeto
*            :CreateTmpFile()                    - Cria o arquivo temporario
*            :Execute()                          - Executa o processamento
*            :Percent()                          - Retorna o percentual realizado
*            :Processa()                         - Inicia o processamento
*            :UpdateTmp()                        - Atualiza a tabela temporaria com a sequencia
*            :End()                              - Finaliza o processo
*
*            :Stable()                           - Medo para identificar o processo em execucao
*            :ControlThread( bCode )             - Realiza o controle das threads em execucao
*            :ParseString( aArray )              - Transforma o array passado como parametro em string
*            :GetNextFile()                      - Retorna o nome do arquivo temporario disponivel
*
*            :Eof()                              - Metodo para identificar o final do arquivo temporario
*            :GoTop()                            - Posiciona no inicio do arquivo temporario
*            :Skip( n )                          - Movimenta entre os registro no arquivo temporario
*            :Seek( a, b, c )                    - Pesquisa informacoes no arquivo temporario
*/
CREATE CLASS hbGrupos

    HIDDEN:
        VAR mLockCache        AS USUAL     INIT hb_mutexCreate() PROTECTED
        VAR mLockThread       AS USUAL     INIT hb_mutexCreate() PROTECTED
        VAR lIsRunning        AS LOGICAL   INIT pFALSE           PROTECTED

    PROTECTED:
        VAR nQuantSequencia   AS NUMERIC INIT 0

	METHOD New( nQuantSequencia, nGrupos )
    METHOD CreateTmpFile()    
    
END CLASS


/***
*
*	:New( nQuantSequencia, nGrupos ) --> Self
*
*	Metodo utilizado para a criacao do objeto
*
*	Parametros:
*        nQuantSequencia - Quantidade de sequencias a serem geradas
*        nGrupos         - Quantidade de grupos por sequencia
*	
*	Retorno:
*        Self              - Objeto Criado
*
*/
METHOD New( nQuantSequencia, nGrupos ) CLASS hbGrupos

	::nQuantidade := iif( .not. HB_ISNIL( nQuantSequencia ), nQuantSequencia,  1 )
	::nGrupos     := iif( .not. HB_ISNIL( nGrupos ), nGrupos, 1 )

return QSelf()


/***
*
*  :CreateTmpFile()
*
*	 Realiza a criacao do arquivo e indice temporario
*
*/
METHOD PROCEDURE CreateTmpFile() CLASS hbGrupos

local oErrLocal

    // Realiza a criacao e abertura do arquivo temporario de combinacoes
    begin sequence with { |oErr| break( oErr ) }
    
        // Realiza a criacao e abertura do arquivo temporario de combinacoes
        dbCreate( ::cFileTmp, 	{	{ 'GRP_CODGRP', 'C', 15, 0 }, ; // Codigo do Grupo
                                    { 'GRP_CODCOM', 'C', 14, 0 }, ; // Codigo da Combinacao
                                    { 'GRP_DEZENA', 'C', 53, 0 }  ; // Sequencia da Dezena Gerada
                                } )
        dbUseArea( pTRUE,, ::cFileTmp, ::cAliasTmp, pTRUE )
        ordCreate( ::cIndTmp, 'COD_GRP', 'GRP_CODGRP+GRP_CODCOM', {|| FIELD->GRP_CODGRP+FIELD->GRP_CODCOM } )
        
    recover using oErrLocal
        IF oErrLocal:genCode != 0
            ::lErrComb := pTRUE
            ::cErrComb := oErrLocal:description
        EndIf
    end sequence

return