grammar Fun;

// Grammar (4.19) from Aho, A.V., Lam, M.S.
// and Sethi, R., Ullman. JD (2006),
// Compilers. Principles, Techniques, and Tools.

s : a A | B;
a : a C | s D | ;

A : 'a';
B : 'b';
C : 'c';
D : 'd';
