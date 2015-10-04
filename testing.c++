#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
using namespace std;

int main(int argc, char* argv[]){
	string line;
	char buffer[200];
		
	if(argc < 2){
		// wrong number of parameters
		cerr << "Wrong number of parameters" << endl;
	}
	
	ifstream myfile(argv[1]);
	
	if(myfile.is_open()){
		while(getline(myfile,line)){
			char *cstr = new char[line.length()+1];
			strcpy(cstr,line.c_str());
			sprintf(buffer, "ruby atm %s", cstr);
			system(buffer);
			delete [] cstr;
		}
		myfile.close();
	}
	else cout << "Unable to open file";

	return 0;
}
