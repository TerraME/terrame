/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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
of this software and its documentation.
*************************************************************************************/

#include <QApplication>
#include <QtCore>
#include <string>
#include "parserHPA.h"

ParserHPA::ParserHPA(string pathModel){
	 parser(pathModel);
}

void S_TokenizeParser(const string& linha, vector<string>& tokens, const string& delimitadores = " ") {
    string::size_type lastPos = linha.find_first_not_of(delimitadores, 0);
    string::size_type pos = linha.find_first_of(delimitadores, lastPos);

    //tentar otimizar aqui
    while (string::npos != pos || string::npos != lastPos) {
        tokens.push_back(linha.substr(lastPos, pos - lastPos));
        lastPos = linha.find_first_not_of(delimitadores, pos);
        pos = linha.find_first_of(delimitadores, lastPos);
    }
}

//metodo para acesso ao modelo
vector<string> ParserHPA::readModel(string modelPath){

    vector<string> modelInFle;
    ifstream fileModel;

    try{
        fileModel.open(modelPath.c_str(),ifstream::in);
    }catch(exception e){
        cout << "problema ao abrir o modelo, verifique o path" << endl;
    }

	//para resolver a ultima linha do modelo e nao restringir para o usuario em comenta'rios

	bool eof_ = false;
	if(!fileModel.eof())
		eof_ = true;

    cerr << "lendo!!!!!!!!!!!!!!!!!!!! " << endl;
    while(eof_) {

		if(fileModel.eof())
			eof_ = false;
		
        char temp[1000];
        fileModel.getline(temp,1000);
        string line = temp;

        // Tiago - O codigo abaixo esta errado, pq o tramento do final de linha nao depende do SO onde o HPA foi compilado
        // Ele depende apenas do SO (ou formato) no qual o ARQUIVO do modelo foi gravado!!!!
		// #if defined ( TME_WIN32 )
		// 	//caso for windows faca isso
		// 	modelInFle.push_back(line);
		// #else
		// 	//temos problemas com a quebra de linha por isso esse tratamento de versao
		// 	string line_aux = "";
		
		// 	if(line.size() > 0)
		// 		for(int i = 0; i < line.size()-1; i++)
		// 			line_aux = line_aux+line[i];
			
		// 	modelInFle.push_back(line_aux);
		// #endif

        // Tiago - pelo motivo expresso no comentario acima, eu resolvi retirar o caracter \r, ja a funcao "getline()"
        // por padrao para no caracter \n gerando uma string terminada em \0. Desta forma o modelo resultante tera sempre
        // o modelo utilizado no linux e no windows 
        string line_aux = "";
        
        if(line.size() > 0)
           for(int i = 0; i < line.size(); i++)
           {

               if (line[i] != '\r') 
               {
                  line_aux = line_aux+line[i];
               }
           }    

        
        modelInFle.push_back(line_aux);

    }

    return modelInFle;
}

vector<string> ParserHPA::removeProblemsLine(string line){

    vector<string> lineClean;
    //remover espacos e tabulacoes
    S_TokenizeParser(line,lineClean," \t \n");

    return lineClean;
}



string ParserHPA::solveParallel(vector<string> splits){

    // Tiago - na linha a seguir eu subistitui o : por . 
    // Veja as explicacoes no proximo comentario com meu nome
    //string resultTranslate = "__HPA__:HPA_PARALLEL(\"";
    string resultTranslate = "__HPA__:parallel(\"";
    string unionTranlate = "";
    string parameters = "";

    for(int i = 0;i < splits.size();i++){
        resultTranslate = resultTranslate + splits.at(i);
        unionTranlate = unionTranlate + splits.at(i);
    }

    //aqui vem a etapa dos parametros apos a virgula
    bool controlPar = false;

    const char *vetChar = unionTranlate.c_str();

    for(int i = 0; i < unionTranlate.size()-1;i++){
        //se estamos no fim da chamada precisamos tomar estes cuidados
        if(i == unionTranlate.size()-1 || (vetChar[i+1] == ';' && vetChar[i] == ')'))
            controlPar = false;

        //estamos entre colchetes vamos armazenar tudo como parâmetro usua'rio define
        if(controlPar)
            parameters = parameters + vetChar[i];

        //inicio de passagem de parâmetros
        if(vetChar[i] == '(')
            controlPar = true;
    }

    resultTranslate = resultTranslate + "\"";

    //caso em que temos parametros para a funcao
    if(parameters.size() > 0)
        resultTranslate = resultTranslate + "," + parameters;

    //encerrando a chamada a funcao parallel
    resultTranslate = resultTranslate + ");";

    return resultTranslate;
}


/// Tiago - Alterei todas as chamadas geradas pelo paser para que utilizam letras minusculas :
// Por exemplo, ao inves de gerar a chamada " __HPA__:HPA_JOINALL()" o  parser ira gerar "__HPA__.joinall()"
vector<string> ParserHPA::translate(vector<string> modelVec){

    vector<string> modelTranslated;

    for(int i = 0; i < modelVec.size()-1;i++){

        //tenho que fazer uma operacao de split para limpar as linhas
        vector<string> vectorClean = removeProblemsLine(modelVec.at(i));

        if(vectorClean.size() > 0 && !vectorClean.at(0).compare("--HPA")){

            if(!vectorClean.at(1).compare("PARALLEL")){

                //preciso pegar a linha imediatamente abaixo que seja diferente de vazio
                i++;
                vectorClean = removeProblemsLine(modelVec.at(i));

                while(vectorClean.empty()){
                    i++;
                    if(i == modelVec.size()){
qWarning("erro");
                        cerr << "error na instrumetacao, PARALLEL nao tem chamada a ser executada";
                        #ifdef WIN32
							exit(0);
						#else
							//procurar alguma forma de adicionar um erro aqui para o linux
						#endif
                    }
                    vectorClean = removeProblemsLine(modelVec.at(i));
                }

                //pegamos a nova linha aqui
                string lineTranslated = solveParallel(vectorClean);
                modelTranslated.push_back(lineTranslated);
            }else if(!vectorClean.at(1).compare("JOINALL")){
                //modelTranslated.push_back("__HPA__.HPA_JOINALL();");
                modelTranslated.push_back("__HPA__:joinall();");
            }else if(!vectorClean.at(1).compare("JOIN")){
                if(vectorClean.size() > 2){
                    //modelTranslated.push_back("__HPA__:HPA_JOIN(\"" + vectorClean.at(2) + "\");");
                    modelTranslated.push_back("__HPA__:join(\"" + vectorClean.at(2) + "\");");
                }else{
                    cerr << "error: nome da funcao para a funcao JOIN nao foi informado" << endl;
                }
            }else if(!vectorClean.at(1).compare("ACQUIRE")){
                if(vectorClean.size() > 2){
                    //modelTranslated.push_back("__HPA__:HPA_Acquire(" + vectorClean.at(2) + ",\"" + vectorClean.at(2) + "\");");
                    modelTranslated.push_back("__HPA__:acquire(" + vectorClean.at(2) + ",\"" + vectorClean.at(2) + "\");");
                }else{
                    cerr << "error: nome da secao critica para ACQUIRE nao foi informado ou e de tipo incompativel" << endl;
                }
            }else if(!vectorClean.at(1).compare("RELEASE")){
                if(vectorClean.size() > 2){
                    //modelTranslated.push_back("__HPA__:HPA_Release(" + vectorClean.at(2) + ",\"" + vectorClean.at(2) + "\");");
                    modelTranslated.push_back("__HPA__:release(" + vectorClean.at(2) + ",\"" + vectorClean.at(2) + "\");");
                }else{
                    cerr << "error: nome da secao critica para RELEASE nao foi informado ou e de tipo incompativel" << endl;
                }
            }else if(!vectorClean.at(1).compare("NP")){
                if(vectorClean.size() > 2){
                    //modelTranslated.push_back("__HPA__:HPA_NP("+vectorClean.at(2)+");");
                    modelTranslated.push_back("__HPA__:np("+vectorClean.at(2)+");");
                }else{
                    cerr << "error: quantidade de nucleos nao foi informada" << endl;
                }
            }

        }else{
            modelTranslated.push_back(modelVec.at(i));
        }
    }

    return modelTranslated;
}

//novo path para o modelo instrumentando (modificar para linux /)
string ParserHPA::manipulatePath(string modelPath){

    vector<string> splitPath;
    //remover espacos e tabulacoes
    #ifdef WIN32
    	S_TokenizeParser(modelPath,splitPath,"\\");
    #else
        S_TokenizeParser(modelPath,splitPath,"/");
    #endif

    string newPath = "";

    for(int i = 0; i < splitPath.size()-1;i++){
        #ifdef WIN32
            newPath = newPath + splitPath.at(i) + "\\";
        #else
            newPath = newPath + splitPath.at(i) + "/";
        #endif
    }

    newPath = newPath + "HPA_" + splitPath.at(splitPath.size()-1);

    return newPath;
}

void ParserHPA::writeModel(string path, vector<string> modelInVec){
    ofstream modelWrite;
    modelWrite.open(path.c_str(), ios_base::out);

    modelWrite << "__HPA__ = HPA();\n";

    for(int i = 0; i < modelInVec.size();i++){
        modelWrite << modelInVec.at(i);
        modelWrite << "\n";
    }
	modelWrite.flush();
    modelWrite.close();
}

void ParserHPA::parser(string modelPath){
    //leitura do modelo apenas uma vez para reduzir operacoes em disco
    vector<string> modelToTranslated = readModel(modelPath);

    if(modelToTranslated.empty()){
        cerr << "modelo em branco, verifique o modelo ou o path passado!"<<endl;
qWarning("erro");
    }

    modelToTranslated = translate(modelToTranslated);

    //funcao para gravacao do novo modelo
    newPath = manipulatePath(modelPath);
    writeModel(newPath,modelToTranslated);

    // Tiago
    cerr << newPath << " : " << modelPath << endl;
}

string ParserHPA::getNewPath(){
	return newPath;
}

void ParserHPA::cleanTranslate(){
	remove(newPath.c_str());
}

