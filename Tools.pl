% A self contained computer algebra system for simple functions
% Gabriel Henderson and Dominic Kuang
% Note: parts of the differentiation and eval predicates
% were taken/modified from the solutions to Assignment 3

% Note: predicates ending with 0 are internal predicates,
% not to be invoked by the user.

% =======================================================================
% TOOLS FOR OTHER FUNCTIONS TO USE
% =======================================================================

	
% Helper function for taylor predicate.
% Computes the Nth term of the series and then
% recurses on the remaining N-1 terms.
taylor0(E, X=X0, N, T) :-
	N > 0, N1 is N - 1, taylor0(E, X=X0, N1, T1),
	diff(E, X=X0, D0), factorial(N, F),
	C is D0/F,
	T = T1 + C * (X - X0)^N, !.
taylor0(_, _, 0, 0).

% Denest0(E, Prev, Result) is true if Result is "flat",
% i.e. there are no more nested multiplications in Result
denest0(E, Prev, Result) :-
	expand0(E, Exp), Exp \= Prev,
	denest0(Exp, E, Result), !.
denest0(E, Prev, E) :-
	expand0(E, Exp), Exp = Prev, !.

% This is a helper function for expand0 in the case that
% we are expanding a binomial. Each call to the function with
% value k computes the C(N, K)*X^N*Y^N term and then recurses
binom0((_ + _)^_, 0, 0).
binom0((E1 + E2)^N, K, B) :-
	K > 0, K < N + 1, K1 is K - 1,
	binom0((E1 + E2)^N, K1, B1), choose(N, K, CNK),
	B = B1 + CNK * E1^N * E2^K, !.

% Evaluate_fraction0(N, D, R) is true if the fraction formed with
% numerator N and denominator D evaluates to the integer N. R is an
% empty list if it cannot be converted to an int, or if the base is 0.
evaluate_fraction0(_, 0, []).
evaluate_fraction0(N, D, N) :-
	number(N), number(D), V is N / D, integer(V).
evaluate_fraction0(_, []).

% Expand_powers0(X^N, Result) is true if X^N is flatted,
% i.e., Result = X * X * ... * X (N times).
expand_powers0(X * Y, PX * PY) :-
	expand_powers0(X, PX),
	expand_term_powers0(Y, PY).
expand_powers0(X, PX) :-
	expand_term_powers0(X, PX).

% Helper function that processes one term at a time
expand_term_powers0(X^1, X).
expand_term_powers0(X^N, X * XN) :-
	N > 1, NN is N - 1,
	expand_term_powers0(X^NN, XN).
expand_term_powers0(X, X).

% Combine_powers0(Exp, Result) simplifys the powers term by term
combine_powers0(A + B, AP + BPE) :-
	combine_powers0(A, AP), to_power0(B, BP), denest0(BP, BP, BPE).
combine_powers0(Exp, Result) :-
	to_power0(Exp, EP), denest0(EP, EP, Result).

% To_power0(Term, Result) is true if term Term simplifies to Result.
% The simplification done is such that x*x*x would be grouped to x^3,
% and all coefficients are multiplied together.
% Works with any number of variables.
% eg ?- to_power(3*12*x*y*z*y*x, D).
% D = 36*(x^2*(y^2*z^1)) .
to_power0(Term, Result) :-
    extract_variables0(Term, V),
    extract_vars0(Term, E),
    count_power_and_coefficient0(Term, E, V, Coefficient, _, ZZ),
    chain0(Term, V, R),
    simplify0(Coefficient * R * ZZ, Result).
to_power0(Term, Term).

% Count_power_and_coefficient0(Term, Variable, C, P) is true if
% term T contains variable Variable P times (and so P is the power of Variable).
% Coefficient is a number representing the coefficient of the ENTIRE term,
% as it doesn't make sense to determine the coefficient of one variable in a term.
% eg. ?- count_power_and_coefficient0(3*x*x*x*y*12, x, C, P).
% C = 36, P = 3.

% Multiply coefficients
count_power_and_coefficient0(Remainder * E, X, AllVars, Coefficient, Power, CN) :-
	number(E),
	count_power_and_coefficient0(Remainder, X, AllVars, RecursiveCoefficient, Power, CN),
	Coefficient is E * RecursiveCoefficient.
% Add number of occurences of Variable
count_power_and_coefficient0(Remainder * X, X, AllVars, Coefficient, Power, CN) :-
	count_power_and_coefficient0(Remainder, X, AllVars, Coefficient, RecursivePower, CN),
	Power is 1 + RecursivePower.
count_power_and_coefficient0(Remainder * Y, X, AllVars, Coefficient, Power, Y * CNT) :-
	\+ member(Y, AllVars),count_power_and_coefficient0(Remainder, X, AllVars, Coefficient, Power, CNT).
count_power_and_coefficient0(Remainder * _, X, AllVars, Coefficient, Power, CN) :-
	count_power_and_coefficient0(Remainder, X, AllVars, Coefficient, Power, CN).
count_power_and_coefficient0(Coefficient, _, _, Coefficient, 0, _) :-
	number(Coefficient).

% Base case - either just a number remaining, or an unknown variable.
count_power_and_coefficient0(X, X, _, 1, 1, 1).
count_power_and_coefficient0(Z, _, AllVars, 1, 0, 1) :-
	member(Z, AllVars).
count_power_and_coefficient0(Z, _, _, 1, 0, Z).

% Extract_variables0(Term, E) is true if term Term contains variable E.
extract_vars0(E, E) :-
	atomic(E), \+number(E).
extract_vars0(_ * Token, Token) :-
	atomic(Token), \+number(Token).
extract_vars0(Remaining*_, E) :-
	extract_vars0(Remaining, E).

% Extract_variables0(Term, List) is true if term T contains variables in
% list List. eg. ?- extract_variables0(3*y*z, List) List = [y, z].
extract_variables0(Term, L) :-
	setof(X, extract_vars0(Term, X), L).
extract_variables0(_, []).

% Term_to_power0(Term, Variable, Result) is true if term Term can group
% up every instances of variable Variable in the form Variable^Power,
% where Power is the number of times Variable appears in Term. eg.
% term_to_power0(3*x*y*z*x, x, R), R = x^2.
term_to_power0(Term, X, X^Power) :-
	count_power_and_coefficient0(Term, X, [], _, Power, _).

% Chain0(Term, VariableList, Result) is true if term T, given a variable
% list VariableList, can be grouped in powers into Result. The
% coefficient is dropped. eg. ?- chain0(3*x*x*y, [x, y], R) produces R =
% x^2*y^1*1
chain0(_, [], 1).
chain0(Term, [H|T], K * L) :-
	term_to_power0(Term, H, K), chain0(Term, T, L).
