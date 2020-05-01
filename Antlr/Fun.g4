grammar Fun;

// Grammar (4.19) from Aho, A.V., Lam, M.S.
// and Sethi, R., Ullman. JD (2006),
// Compilers. Principles, Techniques, and Tools.

s : a A | B ;
a : B D a1 | a1 ;
a1 : C a1 | A D a1 | ;

q : q A B | q B C | D | E | ;

A : 'a';
B : 'b';
C : 'c';
D : 'd';
