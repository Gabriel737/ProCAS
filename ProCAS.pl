% A self contained computer algebra system for simple functions
% Gabriel Henderson and Dominic Kuang
% Note: parts of the differentiation and eval predicates
% were taken/modified from the solutions to Assignment 3

% Note: predicates ending with 0 are internal predicates,
% not to be invoked by the user.

% =======================================================================
% INCLUDE NEEDED LOGIC
% =======================================================================
:- include(Tools)
:- include(Logic/Simplifcation)
:- include(Logic/Substitution)
:- include(Logic/Expansion)
:- include(Logic/Differentiation)
:- include(Logic/Integration)


% =======================================================================
% MAIN FUNCTIONALITY
% =======================================================================

% Diff(E, X, D) is true if D is the (partial) derivative
% of E with respect to the variable X.
% For numerical differentiation, use arguement X=A to evaluate at A.
diff(E, X=A, V) :-
	diff0(E, X, D), eval(D, X=A, V), !.
diff(E, X, D) :-
	diff0(E, X, D0), simplify0(D0, D), !.
% The fundamental theorem of calculus part I
diff(int(E, X, _), X, E).

% Expand(E, R) is true if R is the expanded
% version of E with no nested multiplication
expand(E, R) :- denest0(E, E, R).

% Simplify(E, S) is true if expression E simplifies to
% expression S, where S is the normal form of E. The normal form
% S of an expression E  satisifies the following:
% 1. No occurences of 1*, 0*, 0+, 0-, ^1, or ^0
% 2. All coefficients appear to the left of each term
% 3. All numerical expressions are evaluated eagerly
% 4. All powers are combined

% This first line is here to prevent the inefficiency of expanding
% expressions like x^4 during the simplification process,
% which cannot be simplified more anyways.
simplify(X^N, X^N).
simplify(Exp, Result) :-
	expand_powers0(Exp, EP), expand(EP, E),
	simplify0(E, S), combine_powers0(S, Result), !.
simplify(Exp, Exp).

% Sub(E, L, V) is true if expression E is equivalent to V given a
% list of variable substitutions L (e.g. L = [x=r,y=s]).
% Shorthand availible for single substitutions: use X=A in place of L
sub(E, X=A, V) :-
	sub0(E, [X=A], V), !.
sub(X, L, V) :-
	sub0(X, L, V), !.

% Eval(Exp, L, V) is true if expression Exp evaluates to V given a
% list of variable assignments L (e.g. L = [x=1,y=2]). These variable
% assignments MUST be numerical, not symbolic.
% Shorthand availible for single evaluations: use X=A in place of L
eval(E, X=A, V) :-
	sub(E, X=A, S), V is S, !.
eval(E, L, V) :-
	sub(E, L, S), V is S, !.

% Newton(E, X=X0, N, A) is true if A is the root found by Newton's
% method after begining initial guess X=X0 and iterating N times.
newton(_, _=X0, 0, X0).
newton(E, X=X0, N, A) :-
	N > 0, N1 is N - 1,
	newton(E, X=X0, N1, XN),
	eval(E, X=XN, F), diff(E, X=XN, D),
	A is XN - F / D, !.

% Taylor(E, X=X0, N, T) is true if T is the N-th order Taylor
% Polynomial for E with respect to X about X = X0.
taylor(E, X=X0, N, T) :-
	taylor0(E, X=X0, N, T0), simplify0(T0, T), !.

% gcd(N1, N2, CF) is true with number N1 and N2 share the greatest
% common divisor of integer CF. Note that for the gcd of 0, we return 1.
gcd(0, _, 1).
gcd(_, 0, 1).
gcd(CF, CF, CF) :-
	number(CF).
gcd(A, B, G) :-
	number(A), number(B), A > B, C is A - B, gcd(C, B, G).
gcd(A, B, G) :-
	number(A), number(B), B > A, C is B - A, gcd(C, A, G).

% Factorial(N, F) is true if F = N!
factorial(0, 1).
factorial(N, F) :-
	N > 0, N1 is N-1,
	factorial(N1, F1),
	F is N * F1.

% Choose(N, K, C) is true if C is C(N, K)
% This is the binomial coefficient.
choose(N, K, 0) :-
	K > N.
choose(N, K, C) :-
	K < N + 1, NMK is N-K,
	factorial(N, NF), factorial(K, KF), factorial(NMK, NMKF),
	C is NF / (KF * NMKF).