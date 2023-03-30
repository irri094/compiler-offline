%{
#include <bits/stdc++.h>
#include "1705094.h"
#define YYSTYPE SymbolInfo*

using namespace std;

ofstream asmout;
ofstream errout;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

extern int yylineno;
extern int errcount;
//extern int errcount = 0;

void yyerror(char *s)
{
	//write your code
}

string tocaps(string x){
	string ret = x;
	for(char &ch : ret) ch = toupper(ch);
	return ret;
}

int s_to_int(string s){
	int ret = 0;
	for(char ch : s) ret = (ret * 10 + int(ch-'0') );
	return ret;
}

SymbolTable ST(30);


void logrule(string s){
	// asmout<<"Line "<<yylineno<<": ";
	// asmout<<s<<"\n\n";
}
void logcode(SymbolInfo * pp){
	// SymbolInfo *p = pp;
	// while(p!=nullptr){
	// 	if( (p->getPrev() ) != nullptr){
	// 		if( ( (p->getPrev())->linenumber ) != (p->linenumber) ){
	// 			logout<<"\n";
	// 		}
	// 	}
	// 	string s = p->getName();
	// 	logout<<s;
	// 	if(s=="int" or s=="float" or s=="void" or s=="return") logout<<" ";
	// 	p = p->getNext();
	// }
	// logout<<"\n\n";
}


vector<string> labels;
vector<string> tempvars;
vector<pair<string,int>> temparray;

string newtemp(string nam = ""){
	int sz = tempvars.size();
	string s;
	s = "TEMPVAR_"+to_string(sz);
	if(nam.size()) s += "_"+nam;
	tempvars.push_back(s);
	return s;
}


string arrestring(SymbolInfo *pp){
	string ret = "[ " + pp->varname + " + " + to_string(2*pp->index)+" ]";
	return ret;
}

void marj(SymbolInfo *p1, SymbolInfo *p2){
	SymbolInfo *cur = p1;
	while(cur->getNext()) cur = cur->getNext();
	cur->setNext(p2);
	p2->setPrev(cur);
}

void errmsg(string s){
	errcount++;
	errout<<"Error at line "<<yylineno<<": "<<s<<"\n\n";
	//logout<<"Error at line "<<yylineno<<": "<<s<<"\n\n";
}

void newfunc_dec(SymbolInfo *d1, SymbolInfo *n1, SymbolInfo *p1){
	SymbolInfo* datatyp = d1;
	SymbolInfo *namm = n1;
	SymbolInfo *para = p1;
	SymbolInfo *p = new SymbolInfo();
	p->setName(namm->getName());
	p->retarn_type = tocaps( datatyp->getName() );
	SymbolInfo *cur = para;
	p->fanction = true;
	p->isdeclared = true;
	p->setType("ID");

	while(cur!=nullptr){
		if(cur->getType() == "INT"){
			p->paramtypes.push_back("INT");
		}
		else if(cur->getType() == "FLOAT"){
			p->paramtypes.push_back("FLOAT");	
		}
		else if(cur->getType() != "ID" and cur->getType() != "COMMA"){
			errmsg("Invalid type specifier in function "+p->getName());
		}
		cur = cur->getNext();
	}
	for(int i=1; i< p->paramnames.size(); i++){
		bool jhamela = false;
		for(int j=0; j<i; j++){
			if( p->paramnames[i] == p->paramnames[j] ) jhamela = true;
		}
		if(jhamela) errmsg("Multiple declaration of "+p->paramnames[i]+" in parameter");
	}
	if(!ST.insert(p)){
		errmsg("Multiple declaration of function "+p->getName());
	}
}

void newfunc_def(SymbolInfo *d1, SymbolInfo *n1, SymbolInfo *p1){
	SymbolInfo* datatyp = d1;
	SymbolInfo *namm = n1;
	SymbolInfo *para = p1;
	SymbolInfo *p = new SymbolInfo();
	p->setName(namm->getName());
	p->retarn_type = tocaps( datatyp->getName() );
	SymbolInfo *cur = para;
	p->fanction = true;
	p->isdeclared = true;
	p->isdefined = true;
	p->setType("ID");
	
	while(cur!=nullptr){
		if(cur->getType() == "ID"){
			if(cur->getPrev() == nullptr){
				errmsg("No type specifier of "+cur->getName());
			}
			else{
				string tt = cur->getPrev()->getName();
				if(tt=="int") {
					p->paramnames.push_back(cur->getName());
					p->argnames.push_back(newtemp(cur->getName()));
					p->paramtypes.push_back("INT");
				}
				else if(tt=="float"){
					p->paramnames.push_back(cur->getName());
					p->paramtypes.push_back("FLOAT");
				}
				else errmsg("Invalid type specifier of "+cur->getName());
			}
		}
		cur = cur->getNext();
	}
	SymbolInfo *f =  ST.Lookup(p->getName());
	bool wasdeclaration = false;
	bool waddefined = false;
	if(f!=nullptr){
		if(f->isdefined and f->fanction){
			errmsg("Multiple definition of "+p->getName());
			waddefined = true;
		}
		else if(f->isdeclared and f->fanction){
			if(f->retarn_type != p->retarn_type){
				errmsg("Return type mismatch with function declaration in function "+p->getName());
			}
			if( f->paramtypes.size() != p->paramtypes.size() ){
				errmsg("Total number of arguments mismatch with declaration in function "+p->getName());
			}
			wasdeclaration = true;
			f->isdefined = true;
		}
	}
	if(!ST.insert(p)){
		if(!wasdeclaration and !waddefined) errmsg("Multiple declaration of "+p->getName());
	}
	ST.EnterScope();
	for(int i=0; i< p->paramnames.size(); i++ ){
		SymbolInfo *mara = new SymbolInfo((p->paramnames)[i], "ID");
		mara->varname = p->argnames[i];
		mara->retarn_type = (p->paramtypes)[i];
		if( ! ST.insert( mara ) ) errmsg("Multiple declaration of "+mara->getName()+" in parameter"); 
	}
}

void newvars_dec(SymbolInfo *datatyp, SymbolInfo *vars){
	SymbolInfo *cur = vars;
	while(cur){
		if(cur->getType()=="ID"){
			cur->retarn_type = datatyp->getType();
			if(cur->retarn_type=="VOID"){
				errmsg("Variable type cannot be void");
			}
			else{ 
				if(!ST.insert(cur)){
					errmsg("Multiple declaration of "+cur->getName());
				}
			}
		}
		cur = cur->getNext();
	}
}

void funccall(SymbolInfo *nam, SymbolInfo *arglist){
	SymbolInfo *infu = ST.Lookup(nam->getName());
	if(!infu){
		errmsg("Undeclared function "+nam->getName());
	}
	else{
		if(infu->fanction){
			vector<string>vartypes = arglist->paramtypes;
			vector<string>funcvartypes = infu->paramtypes;
			if(vartypes.size() != funcvartypes.size() ){
				errmsg("Total number of arguments mismatch in function "+nam->getName());
			}
			else{
				for(int i=0; i<vartypes.size(); i++){
					if(vartypes[i]!=funcvartypes[i]){
						errmsg("argument type mismatch in function " + nam->getName());
					}
				}

			}
			if(!infu->isdefined){
				errmsg("function was not defined");
			}
		}
		else{
			errmsg(nam->getName()+" is not a function");
		}
		nam->retarn_type = infu->retarn_type;
	}
	arglist->paramtypes.clear();
}


string marj_rettype(SymbolInfo *p1, SymbolInfo *p2){
	string a = p1->retarn_type, b = p2->retarn_type;
	if(a==b){
		if(a=="INT") return a;
		if(a=="FLOAT") return a;
		return "ERROR";
	}
	if(a=="VOID" or b=="VOID"){
		return "ERROR";
	}
	if(a=="ERROR" or b=="ERROR") return a;
	if(a=="FLOAT" or b=="FLOAT") return "FLOAT";
	return "INT";
}





string newlabel(){
	int sz = labels.size();
	string s = "LABEL_"+to_string(sz);
	labels.push_back(s);
	return s;
}


string newarr(int len){
	int sz = temparray.size();
	string s = "TMPARR_"+to_string(sz);
	temparray.push_back({s,len});
	return s;
}

string getrealvar(SymbolInfo *pp){
	// SymbolInfo *pp2 = ST.Lookup(pp->getName());
	// if( pp2 and pp2->arraytype){
	// 	return arrestring(pp);
	// }
	// else if(pp2){
	// 	if(pp2->varname.size()) return pp2->varname;
	// 	else return to_string(pp2->value);
	// }
	if(pp->arraytype) 		return arrestring(pp);
	if(pp->varname.size()) return pp->varname;
	return to_string(pp->value);
}


%}

%token IF FOR DO INT FLOAT VOID SWITCH DEFAULT WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE CONST_INT CONST_FLOAT CONST_CHAR ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON ID PRINTLN
%type start program unit var_declaration type_specifier declaration_list func_declaration func_definition parameter_list compound_statement statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

%nonassoc THEN
%nonassoc ELSE

//%left 
//%right

//%nonassoc 


%%

start : program
	{
		//write your code in this block in all the similar blocks below
		$$ = $1;
		if(errcount==0){
			asmout << ".MODEL SMALL\n";
			asmout << ".STACK 100H\n";
			asmout << ".DATA\n";
			asmout << "CR EQU 0DH\n";
    		asmout << "LF EQU 0AH\n";
			asmout << "NEWLINE DB CR, LF, '$'\n";	
			for(string s : tempvars){
				asmout << s <<" DW 0\n";
			}
			for(auto z : temparray){
				asmout << z.first <<" DW " << z.second <<" DUP(0)\n";
			}
			asmout << "funcrett DW 0\n";
			asmout << "negg DB 0\n";
			asmout << "digs DB 0\n";
			asmout << ".CODE\n";		
			string printfunc = "printAX PROC ; print number in AX\n\
MOV digs, 0\n\
MOV negg, 0\n\
CMP AX, 0\n\
JGE poss\n\
NEG AX\n\
MOV negg, 1\n\
poss:\n\
WHILELOOP:\n\
CMP AX, 0\n\
JE ENDWHILE \n\       
MOV DX, 0\n\
MOV BX, 10\n\
DIV BX \n\        
PUSH DX\n\
INC digs\n\
JMP WHILELOOP\n\     
ENDWHILE:\n\     
CMP negg, 1\n\
JNE notnegat\n\
MOV AH, 2\n\
MOV DL, '-'\n\
INT 21H\n\
notnegat:\n\    
CMP digs, 0\n\
JG WHILE2:\n\
MOV AH, 2\n\
MOV DL, '0'\n\
INT 21H\n\
JMP EXITfunc\n\
WHILE2:\n\
CMP digs, 0\n\
JE EXITfunc:\n\
DEC digs\n\
POP DX\n\   
ADD DL, 30H\n\
MOV AH, 2\n\
INT 21H\n\
JMP WHILE2\n\
EXITfunc:\n\
LEA DX, NEWLINE\n\
MOV AH, 9\n\
INT 21H\n\        
RET\n\
printAX ENDP\n";
			asmout << printfunc;
			asmout << $1->code;
			asmout << "END MAIN\n";
		}
	}
	;

program : program unit {
		marj($1, $2);
		$1->code += $2->code;
		$$ = $1;
	}
	| unit {
		$$ = $1;
	}
	;
	
unit : var_declaration {
		$$ = $1;
	}
	| func_declaration {
		$$ = $1;
	}
    | func_definition  {
		$$ = $1;
	}
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
		newfunc_dec($1, $2, $4);
		marj($5, $6),marj($4, $5),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
	}
	| type_specifier ID LPAREN RPAREN SEMICOLON  {
		newfunc_dec($1, $2, nullptr);
		marj($4, $5),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
	}
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN { newfunc_def($1, $2, $4); } compound_statement {
		ST.ExitScope();		
		marj($5, $7),marj($4, $5),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
		$$->code += $2->getName()+" PROC\n";
		$$->code += $7->code;
		$$->code += "RET\n";
		$$->code += $2->getName()+" ENDP\n";
	}
	| type_specifier ID LPAREN RPAREN { newfunc_def($1, $2, nullptr); } compound_statement {
		ST.ExitScope();		
		marj($4, $6),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
		$$->code += $2->getName()+" PROC\n";
		if($2->getName() == "main") {
			$$->code += "MOV AX, @DATA\n";
			$$->code += "MOV DS, AX\n";
			$$->code += $6->code;
			$$->code += "MOV AH, 4CH\n";
			$$->code += "INT 21H\n";
		}
		else{
			$$->code += $6->code;
		}
		$$->code += "RET\n";
		$$->code += $2->getName()+" ENDP\n";
	}
	;				


parameter_list : parameter_list COMMA type_specifier ID {
		marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
	}
	| parameter_list COMMA type_specifier {
		marj($2, $3),marj($1, $2);
		$$ = $1;
	}
	| type_specifier ID {
		marj($1, $2);
		$$ = $1;			
	}
	| type_specifier {
		$$ = $1;
	}
	;

 		
compound_statement : LCURL { ST.EnterScope(); } statements RCURL {

		ST.ExitScope();

		marj($3, $4),marj($1, $3);
		$$ = $1;
		$$->code = $3->code;
	}
	| LCURL RCURL {
		marj($1, $2);
		$$ = $1;
	}
	;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {

		newvars_dec($1, $2);

		marj($2, $3), marj($1, $2);
		$$ = $1;
	}
	;
 		 
type_specifier : INT {
		$$ = $1;
	}
	| FLOAT {
		$$ = $1;
	}
	| VOID {
		$$ = $1;
	}
	;
 		
declaration_list : declaration_list COMMA ID {
		$3->varname = newtemp($3->getName());
		marj($2, $3), marj($1, $2);
		$$ = $1;
	}
	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
		$3->arraytype = true;
		marj($5, $6),marj($4, $5),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
		$3->varname = newarr(s_to_int($5->getName()));
	}
	| ID {
		$1->varname = newtemp($1->getName());
		$$ = $1;
	}
	| ID LTHIRD CONST_INT RTHIRD {
		$1->arraytype = true;
		marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
		$1->varname = newarr(s_to_int($3->getName()));
	}
	;
 		  
statements : statement {
		$$ = $1;
	}
	| statements statement {
		$1->code += $2->code;
		marj($1, $2);
		$$ = $1;
	}
	;
	   
statement : var_declaration {
		$$ = $1;
	}
	| expression_statement {
		$$ = $1;
	}
	| compound_statement {
		$$ = $1;
	}
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement {
		marj($6, $7),marj($5, $6),marj($4, $5),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;

		$$->code += $3->code;
		string luup = newlabel();
		$$->code += luup + ":\n";
		$$->code += $4->code;
		string str = getrealvar($4);
		if(str.empty()) str = "1";
		$$->code += "MOV AX, "+str+"\n";
		$$->code += "CMP AX, 0\n";
		string endfor = newlabel();
		$$->code += "JE "+ endfor + "\n";
		$$->code += $7->code + $5->code;
		$$->code += "JMP "+luup+ "\n";
		$$->code += endfor + ":\n";
		
	}
	| IF LPAREN expression RPAREN statement %prec THEN {
		marj($4, $5),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
		$$->code = $3->code;
		$$->code += "MOV AX, "+getrealvar($3)+"\n";
		$$->code += "CMP AX, 0\n";
		string ifshesh = newlabel();
		$$->code += "JE " + ifshesh + "\n";
		$$->code += $5->code;
		$$->code += ifshesh + ":\n";
	}
	| IF LPAREN expression RPAREN statement ELSE statement {
		marj($6, $7),marj($5, $6),marj($4, $5),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;		
		$$->code = $3->code;
		$$->code += "MOV AX, "+getrealvar($3)+"\n";
		$$->code += "CMP AX, 0\n";
		string elseshuru = newlabel();
		$$->code += "JE " + elseshuru + "\n";
		$$->code += $5->code;
		string elseshesh = newlabel();
		$$->code += "JMP " + elseshesh + "\n";
		$$->code += elseshuru + ":\n";
		$$->code += $7->code;
		$$->code += elseshesh + ":\n";
	}
	| WHILE LPAREN expression RPAREN statement {
		marj($4, $5),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
		string whilestart = newlabel();
		$$->code += whilestart + ":\n";
		$$->code += $3->code;
		string str = getrealvar($3);
		if(str.empty()) str = to_string($3->value);
		$$->code += "MOV AX, " + str + "\n";
		$$->code += "CMP AX, 0\n";
		string whileend = newlabel();
		$$->code += "JE "+ whileend +"\n";
		$$->code += $5->code;
		$$->code += "JMP " + whilestart+"\n";
		$$->code += whileend+":\n";
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON {
		SymbolInfo *pp = ST.Lookup( $3->getName());
		if( pp == nullptr ){
			errmsg("Undeclared variable "+$3->getName());
		}
		else {
			$1->code = "MOV AX, "+getrealvar(pp)+ "\n";
			$1->code += "CALL printAX\n";
		}

		marj($4, $5),marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;

	}
	| RETURN expression SEMICOLON {
		marj($2, $3),marj($1, $2);
		$$ = $1;
		$$->code += $2->code;
		$$->code += "MOV AX,"+ getrealvar($2) + "\n";
		$$->code += "MOV funcrett, AX\n";
	}
	;
	  
expression_statement : SEMICOLON	 {
		$$ = $1;
	}			
	| expression SEMICOLON {
		marj($1, $2);
		$$ = $1;
	} 
	;
	  
variable : ID {

		SymbolInfo *pp = ST.Lookup( $1->getName());
		if( pp == nullptr ){
			errmsg("Undeclared variable "+$1->getName());
		}
		else{
			$1->retarn_type = pp->retarn_type;
			$1->varname = pp->varname;
			if(pp->arraytype){
				errmsg("Type mismatch "+$1->getName()+" is an array");
			}
		}

		$$ = $1;
	}		
	| ID LTHIRD expression RTHIRD {

		SymbolInfo *pp = ST.Lookup( $1->getName());
		if( pp == nullptr ){
			errmsg("Undeclared variable "+$1->getName());
		}
		else{
			$1->code += $3->code;
			if($3->varname.empty()) $1->varname = "[" + pp->varname + " + " + to_string(2*$3->value) + "]";
			else{
				$1->code += "MOV BX, " + $3->varname + "\n";
				$1->code += "ADD BX, BX\n";
				$1->varname = "[" + pp->varname + " + BX]";
			}
			//$1->index = $3->value;
			$1->retarn_type = pp->retarn_type;
			
			if(!pp->arraytype){
				errmsg("Type mismatch "+$1->getName()+" is not an array");
			}
		}
		if($3->retarn_type != "INT"){
			errmsg("Expression inside third brackets not an integer");
		}

		marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
	}
	;
	 
 expression : logic_expression {
		$$ = $1;
	}	
	| variable ASSIGNOP logic_expression {

		if($3->retarn_type == "VOID"){
			errmsg("Void function used in expression");
		}
		else if($3->retarn_type!="ERROR" and $1->retarn_type!="ERROR" and $3->retarn_type != $1->retarn_type){
			errmsg("Type mismatch");
		}

		marj($2, $3),marj($1, $2);
		$$ = $1;
		SymbolInfo *pp = ST.Lookup($1->getName());
		SymbolInfo *pp2 = ST.Lookup($3->getName());
		
		string assignedstr = $3->varname;
		// if(pp2!=nullptr){
		// 	if(pp2->arraytype) assignedstr = arrestring($3);
		// }
		// if(!pp->arraytype){
			$$->code = $1->code + $3->code;
			if($3->varname.empty()){
				$$->code += "MOV " + $1->varname+ " , " + to_string($3->value) + "\n";
			}
			else{
				$$->code += "MOV AX, "  + assignedstr + "\n";
				$$->code += "MOV " + $1->varname+ ", AX\n";
			}
			// ST.Lookup($1->getName())->value = $3->value;
		// }
		// else{
		// 	$$->code = $3->code;
		// 	if($3->varname.empty()){
		// 		$$->code += "MOV " + arrestring($1)+ " , " + to_string($3->value) + "\n";
		// 	}
		// 	else {
		// 		$$->code += "MOV AX, "  + assignedstr + "\n";
		// 		$$->code += "MOV " + arrestring($1)+ ", AX\n";
		// 	}
		// 	// ST.Lookup($1->getName())->value = $3->value;
		// }
	} 	
	;
			
logic_expression : rel_expression {
		$$ = $1;		
	} 	
	| rel_expression LOGICOP rel_expression {
		
		if($3->retarn_type == "VOID" or $1->retarn_type == "VOID"){
			errmsg("Void function used in expression");
		}

		marj($2, $3),marj($1, $2);
		$$ = $1;
		$$->retarn_type = "INT";
		
		$$->code = $1->code + $3->code;
		if($2->getName()=="||") {
			$$->code += "MOV AX, " + getrealvar($1) +"\n";
			$$->varname = newtemp();
			string turu = newlabel();
			$$->code += "CMP AX, 0\n";
			$$->code += "JNE " + turu + "\n";
			$$->code += "MOV AX, " + getrealvar($3) +"\n";
			$$->code += "CMP AX, 0\n";
			$$->code += "JNE " + turu + "\n";
			string shesh = newlabel();
			$$->code += "JMP " + shesh + "\n";
			$$->code += turu + ":\n";
			$$->code += "MOV " + $$->varname + ", 1" +"\n";
			$$->code += shesh + ":\n";
			
		}
		if($2->getName()=="&&") {
			$$->code += "MOV AX, " + getrealvar($1) +"\n";
			$$->varname = newtemp();
			string shesh = newlabel();
			$$->code += "CMP AX, 0\n";
			$$->code += "JE " + shesh + "\n";
			$$->code += "MOV AX, " + getrealvar($3) +"\n";
			$$->code += "CMP AX, 0\n";
			$$->code += "JE " + shesh + "\n";
			$$->code += "MOV " + $$->varname + ", 1" +"\n";
			$$->code += shesh + ":\n";
		}
	}	
	;
			
rel_expression : simple_expression {
		$$ = $1;
		
	}
	| simple_expression RELOP simple_expression	{

		if($3->retarn_type == "VOID" or $1->retarn_type == "VOID"){
			errmsg("Void function used in expression");
		}

		marj($2, $3),marj($1, $2);
		$$ = $1;
		string oldvar = getrealvar($1);
		$$->retarn_type = "INT";
		$$->varname = newtemp();

		// if($2->getName()=="<") $$->value = bool($1->value < $3->value);
		// if($2->getName()=="<=") $$->value = bool($1->value <= $3->value);
		// if($2->getName()==">") $$->value = bool($1->value > $3->value);
		// if($2->getName()==">=") $$->value = bool($1->value >= $3->value);
		// if($2->getName()=="==") $$->value = bool($1->value == $3->value);
		// if($2->getName()=="!=") $$->value = bool($1->value != $3->value);

		string falls = newlabel();
		$$->code += $1->code + $3->code;
		if(!oldvar.empty()) $$->code += "MOV AX, " + oldvar + "\n";
		else $$->code += "MOV AX, " + to_string($1->value) + "\n";
		if(!$3->varname.empty()) $$->code += "CMP AX, " + getrealvar($3) + "\n";
		else $$->code += "CMP AX, " + to_string($3->value) + "\n";

		if($2->getName() == "<") {
			$$->code += "JGE " + falls + "\n";
		}
		else if($2->getName() == "<=") {
			$$->code += "JG " + falls + "\n";
		}
		else if($2->getName() == ">") {
			$$->code += "JLE " + falls + "\n";
		}
		else if($2->getName() == ">=") {
			$$->code += "JL " + falls + "\n";
		}
		else if($2->getName() == "==") {
			$$->code += "JNE " + falls + "\n";
		}
		else if($2->getName() == "!="){
			$$->code += "JE " + falls + "\n";
		}
		
		$$->code += "MOV " + getrealvar($$) + ", 1\n";
		string shesh = newlabel();
		$$->code += "JMP " + shesh + "\n";
		$$->code += falls + ":\n";
		$$->code += "MOV " + getrealvar($$) + ", 0\n";
		$$->code += shesh + ":\n";
	}
	;
				
simple_expression : term {
		$$ = $1;
	}
	| simple_expression ADDOP term {
		if($3->retarn_type == "VOID" or $1->retarn_type == "VOID"){
			errmsg("Void function used in expression");
		}
		string rettype = marj_rettype($1, $3);

		marj($2, $3),marj($1, $2);
		$$ = $1;

		$$->code = $1->code + $3->code;
		$$->code += "MOV AX, " + getrealvar($1) + "\n";
		$$->varname = newtemp();
		if($2->getName()=="+") $$->code += "ADD AX, " + getrealvar($3) + "\n";
		if($2->getName()=="-") $$->code += "SUB AX, " + getrealvar($3) + "\n";
		$$->code += "MOV " +$$->varname + ", AX\n";
		
		$$->retarn_type = rettype;
	}
	;
					
term : unary_expression {
		$$ = $1;
	}
	|  term MULOP unary_expression {
		if($3->retarn_type == "VOID" or $1->retarn_type == "VOID"){
			errmsg("Void function used in expression");
		}
		if($2->getName()=="%"){
			if($1->retarn_type!="INT" or $3->retarn_type!="INT"){
				errmsg("Non-Integer operand on modulus operator");
			}
			if($3->getName()=="0"){
				errmsg("Modulus by Zero");	
			}
		}
		string rettype = marj_rettype($1, $3);
		if($2->getName()=="%") rettype = "INT";
		
		marj($2, $3),marj($1, $2);
		$$ = $1;
		string termval = getrealvar($1);
		$$->varname = newtemp();
		$$->code = $1->code + $3->code;
		$$->code += "MOV AX, " + termval + "\n";
		$$->code += "MOV CX, " + getrealvar($3) + "\n";

		$$->retarn_type = rettype;
		if($2->getName()=="*"){
			$$->code += "MUL CX\n";
			$$->code += "MOV " + $$->varname + ", AX\n";
		}
		else if($2->getName()=="/"){
			$$->code += "DIV CX\n";
			$$->code += "MOV " + $$->varname + ", AX\n";
		}
		else if($2->getName()=="%"){
			$$->code += "DIV CX\n";
			$$->code += "MOV " + $$->varname + ", DX\n";
		}
	}
	;

unary_expression : ADDOP unary_expression  {
		marj($1, $2);
		$$ = $1;
		if($1->getName() == "-") {
			$$->code += $2->code;
			$$->varname = newtemp();
			$$->code += "MOV AX, " + getrealvar($2) + "\n";
			$$->code += "NEG AX\n";
			$$->code += "MOV " + $$->varname + ", AX\n";
		}
		else{
			$$->code += $2->code;
			$$->varname = getrealvar($2);
		}
	}
	| NOT unary_expression {
		marj($1, $2);
		$$ = $1;
		$$->varname = newtemp();
		$$->code += "MOV AX, " + getrealvar($2) + "\n";
		$$->code += "NOT AX\n";
		$$->code += "MOV " + $$->varname + ", AX\n";
	} 
	| factor {
		$$ = $1;
	} 
	;
	
factor : variable {
		$$ = $1;
		//$$->value = ST.Lookup($1->getName())->value;
	}
	| ID LPAREN argument_list RPAREN {
		funccall($1, $3);
		marj($3, $4),marj($2, $3),marj($1, $2);
		$$ = $1;
		$$->retarn_type = $1->retarn_type;
		
		$$->code += $3->code;
		SymbolInfo *pp = ST.Lookup($1->getName());
		for(int i=0; i< pp->argnames.size(); i++) {
			$$->code += "MOV AX, " + $3->argnames[i] + "\n";
			$$->code += "MOV " + pp->argnames[i] + ", AX\n";
		}
		$$->code += "CALL " + pp->getName() + "\n";	
		$$->code += "MOV AX, funcrett\n";
		$$->varname = newtemp();
		$$->code += "MOV " + $$->varname + ", AX\n";
	}
	| LPAREN expression RPAREN {
		marj($2, $3),marj($1, $2);
		$$ = $1;
		$$->varname = $2->varname;
		$$->index = $2->index;
		$$->code = $2->code;
	}
	| CONST_INT {
		$$ = $1;
		$$->retarn_type = "INT";
		$$->value = s_to_int($1->getName());
	}
	| CONST_FLOAT {
		$$ = $1;
		$$->retarn_type = "FLOAT";
	}
	| variable INCOP {
		marj($1, $2);
		$$ = $1;
		SymbolInfo *pp = ST.Lookup($1->getName());
		// if(!pp->arraytype){
			$$->code += "MOV AX," +$1->varname + "\n";
			$$->code += "ADD " +$1->varname + ", 1\n";
			$$->varname = newtemp();
			$$->code += "MOV " +$$->varname + ", AX\n";
		// }
		// else{ 
		// 	$$->code += "MOV AX, " +  arrestring($1) + "\n";
		// 	$$->code += "ADD [" + $1->varname+ "+" + to_string(2*$1->index) +" ], 1\n";
		// 	$$->varname = newtemp();
		// 	$$->code += "MOV " +$$->varname + ", AX\n";
		// }
		//$$->value = (ST.Lookup($1->getName())->value)++;
	}
	| variable DECOP {
		marj($1, $2);
		$$ = $1;
		SymbolInfo *pp = ST.Lookup($1->getName());
		if(!pp->arraytype){
			$$->code += "MOV AX," +$1->varname + "\n";
			$$->code += "SUB " +$1->varname + ", 1\n";
			$$->varname = newtemp();
			$$->code += "MOV " +$$->varname + ", AX\n";
		}
		else{ 
			$$->code += "MOV AX, " +  arrestring($1) + "\n";
			$$->code += "SUB [" + $1->varname+ "+" + to_string(2*$1->index) +" ], 1\n";
			$$->varname = newtemp();
			$$->code += "MOV " +$$->varname + ", AX\n";
		}
		//$$->value = (ST.Lookup($1->getName())->value)--;
	}
	;
	
argument_list : arguments {
		$$ = $1;
	}
	| {
		$$ = new SymbolInfo();
	}
	;
	
arguments : arguments COMMA logic_expression {
		marj($2, $3),marj($1, $2);
		$$ = $1;
		$$->paramtypes.push_back( $3->retarn_type );
		if($1->varname.empty()) $$->argnames.push_back(to_string($3->value));
		else $$->argnames.push_back(getrealvar($3));
	}
	| logic_expression {
		$$ = $1;
		
		$$->paramtypes.push_back( $1->retarn_type );
		if($1->varname.empty()) $$->argnames.push_back(to_string($1->value));
		else $$->argnames.push_back(getrealvar($1));
	}
	;

 

%%
int main(int argc,char *argv[])
{

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	asmout.open("code.asm");
	errout.open("error.txt");

	yyin = fin;
	yyparse();
	fclose(yyin);
	

	asmout.close();
	errout.close();
	return 0;
}

