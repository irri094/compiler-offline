bison -d -y -v 1705094.y
echo '1'
g++ -std=c++17 -w -c -o y.o y.tab.c
echo '2'
flex 1705094.l		
echo '3'
g++ -std=c++17 -w -c -o l.o lex.yy.c
echo '4'
g++ -std=c++17 -o a.out y.o l.o -lfl
echo '5'
./a.out input.c
echo '6'
g++ -std=c++17 -o opti.out optimizer.cpp
echo '7'
./opti.out code.asm
