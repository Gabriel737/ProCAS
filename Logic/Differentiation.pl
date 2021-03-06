% A self contained computer algebra system for simple functions
% Gabriel Henderson and Dominic Kuang
% Note: parts of the differentiation and eval predicates
% were taken/modified from the solutions to Assignment 3

% Note: predicates ending with 0 are internal predicates,
% not to be invoked by the user.

% =======================================================================
% Differentiation Logic
% =======================================================================

% Basic rules of differentiation
diff0(E, _, 0) :-
	number(E).
diff0(E, X, 0) :-
	atomic(E), dif(E, X).
diff0(C * E, X, C * D) :-
	number(C), diff0(E, X, D).
diff0(E1 + E2, X, D1 + D2) :-
	diff0(E1, X, D1), diff0(E2, X, D2).
diff0(E1 - E2, X, D1 - D2) :-
	diff0(E1, X, D1), diff0(E2, X, D2).
diff0(E1 * E2, X, D1 * E2 + E1 * D2) :-
	diff0(E1, X, D1), diff0(E2, X, D2).
diff0(E1 / E2, X, (D1 * E2 - E1 * D2) / (E2^2)) :-
	diff0(E1, X, D1), diff0(E2, X, D2).
	
% Chain rule must be implemented function by function;
% there is no way to have a generalized chain rule according to
% The Art of Prolog: Advanced Programming Techniques, page 81-82
diff0(F^N, X, N*F^NN * DF) :-
	NN is N - 1, diff0(F, X, DF), !.
diff0(F^Y, X, Y*F^(Y - 1) * DF) :-
	diff0(F, X, DF).
diff0(A^X, X, log(A) * A^X).
diff0(sqrt(F), X, 0.5 * sqrt(F)* DF) :-
	diff0(F, X, DF).
diff0(sin(F), X, cos(F) * DF) :-
	diff0(F, X, DF).
diff0(cos(F), X, -sin(F) * DF) :-
	diff0(F, X, DF).
diff0(tan(F), X, sec(x)^2 * DF) :-
	diff0(F, X, DF).
diff0(cot(F), X, -csc(X)^2 * DF) :-
	diff0(F, X, DF).
diff0(sec(F), X, sec(F) * tan(F) * DF) :-
	diff0(F, X, DF).
diff0(csc(F), X, -csc(F) * cot(F) * DF) :-
	diff0(F, X, DF).
diff0(e^F, X, e^F * DF) :-
	diff0(F, X, DF).
diff0(log(F), X, (1/F) * DF) :-
	diff0(F, X, DF).
	
% Derivatives of essential functions
diff0(X, X, 1).
diff0(X^N, X, N*X^N1) :-
	number(N), N1 is N - 1.
diff0(X^Y, X, Y*X^(Y - 1)).
diff0(e^X, X, e^X).
diff0(A^X, X, log(A) * A^X).
diff0(sqrt(X), X, frac(1, 2 * sqrt(X))).
diff0(sin(X), X, cos(X)).
diff0(cos(X), X, -sin(X)).
diff0(tan(X), X, sec(X)^2).
diff0(cot(X), X, -csc(X)^2).
diff0(sec(X), X, sec(X) * tan(X)).
diff0(csc(X), X, -csc(X) * cot(X)).
diff0(e^X, X, e^X).
diff0(log(X), X, 1 / X).

