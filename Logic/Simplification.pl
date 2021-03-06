% A self contained computer algebra system for simple functions
% Gabriel Henderson and Dominic Kuang
% Note: parts of the differentiation and eval predicates
% were taken/modified from the solutions to Assignment 3

% Note: predicates ending with 0 are internal predicates,
% not to be invoked by the user.

% =======================================================================
% Simplification
% =======================================================================

% Helper function for simplify.
% Same functionality/usage.
simplify0(X, X) :-
	atomic(X).
simplify0(N * A, N * VA) :-
	number(N), simplify0(A, VA).
simplify0(A + B, V) :-
	simplify0(A, VA),
	simplify0(B, VB),
	simp_vals0(VA + VB, V).
simplify0(A - B, V) :-
	simplify0(A, VA),
	simplify0(B, VB),
	simp_vals0(VA + VB, V).
simplify0(A * B, V) :-
	simplify0(A, VA),
	simplify0(B, VB),
	simp_vals0(VA * VB, V).
	
% Reduce fractions if possible. First tries to evaluate to a integer,
% then by dividing by the gcd0, otherwise does nothing.
simplify0(N / D, R) :-
    simplify0(N, RN),
    simplify0(D, RD),
    gcd(RN, RD, G),
    number(G),
    A is RN / G,
    B is RD / G,
    evaluate_fraction0(A, B, R),
    number(R).
simplify0(N / D, A/B) :-
    simplify0(N, RN),
    simplify0(D, RD),
    gcd(RN, RD, G),
    number(G),
    A is RN / G,
    B is RD / G.
simplify0(A / B,V) :-
    simplify0(A, VA),
    simplify0(B, VB),
    simp_vals0(VA / VB, V).
simplify0(_^0, 1).
simplify0(A^1, VA) :-
	simplify0(A, VA).
simplify0(A^B, V) :-
    simplify0(A, VA),
    simplify0(B, VB),
    simp_vals0(VA^VB, V).
simplify0(A, A).

% simplify_vals(Exp, Exp2) is true if expression Exp simplifies to Exp2,
% where the arguments to Exp have already been simplified
simp_vals0(0 + V, V).
simp_vals0(V + 0, V).
simp_vals0(0 - V, V).
simp_vals0(V - 0, V).
simp_vals0(A + B, AB) :-
    number(A), number(B),
    AB is A + B.
simp_vals0(A - B, AB) :-
    number(A), number(B),
    AB is A - B.
simp_vals0(0 * _, 0).
simp_vals0(_ * 0, 0).
simp_vals0(V * 1, V).
simp_vals0(1 * V, V).
simp_vals0(A * B, AB) :-
    number(A), number(B),
    AB is A * B.
	
% Because division can easily create non-integer numbers,
% and clutter the output, we ignore any division that results in floats.
simp_vals0(A / B, AB) :-
    B \= 0,
    number(A), number(B),
    AB is A / B,
    integer(AB).
simp_vals0(A / B, A / B).
simp_vals0(A^B, R) :-
	number(A), number(B), R is A ** B.
simp_vals0(X, X).