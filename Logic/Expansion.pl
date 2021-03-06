% A self contained computer algebra system for simple functions
% Gabriel Henderson and Dominic Kuang
% Note: parts of the differentiation and eval predicates
% were taken/modified from the solutions to Assignment 3

% Note: predicates ending with 0 are internal predicates,
% not to be invoked by the user.

% =======================================================================
% Expansion
% =======================================================================

% Helper function for expand, this part expands the
% input assuming that it has first been "flattened".
expand0(N, N) :- number(N).
expand0(A, A) :- atom(A).
expand0((E1 + E2)^N, B) :-
	number(N),
	binom0((E1 + E2)^N, N, B).
expand0(X + Y, N) :-
	expand0(X, EX), expand0(Y, EY),
	number(EX), number(EY),
	N is EX + EY.
expand0(X + Y, EX + EY) :-
	expand0(X, EX), expand0(Y, EY).
expand0(X - Y, N) :-
	expand0(X, EX), expand0(Y, EY),
	number(EX), number(EY),
	N is EX - EY.
expand0(X - Y, EX - EY) :-
	expand0(X, EX), expand0(Y, EY).
expand0(X * Y, N) :-
	expand0(X, EX), expand0(Y, EY),
	number(EX), number(EY),
	N is EX * EY.
expand0(X * (Y * Z), X*Y*EZ) :-
	expand0(Z, EZ).
expand0(X * (Y + Z), XE * YE + XE*ZE) :-
	expand0(X, XE), expand0(Y, YE), expand0(Z, ZE).
expand0((Y + Z) * X, XE * YE + XE*ZE) :-
	expand0(X, XE), expand0(Y, YE), expand0(Z, ZE).
expand0(X * (Y - Z), XE * YE - XE*ZE) :-
	expand0(X, XE), expand0(Y, YE), expand0(Z, ZE).
expand0((Y - Z) * X, XE * YE - XE*ZE) :-
	expand0(X, XE), expand0(Y, YE), expand0(Z, ZE).
expand0(X * Y, EX * EY) :-
	expand0(X, EX), expand0(Y, EY).
expand0(X, X).