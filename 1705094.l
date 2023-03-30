%option yylineno
%{
#include <bits/stdc++.h>
#include "1705094.h"

#define YYSTYPE SymbolInfo*

#include "y.tab.h"

using namespace std;

extern YYSTYPE yylval;
extern SymbolTable *table;
void yyerror(char *);

// SymbolTable ST(7);
int errcount = 0, linenum;
string curstring, curlexem;	
ofstream tokenout;

// extern ofstream logout;
extern ofstream errout;

char getrealchar(string s, int id=2){
	if(s[id]=='n') return '\n';
	if(s[id]=='t') return '\t';
	if(s[id]=='\\') return '\\';
	if(s[id]=='\'') return '\'';
	if(s[id]=='\"') return '\"';
	if(s[id]=='a') return '\a';
	if(s[id]=='f') return '\f';
	if(s[id]=='r') return '\r';
	if(s[id]=='b') return '\b';
	if(s[id]=='v') return '\v';
	if(s[id]=='0') return '\0';
	return '\0';
}

// void keyword(string token, string lexeme=yytext){
// 	for(char &ch : token) ch = toupper(ch);
// 	tokenout<< "<"<<token<<"> ";
// 	logout<< "\nLine no "<<yylineno<<": Token <"<<token<<"> Lexeme "<<lexeme<<" found\n";
// }

// void conostant(string token, string lexeme=yytext){
// 	tokenout<< "<"<<token<<", "<<lexeme<<"> ";
// 	logout<< "\nLine no "<<yylineno<<": Token <"<<token<<"> Lexeme "<<lexeme<<" found\n";
	
// 	if(ST.insert(yytext, token))
// 		ST.printAllscope(logout);	
// }

// void conostantchar(string token, string lexeme, string real){
// 	tokenout<< "<"<<token<<", "<<real<<"> ";
// 	logout<< "\nLine no "<<yylineno<<": Token <"<<token<<"> Lexeme "<<lexeme<<" found\n";	
	
// 	if(ST.insert(lexeme, token)){
// 		ST.printAllscope(logout);
// 	}
// }

// void identifier(string token, string lexeme = yytext){
// 	tokenout<< "<"<<token<<", "<<lexeme<<"> ";	
// 	logout<< "\nLine no "<<yylineno<<": Token <"<<token<<"> Lexeme "<<lexeme<<" found\n";
// 	if(ST.insert(yytext, token))
// 		ST.printAllscope(logout);	
// }

// void punc_op(string token, string lexeme = yytext){
// 	tokenout<< "<"<<token<<", "<<lexeme<<"> ";
// 	logout<< "\nLine no "<<yylineno<<": Token <"<<token<<"> Lexeme "<<lexeme<<" found\n";
// 	if(token=="LCURL") ST.EnterScope();
// 	if(token=="RCURL") ST.ExitScope();
// }


// void stringfound(string s, string lexeme){
// 	s = "\"" + s + "\"";
// 	tokenout<< "<STRING, "<<s<<"> ";
// 	logout<<"\nLine no "<<linenum<<": Token <STRING> Lexeme "<<lexeme<<" found\n";
// }

void commentfound(string lexeme){
	// logout<<"\nLine no "<<linenum<<": Token <COMMENT> Lexeme "<<lexeme<<" found\n";
}

void err_message(string msg, string lexeme=yytext){
	errcount++;
	errout<<"\nError at line no "<<yylineno<<": ";
	errout<<msg<<" "<<lexeme<<"\n";
}

void err_message2(string msg, string lexeme=yytext){
	errcount++;
	errout<<"\nError at line no "<<linenum<<": ";
	errout<<msg<<" "<<lexeme<<"\n";
}	

%}

Whitespace [ \t\n]+
Newline (\r\n)|(\n)
Letter [a-zA-Z]
Digit [0-9]
AlphaNumeric [a-zA-Z0-9]
Intejer {Digit}+
Poww (E|e)[+-]?{Intejer}
Flooot {Digit}*\.{Intejer}
BeshiPoint {Digit}*\.{Digit}*\.(\.|{Digit})*
Backslashchar \'\\[0vbrfa\'\"\\tn]\'
Notnewline [^\r\n]

%x SINGLECOM
%x MULTICOM
%x STRING

%%
{Whitespace}|{Newline} {}

"if" { yylval = new SymbolInfo(yytext, "IF"); yylval->linenumber = yylineno; return IF;}
"for" { yylval = new SymbolInfo(yytext, "FOR"); yylval->linenumber = yylineno; return FOR;}
"do" { yylval = new SymbolInfo(yytext, "DO"); yylval->linenumber = yylineno; return DO;}
"int" { yylval = new SymbolInfo(yytext, "INT"); yylval->linenumber = yylineno; return INT;}
"float" { yylval = new SymbolInfo(yytext, "FLOAT"); yylval->linenumber = yylineno; return FLOAT;}
"void" { yylval = new SymbolInfo(yytext, "VOID");yylval->linenumber = yylineno; return VOID;}
"switch" { yylval = new SymbolInfo(yytext, "SWITCH");yylval->linenumber = yylineno; return SWITCH;}
"default" { yylval = new SymbolInfo(yytext, "DEFAULT"); yylval->linenumber = yylineno;return DEFAULT;}
"else" { yylval = new SymbolInfo(yytext, "ELSE");yylval->linenumber = yylineno; return ELSE;}
"while" { yylval = new SymbolInfo(yytext, "WHILE");yylval->linenumber = yylineno; return WHILE;}
"break" { yylval = new SymbolInfo(yytext, "BREAK");yylval->linenumber = yylineno; return BREAK;}
"char" { yylval = new SymbolInfo(yytext, "CHAR");yylval->linenumber = yylineno; return CHAR;}
"double" { yylval = new SymbolInfo(yytext, "DOUBLE");yylval->linenumber = yylineno; return DOUBLE;}
"return" { yylval = new SymbolInfo(yytext, "RETURN");yylval->linenumber = yylineno; return RETURN;}
"case" { yylval = new SymbolInfo(yytext, "CASE");yylval->linenumber = yylineno; return CASE;}
"continue" { yylval = new SymbolInfo(yytext, "CONTINUE"); yylval->linenumber = yylineno; return CONTINUE;}
"printf" { yylval = new SymbolInfo(yytext, "PRINTLN");yylval->linenumber = yylineno; return PRINTLN;}
"println" { yylval = new SymbolInfo(yytext, "PRINTLN");yylval->linenumber = yylineno; return PRINTLN;}


{Intejer}	{
			//string token = "CONST_INT", lexeme = yytext;
			//conostant(token);
			yylval = new SymbolInfo(yytext, "CONST_INT");yylval->linenumber = yylineno;
			return CONST_INT;
		}
({Flooot}|{Intejer}){Poww}?	{
		//string token = "CONST_FLOAT", lexeme = yytext;
		//conostant(token);
		yylval = new SymbolInfo(yytext, "CONST_FLOAT");yylval->linenumber = yylineno;
		return CONST_FLOAT;
	}

{BeshiPoint}{Poww}*	{
		err_message("Too many decimal points");
	}

({Flooot}|{Intejer}){Poww}\.({Flooot}|{Intejer}) {
		err_message("Ill formed number");	
	}



{Backslashchar} {
		string real = "";
		real += getrealchar(yytext);
		string token = "CONST_CHAR";
		string lexeme = yytext;
		//conostantchar(token, lexeme, real);	
		yylval = new SymbolInfo(real, "CONST_CHAR");yylval->linenumber = yylineno;
		return CONST_CHAR;
	}
\'[^\'\\\n\r]\' 	{
		string real = "";
		real += yytext[1];
		string token = "CONST_CHAR";
		string lexeme = yytext;
		//conostantchar(token, lexeme, real);	
		yylval = new SymbolInfo(real, "CONST_CHAR");yylval->linenumber = yylineno;
		return CONST_CHAR;
	}
\'\' 	{
		err_message("Empty character constant error");
	}
\'\\\'	{
		linenum = yylineno - 1;
		err_message2("Unterminated character");
	}

\'[^\'\n]*{Newline}	{
		linenum = yylineno - 1;
		err_message2("Unterminated character");
	}
		
\'({Notnewline}{Notnewline}+)\' {
		err_message("Multi character constant error");	
	}


"+" |
"-"	{
		//punc_op("ADDOP");
		yylval = new SymbolInfo(yytext, "ADDOP");yylval->linenumber = yylineno;
		return ADDOP;
	}
"*" |
"/" |
"%" 	{ 
		//punc_op("MULOP"); 
		yylval = new SymbolInfo(yytext, "MULOP");yylval->linenumber = yylineno;
		return MULOP;
	}
"++" { 
		//punc_op("INCOP"); 
		yylval = new SymbolInfo(yytext, "INCOP");yylval->linenumber = yylineno;
		return INCOP;
	}
"--" 	{ 
		//punc_op("INCOP"); 
		yylval = new SymbolInfo(yytext, "DECOP");yylval->linenumber = yylineno;
		return DECOP;
	}
"<" |
"<=" |
">" |
">=" |
"==" |
"!=" 	{
		//punc_op("RELOP"); 
		yylval = new SymbolInfo(yytext, "RELOP");yylval->linenumber = yylineno;
		return RELOP;
 	}
"=" 	{ 
		//punc_op("ASSIGNOP"); 
		yylval = new SymbolInfo(yytext, "ASSIGNOP");yylval->linenumber = yylineno;
		return ASSIGNOP;
	}
"&&" |
"||" 	{ 
		//punc_op("LOGICOP"); 
		yylval = new SymbolInfo(yytext, "LOGICOP");yylval->linenumber = yylineno;
		return LOGICOP;
	}
"&" |
"|" |
"^" |
"<<" |
">>" 	{ 
		//punc_op("BITOP"); 
		yylval = new SymbolInfo(yytext, "BITOP");yylval->linenumber = yylineno;
		return BITOP;
	}
"!" 	{
	 	//punc_op("NOT"); 
		yylval = new SymbolInfo(yytext, "NOT");yylval->linenumber = yylineno;
		return NOT;
	}
"(" 	{ 
		//punc_op("LPAREN");
		yylval = new SymbolInfo(yytext, "LPAREN");yylval->linenumber = yylineno;
		return LPAREN;
	}
")" 	{ 
		//punc_op("RPAREN"); 
		yylval = new SymbolInfo(yytext, "RPAREN");yylval->linenumber = yylineno;
		return RPAREN;
	}
"{" 	{ 
		//punc_op("LCURL"); 
		yylval = new SymbolInfo(yytext, "LCURL");yylval->linenumber = yylineno;
		return LCURL;
	}
"}" 	{ 
		//punc_op("RCURL"); 
		yylval = new SymbolInfo(yytext, "RCURL");yylval->linenumber = yylineno;
		return RCURL;
	}
"[" 	{ 
		//punc_op("LTHIRD"); 
		yylval = new SymbolInfo(yytext, "LTHIRD");yylval->linenumber = yylineno;
		return LTHIRD;
	}
"]" 	{ 
		//punc_op("RTHIRD"); 
		yylval = new SymbolInfo(yytext, "RTHIRD");yylval->linenumber = yylineno;
		return RTHIRD;
	}
"," 	{ 
		//punc_op("COMMA"); 
		yylval = new SymbolInfo(yytext, "COMMA");yylval->linenumber = yylineno;
		return COMMA;
	}
";" 	{ 
		//punc_op("SEMICOLON"); 
		yylval = new SymbolInfo(yytext, "SEMICOLON");yylval->linenumber = yylineno;
		return SEMICOLON;
	}
		

({Letter}|"_")+[a-zA-Z0-9_]* {
		//identifier("ID");
		yylval = new SymbolInfo(yytext, "ID");yylval->linenumber = yylineno;
		return ID;
	}
{Digit}+[a-zA-Z0-9_]+ {
		err_message("Invalid prefix on ID or invalid suffix on Number");
	}
			
\"	{
		curstring.clear();
		curlexem = yytext;
		linenum = yylineno;
		BEGIN STRING;
	}
	
<STRING>{Newline} 	{
		err_message2("Unterminated string", curlexem);	
		curstring.clear();
		curlexem.clear();	
		BEGIN INITIAL;
	}

<STRING>[^\"]	{
		curlexem += yytext, curstring += yytext;
	}

<STRING>\\{Newline} 	{
		curlexem += yytext;
	}



<STRING>\\[nt\'\"afrbv0] {
		curstring += getrealchar(yytext, 1);
		curlexem += yytext;
	}


	
<STRING>\" {
		curlexem += yytext;
		//stringfound(curstring, curlexem);
		curstring.clear();
		curlexem.clear();
		BEGIN INITIAL;
	}
	
<STRING><<EOF>> 	{
		err_message2("Unterminated string", curlexem);
		curlexem.clear();
		curstring.clear();
		BEGIN INITIAL;
	}

\/\/ 	{
		curlexem = yytext, linenum = yylineno;
		BEGIN SINGLECOM;
	}

<SINGLECOM>(\\{Newline}) {
	}
<SINGLECOM>[^\n] {
		curlexem += yytext;
	}
<SINGLECOM>{Newline} 	{
		commentfound(curlexem);
		curlexem.clear();
		BEGIN INITIAL;
	}
<SINGLECOM><<EOF>> 	{
		commentfound(curlexem);
		curlexem.clear();
		BEGIN INITIAL;
	}

\/\* 	{
		BEGIN MULTICOM;
		linenum = yylineno;
		curlexem = yytext;
	}

<MULTICOM>{Newline} 	{
		curlexem += yytext;
	}
	
<MULTICOM>. 	{
		curlexem += yytext;
	}

<MULTICOM>(\*\/) {
		curlexem += yytext;
		commentfound(curlexem);
		curlexem.clear();
		BEGIN INITIAL;
	}

<MULTICOM><<EOF>> {
		err_message2("Unterminated comment", curlexem);
		curlexem.clear();
		BEGIN INITIAL;
	}

.	{
		err_message("Unrecognized character");
	}

%%


int yywrap(void)
{
	return 1;
}