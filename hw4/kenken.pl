kenken(A,0,_,[]).    
kenken(A,B,[],[L|Rest]):-
    B#>0,
    length(L,A),
    fd_domain(L,1,A),
    fd_all_different(L),
    B1 is B - 1,
    kenken(A,B1,[],Rest),
    unique(L,Rest).
    
/* this creates a list of n lists that each has 1-n and make sure the columns are also different */

    
different([],[]).
different([Head1|Rest1],[Head2|Rest2]):-
    Head1 #\= Head2,
    different(Rest1,Rest2).
/*this compares two lists and see if the column are not same */
    
unique([],_).
unique(_,[]).  
unique(L,[Head|Rest]):-
    different(L,Head),
    unique(L,Rest).
    /* this determines if a list is different from all lists in the list*/

construct([]).
construct([L|Rest]):-
    fd_labeling(L),
    construct(Rest).


kenken(N,[],T) :-
    kenken(N,N,[],T),
    construct(T).
kenken(N,[Head|Rest],T):-
    kenken(N,N,[],T),
    kenken(N,0,0,[Head|Rest],T),
    construct(T).
    
kenken(N,0,0,[],_).
kenken(N,0,0,[Head|Rest],T):-
    logical(T,Head),
    kenken(N,0,0,Rest,T).
/*special /5 cases created for arithmetic constraint, save time by not calling kenken(N,[],T) again*/
    

logical(_,+(_,[])).
logical(T,+(S,L)):-    
    add(T,L,Value),
    S #= Value.
logical(_,*(_,[])).
logical(T,*(P,L)):-
    multiply(T,L,Value),
    P #= Value.
logical(_,-(_,[],_)).
logical(_,-(_,_,[])).    
logical(T,-(D,J,K)):-
    square(T,J,Value1),
    square(T,K,Value2),
    Value = Value1 - Value2,
    (D #= Value;D#= -Value).
    
logical(_,/(_,[],_)).
logical(_,/(_,_,[])).
logical(T,/(Q,J,K)):-
    square(T,J,Value1),
    square(T,K,Value2),
    Result1 = Value1/Value2,
    Result2 = Value2/Value1,
    (Result1#=Q;Result2#=Q).

square(T,[]).
square(T,[Row|Column],Value):-    
    nth1(Row,T,Row_List),
    nth1(Column,Row_List,Value).
	/*access the matching square of T*/
    
add([],_,0).
add(_,[],0).
add(T,[First|Rest],Value):-    
    square(T,First,Value1),
    add(T,Rest,Value2),
    Value = Value1 + Value2.

multiply([],_,1).
multiply(_,[],1).
multiply(T,[First|Rest],Value):-
    square(T,First,Value1),
    multiply(T,Rest,Value2),
    Value = Value1 * Value2.






plain_kenken(0,_,[]).
plain_kenken(N,[],T):-
    findall(Num,between(1,N,Num),ListN),
    plain_help(N,N,[],T,ListN).
plain_kenken(N,[Head|Rest],T):-
    plain_kenken(N,[],T),
    plain(N,0,[Head|Rest],T).


plain_help(_,0,_,[],_).
plain_help(A,B,[],[L|Rest],ListN):-
    B>0,
    length(L,A),
    plain_domain(L,ListN),
    plain_all_different(L),
    B1 is B-1,
    plain_help(A,B1,[],Rest,ListN),
    plain_unique(L,Rest).

plain(_,0,[],_).
plain(N,0,[Head|Rest],T):-
    plain_logical(T,Head),
    plain(N,0,Rest,T).

plain_domain([],_).
plain_domain([Head|Rest],ListN):-
    member(Head,ListN),
    plain_domain(Rest,ListN).

plain_all_different([]).
plain_all_different([H|R]):-
    \+(member(H,R)),
    plain_all_different(R).

plain_different([],[]).
plain_different([Head1|Rest1],[Head2|Rest2]):-
    Head1 \= Head2,
    plain_different(Rest1,Rest2).
/*this compares two lists and see if the column are not same */
    
plain_unique(_,[]).
plain_unique([],_).
plain_unique(L,[Head|Rest]):-
    plain_different(L,Head),
    plain_unique(L,Rest).
    /* this determines if a list is different from all lists in the list*/


plain_logical(_,+(_,[])).
plain_logical(T,+(S,L)):-    
    plain_add(T,L,Value),
    S =:= Value.
plain_logical(_,*(_,[])).
plain_logical(T,*(P,L)):-
    plain_multiply(T,L,Value),
    P =:= Value.
plain_logical(_,-(_,[],_)).
plain_logical(_,-(_,_,[])).    
plain_logical(T,-(D,J,K)):-
    square(T,J,Value1),
    square(T,K,Value2),
    Value is Value1 - Value2,
    (D =:= Value;D =:= -Value).
    
plain_logical(_,/(_,[],_)).
plain_logical(_,/(_,_,[])).
plain_logical(T,/(Q,J,K)):-
    square(T,J,Value1),
    square(T,K,Value2),
    Result1 is Value1/Value2,
    Result2 is Value2/Value1,
    (Result1 =:= Q;Result2 =:= Q).

plain_add([],_,0).
plain_add(_,[],0).
plain_add(T,[First|Rest],Value):-    
    square(T,First,Value1),
    plain_add(T,Rest,Value2),
    Value is Value1 + Value2.

plain_multiply([],_,1).
plain_multiply(_,[],1).
plain_multiply(T,[First|Rest],Value):-
    square(T,First,Value1),
    plain_multiply(T,Rest,Value2),
    Value is Value1 * Value2.



