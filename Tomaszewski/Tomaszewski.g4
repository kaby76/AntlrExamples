grammar Tomaszewski;

s : e|u|;
e : a b| b a;
a : z a z | A;
b : z b z | B;
u : z u z | z;
z : A | B;

A: 'a';
B: 'b';
