#include <bits/stdc++.h>
using namespace std;

ofstream opout;
ifstream kin;

vector<string>splits(string s){
    vector<string>ret;
    string tmp;
    for(char ch : s){
        if(ch==' ' or ch==','){
            if(tmp.size()) ret.push_back(tmp);
            tmp.clear();
        }
        else tmp += ch;
    }
    if(tmp.size()) ret.push_back(tmp);
    return ret;
}

bool ok(vector<string>a, vector<string>b){
    if(a[0]=="MOV" and b[0]=="MOV"){
        if(a[1]==b[2] and a[2]==b[1]) return true;
    }
    return false;
}

void work(){
    vector< vector<string> >cods;
    vector<string>realcode;
    while(true){
        string s;
        getline(kin, s);
        if(s.empty()) break;
        cods.push_back(splits(s));
        realcode.push_back(s);
    }
    vector<bool>baad(cods.size());
    for(int i=1; i<cods.size(); i++){
        if( ok(cods[i-1], cods[i]) ){
            baad[i] = true;
            i++;
        }
    }
    for(int i=0; i<cods.size(); i++) if(!baad[i]) opout << realcode[i] <<"\n";
}

int main(int argc, char *argv[]){
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}

	kin = ifstream(argv[1]);

	opout.open("optimized_code.asm");
	work();
	opout.close();
	return 0;
}

