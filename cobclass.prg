/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*	Classes para geracao Combinatoria.
*
*	Objetos:
*            :mtxCombOcu   - Ponteiro utilizado como semaforo para execucao das rotinas
*            :mtxGrupOcu   - 
*            :lIsExecuting - Variavel para evitar a execucao da rotina em duplicidade
*            :ArqComb      - Arquivo temporario de Combinacoes
*            :IndComb      - Indice temporario de Combinacoes
*            :AliasComb    - Alias para a tabela de combinacoes
*            :DicioComb    - Dicionario interno das combinacoes
*            :nPointerComb - Controle interno para o vetor DicioComb
*            :aCacheComb   - Cache para armazenar antes da gravavao as sequencias geradas
*            :nCorreComb   - Varivel atualizada com o registro corrente processado de combinacoes
*            :lErrComb     - Altera o conteudo caso tenha ocorrido algum erro de execucao
*            :cErrComb     - Informa a descricao do erro ocorrido

*            :ArqGrup           AS CHARACTER INIT ''                            // Arquivo temporario de Grupos Combinados
*            :IndGrup           AS CHARACTER INIT ''                            // Indice temporario de Grupos Combinados
*            :AliasGrup         AS CHARACTER INIT 'tmp_grup'                    // Alias para a tabela de Grupos Combinados
*            :cCodCurrGrup      AS CHARACTER INIT ''                            // * Codigo do Registro Corrente
*            :nRecCurrGrup      AS NUMERIC   INIT 0                             // * Sequencia do registro corrente Processado
*            :aBufferGrup       AS ARRAY     INIT {}                            // * Registro Corrente
*            :DicioGrup         AS ARRAY                                        // * Dicionario interno das Grupos Combinados
*            :PointerGrup       AS NUMERIC   INIT 1                             // * Controle interno para o vetor DicioComb
*            :CacheGrup         AS ARRAY     INIT {}                            // * Cache para armazenar antes da gravavao as sequencias geradas
*            :lErrGrup          AS LOGICAL   INIT FALSE                         // Altera o conteudo caso tenha ocorrido algum erro de execucao
*            :cErrGrup          AS CHARACTER INIT ''                            // Informa a descricao do erro ocorrido
		
*            :Sequencia         AS ARRAY                                        // ** Relacao de sequencias a serem combinadas
*            :Quantidade        AS NUMERIC   INIT 0                             // ** Quantidade de Grupos de dezenas a serem combinadas
*            :VAR Grupos            AS NUMERIC   INIT 0                             // ** Quantidade de Grupos de dezenas a serem combinadas
*            :MaxCacheComb      AS NUMERIC   INIT 4096                          // ** Sequencia gerada para ser grada no arquivo
*            :MaxCacheGrup      AS NUMERIC   INIT 8192                          // ** Sequencia gerada para ser grada no arquivo
*            :Corrente          AS NUMERIC   INIT 0                             // ** Varivel atualizada com o registro corrente processado
*            :Total             AS NUMERIC   INIT 0                             // ** Varivel contendo a quantidade total de registros a serem processados
*            :ReadBuffers       AS ARRAY     INIT {}		                        // Array com as informacoes do registro corrente.


*            :Bottom - Define a linha final para o posicionamento da janela
*            :Right  - Define a coluna final para o posicionamento da janela
*            :Border - Define o formato da borda da janela
*            :Color  - Define a cor da janela
*            :Header - Define a mensagem apresentada no topo da janela
*
*	Metodos:
*            :Open()  - Cria o objeto
*            :Open()  - Exibe na tela o objeto criado
*            :Close() - Fecha o objeto criado
*/

/*
Combinacoes possiveis.
LF - 3.268.760
LM - 47.129.212.243.960
MS - 50.063.860
QN - 24.040.016
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
*	hbCombina
*
*	Classe para a geracao geracao de combinacoes de sequencia
*
*	Objetos:
*            :mLockCache      - Ponteiro para controle interno
*            :mLockThread     - Ponteiro para controle das threads em execucao
*            :lIsRunning      - Variavel informando o status da execucao
*            :aSequencia      - Relacao dos valores a serem analisados
*            :nQuantSequencia - Quantidade de Grupos de dezenas a serem combinadas
*            :nCorrente       - Valor do registro corrente processado
*            :nPercentual     - Percentual realizado
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
CREATE CLASS hbCombina

	HIDDEN:
		VAR mLockCache        AS USUAL     INIT hb_mutexCreate() PROTECTED
		VAR mLockThread       AS USUAL     INIT hb_mutexCreate() PROTECTED
		VAR lIsRunning        AS LOGICAL   INIT pFALSE           PROTECTED

	EXPORTED:
		VAR aSequencia        AS ARRAY     INIT {}
		VAR nQuantSequencia   AS NUMERIC   INIT 0
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

		VAR lErrComb          AS LOGICAL   INIT pFALSE
		VAR cErrComb          AS CHARACTER INIT ''


	METHOD New( aSequencia, nQuantSequencia )
	METHOD CreateTmpFile()
	METHOD Execute()
	METHOD Percent()               INLINE ( ( ::nCorrente / ::nTotal )  * 100 )
	METHOD Processa()
	METHOD UpdateTmp()
	METHOD End()

	HIDDEN:
		METHOD Stable()            INLINE ( Len( ::aCache ) > 0 .or. ::nPointer > 0 )
		METHOD ControlThread( bCode )
		METHOD ParseString( aArray )
		METHOD GetNextFile()
		METHOD Log( nProc )

	EXPORTED:
		METHOD Eof()               INLINE ( ::cAliasTmp )->( Eof() )
		METHOD GoTop()             INLINE ( ::cAliasTmp )->( dbGoTop() )
		METHOD Skip( n )           INLINE ( ::cAliasTmp )->( dbSkip( n ) )
		METHOD Seek( a, b, c )     INLINE ( ::cAliasTmp )->( dbSeek( a, b, c  ) )

END CLASS


/***
*
*	:New( aSequencia, nQuantSequencia ) --> Self
*
*	Metodo utilizado para a criacao do objeto
*
*	Parametros:
*        ::aSequencia      - Array contendo a sequencia a ser processada
*        ::nQuantSequencia - Quantidade do grupo de sequencia
*	
*	Retorno:
*        Self              - Objeto Criado
*
*/
METHOD New( aSequencia, nQuantSequencia ) CLASS hbCombina

	::aSequencia      := iif( .not. HB_ISNIL( aSequencia ), aSequencia,  {} )
	::nQuantSequencia := iif( .not. HB_ISNIL( nQuantSequencia ), nQuantSequencia, 0 )

return QSelf()


/***
*
*  :CreateTmpFile()
*
*	 Realiza a criacao do arquivo e indice temporario
*
*/
METHOD PROCEDURE CreateTmpFile() CLASS hbCombina

local oErrLocal

	// Realiza a criacao e abertura do arquivo temporario de combinacoes
	begin sequence with { |oErr| break( oErr ) }
	
		// Realiza a criacao e abertura do arquivo temporario de combinacoes
		dbCreate( ::cFileTmp, 	{	{ 'COB_CODCOM', 'C', 14, 0 }, ; // Codigo do Combinacao Gerada
									{ 'COB_DEZENA', 'C', 53, 0 }  ; // Sequencia Gerada
								} )          
		dbUseArea( pTRUE,, ::cFileTmp, ::cAliasTmp, pTRUE )
		ordCreate( ::cIndTmp, 'COD_COB', 'COB_CODCOM', {|| FIELD->COB_CODCOM } )
		
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
METHOD Execute() CLASS hbCombina

local lRetValue     := pFALSE
local nElementos    := 1
local nAgrupamentos := 1
local nPos


	If HB_ISARRAY( ::aSequencia ) .and. Len( ::aSequencia ) > 0
		If ::nQuantSequencia  > 0

			// Define o nome do arquivo temporario para os grupos
			::cAliasTmp := 'TMP_COMBINA'
			::cFileTmp  := ::GetNextFile()
			::cIndTmp   := ::GetNextFile()


			// Array para controle do dicionario das combinacoes geradas
			::aDicionario := Array( ::nQuantSequencia, 0 )


			// Calcula o tamanho do cache conforme a memoria disponivel
			::nMaxCache := Int( ( 60 / 100 ) * Memory( HB_MEM_VM ) )


			//
			// Realiza o calculo atualizando a variavel com total das combinacoes possiveis
			//
			for nPos := Len( ::aSequencia ) to ( Len( ::aSequencia ) - ( ::nQuantSequencia -1 ) ) step -1
				nElementos := Int(nElementos * iif( Val( ::aSequencia[ nPos ] ) == 0, 100, Val( ::aSequencia[ nPos ] ) ))
			next


			for nPos := 1 to ::nQuantSequencia
				nAgrupamentos *= Val( ::aSequencia[ nPos ] )
			next


			// Numero total de elementos a serem processados
			::nTotal := Int( nElementos / nAgrupamentos )


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
			::cDescErro := 'Nao foi informado o parametro com a quantidade de combinacoes a ser gerada'
		EndIf
	Else
		::lErro     := pTRUE
		::cDescErro := 'Nao foi informado a sequencia para analise'
	EndIf

return lRetValue


/***
*
*  :Processa()
*
*	 Realiza o processaento das combinacoes
*
*/
METHOD PROCEDURE Processa() CLASS hbCombina

local lFound
local nPos
local nLen
local lWaitWrtCache := pTRUE
local cDezena


	while pTRUE
		
		If ::nPointer <= ::nQuantSequencia
			
			for each cDezena in ::aSequencia 
				lFound := pFALSE
				AEval( ::aDicionario, { |xItem| ;
										iif( hb_AScan( xItem, cDezena,,, pTRUE ) > 0, lFound := pTRUE, Nil ) }, 1, ::nPointer )

				If .not. lFound
					AAdd( ::aDicionario[ ::nPointer ], cDezena)
					If ::nPointer <= ::nQuantSequencia
						::nPointer++
						::Processa()
					EndIf
				EndIf

			next
			
			// Elimina Itens do vetor
			nLen := Len( ::aDicionario[ ::nPointer ] )
			for nPos := nLen to 1 step -1
				ADel( ::aDicionario[ ::nPointer ], nPos )
				ASize( ::aDicionario[ ::nPointer ], Len( ::aDicionario[ ::nPointer ] ) -1 )
			next
			::nPointer--
			exit
			
		Else
			
			while lWaitWrtCache
				//If HB_ISARRAY( ::CacheComb ) .or. Len( ::CacheComb ) < ::MaxCacheComb
				// Atualiza o array aCache com a sequencia gerada
				If Len( ::aCache ) < ::nMaxCache
					If hb_mutexLock( ::mLockCache )
						// Atualiza a Variavel com o registro corrente Processado
						::nCorrente += 1
						
						// Armazena o grupo gerado no vetor de Cache
						AAdd( ::aCache, { ::nCorrente, {} } )
						AEval( ::aDicionario, { |xItem| ;
												AAdd( ATail( ::aCache )[2], ATail( xItem ) ) } )
						
						::nPointer--
						hb_mutexUnlock( ::mLockCache )

						::Log( 1 )
						
						lWaitWrtCache := pFALSE
						hb_dispOutAt( MaxRow() - 2, 1, PadL( 'COMB: '+AllTrim(Str(Len( ::aCache )))+'/'+AllTrim(Str(Len(::aDicionario))), 25 ))
						
					EndIf
				EndIf

			enddo
			exit
			
		EndIf
		
	enddo
		
return


/***
*
*  ::UpdateTmp()
*
*  Atualiza a tabela temporaria.
*
*/
METHOD PROCEDURE UpdateTmp() CLASS hbCombina

local nPos
local oErrLocal
local nHandle
local nLen

	::Log(  , 'ENTROU NO UPDATE - Cache:' + AllTrim(Str(Len(::aCache))) )
	::Log(  , 'ENTROU NO UPDATE - MaxCache:' + AllTrim(Str(::nMaxCache)) )
	::Log(  , 'ENTROU NO UPDATE - Pointer:' + AllTrim(Str(::nPointer)) )	

	// Verifica se existe conteudo na variavel de Cache
	If Len( ::aCache ) >= ::nMaxCache .or. ::nPointer = 0

		::Log(  , 'ENTROU NA VALIDA' )

		begin sequence with { |oErr| break( oErr ) }

			If hb_mutexLock( ::mLockCache )

				dbUseArea( pTRUE,, ::cFileTmp, 'TMP', pTRUE )
				ordCreate( ::cIndTmp, 'COD_COB', 'COB_CODCOM', {|| FIELD->COB_CODCOM } )		

				nLen := Len( ::aCache )
				for nPos := nLen to 1 step -1

					hb_dispOutAt( MaxRow() - 1, 1, PadL( 'COMB GRV: '+AllTrim(Str(nPos))+'/'+AllTrim(Str(Len(::aCache))), 25 ))
				
					TMP->( dbAppend() )
					TMP->COB_CODCOM := StrZero( ::aCache[ nPos ][1], 14 )
					TMP->COB_DEZENA := ::ParseString( ::aCache[ nPos ][2] )
					TMP->( dbUnlock() )

					::Log( 2, TMP->COB_CODCOM + '[ ' + TMP->COB_DEZENA + ']' )

					ADel( ::aCache, nPos )
					ASize( ::aCache, Len( ::aCache ) -1 )
					
				next

				TMP->( dbCloseArea() )

				hb_mutexUnlock( ::mLockCache )

				::Log( 2, 'PASSOU UNLOCK' )
				
			EndIf

		recover using oErrLocal
			If oErrLocal:genCode != 0
				::lErrComb := pTRUE
				::cErrComb := oErrLocal:description
			EndIf
		end sequence

	EndIf

return


/***
*
*  :End()
*
*  Finaliza a execucao do Objetobjeto
*
*/
METHOD PROCEDURE End() CLASS hbCombina

local oErrLocal
local nPos


	// Realiza o fechamento do arquivo temporario
	begin sequence with { |oErr| break( oErr ) }

		// Finaliza todas as Threads
		hb_threadTerminateAll()
		
		// Fecha a tabela temporaria
		(::cAliasTmp)->( dbCloseArea() )

		// Elimina o arquivo temporario
		FErase( ::cFileTmp )
		FErase( ::cIndTmp )

		// Funcao para teste
		hb_gcAll()

	recover using oErrLocal
		If oErrLocal:genCode != 0
			::lErrComb := pTRUE
			::cErrComb := oErrLocal:description
		EndIf
	end sequence

return


/***
*
*  :Log()
*
*  Finaliza a execucao do Objetobjeto
*
*/
METHOD PROCEDURE Log( nProc, cDados ) CLASS hbCombina

local nHandle
local cFile  := hb_DirBase() + 'log.txt'
local cWrite := DToS( Date() ) + '-' + Time() + '-'

	DEFAULT nProc TO 0, ;
			cDados to ''

	do case
		case nProc == 1
			cWrite += 'PROCESSA - '  + AllTrim( cDados ) + Chr(13) + Chr(10)
		case nProc == 2
			cWrite += 'GRAVA - ' + AllTrim( cDados ) + Chr(13) + Chr(10)
		otherwise
			cWrite += 'GRAVA - ' + AllTrim( cDados ) + Chr(13) + Chr(10)
	end case

	If .not. File( cFile )
		FCreate( cFile )
	EndIf

	If ( nHandle := fopen( cFile, FO_READWRITE + FO_SHARED ) ) > 0
		FSeek( nHandle, 0, FS_END )
		FWrite( nHandle, AllTrim(cWrite), Len( AllTrim(cWrite)) )
		FClose( nHandle )
	EndIf

return


/***
*
*  ::ControlThread( <bCode> ) --> lRetStatus
*
*	 Controle as Thread em execucao.
*
*	Parametros:
*        <bCode>          - Array a ser processado.
*
*	Retorno:
*        lRetValue  - Valor logico

*/
METHOD ControlThread( bCode ) CLASS hbCombina

static aThreadList := {}

local nCont
local lRetValue := pFALSE


	begin sequence

		If hb_MutexLock( ::mLockThread )
		
			If HB_ISNIL( bCode )
				If Len( aThreadList ) != 0
					lRetValue := pFALSE
					for nCont := Len( aThreadList ) to 1 step -1
						If hb_ThreadWait( aThreadList[ nCont ], 0.1, pTRUE ) != 1
							lRetValue := pTRUE
						Else
							ADel( aThreadList, nCont )
							ASize( aThreadList, Len( aThreadList ) - 1 )
						EndIf
					next
				EndIf
			Else
				Aadd( aThreadList, hb_ThreadStart( 	HB_BITOR( HB_THREAD_INHERIT_PUBLIC, ;
													HB_THREAD_INHERIT_PRIVATE,          ;
													HB_THREAD_INHERIT_MEMVARS ),        ;
													bCode ) )
			EndIf

		EndIf

	always
		hb_MutexUnlock( ::mLockThread )
	end sequence

return lRetValue


/***
*
*  :ParseString( <aArray> ) --> cRetValue
*
*   Transforma o conteudo do array no formato para gravacao string para gravacao.
*
*	Parametros:
*        <aArray>          - Array a ser processado.
*
*	Retorno:
*        cRetValue         - String com o conteudo do array passado como paramtro.
*
*/
METHOD ParseString( aArray ) CLASS hbCombina

local cRetValue := ''
local nCount    := 0
local nLen


	If HB_ISARRAY( aArray ) .and. Len( aArray ) > 0
		nLen := Len( aArray )
		for nCount := 1 to nLen
			cRetValue += aArray[ nCount ]
			cRetValue += iif( Len( aArray ) > nCount, '-', '' )
		next
	EndIf
		
return( cRetValue )


/***
*
*  :GetNextFile() --> cRetValue
*
*  cCaminho  : Parametro onde e informado o caminho em que o arquivo sera gerado.
*
*/
METHOD GetNextFile() CLASS hbCombina

local cRetValue := ''

	while File( cRetValue := hb_DirBase() + StrZero( hb_RandInt( 99999999 ), 8 ) + '.tmp' ) 
	enddo

return cRetValue



******* Edilson
	



CLASS TLFCombine
	
	HIDDEN:
		VAR mtxCombOcu        AS USUAL     INIT hb_mutexCreate() PROTECTED    // Ponteiro utilizado como semaforo para execucao das rotinas
		VAR mtxGrupOcu        AS USUAL     INIT hb_mutexCreate() PROTECTED    // Ponteiro utilizado como semaforo para execucao das rotinas
		VAR lIsExecuting      AS LOGICAL   INIT pFALSE           PROTECTED    // Variavel para evitar a execucao da rotina em duplicidade
	
	EXPORTED:
		VAR cFileName         AS CHARACTER INIT ''                            // Arquivo contendo as combinacoes

		VAR aSequencia        AS ARRAY     INIT {}                            // Variavel relacionando as sequencias a serem combinadas
		VAR nQuantSequencia   AS NUMERIC   INIT 0                             // ** Quantidade de Grupos de dezenas a serem combinadas
		VAR nQuantGrupos      AS NUMERIC   INIT 0                             // ** Quantidade de Grupos de dezenas a serem combinadas
		VAR nTotal            AS NUMERIC   INIT 0                             // Total de registros a serem processados

		VAR aDicioComb        AS ARRAY     INIT {}                            // Dicionario interno para controle das sequencias combinadas
		VAR nPointer          AS NUMERIC   INIT 1                             // Controle interno para o vetor DicioComb
		VAR aCacheComb        AS ARRAY     INIT {}                            // Cache para armazenar antes da gravavao as sequencias geradas
		VAR nCorreComb        AS NUMERIC   INIT 0                             // Varivel atualizada com o registro corrente processado de combinacoes
		VAR nMaxCacheComb     AS NUMERIC   INIT 4096                          // ** Sequencia gerada para ser grada no arquivo
		VAR nCorreComb        AS NUMERIC   INIT 0                             // Varivel atualizada com o registro corrente processado de combinacoes

		VAR aDicioGrup        AS ARRAY     INIT {}                            // Dicionario interno para controle dos grupos combinadas
		VAR nPointerGrup      AS NUMERIC   INIT 1                             // Controle interno para o vetor DicioComb
		VAR aCacheGrup        AS ARRAY     INIT {}                            // * Cache para armazenar antes da gravavao as sequencias geradas		
		VAR nRecCurrGrup      AS NUMERIC   INIT 0                             // * Sequencia do registro corrente Processado
		VAR nMaxCacheGrup     AS NUMERIC   INIT 8192                          // ** Sequencia gerada para ser grada no arquivo

		VAR cArqFileGrp       AS CHARACTER INIT ''                            // Nome do arquivo temporario para o arquivo de dados para os grupos
		VAR cIndFileGrp       AS CHARACTER INIT ''                            // Nome do arquivo temporario para o arquivo de Indice de grupos
		VAR cArqFileCob       AS CHARACTER INIT ''                            // Nome do arquivo temporario para o arquivo de dados para as combinacoes
		VAR cIndFileCob       AS CHARACTER INIT ''                            // Nome do arquivo temporario para o arquivo de Indice de combinacoes

		VAR lErrComb          AS LOGICAL   INIT pFALSE                        // Altera o conteudo caso tenha ocorrido algum erro de execucao
		VAR cErrComb          AS CHARACTER INIT ''                            // Informa a descricao do erro ocorrido


		METHOD New( aSequencia, nQuantSequencia, nGrupos )                    // Cria o Objeto
		METHOD CreateCopFile()                                                // Realiza a criacao do arquivo temporario para combinacoes
		METHOD CreateGrpFile()                                                // Realiza a criacao do arquivo temporario para grupos
		METHOD Execute()                                                      // Inicia a execucao do objeto
		METHOD ControleThread( bCode )                                        // Controle as Threads em execucao
		METHOD GeraComb()
		METHOD GeraGrup()
		METHOD Status()                                                       // Retorna o Status da execucao em execucao
		METHOD CommitComb()                                                   // Realiza a gravacao dos dados em cache no arquivo
		METHOD CommitGrup()                                                   // Realiza a gravacao dos dados em cache no arquivo Grupos Combinados
		METHOD Close()                                                        // Fecha e Elimina o Arquivo temporario

		METHOD ParseString( aArray )                                          // Converte o Conteudo do vetor em String para gravação no arquivo

END CLASS


/***
*
*  ::New( aSequencia, nQuantidade ) --> Self
*
*	 Realiza a criação do objeto.
*
*/
METHOD New( cFileName, aSequencia, nQuantSequencia, nQuantGrupos ) CLASS TLFCombine

	::cFileName       := iif( .not. HB_ISNIL( cFileName ), cFileName,  '' )
	::aSequencia      := iif( .not. HB_ISNIL( aSequencia ), aSequencia,  {} )
	::nQuantSequencia := iif( .not. HB_ISNIL( nQuantSequencia ), nQuantSequencia, 0 )
	::nQuantGrupos    := iif( .not. HB_ISNIL( nQuantGrupos ), nQuantGrupos, 0 )

return QSelf()


/***
*
*  ::CreateGrupFile()
*
*  Metodo para a criacao e abertura do arquivo temporario para grupos
*
*/
METHOD PROCEDURE CreateGrpFile() CLASS TLFCombine

local oErrLocal

	// Realiza a criacao e abertura do arquivo temporario de combinacoes
	begin sequence with { |oErr| break( oErr ) }

		// Realiza a criacao e abertura do arquivo temporario de grupos
		dbCreate( ::cArqFileGrp, 	{ 	{ 'GRP_CODGRP', 'C', 15, 0 }, ; // Codigo do Grupo
										{ 'GRP_CODCOM', 'C', 14, 0 }, ; // Codigo da Combinacao
										{ 'GRP_DEZENA', 'C', 53, 0 }  ; // Sequencia da Dezena Gerada
									} )          
		dbUseArea( pTRUE,, ::cArqFileGrp, 'TMP_GRUPOS', pFALSE )
		ordCreate( ::cIndFileGrp, 'COD_GRP', 'GRP_CODGRP+GRP_CODCOM', {|| FIELD->GRP_CODGRP + FIELD->GRP_CODCOM } )

	recover using oErrLocal
		If oErrLocal:genCode != 0
			::lErrComb := pTRUE
			::cErrComb := oErrLocal:description
		EndIf
	end sequence

return


/***
*
*  ::CreateCompFile()
*
*	 Realiza a criação do objeto.
*
*/
METHOD PROCEDURE CreateCopFile() CLASS TLFCombine

local oErrLocal

	// Realiza a criacao e abertura do arquivo temporario de combinacoes
	begin sequence with { |oErr| break( oErr ) }
	
		// Realiza a criacao e abertura do arquivo temporario de combinacoes
		dbCreate( ::cArqFileCob, 	{	{ 'COB_CODCOM', 'C', 14, 0 }, ; // Codigo do Combinacao Gerada
										{ 'COB_DEZENA', 'C', 53, 0 }  ; // Sequencia Gerada
									} )          
		dbUseArea( pTRUE,, ::cArqFileCob, 'TMP_COMBINA', pFALSE )
		ordCreate( ::cIndFileCob, 'COD_COB', 'COB_CODCOM', {|| FIELD->COB_CODCOM } )
		
	recover using oErrLocal
		If oErrLocal:genCode != 0
			::lErrComb := pTRUE
			::cErrComb := oErrLocal:description
		EndIf
	end sequence

return


/***
*
*  ::Execute() --> lValue
*
*	 Inicia a execucao do objeto
*
*/
METHOD Execute() CLASS TLFCombine

local lRetValue     := pFALSE
local nElementos    := 1
local nAgrupamentos := 1
local nPos

	If ISCHARACTER( ::cFileName ) .and. .not. Empty( ::cFileName )
		If HB_ISARRAY( ::aSequencia ) .and. Len( ::aSequencia ) > 0
			If ::nQuantSequencia  > 0
				If ::nQuantGrupos  > 0

					// Define o nome do arquivo temporario para os grupos
					::cArqFileGrp := GetNextFile( SystemTmp(), 'tmp' )
					::cIndFileGrp := GetNextFile( SystemTmp(), 'tmp' )

					// Define o nome do arquivo temporario para as combinacoes
					::cArqFileCob := GetNextFile( SystemTmp(), 'tmp' )
					::cIndFileCob := GetNextFile( SystemTmp(), 'tmp' )


					// Array para controle do dicionario das combinacoes geradas
					::aDicioComb := Array( ::nQuantSequencia, 0 )
					
					// Array para controle do dicionario do Grupo de Combinacoes
					::aDicioGrup := Array( ::nQuantGrupos, 0 )
					
					//
					// Realiza o calculo atualizando a variavel com total das combinacoes possiveis
					//
					for nPos := Len( ::aSequencia ) to ( Len( ::aSequencia ) - ( ::nQuantSequencia -1 ) ) step -1
						nElementos := Int(nElementos * iif( Val( ::aSequencia[ nPos ] ) == 0, 100, Val( ::aSequencia[ nPos ] ) ))
					next
					
					for nPos := 1 to ::nQuantSequencia
						nAgrupamentos *= Val( ::aSequencia[ nPos ] )
					next
					::nTotal := Int( nElementos / nAgrupamentos )
					//::nTotal *= ::nQuantGrupos

					::CreateGrpFile()
					::CreateCopFile()

					// Controla a inicializacao das threads
					If .not. ::lIsExecuting .and. .not. ::lErrComb

// Desabilita a execucao da Thread em DEBUG
#if __pragma( DEBUGINFO )						
						::GeraComb()
						::GeraGrup()

						::CommitComb()
						::CommitGrup()
#else
						::ControleThread( { || ::GeraComb() } )
						::ControleThread( { || ::GeraGrup() } )
#endif
						::lIsExecuting := pTRUE
					EndIf

					// Atualiza a variavel de retorno
					lRetValue := pTRUE
					
				Else
					::lErro     := pTRUE
					::cDescErro := 'Nao foi informado o parametro com a quantidade de grupos a ser gerada'	
				EndIf
			Else
				::lErro     := pTRUE
				::cDescErro := 'Nao foi informado o parametro com a quantidade de combinacoes a ser gerada'
			EndIf
		Else
			::lErro     := pTRUE
			::cDescErro := 'Nao foi informado a sequencia para analise'
		EndIf
	Else
		::lErro     := pTRUE
		::cDescErro := 'Nome do arquivo nao foi informado no parametro'
	EndIf

return lRetValue



/***
*
*  ::Status() --> lRetValue
*
*	 Retorna o status das rotinas sendo executadas.
*
*/
METHOD Status() CLASS TLFCombine

local lRetCtrlThread := pFALSE
local lRetCombCommit := pFALSE
local lRetGrupCommit := pFALSE

	// Caso nao tenha ocorrido nenhum erro na criacao dos arquivos temporarios
	If .not. ::lErrComb
		lRetCtrlThread := ::ControleThread()
		lRetCombCommit := ::CommitComb()
		lRetGrupCommit := ::CommitGrup()
	EndIf
		
return ( lRetCtrlThread .and. lRetCombCommit .and. lRetGrupCommit )


/***
*
*  ::ControleThread() --> lRetValue
*
*  Realiza o Controle as Thread em execucao.
*
*/
METHOD ControleThread( bCode ) CLASS TLFCombine

static aThreadList := {}
static s_Mutex     := hb_mutexCreate()

local nCont
local lIsRunning   := pFALSE


	begin sequence

		hb_MutexLock( s_Mutex )
		
		If HB_ISNIL( bCode )
			If Len( aThreadList ) != 0
				lIsRunning := pFALSE
				for nCont := Len( aThreadList ) to 1 step -1
					If hb_threadWait( aThreadList[ nCont ], 0.1, pTRUE ) != 1
						lIsRunning := pTRUE
					Else
						ADel( aThreadList, nCont )
						ASize( aThreadList, Len( aThreadList ) - 1 )
					EndIf
				next
			EndIf
		Else
			AAdd( aThreadList, hb_threadStart( 	HB_BITOR( 	HB_THREAD_INHERIT_PUBLIC,    ;
															HB_THREAD_INHERIT_PRIVATE,   ;
															HB_THREAD_INHERIT_MEMVARS    ;
														),                               ;
												bCode )                                  ;
				)
		EndIf
	always
		hb_MutexUnlock( s_Mutex )
	end sequence

return lIsRunning


/***
*
*  ::GeraComb() --> Nil
*
*	 Processa a sequencia gravando os grupos gerados no vetor CacheComb.
*
*/
METHOD PROCEDURE GeraComb() CLASS TLFCombine

local lFound
local nPos
local lWaitWrtCache := pTRUE
local cDezena


	while pTRUE
		
		If ::nPointer <= ::nQuantSequencia
			
			for each cDezena in ::aSequencia 
				lFound := pFALSE
				AEval( ::aDicioComb, { |xItem| ;
										iif( hb_AScan( xItem, cDezena,,, pTRUE ) > 0, lFound := pTRUE, Nil ) }, 1, ::nPointer )

				If .not. lFound
					AAdd( ::aDicioComb[ ::nPointer ], cDezena)
					If ::nPointer <= ::nQuantSequencia
						::nPointer++
						::GeraComb()
					EndIf
				EndIf

			next
			
			// Elimina Itens do vetor
			for nPos := Len( ::aDicioComb[ ::nPointer ] ) to 1 step -1
				ADel( ::aDicioComb[ ::nPointer ], nPos )
				ASize( ::aDicioComb[ ::nPointer ], Len( ::aDicioComb[ ::nPointer ] ) -1 )
			next
			::nPointer--
			exit
			
		Else
			
			while lWaitWrtCache
				//If HB_ISARRAY( ::CacheComb ) .or. Len( ::CacheComb ) < ::MaxCacheComb
				If Len( ::aCacheComb ) < ::nMaxCacheComb
					If hb_mutexLock( ::mtxCombOcu )
						// Atualiza a Variavel com o registro corrente Processado
						::nCorreComb += 1
						
						// Armazena o grupo gerado no vetor de Cache
						AAdd( ::aCacheComb, { ::nCorreComb, {} } )
						AEval( ::aDicioComb, { |xItem| AAdd( ATail( ::aCacheComb )[2], ATail( xItem ) ) } )
						
						::nPointer--
						hb_mutexUnlock( ::mtxCombOcu )
						
						lWaitWrtCache := pFALSE
						hb_dispOutAt( MaxRow() - 2, 1, PadL( 'COMB: '+AllTrim(Str(Len( ::aCacheComb )))+'/'+AllTrim(Str(Len(::aDicioComb))), 25 ))
						
					EndIf
				EndIf
			enddo
			exit
			
		EndIf
		
	enddo
		
return


/***
*
*  ::GeraGrup() --> Nil
*
*	 Processa a sequencia gravando os grupos gerados no vetor CacheGrup.
*
*/
METHOD PROCEDURE GeraGrup() CLASS TLFCombine

local lFound
local nPos
local lWaitWrtCache := pTRUE

	while pTRUE
		
		If ::nPointerGrup <= ::nQuantGrupos
			
			for nPos := 1 to ::nTotal
				lFound := pFALSE
				AEval( ::aDicioGrup, { |xItem| ;
										iif(  hb_AScan( xItem, nPos,,, pTRUE ) > 0, lFound := pTRUE, Nil ) }, 1, ::nPointerGrup )
				If .not. lFound
					AAdd( ::aDicioGrup[ ::nPointerGrup ], nPos )
					If ::nPointerGrup <= ::nQuantGrupos
						::nPointerGrup++
						::GeraGrup()
					EndIf
				EndIf
			next
			
			// Elimina Itens do vetor
			for nPos := Len( ::aDicioGrup[ ::nPointerGrup ] ) to 1 step -1
				ADel( ::aDicioGrup[ ::nPointerGrup ], nPos )
				ASize( ::aDicioGrup[ ::nPointerGrup ], Len( ::aDicioGrup[ ::nPointerGrup ] ) -1 )
			next
			::nPointerGrup--
			exit
			
		Else
			while lWaitWrtCache
				If Len( ::aCacheGrup ) < ::nMaxCacheGrup
					If hb_mutexLock( ::mtxGrupOcu )
						// Atualiza a Variavel com o registro corrente Processado
						::nRecCurrGrup += 1
						
						// Armazena o grupo gerado no vetor de Cache
						AAdd( ::aCacheGrup, { ::nRecCurrGrup, {} } )
						AEval( ::aDicioGrup, { |xItem| ;
								AAdd( ATail( ::aCacheGrup )[2], ATail( xItem ) ) } )
						
						::nPointerGrup--
						hb_mutexUnlock( ::mtxGrupOcu )

						lWaitWrtCache := pFALSE
						hb_dispOutAt( MaxRow() - 2, 50, PadL('GRUPOS: '+AllTrim(Str(Len( ::aCacheGrup ))) + '/' + AllTrim(Str(Len(::aDicioGrup))), 25 ))

					EndIf
				EndIf
			enddo
			exit
			
		EndIf
		
	enddo
		
return


/***
*
*  ::ParseString( <aArray> ) --> cRetValue
*
*	 Recebe um array com as Sequencia no qual sera convertido para uma string com o contendo do Array.
*
*   <aArray> : Vetor com as Dezenas a serem processadas.
*
*   cResult  : String contendo as dezenas do vetor agrupadas.
*
*/
METHOD ParseString( aArray ) CLASS TLFCombine

local cRetValue := ''
local nCount    := 0

	If HB_ISARRAY( aArray ) .and. Len( aArray ) > 0
		for nCount := 1 to Len( aArray )
			cRetValue += aArray[ nCount ]
			cRetValue += iif( Len( aArray ) > nCount, '-', '' )
		next
	EndIf
		
return( cRetValue )


/***
*
*  ::CommitComb() --> Nil
*
*	 Executa o procedimento para geração das sequencias.
*
*/
METHOD PROCEDURE CommitComb() CLASS TLFCombine

local nPos
local oErrLocal
local nHandle


	// Verifica se existe conteudo na variavel de Cache
	If Len( ::aCacheComb ) >= ::nMaxCacheComb .or. ::nPointer == 0
		
		begin sequence with { |oErr| break( oErr ) }
		
			If hb_mutexLock( ::mtxCombOcu )

				for nPos := Len( ::aCacheComb ) to 1 step -1

					hb_dispOutAt( MaxRow() - 1, 1, PadL( 'COMB GRV: '+AllTrim(Str(nPos))+'/'+AllTrim(Str(Len(::CacheComb))), 25 ))
				
					TMP_COMBINA->( dbAppend() )
					TMP_COMBINA->COB_CODCOM := StrZero( ::aCacheComb[ nPos ][1], 14 )
					TMP_COMBINA->COB_DEZENA := ::ParseString( ::aCacheComb[ nPos ][2] )
					TMP_COMBINA->( dbUnlock() )

					If .not. File( '/home/edilson/odin/combina.txt' )
						FCreate( '/home/edilson/odin/combina.txt' )
					EndIf

					If ( nHandle := fopen( '/home/edilson/odin/combina.txt' ) ) > 0
						FSeek( nHandle, 0, 2 )
						fwrite( nHandle, TMP_COMBINA->COB_CODCOM + '-' + TMP_COMBINA->COB_DEZENA + Chr(13) + Chr(10 ))
						FClose( nHandle )
					EndIf

					ADel( ::aCacheComb, nPos )
					ASize( ::aCacheComb, Len( ::aCacheComb ) -1 )
					
				next
				
				hb_mutexUnlock( ::mtxCombOcu )
			EndIf
			
		recover using oErrLocal
			If oErrLocal:genCode != 0
				::lErrComb := pTRUE
				::cErrComb := oErrLocal:description
			EndIf
		end sequence
		
	EndIf

return


/***
*
*  ::CommitGrup()
*
*	 Executa o procedimento para geração das sequencias.
*
*/
METHOD PROCEDURE CommitGrup() CLASS TLFCombine

local nPos
local nCount
local oErrLocal
local nHandle

	// Verifica se existe conteudo na variavel de Cache
	If Len( ::aCacheGrup ) >= ::nMaxCacheGrup .or. ::nPointerGrup == 0
		
		begin sequence with { |oErr| Break( oErr ) }
		
			If hb_mutexLock( ::mtxGrupOcu )
				
				for nPos := Len( ::aCacheGrup ) to 1 step -1
				
					hb_dispOutAt( MaxRow() - 1, 50, PadL('GRUP GRV: '+AllTrim(Str(nPos))+'/'+AllTrim(Str(Len( ::CacheGrup ))), 25 ))				
					
					If Len( ::CacheGrup[ nPos ][2] ) > 0
						for nCount := Len( ::aCacheGrup[ nPos ][2] ) to 1 step -1
						
							If TMP_GRUPOS->( dbSeek( StrZero( ::CacheGrup[ nPos ][2][ nCount ], 14 ) ) )
								
								TMP_GRUPOS->( dbAppend() )
								TMP_GRUPOS->GRP_CODGRP := StrZero( ::CacheGrup[ nPos ][1], 15 )
								TMP_GRUPOS->GRP_CODCOM := TMP_COMBINA->COB_CODCOM
								TMP_GRUPOS->GRP_DEZENA := TMP_COMBINA->COB_DEZENA
								TMP_GRUPOS->( dbUnlock() )

								If .not. File( '/home/edilson/odin/grupo.txt' )
									FCreate( '/home/edilson/odin/grupo.txt' )
								EndIf

								If ( nHandle := fopen( '/home/edilson/odin/grupo.txt' ) ) > 0
									FSeek( nHandle, 0, 2 )
									fwrite( nHandle, TMP_GRUPOS->GRP_CODCOM + '-' + TMP_GRUPOS->GRP_DEZENA + Chr(13) + Chr(10 ))
									FClose( nHandle )
								EndIf
								
								ADel( ::aCacheGrup[ nPos ][2], nCount )
								ASize( ::aCacheGrup[ nPos ][2], Len( ::aCacheGrup[ nPos ][2] ) -1 )
								
							EndIf
							
						next
						
					EndIf
					
					ADel( ::aCacheGrup, nPos )
					ASize( ::aCacheGrup, Len( ::aCacheGrup ) -1 )

/*					Else
						ADel( ::CacheGrup, nPos )
						ASize( ::CacheGrup, Len( ::CacheGrup ) -1 )
					EndIf */
					
				next
				hb_mutexUnlock( ::mtxGrupOcu )
			EndIf
		
		RECOVER USING oErrLocal
			If oErrLocal:genCode != 0
				::lErrGrup := pTRUE
				::cErrGrup := oErrLocal:description
			EndIf
		END SEQUENCE
		
	EndIf
								
return


/***
*
*  ::Close()
*
*	 Realiza o fechamento e a exclusao dos arquivos temporarios.
*
*/
METHOD PROCEDURE Close() CLASS TLFCombine

local oErrLocal

	// Realiza o fechamento do arquivo temporario
	begin sequence with { |oErr| break( oErr ) }
		
		// Fecha o Arquivo de Grupos
		TMP_GRUPOS->( dbCloseArea() )

		// Fecha o Arquivo de Grupos de Combinacoes
		TMP_COMBINA->( dbCloseArea() )
		
		// Elimina os arquivos temporarios de grupos
		FErase( ::cArqFileGrp )
		FErase( ::cIndFileGrp )

		// Elimina os arquivos temporarios de combinacoes
		FErase( ::cArqFileCob )
		FErase( ::cIndFileCob )

		// Funcao para teste
		hb_gcAll( )
	
	recover using oErrLocal
		If oErrLocal:genCode != 0
			::lErrComb := pTRUE
			::cErrComb := oErrLocal:description
		EndIf
	end sequence
			
return
