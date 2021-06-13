/*
* ODIN
* (C) 2020 Edilson Mendes Nascimento <edilson.mendes.nascimento@gmail.com>
*/

/***
*
*	Classes para Criacao de Rede Neural.
*
*/

#include 'hbclass.ch'

CLASS TNeuralNetwork

    VAR oInputLayer   AS OBJECT
    VAR aHiddenLayers AS ARRAY   INIT {}
    VAR oOutputLayer  AS OBJECT
    VAR nLearningRate AS NUMERIC INIT 0.1

    METHOD New( nInputs, aHiddenLayersNeurons, nOutputs )
    METHOD Learn( aInputs, aOutputs )
    METHOD Propagation( aInputs, aOutputs )
    METHOD BackPropagation( aInputs, aOutputs )

END CLASS


METHOD New( nInputs, aHiddenLayersNeurons, nOutputs) CLASS TNeuralNetwork

local n

    ::oInputLayer := TNeuralLayer():New( nInputs, nInputs)

    for n := 1 to Len( aHiddenLayersNeurons ) // Numero de Camadas Ocultas
        AAdd( ::aHiddenLayers, TNeuralLayer():New( aHiddenLayersNeurons[ n ], ;
        iif( n == 1, nInputs, aHiddenLayersNeurons[ n - 1 ] ) ) )
    next

    ::oOutputLayer := TNeuralLayer():New( nOutputs, ATail( aHiddenLayersNeurons ) )

return Self


METHOD PROCEDURE Learn( aInputs, aOutputs) CLASS TNeuralNetwork

local n

    ::Propagation( aInputs, aOutputs)
    ::BackPropagation( aInputs, aOutputs)

    ? 'Inputs:', aInputs
    
    for n := 1 to Len( ::oOutputLayer:aNeurons )
        ?? ',output:', ::oOutputLayer:aNeurons[ n ]:nValue
        ?? ', expected output:', aOutputs[ n ]
        ?? ', error:', ::oOutputLayer:aNeurons[ n ]:nDeltaError
    next

return


METHOD PROCEDURE Propagation( aInputs, aOutputs) CLASS TNeuralNetwork

local oInputNeuron
local oHiddenLayer
local oHiddenLayerNeuron
local oOutputNeutron
local nSum

    for each oInputNeuron in ::oInputLayer:aNeurons
        oInputNeuron:nValue := aInputs[ oInputNeuron:__enumIndex ]
    next

    for each oHiddenLayer in ::aHiddenLayers
        If oHiddenLayer:__enumIndex == 1
            for each oHiddenLayerNeuron in oHiddenLayer:aNeurons
                nSum := oHiddenLayerNeuron:nBias
                for each oInputNeuron in ::oInputLayer:aNeurons
                    nSum += oInputNeuron:nValue * oHiddenLayerNeuron:aWeights[ oInputNeuron:__enumIndex ]
                next
                oHiddenLayerNeuron:nValue := dSigmoid( nSum )
            next
        EndIf
    next

    for each oOutputNeutron in ::oOutputLayer:aNeurons
        nSum := oOutputNeutron:nBias
        for each oHiddenLayerNeuron in ATail( ::aHiddenLayers ):aNeurons
            nSum += oHiddenLayerNeuron:nValue * oOutputNeutron:aWeights[ oHiddenLayerNeuron:__enumIndex ]
        next
        oOutputNeutron:nValue := dSigmoid( nSum )
    next

return


METHOD PROCEDURE BackPropagation( aInputs, aOutputs ) CLASS TNeuralNetwork

local oOutputNeuron
local oHiddenLayer
local oHiddenLayerNeuron
local oInputNeuron
local nError

    for each oOutputNeuron in ::oOutputLayer:aNeurons
        nError := aOutputs[ oOutputNeuron:__enumIndex ] - oOutputNeuron:nValue
        oOutputNeuron:nDeltaError := nError * dSigmoid( oOutputNeuron:nValue )
    next

    for each oHiddenLayer in ::aHiddenLayers // Como Retroceder ?
        If oHiddenLayer:__enumIndex == Len( ::aHiddenLayers )
            for each oHiddenLayerNeuron in ::oHiddenLayer:aNeurons
                nError := 0
                for each oOutputNeuron in ::oOutputLayer:aNeurons
                    nError += oOutputNeuron:nDeltaError * oHiddenLayerNeuron:aWeights[ oOutputNeuron:__enumIndex ]
                next
                oHiddenLayerNeuron:nDeltaError := nError * dSigmoid( oHiddenLayerNeuron: nValue )
            next
        Else
        EndIf
    next

    for each oOutputNeuron in ::oOutputLayer:aNeurons
        oOutputNeuron:nBias += oOutputNeuron:nDeltaError * ::nLearningRate
        for each oHiddenLayer in ::aHiddenLayers
            If oHiddenLayer:__enumIndex == Len( ::aHiddenLayers )
                for each oHiddenLayerNeuron in oHiddenLayer:aNeurons
                    for each oOutputNeuron in ::oOutputLayer:aNeurons
                        oOutputNeuron:aWeights[ oHiddenLayerNeuron:__enumIndex ] += oHiddenLayerNeuron:nValue * ;
                                                                                        oOutputNeuron:nDeltaError * ::nLearningRate
                    next
                next
            EndIf
        next
    next

    for each oHiddenLayerNeuron in ::aHiddenLayers[ 1 ]:aNeurons
        oHiddenLayerNeuron:nBias += oHiddenLayerNeuron:nDeltaError * ::nLearningRate
        for each oInputNeuron in ::oInputLayer:aNeurons
            oHiddenLayerNeuron:aWeights[ oInputNeuron:__enumIndex ] += aInputs[ oHiddenLayerNeuron:__enumIndex ] * ;
                                                                         oHiddenLayerNeuron:nDeltaError * ::nLearningRate
        next
    next

return




CLASS TNeuralLayer

    VAR aNeurons AS ARRAY INIT {}

    METHOD New( nNeurons, nInputs )

END CLASS
        

METHOD New( nNeurons, nInputs ) CLASS TNeuralLayer

local n

    for n := 1 to nNeurons
        AAdd( ::aNeurons, TNeuron():New( nInputs ) )
    next

return Self



CLASS TNeuron

    VAR nBias       AS NUMERIC INIT hb_Random()
    VAR aWeights    AS ARRAY
    VAR nValue      AS NUMERIC
    VAR nDeltaError AS NUMERIC

    METHOD New( nInputs )

END CLASS


METHOD New( nInputs ) CLASS TNeuron

local n

    ::aWeights := Array( nInputs )

    for n := 1 to nInputs
        ::aWeights[ n ] := hb_Random()
    next

return Self


FUNCTION SidMoid( nValue )
    return 1 / ( 1 + math_E() ^ -nValue )


FUNCTION dSigmoid( nValue ) // retorna a derivada da função sigmóide
    return nValue * (1 - nValue)


#pragma BEGINDUMP

#include <hbapi.h>
#include <math.h>

HB_FUNC( MATH_E ) {
    hb_retnd( M_E );
}

#pragma ENDDUMP