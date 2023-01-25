grammar SuperArithmetic;

import Arithmetic;

file_ : expression EOF; // override parser rule to allow only one expression.
STRING : '"' .*? '"' ; // override lexer rule to only allow double quotes for a string.
