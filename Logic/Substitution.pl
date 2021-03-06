% A self contained computer algebra system for simple functions
% Gabriel Henderson and Dominic Kuang
% Note: parts of the differentiation and eval predicates
% were taken/modified from the solutions to Assignment 3

% Note: predicates ending with 0 are internal predicates,
% not to be invoked by the user.

% =======================================================================
% Substitution
% =======================================================================

% Helper function for sub
% Has same usage/function as sub.
sub0(X, L, V) :-
	member(X=V, L).
sub0(N, _, N) :-
	number(N).
sub0(-E, L, -V) :-
	sub0(E, L, V).
sub0(A + B, L, V) :-
	sub0(A, L, V1),
	sub0(B, L ,V2),
	V = V1 + V2.
sub0(A - B, L, V) :-
	sub0(A, L, V1),
	sub0(B, L ,V2),
	V = V1 + V2.
sub0(A * B, L, V) :-
	sub0(A, L, V1),
	sub0(B, L, V2),
	V = V1 * V2.
sub0(A / B, L, V) :-
	sub0(A, L, V1),
	sub0(B, L, V2),
	V = V1 / V2.
	
% Once again, there is no way to do this generally
sub0(e^E, L, e^S) :-
	sub0(E, L, S).
sub0(E^N, L, S^N) :-
	sub0(E, L, S).
sub0(A^E, L, A^S) :-
	sub0(E, L, S).
sub0(sqrt(E), L, sqrt(S)) :-
	sub0(E, L, S).
sub0(sin(E), L, sin(S)) :-
	sub0(E, L, S).
sub0(cos(E), L, cos(S)) :-
	sub0(E, L, S).
sub0(tan(E), L, tan(S)) :-
	sub0(E, L, S).
sub0(cot(E), L, cot(S)) :-
	sub0(E, L, S).
sub0(sec(E), L, sec(S)) :-
	sub0(E, L, S).
sub0(csc(E), L, csc(S)) :-
	sub0(E, L, S).
sub0(e^E, L, e^S) :-
	sub0(E, L, S).
sub0(log(E), L, log(S)) :-
	sub0(E, L, S).
sub0(E, _, E).