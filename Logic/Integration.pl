% A self contained computer algebra system for simple functions
% Gabriel Henderson and Dominic Kuang
% Note: parts of the differentiation and eval predicates
% were taken/modified from the solutions to Assignment 3

% Note: predicates ending with 0 are internal predicates,
% not to be invoked by the user.

% =======================================================================
% TOOLS: GCD, Factorial, N choose K
% =======================================================================

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