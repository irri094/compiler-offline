int main(){
    int a,b,c[20],i;
    c[0] = 0;
    for(i=1;i<=10;i++){
        c[i] = i;
        a = c[i-1];
        b = c[i];
        c[i] = a + b; 
    	a = c[i];
    	println(a);
    }
    println(a);
    println(b);
}


