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
        VAR nTotalGrupos      AS NUMERIC   INIT 0
        VAR nQuantGrupos      AS NUMERIC   INIT 0

		VAR nCorrente         AS NUMERIC   INIT 0
		VAR nPercentual       AS NUMERIC   INIT 0
		VAR nTotal            AS NUMERIC   INIT 0
		VAR lStop             AS LOGICAL   INIT pFALSE

		VAR aDicionario       AS ARRAY     INIT {}
		VAR nPointer          AS NUMERIC   INIT 1
		VAR aCache            AS ARRAY     INIT {}
		VAR nMaxCache         AS NUMERIC   INIT 4096

		VAR cAliasTmp         AS CHARACTER INIT ''
		VAR cFileTmp          AS CHARACTER INIT ''
		VAR cIndTmp           AS CHARACTER INIT ''

		VAR lErrGrp           AS LOGICAL   INIT pFALSE
		VAR cErrGrp           AS CHARACTER INIT ''


	METHOD New( nQuantSequencia, nGrupos )
    METHOD CreateTmpFile()
    METHOD Execute()

    HIDDEN:
        METHOD Stable()            INLINE ( Len( ::aCache ) > 0 .or. ::nPointer > 0 )
        METHOD ControlThread( bCode )
		METHOD GetNextFile()

    
END CLASS


/***
*
*	:New( nTotalGrupos, nQuantGrupos ) --> Self
*
*	Metodo utilizado para a criacao do objeto
*
*	Parametros:
*        nTotalGrupos - Quantidade de total grupos a serem geradas
*        nQuantGrupos - Quantidade de grupos por sequencia
*	
*	Retorno:
*        Self         - Objeto Criado
*
*/
METHOD New( nTotalGrupos, nQuantGrupos ) CLASS hbGrupos

	::nTotalGrupos := iif( .not. HB_ISNIL( nTotalGrupos ), nTotalGrupos,  1 )
	::nQuantGrupos := iif( .not. HB_ISNIL( nQuantGrupos ), nQuantGrupos, 1 )

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
                                    { 'GRP_CODCOM', 'C', 14, 0 }  ; // Codigo da Combinacao
                                } )
        dbUseArea( pTRUE,, ::cFileTmp, ::cAliasTmp, pTRUE )
        ordCreate( ::cIndTmp, 'COD_GRP', 'GRP_CODGRP+GRP_CODCOM', {|| FIELD->GRP_CODGRP+FIELD->GRP_CODCOM } )
        
    recover using oErrLocal
        If oErrLocal:genCode != 0
            ::lErrComb := pTRUE
            ::cErrComb := oErrLocal:description
        EndIf
    end sequence

return


/***
*
*  :Execute() --> lRetValue
*
*	 Inicia a execucao do objeto
*
*/
METHOD Execute() CLASS hbGrupos

local lRetValue     := pFALSE


    If ::nTotalGrupos > 0
        If ::nQuantGrupos  > 0

            // Define o nome do arquivo temporario para os grupos
            ::cAliasTmp := 'TMP_GRUPOS'
            ::cFileTmp  := ::GetNextFile()
            ::cIndTmp   := ::GetNextFile()


            // Array para controle do dicionario das combinacoes geradas
            ::aDicionario := Array( ::nQuantGrupos, 0 )


            // Calcula o tamanho do cache conforme a memoria disponivel
            ::nMaxCache := Int( ( 60 / 100 ) * Memory( HB_MEM_VM ) )


            // Numero total de elementos a serem processados
            ::nTotal := ::nQuantGrupos * ::nTotalGrupos


            // Calcula o tamanho do cache conforme a memoria disponivel
            If ( ::nMaxCache := Int( ( 60 / 100 ) * Memory( HB_MEM_VM ) ) ) > ::nTotal
                ::nMaxCache := ::nTotal
            EndIf


            // Cria o arquivo temporario
            ::CreateTmpFile()


            // Controla a inicializacao das threads
            If .not. ::lIsRunning .and. .not. ::lErrComb
                ::lIsRunning := pTRUE
                // ::Processa()
                // ::UpdateTmp()

                ::ControlThread( { || ::Processa() } )
                while ::ControlThread() .or. ::Stable()
                    ::Log(  , 'RODOU UPDATE' )
                    ::ControlThread( { || ::UpdateTmp() } )
                enddo

                ::Log(  , 'FINALIZOU AS TASKS - Pointer:' + AllTrim( Str( ::nPointer ) ) )
                ::Log(  , 'FINALIZOU AS TASKS - Pointer:' + AllTrim( Str( Len( ::aCache ) ) ) )				

            EndIf

            // Atualiza a variavel de retorno
            lRetValue := pTRUE
                
        Else
            ::lErro     := pTRUE
            ::cDescErro := 'Nao foi informado a quantidade de grupos gerados por sequencia'
        EndIf
    Else
        ::lErro     := pTRUE
        ::cDescErro := 'Nao foi informado o total de grupos a ser gerado'
    EndIf

return lRetValue
