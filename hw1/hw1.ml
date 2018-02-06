(*homework 1 due date: 2018/01/18*)

let rec contain a b = match b with
  |  [] -> false
  |  start::rest -> (a=start) || (contain a rest);;
(* tests if a is in b b=list *)

let rec subset a b = match a with
  | []->true
  | start::rest -> (contain start b) && (subset rest b);;

let equal_sets a b = (subset a b)&& (subset b a);;
(*a bit of math here: two sets are equal iff eihter is subset of the other*)

let set_union a b = a@b;;
(*kind of trick here as we ignore duplicates so direcly merge a b together *)

let rec set_intersection a b = match a with
  | []->[]
  | start::rest-> if(contain start b) then start::(set_intersection rest b) else set_intersection  rest b;;

let rec set_diff a b = match a with
  | []->[]
  | start::rest-> if not(contain start b) then start::(set_diff rest b) else set_diff rest b;;
 (*basically the same as set_intersection except that the condition is opposite*)

let rec computed_fixed_point eq f x =
  if eq (f x) x then x
  else computed_fixed_point eq f (f x);;
(*would be infinity if there is no  point*)

let rec calp f p x = if p=0 then x else f(calp f (p-1) x);;
let rec computed_periodic_point eq f p x= 
  if eq (calp f p x) x then x
  else computed_periodic_point eq f p (f x);;


let rec while_away s p x = match p x with
  | false ->[]
  | true ->x::(while_away s p (s x));;


let rec runlength a b = match a with
 | 0 -> []
 | _-> b::(runlength (a-1) b);;

let rec rle_decode lp = match lp with
 | []->[]
 | start::rest-> (runlength (fst start) (snd start))@ rle_decode rest;;




(*real problem here*)
type ('nonterminal, 'terminal) symbol =
 | N of 'nonterminal
 | T of 'terminal


let safesymbol symb list = match symb with
 | T _ ->true
 | N name -> contain name list;;

let rec saferule rule list = match rule with
 | [] -> true
 | start::rest ->(safesymbol start list) && (saferule rest list) 

let rec build a list = match a with
 | []->list
 | (f,s)::rest -> if (saferule s list) && not (contain f list) then (build rest (f::list)) else build rest list;;

let finalbuild (a,list) = (a,(build a list));;

let equal (a,b) (c,d) = equal_sets b d;;

let rec create rules list newlist = match rules with
 | []-> newlist
 | start::rest -> if (saferule (snd start) list) then (create rest list (newlist@[start])) else (create rest list newlist);;
 (* add rules to the safe list if it is safe*)							 


let filter_blind_alleys g = (fst g), (create (snd g) (snd (computed_fixed_point equal finalbuild ((snd g),[])))[]);;


