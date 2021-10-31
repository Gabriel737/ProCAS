% A self contained computer algebra system for simple functions
% Gabriel Henderson and Dominic Kuang
% Note: parts of the differentiation and eval predicates
% were taken/modified from the solutions to Assignment 3

% Note: predicates ending with 0 are internal predicates,
% not to be invoked by the user.

% =======================================================================
% DEPRECATED: For reference only, use the new implementation instead!
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
% However, it does not work since Prolog runs out of stack space during
% the search for a function I that, when differentiated,
% simplifies to expression E. Thus Prolog is not suitable for this task!
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

% Handle case where it's just the variable with no coefficient.
add_coefficients(X, X, 1, 0) :-
	atomic(X), \+ number(X).
% Handle case with a coefficient
add_coefficients(C * X, X, C, 0) :-
	number(C).
% Since prolog doesn't have associativity rules, we also need the coefficient on the other side
add_coefficients(X*C, X, C, 0) :-
	number(C).
% Handle expressions. Recursively
add_coefficients(A+B, X, C, R1+R2) :-
	add_coefficients(A, X, C1, R1),
	add_coefficients(B, X, C2, R2), C is C1+C2.
add_coefficients(A * B, X, C, R1+R2) :-
	add_coefficients(A, X, C1, R1),
	add_coefficients(B, X, C2, R2), C is C1+C2.
add_coefficients(R, _, 0, R).

% group(E, X, D) is true if expression E groups variable X into an expression of the from
% D = C*X+R, where C is the number of occurences of X, and R is the remaining expression that couldn't be grouped.
group(E, X, C * X + R) :-
	add_coefficients(E, X, C, D), \+ (C is 0), simplify(D, R).
% Handles the case where C is 0, and so we can get rid of
% the 0 * X part of the expression.
group(E, X, R) :-
	add_coefficients(E, X, _, D), simplify(D, R).

% group_all(E, VarList, R) is true if expression E results in expression R,
% where R has all variables in the list VarList grouped together
% (that is, all variables are collected)

group_all(R, [], R).
group_all(E, [H|T], R) :-
	group(E, H, D), group_all(D, T, R).

simplicate(E, D) :-
	simplify(E, SX), extract_variables0(SX, EV), group_all(SX, EV, RD), simplify(RD, D).
