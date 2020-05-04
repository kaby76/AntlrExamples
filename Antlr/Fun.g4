grammar Fun;

// Grammar (4.19) from Aho, A.V., Lam, M.S.
// and Sethi, R., Ullman. JD (2006),
// Compilers. Principles, Techniques, and Tools.

s :
    a A 
    | B  // Comment
    ;
a :
    a C
    | s D
    |
    ;

// Order [s, a]
// 1) Indirect Substitution (s => a):
//      s -> a A | B ;
//      a -> a C | a A D | B D | ;
// 2) Direct recursion removal:
//      s -> a A | B ;
//      a -> B D a1 | a1 ;
//      a1 -> C a1 | A D a1 | ;
// 3) Kleene:
//      s -> a A | B ;
//      a -> B D a1 | a1 ;
//      a1 -> (C | A D )* ;
// 4) Subsitute & removal "a" :
//      s -> B D a1 A | a1 A | B ;
//      a1 -> (C | A D )* ;
// 5) Substitute & removal "a1":
//      s -> B D (C | A D)* A | (C | A D)* A | B;
// 6) "Normalize?"
//      
//
// Order [a, s]
// 1) Direct recursion removal:
//      a -> s D a1 | a1 ;
//      a1 -> C a1 | ;
//      s -> a A | B ;
// 2) Indirect Substitution (a => s):
//      a -> s D a1 | a1 ;
//      a1 -> C a1 | ;
//      s -> s D a1 A | a1 A | B ;
// 3) Direct recursion removal:
//      a -> s D a1 | a1 ;
//      a1 -> C a1 | ;
//      s -> a1 A s1 | B s1 ;
//      s1 -> D a1 A s1 | ;
// 4) Removal "a" (useless production):
//      a1 -> C a1 | ;
//      s -> a1 A s1 | B s1 ;
//      s1 -> D a1 A s1 | ;
// 5) Kleene of a1 & s1:
//      a1 -> C* ;
//      s -> a1 A s1 | B s1 ;
//      s1 -> (D a1 A)* ;
// 6) Substitute & removal "a1":
//      s -> C* A s1 | B s1 ;
//      s1 -> (D C* A)* ;
// 7) Substitute & removal "s1":
//      s -> C* A (D C* A)* | B (D C* A)* ;
// 8) "Normalize?"
//      s -> B (D C* A)* |  C* A (D C* A)* ;
//


// p : p A B | p B C | D | E | ;
// q : A B q | B C q | D | E | ;
p : p A B | p B C | D | E | ;
q : A B q | B C q | D | E | ;

A : 'a';
B : 'b';
C : 'c';
D : 'd';
E : 'e';
