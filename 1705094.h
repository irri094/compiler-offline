#ifndef SYMTABLE_H
#define SYMTABLE_H

#include<bits/stdc++.h>
using namespace std;

//int bucksize=10;

class SymbolInfo{
public:
    string getName(){
        return Name;
    }
    string getType(){
        return Type;
    }
    void setName(string s){
        Name = s;
    }
    void setType(string s){
        Type = s;
    }
    SymbolInfo* getNext(){
        return next;
    }
    void setNext(SymbolInfo *p){
        next = p;
    }
    SymbolInfo* getPrev(){
        return prev;
    }
    void setPrev(SymbolInfo *p){
        prev = p;
    }
    void setIdx(int x){
        idx = x;
    }
    int getIdx(){
        return idx;
    }
    void setPos(int x){
        pos = x;
    }
    int getPos(){
        return pos;
    }
    SymbolInfo(){
    }
    SymbolInfo(string s1, string s2){
        Name = s1, Type = s2;
    }
    SymbolInfo(SymbolInfo *pp){
        Name = pp->getName(), Type = pp->getType();
        fanction = pp->fanction, paramnames = pp->paramnames, paramtypes = pp->paramtypes, argnames = pp->argnames;
        isdeclared = pp->isdeclared, isdefined = pp->isdefined, linenumber = pp->linenumber;
        retarn_type = pp->retarn_type, arraytype = pp->arraytype;
        code = pp->code, varname = pp->varname, value = pp->value, index = pp->index;
    }
    ~SymbolInfo(){
    }
    /// if function
    
    bool fanction;
    vector<string> paramnames;
    vector<string> argnames;
    vector<string> paramtypes;
    bool isdeclared;
    bool isdefined;
    /// if function

    int linenumber = 0;
    string retarn_type = "ERROR";
    bool arraytype = false;

    string code;
    string varname;
    int value=0;
    int index=0;

private:
    SymbolInfo *next = nullptr;
    SymbolInfo *prev = nullptr;
    string Name = "", Type = "";
    int idx, pos;
};

class ScopeTable{
public:
    ScopeTable(int n2 = 7){
        n = n2;
        hashtable.resize(n);
        for(int i=0; i<n; i++) hashtable[i] = nullptr;
    }
    ~ScopeTable(){
        hashtable.clear();
    }

    bool insert2(SymbolInfo * pp){
        string name = pp->getName();
        int idx = hash_func(name), cnt = 0;
        SymbolInfo* p = hashtable[idx];
        bool done = false;
        SymbolInfo *agerta = nullptr;
        while(!done){
            if(!p){
                p = new SymbolInfo(pp);
                if(agerta){
                    agerta->setNext( p );
                    p->setPrev( agerta );
                }
                else hashtable[idx] = p;
                done = true;
            }
            else{
                if(p->getName()==name) break;
                else{
                    agerta = p;
                    p = p->getNext(), cnt++;
                }
            }
        }
        if(done){
            p->setIdx(idx), p->setPos(cnt);
//            cout<<"inserted in Scopetable# "<<id<<" at position "<<idx<<", "<<cnt<<"\n";
        }
        else {
//            cout<<"< "<< s1<<" , "<<s2<<" > already exists in current scopetable\n";
        }
        return done;        
    }
    bool insert2(string s1, string s2){
        string name = s1;
        int idx = hash_func(name), cnt = 0;
        SymbolInfo* p = hashtable[idx];
        bool done = false;
        SymbolInfo *agerta = nullptr;
        while(!done){
            if(!p){
                p = new SymbolInfo(s1, s2);
                if(agerta){
                    agerta->setNext( p );
                    p->setPrev( agerta );
                }
                else hashtable[idx] = p;
                done = true;
            }
            else{
                if(p->getName()==name) break;
                else{
                    agerta = p;
                    p = p->getNext(), cnt++;
                }
            }
        }

        if(done){
            p->setIdx(idx), p->setPos(cnt);
//            cout<<"inserted in Scopetable# "<<id<<" at position "<<idx<<", "<<cnt<<"\n";
        }
        else {
//            cout<<"< "<< s1<<" , "<<s2<<" > already exists in current scopetable\n";
        }
        return done;
    }
    SymbolInfo * Lookup(string name){ /// return null if not found
        int idx = hash_func(name);
        SymbolInfo * cur = hashtable[idx];

        while(cur){
            if(cur->getName()!=name) cur = cur->getNext();
            else return cur;
        }

        return nullptr;
    }
    bool Delete(string s){
        SymbolInfo * cur = Lookup(s);
        if(!cur){
//            cout<<"Not Found\n";
            return false;
        }
        SymbolInfo *nx = cur->getNext();
        SymbolInfo *pv = cur->getPrev();
        if(pv){
            pv->setNext( nx );
        }
        if(nx){
            nx->setPrev(pv);
        }
        while(nx){
            nx->setPos( nx->getPos()-1 );
            nx = nx->getNext();
        }
        if(cur->getPos()==0) hashtable[cur->getIdx()] = nx;
//        cout<<"deleted entry "<<cur->getIdx()<<" , "<<cur->getPos()<< " from current scopetable\n";
        delete cur;
        return true;
    }
    void print(ofstream &kout){
        kout<<"\nScopeTable # "<<id<<"\n";
        for(int i=0; i<n; i++){
            SymbolInfo * cur = hashtable[i];
            if(cur){
                kout<<" "<<i<<" --> ";
                while(cur){
                    kout<<"< "<<cur->getName()<<" : "<<cur->getType()<<" > ";
                    cur = cur->getNext();
                }
                kout<<"\n";
            }
        }
    }
    int getNumofdelet(){
        return numofdelet;
    }
    void settableid(){
        if(!parentScope){
            id = "1";
            return;
        }
        string s = parentScope->gettableid();
        int d = parentScope->getNumofdelet()+1;
        string ch;
        while(d){
            ch += char('0' + d%10);
            d/=10;
        }
        reverse(ch.begin(), ch.end());
        id = s+"."+ch;
    }
    string gettableid(){
        return id;
    }

    ScopeTable * getParentscope(){
        return parentScope;
    }
    void setParentscope(ScopeTable *p){
        parentScope = p;
    }
    void incDelet(){
        numofdelet++;
    }
    int getN(){
        return n;
    }
private:
    string id;
    int numofdelet = 0;
    ScopeTable * parentScope = nullptr;
    int n; /// number of buckets
    vector<SymbolInfo*> hashtable;
    int hash_func(string s){
        int sum=0;
        for(char ch : s) sum+=int(ch);
        sum%=n;
        return sum%n;
    }
};

class SymbolTable{
    int baketsize = 10;
public:
    SymbolTable(int bsize = 7){
        baketsize = bsize;
        currentTable = new ScopeTable();
        currentTable->settableid();
    }
    ~SymbolTable(){
        while(currentTable){
            ScopeTable * s = currentTable->getParentscope();
            delete currentTable;
            currentTable = s;
        }
    }
    void EnterScope(){
        string s = currentTable->gettableid();
        ScopeTable *p = new ScopeTable(baketsize);
        p->setParentscope(currentTable);
        currentTable = p;
        currentTable->settableid();
//        cout<<"new scopetable with id "<<currentTable->gettableid()<<" created\n";
    }
    void ExitScope(){
        ScopeTable *p = currentTable->getParentscope();
        if(p){
            p->incDelet();
//            cout<<"scopetable with id "<<currentTable->gettableid()<<" removed\n";
            delete currentTable;
            currentTable = currentTable->getParentscope();
        }
    }
    bool insert(SymbolInfo *p){
        return currentTable->insert2(p);
    }
    bool insert(string s1, string s2){
        return currentTable->insert2(s1, s2);
    }
    bool remove1(string s){
        bool b = currentTable->Delete(s);
//        if(!b) cout<<s<<" not found\n";
        return b;
    }
    SymbolInfo * Lookup(string s){
        ScopeTable *cur = currentTable;
        while(cur){
            SymbolInfo *p = cur->Lookup(s);
            if(p){
//                cout<<"found at scopetable# "<< cur->gettableid() <<" at position "<< p->getIdx() <<", " <<p->getPos()<<"\n";
                return p;
            }
            cur = cur->getParentscope();
        }
//        cout<<"not found\n";
        return nullptr;
    }
    void printCurscope(ofstream &kout){
        currentTable->print(kout);
    }
    void printAllscope(ofstream &kout){
        ScopeTable *cur = currentTable;
        while(cur){
            cur->print(kout);
            cur = cur->getParentscope();
        }
    }
private:
    ScopeTable *currentTable = nullptr;
};
//
//int main(){
//    freopen("input.txt", "r", stdin);
//    freopen("output.txt", "w", stdout);
//    cin>>bucksize;
//    char ch;
//    SymbolTable ST;
//    while(cin>>ch){
//        if(ch=='I'){
//            string s1, s2;
//            cin>>s1>>s2;
//            cout<<ch<<" "<<s1<<" "<<s2<<"\n";
//            ST.insert1(s1, s2);
//        }
//        else if(ch=='S'){
//            cout<<ch<<"\n";
//            ST.EnterScope();
//        }
//        else if(ch=='P'){
//            char ch2;
//            cin>>ch2;
//            cout<<ch<<" "<<ch2<<"\n";
//            if(ch2=='A') ST.printAllscope();
//            else if(ch2=='C') ST.printCurscope();
//        }
//        else if(ch=='D'){
//            string s;
//            cin>>s;
//            cout<<ch<<" "<<s<<"\n";
//            ST.remove1(s);
//        }
//        else if(ch=='L'){
//            string s;
//            cin>>s;
//            cout<<ch<<" "<<s<<"\n";
//            ST.Lookup(s);
//        }
//        else if(ch=='E'){
//            cout<<ch<<"\n";
//            ST.ExitScope();
//        }
//        cout<<"\n";
//    }
//}
///*
//7
//I a a
//S
//I h h
//S
//I o o
//P A
//*/
#endif
