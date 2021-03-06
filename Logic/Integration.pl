% A self contained computer algebra system for simple functions
% Gabriel Henderson and Dominic Kuang
% Note: parts of the differentiation and eval predicates
% were taken/modified from the solutions to Assignment 3

% Note: predicates ending with 0 are internal predicates,
% not to be invoked by the user.

% =======================================================================
% Integration Logic
% =======================================================================

% Int(E, X, I) is true if I is the integral of
% E with respect to the variable X
% Simplification of input to int0 is handled by diff(I0, X, E)
% For numerical integration, use arguments X=A and X=b for limits of
% integration.
int(E, X=A, X=B, V) :-
	int0(E, X, D), eval(D, X=A, V1), eval(D, X=B, V2), V is V2 - V1, !.
int(E, X, I) :-
	int0(E, X, I0), simplify(I0, I), !.
% The fundamental theorem of calculus part II
int(diff(E, X, _), X, E).

% This is for demonstration purposes.
int_simple(E, X, I) :- diff0(I, X, E), !.
int_simple(E, X, diff(?, X, E)).

% Integration is defined in terms of differentiation!
% Prolog will querty the search function space for an antiderivative
% This is based on the Fundamental Theorem of calculus
% Note: will fail on overly complicated functions due to stack size limitations
int0(E, X, I) :-
	diff(I, X, E).
int0(N * E, X, N * I) :-
	number(N), int0(E, X, I).
int0(N * E, X, N * I) :-
	atom(N), dif(N, X), int0(E, X, I).
int0(E1 + E2, X, I1 + I2) :-
	int0(E1, X, I1), int0(E2, X, I2).
int0(E1 - E2, X, I1 - I2) :-
	int0(E1, X, I1), int0(E2, X, I2).