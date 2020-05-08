//Author: Saulo Henrique Cabral Silva
#ifndef PARSER_HPA_H 
#define PARSER_HPA_H 

#include <string>
#include <iostream>
#include <vector>
#include <fstream>

using namespace std;

class ParserHPA{
private:

	string newPath;
	vector<string> removeProblemsLine(string line);
	string solveParallel(vector<string> splits);
	vector<string> translate(vector<string> modelVec);
	string manipulatePath(string modelPath);
	void writeModel(string path, vector<string> modelInVec);
	void parser(string modelPath);
	vector<string> readModel(string modelPath);

public:

	ParserHPA(string pathModel);
	string getNewPath();
	void cleanTranslate();

};

#endif