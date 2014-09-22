/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright © 2001-2008 INPE and TerraLAB/UFOP.

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this library and its documentation.

Author: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*************************************************************************************/

/**
 * \file model.h
 * \author Tiago Garcia de Senna Carneiro
 */

#if ! defined( MODEL )
#define MODEL

#include "bridge.h"
#include <string>

#include <sstream>
#include <stdio.h>

#if defined ( TME_WIN32 )
#include <iostream>
#else
//#include <iostream.h>
#endif

using namespace std;

typedef string ModelID;
// Classe Model: define a interface para um modelo de uso geral. Suas interfaces
// derivadas poderiam modelar regiões, relógios, as leis que governam o comportamento 
// de algum fenômeno ou as interferências resultantes da cooperação de comunidades de 
// indivíduos autônomos sobre um determinado ambiente.
// Para implementar essas subclasses o programador poderia lançar mão de modelos 
// matemáticos como, por exemplo, células que modelam regiões, geralmente, retangulares 
// ou hexagonais do espaço. Algoritmos de simulação, como simulação de Monte Carlo ou 
// simulação dirigia por evetos poderiam ser utilizados para se implementar os relógios. 
// Máquinas de estados como os autômatos de estados finitos ou autômantos de pilha 
// poderiam ser utilizadas para modelar o comportamento de fenômenos. Técnicas de 
// inteligência artificial como agentes poderiam ser utilizadas para simular 
// indivíduos autônomos. 
//

/**
 * \brief Define a interface para um modelo de uso geral.
 *
 * Suas interfaces derivadas poderiam modelar regiões, relógios, as leis que governam o comportamento
 * de algum fenômeno ou as interferências resultantes da cooperação de comunidades de indivíduos
 * autônomos sobre um determinado ambiente.
 * Para implementar essas subclasses o programador poderia lançar mão de modelos matemáticos como, por exemplo,
 * células que modelam regiões, geralmente, retangulares ou hexagonais do espaço. Algoritmos de simulação,
 * como simulação de Monte Carlo ou simulação dirigia por evetos poderiam ser utilizados para se implementar
 * os relógios. Máquinas de estados como os autômatos de estados finitos ou autômantos de pilha poderiam ser
 * utilizadas para modelar o comportamento de fenômenos. Técnicas de inteligência artificial como agentes
 * poderiam ser utilizadas para simular indivíduos autônomos.
 */

/**
 * \brief
 *  Implementation for a Model object.
 *
 */
class ModelImpl : public Implementation
{
public:
    /// Construtor
    ModelImpl( void ) {
        char strNum[255];
        //	char ch;

        //#if defined ( TME_WIN32 ) //Raian: Comentei pq o ostringstream estava gerando um segmentation fault no linux
        sprintf (strNum, "%ld", modelCounter);
        //#else
        //ostringstream strStream( (string &) strNum );
        //strStream << modelCounter;
        //#endif

        setID( string( "model")+ strNum ); modelCounter++;
    }
    void setID( ModelID id ) { modelID = id; }
    ModelID getID( void ) { return modelID; }
    ModelID setId( ModelID id ) { modelID = modelID + ":" + id; return modelID; }
private:
    ModelID modelID;
    static long int modelCounter;
};


/**
 * \brief
 *  Handle for a Model object.
 *
 */

class Model : public Interface<ModelImpl>
{
public:
    ModelID getID( void ) { return pImpl_->getID(); }
    virtual void update( void ) { }

    ModelID setId( ModelID id ){ return pImpl_->setId(id); }
};

#endif

// Metodo abstrato que deve ser implementado pelo programador para definir 
// os objetos que compï¿½em uma instância de um modelo.
///virtual void modelDefinition( )  = 0;
