% get value of the square
square(Value,[Row|Col],Lists) :-
    nth(Row,Lists,Column),
    nth(Col,Column,Value).

% set the number of columns
setcolumn_p(_,[],_).
setcolumn_p(N,[Head|Rest],L) :- 
    length(Head,N),
    legal(L,Head),
    different(Head),
    setcolumn_p(N,Rest,L).

% set the range for every integer
legallist(1,L) :-
    append([1],[],L).
legallist(N,L) :- 
    NewN is N-1,
    NewN >= 1,
    legallist(NewN,RestL),
    append(RestL,[N],L).


% set each column only contains elements of different values.
diff([]).
diff([Head|Lists]) :-
    diff_each(Head,Lists),
    diff(Lists).

diff_each(_,[]).
diff_each(List,[Head|Rest]) :- 
    diff_each(List,Rest),
    diff_column(List,Head).

diff_column([],[]).
diff_column([Head1|Rest1],[Head2|Rest2]) :-
    Head1 =\= Head2,
    diff_column(Rest1,Rest2).

/*
legall(_,[]).
legall(L,[Head|Rest]) :-
    legal(L,Head),
    different(Head),
    legall(L,Rest).
*/

legal(_,[]).
legal(L,[Head|Rest]) :-
    member(Head,L),
    legal(L,Rest).


different([]).
different([Head|Rest]) :- 
    \+ (member(Head,Rest)),
    different(Rest).
    
constraints_p(_,[]).    
constraints_p(T,Lists) :-
    maplist(satisfy_p(T),Lists).

satisfy_p(_,+(0,[])).
satisfy_p(T,+(S,[Head|Rest])) :- 
    square(V,Head,T),
    satisfy_p(T,+(RestS,Rest)),
    S is V + RestS.

satisfy_p(_,*(1,[])).
satisfy_p(T,*(P,[Head|Rest])) :-
    square(V,Head,T),
    satisfy_p(T,*(RestP,Rest)),
    P is V*RestP.

% −(D, J, K)
satisfy_p(T,-(D,J,K)) :-
    square(V1,J,T),
    square(V2,K,T),
    (D is V1-V2;D is V2-V1).

% /(Q, J, K)
satisfy_p(T,/(Q,J,K)) :-
    square(V1,J,T),
    square(V2,K,T),
    (Q is V1/V2;Q is V2/V1).
    


plain_kenken(N,C,T) :- 
    length(T,N), % set number of rows
    legallist(N,L),
    setcolumn_p(N,T,L),
    diff(T),
    constraints_p(T,C).
    
